--

---@class THlib.reimu_player:THlib.player_class
reimu_player = Class(player_class)

reimu_player._load = function()
    if CheckRes('tex', 'reimu_player') then
        return
    end
    LoadTexture('reimu_player', 'THlib\\player\\reimu\\reimu.png')
    --LoadAnimation('reimu_bullet_red_ef', 'reimu_player', 0, 144, 16, 16, 4, 1, 4)
    --SetAnimationState('reimu_bullet_red_ef', 'mul+add', Color(0xA0FFFFFF))

    LoadTexture('reimu_player', 'THlib\\player\\reimu\\reimu.png')
    LoadTexture('reimu_kekkai', 'THlib\\player\\reimu\\reimu_kekkai.png')
    LoadTexture('reimu_orange_ef2', 'THlib\\player\\reimu\\reimu_orange_eff.png')
    LoadImageFromFile('reimu_bomb_ef', 'THlib\\player\\reimu\\reimu_bomb_ef.png')
    LoadAnimation('reimu_bullet_orange_ef2', 'reimu_orange_ef2', 0, 0, 64, 16, 1, 9, 1)
    SetAnimationCenter('reimu_bullet_orange_ef2', 0, 8)
    LoadImageGroup('reimu_player', 'reimu_player', 0, 0, 32, 48, 8, 3, 0.5, 0.5)
    LoadImage('reimu_bullet_red', 'reimu_player', 192, 160, 64, 16, 16, 16)
    SetImageState('reimu_bullet_red', '', Color(0xA0FFFFFF))
    SetImageCenter('reimu_bullet_red', 56, 8)
    LoadAnimation('reimu_bullet_red_ef', 'reimu_player', 0, 144, 16, 16, 4, 1, 4)
    SetAnimationState('reimu_bullet_red_ef', 'mul+add', Color(0xA0FFFFFF))

    LoadImage('reimu_bullet_blue', 'reimu_player', 0, 160, 16, 16, 16, 16)
    SetImageState('reimu_bullet_blue', '', Color(0x80FFFFFF))
    LoadAnimation('reimu_bullet_blue_ef', 'reimu_player', 0, 160, 16, 16, 4, 1, 4)
    SetAnimationState('reimu_bullet_blue_ef', 'mul+add', Color(0xA0FFFFFF))

    LoadImage('reimu_support', 'reimu_player', 64, 144, 16, 16)
    LoadImage('reimu_bullet_ef_img', 'reimu_player', 48, 144, 16, 16)
    LoadImage('reimu_kekkai', 'reimu_kekkai', 0, 0, 256, 256, 0, 0)
    SetImageState('reimu_kekkai', 'mul+add', Color(0x804040FF))
    LoadPS('reimu_bullet_ef', 'THlib\\player\\reimu\\reimu_bullet_ef.psi', 'reimu_bullet_ef_img')
    LoadPS('reimu_sp_ef', 'THlib\\player\\reimu\\reimu_sp_ef.psi', 'parimg1', 16, 16)
    -----------------------------------------
    LoadImage('reimu_bullet_orange', 'reimu_player', 64, 176, 64, 16, 64, 16)
    SetImageState('reimu_bullet_orange', '', Color(0x80FFFFFF))
    SetImageCenter('reimu_bullet_orange', 32, 8)

    LoadImage('reimu_bullet_orange_ef', 'reimu_player', 64, 176, 64, 16, 64, 16)
    SetImageState('reimu_bullet_orange_ef', '', Color(0x80FFFFFF))
    SetImageCenter('reimu_bullet_orange_ef', 32, 8)
end

function reimu_player:init()
    reimu_player._load()
    player_class.init(self)
    self.name = 'Reimu'
    self.hspeed = 4.5
    self.imgs = {}
    self.A = 0.5
    self.B = 0.5
    for i = 1, 24 do
        self.imgs[i] = 'reimu_player' .. i
    end
    self.slist = {
        { nil, nil, nil, nil },
        { { 0, 36, 0, 24 }, nil, nil, nil },
        { { -32, 0, -12, 24 }, { 32, 0, 12, 24 }, nil, nil },
        { { -32, -8, -16, 20 }, { 0, -32, 0, 28 }, { 32, -8, 16, 20 }, nil },
        { { -36, -12, -16, 20 }, { -16, -32, -6, 28 }, { 16, -32, 6, 28 }, { 36, -12, 16, 20 } },
        { { -36, -12, -16, 20 }, { -16, -32, -6, 28 }, { 16, -32, 6, 28 }, { 36, -12, 16, 20 } },
    }
    self.anglelist = {
        { 90, 90, 90, 90 },
        { 90, 90, 90, 90 },
        { 100, 80, 90, 90 },
        { 100, 90, 80, 90 },
        { 110, 100, 80, 70 },
    }
end
-------------------------------------------------------
function reimu_player:shoot()
    PlaySound('plst00', 0.3, self.x / 1024)
    self.nextshoot = 4
    New(reimu_bullet_red, 'reimu_bullet_red', self.x + 10, self.y, 24, 90, 2)
    New(reimu_bullet_red, 'reimu_bullet_red', self.x - 10, self.y, 24, 90, 2)
    if self.support > 0 then
        if self.slow == 1 then
            for i = 1, 4 do
                if self.sp[i] and self.sp[i][3] > 0.5 then
                    New(reimu_bullet_orange, 'reimu_bullet_orange',
                        self.supportx + self.sp[i][1] - 3,
                        self.supporty + self.sp[i][2],
                        24, 90, 0.3)
                    New(reimu_bullet_orange, 'reimu_bullet_orange',
                        self.supportx + self.sp[i][1] + 3,
                        self.supporty + self.sp[i][2],
                        24, 90, 0.3)
                end
            end
        else
            --local num=60/(self.support+1)
            if self.timer % 8 < 4 then
                local num = int(lstg.var.power / 100) + 1
                for i = 1, 4 do
                    if self.sp[i] and self.sp[i][3] > 0.5 then
                        New(reimu_bullet_blue, 'reimu_bullet_blue',
                            self.supportx + self.sp[i][1],
                            self.supporty + self.sp[i][2],
                            8, self.anglelist[num][i], self.target, 900, 0.7)
                    end
                end
            end
        end
    end
end
-------------------------------------------------------
function reimu_player:spell()
    if self.slow == 1 then
        PlaySound('power1', 0.8)
        PlaySound('cat00', 0.8)
        misc.ShakeScreen(210, 3)
        --New(bullet_killer,self.x,self.y)
        New(player_spell_mask, 64, 64, 255, 30, 210, 30)
        New(reimu_kekkai, self.x, self.y, 1.25, 3, 20, 12)
        self.nextspell = 240
        self.protect = 360
    else
        PlaySound('nep00', 0.8)
        PlaySound('slash', 0.8)
        New(player_spell_mask, 200, 0, 0, 30, 180, 30)
        local rot = ran:Int(0, 360)
        for i = 1, 8 do
            New(reimu_sp_ef1, 'reimu_sp_ef', self.x, self.y, 8, rot + i * 45, tar1, 1200, 1, 40 - 10 * i)
        end
        self.nextspell = 300
        self.protect = 360
    end
end
-------------------------------------------------------
function reimu_player:render()
    for i = 1, 4 do
        if self.sp[i] and self.sp[i][3] > 0.5 then
            Render('reimu_support', self.supportx + self.sp[i][1], self.supporty + self.sp[i][2], self.timer * 3)
        end
    end
    player_class.render(self)
end
-------------------------------------------------------

---@class THlib.reimu_sp_ef1:object
reimu_sp_ef1 = Class(object)
function reimu_sp_ef1:init(img, x, y, v, angle, target, trail, dmg, t)
    self.killflag = true
    self.group = GROUP_PLAYER_BULLET
    self.layer = LAYER_PLAYER_BULLET
    self.img = img
    self.vscale = 1.2
    self.hscale = 1.2
    self.a = self.a * 1.2
    self.b = self.b * 1.2
    self.x = x
    self.y = y
    self.rot = angle
    self.angle = angle
    self.v = v
    self.target = target
    self.trail = trail
    self.dmg = dmg
    self.DMG = dmg
    self.bound = false
    self.tflag = t
end
function reimu_sp_ef1:frame()
    local w = lstg.world
    if BoxCheck(self, w.l, w.r, w.b, w.t) then
        self.inscreen = true
    end
    if self.timer < 150 + self.tflag then
        self.rot = self.angle - 4 * self.timer - 90
        self.x = self.timer * 1 * cos(self.rot + 90) + player.x
        self.y = self.timer * 1 * sin(self.rot + 90) + player.y
    end
    player_class.findtarget(self)
    if self.timer > 150 + self.tflag then
        self.killflag = false
        self.dmg = 35
        if IsValid(self.target) and self.target.colli then
            local a = math.mod(Angle(self, self.target) - self.rot + 720, 360)
            if a > 180 then
                a = a - 360
            end
            local da = self.trail / (Dist(self, self.target) + 1)
            if da >= abs(a) then
                self.rot = Angle(self, self.target)
            else
                self.rot = self.rot + sign(a) * da
            end
        end
        self.vx = 8 * cos(self.rot)
        self.vy = 8 * sin(self.rot)
        local world = lstg.world
        if self.inscreen then
            if self.x > world.r then
                self.x = world.r
                self.vx = 0
                self.vy = 0
            end
            if self.x < world.l then
                self.x = world.l
                self.vx = 0
                self.vy = 0
            end
            if self.y > world.t then
                self.y = world.t
                self.vx = 0
                self.vy = 0
            end
            if self.y < world.b then
                self.y = world.b
                self.vx = 0
                self.vy = 0
            end
        end
    end
    if self.timer > 230 then
        self.killflag = true
        self.dmg = 0.4 * self.DMG
        self.a = 2 * self.a
        self.b = 2 * self.b
        self.vscale = (self.timer - 230) * 0.5 + 1
        self.hscale = (self.timer - 230) * 0.5 + 1
    end
    if self.timer > 240 then
        Kill(self)
    end
    New(bomb_bullet_killer, self.x, self.y, self.a * 1.5, self.b * 1.5, false)
end

function reimu_sp_ef1:kill()
    misc.ShakeScreen(5, 5)
    PlaySound('explode', 0.3)
    New(bubble, 'parimg12', self.x, self.y, 30, 4, 6, Color(0xFFFFFFFF), Color(0x00FFFFFF), LAYER_ENEMY_BULLET_EF, '')
    local a = ran:Float(0, 360)
    for i = 1, 12 do
        New(reimu_sp_ef2, self.x, self.y, ran:Float(4, 6), a + i * 30, 2, ran:Int(1, 3))
    end
    self.vscale = 2
    self.hscale = 2
    --misc.KeepParticle(self)
end

function reimu_sp_ef1:del()
    PlaySound('explode', 0.3)
    New(bubble, 'parimg12', self.x, self.y, 30, 4, 6, Color(0xFFFFFFFF), Color(0x00FFFFFF), LAYER_ENEMY_BULLET_EF, '')
    --	for i=1,4 do
    --		New(reimu_sp_ef2,16,16,self.x,self.y,3,360/16*i,0.25,4,30)
    --	end
    misc.KeepParticle(self)
    self.vscale = 6
    self.hscale = 6
end

-------------------------------------------------------

---@class THlib.reimu_sp_ef2:object
reimu_sp_ef2 = Class(object)

function reimu_sp_ef2:init(x, y, v, angle, scale, index)
    self.img = 'reimu_bomb_ef'
    self.group = GROUP_GHOST
    self.layer = LAYER_PLAYER_BULLET
    self.colli = false
    self.x = x
    self.y = y
    self.rot = angle
    self.vx = v * cos(angle)
    self.vy = v * sin(angle)
    self.dmg = dmg
    self.hide = false
    self.scale = scale
    self.hscale = scale
    self.vscale = scale
    self.rbg = { { 255, 0, 0 }, { 0, 255, 0 }, { 0, 0, 255 } }
    self.index = index
    --ParticleSetEmission(self,10)
end

function reimu_sp_ef2:frame()
    self.vscale = self.scale * (1 - self.timer / 60)
    self.hscale = self.scale * (1 - self.timer / 60)
    if self.timer >= 30 then
        Del(self)
    end
end

function reimu_sp_ef2:render()
    SetImageState(self.img, 'mul+add', Color(255 - 255 * self.timer / 30, self.rbg[self.index][1], self.rbg[self.index][2], self.rbg[self.index][3]))
    Render(self.img, self.x, self.y)
    SetImageState(self.img, 'mul+add', Color(255, 255, 255, 255))
end
-------------------------------------------------------

---@class THlib.reimu_bullet_red:THlib.player_bullet_straight
reimu_bullet_red = Class(player_bullet_straight)

function reimu_bullet_red:kill()
    New(reimu_bullet_red_ef, self.x, self.y, self.rot + 180)
end
-------------------------------------------------------

---@class THlib.reimu_bullet_red_ef:object
reimu_bullet_red_ef = Class(object)

function reimu_bullet_red_ef:init(x, y)
    self.x = x
    self.y = y
    self.rot = 90
    self.img = 'reimu_bullet_red_ef'
    self.layer = LAYER_PLAYER_BULLET + 50
    self.group = GROUP_GHOST
    self.vy = 2.25
end
function reimu_bullet_red_ef:frame()
    if self.timer > 14 then
        self.y = 600
        Del(self)
    end
end
-------------------------------------------------------

---@class THlib.reimu_bullet_orange:THlib.player_bullet_straight
reimu_bullet_orange = Class(player_bullet_straight)

function reimu_bullet_orange:kill()
    New(reimu_bullet_orange_ef, self.x, self.y, self.rot + 180 + ran:Float(-15, 15))
    New(reimu_bullet_orange_ef2, self.x, self.y)
end
-------------------------------------------------------

---@class THlib.reimu_bullet_blue:THlib.player_bullet_straight
reimu_bullet_blue = Class(player_bullet_trail)

function reimu_bullet_blue:init(img, x, y, v, angle, target, trail, dmg)
    self.group = GROUP_PLAYER_BULLET
    self.layer = LAYER_PLAYER_BULLET
    self.img = img
    self.x = x
    self.y = y
    self.rot = angle
    self.v = v
    self.target = target
    self.trail = trail
    self.dmg = dmg
end

function reimu_bullet_blue:frame()
    player_class.findtarget(self)
    if IsValid(self.target) and self.target.colli then
        local a = math.mod(Angle(self, self.target) - self.rot + 720, 360)
        if a > 180 then
            a = a - 360
        end
        local da = self.trail / (Dist(self, self.target) + 1)
        if da >= abs(a) then
            self.rot = Angle(self, self.target)
        else
            self.rot = self.rot + sign(a) * da
        end
    end
    self.vx = self.v * cos(self.rot)
    self.vy = self.v * sin(self.rot)
end

function reimu_bullet_blue:kill()
    New(reimu_bullet_blue_ef, self.x, self.y, self.rot)
end

-------------------------------------------------------

---@class THlib.reimu_bullet_blue_ef:object
reimu_bullet_blue_ef = Class(object)

function reimu_bullet_blue_ef:init(x, y, rot)
    self.x = x
    self.y = y
    self.rot = rot
    self.img = 'reimu_bullet_blue_ef'
    self.layer = LAYER_PLAYER_BULLET + 50
    self.group = GROUP_GHOST
    self.vx = 1 * cos(rot)
    self.vy = 1 * sin(rot)
end

function reimu_bullet_blue_ef:frame()
    if self.timer > 14 then
        Del(self)
    end
end
-------------------------------------------------------

---@class THlib.reimu_sp_ef:THlib.player_bullet_trail
reimu_sp_ef = Class(player_bullet_trail)

function reimu_sp_ef:kill()
    PlaySound('explode', 0.3)
    New(bubble, 'parimg12', self.x, self.y, 30, 4, 6, Color(0xFFFFFFFF), Color(0x00FFFFFF), LAYER_ENEMY_BULLET_EF, '')
    for i = 1, 16 do
        New(reimu_sp_ef2, 16, 16, self.x, self.y, 3, 360 / 16 * i, 0.25, 4, 30)
    end
    misc.KeepParticle(self)
end

function reimu_sp_ef:del()
    misc.KeepParticle(self)
end
-------------------------------------------------------

---@class THlib.reimu_bullet_ef:object
reimu_bullet_ef = Class(object)

function reimu_bullet_ef:init(x, y, rot)
    self.x = x
    self.y = y
    self.rot = rot
    self.img = 'reimu_bullet_ef'
    self.layer = LAYER_PLAYER_BULLET + 50
    self.group = GROUP_GHOST
end

function reimu_bullet_ef:frame()
    if self.timer == 4 then
        ParticleStop(self)
    end
    if self.timer == 30 then
        Del(self)
    end
end
-------------------------------------------------------

---@class THlib.reimu_bullet_orange_ef:object
reimu_bullet_orange_ef = Class(object)

function reimu_bullet_orange_ef:init(x, y, rot)
    self.x = x
    self.y = y + 32
    self.rot = rot
    self.img = 'reimu_bullet_orange_ef'
    self.layer = LAYER_PLAYER_BULLET + 50
    self.group = GROUP_GHOST
    self.vy = 2
    self.hscale = ran:Float(1.4, 1.6)
end

function reimu_bullet_orange_ef:frame()
    SetImgState(self, 'mul+add', 255 - 255 * self.timer / 16, 255, 255, 255)
    if self.timer > 15 then
        self.x = 600
        Del(self)
    end
end

-------------------------------------------------------

---@class THlib.reimu_bullet_orange_ef2:object
reimu_bullet_orange_ef2 = Class(object)

function reimu_bullet_orange_ef2:init(x, y)
    self.x = x
    self.y = y + 32
    self.rot = -90 + ran:Float(-10, 10)
    self.img = 'reimu_bullet_orange_ef2'
    self.layer = LAYER_PLAYER_BULLET + 50
    self.group = GROUP_GHOST
    self.hscale = ran:Float(1.5, 1.8)
    self.vscale = 1.5
end

function reimu_bullet_orange_ef2:frame()
    SetImgState(self, 'mul+add', 255, 255, 155, 155)
    if self.timer >= 9 then
        self.x = 600
        Del(self)
    end
end

-------------------------------------------------------

---@class THlib.reimu_kekkai:object
reimu_kekkai = Class(object)

function reimu_kekkai:init(x, y, dmg, dr, n, t)
    self.x = x
    self.y = y
    self.dmg = dmg
    SetImageState('reimu_kekkai', 'mul+add', Color(0x804040FF))
    self.killflag = true
    self.group = GROUP_PLAYER_BULLET
    self.layer = LAYER_PLAYER_BULLET
    self.r = 0
    self.a = 0
    self.b = 0
    self.dr = dr
    self.ds = dr / 256
    self.n = 0
    self.mute = true
    self.list = {}
    task.New(self, function()
        for i = 1, n do
            self.list[i] = { scale = 0, rot = 0 }
            self.n = self.n + 1
            task.Wait(t)
        end
        self.dmg = 0
        PlaySound('slash', 1.0)
        --		New(bullet_killer,self.x,self.y)
        for i = 128, 0, -4 do
            SetImageState('reimu_kekkai', 'mul+add', Color(0x004040FF) + i * Color(0x01000000))
            task.Wait(1)
        end
        Del(self)
    end)
end

function reimu_kekkai:frame()
    task.Do(self)
    if self.timer % 6 == 0 then
        self.mute = false
    else
        self.mute = true
    end
    self.r = self.r + self.dr
    self.a = self.r
    self.b = self.r
    for i = 1, self.n do
        self.list[i].scale = self.list[i].scale + self.ds
        self.list[i].rot = self.list[i].rot + (-1) ^ i
    end
    New(bomb_bullet_killer, self.x, self.y, self.a / 1.25, self.b / 1.25, false)
end

function reimu_kekkai:render()
    for i = 1, self.n do
        Render('reimu_kekkai', self.x, self.y, self.list[i].rot, self.list[i].scale)
    end
end
