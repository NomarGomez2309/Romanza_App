const path = require('path');
const fs = require('fs');
const lib = path.resolve('tools/firebase-tests/node_modules/firebase-tools/lib');
(async () => {
 const auth = require(path.join(lib,'auth'));
 const opts = {project:'romanza-app'};
 auth.setActiveAccount(opts, auth.getGlobalDefaultAccount());
 await require(path.join(lib,'requireAuth')).requireAuth(opts);
 const rules = require(path.join(lib,'gcp/rules'));
 const name = await rules.getLatestRulesetName('romanza-app','cloud.firestore');
 if (name) {
  const files = await rules.getRulesetContent(name);
  fs.writeFileSync('.knowledge/firestore-before.rules',files[0].content);
  console.log('Current ruleset:',name);
  const local = fs.readFileSync('firestore.rules','utf8');
  const previous = require('child_process').execFileSync('git',['show','HEAD:firestore.rules'],{encoding:'utf8'});
  const normalize = text => text.replace(/\r\n/g,'\n').trim();
  console.log('Remote matches previous local rules:', normalize(previous) === normalize(files[0].content));
  console.log('Remote matches new local rules:', normalize(local) === normalize(files[0].content));
 }
 const {Client} = require(path.join(lib,'apiv2'));
 const client = new Client({urlPrefix:'https://identitytoolkit.googleapis.com',apiVersion:'v2'});
 const config = (await client.get('/projects/romanza-app/config',{skipLog:{resBody:true}})).body;
 const google = (await client.get('/projects/romanza-app/defaultSupportedIdpConfigs/google.com',{skipLog:{resBody:true}})).body;
 console.log(JSON.stringify({email:config.signIn?.email,googleEnabled:google.enabled,googleClientId:google.clientId}));
})().catch(e => { console.error(e.message); process.exitCode=1; });
