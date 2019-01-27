--

shababa_player = Class(player_class)

shababa_player._load = function()
    if CheckRes('tex','shababa_player') then
        return
    end
    LoadTexture('shababa_player', 'THlib\\player\\shababa\\shababa.png')
    LoadImageGroup('shababa_player', 'shababa_player', 0, 0, 32, 48, 8, 3, 0.5, 0.5)
    --support
    LoadImage('ran_support_1', 'shababa_player', 0, 168, 32, 24)
    LoadImage('ran_support_2', 'shababa_player', 32, 168, 32, 24)
    LoadImageGroup('junko_support', 'shababa_player', 0, 192, 32, 24, 4, 1)
    LoadImage('sei_support', 'shababa_player', 0, 240, 32, 24)
    --bullet_main
    LoadImage('shababa_bullet', 'shababa_player', 0, 144, 64, 24, 24, 16)
    SetImageState('shababa_bullet', '', Color(125, 255, 255, 255))
    LoadAnimation('shababa_bullet_ef', 'shababa_player', 0, 144, 64, 24, 3, 1, 8)
    --bullet_ran
    LoadImageGroup('ran_bullet', 'shababa_player', 64, 168, 32, 24, 4, 1, 16, 16)
    for i = 1, 4 do
        SetImageState('ran_bullet' .. i, '', Color(155, 255, 255, 255))
    end
    --bullet_junko
    LoadImage('junko_bullet', 'shababa_player', 192, 144, 48, 48, 0, 0)
    SetImageState('junko_bullet', 'mul+add')
    LoadImageGroup('junko_laser_head', 'shababa_player', 128, 192, 32, 24, 2, 1)
    SetImageCenter('junko_laser_head1', 0, 12)
    SetImageCenter('junko_laser_head2', 0, 12)
    SetImageState('junko_laser_head1', 'mul+add')
    SetImageState('junko_laser_head2', 'mul+add')
    --bullet_sei
    LoadImage('sei_bullet', 'shababa_player', 160, 240, 32, 24, 12, 12)
    SetImageState('sei_bullet', '', Color(0x80FFFFFF))
    LoadImage('sei_bullet_ef', 'shababa_player', 160, 240, 32, 24, 12, 12)
    --bomb
    LoadImageFromFile('FA_bomb', 'THlib\\player\\shababa\\FA_bomb.png')
    LoadImageFromFile('bomb1', 'THlib\\player\\shababa\\bomb1.png')
    --sound effect
    LoadSound("FAa", "THlib\\player\\shababa\\FAa.wav")
    LoadSound("FAQ", "THlib\\player\\shababa\\FAQ.wav")
end

function shababa_player:init()
    shababa_player._load()
    self.se = 0
    self.atkmode = 1
    self.atk_t = 0
    self.alist = {}
    self.alist[1] = {
        { 0, 0, 0, 0 },
        { 90, 0, 0, 0 },
        { 135, 45, 0, 0 },
        { 135, 45, -90, 0 },
        { 135, 45, -135, -45 },
        { 98, 86, 94, 82 },
    }
    self.alist[2] = {
        { 0, 0, 0, 0 },
        { 90, 0, 0, 0 },
        { 105, 75, 0, 0 },
        { 120, 60, 90, 0 },
        { 120, 60, 100, 80 },
        { 98, 86, 94, 82 },
    }
    self._slist = {}
    self._slist[1] = {
        { nil, nil, nil, nil },
        { { 0, 42, 0, 36 }, nil, nil, nil },
        { { -22, 32, -16, 24 }, { 22, 32, 16, 24 }, nil, nil },
        { { -32, 24, -24, 16 }, { 0, 42, 0, 36 }, { 32, 24, 24, 16 }, nil },
        { { -16, 42, -8, 36 }, { 16, 42, 8, 36 }, { 42, 16, 24, 12 }, { -42, 16, -24, 12 } },
        { { -16, 42, -8, 36 }, { 16, 42, 8, 36 }, { -42, 16, -24, 12 }, { 42, 16, 24, 12 } },
    }
    self._slist[2] = {
        { nil, nil, nil, nil },
        { { 0, 42, 0, 36 }, nil, nil, nil },
        { { -32, 0, 24, 0 }, { 32, 0, -24, 0 }, nil, nil },
        { { -32, 0, 24, 0 }, { 0, 42, 0, 36 }, { 32, 0, -24, 0 }, nil },
        { { -20, 32, 10, 32 }, { 20, 32, -10, 32 }, { -36, 8, 28, 0 }, { 36, 8, -28, 0 } },
        { { -20, 32, -16, 24 }, { 20, 32, 16, 24 }, { -36, 4, -20, 4 }, { 36, 4, 20, 4 } },
    }
    self._slist[3] = {
        { nil, nil, nil, nil },
        { { 0, 48, 0, 36 }, nil, nil, nil },
        { { -30, 30, -30, 30 }, { 30, 30, 30, 30 }, nil, nil },
        { { -36, 36, -24, 24 }, { 36, 36, 24, 24 }, { 0, -48, 0, 36 }, nil },
        { { -36, 36, -28, 28 }, { 36, 36, 28, 28 }, { -36, -36, -10, 36 }, { 36, -36, 10, 36 } },
        { { -22, 32, -18, 24 }, { 22, 18, 36, 24 }, { -42, 16, -36, 12 }, { 42, 16, 36, 12 } },
    }
    player_class.init(self)
    self.slowflag = true
    self.shootflag = true
    self.slowflagtime = 0
    self.shootflagtime = 0
    self.hspeed = 4.5
    self.lspeed = 2
    self.imgs = {}
    for i = 1, 24 do
        self.imgs[i] = 'shababa_player' .. i
    end
    self.slist = {}
    self.slist = self._slist[1]
    self.shootmode = {}
    self.A = 0.5
    self.B = 0.5
    self.shootmode[1] = function()
        self.nextshoot = 1
        local power = int(lstg.var.power / 100)
        if self.timer % 2 < 1 then
            PlaySound('plst00', 0.15, self.x / 200)
            New(shababa_main, 'shababa_bullet', self.x - 10, self.y, 32, 90, 0.9)
            New(shababa_main, 'shababa_bullet', self.x + 10, self.y, 32, 90, 0.9)
        end
        for i = 1, 4 do
            if self.sp[i] and self.sp[i][3] > 0.5 then
                New(shababa_ran_bullet, 'ran_bullet' .. ((10000000 - self.timer) % 4) + 1, self.supportx + self.sp[i][1], self.supporty + self.sp[i][2], 30, 90, 0.2)
            end
        end
    end

    self.shootmode[2] = function()
        self.nextshoot = 2
        self.atk_t = self.atk_t + 1
        local power = int(lstg.var.power / 100)
        local v = 8
        PlaySound('plst00', 0.15, self.x / 200)
        New(shababa_main, 'shababa_bullet', self.x - 10, self.y, 32, 90, 0.9)
        New(shababa_main, 'shababa_bullet', self.x + 10, self.y, 32, 90, 0.9)
        for i = 1, 4 do
            if self.sp[i] and self.sp[i][3] > 0.5 then
                if power == 1 then
                    if self.atk_t % 8 == 0 then
                        New(shababa_junko_bullet, self.supportx + self.sp[i][1], self.supporty + self.sp[i][2], v + self.slow * 4, 1)
                    end
                elseif power == 2 then
                    if self.atk_t % 8 == 0 then
                        New(shababa_junko_bullet, self.supportx + self.sp[i][1], self.supporty + self.sp[i][2], v + self.slow * 4, 1)
                    end
                elseif power == 3 then
                    if i == 2 and self.atk_t % 16 == 0 then
                        New(shababa_junko_bullet, self.supportx + self.sp[i][1], self.supporty + self.sp[i][2], v + self.slow * 4, 1)
                    end
                    if (i == 1 or i == 3) and self.atk_t % 16 == 8 then
                        New(shababa_junko_bullet, self.supportx + self.sp[i][1], self.supporty + self.sp[i][2], v + self.slow * 4, 1)
                    end
                elseif power == 4 then
                    if i <= 2 and self.atk_t % 16 == 0 then
                        New(shababa_junko_bullet, self.supportx + self.sp[i][1], self.supporty + self.sp[i][2], v + self.slow * 4, 1)
                    end
                    if i > 2 and self.atk_t % 16 == 8 then
                        New(shababa_junko_bullet, self.supportx + self.sp[i][1], self.supporty + self.sp[i][2], v + self.slow * 4, 1)
                    end
                end
            end
        end
    end

    self.shootmode[3] = function()
        self.nextshoot = 2
        self.atk_t = self.atk_t + 1
        local power = int(lstg.var.power / 100)
        PlaySound('plst00', 0.15, self.x / 200)
        New(shababa_main, 'shababa_bullet', self.x - 10, self.y, 32, 90, 0.9)
        New(shababa_main, 'shababa_bullet', self.x + 10, self.y, 32, 90, 0.9)
        if self.atk_t % 4 == 0 then
            for i = 1, 4 do
                if self.sp[i] and self.sp[i][3] > 0.5 then
                    if self.slow == 1 then
                        for j = -3, 3 do
                            New(shababa_sei_bullet, 'sei_bullet', self.supportx + self.sp[i][1], self.supporty + self.sp[i][2], 7, self.alist[2][power + 1][i] + j * 7, 0.7)
                        end
                    else
                        for j = -7, 7 do
                            New(shababa_sei_bullet, 'sei_bullet', self.supportx + self.sp[i][1], self.supporty + self.sp[i][2], 7, self.alist[1][power + 1][i] + j * 7, 0.85)--self.alist[power+1][i]
                        end
                    end
                end
            end
        end
    end
end

function shababa_player:shoot()
    self.shootmode[self.atkmode]()
end

function shababa_player:spell()
    PlaySound('slash', 1.0)
    PlaySound('ch00', 1.0)
    PlaySound('FAQ', 1.0)
    misc.ShakeScreen(330, 5)
    New(shababa_bomb, 0, 0)
    self.nextspell = 360
    self.protect = 420
end

function shababa_player:render()
    if self.atkmode == 1 then
        if int(self.support) == 4 then
            SetImageState('ran_support_2', '', Color(0x80FFFFFF))
            for i = 1, 4 do
                if self.sp[i] then
                    Render('ran_support_2', self.supportx + self.sp[i][1], self.supporty + self.sp[i][2], 15 * sin(2 * self.timer), self.sp[i][3] * 1.3, 1.3)
                end
            end
            SetImageState('ran_support_2', '', Color(0xFFFFFFFF))
        end
        for i = 1, 4 do
            if self.sp[i] then
                Render('ran_support_1', self.supportx + self.sp[i][1], self.supporty + self.sp[i][2], 15 * sin(2 * self.timer), self.sp[i][3], 1)
            end
        end
    end
    if self.atkmode == 2 then
        for i = 1, 4 do
            SetImageState('junko_support' .. i, '', Color(0xCCFFFFFF))
            if self.sp[i] then
                Render('junko_support' .. int(0.15 * (self.timer % 24)) + 1, self.supportx + self.sp[i][1], self.supporty + self.sp[i][2], 0, self.sp[i][3], 1)
            end
        end
        --[[		local scale=self.ani%60
                for i=1,4 do
                    SetImageState('junko_support'..i,'',Color(180-scale*3,255,255,255))
                    if self.sp[i] then
                        Render('junko_support'..int(0.2*(self.timer%15))+1,self.supportx+self.sp[i][1],self.supporty+self.sp[i][2],0,self.sp[i][3]*(scale/100+1))
                    end
                end]]
    end
    if self.atkmode == 3 then
        SetImageState('sei_support', '', Color(0xCCFFFFFF))
        for i = 1, 4 do
            if self.sp[i] then
                Render('sei_support', self.supportx + self.sp[i][1], self.supporty + self.sp[i][2], self.ani * 6, self.sp[i][3], 1)
            end
        end
    end
    player_class.render(self)
end

function shababa_player:frame()
    if self.nextspell == 0 then
        if not (KeyIsDown 'slow') then
            self.slowflag = true
            self.slowflagtime = 4
        end
        if not (KeyIsDown 'shoot') then
            self.shootflag = true
            self.shootflagtime = 4
        end
        if KeyIsDown 'slow' and KeyIsDown 'shoot' and (self.slowflag and self.shootflag) then
            self.atkmode = (self.atkmode + 3) % 3 + 1
            self.slowflagtime = 0
            self.shootflagtime = 0
            self.slist = self._slist[self.atkmode]
        end
        if KeyIsDown 'slow' and self.slowflagtime == 0 then
            self.slowflag = false
        end
        if KeyIsDown 'shoot' and self.shootflagtime == 0 then
            self.shootflag = false
        end
        if self.slowflagtime > 0 then
            self.slowflagtime = self.slowflagtime - 1
        end
        if self.shootflagtime > 0 then
            self.shootflagtime = self.shootflagtime - 1
        end
    end
    player_class.frame(self)
end
-----------------------bomb-------------------------------
shababa_bomb = Class(object)

function shababa_bomb:init(x, y)
    self.group = GROUP_PLAYER_BULLET
    self.layer = LAYER_ENEMY - 1
    self.img = 'FA_bomb'
    self.x = x
    self.y = y
    self.a = 32
    self.b = 32
    self.dmg = 1
    self.alpha = 255
    self.killflag = true
end

function shababa_bomb:frame()
    if self.timer < 180 then
        self.hscale = 0.1 * self.timer / 180
        self.vscale = self.hscale
    elseif self.timer < 210 then
        self.hscale = 0.1 + 1 * (self.timer - 180) / 30
        self.vscale = self.hscale
    end
    if self.timer > 330 then
        self.alpha = 255 - 255 * (self.timer - 330) / 30
    end
    if self.timer > 360 then
        Del(self)
    end
    if self.timer == 180 then
        PlaySound('FAa', 1.0)
        PlaySound('enep02', 1.0)
    end
    if self.timer == 180 then
        self.a = 256
        self.b = 256
        self.dmg = 2.5
        New(shababa_b_killer)
    end
end
function shababa_bomb:render()
    SetImageState(self.img, '', Color(self.alpha, 255, 255, 255))
    SetImageState('bomb1', '', Color(self.alpha, 255, 255, 255))
    if self.timer > 180 then
        Render('bomb1', self.x, self.y, self.timer * 3, min(1.5, (self.timer - 180) * 1.5 / 30))
    end
    DefaultRenderFunc(self)
    SetImageState(self.img, '', Color(255, 255, 255, 255))
end

shababa_b_killer = Class(object)

function shababa_b_killer:init()
    self.group = GROUP_PLAYER
    self.layer = LAYER_BG
    self.x, self.y = 0, 0
    self.a = 256
    self.b = 256
end

function shababa_b_killer:frame()
    if self.timer > 180 then
        Del(self)
    end
end

function shababa_b_killer:colli(other)
    if other.group == GROUP_ENEMY_BULLET then
        Kill(other)
    end
end
--------------------------------------------------------
--------------------main bullet-------------------------
shababa_main = Class(player_bullet_straight)

function shababa_main:kill()
    New(shababa_main_ef, self.x, self.y, self.rot)
end

shababa_main_ef = Class(object)

function shababa_main_ef:init(x, y, rot)
    self.x = x
    self.y = y
    self.rot = rot
    self.img = 'shababa_bullet_ef'
    self.layer = LAYER_PLAYER_BULLET + 50
    self.vx = 4 * cos(rot)
    self.vy = 4 * sin(rot)
end

function shababa_main_ef:frame()
    if self.timer >= 15 then
        Del(self)
    end
end

function shababa_main_ef:render()
    SetAnimationState(self.img, 'mul+add', Color(255 - 255 * self.timer / 15, 255, 255, 255))
    DefaultRenderFunc(self)
    SetAnimationState(self.img, '', Color(100, 255, 255, 255))
end
--------------------------------------------------------
----------------ran_bullet------------------------------
shababa_ran_bullet = Class(player_bullet_straight)

function shababa_ran_bullet:init(img, x, y, v, angle, dmg, i)
    player_bullet_straight.init(self, img, x, y, v, angle, dmg)
    self.angle = angle
    if i ~= 1 then
        self.mute = true
    end
end
function shababa_ran_bullet:kill()
    New(shababa_ran_bullet_ef, self.x, self.y, self.rot, self.img)
end

shababa_ran_bullet_ef = Class(object)

function shababa_ran_bullet_ef:init(x, y, rot, img)
    self.x = x
    self.y = y
    self.rot = rot
    self.img = img
    self.layer = LAYER_PLAYER_BULLET + 50
    self.vx = 1 * cos(rot)
    self.vy = 1 * sin(rot)
end

function shababa_ran_bullet_ef:frame()
    if self.timer >= 9 then
        Del(self)
    end
    self.hscale = 1 + 0.2 * self.timer / 9
    self.vscale = self.hscale
end

function shababa_ran_bullet_ef:render()
    SetImageState(self.img, 'mul+add', Color(155 - 155 * self.timer / 9, 255, 255, 255))
    DefaultRenderFunc(self)
    SetImageState(self.img, '', Color(155, 255, 255, 255))
end
---------------------------------------------------------
--------------------junko--------------------------------
shababa_junko_bullet = Class(object)

function shababa_junko_bullet:init(x, y, v, i)
    self.img = 'junko_bullet'
    self.x = x
    self.y = y
    self.flag = i
    self.group = GROUP_GHOST
    self.layer = LAYER_PLAYER_BULLET
    self.hscale = 0.75
    self.vscale = 0.75
    self.omiga = 6
    --	local yy=self.target.y or 144
    --	local angle=Angle(x,y,196*i,yy)
    self.vy = v
end

function shababa_junko_bullet:frame()
    for i, o in ObjList(GROUP_ENEMY) do
        if o.colli then
            if abs(o.y - self.y) <= 6 then
                New(shababa_junko_laser, self.x, self.y, 90 + 90 * self.flag)
                Del(self)
                break
            end
        end
    end
    --	if self.x>196 or self.x<-196 then
    --		New(shababa_junko_laser,self.x,self.y,90+90*self.flag)
    --		Del(self)
    --	end
end

shababa_junko_laser = Class(object)

function shababa_junko_laser:init(x, y, angle)
    self.x = x
    self.y = y
    self.rot = angle
    self.img = 'junko_laser_head1'
    self.a = 400
    self.b = 16
    self.rect = true
    self.bound = false
    self.hscale = 1.5
    self.vscale = 1.5
    self.group = GROUP_PLAYER_BULLET
    self.layer = LAYER_PLAYER_BULLET
    self.killflag = true
    self.fire = 0
    if IsValid(_boss) then
        self.dmg = 0.07
    else
        self.dmg = 0.035
    end
end

function shababa_junko_laser:frame()
    if self.timer % 8 == 0 then
        self.mute = false
    else
        self.mute = true
    end
    if self.timer < 10 then
        self.fire = self.fire + 0.1
    end
    if self.timer > 25 then
        self.fire = self.fire - 0.1
    end
    if self.timer == 35 then
        Del(self)
    end
    self.dmg = self.dmg + 0.002
end

function shababa_junko_laser:render()
    local offset = (self.timer * 12) % 256
    RenderJunkoLaser(self.x, self.y, offset, 36 * self.fire, Color(0x80FFFFFF), self.rot)
    RenderJunkoLaser(self.x, self.y, offset, 36 * self.fire, Color(0x80FFFFFF), self.rot + 180)
    Render('junko_laser_head' .. self.timer % 2 + 1, self.x - 2.5, self.y, 0, 1.5)
    Render('junko_laser_head' .. self.timer % 2 + 1, self.x + 2.5, self.y, 180, 1.5)
end

function RenderJunkoLaser(x, y, offset, w, c, angle)
    local l1 = offset
    local l2 = 256 - offset
    local i = cos(angle)
    RenderTexture('shababa_player', 'mul+add',
            { x, y + w, 0.5, l2, 216, c },
            { x + i * l1, y + w, 0.5, 256, 216, c },
            { x + i * l1, y - w, 0.5, 256, 240, c },
            { x, y - w, 0.5, l2, 240, c }
    )
    RenderTexture('shababa_player', 'mul+add',
            { x, y + w, 0.5, 0, 216, c },
            { x + i * (l1 + 256), y + w, 0.5, 256, 216, c },
            { x + i * (l1 + 256), y - w, 0.5, 256, 240, c },
            { x, y - w, 0.5, 0, 240, c }
    )
    RenderTexture('shababa_player', 'mul+add',
            { x + i * (l1 + 256), y + w, 0.5, 0, 216, c },
            { x + i * (l1 + 512), y + w, 0.5, 256, 216, c },
            { x + i * (l1 + 512), y - w, 0.5, 256, 240, c },
            { x + i * (l1 + 256), y - w, 0.5, 0, 240, c }
    )
end
----------------------------------------------------------------------
----------------------Tensei------------------------------------------
shababa_sei_bullet = Class(player_bullet_straight)

function shababa_sei_bullet:init(img, x, y, v, angle, dmg)
    player_bullet_straight.init(self, img, x, y, v, angle, dmg)
    self.omiga = 6
    self.angle = angle
end

function shababa_sei_bullet:frame()
    self.dmg = max(self.dmg - 0.2 / 60, 0.7)
end

function shababa_sei_bullet:kill()
    New(shababa_sei_bullet_ef, self.x, self.y, self.angle)
end

shababa_sei_bullet_ef = Class(object)

function shababa_sei_bullet_ef:init(x, y, angle)
    self.x = x
    self.y = y
    self.img = 'sei_bullet_ef'
    self.vx = 1.5 * cos(angle)
    self.vy = 1.5 * sin(angle)
    self.omiga = 6
end

function shababa_sei_bullet_ef:frame()
    if self.timer >= 30 then
        Del(self)
    end
end

function shababa_sei_bullet_ef:render()
    SetImageState(self.img, 'mul+add', Color(255 - 255 * self.timer / 30, 255, 255, 255))
    DefaultRenderFunc(self)
    SetImageState(self.img, 'mul+add', Color(255, 255, 255, 255))
end
------------------------------------------------------------------------------




