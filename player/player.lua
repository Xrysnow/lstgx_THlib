--

local int = int
local abs = abs
local min = min
local max = max
local sin = sin
local cos = cos
local task = task
local Color = Color
local New = New
local IsValid = IsValid
local PlaySound = PlaySound
local SetImageState = SetImageState
local Render = Render
local Del = Del
local ObjList = ObjList
local KeyIsDown = KeyIsDown
local Dist = Dist
local Angle = Angle

LoadPS('player_death_ef', 'THlib\\player\\player_death_ef.psi', 'parimg1')
LoadPS('graze', 'THlib\\player\\graze.psi', 'parimg6')
LoadImageFromFile('player_spell_mask', 'THlib\\player\\spellmask.png')

---
---@class THlib.player_class:object
player_class = Class(object)
function player_class:init()
    self.group = GROUP_PLAYER
    self.y = -176
    self.supportx = 0
    self.supporty = self.y
    self.hspeed = 4
    self.lspeed = 2
    self.collect_line = 96
    self.slow = 0
    self.layer = LAYER_PLAYER
    self.lr = 1
    self.lh = 0
    self.fire = 0
    self.lock = false
    self.dialog = false--是否处于对话状态
    self.nextshoot = 0
    self.nextspell = 0
    self.A = 0--|自机判定大小
    self.B = 0--|
    --self.nextcollect=0--HZC收点系统
    self.death = 0--miss之后的计时器，100->0
    self.protect = 120
    lstg.player = self
    player = self
    self.grazer = New(grazer)
    if not lstg.var.init_player_data then
        error('Player data has not been initialized. (Call function item.PlayerInit.)')
    end
    self.support = int(lstg.var.power / 100)--子机数量
    self.sp = {}
    self.time_stop = false
end

function player_class:frame()
    --find target
    if ((not IsValid(self.target)) or (not self.target.colli)) then
        player_class.findtarget(self)
    end
    if not KeyIsDown 'shoot' then
        self.target = nil
    end
    --
    local dx = 0
    local dy = 0
    local v = self.hspeed
    if (self.death == 0 or self.death > 90) and (not self.lock) and not (self.time_stop) then
        --slow
        if KeyIsDown 'slow' then
            self.slow = 1
        else
            self.slow = 0
        end
        --shoot and spell
        if not self.dialog then
            if KeyIsDown 'shoot' and self.nextshoot <= 0 then
                self.class.shoot(self)
            end
            if KeyIsDown 'spell' and self.nextspell <= 0 and lstg.var.bomb > 0 and not lstg.var.block_spell then
                --spell
                item.PlayerSpell()
                lstg.var.bomb = lstg.var.bomb - 1
                self.class.spell(self)
                self.death = 0
            end
        else
            self.nextshoot = 15
            self.nextspell = 30--每隔15帧处理一次shoot，每隔30帧处理一次spell
        end
        --move
        if self.death == 0 and not self.lock then
            if self.slowlock then
                self.slow = 1
            end
            if self.slow == 1 then
                v = self.lspeed
            end
            if KeyIsDown 'up' then
                dy = dy + 1
            end
            if KeyIsDown 'down' then
                dy = dy - 1
            end
            if KeyIsDown 'left' then
                dx = dx - 1
            end
            if KeyIsDown 'right' then
                dx = dx + 1
            end
            if dx * dy ~= 0 then
                v = v * SQRT2_2
            end--斜向移动时除以根号2
            self.x = self.x + v * dx
            self.y = self.y + v * dy
            --限位
            self.x = max(min(self.x, lstg.world.pr - 8), lstg.world.pl + 8)
            self.y = max(min(self.y, lstg.world.pt - 32), lstg.world.pb + 16)
        end
        --fire
        if KeyIsDown 'shoot' and not self.dialog then
            self.fire = self.fire + 0.16
        else
            self.fire = self.fire - 0.16
        end
        if self.fire < 0 then
            self.fire = 0
        end
        if self.fire > 1 then
            self.fire = 1
        end
        --收点
        if self.y > self.collect_line then
            for i, o in ObjList(GROUP_ITEM) do
                o.attract = 8
            end
            --HZC收点系统
            --		else
            --		if self.y>self.collect_line then
            --			for i,o in ObjList(GROUP_ITEM) do o.attract=8 self.item=i
            --			end
            --			if self.nextcollect==0 then
            --				item.playercollect(self.item)
            --			end
            --			self.item=0
            --			self.nextcollect=60
        else
            if KeyIsDown 'slow' then
                for i, o in ObjList(GROUP_ITEM) do
                    if Dist(self, o) < 48 then
                        o.attract = max(o.attract, 3)
                    end
                end
            else
                for i, o in ObjList(GROUP_ITEM) do
                    if Dist(self, o) < 24 then
                        o.attract = max(o.attract, 3)
                    end
                end
            end
        end
    elseif self.death == 90 then
        if self.time_stop then
            self.death = self.death - 1
        end--不受时停影响
        item.PlayerMiss()
        --反色圆效果
        self.deathee = {}
        self.deathee[1] = New(deatheff, self.x, self.y, 'first')
        self.deathee[2] = New(deatheff, self.x, self.y, 'second')
        --粒子效果
        New(player_death_ef, self.x, self.y)
    elseif self.death == 84 then
        if self.time_stop then
            self.death = self.death - 1
        end
        self.hide = true
        self.support = int(lstg.var.power / 100)
    elseif self.death == 50 then
        if self.time_stop then
            self.death = self.death - 1
        end
        self.x = 0
        self.supportx = 0
        self.y = -236
        self.supporty = -236
        self.hide = false
        New(bullet_deleter, self.x, self.y)--消弹
    elseif self.death < 50 and not (self.lock) and not (self.time_stop) then
        --此处没有self.death-1，会被时停影响
        self.y = -176 - 1.2 * self.death--从下向上出现
    end
    --img
    --加上time_stop的限制来实现图像时停
    if not (self.time_stop) then
        --根据lr决定显示哪一帧
        if abs(self.lr) == 1 then
            self.img = self.imgs[int(self.ani / 8) % 8 + 1]
        elseif self.lr == -6 then
            self.img = self.imgs[int(self.ani / 8) % 4 + 13]
        elseif self.lr == 6 then
            self.img = self.imgs[int(self.ani / 8) % 4 + 21]
        elseif self.lr < 0 then
            self.img = self.imgs[7 - self.lr]
        elseif self.lr > 0 then
            self.img = self.imgs[15 + self.lr]
        end
        --设置判定（碰撞盒大小）
        self.a = self.A
        self.b = self.B
        --计算lr
        self.lr = self.lr + dx;
        if self.lr > 6 then
            self.lr = 6
        end
        if self.lr < -6 then
            self.lr = -6
        end
        if self.lr == 0 then
            self.lr = self.lr + dx
        end
        if dx == 0 then
            if self.lr > 1 then
                self.lr = self.lr - 1
            end
            if self.lr < -1 then
                self.lr = self.lr + 1
            end
        end

        --低速过渡状态，用于子机位置过渡、判定点显示过渡
        self.lh = self.lh + (self.slow - 0.5) * 0.3
        if self.lh < 0 then
            self.lh = 0
        end
        if self.lh > 1 then
            self.lh = 1
        end

        if self.nextshoot > 0 then
            self.nextshoot = self.nextshoot - 1
        end
        if self.nextspell > 0 then
            self.nextspell = self.nextspell - 1
        end
        --if self.nextcollect>0 then self.nextcollect=self.nextcollect-1 end--HZC收点系统

        if self.support > int(lstg.var.power / 100) then
            self.support = self.support - 0.0625
        elseif self.support < int(lstg.var.power / 100) then
            self.support = self.support + 0.0625
        end
        if abs(self.support - int(lstg.var.power / 100)) < 0.0625 then
            self.support = int(lstg.var.power / 100)
        end

        self.supportx = self.x + (self.supportx - self.x) * 0.6875
        self.supporty = self.y + (self.supporty - self.y) * 0.6875

        if self.protect > 0 then
            self.protect = self.protect - 1
        end
        if self.death > 0 then
            self.death = self.death - 1
        end

        lstg.var.pointrate = item.PointRateFunc(lstg.var)
        --更新子机
        if self.slist then
            --子机位置表
            self.sp = {}--子机
            if self.support == 5 then
                for i = 1, 4 do
                    self.sp[i] = MixTable(self.lh, self.slist[6][i])
                    self.sp[i][3] = 1--子机火力，一般大于0.5时才有效
                end
            else
                local s = int(self.support) + 1
                local t = self.support - int(self.support)
                for i = 1, 4 do
                    if self.slist[s][i] and self.slist[s + 1][i] then
                        self.sp[i] = MixTable(t,
                                              MixTable(self.lh, self.slist[s][i]),
                                              MixTable(self.lh, self.slist[s + 1][i])
                        )
                        self.sp[i][3] = 1
                    elseif self.slist[s + 1][i] then
                        self.sp[i] = MixTable(self.lh, self.slist[s + 1][i])
                        self.sp[i][3] = t
                    end
                end
            end
        end
        --
    end
    --time_stop
    if self.time_stop then
        self.timer = self.timer - 1
    end
end

function player_class:render()
    --闪烁蓝色
    --TODO 反复set影响效率
    if self.protect % 3 == 1 then
        SetImageState(self.img, '', Color(0xFF0000FF))--初始值应避开此条件
    else
        SetImageState(self.img, '', Color(0xFFFFFFFF))
    end
    object.render(self)
end

function player_class:colli(other)
    if self.death == 0 and not self.dialog and not cheat then
        if self.protect == 0 then
            --miss
            PlaySound('pldead00', 0.5)
            self.death = 100
        end
        if other.group == GROUP_ENEMY_BULLET then
            Del(other)
        end
    end
end

---追踪功能，以最接近垂直方向的敌人作为目标
function player_class:findtarget()
    self.target = nil
    local maxpri = -1
    for i, o in ObjList(GROUP_ENEMY) do
        if o.colli then
            local dx = self.x - o.x
            local dy = self.y - o.y
            local pri = abs(dy) / (abs(dx) + 0.01)
            if pri > maxpri then
                maxpri = pri
                self.target = o
            end
        end
    end
end

---擦弹功能
---@class THlib.grazer:object
grazer = Class(object)
function grazer:init()
    self.layer = LAYER_ENEMY_BULLET_EF + 50
    self.group = GROUP_PLAYER
    self.player = lstg.player
    self.grazed = false
    self.img = 'graze'
    ParticleStop(self)
    self.a = 24
    self.b = 24
    self.aura = 0
end

function grazer:frame()
    self.x = self.player.x
    self.y = self.player.y
    self.hide = self.player.hide
    if not self.player.time_stop then
        self.aura = self.aura + 1.5
    end
    --
    if self.grazed then
        PlaySound('graze', 0.3, self.x / 200)
        self.grazed = false
        ParticleFire(self)
    else
        ParticleStop(self)
    end
end

function grazer:render()
    --self.x = self.player.x
    --self.y = self.player.y
    object.render(self)
    --渲染判定点，根据低速过渡状态改变透明度和大小，匀速自转
    --写在这里可能是为了实现gzz效果
    SetImageState('player_aura', '', Color(0xC0FFFFFF) * self.player.lh + Color(0x00FFFFFF) * (1 - self.player.lh))
    Render('player_aura', self.x, self.y, self.aura, 2 - self.player.lh)
    SetImageState('player_aura', '', Color(0xC0FFFFFF))
    Render('player_aura', self.x, self.y, -self.aura, self.player.lh)
end

function grazer:colli(other)
    if other.group ~= GROUP_ENEMY and (not other._graze) then
        item.PlayerGraze()
        lstg.player.grazer.grazed = true
        other._graze = true
        --只能擦一次，激光的擦弹由激光对象计算
    end
end

---直线
---@class THlib.player_bullet_straight:object
player_bullet_straight = Class(object)

---@param img string
---@param x number
---@param y number
---@param v number
---@param angle number
---@param dmg number
function player_bullet_straight:init(img, x, y, v, angle, dmg)
    self.group = GROUP_PLAYER_BULLET
    self.layer = LAYER_PLAYER_BULLET
    self.img = img
    self.x = x
    self.y = y
    self.rot = angle
    self.vx = v * cos(angle)
    self.vy = v * sin(angle)
    self.dmg = dmg
    if self.a ~= self.b then
        self.rect = true
    end
end

---直线，colli=false，没有img
---@class THlib.player_bullet_hide:object
player_bullet_hide = Class(object)

function player_bullet_hide:init(a, b, x, y, v, angle, dmg, delay)
    self.group = GROUP_PLAYER_BULLET
    self.layer = LAYER_PLAYER_BULLET
    self.colli = false
    self.a = a
    self.b = b
    self.x = x
    self.y = y
    self.rot = angle
    self.vx = v * cos(angle)
    self.vy = v * sin(angle)
    self.dmg = dmg
    self.delay = delay or 0
end

function player_bullet_hide:frame()
    if self.timer == self.delay then
        self.colli = true
    end
end

---诱导
---@class THlib.player_bullet_trail:object
player_bullet_trail = Class(object)

function player_bullet_trail:init(img, x, y, v, angle, target, trail, dmg)
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

function player_bullet_trail:frame()
    if IsValid(self.target) and self.target.colli then
        local a = math.mod(Angle(self, self.target) - self.rot + 720, 360)
        if a > 180 then
            a = a - 360
        end
        --有限程度的诱导
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

---bomb颜色遮罩
---@class THlib.player_spell_mask:object
player_spell_mask = Class(object)

function player_spell_mask:init(r, g, b, t1, t2, t3)
    self.x = 0
    self.y = 0
    self.group = GROUP_GHOST
    self.layer = LAYER_BG + 1
    self.img = 'player_spell_mask'
    self.red = r
    self.green = g
    self.blue = b
    SetImageState('player_spell_mask', 'mul+add', Color(0, r, g, b))
    task.New(self, function()
        for i = 1, t1 do
            SetImageState('player_spell_mask', 'mul+add', Color(i * 255 / t1, r, g, b))
            task.Wait(1)
        end
        task.Wait(t2)
        for i = t3, 1, -1 do
            SetImageState('player_spell_mask', 'mul+add', Color(i * 255 / t1, r, g, b))
            task.Wait(1)
        end
        Del(self)
    end)
end

function player_spell_mask:frame()
    task.Do(self)
end

---miss时的粒子效果
---@class THlib.player_death_ef:object
player_death_ef = Class(object)
function player_death_ef:init(x, y)
    self.x = x
    self.y = y
    self.img = 'player_death_ef'
    self.layer = LAYER_PLAYER + 50
end

function player_death_ef:frame()
    if self.timer == 4 then
        ParticleStop(self)
    end
    if self.timer == 60 then
        Del(self)
    end
end

---MixTable(x,t1,t2)
---对表中数值进行线性组合
---r=(1-x)*t1+x*t2
---r=(1-x)*t1前半+x*t1后半
function MixTable(x, t1, t2)
    local r = {}
    local y = 1 - x
    if t2 then
        for i = 1, #t1 do
            r[i] = y * t1[i] + x * t2[i]
        end
        return r
    else
        local n = int(#t1 / 2)
        for i = 1, n do
            r[i] = y * t1[i] + x * t1[i + n]
        end
        return r
    end
end

---miss时的圆形扩散效果
---@class THlib.deatheff:object
deatheff = Class(object)
function deatheff:init(x, y, type_)
    self.x = x
    self.y = y
    self.type = type_
    self.size = 0
    self.size1 = 0
    self.layer = LAYER_TOP - 1
    task.New(self, function()
        local size = 0
        local size1 = 0
        if self.type == 'second' then
            task.Wait(30)
        end
        for i = 1, 360 do
            self.size = size
            self.size1 = size1
            size = size + 12
            size1 = size1 + 8
            task.Wait(1)
        end
    end)
end

function deatheff:frame()
    task.Do(self)
    if self.timer > 180 then
        Del(self)
    end
end

function deatheff:render()
    if self.type == 'first' then
        --5个反色圆，1大4小
        rendercircle(self.x, self.y, self.size, 180)
        rendercircle(self.x + 35, self.y + 35, self.size1, 180)
        rendercircle(self.x + 35, self.y - 35, self.size1, 180)
        rendercircle(self.x - 35, self.y + 35, self.size1, 180)
        rendercircle(self.x - 35, self.y - 35, self.size1, 180)
    elseif self.type == 'second' then
        rendercircle(self.x, self.y, self.size, 180)
    end
end

---player列表
---{显示名, 类名(score用), 简称(rep显示用)}
---@class THlib.player_list
player_list = {
    { 'Hakurei Reimu', 'reimu_player', 'Reimu' },
    { 'Kirisame Marisa', 'marisa_player', 'Marisa' },
    { 'Shalimar', 'shababa_player', 'Shalimar' },
}

Include 'THlib/player/reimu/reimu.lua'
Include 'THlib/player/marisa/marisa.lua'
Include 'THlib/player/shababa/shababa_player.lua'
