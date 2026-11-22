'use strict';
const {test, before, after, beforeEach} = require('node:test');
const {readFileSync} = require('node:fs');
const {resolve} = require('node:path');
const {initializeTestEnvironment, assertSucceeds, assertFails} = require('@firebase/rules-unit-testing');
const {doc, setDoc, getDoc, updateDoc, deleteDoc, serverTimestamp, collection, getDocs, query, where, Timestamp, deleteField} = require('firebase/firestore');
const {ref, uploadBytes, getBytes} = require('firebase/storage');
require('firebase/firestore').setLogLevel('silent');
let env;
before(async () => {
  if (!process.env.FIRESTORE_EMULATOR_HOST || !process.env.FIREBASE_STORAGE_EMULATOR_HOST) {
    throw Error('Run via npm run test:emulators. Never target a live project.');
  }
  env = await initializeTestEnvironment({projectId: 'demo-romanza',
    firestore: {host: '127.0.0.1', port: 8080, rules: readFileSync(resolve(__dirname, '../firestore.rules'), 'utf8')},
    storage: {host: '127.0.0.1', port: 9199, rules: readFileSync(resolve(__dirname, '../../storage.rules'), 'utf8')}});
});
after(async () => { await env?.cleanup(); });
beforeEach(async () => { await env.clearFirestore(); });
const db = (uid, verified = true) => env.authenticatedContext(uid, {email_verified: verified}).firestore();
const profile = uid => ({uid, displayName: 'Alex', theme: 'Default', language: 'system',
  onboardingSkipped: false, coupleId: null, partnerId: null, activeInviteId: null,
  acceptedTermsVersion: null, acceptedTermsAt: null,
  createdAt: serverTimestamp(), updatedAt: serverTimestamp()});
async function seed(path, data) {
  await env.withSecurityRulesDisabled(ctx => setDoc(doc(ctx.firestore(), path), data));
}
test('owner can create valid profile and change only editable fields', async () => {
  const ref = doc(db('a'), 'users/a');
  await assertSucceeds(setDoc(ref, profile('a')));
  await assertSucceeds(updateDoc(ref, {displayName: 'Nuevo', theme: 'Forest', updatedAt: serverTimestamp()}));
  await assertSucceeds(getDoc(ref));
});
test('anonymous and other user cannot read, list or write profiles', async () => {
  await seed('users/a', profile('a'));
  await assertFails(getDoc(doc(env.unauthenticatedContext().firestore(), 'users/a')));
  await assertFails(getDocs(collection(db('b'), 'users')));
  await assertFails(getDoc(doc(db('b'), 'users/a')));
  await assertFails(updateDoc(doc(db('b'), 'users/a'), {displayName: 'Impostor', updatedAt: serverTimestamp()}));
});
test('creation cannot forge UID, membership, consent or privileged fields', async () => {
  for (const patch of [{uid: 'b'}, {coupleId: 'stolen'}, {partnerId: 'b'},
    {activeInviteId: 'fake'}, {acceptedTermsVersion: 'v1'}, {isAdmin: true},
    {acceptedTermsAt: Timestamp.now()}, {createdAt: Timestamp.fromMillis(1)}]) {
    await assertFails(setDoc(doc(db('a'), 'users/a'), {...profile('a'), ...patch}));
  }
});
test('update cannot remove required fields, change types, exceed limits or add fields', async () => {
  const ref = doc(db('a'), 'users/a');
  await setDoc(ref, profile('a'));
  for (const patch of [{displayName: 4}, {displayName: 'x'.repeat(61)},
    {displayName: deleteField()}, {language: 'x'.repeat(21)}, {theme: 'Unknown'},
    {onboardingSkipped: 'yes'}, {extra: 'x'}, {uid: 'b'},
    {createdAt: Timestamp.fromMillis(1)}, {updatedAt: Timestamp.fromMillis(1)}]) {
    await assertFails(updateDoc(ref, {...patch, ...(Object.hasOwn(patch, 'updatedAt') ? {} : {updatedAt: serverTimestamp()})}));
  }
});
test('owner cannot assign relationship or consent fields after profile creation', async () => {
  const ref = doc(db('a'), 'users/a');
  await setDoc(ref, profile('a'));
  for (const patch of [{coupleId: 'c'}, {partnerId: 'b'}, {activeInviteId: 'i'},
    {acceptedTermsVersion: 'v1'}, {acceptedTermsAt: serverTimestamp()}]) {
    await assertFails(updateDoc(ref, {...patch, updatedAt: serverTimestamp()}));
  }
  await assertFails(setDoc(doc(db('a'), 'users/a/consents/v1'), {version: 'v1'}));
});
test('membership, pending invitations and legal publication are backend-only', async () => {
  await seed('couples/c', {members: ['a', 'b'], status: 'active'});
  await seed('invites/i', {ownerUid: 'a', status: 'open'});
  await assertSucceeds(getDoc(doc(db('a'), 'couples/c')));
  await assertFails(getDoc(doc(db('x'), 'couples/c')));
  await assertFails(getDoc(doc(db('a', false), 'couples/c')));
  await assertFails(updateDoc(doc(db('a'), 'couples/c'), {members: ['a', 'x']}));
  await assertFails(setDoc(doc(db('a'), 'couples/new'), {members: ['a'], status: 'pending'}));
  await assertSucceeds(getDoc(doc(db('a'), 'invites/i')));
  await assertFails(getDoc(doc(db('b'), 'invites/i')));
  await assertFails(getDocs(query(collection(db('b'), 'invites'), where('status', '==', 'open'))));
  await assertFails(updateDoc(doc(db('a'), 'invites/i'), {status: 'accepted'}));
  await assertFails(setDoc(doc(db('a'), 'legal/current'), {version: 'fake'}));
});
test('only author deletes a memory; neither member can forge or edit metadata', async () => {
  await seed('couples/c', {members: ['a', 'b'], status: 'active'});
  await seed('couples/c/gallery/photo', {authorUid: 'a'});
  await assertSucceeds(getDoc(doc(db('b'), 'couples/c/gallery/photo')));
  await assertFails(deleteDoc(doc(db('b'), 'couples/c/gallery/photo')));
  await assertFails(updateDoc(doc(db('b'), 'couples/c/gallery/photo'), {authorUid: 'b'}));
  await assertFails(setDoc(doc(db('a'), 'couples/c/gallery/forged'), {authorUid: 'a'}));
  await assertSucceeds(deleteDoc(doc(db('a'), 'couples/c/gallery/photo')));
});
test('ended couples and orphan content are inaccessible', async () => {
  await seed('couples/c', {members: ['a', 'b'], status: 'ended'});
  await seed('couples/c/gallery/photo', {authorUid: 'a'});
  await seed('couples/orphan/gallery/photo', {authorUid: 'a'});
  await assertFails(getDoc(doc(db('a'), 'couples/c')));
  await assertFails(getDoc(doc(db('a'), 'couples/c/gallery/photo')));
  await assertFails(getDoc(doc(db('a'), 'couples/orphan/gallery/photo')));
});
test('unknown paths and media uploads/downloads remain closed', async () => {
  await assertFails(setDoc(doc(db('a'), 'rateLimits/a'), {count: 0}));
  await assertFails(setDoc(doc(db('a'), 'unknown/path'), {value: true}));
  const object = ref(env.authenticatedContext('a').storage(), 'users/a/photo.jpg');
  await assertFails(uploadBytes(object, new Uint8Array([1]), {contentType: 'image/jpeg'}));
  await assertFails(getBytes(object));
});
