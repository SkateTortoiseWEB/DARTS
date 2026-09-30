// node replay.mjs <oche.html> <unzipped recording dir> [optionsJSON]
// Plays an Oche camera recording (Record button in the camera view) into the page as if it were the webcam,
// using the calibration and settings saved with it, and prints what gets scored. Options override the saved
// ones, e.g. {"sens":24}.
import {chromium} from '/opt/node22/lib/node_modules/playwright/index.mjs';
import fs from 'fs';
const [,,page,dir,extra]=process.argv;const info=JSON.parse(fs.readFileSync(dir+'/settings.json'));
const over=JSON.parse(extra||'{}'),sizes=over.sizes||info.learnedDartSizes||[];delete over.sizes;   // {"sizes":[230,230]} = already learnt dart size (square mm)
const opts=Object.assign({},info.options,over);
const b=await chromium.launch({args:['--autoplay-policy=no-user-gesture-required','--allow-file-access-from-files']});
const pg=await b.newPage({viewport:{width:1400,height:900}});
pg.on('pageerror',e=>console.log('PAGEERR',e.message));
pg.on('console',m=>{if(m.text().startsWith('@'))console.log(m.text().slice(1));});
await pg.addInitScript(`localStorage.clear();localStorage.setItem('oche-cam',${JSON.stringify(JSON.stringify({cal:info.calibrationPoints.map((p,i)=>({p,b:[info.calibrationTargets[i].x,info.calibrationTargets[i].y],t:-1})),opts:{...opts,enabled:false},sizes}))});
  window.__vid=${JSON.stringify('file://'+fs.realpathSync(dir)+'/camera.webm')};
  navigator.mediaDevices.getUserMedia=async()=>{const v=document.createElement('video');v.muted=true;v.src=window.__vid;window.__rv=v;await v.play();return v.captureStream();};
  navigator.mediaDevices.enumerateDevices=async()=>[];`);
await pg.goto('file://'+page);
await pg.evaluate(()=>{document.querySelector('#setup')?.close?.();newGame({names:['A','B'],start:501,legsToWin:1,doubleOut:true});
  const o=window.camSetStatus;window.camSetStatus=t=>{console.log('@'+(window.__rv?__rv.currentTime:0).toFixed(1).padStart(5)+'  '+t);o(t);};
  const r=window.registerDart;window.registerDart=(x,y)=>{console.log('@'+__rv.currentTime.toFixed(1).padStart(5)+'    dart at '+x.toFixed(0)+','+y.toFixed(0)+' = '+scoreAt(x,y).label);r(x,y);};});
await pg.evaluate(()=>camStart());
await pg.evaluate(()=>new Promise(r=>{const i=setInterval(()=>{if(__rv.ended){clearInterval(i);r();}},200);}));
await b.close();
