// node run.mjs <page.html> [paramsJSON]   runs throw scenarios against the simulated webcam
import {chromium} from '/opt/node22/lib/node_modules/playwright/index.mjs';
import fs from 'fs';
const page_=process.argv[2],params=JSON.parse(process.argv[3]||'{}');
const fake=fs.readFileSync(new URL('./fakecam.js',import.meta.url),'utf8');
const b=await chromium.launch({args:['--autoplay-policy=no-user-gesture-required']});
const pg=await b.newPage({viewport:{width:1400,height:900}});
pg.on('pageerror',e=>console.log('PAGEERR',e.message));
await pg.addInitScript(`window.SIM_PARAMS=${JSON.stringify(params)};localStorage.clear();`);
await pg.addInitScript(fake);
await pg.goto('file://'+page_);
await pg.evaluate(()=>{
  document.querySelector('#setup')?.close?.();
  newGame({names:['A','B'],start:501,legsToWin:1,doubleOut:true});
  window.HITS=[];const orig=window.registerDart;window.registerDart=(x,y)=>{HITS.push({x,y,label:scoreAt(x,y).label});orig(x,y);};
  speechSynthesis&&(speechSynthesis.speak=()=>{});
});
await pg.evaluate(()=>camStart());
await pg.waitForTimeout(1500);
await pg.evaluate(()=>{const C=window.dartsCamera,T=[[0,0],[0,-170],[170,0],[0,170],[-170,0]];
  C.cal=T.map(([bx,by])=>{const [px,py]=SIM.toImg(bx,by);return {p:[px/1280,py/720],b:[bx,by],t:-1};});camComputeH();camBuildMask();});
await pg.waitForTimeout(2500);
const rnd=(()=>{let s=params.seed||7;return()=>{s=(s*16807)%2147483647;return s/2147483647;};})();
function spot(){for(;;){const r=Math.sqrt(rnd())*168,a=rnd()*2*Math.PI;return [r*Math.sin(a),-r*Math.cos(a)];}}
let errs=[],ord=0,truth=[],ok=0,tot=0,turnsOk=0,turns=0;
async function throwAt(p){await pg.evaluate(([x,y])=>{SIM.streak=[x-60,y+40,x,y];setTimeout(()=>{SIM.streak=null;SIM.magnets.push({x,y});},60);},p);}
for(let turn=0;turn<(params.turns||4);turn++){
  const gap=params.gap??2500;
  const ps=params.group?(()=>{const [x,y]=spot();const a=rnd()*6.28,d=params.group;return [[x,y],[x+d*Math.cos(a),y+d*Math.sin(a)],[x+d*Math.cos(a+2.1),y+d*Math.sin(a+2.1)]];})():[spot(),spot(),spot()];
  for(const p of ps){await throwAt(p);await pg.waitForTimeout(gap);}
  await pg.waitForTimeout(1500);
  const got=await pg.evaluate(()=>{const h=HITS;HITS=[];return h;});
  const want=await pg.evaluate(ps=>ps.map(([x,y])=>scoreAt(x,y).label),ps);
  const err=got.map(g=>Math.min(...ps.map(p=>Math.hypot(g.x-p[0],g.y-p[1]))));errs.push(...err);
  let m=0;const pool=got.map(g=>g.label);want.forEach(w=>{const j=pool.indexOf(w);if(j>=0){m++;pool.splice(j,1);}});ok+=m;tot+=3;const inOrder=want.every((w,i)=>got[i]&&got[i].label===w);ord+=inOrder?1:0;
  // pull out with a hand
  const cur0=await pg.evaluate(()=>dartsApi.state().cur);
  await pg.evaluate(()=>{SIM.hand={x:0,y:0};SIM.expo=-6;});await pg.waitForTimeout(1200);
  await pg.evaluate(()=>{SIM.magnets=[];});await pg.waitForTimeout(600);
  await pg.evaluate(()=>{SIM.hand=null;SIM.expo=0;});await pg.waitForTimeout(2500);
  const cur1=await pg.evaluate(()=>dartsApi.state().cur);
  const status=await pg.evaluate(()=>dartsCamera.status);
  const nextOk=cur1!==cur0;turns++;if(nextOk&&m===3&&got.length===3)turnsOk++;
  console.log(`turn ${turn}: want ${want.join(' ')} | got ${got.map(g=>g.label).join(' ')||'(nothing)'} | err mm ${err.map(e=>e.toFixed(1)).join(' ')} | next ${nextOk?'yes':'NO'} | ${status}`);
}
errs.sort((a,b)=>a-b);console.log(`RESULT darts right ${ok}/${tot}, in order ${ord}/${turns}, perfect turns ${turnsOk}/${turns}, err median ${(errs[errs.length>>1]||0).toFixed(1)} max ${(errs[errs.length-1]||0).toFixed(1)} mm`);
await b.close();
