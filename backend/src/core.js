'use strict';
const {randomBytes, createHash} = require('node:crypto');
const {FieldValue, Timestamp} = require('firebase-admin/firestore');
const {HttpsError} = require('firebase-functions/v2/https');

const hashToken = token => createHash('sha256').update(token).digest('hex');
const fail = (code, message) => { throw new HttpsError(code, message); };
const stamp = () => FieldValue.serverTimestamp();

function createCore(db, clock = () => Date.now()) {
  function identity(request) {
    if (!request.auth) fail('unauthenticated', 'Inicia sesión.');
    if (request.auth.token.email_verified !== true) {
      fail('failed-precondition', 'Verifica tu correo primero.');
    }
    return request.auth.uid;
  }
  async function rate(uid) {
    const ref = db.doc(`rateLimits/${uid}`);
    await db.runTransaction(async tx => {
      const snap = await tx.get(ref);
      const now = clock();
      const sameWindow = snap.exists && now - snap.data().startedAt < 60000;
      const count = sameWindow ? snap.data().count : 0;
      if (count >= 20) fail('resource-exhausted', 'Espera un minuto antes de reintentar.');
      tx.set(ref, {startedAt: sameWindow ? snap.data().startedAt : now,
        count: count + 1, expiresAt: Timestamp.fromMillis(now + 86400000)});
    });
  }
  async function caller(request) {
    const uid = identity(request);
    await rate(uid); // Includes unsuccessful token lookups; cannot bypass from client.
    return uid;
  }
  function tokenId(data) {
    if (typeof data?.token !== 'string' || !/^[A-Za-z0-9_-]{43}$/.test(data.token)) {
      fail('invalid-argument', 'Invitación no válida.');
    }
    return hashToken(data.token);
  }
  function inviteId(data) {
    if (typeof data?.inviteId !== 'string' || !/^[a-f0-9]{64}$/.test(data.inviteId)) {
      fail('invalid-argument', 'Invitación no válida.');
    }
    return data.inviteId;
  }
  function legalVersion(snap) {
    const data = snap.data();
    if (!snap.exists || typeof data.version !== 'string' ||
        !/^[A-Za-z0-9._-]{1,128}$/.test(data.version) ||
        ![data.termsUrl, data.privacyUrl].every(url =>
          typeof url === 'string' && url.length <= 2048 && /^https:\/\/.+/.test(url))) {
      fail('failed-precondition', 'Las condiciones aún no están publicadas.');
    }
    return data.version;
  }
  async function ready(tx, snap, version) {
    const p = snap.data();
    if (!snap.exists || p.uid !== snap.id || typeof p.displayName !== 'string' ||
        p.displayName.trim().length < 1 || p.displayName.length > 60 ||
        p.acceptedTermsVersion !== version || !(p.acceptedTermsAt instanceof Timestamp)) {
      fail('failed-precondition', 'Completa tu perfil y acepta las condiciones vigentes.');
    }
    const consent = await tx.get(snap.ref.collection('consents').doc(version));
    if (!consent.exists || consent.data().version !== version ||
        !(consent.data().acceptedAt instanceof Timestamp)) {
      fail('failed-precondition', 'Acepta las condiciones vigentes para continuar.');
    }
    return p;
  }
  function validInvite(snap, ownerSnap) {
    const i = snap.data();
    if (!snap.exists || !ownerSnap.exists || i.ownerUid !== ownerSnap.id ||
        ownerSnap.data().activeInviteId !== snap.id ||
        !['open', 'requested'].includes(i.status) ||
        !(i.expiresAt instanceof Timestamp) || i.expiresAt.toMillis() <= clock()) {
      fail('not-found', 'La invitación no está disponible.');
    }
    return i;
  }
  const userRef = uid => db.doc(`users/${uid}`);
  const legalRef = db.doc('legal/current');

  return {
    async acceptTerms(request) {
      const uid = await caller(request);
      return db.runTransaction(async tx => {
        const [legal, profile] = await Promise.all([tx.get(legalRef), tx.get(userRef(uid))]);
        const version = legalVersion(legal);
        if (request.data?.version !== version || request.data?.accepted !== true) {
          fail('failed-precondition', 'Confirma las condiciones vigentes.');
        }
        if (!profile.exists) fail('failed-precondition', 'Crea tu perfil primero.');
        const ref = userRef(uid).collection('consents').doc(version);
        const consent = await tx.get(ref);
        // Repeated requests must preserve the original acceptance evidence.
        if (!consent.exists) tx.create(ref, {version, acceptedAt: stamp(),
          termsUrl: legal.data().termsUrl, privacyUrl: legal.data().privacyUrl});
        tx.update(userRef(uid), {acceptedTermsVersion: version,
          acceptedTermsAt: consent.exists ? consent.data().acceptedAt : stamp(), updatedAt: stamp()});
        return {version};
      });
    },
    async createInvite(request) {
      const uid = await caller(request);
      const token = randomBytes(32).toString('base64url');
      const id = hashToken(token);
      const expiresAt = Timestamp.fromMillis(clock() + 15 * 60 * 1000);
      await db.runTransaction(async tx => {
        const [profile, legal] = await Promise.all([tx.get(userRef(uid)), tx.get(legalRef)]);
        const p = await ready(tx, profile, legalVersion(legal));
        if (p.coupleId) fail('failed-precondition', 'Ya tienes una pareja vinculada.');
        if (p.activeInviteId) {
          const previousRef = db.doc(`invites/${p.activeInviteId}`);
          const previous = await tx.get(previousRef);
          if (previous.exists) tx.update(previousRef, {status: 'revoked'});
        }
        tx.create(db.doc(`invites/${id}`), {ownerUid: uid, ownerName: p.displayName,
          candidateUid: null, candidateName: null, status: 'open', expiresAt, createdAt: stamp()});
        tx.update(userRef(uid), {activeInviteId: id, updatedAt: stamp()});
      });
      return {token, inviteId: id, expiresAt: expiresAt.toMillis()};
    },
    async previewInvite(request) {
      const uid = await caller(request);
      const id = tokenId(request.data);
      return db.runTransaction(async tx => {
        const snap = await tx.get(db.doc(`invites/${id}`));
        if (!snap.exists) fail('not-found', 'La invitación no está disponible.');
        const [owner, profile, legal] = await Promise.all([
          tx.get(userRef(snap.data().ownerUid)), tx.get(userRef(uid)), tx.get(legalRef)]);
        const i = validInvite(snap, owner);
        const p = await ready(tx, profile, legalVersion(legal));
        if (i.ownerUid === uid || p.coupleId || i.status !== 'open') {
          fail('failed-precondition', 'No puedes utilizar esta invitación.');
        }
        return {ownerName: owner.data().displayName};
      });
    },
    async requestInvite(request) {
      const uid = await caller(request);
      const id = tokenId(request.data);
      await db.runTransaction(async tx => {
        const ref = db.doc(`invites/${id}`);
        const snap = await tx.get(ref);
        if (!snap.exists) fail('not-found', 'La invitación no está disponible.');
        const [owner, profile, legal] = await Promise.all([
          tx.get(userRef(snap.data().ownerUid)), tx.get(userRef(uid)), tx.get(legalRef)]);
        const i = validInvite(snap, owner);
        const version = legalVersion(legal);
        const p = await ready(tx, profile, version);
        await ready(tx, owner, version);
        if (i.ownerUid === uid || p.coupleId || owner.data().coupleId ||
            (i.status !== 'open' && i.candidateUid !== uid)) {
          fail('failed-precondition', 'La invitación ya no está disponible.');
        }
        tx.update(ref, {status: 'requested', candidateUid: uid, candidateName: p.displayName});
      });
      return {status: 'requested'};
    },
    async confirmInvite(request) {
      const uid = await caller(request);
      const id = inviteId(request.data);
      const coupleRef = db.collection('couples').doc();
      await db.runTransaction(async tx => {
        const ref = db.doc(`invites/${id}`);
        const snap = await tx.get(ref);
        if (!snap.exists || snap.data().ownerUid !== uid) fail('not-found', 'Invitación no disponible.');
        const i = snap.data();
        if (i.status !== 'requested' || typeof i.candidateUid !== 'string' || i.candidateUid === uid) {
          fail('failed-precondition', 'No hay una solicitud pendiente.');
        }
        const [owner, candidate, legal] = await Promise.all([
          tx.get(userRef(uid)), tx.get(userRef(i.candidateUid)), tx.get(legalRef)]);
        validInvite(snap, owner);
        const version = legalVersion(legal);
        const a = await ready(tx, owner, version);
        const b = await ready(tx, candidate, version);
        if (a.coupleId || b.coupleId) fail('failed-precondition', 'Una cuenta ya tiene pareja.');
        tx.create(coupleRef, {members: [uid, i.candidateUid], status: 'active',
          profiles: {[uid]: {displayName: a.displayName}, [i.candidateUid]: {displayName: b.displayName}},
          createdAt: stamp(), updatedAt: stamp()});
        tx.update(userRef(uid), {coupleId: coupleRef.id, partnerId: i.candidateUid,
          activeInviteId: null, updatedAt: stamp()});
        // Any other invitation created by the candidate becomes invalid atomically.
        tx.update(userRef(i.candidateUid), {coupleId: coupleRef.id, partnerId: uid,
          activeInviteId: null, updatedAt: stamp()});
        tx.update(ref, {status: 'accepted', coupleId: coupleRef.id});
      });
      return {coupleId: coupleRef.id};
    },
    async revokeInvite(request) {
      const uid = await caller(request);
      const id = inviteId(request.data);
      await db.runTransaction(async tx => {
        const ref = db.doc(`invites/${id}`);
        const [snap, user] = await Promise.all([tx.get(ref), tx.get(userRef(uid))]);
        if (!snap.exists || snap.data().ownerUid !== uid) fail('not-found', 'Invitación no disponible.');
        if (snap.data().status === 'accepted') fail('failed-precondition', 'La invitación ya fue utilizada.');
        tx.update(ref, {status: 'revoked'});
        if (user.data()?.activeInviteId === id) tx.update(userRef(uid), {activeInviteId: null, updatedAt: stamp()});
      });
      return {status: 'revoked'};
    },
    async unlinkCouple(request) {
      const uid = await caller(request);
      if (request.data?.confirmed !== true) fail('invalid-argument', 'Confirma la desvinculación.');
      await db.runTransaction(async tx => {
        const profile = await tx.get(userRef(uid));
        const id = profile.data()?.coupleId;
        if (!id) fail('failed-precondition', 'No tienes pareja vinculada.');
        const ref = db.doc(`couples/${id}`);
        const couple = await tx.get(ref);
        const c = couple.data();
        if (!couple.exists || c.status !== 'active' || !Array.isArray(c.members) ||
            c.members.length !== 2 || !c.members.includes(uid)) {
          fail('failed-precondition', 'El vínculo no está activo.');
        }
        const otherUid = c.members.find(member => member !== uid);
        const other = await tx.get(userRef(otherUid));
        tx.update(ref, {status: 'ended', endedAt: stamp(), updatedAt: stamp()});
        tx.update(userRef(uid), {coupleId: null, partnerId: null, updatedAt: stamp()});
        if (other.exists && other.data().coupleId === id) {
          tx.update(userRef(otherUid), {coupleId: null, partnerId: null, updatedAt: stamp()});
        }
      });
      return {status: 'ended'};
    },
  };
}
module.exports = {createCore, hashToken};
