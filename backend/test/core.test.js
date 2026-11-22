'use strict';
const {test, before, after, beforeEach} = require('node:test');
const assert = require('node:assert/strict');
const {initializeApp, deleteApp, cert} = require('firebase-admin/app');
const {generateKeyPairSync} = require('node:crypto');
const {getFirestore, Timestamp} = require('firebase-admin/firestore');
const {createCore, hashToken} = require('../src/core');
let app, db, core, now;
const request = (uid, data = {}, verified = true) => ({auth: uid ? {uid, token: {email_verified: verified}} : null, data});
const rejected = (promise, code) => assert.rejects(promise, error => error.code === code);
before(() => {
  if (!process.env.FIRESTORE_EMULATOR_HOST) throw Error('Emulator required.');
  // Ephemeral test key, never a real account or ambient credential lookup.
  const {privateKey} = generateKeyPairSync('rsa', {modulusLength: 2048,
    privateKeyEncoding: {type: 'pkcs8', format: 'pem'}, publicKeyEncoding: {type: 'spki', format: 'pem'}});
  app = initializeApp({projectId: 'demo-romanza', credential: cert({projectId: 'demo-romanza',
    clientEmail: 'emulator-only@example.invalid', privateKey})}, 'core-tests');
  db = getFirestore(app);
});
after(async () => { await deleteApp(app); });
beforeEach(async () => {
  for (const collection of await db.listCollections()) await db.recursiveDelete(collection);
  now = Date.now(); core = createCore(db, () => now);
  await db.doc('legal/current').set({version: 'v1', termsUrl: 'https://example.com/terms', privacyUrl: 'https://example.com/privacy'});
  for (const uid of ['a', 'b', 'c']) await db.doc(`users/${uid}`).set({uid, displayName: uid,
    coupleId: null, partnerId: null, activeInviteId: null,
    acceptedTermsVersion: 'v1', acceptedTermsAt: Timestamp.now()});
  for (const uid of ['a', 'b', 'c']) await db.doc(`users/${uid}/consents/v1`).set({version: 'v1', acceptedAt: Timestamp.now()});
});
test('all operations reject unauthenticated and unverified callers', async () => {
  for (const handler of Object.values(core)) {
    await rejected(handler(request(null)), 'unauthenticated');
    await rejected(handler(request('a', {}, false)), 'failed-precondition');
  }
});
test('terms require explicit current acceptance and preserve the original evidence', async () => {
  await db.doc('users/a/consents/v1').delete();
  await rejected(core.acceptTerms(request('a', {version: 'v1'})), 'failed-precondition');
  await rejected(core.acceptTerms(request('a', {version: 'old', accepted: true})), 'failed-precondition');
  await core.acceptTerms(request('a', {version: 'v1', accepted: true}));
  const original = (await db.doc('users/a/consents/v1').get()).data();
  await core.acceptTerms(request('a', {version: 'v1', accepted: true}));
  const repeated = (await db.doc('users/a/consents/v1').get()).data();
  assert(original.acceptedAt.isEqual(repeated.acceptedAt));
});
test('missing published legal documents prevent pairing and consent', async () => {
  await db.doc('legal/current').delete();
  await rejected(core.createInvite(request('a')), 'failed-precondition');
  await rejected(core.acceptTerms(request('a', {version: 'v1', accepted: true})), 'failed-precondition');
});
test('invitation stores only a hash, previews identity and requires both confirmations', async () => {
  const invite = await core.createInvite(request('a'));
  assert.equal(invite.token.length, 43);
  assert.equal(invite.inviteId, hashToken(invite.token));
  const stored = (await db.doc(`invites/${invite.inviteId}`).get()).data();
  assert(!JSON.stringify(stored).includes(invite.token));
  assert.equal((await core.previewInvite(request('b', invite))).ownerName, 'a');
  await core.requestInvite(request('b', invite));
  assert.equal((await db.doc('users/b').get()).data().coupleId, null);
  await rejected(core.confirmInvite(request('b', invite)), 'not-found');
  const linked = await core.confirmInvite(request('a', invite));
  for (const uid of ['a', 'b']) assert.equal((await db.doc(`users/${uid}`).get()).data().coupleId, linked.coupleId);
  assert.equal((await db.doc(`couples/${linked.coupleId}`).get()).data().status, 'active');
  await rejected(core.confirmInvite(request('a', invite)), 'failed-precondition');
  await rejected(core.requestInvite(request('c', invite)), 'not-found');
});
test('self-link, superseded, revoked, expired and invalid invites fail', async () => {
  const old = await core.createInvite(request('a'));
  await rejected(core.previewInvite(request('a', old)), 'failed-precondition');
  const current = await core.createInvite(request('a'));
  await rejected(core.previewInvite(request('b', old)), 'not-found');
  await core.revokeInvite(request('a', current));
  await rejected(core.requestInvite(request('b', current)), 'not-found');
  const expired = await core.createInvite(request('a'));
  now += 15 * 60 * 1000;
  await rejected(core.previewInvite(request('b', expired)), 'not-found');
  await rejected(core.previewInvite(request('b', {token: 'bad'})), 'invalid-argument');
});
test('racing candidates cannot both reserve one invitation', async () => {
  const invite = await core.createInvite(request('a'));
  const outcomes = await Promise.allSettled(['b', 'c'].map(uid => core.requestInvite(request(uid, invite))));
  assert.equal(outcomes.filter(r => r.status === 'fulfilled').length, 1);
  assert.equal((await db.doc(`invites/${invite.inviteId}`).get()).data().status, 'requested');
});
test('two simultaneous confirmations cannot put a user in two couples', async () => {
  const a = await core.createInvite(request('a'));
  const c = await core.createInvite(request('c'));
  await core.requestInvite(request('b', a));
  await core.requestInvite(request('b', c));
  const results = await Promise.allSettled([core.confirmInvite(request('a', a)), core.confirmInvite(request('c', c))]);
  assert.equal(results.filter(r => r.status === 'fulfilled').length, 1);
  assert.equal((await db.collection('couples').get()).size, 1);
});
test('new terms or an incomplete profile block confirmation without partial writes', async () => {
  const invite = await core.createInvite(request('a'));
  await core.requestInvite(request('b', invite));
  await db.doc('users/b').update({displayName: ''});
  await rejected(core.confirmInvite(request('a', invite)), 'failed-precondition');
  assert.equal((await db.collection('couples').get()).size, 0);
  await db.doc('users/b').update({displayName: 'b'});
  await db.doc('legal/current').update({version: 'v2'});
  await rejected(core.confirmInvite(request('a', invite)), 'failed-precondition');
});
test('unlink clears both profiles and closes shared access atomically', async () => {
  const invite = await core.createInvite(request('a'));
  await core.requestInvite(request('b', invite));
  const {coupleId} = await core.confirmInvite(request('a', invite));
  await rejected(core.unlinkCouple(request('a')), 'invalid-argument');
  await core.unlinkCouple(request('b', {confirmed: true}));
  assert.equal((await db.doc(`couples/${coupleId}`).get()).data().status, 'ended');
  assert.equal((await db.doc('users/a').get()).data().coupleId, null);
  assert.equal((await db.doc('users/b').get()).data().partnerId, null);
});
test('failed guesses consume the server rate limit', async () => {
  const data = {token: 'x'.repeat(43)};
  for (let i = 0; i < 20; i++) await rejected(core.previewInvite(request('b', data)), 'not-found');
  await rejected(core.previewInvite(request('b', data)), 'resource-exhausted');
  now += 60000;
  await rejected(core.previewInvite(request('b', data)), 'not-found');
});

test('a forged profile acceptance cannot replace backend consent evidence', async () => {
  await db.doc('users/a/consents/v1').delete();
  await rejected(core.createInvite(request('a')), 'failed-precondition');
});
test('creating another invitation works after expired records have been cleaned up', async () => {
  const old = await core.createInvite(request('a'));
  await db.doc(`invites/${old.inviteId}`).delete();
  const replacement = await core.createInvite(request('a'));
  assert.notEqual(old.inviteId, replacement.inviteId);
});
