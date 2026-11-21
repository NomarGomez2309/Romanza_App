// Run against the local demo Firestore emulator, never a production project.
import test from 'node:test';
import assert from 'node:assert/strict';
const project = 'demo-romanza-auth';
const base = `http://127.0.0.1:8089/v1/projects/${project}/databases/(default)/documents`;
const token = (uid, verified = true) => {
  const encode = value => Buffer.from(JSON.stringify(value)).toString('base64url');
  return `${encode({ alg: 'none', typ: 'JWT' })}.${encode({
    sub: uid, user_id: uid, aud: project,
    iss: `https://securetoken.google.com/${project}`,
    iat: Math.floor(Date.now() / 1000), exp: Math.floor(Date.now() / 1000) + 3600,
    email_verified: verified, firebase: { sign_in_provider: 'password' },
  })}.`;
};
const request = async (path, auth, body) => fetch(`${base}${path}`, {
  method: body ? 'POST' : 'GET',
  headers: { 'Content-Type': 'application/json', ...(auth ? { Authorization: `Bearer ${auth}` } : {}) },
  body: body ? JSON.stringify(body) : undefined,
});
const profile = (uid, extra = {}) => ({ writes: [{
  update: { name: `projects/${project}/databases/(default)/documents/users/${uid}`,
    fields: { uid: { stringValue: uid }, name: { stringValue: 'Prueba' }, ...extra } },
  updateTransforms: ['createdAt', 'updatedAt'].map(fieldPath => ({ fieldPath, setToServerValue: 'REQUEST_TIME' })),
}] });
test('verified profiles are private and membership cannot be self granted', async () => {
  const uid = `rules-${Date.now()}`;
  assert.equal((await request(':commit', token(uid), profile(uid))).status, 200);
  assert.equal((await request(`/users/${uid}`, token(uid))).status, 200);
  for (const auth of [null, token('outsider'), token(uid, false)]) {
    assert.equal((await request(`/users/${uid}`, auth)).status, 403);
  }
  const pending = `${uid}-pending`;
  assert.equal((await request(':commit', token(pending, false), profile(pending))).status, 403);
  for (const field of ['coupleId', 'termsAccepted', 'role']) {
    const other = `${uid}-${field}`;
    assert.equal((await request(':commit', token(other), profile(other, { [field]: { stringValue: 'forged' } }))).status, 403);
  }
  const coupleWrite = { writes: [{ update: {
    name: `projects/${project}/databases/(default)/documents/couples/${uid}`,
    fields: { members: { arrayValue: { values: [{ stringValue: uid }] } } },
  } }] };
  assert.equal((await request(':commit', token(uid), coupleWrite)).status, 403);
  assert.equal((await request(':commit', 'owner', coupleWrite)).status, 200);
  // Shared modules remain unavailable until the invitation backend exists.
  assert.equal((await request(`/couples/${uid}`, token(uid))).status, 403);
  assert.equal((await request(`/couples/${uid}`, token('outsider'))).status, 403);
  assert.equal((await request(':commit', token(uid), coupleWrite)).status, 403);
});
