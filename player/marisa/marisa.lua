--

---@class THlib.marisa_player:THlib.player_class
marisa_player = Class(player_class)

marisa_player._load = function()
    if CheckRes('tex','marisa_player') then
        return
    end
    LoadTexture('marisa_player', 'THlib\\player\\marisa\\marisa.png')
    LoadTexture('marisa_spark', 'THlib\\player\\marisa\\marisa_spark.png')
    LoadTexture('MarisaLaser', 'THlib\\player\\marisa\\MarisaLaser.png')
    LoadImageFromFile('marisa_hit_par', 'THlib\\player\\marisa\\marisa_hit_par.png')
    LoadImageGroup('marisa_player', 'marisa_player', 0, 0, 32, 48, 8, 3, 1, 1)
    LoadImage('marisa_bullet', 'marisa_player', 0, 144, 32, 16, 16, 16)
    LoadAnimation('marisa_bullet_ef', 'marisa_player', 0, 144, 32, 16, 4, 1, 4)
    SetImageState('marisa_bullet', '', Color(0x80FFFFFF))
    LoadImage('marisa_missile', 'marisa_player', 192, 224, 32, 16, 8, 8)
    SetImageState('marisa_missile', '', Color(0xEEFFFFFF))
    LoadAnimation('marisa_missile_ef', 'marisa_player', 64, 224, 32, 32, 4, 1, 2)
    SetAnimationState('marisa_missile_ef', 'mul+add', Color(0x80FFFFFF))
    LoadImage('marisa_support', 'marisa_player', 144, 144, 16, 16)
    LoadImage('marisa_laser_light', 'marisa_player', 224, 224, 32, 32)
    SetImageState('marisa_laser_light', 'mul+add', Color(0xFFFFFFFF))
    LoadImage('marisa_spark', 'marisa_spark', 0, 64, 256, 128, 0, 0)
    LoadImage('marisa_spark_wave', 'marisa_spark', 256, 0, 96, 256, 96, 180)
    SetImageState('marisa_spark', 'mul+add', Color(0xFFFFFFFF))
    SetImageState('marisa_spark_wave', 'mul+add', Color(0xFFFFFFFF))
    SetImageCenter('marisa_spark', 0, 64)
    LoadPS('marisa_sp_ef', 'THlib\\player\\marisa\\marisa_sp_ef.psi', 'parimg6')
    LoadPS('marisa_hit', 'THlib\\player\\marisa\\marisa_hit.psi', 'marisa_hit_par')
end

function marisa_player:init()
    marisa_player._load()
    player_class.init(self)
    self.name = 'Marisa'
    self.imgs = {}
    self.A = 1
    self.B = 1
    for i = 1, 24 do
        self.imgs[i] = 'marisa_player' .. i
    end
    self.hspeed = 5
    self.offset = { 600, 600, 600, 600 }
    self.slist = {
        { nil, nil, nil, nil },
        { { 0, 32, 0, 29 }, nil, nil, nil },
        { { -30, 10, -8, 23 }, { 30, 10, 8, 23 }, nil, nil },
        { { -30, 0, -10, 24 }, { 0, 32, 0, 32 }, { 30, 0, 10, 24 }, nil },
        { { -30, 10, -15, 20 }, { -12, 32, -7.5, 29 }, { 12, 32, 7.5, 29 }, { 30, 10, 15, 20 } },
        { { -30, 10, -15, 20 }, { -7.5, 32, -7.5, 29 }, { 7.5, 32, 7.5, 29 }, { 30, 10, 15, 20 } },
    }
    self.anglelist = {
        { 90, 90, 90, 90 },
        { 90, 90, 90, 90 },
        { 95, 85, 90, 90 },
        { 95, 90, 85, 90 },
        { 95, 90, 90, 85 }
    }
    self.Missile = function(idx)
        PlaySound('msl', 0.2)
        for _, i in ipairs(idx) do
            if self.sp[i] and self.sp[i][3] > 0.5 then
                New(marisa_missile, 'marisa_missile',
                        self.supportx + self.sp[i][1],
                        self.supporty + self.sp[i][2],
                        16, 90, 1.4)
            end
        end
    end
end

function marisa_player:frame()
    self.offset = { 600, 600, 600, 600 }
    player_class.frame(self)
end

function marisa_player:shoot()
    if self.nextspell <= 0 then
        if self.timer % 4 == 0 then
            PlaySound('plst00', 0.15, self.x / 1024)
            New(marisa_bullet, 'marisa_bullet', self.x + 6, self.y, 24, 90, 2)
            New(marisa_bullet, 'marisa_bullet', self.x - 6, self.y, 24, 90, 2)
        end
        local power = int(lstg.var.power / 100)
        if self.slow == 1 then
            if power <= 2 then
                if self.timer % 16 == 0 then
                    self.Missile({ 1, 2, 3, 4 })
                end
            elseif power == 3 then
                if self.timer % 16 == 0 then
                    self.Missile({ 1, 3 })
                end
                if self.timer % 16 == 8 then
                    self.Missile({ 2 })
                end
            else
                if self.timer % 16 == 0 then
                    self.Missile({ 1, 4 })
                end
                if self.timer % 16 == 8 then
                    self.Missile({ 2, 3 })
                end
            end
        elseif self.support > 0 then
            if self.timer % 12 == 0 then
                PlaySound('lazer02', 0.025)
            end
            local num = 30 / (self.support + 1)
            for i = 1, 4 do
                --local angle=105-i*num
                local angle = self.anglelist[int(lstg.var.power / 100) + 1][i]
                if self.sp[i] and self.sp[i][3] > 0.5 then
                    local target = nil
                    local x, y = self.supportx + self.sp[i][1], self.supporty + self.sp[i][2]
                    for j, o in ObjList(GROUP_ENEMY) do
                        if o.colli and IsInLaser(x, y, angle, o, 16) then
                            local d = Dist(o.x, o.y, x, y)
                            if d < self.offset[i] then
                                target = o
                                self.offset[i] = d
                            end
                        end
                    end
                    for j, o in ObjList(GROUP_NONTJT) do
                        if o.colli and IsInLaser(x, y, angle, o, 16) then
                            local d = Dist(o.x, o.y, x, y)
                            if d < self.offset[i] then
                                target = o
                                self.offset[i] = d
                            end
                        end
                    end
                    if target then
                        self.offset[i] = max(0, self.offset[i] - target.b)
                        New(marisa_laser_hit, x + self.offset[i] * cos(angle), y + self.offset[i] * sin(angle))
                        if target.class.base.take_damage then
                            target.class.base.take_damage(target, 0.25)
                        end
                        if target.hp > target.maxhp * 0.1 then
                            PlaySound('damage00', 0.3, target.x / 1024)
                        else
                            PlaySound('damage01', 0.6, target.x / 1024)
                        end
                    end
                end
            end
        end
    end
end

function marisa_player:spell()
    if self.slow == 0 then
        New(player_spell_mask, 0, 0, 255, 30, 210, 30)
        PlaySound('slash', 1.0)
        PlaySound('nep00', 1.0)
        New(marisa_sp_ef, 0)
        New(marisa_sp_ef, 0)
        New(marisa_sp_ef, 120)
        New(marisa_sp_ef, 120)
        New(marisa_sp_ef, 240)
        New(marisa_sp_ef, 240)
        misc.ShakeScreen(210, 3)
        New(tasker, function()
            New(bullet_killer, self.x, self.y)
            local rot = 0
            for i = 1, 120 do
                rot = rot + 3
                for i = 1, 3 do
                    local a = rot + 180 + i * 360 / 3
                    New(player_bullet_hide, 16, 16, self.x, self.y, 12, a, 0.4)
                    for j = 1, 8 do
                        New(player_bullet_hide, 16, 16, self.x, self.y, 12, a + 2.1 * j, 0.8, 2 * j)
                        New(player_bullet_hide, 16, 16, self.x, self.y, 12, a - 2.1 * j, 0.8, 2 * j)
                    end
                end
                task.Wait(2)
            end
            PlaySound('slash', 1.0)
            New(bullet_killer, self.x, self.y)
        end)
        self.nextspell = 240
        self.protect = 360
    else
        self.slowlock = true
        New(player_spell_mask, 255, 255, 0, 30, 240, 30)
        PlaySound('slash', 1.0)
        PlaySound('nep00', 1.0)
        self.nextspell = 300
        self.nextshoot = 300
        self.protect = 360
        New(marisa_spark, self.x, self.y, 90, 30, 240, 30)
        --		self.hspeed=1
        --		self.lspeed=1
        New(tasker, function()
            for i = 1, 27 do
                New(marisa_spark_wave, player.x, player.y - 16, 90, 12, 0.9)
                task.Wait(10)
            end
            New(bullet_killer, self.x, self.y)
            PlaySound('slash', 1.0)
            self.slowlock = false
            --			player.hspeed=5
            --			player.lspeed=2
        end)
        misc.ShakeScreen(270, 5)
    end
end

function marisa_player:render()
    local sz = 1.2 + 0.1 * sin(self.timer * 0.2)
    --support
    SetImageState('marisa_support', '', Color(0xFFFFFFFF))
    for i = 1, 4 do
        if self.sp[i] then
            Render('marisa_support', self.supportx + self.sp[i][1], self.supporty + self.sp[i][2], 0, self.sp[i][3], 1)
        end
    end
    --support deco
    SetImageState('marisa_support', '', Color(0x80FFFFFF))
    for i = 1, 4 do
        if self.sp[i] then
            Render('marisa_support', self.supportx + self.sp[i][1], self.supporty + self.sp[i][2], 0, self.sp[i][3] * sz, sz)
        end
    end
    if self.support > 0 and self.fire == 1 and self.slow == 0 and self.nextshoot <= 0 then
        local num = 30 / (self.support + 1)
        local timer = self.timer * 16
        for i = 1, 4 do
            --local angle=105-i*num
            local angle = self.anglelist[int(lstg.var.power / 100) + 1][i]
            if self.sp[i] and self.sp[i][3] > 0.5 then
                local x, y = self.supportx + self.sp[i][1], self.supporty + self.sp[i][2]
                if self.offset[i] < 600 then
                    CreateLaser(x, y, angle, 16, timer, Color(0x804040FF), self.offset[i])
                    --Render('marisa_laser_hit',x+self.offset[i]*cos(angle),y+self.offset[i]*sin(angle),timer,0.5)
                else
                    CreateLaser(x, y, angle, 16, timer, Color(0x80FFFFFF), 600)
                end
                Render('marisa_laser_light', x, y, self.timer * 5, 1 + 0.4 * sin(self.timer * 45 + i * 90))
            end
        end
    end
    player_class.render(self)
end

---@class THlib.marisa_bullet:THlib.player_bullet_straight
marisa_bullet = Class(player_bullet_straight)

function marisa_bullet:kill()
    New(marisa_bullet_ef, self.x, self.y, self.rot, 3)
    New(marisa_bullet_ef, self.x, self.y, self.rot, 4)
    New(marisa_bullet_ef, self.x, self.y, self.rot, 5)
end

---@class THlib.marisa_missile:THlib.player_bullet_straight
marisa_missile = Class(player_bullet_straight)

function marisa_missile:frame()
    self.vy = min(self.timer / 3 + 3, 12)
end
function marisa_missile:kill()
    PlaySound('msl2', 0.3)
    local a, r = ran:Float(0, 360), ran:Float(0, 6)
    New(marisa_missile_ef, self.x + r * cos(a), self.y + r * sin(a), self.dmg, 5)
end

---@class THlib.marisa_missile_ef:object
marisa_missile_ef = Class(object)

function marisa_missile_ef:init(x, y, dmg, t)
    self.x = x
    self.y = y
    self.a = 4
    self.b = 4
    self.img = 'marisa_missile_ef'
    self.group = GROUP_PLAYER_BULLET
    self.dmg = dmg / 20
    self.killflag = true
    self.layer = LAYER_PLAYER_BULLET
    self.mute = true
    self.t = t
end

function marisa_missile_ef:frame()
    if self.timer == 3 and self.t > 0 then
        local a, r = ran:Float(0, 360), ran:Float(8, 16)
        New(marisa_missile_ef, self.x + r * cos(a), self.y + r * sin(a), self.dmg * 20, self.t - 1)
        --SystemLog('marisa_missile_ef:frame')
    end
    if self.timer == 15 then
        Del(self)
    end
end

---@class THlib.marisa_bullet_ef:object
marisa_bullet_ef = Class(object)

function marisa_bullet_ef:init(x, y, rot, v)
    self.x = x
    self.y = y
    self.rot = rot
    self.vx = v * cos(rot)
    self.vy = v * sin(rot)
    self.img = 'marisa_bullet_ef'
    self.layer = LAYER_PLAYER_BULLET + 50
end

function marisa_bullet_ef:frame()
    if self.timer == 7 then
        Del(self)
    end
end
function marisa_bullet_ef:render()
    SetAnimationState('marisa_bullet_ef', '',
            Color(128 - 8 * self.timer, 255, 255, 255))
    object.render(self)
end

---@class THlib.marisa_laser_hit:object
marisa_laser_hit = Class(object)

function marisa_laser_hit:init(x, y)
    self.x = x
    self.y = y
    self.group = GROUP_GHOST
    self.layer = LAYER_PLAYER_BULLET + 60
    self.img = 'marisa_hit'
end

function marisa_laser_hit:frame()
    if self.timer == 4 then
        ParticleStop(self)
    end
    if self.timer == 10 then
        Del(self)
    end
end

---@class THlib.marisa_sp_ef:object
marisa_sp_ef = Class(object)

function marisa_sp_ef:init(rot)
    self.layer = LAYER_PLAYER - 1
    self.rot = rot
    self.img = 'marisa_sp_ef'
end

function marisa_sp_ef:frame()
    self.x = lstg.player.x
    self.y = lstg.player.y
    self.omiga = 1.5
    if self.timer > 240 then
        ParticleSetEmission(self, ParticleGetEmission(self) - 10)
    end
    if self.timer == 480 then
        Del(self)
    end
end

---@class THlib.marisa_spark:object
marisa_spark = Class(object)

function marisa_spark:init(x, y, rot, turnOnTime, wait, turnOffTime)
    self.x = x
    self.y = y
    self.rot = rot
    self.img = 'marisa_spark'
    self.group = GROUP_GHOST
    self.layer = LAYER_PLAYER_BULLET
    self.hscale = 2.5
    task.New(self, function()
        for i = 0, turnOnTime do
            self.vscale = 2.5 * i / turnOnTime
            task.Wait(1)
        end
        task.Wait(wait)
        for i = 0, turnOffTime do
            self.vscale = 2.5 * (1 - i / turnOffTime)
            task.Wait(1)
        end
        Del(self)
    end)
end

function marisa_spark:frame()
    task.Do(self)
    self.x = player.x
    self.y = player.y
end

---@class THlib.marisa_spark_wave:object
marisa_spark_wave = Class(object)

function marisa_spark_wave:init(x, y, rot, v, dmg)
    self.x = x
    self.y = y
    self.rot = rot
    self.img = 'marisa_spark_wave'
    self.group = GROUP_PLAYER_BULLET
    self.layer = LAYER_PLAYER_BULLET
    self.vx = v * cos(rot)
    self.vy = v * sin(rot)
    self.dmg = dmg
    self.rect = true
    self.killflag = true
end

function marisa_spark_wave:frame()
    self.x = player.x
    self.vscale = min(1.5, self.timer / 10)
    self.hscale = self.vscale
    New(bomb_bullet_killer, self.x, self.y, 100, 100, false)
end

function IsInLaser(x0, y0, a, unit, w)
    local a1 = a - Angle(x0, y0, unit.x, unit.y)
    if a % 180 == 90 then
        if abs(unit.x - x0) < ((unit.a + unit.b + w) / 2) and cos(a1) >= 0 then
            return true
        else
            return false
        end
    else
        local A = tan(a)
        local C = y0 - A * x0
        if abs(A * unit.x - unit.y + C) / hypot(A, 1) < ((unit.a + unit.b + w) / 2) and cos(a1) >= 0 then
            return true
        else
            return false
        end
    end
end

function CreateLaser(x, y, a, w, t, c, offset)
    local width = w / 2
    local n = int(offset / 256)
    local length = t % 256
    local endl = int(offset - n * 256)

    local w_x = width * cos(a)
    local w_y = width * sin(a)
    local tex = 'MarisaLaser'
    local blend = 'mul+add'

    for i = 1, n do
        local vx1 = x + (length + 256 * (i - 1)) * cos(a)
        local vy1 = y + (length + 256 * (i - 1)) * sin(a)
        local vx2 = x + 256 * i * cos(a)
        local vy2 = y + 256 * i * sin(a)
        local vx3 = x + 256 * (i - 1) * cos(a)
        local vy3 = y + 256 * (i - 1) * sin(a)
        RenderTexture(
                tex, blend,
                { vx1 - w_y, vy1 + w_x, 0.5, 0, 0, c },
                { vx2 - w_y, vy2 + w_x, 0.5, 256 - length, 0, c },
                { vx2 + w_y, vy2 - w_x, 0.5, 256 - length, 16, c },
                { vx1 + w_y, vy1 - w_x, 0.5, 0, 16, c })
        RenderTexture(
                tex, blend,
                { vx3 - w_y, vy3 + w_x, 0.5, 256 - length, 0, c },
                { vx1 - w_y, vy1 + w_x, 0.5, 256, 0, c },
                { vx1 + w_y, vy1 - w_x, 0.5, 256, 16, c },
                { vx3 + w_y, vy3 - w_x, 0.5, 256 - length, 16, c })
    end

    local vx2 = x + (endl + 256 * n) * cos(a)
    local vy2 = y + (endl + 256 * n) * sin(a)
    local vx3 = x + 256 * n * cos(a)
    local vy3 = y + 256 * n * sin(a)
    if length <= endl then
        local vx1 = x + (length + 256 * n) * cos(a)
        local vy1 = y + (length + 256 * n) * sin(a)
        RenderTexture(
                tex, blend,
                { vx1 - w_y, vy1 + w_x, 0.5, 0, 0, c },
                { vx2 - w_y, vy2 + w_x, 0.5, endl - length, 0, c },
                { vx2 + w_y, vy2 - w_x, 0.5, endl - length, 16, c },
                { vx1 + w_y, vy1 - w_x, 0.5, 0, 16, c })
        RenderTexture(
                tex, blend,
                { vx3 - w_y, vy3 + w_x, 0.5, 256 - length, 0, c },
                { vx1 - w_y, vy1 + w_x, 0.5, 256, 0, c },
                { vx1 + w_y, vy1 - w_x, 0.5, 256, 16, c },
                { vx3 + w_y, vy3 - w_x, 0.5, 256 - length, 16, c })
    else
        RenderTexture(
                tex, blend,
                { vx3 - w_y, vy3 + w_x, 0.5, 256 - length, 0, c },
                { vx2 - w_y, vy2 + w_x, 0.5, endl + 256 - length, 0, c },
                { vx2 + w_y, vy2 - w_x, 0.5, endl + 256 - length, 16, c },
                { vx3 + w_y, vy3 - w_x, 0.5, 256 - length, 16, c })
    end
end
