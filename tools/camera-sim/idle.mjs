// empty board for 60 s with heavy noise, exposure wobble and a hand passing: nothing should be scored
import {chromium} from '/opt/node22/lib/node_modules/playwright/index.mjs';
import fs from 'fs';
const b=await chromium.launch();const pg=await b.newPage({viewport:{width:1400,height:900}});
await pg.addInitScript(`window.SIM_PARAMS={"noise":18};localStorage.clear();`);
await pg.addInitScript(fs.readFileSync(new URL('./fakecam.js',import.meta.url),'utf8'));
await pg.goto('file://'+process.argv[2]);
await pg.evaluate(()=>{document.querySelector('#setup')?.close?.();newGame({names:['A','B'],start:501,legsToWin:1,doubleOut:true});window.HITS=[];const o=window.registerDart;window.registerDart=(x,y)=>{HITS.push(scoreAt(x,y).label);o(x,y);};});
await pg.evaluate(()=>camStart());await pg.waitForTimeout(1500);
await pg.evaluate(()=>{const C=dartsCamera,T=[[0,0],[0,-170],[170,0],[0,170],[-170,0]];C.points=T.map(([bx,by])=>{const [px,py]=SIM.toImg(bx,by);return [px/1280,py/720];});camComputeH();camBuildMask();});
for(let i=0;i<30;i++){await pg.evaluate(i=>{SIM.expo=[0,3,-3,6,-2][i%5];if(i%10===5)SIM.hand={x:50,y:50};else SIM.hand=null;},i);await pg.waitForTimeout(2000);}
console.log('false hits:',JSON.stringify(await pg.evaluate(()=>HITS)));await b.close();
