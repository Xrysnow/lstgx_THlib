sakuya_player=Class(player_class)

function sakuya_player:init(slot)
	LoadTexture('sakuya_player','THlib\\player\\sakuya\\sakuya.png')
	LoadTexture('sakuya_player2p','THlib\\player\\sakuya\\sakuya_2p.png')
	LoadImageGroup('sakuya_player','sakuya_player',0,0,32,48,8,3,1,1)
	LoadImageGroup('sakuya_player2p','sakuya_player2p',0,0,32,48,8,3,1,1)
	LoadImageGroup('sakuya_support','sakuya_player',128,144,16,16,8,2)
	LoadImage('sakuya_knife_red','sakuya_player',0,144,32,16,16,16)
	LoadAnimation('sakuya_knife_red_ef','sakuya_player',32,144,32,16,3,1,4)
	LoadImage('sakuya_knife_blue','sakuya_player',0,160,32,16,16,16)
	LoadAnimation('sakuya_knife_blue_ef','sakuya_player',32,160,32,16,3,1,4)
	LoadImage('sakuya_knife_green','sakuya_player',0,176,32,16,16,16)
	LoadAnimation('sakuya_knife_green_ef','sakuya_player',32,176,32,16,3,1,4)
	LoadImageFromFile('sakuya_white','THlib\\player\\sakuya\\sakuya_white.png')
	
	LoadImage('sakuya_bigknife_red','sakuya_player',0,192,64,16,16,16)
	LoadImage('sakuya_bigknife_green','sakuya_player',128,192,64,16,16,16)
	LoadAnimation('sakuya_bigknife_red_ef','sakuya_player',0,144,32,16,4,1,4)
	LoadAnimation('sakuya_bigknife_green_ef','sakuya_player',0,176,32,16,4,1,4)
	
	LoadPS('sakuya_blood','THlib\\player\\sakuya\\sakuya_blood.psi','parimg1')
	
	SetImageState('sakuya_white','mul+sub',Color(0xFFFFFFFF))
	SetImageState('sakuya_knife_red','',Color(0xA0FFFFFF))
	SetImageState('sakuya_knife_blue','',Color(0xA0FFFFFF))
	SetImageState('sakuya_knife_green','',Color(0xA0FFFFFF))
	
	SetImageState('sakuya_bigknife_red','',Color(0xA0FFFFFF))
	
	LoadSound('sakuya_tick','THlib\\player\\sakuya\\sakuya_tick.wav')
	
	player_class.init(self)
	
	self.grazer.nopause=true
	
	self.name='Sakuya'
	self.nopause=true
	self.hspeed=4.5
	self.lspeed=2
	self.range=15
	self.dmgbonus=1
	self.A=1 self.B=1
	self.imgs={}
	if slot and slot==2 and jstg.players[1].name==self.name then
		for i=1,24 do self.imgs[i]='sakuya_player2p'..i end
	else
		for i=1,24 do self.imgs[i]='sakuya_player'..i end
	end
	self.slist=
	{
		{              nil,            nil,               nil,             nil},
		{{  0,-32,  0,-32},            nil,               nil,             nil},
		{{-30,-10,-15,-20},{30,-10,15,-20},               nil,             nil},
		{{-30,-10,-15,-20},{30,-10,15,-20},{  0,-32,   0,-32},             nil},
		{{-30,-10,-15,-20},{30,-10,15,-20},{-15,-32,-7.5,-32},{15,-32,7.5,-32}},
		{{-30,-10,-15,-20},{30,-10,15,-20},{-15,-32,-7.5,-32},{15,-32,7.5,-32}},
	}
end

function sakuya_player:frame()
	player_class.frame(self)
	if self.nextspell>0 and (((not IsValid(self.target)) or (not self.target.colli))) then player_class.findtarget(self) end
	if self.slow==1 then self.range=math.max(0.5,self.range-1.5)
	else self.range=math.min(15,self.range+1.5) end
	self.dmgbonus=self.range*0.2+0.9
	if self.protect>0 and GetCurrentSuperPause()>0 then
		CollisionCheck(GROUP_PLAYER,GROUP_ENEMY_BULLET)
		CollisionCheck(GROUP_PLAYER,GROUP_INDES)
	end
end

function sakuya_player:shoot()
	PlaySound('plst00',0.3,self.x/1024)
	self.nextshoot=4
	New(sakuya_knife,'sakuya_bigknife_red',self.x+6,self.y,24,90,2)
	New(sakuya_knife,'sakuya_bigknife_red',self.x-6,self.y,24,90,2)
	if self.timer%8<4 then
		for i=1,4 do if self.sp[i] and self.sp[i][3]>0.5 then
			for j=-4,4 do New(sakuya_knife,'sakuya_knife_blue',self.supportx+self.sp[i][1],self.supporty+self.sp[i][2],24,90+j*self.range,0.15*self.dmgbonus) end
		end end
	end
end
--[[
function sakuya_player:spell()
	PlaySound('gun00',1.0)
	misc.ShakeScreen(240,5)
	New(sakuya_spell,self.x,self.y)
	self.nextspell=240
	self.protect=360
end
--]]

function sakuya_player:spell()
	if self.slow==1 then
		self.nextspell=300
		self.protect=360
		--PauseMusic()
		local BGMName=''
		local _, bgm = EnumRes('bgm')
        for _,v in pairs(bgm) do
			if GetMusicState(v) == 'playing' then
				PauseMusic(v)
				BGMName=v
				break
			end
        end
		New(sakuya_reverse,240,self,BGMName,300)
		PlaySound('sakuya_tick',1.0)
		AddSuperPause(240)

	else
		self.collect_line=self.collect_line-300
		New(tasker,function()
			task.Wait(90)
			self.collect_line=self.collect_line+300
		end)
		self.nextspell=300
		self.protect=360
		misc.ShakeScreen(240,5)
		New(player_spell_mask,0,200,0,30,240,30)
		
		PlaySound('nep00',0.8)
		local _sakuya=self
		New(tasker,function()
			for _t=1,120 do
				for _i=0,2 do
					New(sakuya_fake_bullet,_sakuya.x,_sakuya.y,80,90+_t*3+_i*120,30,_sakuya,0.5)
					New(sakuya_fake_bullet,_sakuya.x,_sakuya.y,80,90+-_t*3+_i*120,30,_sakuya,0.5)
				end
				task.Wait(2)
			end
			PlaySound('slash',0.8)
			New(bullet_killer,_sakuya.x,_sakuya.y)
		end)
	end
end

function sakuya_player:render()
	player_class.render(self)
	local t=int((self.timer/3)%16)+1
	for i=1,4 do
		if self.sp[i] and self.sp[i][3]>0.5 then
			Render('sakuya_support'..t,self.supportx+self.sp[i][1],self.supporty+self.sp[i][2])
		end
	end
end

sakuya_knife=Class(player_bullet_straight)

function sakuya_knife:kill()
	New(sakuya_knife_ef,self.x,self.y,self.rot,3,self.img..'_ef')
	New(sakuya_blood_ef,self.x,self.y,self.rot,4,12)
end

sakuya_knife_ef=Class(object)

function sakuya_knife_ef:init(x,y,rot,v,img)
	self.x=x
	self.y=y
	self.rot=rot
	self.vx=v*cos(rot)
	self.vy=v*sin(rot)
	self.img=img
	self.group=GROUP_GHOST
	self.layer=LAYER_PLAYER_BULLET+50
end

function sakuya_knife_ef:frame()
	if self.timer==12 then Del(self) end
end

function sakuya_knife_ef:render()
	SetAnimationState(self.img,'',Color(128-10*self.timer,255,255,255))
	object.render(self)
end

sakuya_blood_ef=Class(object)

function sakuya_blood_ef:init(x,y,a,t1,t2)
	self.x=x
	self.y=y
	self.rot=a
	self.group=GROUP_GHOST
	self.layer=LAYER_PLAYER_BULLET+60
	self.stoptime=t1
	self.deathtime=t2
	self.img='sakuya_blood'
end

function sakuya_blood_ef:frame()
	if self.timer==self.stoptime then
		ParticleStop(self)
	end
	if self.timer==self.deathtime then
		Del(self)
	end
end
--[[
sakuya_spell=Class(object)

function sakuya_spell:init(x,y)
	self.x=x
	self.y=y
	self.img='sakuya_bomb'
	self.omiga=-2
	self.group=GROUP_PLAYER
	self.layer=LAYER_PLAYER-1
	SetImageState(self.img,'',Color(0xFFFFFFFF))
end
--]]
sakuya_fake_bullet=Class(object)

function sakuya_fake_bullet:init(x,y,r,a,t,master,dmg)
	self.x=x
	self.y=y
	self.rot=a
	self.img='sakuya_knife_green'
	self.group=GROUP_GHOST
	self.layer=LAYER_PLAYER_BULLET
	
	local _x,_y=x+r*cos(a),y+r*sin(a)
	
	task.New(self,function()
		local _l,_r,_b,_t=_x<lstg.world.boundl,_x>lstg.world.boundr,_y<lstg.world.boundb,_y>lstg.world.boundt
		if _l or _r or _b or _t then
			local rx,ry=_x,_y
			if _l then
				local tx=lstg.world.boundl
				local ty=y-(x-tx)*(y-_y)/(x-_x)
				if Dist(x,y,tx,ty)<Dist(x,y,rx,ry) then rx,ry=tx,ty end
			elseif _r then
				local tx=lstg.world.boundr
				local ty=y-(x-tx)*(y-_y)/(x-_x)
				if Dist(x,y,tx,ty)<Dist(x,y,rx,ry) then rx,ry=tx,ty end
			end
			if _b then
				local ty=lstg.world.boundb
				local tx=x-(y-ty)*(x-_x)/(y-_y)
				if Dist(x,y,tx,ty)<Dist(x,y,rx,ry) then rx,ry=tx,ty end
			elseif _t then
				local ty=lstg.world.boundt
				local tx=x-(y-ty)*(x-_x)/(y-_y)
				if Dist(x,y,tx,ty)<Dist(x,y,rx,ry) then rx,ry=tx,ty end
			end
			task.MoveTo(rx,ry,t,MOVE_DECEL)
		else
			task.MoveTo(_x,_y,t,MOVE_DECEL)
		end
		if IsValid(master.target) then
			New(sakuya_knife,'sakuya_bigknife_green',self.x,self.y,18,Angle(self,master.target),dmg)
		else
			New(sakuya_knife,'sakuya_bigknife_green',self.x,self.y,18,a,dmg)
		end
		Del(self)
	end)
end

function sakuya_fake_bullet:frame()
	task.Do(self)
end

sakuya_reverse=Class(object)

function sakuya_reverse:init(DelTime,Master,BGM,dmg)
	self.x=0
	self.y=0
	self.rot=0
	self.group=GROUP_GHOST
	self.layer=LAYER_TOP
	self.img='sakuya_white'
	self.nopause=true
	self.deltime=DelTime
	self.master=Master
	self.bgmname=BGM
	self._dmg=dmg
end

function sakuya_reverse:frame()
	if self.timer==self.deltime then
		New(bullet_killer,self.master.x,self.master.y)
		PlaySound('slash',0.8)
		if self.bgmname~='' then ResumeMusic(self.bgmname) end
		New(sakuya_bombdamage,320,240,0,0,0,0,self._dmg,0)
		Del(self)
	end
end

sakuya_bombdamage=Class(player_bullet_hide)

function sakuya_bombdamage:init(a,b,x,y,v,angle,dmg,delay)
	player_bullet_hide.init(self,a,b,x,y,v,angle,dmg,delay)
	self.rect=true
	self.killflag=true
end

function sakuya_bombdamage:frame()
	player_bullet_hide.frame(self)
	if self.timer>=self.delay then Del(self) end
end