// Injected before the page loads: replaces the webcam with a simulated overhead view of a
// black-and-white paper dartboard. window.SIM controls magnets, a hand and lighting.
(()=>{
const W=1280,H=720;
const P=Object.assign({cx:640,cy:370,s:1.55,k:0.12,sy:0.9,noise:9,magR:6.5,magCol:'#161616',hi:'#6a6a6a',shadow:.35,shadowOff:[2.5,3],expo:0},window.SIM_PARAMS||{});
const ORDER=[20,1,18,4,13,6,10,15,2,17,3,19,7,16,8,11,14,9,12,5];
const toImg=(bx,by)=>[P.cx+P.s*bx+P.k*P.s*by, P.cy+P.sy*P.s*by];   // affine, mm -> px
const SIM={magnets:[],hand:null,streak:null,expo:0,toImg,P};
window.SIM=SIM;SIM.canvas=null;
const c=document.createElement('canvas');c.width=W;c.height=H;SIM.canvas=c;const x=c.getContext('2d');
function board(){
  x.save();x.setTransform(P.s,0,P.k*P.s,P.sy*P.s,P.cx,P.cy);
  x.fillStyle='#f4f4f0';x.fillRect(-215,-215,430,430);          // paper
  const ring=(r0,r1,phase)=>{for(let i=0;i<20;i++){const a0=(i*18-9-90)*Math.PI/180,a1=a0+18*Math.PI/180;
    x.beginPath();x.arc(0,0,r1,a0,a1);x.arc(0,0,r0,a1,a0,true);x.closePath();x.fillStyle=(i+phase)%2?'#f4f4f0':'#141414';x.fill();}};
  ring(170,162,1);ring(162,107,0);ring(107,99,1);ring(99,15.9,0);
  x.beginPath();x.arc(0,0,15.9,0,7);x.fillStyle='#f4f4f0';x.fill();
  x.beginPath();x.arc(0,0,6.35,0,7);x.fillStyle='#141414';x.fill();
  x.strokeStyle='#777';x.lineWidth=.6;for(const r of [6.35,15.9,99,107,162,170]){x.beginPath();x.arc(0,0,r,0,7);x.stroke();}
  x.fillStyle='#141414';x.font='16px sans-serif';x.textAlign='center';x.textBaseline='middle';
  ORDER.forEach((n,i)=>{const a=(i*18)*Math.PI/180;x.fillText(n,190*Math.sin(a),-190*Math.cos(a));});
  for(const m of SIM.magnets){
    x.fillStyle=`rgba(0,0,0,${P.shadow})`;x.filter='blur(3px)';x.beginPath();x.arc(m.x+P.shadowOff[0],m.y+P.shadowOff[1],P.magR+1,0,7);x.fill();x.filter='none';
    x.fillStyle=m.col||P.magCol;x.beginPath();x.arc(m.x,m.y,P.magR,0,7);x.fill();
    x.fillStyle=P.hi;x.beginPath();x.arc(m.x-P.magR*.35,m.y-P.magR*.35,P.magR*.3,0,7);x.fill();
  }
  if(SIM.streak){const s=SIM.streak;x.strokeStyle='rgba(40,40,40,.5)';x.lineWidth=P.magR*1.6;x.lineCap='round';x.beginPath();x.moveTo(s[0],s[1]);x.lineTo(s[2],s[3]);x.stroke();}
  x.restore();
  if(SIM.hand){const [hx,hy]=toImg(SIM.hand.x,SIM.hand.y);x.fillStyle='#c98f6d';x.beginPath();x.ellipse(hx,hy,90,60,.5,0,7);x.fill();x.fillRect(hx,hy-40,600,80);}
}
function draw(){
  x.fillStyle='#8a8f86';x.fillRect(0,0,W,H);board();
  const d=x.getImageData(0,0,W,H),a=d.data,n=P.noise,e=SIM.expo;
  for(let i=0;i<a.length;i+=4){const r=(Math.random()+Math.random()-1)*n;a[i]+=r+e;a[i+1]+=r+e;a[i+2]+=r*1.3+e;}
  x.putImageData(d,0,0);
}
setInterval(draw,50);draw();
const stream=c.captureStream(20);
navigator.mediaDevices.getUserMedia=async()=>stream;
navigator.mediaDevices.enumerateDevices=async()=>[{kind:'videoinput',deviceId:'sim',label:'Simulated webcam'}];
})();
