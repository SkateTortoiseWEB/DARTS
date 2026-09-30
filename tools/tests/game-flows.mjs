// functional checks of the new shell: full game to a win, rematch, undo, keypad, players, settings, backup
import {chromium} from '/opt/node22/lib/node_modules/playwright/index.mjs';
const b=await chromium.launch();const ctx=await b.newContext({viewport:{width:1440,height:900},acceptDownloads:true});const pg=await ctx.newPage();
const errs=[];pg.on('pageerror',e=>errs.push(e.message));
await pg.goto('http://127.0.0.1:8765/');await pg.evaluate(()=>localStorage.clear());await pg.reload();await pg.waitForTimeout(1000);
const ok=(c,m)=>console.log((c?'PASS ':'FAIL ')+m);
// setup: 2 players, 101 straight out isn't offered; use 301 double out
await pg.selectOption('#startScore','301');await pg.click('#startBtn');await pg.waitForTimeout(800);
ok(await pg.evaluate(()=>document.querySelector('#matchChip').textContent.includes('301')),'match chip shows the game');
const pad=async(label)=>{const m={T:3,D:2}[label[0]]||1;const n=label.replace(/^[TD]/,'');
  await pg.click(`#padPanel .seg [data-mult="${m}"]`);await pg.click(n==='25'?'#b25':n==='Bull'?'#b50':`#numGrid button:nth-child(${n})`);await pg.waitForTimeout(150);};
await pg.keyboard.press('k');await pg.waitForTimeout(200);ok(await pg.isVisible('#padPanel'),'K opens the keypad');
for(const t of ['T20','T20','T20'])await pad(t);          // Joseph 121
await pg.waitForTimeout(2800);await pg.keyboard.press('Escape');ok(await pg.isHidden('#padPanel'),'Escape closes the keypad');await pg.keyboard.press('k');
ok(await pg.evaluate(()=>dartsApi.state().players[0].rem===121),'180 scored from the keypad');
ok(await pg.evaluate(()=>document.querySelector('#nextBtn').classList.contains('ready')),'Next button highlights when the turn is over');
await pg.click('#nextBtn');await pg.waitForTimeout(300);
for(const t of ['20','20','20'])await pad(t);await pg.click('#nextBtn');await pg.waitForTimeout(300);   // Theo 241
await pad('T20');await pg.waitForTimeout(200);await pg.click('#undoBtn');await pg.waitForTimeout(200);
ok(await pg.evaluate(()=>dartsApi.state().players[0].rem===121&&dartsApi.state().turn.darts.length===0),'Undo takes the dart back');
for(const t of ['T20','T11','D14'])await pad(t);         // 60+33+28 = 121 checkout on a double
await pg.waitForTimeout(3000);await pg.mouse.click(700,450);await pg.waitForTimeout(600);
ok(await pg.evaluate(()=>dartsApi.state().winner===0),'Joseph wins on D14');
ok(await pg.evaluate(()=>document.querySelector('#nextText').textContent==='Rematch'),'Next button becomes Rematch');
await pg.click('#nextBtn');await pg.waitForTimeout(600);
ok(await pg.evaluate(()=>{const s=dartsApi.state();return s.winner===null&&s.players[0].name==='Theo'&&s.players[0].rem===301;}),'Rematch starts with the other player first');
ok(await pg.evaluate(()=>document.querySelector('#lbBody').textContent.includes('Joseph')&&[...document.querySelectorAll('#lbBody tr')].find(r=>r.textContent.includes('Joseph')).children[1].textContent==='1'),'Leaderboard counts the win');
// settings: players
await pg.keyboard.press(',');await pg.waitForTimeout(400);ok(await pg.evaluate(()=>document.querySelector('#dev').classList.contains('open')),', opens settings');
await pg.fill('#addPlayerName','Sam');await pg.press('#addPlayerName','Enter');await pg.waitForTimeout(200);
ok(await pg.evaluate(()=>ACCOUNTS.includes('Sam')&&document.querySelector('#playersList').textContent.includes('Sam')),'Add a player in settings');
await pg.click('[data-remove="Theo"]');await pg.waitForTimeout(200);
ok(await pg.evaluate(()=>ACCOUNTS.includes('Theo')),'Can\'t remove a player who is in the current game');
await pg.click('[data-remove="Michael"]');await pg.waitForTimeout(200);
ok(await pg.evaluate(()=>!ACCOUNTS.includes('Michael')&&!document.querySelector('#lbBody').textContent.includes('Michael')),'Remove a player (hidden from the leaderboard)');
const [dl]=await Promise.all([pg.waitForEvent('download'),pg.evaluate(()=>{document.querySelector('#exportBtn').click();})]);
const data=JSON.parse(await (await import('fs')).promises.readFile(await dl.path(),'utf8'));
ok(Array.isArray(data.players)&&data.players.includes('Sam')&&data.matches.length===1,'Backup includes players and the match');
await pg.click('#scrim',{position:{x:100,y:400}});await pg.waitForTimeout(400);ok(await pg.evaluate(()=>!document.querySelector('#dev').classList.contains('open')),'Clicking outside closes settings');
// board click can be switched off
await pg.evaluate(()=>{const c=document.querySelector('#boardClick');c.checked=false;c.dispatchEvent(new Event('change'));});
const before=await pg.evaluate(()=>dartsApi.state().turn.darts.length);await pg.mouse.click(520,300);await pg.waitForTimeout(200);
ok(await pg.evaluate(n=>dartsApi.state().turn.darts.length===n,before),'Board clicks ignored when switched off');
// reload keeps players and the game
await pg.reload();await pg.waitForTimeout(1200);
ok(await pg.evaluate(()=>ACCOUNTS.includes('Sam')&&!ACCOUNTS.includes('Michael')),'Players kept after reload');
console.log('errors:',errs.join(' | ')||'none');await b.close();
