pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- eXPLORERS
-- BY rEMY dEVAUX

-- originally made for alakajam

-- post-jam changelog:
-- - added title-screen intro/outro
-- - changed title from explorer to explorers
-- - enhanced title-screen
-- - added birds
-- - animated percentage going up
-- - improved camera
-- - added map border vfx
-- - made map borders push back rafts
-- - optimized rendering with (more) object culling
-- - added explorer voices
-- - added moai
--
-- - fixed skull and crystal texts being inversed
-- - fixed explorers bringing rafts further inland and getting stranded
-- - fixed explorers origin direction being inverted

--for i,v in ipairs(split"♥………………♥,★ tHANK yOU! ★,… FOR BUYING …,eXPLORERS dELUXE,♥………………♥") do
for i,v in ipairs(split"♥………………♥,explorers deluxe,IS AVAILABLE ON, ★ itch.io! ★,♥………………♥") do
 menuitem(i,v,function() end)
end

sfx(27,3)
plt=split"0x01,0x8c,0x0c,0x84,0x04,0x8e,0x0f,0x83,0x03,0x0b,0x8a,0x87,0x09,0x08,0x82"
for i=0,31 do
 for j=1,15 do
  pal(j,plt[j-i\2] or 0,1)
 end
 flip()
end

poke(0x5f2e,1)

drk,lit={},{}
for i=0,15 do
 lit[i],drk[i]=sget(i,4),sget(i,6)
end

function _init()
 mmoai={}
 all_colors_to()
 camera()
 init_objects(split"raft,bot,item,bird,moai")
 gen_map()
 cls()flip()
 sfx(28,3)

 pal(plt,1)
 
-- local plt = split"0x01,0x8c,0x0c,0x84,0x04,0x8e,0x0f,0x83,0x03,0x0b,0x8a,0x87,0x09,0x08,0x82"
-- 
-- for i=0,15 do
--  pal(i,plt[drk[drk[i]]] or 0,1)
-- end
 
 dpctg,pctg,pctgy,wavt,wavi,lndn = 0,0,-16,9,0,0
 title,titlet,winda,haggle,hagcld,credt = true, 0, rnd(1),false,1,0

 nwinda=winda
 
 local mx,my
 repeat
  mx,my=rnd(64)\1,rnd(48)\1
 until mget(mx|((my&0x20)<<1),my&31)==0
 player = new_player((mx<<5)|16,(my<<5)|16)
 camx,camy = player.x-64,player.y-64
 
 for i=0,15 do
  local mx,my
  repeat
   mx,my=rnd(64)\1,rnd(48)\1
  until mget(mx|((my&0x20)<<1),my&31)==0
  local b=new_bot((mx<<5)|16,(my<<5)|16)
  for j=1,100 do
   upd_bot(b)
  end
 end
 
 for i=0,31 do
  local x,y
  repeat
   x=rnd(256)
   y=rnd(192)
  until get_map(x,y)~=0
  new_item((x<<3)|4,(y<<3)|4,i&3)
 end
 
 for i=0,15 do
  local x,y
  repeat
   x=rnd(256)\1
   y=rnd(192)\1
  until get_map(x,y)~=0
  new_item((x<<3)|4,(y<<3)|4,(i&3)|4)
 end
 
-- new_bot(player.x+8,player.y)
 camera(camx,camy)
end

function _update()
 srand(t()<<4)
 
 wavt+=.033
 lndn/=484
 if wavt>2+lndn then
  local ch=wavi&1+1
  if stat(16+ch)<0 then
   wavi+=1
   sfx(8+rnd(4),(wavi&1)+1)
   wavt=rnd(2)
  end
  
  ch=(ch&1)+1
  if stat(16+ch) and chance(1) then
   bird_sfx(53+rnd(5)\1,ch)
  end
 end
 
 lndn=0
 
-- if btnp(4,1) then
--  start_haggle(objs.bot[1])
-- end
 
 if chance(1) then
  nwinda=rnd(1)
 end
 
 local dw=angle_diff(nwinda,winda)
 if abs(dw)>0.1 then
  winda-=0.02*dw
 end
 
 camera(camx,camy)
 update_objects()
 for i=1,8 do new_birds() end
 
 srand(t()<<1)
 if haggle then
  upd_haggle()
 elseif hagcld>0 then
  hagcld-=0.033
 end
 
 if btn(5) then
  local fy=256
  sfx(23)
  while btn(5) do
   fy=lerp(fy,92-6,0.1)
  
   draw_minimap(64,fy)
   flip()
  end
  sfx(24)
  while fy<256 do
   fy=lerp(fy,300,0.1)
   _draw()
   draw_minimap(64,fy)
   flip()
  end
 end
 
 for y=-2,2 do
 for x=-2,2 do
  local mx=min((player.x>>5)+x,63)
  local my=min((player.y>>5)+y,47)
  mx,my=mx|((my&0x20)<<1),my&31
  
  mset(mx,my,mget(mx,my)|0x80)
 end
 end
 
 local v=player.onraft and 32 or 64
 camx=lerp(camx,player.x-64+v*player.vx,0.05)
 
 if haggle then
  camy=lerp(camy,player.y-32,0.05)
 else
  camy=lerp(camy,player.y-64+v*player.vy,0.05)
 end
end

function _draw()
 cls(2)
-- draw_face(face,16,16,btn(4,1),btn(5),t())
 
 camera(flr(camx+.5),flr(camy+.5))
 draw_map(camx\8,camy\8)
 for s in group"moai" do
  spr(0x8c, s.x-16, s.y-16, 4, 4)
 end
 
 draw_objects(0,2)
 
 draw_leaves(camx\8,camy\8)
 
 pal(11,0)
 draw_objects(3,4)
 all_colors_to()
 
 camera()
 
 if haggle then
  drw_haggle()
 end
 
 
 if title or titlet>0 then
  titlet=mid(titlet+(title and .02 or-.02),0,2)
  local v=sqr(sin(min(titlet,1)*.25))
  local v0=sqr((1-cos(min(titlet*2,1)*.5))>>1)
  local v2=sqr(sin(mid(titlet-.5,0,1)*.25))*128
 
  if title then
   rectfill(0,0,127,63-v0*24,0)
   rectfill(0,64+v0*24,127,127,0)
  else
   rectfill(0,-1,127,v0*40-1,0)
   rectfill(0,129-v0*40,128,127,0)
  end
 
  local x,cs=28,split"3,2,1,2,3"
  
  camera(0,48-v*48)
  
  for i=0,8 do
   local s=8+(i\5)*16+(i%5)
   local x=x+i*8
   local y=12+2*cos(t()*.45+(i>>3))
   local c=cs[flr(i+t()*16)%64] or 7
   
   pal(7,0)
   spr(s,x-1,y)
   spr(s,x+1,y)
   spr(s,x,y-1)
   spr(s,x,y+1)
   spr(s,x+1,y-1)
   spr(s,x-1,y+1)
   pal(7,c)
   spr(s,x,y)
  end
  pal(7,7)
  
  super_print("BY rEMY  ",96,28)
  pal(9,0)
  spr(0x17,106,27)
  spr(0x17,105,26,1,1,true,true)
  pal(9,9)
  
  camera()
  super_print("🅾️ TO CONFIRM PROMPTS ",-64+v2,92)
  super_print("❎ TO VIEW MAP ",192-v2,102)
  
  credt += 1
  local credits = "      tHIS GAME WAS MADE BY rEMY dEVAUX  -♥-  sPECIAL THANKS TO: bENJAMIN sOULE, lISA sCHAEFFER, jOSEPH wHITE, eLODIE pRADEL, cOCO, pICO  -♥-  tHANK YOU TO MY pATREON SUPPORTERS: ★bLAS, dAN lEWIS, dAN rEES-jONES, fLO dEVAUX, jEARL, jOEL jORGENSEN, jOSEPH wHITE, mARTY kOVACH, pAUL nGUYEN, bBSAMURAI, bERKFREI, rOTATETRANSLATE, cOLE sMITH, dAVID cOLE, eIYERON, eLIAS aLONSO, eLIOTT, rAPHAEL gASCHIGNARD, sAM lOESCHEN, aMY, aNNE lE cLECH, gRUBER, jAKUB wASILEWSKI, pIERRE b., sEAN s. lEBLANC, sIMON sTれ✽LHANDSKE, sLONO, vAPORSTACK  -♥-  aND THANK you FOR PLAYING!!"
  local x,y = 256-(credt)%(#credits*4+400), 129-v0*7
  
  print(credits, x, y+1, 1)
  print(credits, x, y, 2)
  
  if titlet==2 and (t()%2<1.5) then
   super_print("[pRESS 🅾️] ",64,116)
  end
  
  if btn(4) and title then
   title,titlet=false,1.5
   sfx(30,3)
  end
 else
  pctgy=lerp(pctgy,2.5,0.1)
  
  if pctg>96 and pctg<100 then
   pctg=100
   music(0)
  end
  
  if dpctg<pctg then
   dpctg+=0.06
  end
  
  if dpctg >= 100 then
   super_print("★ 100% ★  ",63,pctgy)
   super_print("~ wELL dONE! ~",63,pctgy+10)
  else
   local str=sub(tostr(dpctg),1,4).."%"
   super_print(str,63,pctgy)
  end
 end
 
 if stat(1)<0.8 then
  count_pctg()
 end

-- if btn(5,1) then
--  print(stat(1),0,0,7)
-- end
end

function super_print(str,x,y,c)
 x-=#str*2
 color(0)
 print(str,x-1,y)
 print(str,x+1,y)
 print(str,x,y-1)
 print(str,x,y+1)
 print(str,x+1,y-1)
 print(str,x-1,y+1)
 
 print(str,x,y,c or 7)
end


function start_haggle(b)
 player.haggle,b.haggle,player.vx,player.vy,b.vx,b.vy=b,true,0,0,0,0
 haggle,hagt,hagstrt,hagcld=true,0,true,3
 
 hstep,hline,talkin=1,srnd "hI... wHAT DO YOU WANT?,HUM.. hELLO?,wHAT?,... yOU WANT SOMETHING?,yES?,wANNA TALK?,wHAT'S WITH YOU SAILOR?,mAKE IT QUICK. pLEASE."
 
 sfx(22,3)
end

function end_haggle()
 player.haggle.haggle, player.haggle, haggle, stophag=nil
end

function upd_haggle()
 local b=player.haggle
 if stophag then
  hagt=max(hagt-0.33,0)
  if hagt<=0 then
   end_haggle()
  end
 else
  hagt=min(hagt+0.33,5)
 end
 
 if hagt>=5 and hagstrt and not stophag then
  talkin=0
  hagstrt=false
 end
 
 if talkin and talkin<#hline then
  talkin+=btn(4) and 2 or .5
  local chr=ord(hline, talkin)
  if (talkin%1<.5 or btn(4)) and chr~=32 then
   srand(chr)
--   local a=0x3530
--   poke(0x3530,(rnd(16)+b.tone)|(srnd"0,1"<<6))
----   poke(a|1,((rnd(6)&7)<<1)|((rnd(6)&7)<<4))
--   poke(0x3531,(((rnd(6)&7)+1)<<1)|((srnd"3,4,5")<<4))
--   poke(0x3571,4+rnd(12)&0xff)
   poke2(0x3530,0x8b00|(irnd(16)+b.tone)|(irnd(4)<<6)|(irnd(6)<<12))
   sfx(12,3)
   srand(t())
  end
  
  if talkin>=#hline then
   if hstep==1 then
    hchoice={
     "wHERE'R YOU COMIN FROM?",
     "cAN WE HELP EACH OTHER?",
     srnd "yOUR ASS LOOKS GREAT!,i'M LOVING YOUR LOOK!,yOU'RE VERY GOODLOOKING!,i THINK i'M IN LOVE.,cOULD WE... KISS?,hOW ARE YOU THIS CUTE?"
    }
   elseif hstep==2 then
    hchoice={
     "wOULD YOU HELP ME?",
     "aH, TOO BAD."
    }
   elseif hstep==4 then
    hchoice={
     "wHERE'R YOU COMIN FROM?",
     "cAN WE HELP EACH OTHER?"
    }
   elseif hstep==3 then
    if b.frdly then
     map_transfer(b)
     hchoice={"nICE, BYE!"}
     hstep=7
    else
     talkin=0
     if haggle_items(b) then
      hstep=5
      hline=srnd "yES!,pLEASURE DOIN' BIZNES',yOU GOT IT.,hAH! tHIS WILL SERVE!,dEAL DEALT AND DONE!"
      b.frdly=true
      b.forth=true
     else
      hstep=6
      hline=srnd "tHANKS BUT NO DEAL.,mMMH NOT GOOD ENOUGH!,fOR THIS?! nO WAY!,cUTE BUT NO."
     end
    end
   elseif hstep==5 then
    map_transfer(b)
    hchoice={srnd "nICE! bYE!,gREAT! tHANKS!"}
    hstep=7
   elseif hstep==6 then
    hchoice={srnd "aH.,oK BYE THEN.,yOU'RE KEEPING IT?"}
    hstep=7
   end
   cho=1
  end
 end
 
 
 if hchoice then
  if btnp(3) then
   cho=min(cho+1,#hchoice)
  end
  if btnp(2) then
   cho=max(cho-1,1)
  end
  
  if btnp(4) then
   if hstep==1 then -- meet
    if cho==1 then
     hstep=2
    elseif cho==2 then
     hstep=3
    elseif cho==3 then
     hstep=4
    end
   elseif hstep==2 then
    if cho==1 then
     hstep=3
    else
     stophag=true
    end
   elseif hstep==4 then
    if cho==1 then
     hstep=2
    elseif cho==2 then
     hstep=3
    end
   elseif hstep==7 then
    stophag=true
   end
   
   if hstep==2 then
    if b.forth then
     local direw={[-1]="wEST","eAST"}
     local dirns={[-1]="nORTH","sOUTH"}
     local dx,dy=b.stx-b.x,b.sty-b.y
     local dir=abs(dx)>abs(dy) and direw[sgn(dx)] or dirns[sgn(dy)]

     hline="i COME FROM THE "..dir.."."
    else
     hline=srnd"wHY WOULD I TELL YA?,wHO ARE YOU AGAIN?"
    end
   elseif hstep==3 then
    if b.frdly then
     hline=srnd"sURE FRIEND!,hERE YOU GO!"
    elseif b.forth then
     hline=srnd"wANT M'MAP? cOULD HAPPEN,lET'S MAKE IT HAPPEN"
    else
     hline=srnd"hOW MUCH'S IT WORTH T'YA,lET'S SEE WHAT YOU HAVE"
    end
   elseif hstep==4 then
    if b.vain then
     b.forth=true
     hline=srnd "tHANKS! y'RE NOT TOO BAD,rEALLY?? oH MY!,yA'RE PRETTY CUTE TOO.,hAH! oNE GETS THISRTY EH?,yOU HAVE GOOD TASTE.,yA'RE TOO KIND.,wAS THINKING THE SAME!"
    else
     hline=srnd "yA'RE CREEPY.,mMH NOT INTERESTED.,i'M NOT FALLING FOR THAT.,pLEASE STOP.,lEAVE ME ALONE.,qUIT IT.,tRYNA BUTTER ME UP?"
    end
   end

   talkin,hchoice=0
   if stophag then
    talkin=nil
    sfx(21,3)
   end
  end
 end
 
end

function drw_haggle()
 local b=player.haggle

 local r=min(hagt*16,40)
 local y=128-r
 
 circfill(127-r/4,110,r,0)
 circ(127-r/4,110,r-2,3)
 
 rectfill(0,y-1,127,127,0)
 line(1,y,92,y,2)
 line(2,y,91,y,3)
 line(3,y,90,y,7)
 
 local dx=hagt*7.5
 draw_face(b.k,137-dx,87,talkin and talkin<#hline,b.forth,time(),b.skn,b.hr)
 
 if not talkin or stophag then return end

 y+=4
 local str=sub(hline,1,talkin+1)
 print(str,0,y+2,1)
 print(str,0,y+1,2)
 print(str,0,y,7)
 y+=1
 
 local x=3
 if hchoice then
  for i,s in pairs(hchoice) do
   local y=y+i*8
   
   if i==cho then
    local x=x+1
    spr(0x1c,x-5,y)
    print(s,x,y+2,1)
    print(s,x,y+1,2)
    print(s,x,y,7)
   else
    print(s,x,y+1,1)
    print(s,x,y,3)
   end
   
  end
 end

end

function map_transfer(b)
 local fy=256
 sfx(25,0)
 for i=0,95 do
  fy=lerp(fy,92-6,0.1)
  
  local v=b.hist[i]
  for j=0,31 do
   local mx=((i&1)<<5)|j
   local my=i>>1
   mx,my=mx|((my&0x20)<<1),my&31
   
   local bit=((v<<j)&0x8000)>>>8
   mset(mx,my,mget(mx,my)|bit)
  end
  
  if i&1==1 then
   fy=lerp(fy,92,0.1)
   draw_minimap(64,fy)
   flip()
  end
 end
 
 for i=0,15 do
  draw_minimap(64,fy)
  flip()
 end
 
 sfx(24,0)
 while fy<256 do
  fy=lerp(fy,300,0.1)
  _draw()
  draw_minimap(64,fy)
  flip()
 end
end

function haggle_items(b)
 camera(-16,-48)
 local ch,ok=1
 local pl,pr
 local ti=10
 while not ok do
  if ti>0 then
  ti-=1
  end
  
  if btn(0) then
   if not pl then
   ch=max(ch-1,1)
   pl=true
   end
  else
   pl=false
  end
  
  if btn(1) then
   if not pr then
   pr=true
   ch=min(ch+1,8)
   end
  else
   pr=false
  end
 
  rectfill(-16,0,96+16,32,0)
  local str="gIVE WHAT?"
  print(str,47-#str*2,3,1)
  print(str,47-#str*2,2,2)
  print(str,47-#str*2,1,7)
  local y=10
  for i=1,8 do
   local x=(i-1)*12+2
   rect(x-1,y-1,x+8,y+8,1)
   local s=player.items[i]
   if s then
    spr(0x70+s,x,y)
   end
   
   if ch==i then
    spr(22,x,y+8)
    local str
    if s then
     str=items[s+1]
    else
     str="gO bACK"
    end
    local xx=x-#str*2+3
    local yy=y+15
    print(str,xx,yy+2,1)
    print(str,xx,yy+1,2)
    print(str,xx,yy,7)
    
    ok=(btn(4) and ti<=0)
   end
  end
  
  flip()
 end
 
 n=player.items[ch]
 
 if not n then
  stophag,talkin=true
  sfx(21,3)
  return false
 end
 
 deli(player.items,ch)

 if b.forth or n>=4 then
  return true
 else
  sfx(26)
  return false
 end
end

function count_pctg()
 if pctg==100 then return end

 local n=0
 for y=0,47 do
  for x=0,63 do
--   local m=mget(x,y)
   local m=mget(x|((y&0x20)<<1),y&31)
   if m&0x80>0 then
    n+=1
   end
  end
 end
 
 pctg = n/3072*100
end

-->8
-- * game objects *

function upd_player(s)
 upd_chr(s,
  (btn(0) and -1 or 0)+
  (btn(1) and 1  or 0),
  (btn(2) and -1 or 0)+
  (btn(3) and 1  or 0)
 )
 
 s.rafttim=max(s.rafttim-0.25,0)
 
 if s.onraft then
  if get_map(s.x>>3,s.y>>3)>0 and s.rafttim<=0 then
   s.onraft=false
   s.rafttim=2.5
   new_raft(s)
   sfx(19)
  end
 else
  if s.rafttim<=0 then
   if take_raft(s) then
    sfx(20)
   end
  end
  
  local i=collide_objgroup(s,"item")
  if i then
   local n=i.s
   add(s.items,n)
   deregister_object(i)
   new_text(items[n+1],s.x,s.y-8)
   if n<=4 then
    sfx(14)
   else
    sfx(13)
   end
  end
 end
 
 if not haggle and hagcld<=0 and not title then
  local b=collide_objgroup(s,"bot")
  if b then
   start_haggle(b)
  end
 end
end

function upd_bot(s)
 s.dirt-=0.033
 s.rafttim=max(s.rafttim-0.25,0)
 
 if s.dirt<0 then
  if s.onraft then
   s.dir+=got(0.25)
   s.dir%=1
  else
   if s.toraft<=0 and chance(75) then
    local d,r=0x7fff
    for rr in group("raft") do
     local dx,dy=rr.x-s.x,rr.y-s.y
     local dd=sqr(dx>>8)+sqr(dy>>8)
     if dd<d then
      d,r=dd,rr
     end
    end
    
    if r then
     s.dir=atan2(r.x-s.x,r.y-s.y)%1
    end
   else
    if chance(10) then
     s.dir=-1
    else
     s.dir+=got(0.5)
     s.dir%=1
    end
   end
  end
  
  s.dirt=1+rnd(2)
 end
 
 if s.dir>=0 then
  if abs(player.x-s.x)<64 or abs(player.y-s.y)<64 then
   upd_chr(s,.75*cos(s.dir),.75*sin(s.dir))
  else
   upd_chr(s,cos(s.dir),sin(s.dir))
  end
 else
  upd_chr(s,0,0)
 end
 
 if s.onraft then
  if get_map(s.x>>3,s.y>>3)>0 and s.rafttim<=0 then
   s.onraft=false
   s.toraft=10+rnd(10)
   new_raft(s)
  end
 elseif not s.haggle then
 
  s.toraft-=0.033
  
  if s.toraft<=0 then
   take_raft(s)
  end
 end
 
 s.histt-=0.033
 if s.histt<=0 then
  s.histt=2+rnd(1)

  for y=-2,2 do
  for x=-2,2 do
   local mx=mid((s.x>>5)+x,0,63)&0xffff
   local my=mid((s.y>>5)+y,0,47)&0xffff
   
   local a=(my<<1)|((mx>>5)&0xffff)
   s.hist[a]|=0x8000>>>(mx&31)
  end
  end
 end
end

function upd_chr(s,accx,accy)
 if s.haggle then return end

 if s.onraft then
  local acc=0.05+(_dbg and 1 or 0)

  s.vx+=accx*acc
  s.vy+=accy*acc
  
  s.vx+=(max(-s.x,0)-max(s.x-2048,0))>>10
  s.vy+=(max(-s.y,0)-max(s.y-1536,0))>>10
  
  s.x+=s.vx +0.1*cos(winda)
  s.y+=s.vy +0.1*sin(winda)
  
  s.vx*=0.95
  s.vy*=0.95
  
  local ma=1.1+(_dbg and 40 or 0)
  local dv=dist(s.vx,s.vy)
  if dv>ma then
   s.vx*=ma/dv
   s.vy*=ma/dv
  end
  
  s.rdt-=0.5
  if s.rdt<0 and not(abs(s.x-_camx-64)>72 or abs(s.y-_camy-64)>72) then
   add(rpls,{x=s.x,y=s.y,l=0})
   s.rdt=2
  end
 else
 
  local acc=0.5
  s.vx+=accx*acc
  s.vy+=accy*acc
  
  local xx=(s.x+4*s.vx)
  local yy=(s.y+4*s.vy)
  
  acc>>=2
  local b=0
  if get_map((xx-8)>>3,(yy-8)>>3)==0 then
   s.vx+=acc
   s.vy+=acc
   b+=1
  end
  
  if get_map((xx+8)>>3,(yy-8)>>3)==0 then
   s.vx-=acc
   s.vy+=acc
   b+=1
  end
  
  if get_map((xx-8)>>3,(yy+8)>>3)==0 then
   s.vx+=acc
   s.vy-=acc
   b+=1
  end
  
  if get_map((xx+8)>>3,(yy+8)>>3)==0 then
   s.vx-=acc
   s.vy-=acc
   b+=1
  end
  
  if b==4 then
   s.vx,s.vy=0,0
  end
  
  s.x+=s.vx
  s.y+=s.vy
  
  s.vx*=0.5
  s.vy*=0.5
  
  local ma=2
  local dv=dist(s.vx,s.vy)
  if dv>ma then
   s.vx*=ma/dv
   s.vy*=ma/dv
  end
 end
 
 if abs(s.vx)>0.1 then
  s.fleft=s.vx<0
 end

end

function take_raft(s)
 local r=collide_objgroup(s,"raft")

 if r then
  s.onraft=true
  s.col=r.col
  s.rafttim=5
  s.x,s.y=r.x,r.y
  s.vx,s.vy=r.pvx,r.pvy
  s.x+=s.vx
  s.y+=s.vy
  s.dir=atan2(s.vx,s.vy)%1
  s.dirt=7+rnd(1)
  
  deregister_object(r)
  return true
 end
end

function upd_bird(s)
 if #s.bds > 0 then
  local d = true
  for b in all(s.bds) do
   b[1]+=b[3]
   b[2]+=b[4]
   if b[1]<_camx-16 or b[1]>_camx+144 or b[2]<_camy-16 then
    del(s.bds,b)
   end
   
   if chance(5) then
    bird_sfx(b[7],1)
   end
  end
  if #s.bds==0 then
   deregister_object(s)
  end
 else
  if max(abs((player.x>>3)-s.mx),abs((player.y>>3)-s.my)) < 6 then
   local x,y=s.mx<<3,(s.my<<3)-4
   local k,c=1+rnd(3.5)
   for i=1,k do
    add(s.bds,{
     x+got(4),y+got(4),
     rnd{1.5,-1.5}+got(.5),
     -0.5-rnd(1.5),
     rnd(9999),ornd(hair),
     42+rnd(16)\1
    })
    bird_sfx(s.bds[i][7],1)
   end
   sfx(18,0)
  end
 end
end

function bird_sfx(tone,ch)
 poke(0x3684,tone|192)
 poke(0x3686,(tone+4)|192)
 poke(0x3688,(tone+4)|192)
 poke(0x36C5,10+rnd(10))
 sfx(17,ch)
end

function upd_moai(s)
 if max(abs(s.x - player.x), abs(s.y - player.y))>80 or s.explo then return end
 sfx(33,2)
 s.explo = true
end


function drw_chr(s)
 if abs(s.x-_camx-64)>72 or abs(s.y-_camy-64)>72 then
  return
 end

 if s.onraft then
  drw_raft(s)
  
  draw_oanim(s.idle,s.x-6,s.y-6,s.fleft,s.plt)
 else
  local dorun=abs(s.vx)+abs(s.vy)>0.1
  draw_oanim(dorun and "run" or s.idle,s.x-4,s.y-8,s.fleft,s.plt)
  
  local n=(time()*20 + (s.k or 0))%8
  if dorun and n>=3 and n<3.666 and stat(19)<0 then-- and n%1<0.666 then
   sfx(s==player and 15 or 16, 3)
  end
 end
 all_colors_to()
end

function drw_sail(x,y,coa,sia,col,var)
 pal(14,col)
 pal(15,drk[col])
 
 local mx=126+var
 for i=30,1,-1 do
  local y=y\1+(i>>2)
  local si=sin(i/60)
  local w=5-2*si
  local f=(6+2*cos(t()>>1))*si
  
  local ax,ay = x-w*coa+f*sia, y-w*sia-f*coa
  local bx,by = x+w*coa+f*sia, y+w*sia-f*coa
  
  local my=16|(i>>5)
  if ay<by then
   ax,ay,bx,by=bx,by,ax,ay
  end
  
  pal(13,5)
  tline(ax,ay+1,bx,by+1,mx,my,.5/w,0)
  pal(13,13)
  tline(ax,ay,bx,by,mx,my,.5/w,0)
 end
 
 pal(14,14)
 pal(15,15)
end

function drw_raft(s)
 if abs(s.x-_camx-64)>72 or abs(s.y-_camy-64)>72 then
  return
 end

 local coa,sia = cos(winda+.25), 0.5*sin(winda+.25)

 spr(0x1e,s.x-8,s.y-4,2,1)

 if coa>=-0.1 then
  spr(0x0d,s.x-4,s.y-12,1,2)
 end
 
 drw_sail(s.x\1,s.y-12,coa,sia,s.col,s.var)

 if coa<-0.1 then
  spr(0x0d,s.x-4,s.y-12,1,2)
 end
end

function drw_item(s)
 if abs(s.x-_camx-64)>72 or abs(s.y-_camy-64)>72 then
  return
 end

 local sp,x,y=0x70+s.s,s.x-4,s.y-4
 
 all_colors_to(((t()\.25)&1)*7)
 spr(sp,x-1,y)
 spr(sp,x+1,y)
 spr(sp,x,y-1)
 spr(sp,x,y+1)
 all_colors_to()
 spr(sp,x,y)
end


local brdan=split"0x53,0x52,0x51,0x50,0x52"
function drw_bird(s)
 for b in all(s.bds) do
  pal(14,b[6])
  pal(6,lit[b[6]])
  spr(brdan[((time()/.05+b[5])\1)%#brdan+1],b[1],b[2],1,1,b[3]<0)
 end
end

local tcols="\2\3\7\7\7\7\7\7\7\3\2\1"
function drw_text(s)
 s.l+=.5
 
 local c=ord(tcols,s.l)
 super_print(s.str, s.x, s.y+4*sin(s.l/30), c or 0)
 
 if not c then
  deregister_object(s)
 end
end

function drw_moai(s)
 if max(abs(s.x-_camx-64),abs(s.y-_camy-77))>80 then
  return
 end

 spr(0x80+(s.sp&3)*3, s.x-12, s.y-29, 3, 4, s.sp>=4)
end


function new_player(x,y)
 local s={
  x=x,y=y,
  w=6,h=6,
  vx=0,
  vy=0,
  onraft=true,
  rafttim=0,
  col=14,
  rdt=0,
  var=1,
  tc=14,
  hr=2,
  raftcol=14,
  idle="idle1",
  skn=ornd(skin),
  items={2},
  update=upd_player,
  draw=drw_chr,
  regs="to_update,to_draw2"
 }
 
 s.plt={[6]=s.skn,[2]=s.hr,[3]=lit[s.hr],[14]=s.tc}
 
 return register_object(s)
end

function new_raft(chr)
 local s={
  x=chr.x,
  y=chr.y,
  pvx=-chr.vx,
  pvy=-chr.vy,
  w=1,h=1,
  col=chr.col,
  var=chr.var,
  draw=drw_raft,
  regs="to_draw1,raft"
 }
 
 return register_object(s)
end

tunics="\14\13\12\2\3\9\10\11"
function new_bot(x,y)
 local s={
  x=x,y=y,
  w=16,h=16,
  vx=0,vy=0,
  onraft=true,
  toraft=0,
  rafttim=0,
  var=irnd(2),
  dir=rnd(1),
  dirt=0,
  idle=srnd "idle1,idle2,idle3",
  skn=ornd(skin),
  tone=irnd(20),
  k=rnd(),
  rdt=0,
  hist={},
  histt=0,
  stx=x,sty=y,
  
  vain=chance(75),
  forth=chance(40),
  frdly=chance(10),
  
  update=upd_bot,
  draw=drw_chr,
  regs="to_update,to_draw2,bot"
 }
 
 if s.frdly then
  s.vain=true
  s.forth=true
 end
 
 repeat s.hr=ornd(hair) until s.hr~=s.skn
 
 s.tc = chance(25) and s.skn or ornd(tunics)
 s.col=s.tc
 
 s.plt={[6]=s.skn,[2]=s.hr,[3]=lit[s.hr],[14]=s.tc}
 
 for i=0,95 do
  s.hist[i]=0
 end
 
 return register_object(s)
end

function new_item(x,y,s)
 register_object{
  x=x,y=y,
  w=8,h=8,
  s=s,
  draw=drw_item,
  regs="to_draw1,item"
 }
end

function new_birds()
 if #objs.bird > 64 then
  return
 end
 
 local mx,my = rnd(2048)\8, rnd(1536)\8
 if get_map(mx,my)&3>0 then
  srand(mx|my>>16)
  if chance(15) then
   register_object{
    mx=mx,
    my=my,
    bds={},
    update=upd_bird,
    draw=drw_bird,
    regs="bird,to_update,to_draw4"
   }
  end
  srand(time()+rnd())
 end
 
end

function new_text(str,x,y)
 register_object{
  x=x,
  y=y,
  l=1,
  str=str,
  draw=drw_text,
  regs="to_draw4"
 }
end

local mospr = split"0,1,2,3,5,6,7"
function new_moai(x,y)
 local spi = #objs.moai == 0 and 1 or (irnd(#mospr)+1)
 mmoai[(x\32)|((y\32)<<6)] = register_object{
  x=x,
  y=y,
  sp=mospr[spi],
  update=upd_moai,
  draw=drw_moai,
  regs="to_draw3,to_update,moai"
 }
 deli(mospr, spi)
end


-->8
-- * face drawing *

hair="\2\4\5\8\9\12\13\14\15"
skin="\15\4\5\6\7"
local skind={[5]=15,[6]=4,[7]=5}
function draw_face(n,x,y,talk,smile,t,sk,hr)
 srand(n)
 
 camera(-x,-y)

 local sk=sk
 local skd=skind[sk] or 0
 
 pal(6,sk)
 pal(4,skd)
 pal(2,hr)
 
 pal(8,0)
 
 local ns=split"0,1,2,1"
 local nt = ((t/0.1)%4)\1
 local tn = talk and ns[nt+1] or 0
 local ty,th
 if tn==0 then
  if smile then
   ty,th=2,4
  else
   ty,th=4,2
  end
 elseif tn==1 then
  ty,th=1,4
 elseif tn==2 then
  ty,th=0,4
 end
 
 local tx = (rnd(3)\1-1)*(nt\2)
 if talk then
  camera(-x-tx,-y-ty)
 else
  camera(-x,-y-ty)
 end
 
 rectfill(5,-1,15,6,6)
 rectfill(0,7,20,17,6)
 rectfill(7,18,20,21,6)
 rectfill(8,20,8,21,4)

 
 spr(0xd0,-3,0) --forehead
 spr(0xd1,15,-1) --backhead
 
 --eye
 if chance(5) then
  spr(0xd3,5,7)
  line(1,6,5,7,0)
  line(13,8,20,8,0)
 
 else
  local e=0xe8+rnd(4)
  local na=(t+rnd(999))%(1.5+rnd(3))
  local nb=(t+rnd(999))%(2+rnd(4))
  local n1=0.1+rnd(0.3)
  local n2=0.4+rnd(2)
  if na<n1 then
   spr(0xd2,6,8)
  elseif nb<n2 then
   spr(e+16,6,8)
  else
   spr(e,6,8)
  end
 end
 
 local nc=(t+rnd(999))%(2+rnd(6))
 local n3=0.4+rnd(2)
 
 palt(6,true)
 spr(0xc0+rnd(4),6,2-(nc<n3 and 1 or 0)) --eyebrow
 palt(6,false)
 
 spr(0xe4+rnd(4),-4,8) --nose
 
 --mouth
 local n=rnd(4)\1
 
 if chance(50) then
  pal(14,skd)
 end
 
 if tn==0 and smile then
  camera(-x,-y)
  spr(0xd8+n,-1,18)
 else
  local sx,sy=32+n*8,120
  sspr(sx,sy,8,th,-1,18)
 
  camera(-x,-y)
  local yy=8-th
  sspr(sx,sy+yy,8,th,-1,18+yy)
 end
 
 pal(14,14)
 
 rectfill(7,22,20,25,6)
 rectfill(0,26,20,28,6)
 rectfill(5,29,20,32,6)
 if ty<4 then
 rectfill(8,22,8,23,4)
 else
  pset(8,23,4)
 end
 
 spr(0xe0+rnd(4),13,33) --neck
 spr(0xf0+rnd(4),-3,28) --chin
 
 if rnd(2)<1 then
  spr(0xc4+rnd(4),5,32) --beard
 else
  pset(12,33,4)
 end
 
 --hair
 if talk then
  camera(-x-tx,-y-ty)
 else
  camera(-x,-y-ty)
 end

 if rnd(5)>=1 then
  for i=0,3 do pal(1<<i,6) end
  local n=rnd(4)\1
  for i=1,15 do
   if i&(1<<n)>0 then
    pal(i,hr)
   else
    palt(i,true)
   end
  end
  
  spr(0xcc,-4,-12,4,4)
 end
 poke(0x5f5e,0xff)
 
 palt(6,false)
 palt(4,false)
 pal(6,sk)
 pal(4,skd)
 spr(0xd4+rnd(4),14,10)--ear
 
 --pset(0,0,3)
 
 camera()
 for i=1,15 do pal(i,i)palt(i,false)end
 pal(0,0)
end
-->8
-- * objects handling *
function init_objects(groups)
 objs={to_update={}}
 for i=0,4 do
   objs["to_draw"..i]={}
 end
 for name in all(groups) do
  objs[name]={}
 end
end

function objects_call(grp, method)
 local tbl = grp and objs[grp]
 for obj in all(tbl) do
  if obj[method] then
   obj[method](obj)
  end
 end
end

function update_objects()
 local tbl = objs.to_update
 for obj in all(tbl) do
  obj:update()
 end
end

function draw_objects(start,finish)
 start,finish=start or 0,finish or 4
 for i=start,finish do
  local dobjs=objs["to_draw"..i]

  for obj in all(dobjs) do
   obj:draw()
  end
 end
end

function collide_objgroup(obj,groupname)
 for obj2 in group(groupname) do
  if obj2~=obj and collide_objobj(obj,obj2) then
   return obj2
  end
 end

 return false
end

function collide_objobj(obj1,obj2)
 return (abs(obj1.x-obj2.x)<(obj1.w+obj2.w)/2
     and abs(obj1.y-obj2.y)<(obj1.h+obj2.h)/2)
end

function register_object(o)
 for reg in all(split(o.regs)) do
  add(objs[reg],o)
 end
 return o
end

function deregister_object(o)
 for reg in all(split(o.regs)) do
  del(objs[reg],o)
 end
end

function group(name) return all(objs[name]) end
-->8
-- * utilities *

local _camera=camera
function camera(x,y)
 if not x then
  _camx,_camy=0,0
 else
  _camx,_camy=x,y
 end
 _camera(_camx,_camy)
end

function all_colors_to(c)
 if c then
  pal({c,c,c,c,c,c,c,c,c,c,c,c,c,c,c})
 else
  pal(split"1,2,3,4,5,6,7,8,9,10,11,12,13,14,15")
 end
-- for i=0,15 do
--  pal(i,c or i)
-- end
end

function angle_diff(a1,a2)
 return (a2-a1+0.5)%1-0.5
end

function merge_arrays(ard,ars)
 for k,v in pairs(ars) do
  ard[k]=v
 end
 return ard
end

function got(a) return rnd(a*2)-a end
function lerp(a,b,i) return (1-i)*a+i*b end
function dist(x,y) return sqrt(x*x+y*y) end
function sqr(a) return a*a end
function chance(a) return rnd(100)<a end
function ornd(str) return ord(str,rnd(#str)+1) end
function srnd(str) return rnd(split(str)) end
function irnd(n) return rnd(n)\1 end

-->8
-- * map stuff *

--sndflp,grsflp,
rpls,wavs={},{},{},{}

function gen_map()
 cls()
 camera(-32,-40)
 for i=0,29 do
  local w,h=3+rnd(8)\1,3+rnd(8)\1
  local x,y=2+rnd(60-w),2+rnd(44-h)
  
  ovalfill(x,y,x+w,y+h,1)
--  flip()
 end
 
 for i=0,1999 do
  local x,y = 2+rnd(60),2+rnd(44),3
  if pget(x,y)==1 then
   if pget(x-1,y)*pget(x+1,y)*pget(x,y-1)*pget(x,y+1)==0 then
    pset(x,y,0)
   end
  end
  
--  if i%500==0 then
--   flip()
--  end
 end
 
 for y=0,47 do
  for x=0,63 do
   local mx,my=x|((y&0x20)<<1),y&31
   if pget(x,y)==1 then
    mset(mx,my,pget(x-1,y)+(pget(x+1,y)<<1)+(pget(x,y-1)<<2)+(pget(x,y+1)<<3))
   else
    mset(mx,my,0)
   end
  end
 end
 
 local i=6
 while i>0 do
  local mx,my = irnd(63), irnd(47)
  
--  if mget(mx,my)&10>0 and mget(mx+1,my)&9>0 and mget(mx,my+1)&6>0 and mget(mx+1,my+1)&5>0 then
  local mmx, mmy = mx|((my&0x20)<<1),my&31
  if mget(mmx, mmy)==15 then
   local x,y = (mx+.5)*32,(my+.5)*32
   local d = 64 --> calculate min tile dist
   for m in group"moai" do
    d=min(d,dist((m.x-x)/8, (m.y-y)/8))
--    d=min(d,min(abs(m.x-x), abs(m.y-y)))
   end
   if d>12 then
    mset(mmx,mmy,16)
    new_moai(x,y)
    i-=1
   end
  end
 end
 
-- camera(0,-48)
-- for y=0,31 do
--  for x=0,127 do
--   pset(x,y,mget(x,y))
--  end
--  flip()
-- end
 
 sndflp={[0]=0x0102,0x0204,0x0408,0x0801}
 grsflp={[0]=0x8260,0x14c0,0x2890,0x4130}

 wavflp={[0]=0x5050,0xa0a0,0x5050,0xa0a0}
 wtrflp={[0]=0xefbf,0xdf7f,0xbfef,0x7fdf}
end

function get_map(mx,my)
 local mmx,mmy=mx\4,my\4
 if mmx<0 or mmx>63 or mmy<0 or mmy>47 then
  return 0
 end

 local n=mget(mmx|((mmy&0x20)<<1),mmy&31)&0xf
 if n==0 then return 0 end
 return sget((n<<2)|(mx&3),my&3)
end

mnmt=0
function draw_minimap(x,y)
 camera()
 fillp(~0x5050)
-- rectfill(0,0,127,127,0)
 circfill(x,y,112,0)
 fillp()

 x-=32
 y-=24
 
 rectfill(x-4,y-4,x+67,y+51,12)
 pal(1,0)
 
 spr(0x4e,x-12,y-12)
 spr(0x4f,x+68,y-12)
 spr(0x5e,x-12,y+52)
 spr(0x5f,x+68,y+52)
 
 for i=0,6 do
  local y=y-4+(i<<3)
  spr(0x4a|(i&1),x-12,y)
  spr(0x4c|(i&1),x+68,y)
 end
 
 for i=0,8 do
  local x=x-4+i*8
  spr(0x5a|(i&1),x,y-12)
  spr(0x5c|(i&1),x,y+52)
 end
 
 spr(0xcb,x+61,y-6)
 
 local flp={[0]=░,0,0,0,0,0,0,0,0,0,0,0,0,0,0,▒&0xffff}
 
 camera(-x,-y,true)
 local n=0
 for y=0,47 do
  for x=0,63 do
   local m=mget(x|((y&0x20)<<1),y&31)
   if m&0x80>0 then
    m&=0xf
    fillp(flp[m])
    color(m==0 and 0xcd or 0x45)
    pset(x,y)
    n+=1
    
    local s = mmoai[x|(y<<6)]
    if s then
     spr(s.explo and 0xca or 0xc8, x-3, y-7)
    end
   end
  end
 end
 
 pctg=n/3072*100
 local str=sub(tostr(pctg),1,4).."%"
 print(str,2,47,4)
 
 mnmt+=0.066
 spr(0xc9,player.x\32-3,player.y\32-7-(mnmt&1))
 
 fillp()
-- camera()
 pal(1,1)
 
 local x=-12
 local y=56
 for itm in all(player.items) do
  local s=0x70+itm
  all_colors_to(0)
  spr(s,x-1,y)
  spr(s,x+1,y)
  spr(s,x,y-1)
  spr(s,x,y+1)
  all_colors_to()
  spr(s,x,y)
  x+=6
 end
 
end

local mcst,mbf,mmx,mmy={[0]=0,[16]=8},{}
local function ite_tiles(w,h,mask,foo) -- ! only use even w and h
 local mx=mmx-(w>>1)+8
 local my=mmy-(h>>1)+8
 
 for cy=my,my+h do
 for cx=mx,mx+w do
 
   local n = cx|(cy>>16)
   local m=mbf[n]
   
   if not m then
    local ccy=cy>>2
    local ch=mget((cx>>2)|((ccy&0x20)<<1),ccy&31)&0x1f
    m=mcst[ch] or sget((ch<<2)|(cx&3),cy&3)
    mbf[n]=m
    
    if m>0 then
     lndn+=1
    end
   end
   
   if m&mask>0 then
    local x,y=cx<<3,cy<<3
    srand(n)
    foo(x,y,m)
   end

 end
 end
end

function draw_map(mx,my)
 mbf={}
 mmx,mmy = mx,my
 
 local flx=_camx&3
 local fly=_camy&3
 
 local function tfillp(tbl)
--  if not tbl then cls(4) flip() return end
  local n=(tbl[flx]<<>(fly<<2))|(tbl[flx]<<>((fly<<2)|16))&0xffff
  fillp(n)
  return n
 end

 local t=time()

 local sr=1-5*sin(((t>>4)+0.1)&0x.7fff)

-- fillp((wavflp[flx]<<>(fly<<2))|(wavflp[flx]<<>((fly<<2)|16))&0xffff)
 tfillp(wtrflp)
 color(0x21)
 local co=cos(t>>2)*8
 
 if mx<2 or mx>=63 then
  rectfill(_camx-1,_camy-1,co,_camy+128)
  rectfill(2048-co,_camy-1,_camx+128,_camy+128)
  
  if my<2 then
   rectfill(_camx-1,_camy-1,64,64)
   rectfill(1984,_camy-1,_camx+128,64)
   color(0x22)
   circfill(64,64,64-co)
   circfill(1984,64,64-co)
   color(0x21)
  end
  
  if my>=47 then
   rectfill(_camx-1,1472,64,_camy+128)
   rectfill(1984,1472,_camx+128,_camy+128)
   color(0x22)
   circfill(64,1472,64-co)
   circfill(1984,1472,64-co)
   color(0x21)
  end
 end
 
 if my<1 then
  rectfill(_camx-1,_camy-1,_camx+128,co)
 end
 if my>=48 then
  rectfill(_camx-1,1536-co,_camx+128,_camy+128)
 end
 
 tfillp(wavflp)
 color(0x32)
 ite_tiles(22,22,4,function(x,y)
  circfill(x|4,y|4,18+rnd(4)+sr)
 end)

 fillp()
 color(3)
 
 ite_tiles(20,20,4,function(x,y)
  circfill(x|4,y|4,14+rnd(4)+sr)
 end)
 
 srand(t)
 if chance(50) then
  local x=_camx-16+rnd(160)
  local y=_camy-16+rnd(160)
  add(wavs,{l=0,x=x-4,y=y,w=sgn(got(1)),f=chance(5)})
 end
 
 for w in all(wavs) do
  if w.f then
   spr(0x78+w.l,w.x\1+w.w*w.l,w.y,1,1,w.w<0)
   w.l+=.33
  else
   sspr((w.l\1)<<3,7,8,1,w.x,w.y)
   w.l+=.125
  end
  
  if w.l>=8 then del(wavs,w) end
 end
 
 local fw1=tfillp(wtrflp)|0b.1
 o,flx=flx,(flx+2)&3
 local fw2=tfillp(wtrflp)|0b.1
 flx=o

 for r in all(rpls) do
  local rr=min(r.l*.5+5,7)
  fillp(fw1)
  circ(r.x,r.y,rr,3)
  fillp(fw2)
  circ(r.x,r.y,rr,7)
  
  r.l+=0.125
  
  if r.l+4>14 then
   del(rpls,r)
  end
 end

 local sr=1-4*sin((t>>4)&0x.7fff)

 tfillp(sndflp)
 color(0xdc)
 ite_tiles(20,20,4,function(x,y)
  circfill(x|4,y|4,6+rnd(4)+sr)
 end)
 
 tfillp(grsflp)
-- fillp((grsflp[flx]<<>(fly<<2))|(grsflp[flx]<<>((fly<<2)|16))&0xffff)
 color(0xba)
 ite_tiles(18,18,3,function(x,y,m)
  if m==9 then
   circfill(x|4,y|4,6+rnd(4),0x9a)
  else
   circfill(x|4,y|4,6+rnd(4),0xba)
  end
 end)
 
 fillp()
 local camxa=_camx-40
 local camya=_camy-16
 local camxb=_camx+136
 local camyb=_camy+140
 
 pal(7,9)
 ite_tiles(18,18,3,function(x,y,m)
  if chance(15) then
   x+=rnd(4)
   y+=rnd(4)
   spr(0x40+rnd(4),x+2,y-2,1,1)
  elseif chance(15) then
   spr(0x61+rnd(15),x+rnd(2)+3,y+rnd(2)+3,1,1,chance(50))
  end
 end)

 pal(7,7)
 pal(8,8)
 pal(10,10)
 pal(11,11)
end

function draw_leaves(mx,my)
 local t=time()

 local wp=1+cos(t*0.25)
 local wc=wp*cos(winda)
 local ws=wp*0.5*sin(winda)
 pal{[8]=8,[10]=9,[11]=10}
 
 local wws={}
 for i=0,3 do
  wws[i]=.25+.75*cos((.5+(i>>2))*t)
 end
 
 pal(7,8)
 ite_tiles(18,18,3,function(x,y,m)
  if chance(15) then
   x+=rnd(4)
   y+=rnd(4)
   local pw=wws[rnd(4)\1]
   spr(0x44+((rnd(3)\1)<<1),x-2+pw*wc,y-10+pw*ws,2,2,rnd(2)<1)
  end
 end)
 
 pal{[7]=7,[8]=8,[10]=10,[11]=11}
end
-->8
-- * anims *
anims={
 run={s=0x20,n=16,spd=20},
 idle0={spd=2,"\16\16\16\21"},
 idle1={spd=5,"\16\16\17\18\19\18\17\18\19\20"},
 idle2={spd=12,"\16\16\48\49\50\50\50\51\51\52\53\54\55\48\48\16"},
 idle3={spd=12,"\16\16\56\57\57\58\58\58\59\59\60\60\59\59\59\61\61\59\59\59\60\59\61\59\60\60\59\59\59\59\62\63\48\49"}
}

function draw_oanim(name,x,y,flip,plt)
 local nfo=anims[name]
 local s
 local t=time()*nfo.spd
 
 local str=nfo[1]
 
 if str then
  local n=t%#str
  s=ord(str,n+1)
 else
  local n=t%nfo.n
  s=nfo.s+n
 end
 
 all_colors_to(0)
 spr(s,x-1,y,1,1,flip)
 spr(s,x+1,y,1,1,flip)
 spr(s,x,y-1,1,1,flip)
 spr(s,x,y+1,1,1,flip)
 all_colors_to()
 if plt then pal(plt) end
 spr(s,x,y,1,1,flip)
end

-->8
-- * item names *

items=split("cOCONUT,bIG fRUIT,rUM,bIG fLOWER,jEWELRY,bLUE cRYSTAL,gOLD tABLET,gOLDEN sKULL")

__gfx__
ccccccc0cccccccccaaca9acca9aa99accccccc00ccccccccaaca9acca9aa99a0077777700000077007777700077000000777770000dd000deeffeeddfeeeefd
caacaacccaaaaaaacaac99acca999999caacaaccccaaaaaacaac99acca9999990077777707700777007777770077000007777777000d50000eeffee00feeeef0
caccaaacccaaaaaacaccaaccccaaaaaacaac99acca999999caac99acca9999990077000707777770077000770777000007700077000d40000eeffee00feeeef0
ccc0cccc0cccccccccc0ccc00ccccccccaaca9acca9aa99acaaca9acca9aa99a0777770000777000077000770770000007700777000d40000eeffee00feeeef0
f23756779abccc640000000000000000000000000000000000000000000000000777700000077700077777770770000077700770000d50000eeffee00feeeef0
0123456789abcdef0000000000000000000000000000000000000000000000007770007007777770777777707770007077000770000540000eeffee00feeeef0
0f12f456089ab5f00000000000000000000000000000000000000000000000007777777077700770777000007777777077777770000550000eeffee00feeeef0
00003000000373000037773003773773377303733730003333000003300000007777777077000000770000007777777707777700000d5000deeffeeddfeeeefd
00022000000022000002200000220000002200000000000000000000000009900077777000077770077777700007777700000000000d40000dd5dddd55d55ddd
00236000000236000023600002360000023600000002200000070000009997990077777700777777077777770077777707700000000d50000444455544544445
00266000000266000026600002660000026600000023600000777000097777790770007700770000077000770077000707770000000d4000d5dd55d5dd55ddd0
00ee6e00006ee6e006ee6e600ee6e6000ee6e0000026600000777000997779900770007707777700077000770077700007720000000d50005445544554445450
060ee0600600ee06600ee00660ee006060ee060000ee6e0000222000777779000777777707777000077777770007770002210000000540000dddd555555dd5dd
060ee0600000ee06000ee00060ee000060ee0600060ee06000111000979990007777777077700000777777707000777001100000000000000554554444554455
000e0e00000e0e00000e0e0000e0e00000e0e000060e0e600000000099000000777077707777770077000770777777700000000000000000dd55ddddd555ddd0
00600600006006000060060000600600006006000060060000000000000000007700770077777000770007700777770000000000000000005444545445454450
00022000000220000002200000000000000000000000000000022000000220000002200000022000000220000000000000000000000000000002200000022000
00236000002360000023600000022000000220000002200000066000000666000023606000236000002360000002200000022000000220000023600000236000
00266006002660060026600000236000062360000063600000066000000666000026606000266006002660000023600006236000002360000026600000266600
06ee6e6006ee6e6066ee6e66602660000626600000666000000e6000000ee000006eee0006eeee6066eeee66602660000626600000266000000ee000006e6600
600ee000600ee000000ee00006ee6e0000ee6e0000ee6000000ee000000ee000006ee000600ee000000ee00006eeee0000eeee0000eee0000006e000006ee000
000eee6006eeee0006eee000000ee066000ee660000ee600000eee00000eee00000eee6006eeee0006eee000000ee066000ee660000e66000006ee00000eee60
06e000000000006000000e00006eee00000ee000000eee00000e060000e0006006e000000000006000000e00006eee00000ee000000eee00000e060000e00000
00000000000000000000006000000600000060000006000000600000060000000000000000000000000000600000060000006000000600000060000006000000
00000000000000000000000000222060002220000022200000000000000000000000000000000000000220000002200000002200002200000000000000000000
00022000000220000002200000266060002660060023600000222000000220000002200000022000002360000023600000023600023600000002200000022000
00236000002360000023600000ee6e0006ee6e600006600000236000002360000023600000236000002660000026600000026600026600000023600000236000
002660000026600000266060060ee000600ee00066ee6e660006600000266000002660000026600066ee6e6606ee6e60066ee6e00ee6e6600026600000266000
06ee6e6006ee6e6006ee6e60060ee000000ee000000ee00006ee6e6006ee6e6006ee6e6006ee6e60000ee000600ee0060000ee0660ee000006ee6e6006ee6e60
600ee006060ee060060ee00000e0e00000e00e00000ee000600ee006600ee006600ee006060ee06000eee00000eee000000eee066eee0000600ee006600ee006
000eee00000eee00000eee00006060000060060000e00e0000eeee0000eeee00000eee00000eee000600e0000600e00000600e000600e00000eeee00000eee00
006e0600006e0600006e06000000000000000000006006000060060000600600006e6000006e60000000600000006000000060000000600000606000006e6000
00004400000440000004400000440000000777000000000000000000077777000000000000000000001dcccc01ccccccccccccd1cccccd100001111000000111
00004400000440000004500000540000007aab7000007700077700007bbba7000000000000777000001ccccc01ccccccccccccc1ccccc1000001dcd100111dc1
0000540000044000000540000d40000007a7aab70077ba707aab7707baa770000077700077bb700001cccccc01dcccccccccccc1ccccc1000015cccc11dcccc1
0000055000055000000550000550000007777aab77baaaa777aaab7baa77700007bba707baa7000001cccccc001cccccccccccc1cccccd10115cccccccccccd1
00000d50000d5000000d50000d500000007bbaaabbaa87770078aabbababb7007b88aa7aa877700001cccccc001cccccccccccd1cccccd101dcccccccccccc10
00000550000d5000080550008d50000007aaaba8aa887000000788aa8aaaaa7077788abaababb70001dccccc001ccccccccccc10cccccc1001cccccccccccc10
00008dd800dd5080008d5500d55800007b88aaaaabba70000007abbaaa8877b70007bba8baaaab7001dccccc001dcccccccccc10cccccd1001cccccccccccd10
0008dd5508d5580008ddd580dd558000787778baaaaaa700007aaaaaaba70077007baaaaab778aa701cccccc0001cccccccccc10cccccc1001dcccccccccc100
0000bb000000bb0000000000bbb00000770007aa7788a700007a88778aaa7000007aa877aab777770111110000000000cccccccccccccccc01dccccccccccc10
00bbeeb0000beeb0bbbbbb00be6b000000007baa70778a7007a87700778a700007ba87007aa700001dcccd1111100111cccccccccccccccc01cccc5cccccccc1
0be66edb00be6edbb6666eb0bee6bb0000007ba700007a7007a700000077a70007ba700078a70000dcccccccdcd11dcccccccccccccccccc01cccc5dccccccc1
b66eebbb0beee6bbbeeeeedbbeee6eb000007a7000000770077000000000770007a7000007a70000cccccccccccccccccccccccccccccccc01ccccc5ccccccd1
beedb000bebee6b00beeebbb0beeeedb00007b700000000000000000000000000770000000770000cccccccccccccccccccccccccccccccc1dccccd5cccccc10
bbbb0000bb0be6b0bebdb0000beeebbb000077000000000000000000000000000000000000000000ccccccccccccccccccc11ccccccccccc1ccccc11cccccd10
000000000000bbb0bb0b0000bebdb000000000000000000000000000000000000000000000000000ccccccccccccccccccd1011dcccd111d1ccd1100ccd11110
000000000000000000000000bb0b0000000000000000000000000000000000000000000000000000cccccccccccccccc11110001111100011111000011100000
4829428400000000000000000000000000099900009990000000000000000000000000000000000000000000009090000000000000000000dcd0090000aaaa00
0084422800000000000000000000000000944490094449000000009000000000009990000000000000009900000900000000090000000dcdcec099000a9a9aa0
008942280000d000000d000000000000094545b094454b000900090000066600094549000000000000000990009000000090900009a00cecdcd0dcd0a9a9aaaa
48294284008d5000000d5000000ccd08945544b0944444b000909900806665000b4454900054000000000000000000000009900009909dcd0099cec0aaaa9a9a
77c447c700dd5080008dd08080ccdd80b444444bb454444b009988000865544000b444b008448000000000000000000000098000009990000009dcd0a9a9a9aa
4994494c08d5480008d5580008ddde800bb4454b0b44554b0008800008554448000bbb00000800000000000000009900000800000008800000088000aa9aaa9a
44444444000000000000000000808800000b44b000b444b00000000000888080000000000000000000990000000990000000000000000000000000000aa9a9a0
c49994940000000000000000000000000000bb00000bbb0000000000000000000000000000000000000000000000000000000000000000000000000000aaaa00
0044550000bbb0aa00555000006ccd60cd5555cd0000037000cccccc00cccc00000000000000000000000000000c000000000000000000000000000000000000
04450550000abb9a0077300006dddeeedd0550d57307323000cddddd0cccddc0000000000000000000006c0000d6ec000000c000000000000000000000000000
04455555076444b000307000cdcdeddd0cd00cd0330323300cdcdccdccddcccc000000000000000000c6ed0000006d00000d6000000000000000000000000000
44505055776ee4bb02ee7700ddeccddd0d5ddd50322322300cddeddedffccffc000000000000cd00000d0000000000000000e600000000000000000000000000
4445555476e76eaa03e77300dddced5500077000032312770dcdcdeecf5cdf5d0000000000006e0000000000000000000000dc000000c0000000000000000000
444444406e76ee0a0777e2000deedf500077660003231323cededde00cc55dd000000000030ce000000000000000000000000000000d60003000c00300000000
044444406e7eee00077ee3000eed559a0066ee0000211120ddcddee000dddd000000cd000000d0307000000000000000000000000070e607000d600000000000
004444000e6ee0000737330000ed5009000ee00000211200eeeeee0000cd0c000037777337733773330033303003030000000000000377730337773337303730
00000000bbbbbbbb00000000000000000000bbbb00000000000000000000bbbbb0000000000000000000bbbbb000000000aabaaa9aaa9aaa9aaa9aaa9aaaaa00
000000bb5dddddd5bb00000000000000000bddddbbb00000000000000bbbdddddb00000000000000bbbbdddd5b0000000aaaaa9aaa9aaa9aaa9aaa9aaabaaaa0
00000b5dddddddddd5b000000000000000bddddddddbb0000000000bbdddddddddb00000000000bbddddddddd5b00000aaaaa99aa99aa99aa99aa99aabbaaaaa
0000b5dddddddddd5d5b0000000000000bbddddddddddb00000000bddddddd5d55db000000000b5dddddddddd5b00000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
000b4dddddddddddd5db000000000000bdd5ddddddddddb000000bddddddd5d5d5ddb00000000bdddddddd5d5db00000baaabaaa9aaa9aaa9aaa9aaa9aaabaaa
000b4ddddddddd5d5d5bbb0000000000bdd5dd5555555db000000bd555555d5d55ddb00000000bddddd5d5dd555b0000aabaaa9aaa9aaa9aaa9aaa9aaa9aaaba
00b4dddd555555d5d5dbddb00000000bdd5dd544444455db0000bd55444455d545ddb00000000b55555d5d55dddb0000abbaa99aa99aa99aa99aa99aa99aabba
0b54dd55444444555d55dd5b0000000bdd5554444444455b0000b54444444455455db00000000b44444555d5dddb0000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
b5d5d5444444444445555ddb0000000bdd4544444444445b0000b544444444455555b000000000b444444455dddb00009aaaaaaaa9a99a9aaaaaaaaaaaaa9aaa
bdd554444445444444455ddb000000bdd4544444555444b00000b444444444445555b000000000b444444555d5db0000aa9aaaaaaaaaaaaaaaaaaaaaaaaaaa9a
b5d544444455544444445d5b000000bdd4544554555444b00000b444445544445555b00000000b4544455dd555db0000a99aaaaaaa9999999999999aa9a9a99a
b545444444d5d4444444554b000000bd5555555455d444b000000b44455544455555b00000000b554445dd5455db0000aaaaa999995dd5ddd5ddd599999aaaaa
b54544445dd5d5544444554b00000bd545555554d5d444b00000bb44d55d55554555b0000000b555444555545555b000aaa99955ddd5ddd5ddd5ddd55599aaaa
b54d45555d55d5555544554b00000bd54555555ddddd44b00000b44d55d555555555b000000bd5dd54555554555db000aa9955ddd55554555455545dd5559a9a
b4dd5555ddddd5555555454b00000bd55555555ddddd44b00000b4d55dd555554555b00000bddddd545555455555b000a995ddd4554f444f444f44545dd5599a
b4d55555dddd55544554444b00000b54555555dddddd44b00000bddddd5555554555b0000bdddddd545555455555b000995dd5544f444f444f444f4444ddd599
b4d5555dddddd454d554444b0000bd54555555ddddddd4b0000bdddddd5555554555b0000bdddddd545555455554b00095d5d54f444f444f444f444f4455dd59
b455555d5454d4555554444b0000bd5555555dddddddd4b0000bdddddd5555554555b00000b444dd445555455554b00095ddd4444f444f444f444f444f5dd559
b5455554444444555554444b0000b545d5555d544ddd55b000b55dd55d5555554444b000000b4444445555445544b00095d5dd5f444f444f444f444f55d5dd59
b5455555444445555544444b0000b545d55555d544d545b000b5455445d555555bbb00000000bb4445555d544445b000995dd5d55f444f444f444f45d5ddd599
b445555d54445555544444b000000b45d5555555555444b000b5445544d5555d5b0000000000b445d5555d5444554b00a9955dd5d554444f444f5555ddd5599a
0b4555ddd555d5555444bb00000000b5dd5555ddddd554b0000b44444445555d5b0000000000b55ddd55dd5555555b00aaa9555dd5dd54555455d5ddd555999a
00b554555ddddd55544b0000000000b5dd555d44444d4b00000b4444555555dd5b0000000000b4444455dd5455555b00aaaa99555dd5ddd5ddd5ddd555999aaa
00b5554445555545544b0000000000b5ddd5545555544b00000b45ddd55555dd5b00000000000b444455d554555d5b00aaaa9999555555ddd55555559999aaaa
0b555554444444555544b000000000b455dd555444454b00000b4ddddd555dd54b00000000000b44455d5545555d5b00baaaaa999999555555559999aa9a9aaa
0b5d5555444445555544b000000000bb445555554454b000000b54444555dd54b000000000000b445555445555dd5b00aabaaaa9999999999999999aaaaaaaba
0b5dddd55555555d5544b0000000bbd5544445555554b00000b5554455555545db00000000000b445544555555dd55b0abbaaaaaa9aa999aaaaa99aaaaaaabba
0b45ddddddddddd5555b000000bbddd5554444444444b00000b5555555554455ddb0000000000b44444455d5555dd5b0aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
00bb55dddddd55544bb000000b5dddd55554444444bb000000b455555444555dd55b0000000000bb444455d55555d5b0baaabaaa9aaa9aaa9aaa9aaa9aaaaaaa
000b4455555544444b000000b555dddd55555444444b0000000b44444445555d555b000000000000b44455d545555000aabaaabaaaaaaa9aaa9aaa9aaabaaaaa
0000044444444444000000000005555ddd555554444b000000b44444455555555000000000000000b4445dd5445500000abaabbaabbaa99aa99aa99aabbaaaa0
000000044444440000000000000000055555d5555400000000b4444555555500000000000000000000455dd54400000000aaaaaaaaaaaaaaaaaaaaaaaaaaaa00
6666666666666666666666666666666666666666222222626666222262626262000cc00000000000000cc0000050500000000000008888000000000000000000
666666666666666666666666666666660000000422222020222222220020202600caac00eee0eee000c99c004440400000000000088888800008880000110000
666666666666666666666622666666660000000022220000222222220202000200c99c00eee0ee0000c88c005004440000000000800088880888888001001000
62222266622222666662222222222226000000060220200002222222000020000c99ac00e0e0eee00c889c000005450000000000000008888888000801111110
22222226222222266222226622222222000000660220000602222222000000060caaac00000000000c999c0000050500000000000000088888c0000001111111
666666622666662626666666622222220000006602000006022222200000000600ccc00000eee00000ccc00005500055000800888ccccccccd11000411119111
6666666666666666666666666666666600000006020200060022220000000006000a0000000e00000009000000050500008088ccccccccccdcccdcc011991111
6666666666666666666666666666666600000000002000000000000000000000000000000000000000000000000050000008ccccccccccddffdddddcdd991111
000000066600000066666666888800000044400000444000004400000000000006666666066666660666666606666666040ccccccccdddffddfddddddddd9910
0000006666660000666666668888888804666400046664000466400000444000066666ee06666666066666110666666e00cccccccddfffffffffddddffddd980
00000666666660006666666688888888066464000664640004666400066664006eeeeeee06666666066661116eeeeeee00ccccccffffffffffffffffddfddc80
0000066666666000644446468888888806646600066664000664640006646640eeeee77e0666666461111111eeeeeee784cccccffefefefefefeffffffffdc8c
0000666666666600666666668888888806666400066640000664640006664640007707ee0666667611111111777dcd7e0cccccefefefefefefefafeffffffcd8
000066666666660066666666888888880666400000000000066664000666664007707eee00770046111111167d77ddee0cccccfefefef6fefefefefeffffffe8
0006666666666600666666660888888006600000000000000646640006664400eeeeeee60007766611111166eeeeeee60cccceef2767264eeeefefefffffffca
0006666666666600666666660088880000000000000000000004400000000000eeeeee660666666601116666eeeeee660cc8c6722222204eee76fa7effffffca
666666666666666666666666666666660000666600006666000066660066666666666666666677666666666666446666008c02262000000886676f67efffffeb
66666666666666666666666666666666000666660006666600006666006666666677776666678766666666666477466600880222000000882a6072f6fffffff8
666666666666644666666666666666640066666606666666000666660666666667887776667887466644446667887666088002220000008202250727effffff0
66666666666664466664664666464464006666666666666600066666066666666788877666777466677887766788766608800222000000820220527affffffb0
66666666664666666466446644644644066664666666664600066666066666666788877666444666647777666477666600880222000000082224062faffffb30
6666666666666666664464664644644606666646666446640006666606666646647777466666666666444666664466660088022020000000022002aa5bbbbb30
6666666666666666446466664446666606644646064444640006664606644646644444466666666666666666666666660080022020000000020002a70bbbbb30
6666666666666666666666666666666600004466000044460000446600004466664444666666666666666666666666660800022020000000020082a21bb3bbb0
000666660006666600066666000666666eeeeee606666666611111166eeeeee666666666666677666666666666446666000000220000000000200822bbb3bb90
00666666000666660000666600666666eeeeeeee0077007411111111eeeeeeee66777766666877666666666664774666000000220000000000200022bb333b98
066666660006666600006666006666660077077e0000000011111111777d777e67788876668877466644446667887666000000200000000000200002bb333399
0666666600066666000006660666666600000000000000000770000000770077677888766677746667777776644446660000002000000000000000023bb33891
064466660006666600000006066666660000000000000000000000017700cd006777887666444666647887666666666600000200000000000000000333b32811
006466600004666000000000046666000770770e00000000111111117d77dd7e647777466666666666444666666666660000020000000000000000231b212801
00066600000000000000000000000000eeeeeeee0007700411111111eeeeeeee6444444666666666666666666666666600000020000000000000012103003081
00000000000000000000000000000000eeeeeee60666666601111116eeeeeee66644446666666666666666666666666600000000000000000000021003000010
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000fffff000ff000000fffff0000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000ff00ffffff00ff00000fffffff000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000ff00fff0ff000ff0fff00000ff000ff00fffff00000000000000000000000000000000000000000000000000000
000000000000000000000000000000ffffff0ffffff00ff000ff0ff000000ff00fff00ffffff000ffff00ffffff0000fffff0000000000000000000000000000
000000000000000000000000000000ffffff00fff0000fffffff0ff00000fff00ff00ff000ff00ffffff0fffffff00ffffff0000000000000000000000000000
000000000000000000000000000000ff000f000fff00fffffff0fff000f0ff000ff00ff000ff00ff00000ff000ff00ff000f0000000000000000000000000000
00000000000000000000000000000fffff000ffffff0fff00000fffffff0fffffff00fffffff0fffff000ff000ff00fff0000000000000000000000000000000
00000000000000000000000000000ffff000fff00ff0ff000000fffffff00fffff00fffffff00ffff0000fffffff000fff000000000000000000000000000000
0000000000000000000000000000fff000f0ff000000000000000000000000000000fff0fff0fff00000fffffff0f000fff00000000000000000000000000000
0000000000000000000000000000fffffff000000000000000000000000000000000ff00ff00ffffff00ff000ff0fffffff00000000000000000000000000000
0000000000000000000000000000fffffff00000000000000000000000000000000000000000fffff000ff000ff00fffff000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000fff000000000000000000f0000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000ff00f0f00000f0f0fff0fff0f0f000fffff000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000ff00fff00000ff00ff00fff0fff000fff00000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000f0f000f00000f0f0f000f0f000f0fffff00000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000fff0ff000000f0f00ff0f0f0ff000f00000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
jjj33bb333bbj9nnn9nnn9nnncccccccsssssssssssssssssssssssssssssssscccccccnn9nnn9nnn9nnn9nnn9nnn9nnn9nnn9nnn9nnn9nnn9nnnccccccccsss
nnjjj33j3b333jnnnnnnnnnnncccccccscscssssssssssssssssssssssssscsccccccccnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnncccccccccsc
bbj3bb33333jjbjn9nnn9nnn9cccccccsssssssssssssssssssssssssssssssscccccccn9nnn9nnn9nnn9nnn9nnn9nnnbbbbbnnn9nnn9nnn9nnn9ccccccccsss
bj333333bjjjjjjnnnnnnnnnncccccccscscssssssssssssssssssssssscscsccccccccnnnnnnnnnnnnnnnnnnnnnnnqbbbqbbbqnnnnnnnnnnnnnncccccccccsc
qj3jjjj33jnnnjjnn9nnn9nnncccccccsssssssssssssssssssssssssssssssccccccccnn9nnn9nnn9nnn9nnqbbbqbbbqbbbqbbbq9nnn9nnn9nnnccccccccsss
j3jjjbj33bjnnnnnnnnnnnnnncccccccscscssssssssssssssssssssssscscscccccccnnnnnnnnnnnnnnnnbqqbbqqbbqqbbqqbbqqbnnnnnnnnnnncccccccccsc
j3jbbbkj3bjn9nnn9nnn9nnn9cccccccssssssssssssssssssssssssssssssscccccccnn9nnn9nnn9nnn9bbbbbbbbbbbbbbbbbbbbbnn9nnn9nnn9ccccccccsss
jjqbbbkkj3jnnnnnnnnnnnnnccccccccscscssssssssssssssssssssssscscccccccccnnnnnnnnnnnnnnbbqbbbqbbbqbbbqbbbqbbbqnnnnnnnnnccccccccccsc
qbbbqb44jbjnn9nnn9nnn9nncccccccsssssssssssssssssssssssssssssssccccccc9nnn9nnn9nnn9nnqbbbqbbbqbbbqbbbqbbbqbbnn9nnn9nnnfcccccccsss
qbbqqb94qjjqnnnnnnnnnnnnccccccccscssssssssssssssssssssssssscsccccccccnnnnnnnnnnnnnnqqbbqqbbqqbbqqbbqqbbqqbbqnnnnnnnnncccccccccsc
bbbbbb94bbbb9nnn9nnn9nnccccccccssssssssssssssssssssssssssssssscccccccnnn9nnn9nnn9nnbbbbbbbbbbbbbbbbbbbbbbbbb9nnn9nnn9nccccccccss
bbqbb994bjqbnnnnnnnnnnccccccccscscscscssssscscscscscscscscsfsccfcccccnnnnnnnnnnnnnnbbbqbbbqbbbqbbbqbbbqbbbqbnnnnnnnnnnccccccccsc
qbbbj944jbbbn9nnn9nnn9nccccccccsssssssssssssssssssssssssssssssccccccc9nnn9nnn9nnn9nbqbbbqbbbqbbbqbbbqbbbqbbbn9nnn9nnn9nccccccccs
qbbqqbbqqbbqnnnnnnnnnnnnccccccccscscscscscscscscscscscscsfscsfc9988ii9nnnnnnnnnnnnnqqbbqqbbqqbbqqbbqqbbqqbbqnnnnnnnnnnnncccccccc
bbbbbbbbbbbn9nnn9nnn9nnncccccccssssssssssssssscccccccccssss99i88888ii4nn9nnn9nnn9nnnbbbbbbbbbbbbbbbbbbbbbbbn9nnn9nnn9nnncccccccc
bbqbbbqbbbqnnnnnnnnnnnnnccccccccccccccccscsccccccccccccfcc944i88888i44nnnnnnnnnnnnnnbbqbbbqbbbqbbbqbbbqbbbqnnnnnnnnnnnnncccccccc
qbbbqbbbqbnnn9nnn9nnn9nnnccccccccccccccccccccccccccccccccc44i888888iiinnn9nnn9nnn9nnnbbbqbbbqbbbqbbbqbbbqbnnn9nnn9nnn9nnnccccccc
qbbqqbbqqbbnnnnnnnnnnnnnnccccccccccccccccccccccccccccccccfcci8888888iinnnnnnnnnnnnnnqbbqqbbqqbbqqbbqqbbqqbnnnnnnnnnnnnnnnccccccc
bbbbbbbbbbbn9nnn9nnn9nnn9ccccccccccccccccccccccccccccccccccci0088888iinn9nnn9nnn9nnnbbbbbbbbbbbbbbbbbbbbbnnn9nnn9nnn9nnn9ccccccc
bb3bbbqbbbqnnnnnnnnnnnnnnccccccccccccccccccccccccccccccfcccf0ss08888iinnnnnnnnnnnnnnbbqbbbqbbbqbbbqbbbqbbnnnnnnnnnnnnnnnnccccccc
qbb3qbb3qbbnn9nnn9nnn9nnncccccccccccccccccccccccccccccccccc0scu08888iinnn9nnn9nnn9nnqbbbqbbbqbbbqbbbqbbbq9nnn9nnn9nnn9nnnccccccc
qbb33b3qqbbnnnnnnnnnnnnnncccccccccccccccccccccccccccccccc990suu00888ii99nnnnnnnnnnnnqbbqqbbqqbbqqbbqqbbqqbnnnnnnnnnnnnnnnnnnnncc
jjjjj33bbjjjjjnn9nnn9nnn9nnn9ncn9nnn9ncccccccccn9nnn9nccck0u88u8u0888ik49nnn9nnn9nnn9bbbbbbbbbbbbbbbbbbbbbnn9nnn9nnn9nnn9nnn9nnn
bbbjjjqbjj3bbbjnnnnjjjnnnnnnnnnnnnnnnnnnncccnnnnnnnnnnnn90u008800u04999nnnnnnnnnnnnnbbqbbbqbbbqbbbqbbbqbbbqnnnnnnnnnnnnnnnnnnnnn
j33bjbjjb3jj33bjnjjb33jnn9nnn9nnn9nnn9nnn9cnn9nnn9nnn9nn4k04088040kk4k4nn9nnn9nnn9nnqbbbqbbbqbbbqbbbqbbbqbbnn9nnn9nnn9nnn9nnn9nn
jj33bjb333jjj33bjb333jjnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn999080804499499nnnnnnnnnnnqqbbqqbbqqbbqqbbqqbbqqbbqnnnnnnnnnnnnnnnnnnnn
b3b3bb33jjbb3b3bb33jjnnn9nnn9nnn9nnn9nnn9nnn9nnn9nnn9nnn9440u00u0k44kk449nnn9nnn9nnbbbbbbbbbbbbbbbbbbbbbbbbb9nnn9nnn9nnn9nnn9nnn
333j33jjj33333j33jjjnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn994409909444999nnnnnnnnnnnnbbbqbbbqbbbqbbbqbbbqbbbqbbnnnnnnnnnnnnnnnnnnn
jj333bbjbjjjj333bb3jn9nnn9nnn9nnn9nnn9nnn9nnn9nnn9nnn9nn4kkk4k4kk4k4kk4nn9nnn9nnn9nbqbbb3bbb3bbb3bbb3bbbqbbbqbbnn9nnn9nnn9nnn9nn
j3b3333jjjbj3b333333jnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnqbbqqbb33bb33bb33bb33bbqqbbqqbbqnnnnnnnnnnnnnnnn
333jjjjj3jj333jjjjj3jnnn9nnn9nnn9nnn9nnnjjjjjnnn9nnn9nnn9nnn9nnn9nnn9nnn9nnn9nnbbbbbbjjjjjbbbbbbbbbbbbbbbbbbbbbbbnnn9nnn9nnn9nnn
3jjj4kjjj3j3jjj4jjjj3jnnnnnnnnnnnnnnnnnnj3bbbjnnnnjjjnnnnnnnnnnnnnnnnnnnnnnnnjjjbbqbjbbb3j3bbb3bbb3bbbqbbbqbbbqbbbnnnnnnnnnnnnnn
jj4qkk44jj3jjb4j33bj3jnnnjjnn9nnn9nnn9nnnjj33bjnjjb33jnnn9nnn9nnn9nnn9nnn9nnj33bjjbjb33jjbbb3bbb3bbbqbbbqbbbqbbbqbnnn9nnn9nnn9nn
394qqkkkqjjqqbj3j33bjjnjjjjjnnnnnnnnnnnnnjjj33bjb333jjnnnnnnnnnnnnnnnnnnnnnnjj333bjb33jjjbb33bb33bbqqbbqqbbqqbbqqbbnnnnjjjnnnnnn
j94bbqqqbbbbbbjjjj33bjjj3bbbjnnn9jjj9nnnjbb3b3bb33jjbnnn9nnn9nnnbbbbbnnn9nnnbbjj33bb3b3bbjbbbbbbbbbbbbbbbbbbbbbbbbbn9nnjbbjj9nnj
944jbbqbbb3bjb4jbb333bb3jj33bjnjjb33jnqj33333j33jjjbbbqnnnnnnnqbbbqbbbqnnnnnbbqjjj33j33333jbbb3bbbqbbbqbbbqbbbqbbbqnnnnnj33bjnj3
9944jbbb3bbbqjj333b3j33jjjj33bjb333jjbjbjjjj333bb3jbqbbbqbbbqbbbqbbbqbbbqbbbqbbj3bb333jjjjbj3bbb3bbbqbbb3bbb3bbbqbbbq9njjjj33j33
3bb33bb33bbqjjbjj33333bjbb3b3bb33jjqqbjjqbj3b333333jqbbqqbbqqbbqqbbqqbbqqbbqqbj333333b3j3bjj3bb33bb33bb33bb33bbqqbbqqbjbb3b33b3j
bbbbbbbbbbbbbjjjjjjb33j33333j33jjjbbbbbbbj333jjjjj3jbbbbbbbbbbbbbbbbbjjjjjbbbbj3jjjjj333jbbbbbbbbbbbbbbbbbbbbbbbbbbbbjb3333bj3bb
bb3bbb3bbbqbbjjbbbj33jbjjjj333bb3jqbbbqbbj3jjjqbjjj3jbqbbbqbbjjjbbqbjbbb3jqbbj3jjj3bjjj3jb3bbb3bbb3bbb3bbb3bbbqbbbqbj33jjjb33333
3bbb3bbb3bbbqbbbqjb33jjjjj3b333333jbqbbbj3jj4bbbqbj3jbbbqbbbj33bjjbjb33jjbbbqj3j3bbbkkjj3jbb3bbb3bbb3bbb3bbbqbbbqbbbjjjjjb33jjj3
3bb33bb33bbqqbbqqjb3jjjjjj33jjjjj3jqqbbqjjb94bbqqbbjjbbqqbbqjj333bjb33jjjbbq3jj33bb344b3jjb33bb33bb33bb33bbqqbbqqbbqqbbqj33jkkjj
bbbbbbbbbbbbbjjjbj3jjbbb3jjjjbbjjj3jbbbbbbj94bbbbbbbbbbbbbbbbbjj33bb3b3bbjbbbbbbbbbb94bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbj3jj4kbj
bb3bbb3bbb3bj33bjjbjb33jjjj4bb3bbj3jbbqbbb944jqbbb3bbbqbbbqbbbqjjj33j33333jbbb3bbb3b943bbb3bbb3bbb3bbb3bbb3bbbqbbbqbbbqbj3jbb44b
3bbb3bbb3bbbjj333bjb33jjjb943bbb3bjjqbbb3b9944jb3bbb3bbbqbbbqbbj3bb333jjjjbj3bbb3bb994bj3bbb3bbb3bbb3bbb3bbb3bbbqbbbqbbbjjbbq94b
3bb33bb33bb39bjj33bb3b3bbj943bb33bb33bb33bb33bb33bb33bb33bb33bj333333b3j3bjjuuu33bj944j33bb33bb33bb33bb33bb33bbq3bb33bb33bbqq44q
bbbbbbbbbbbj49bjjj33j33333j4jbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbj3jjjjj333jjbuuu4bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbj99j
bb3bbb3bbb3449jj3bb333jjjjbj4j3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbj3jjj3bjjjjjbju44kkbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbbjjjb3bjjjj9944
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000fffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000ff000ff00000fff00ff000000ff00ff0ff00fff0fff0ff00fff000000ff0ff000ff0fff00ff0fff00ff00000000000000000000000
0000000000000000000000ff0f0ff000000f00f0f00000f000f0f0f0f0ff000f00f0f0fff00000f0f0f0f0f0f0fff0f0f00f00f0000000000000000000000000
0000000000000000000000ff000ff000000f00f0f00000f000f0f0f0f0f0000f00ff00f0f00000fff0ff00f0f0f0f0fff00f0000f00000000000000000000000
00000000000000000000000fffff0000000f00ff0000000ff0ff00f0f0f000fff0f0f0f0f00000f000f0f0ff00f0f0f0000f00ff000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000fffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000ff0f0ff00000fff00ff00000f0f0fff0fff0f0f00000fff00ff00ff0000000000000000000000000000000000000
000000000000000000000000000000000000fff0fff000000f00f0f00000f0f00f00ff00f0f00000fff0f0f0f0f0000000000000000000000000000000000000
000000000000000000000000000000000000ff0f0ff000000f00f0f00000fff00f00f000fff00000f0f0fff0fff0000000000000000000000000000000000000
0000000000000000000000000000000000000fffff0000000f00ff0000000f00fff00ff0fff00000f0f0f0f0f000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000ff00fff0000000000000000000000fffff000ff000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000f000f0f0ff00fff00ff00ff00000ff000ff000f000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000f000fff0f0f0ff00f000f0000000ff0f0ff000f000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000f000f000ff00f00000f000f00000ff000ff000f000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000ff00f000f0f00ff0ff00ff0000000fffff000ff000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e0f
__sfx__
010f00002161121611216112161121611216112161121611216112161121611216112161121611216112161121611216112161121611216112161121611216112161121611216112161121611216112161121611
011000001082110821108211082110831108311083110831108211082110821108211083110831108311083110821108211082110821108111081110811108111082110821108211082110831108311083110831
011000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010500001807418075000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010500001817418175000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010500001857418575000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010500001877418775000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01160000078140e81112811198111a8211a82125831288311e8312083120831208211982118821178211582113811118110f8110c8110c8110881005810058100481003810038100281001815008000080000800
011400000a8140c8110f81112811148211582117831198311c83120831248412e8412982127821208211c82119811158111381112811108110d81108811058110081203812038120281201815008000080000800
0112000003814048110481105811058210582106831098310c83110831148411084116841098410e831078210a811088110781105811058110481103811028110181001810018100281001815008000080000800
01140000058140581105811058110582105821058310683107831088310a8310a8310a8210a8210a8210982107811068110481103811028110181101811018150080000800008000000000000000000000000000
010a00000cc501010510105101050f105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105001050000000000
011000000c3351e05414546205362c52614516205152c50314506205062c50314506205062c503145062050624000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000c34514546205362052620515000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400000c61500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010300000083300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011400003501439011390151a5061a5001a5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00003361420611386112c61630831308213081500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c0000183231e05512155128001a800183001e000121001c8001d8001d8001e8001e8001e8001e8001d8001c8001c8001b8001a8001780015800128000d8000c8050c800008000080000000000000000000000
010a0000121551e0551832307800128001a8001a8001a8001a8001a8001a8001d8001c8001c8001b8001a8001780015800128000d8000c8050c80000800008000000000000000000000000000000000000000000
010c00001c324191650d7352973524000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c0000297440d765191451c32500000000000000000000000000000000000000001c300191000d7002970000000000000000000000000000000000000000000000000000000000000000000000000000000000
010d0000196342a2252c615146341a635000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010d00001a6341e225146152c62119635000000000000000196002a2001a600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c0000196442a2252c625146341a64500000006001461400616116010d8140461604821166041181502821006060e614008150f816246140060124616006041a8141c6151d6061d61613811148240d6060f614
010c000004143101510e1510214102131021250000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400002f7172d5272b7372954728757265572475723557217571f5571d7571c5571a7571855717757155571375711557107570e5570c7570b55709757075570574704537027270051700700000000000000000
010d00000c3530705500000130251f0412b0511f055000000c7110e731107511175113751150550000000000187111a7311c7511d7511f0512105500000300143203634056350563005632036340150000027155
011000002401426036280562905624056260262803629015000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00000c0540e05010050110501305015040170400c0400e03010030110201302015020170200c0100e01010014110141301415014170150000000000000000000000000000000000000000000000000000000
010800000015402155041550515507155091550b1550c1550e1551015511155131551515517155181551a1551c1551d1551f1552115523155241552615528155291552b1552d1552f34530035320250000026053
010800002605126051320412604126031320312602126021320112601126011320112601126011320112601126011320142601426015000000000000000000000000000000000000000000000000000000000000
011400000051400521005310054100354013630e1440e0410c1410b04109141070410514104041021310002100111000150011500015001150001500000000000000000000000000000000000000000000000000
__music__
00 1f424344
04 20424344

