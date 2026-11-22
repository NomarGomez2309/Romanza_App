'use strict';
const {initializeApp} = require('firebase-admin/app');
const {getFirestore} = require('firebase-admin/firestore');
const {onCall} = require('firebase-functions/v2/https');
const {createCore} = require('./core');
initializeApp();
const core = createCore(getFirestore());
// No production bypass. Register App Check before deploying these callables.
for (const [name, handler] of Object.entries(core)) {
  exports[name] = onCall({region: 'us-central1', enforceAppCheck: true,
    maxInstances: 10, timeoutSeconds: 30}, handler);
}
