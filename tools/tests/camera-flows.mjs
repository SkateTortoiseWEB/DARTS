import {chromium} from '/opt/node22/lib/node_modules/playwright/index.mjs';
import fs from 'fs';
const b=await chromium.launch();const ctx=await b.newContext({viewport:{width:1440,height:900},acceptDownloads:true});const pg=await ctx.newPage();
const errs=[];pg.on('pageerror',e=>errs.push(e.message));
await pg.addInitScript(fs.readFileSync(new URL('../camera-sim/fakecam.js',import.meta.url),'utf8'));
await pg.goto('http://127.0.0.1:8765/');await pg.evaluate(()=>localStorage.clear());await pg.reload();await pg.waitForTimeout(1000);
const ok=(c,m)=>console.log((c?'PASS ':'FAIL ')+m);
await pg.click('#startBtn');await pg.waitForTimeout(500);
await pg.keyboard.press('c');await pg.waitForTimeout(500);ok(await pg.isVisible('#camView'),'C opens camera setup');
await pg.click('#camStart2');await pg.waitForTimeout(2000);await pg.click('[data-go="2"]');
const P=await pg.evaluate(()=>SIM.P),img=(bx,by)=>[P.cx+P.s*bx+P.k*P.s*by,P.cy+P.sy*P.s*by];
const clickBoard=async(bx,by)=>{const [px,py]=img(bx,by);const s=await pg.evaluate(([u,v])=>{const r=document.querySelector('#camOverlay').getBoundingClientRect();const [x,y]=cvToScreen(u,v);return [x+r.left,y+r.top];},[px/1280,py/720]);await pg.mouse.click(s[0],s[1]);await pg.waitForTimeout(120);};
const T=await pg.evaluate(()=>CAL_TARGETS.map(t=>t.b));for(let i=0;i<4;i++)await clickBoard(...T[i]);
ok(await pg.evaluate(()=>!!dartsCamera.H&&document.querySelector('#camPill').dataset.state==='watching'),'4 points calibrate the camera');
// zoom in and check the points still map
await pg.mouse.move(600,450);await pg.mouse.wheel(0,-600);await pg.waitForTimeout(200);
ok(await pg.evaluate(()=>CV.s>CV.fit*1.5),'Scroll zooms the picture');
await clickBoard(...T[4]);ok(await pg.evaluate(()=>dartsCamera.cal.length===5),'Clicking while zoomed adds the next point in the right place');
ok(await pg.evaluate(()=>{const q=dartsCamera.cal[4];const [x,y]=hApply(dartsCamera.H,q.p[0],q.p[1]);return Math.hypot(x,y)<0.6;}),'Bull point lands within 0.6 mm');
// rings: pretend the treble's inner wire is at 95 mm
await pg.evaluate(()=>{CV.s=CV.fit;camFitView();});await pg.click('#camSteps [data-step="3"]');await pg.click('[data-ring="trebIn"]');
for(const a of [10,70,130,190,250,310])await clickBoard(95*Math.sin(a*Math.PI/180),-95*Math.cos(a*Math.PI/180));
ok(await pg.evaluate(()=>Math.abs(R.trebIn-95)<0.5),'Measured treble ring used for scoring ('+await pg.evaluate(()=>R.trebIn.toFixed(2))+' mm)');
ok(await pg.evaluate(()=>scoreAt(0,-97).label==='T20'),'97 mm from the centre now scores T20');
// save the mapping, wipe, open it again
const [dl]=await Promise.all([pg.waitForEvent('download'),pg.click('#camSteps [data-step="2"]').then(()=>pg.click('#mapSave'))]);
const file=await dl.path();const m=JSON.parse(fs.readFileSync(file,'utf8'));
ok(m.format==='board-mapping'&&m.calibrationPoints.length===5&&Math.abs(m.board.rings.trebIn-95)<0.5,'Mapping file has points and rings');
const H0=await pg.evaluate(()=>dartsCamera.H.slice());
await pg.click('#camCal');ok(await pg.evaluate(()=>!dartsCamera.H),'Start over clears the calibration');
await pg.setInputFiles('#mapInput',file);await pg.waitForTimeout(300);
const drift=await pg.evaluate(h=>{let w=0;for(const [u,v] of [[.3,.3],[.5,.5],[.7,.6],[.45,.8]]){const a=hApply(h,u,v),b=hApply(dartsCamera.H,u,v);w=Math.max(w,Math.hypot(a[0]-b[0],a[1]-b[1]));}return w;},H0);
ok(drift<0.01,'Opening the mapping restores the same calibration (differs by '+drift.toFixed(4)+' mm)');
ok(await pg.evaluate(()=>Math.abs(R.trebIn-95)<0.5),'and the measured rings');
// test step: a magnet is shown but not scored into the game
await pg.click('#camSteps [data-step="4"]');await pg.waitForTimeout(2500);
const d0=await pg.evaluate(()=>dartsApi.state().turn.darts.length);
await pg.evaluate(()=>SIM.magnets.push({x:0,y:-130}));await pg.waitForTimeout(3000);
ok(await pg.evaluate(()=>document.querySelector('#camLastHit').textContent==='20'),'Test step shows the dart ('+await pg.evaluate(()=>document.querySelector('#camLastHit').textContent)+')');
ok(await pg.evaluate(n=>dartsApi.state().turn.darts.length===n,d0),'but doesn\'t score it into the game');
await pg.click('#camClose');await pg.evaluate(()=>{SIM.magnets=[];});await pg.waitForTimeout(3000);
await pg.evaluate(()=>SIM.magnets.push({x:0,y:-60}));await pg.waitForTimeout(3000);
ok(await pg.evaluate(()=>dartsApi.state().turn.darts.some(d=>d.label==='20')),'After Done, darts score into the game');
// reload: calibration and rings survive
await pg.reload();await pg.waitForTimeout(1500);
ok(await pg.evaluate(()=>dartsCamera.cal.length===5&&Math.abs(R.trebIn-95)<0.5),'Calibration and rings kept after reload');
console.log('errors:',errs.join(' | ')||'none');
// no server: open the file directly
const p2=await b.newPage();const e2=[];p2.on('pageerror',e=>e2.push(e.message));
await p2.goto(new URL('../../Oche.app/Contents/Resources/oche.html',import.meta.url).href);await p2.waitForTimeout(1200);
await p2.click('#startBtn');await p2.waitForTimeout(400);await p2.evaluate(()=>dartsApi.registerDart(0,-103));
ok(await p2.evaluate(()=>dartsApi.state().players[0].rem===441),'Works opened as a plain file too');
ok(await p2.evaluate(()=>document.fonts.check('600 20px "Barlow Condensed"')),'Built-in fonts load offline');
console.log('file errors:',e2.join(' | ')||'none');await b.close();
