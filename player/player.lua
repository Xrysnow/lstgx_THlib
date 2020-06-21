---=====================================
---player
---=====================================
player_lib = {}
local player_lib = player_lib
local LOG_MODULE_NAME = "[lstg][THlib][player]"

----------------------------------------
---加载资源
LoadPS("player_death_ef", "THlib\\player\\player_death_ef.psi", "parimg1")
LoadPS("graze", "THlib\\player\\graze.psi", "parimg6")
LoadImageFromFile("player_spell_mask", "THlib\\player\\spellmask.png")
Include("THlib\\player\\player_system.lua")

----------------------------------------
---player class
---@class player
player_class = Class(object)
local player_class = player_class

player_lib.player_class = player_class

function player_class:init(slot)
    self.group = GROUP_PLAYER
    self.layer = LAYER_PLAYER
    self.bound = false
    self.y = -176
    self._wisys = PlayerWalkImageSystem(self) --by OLC，自机行走图系统
    self._playersys = player_lib.system(self, slot) --by OLC，自机逻辑系统
    lstg.player = self
    player = self
    if not lstg.var.init_player_data then
        error("Player data has not been initialized. (Call function item.PlayerInit.)")
    end
end

function player_class:frame()
    self._playersys:doFrameBeforeEvent()
    self._playersys:frame()
    self._playersys:doFrameAfterEvent()
end

function player_class:render()
    self._playersys:doRenderBeforeEvent()
    self._playersys:render()
    self._playersys:doRenderAfterEvent()
end

function player_class:colli(other)
    self._playersys:doColliBeforeEvent(other)
    self._playersys:colli(other)
    self._playersys:doColliBeforeEvent(other)
end

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
    for i, o in ObjList(GROUP_NONTJT) do
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

function MixTable(x, t1, t2)
    --子机位置表的线性插值
    r = {}
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

grazer = Class(object)

function grazer:init(player)
    self.layer = LAYER_ENEMY_BULLET_EF + 50
    self.group = GROUP_PLAYER
    self.player = player or lstg.player
    --self.player=lstg.player
    self.grazed = false
    self.img = "graze"
    ParticleStop(self)
    self.a = 24
    self.b = 24
    self.aura = 0
    self.aura_d = 0
    self.log_state = self.player.slow
    self._slowTimer = 0
    self._pause = 0
end

function grazer:frame()
    local p = self.player
    local alive = (p.death == 0 or p.death > 90)
    if alive then
        self.x = p.x
        self.y = p.y
        self.hide = p.hide
    end
    if not p.time_stop then
        if alive then
            if self.log_state ~= p.slow then
                self.log_state = p.slow
                self._pause = 30
            end
        end
        if p.slow == 1 then
            self._slowTimer = min(self._slowTimer + 1, 30)
        else
            self._slowTimer = 0
        end
        if self._pause == 0 then
            self.aura = self.aura + 1.5
        end
        self._pause = max(0, self._pause - 1)
        self.aura_d = 180 * cos(90 * self._slowTimer / 30) ^ 2
    end
    --
    if self.grazed then
        PlaySound("graze", 0.3, self.x / 200)
        self.grazed = false
        ParticleFire(self)
    else
        ParticleStop(self)
    end
end

function grazer:render()
    object.render(self)
    SetImageState("player_aura", "", Color(0xC0FFFFFF))
    Render("player_aura", self.x, self.y, -self.aura + self.aura_d, self.player.lh)
    SetImageState("player_aura", "", Color(0xC0FFFFFF) * self.player.lh + Color(0x00FFFFFF) * (1 - self.player.lh))
    Render("player_aura", self.x, self.y, self.aura, 2 - self.player.lh)
end

function grazer:colli(other)
    if other.group ~= GROUP_ENEMY and (not (other._graze) or other._inf_graze) then
        item.PlayerGraze()
        self.grazed = true
        if not (other._inf_graze) then
            other._graze = true
        end
    end
end

death_weapon = Class(object)

function death_weapon:init(x, y)
    self.x = x
    self.y = y
    self.group = GROUP_GHOST
    self.hide = true
end

function death_weapon:frame()
    if self.timer >= 90 then
        Del(self)
    end
    for i, o in ObjList(GROUP_ENEMY) do
        if o.colli == true then
            if Dist(self, o) < 800 and self.timer > 60 then
                Damage(o, 0.75)
                if o.dmgsound == 1 then
                    if o.dmg_factor then
                        if o.hp > 100 then
                            PlaySound('damage00', 0.3, o.x / 200)
                        else
                            PlaySound('damage01', 0.6, o.x / 200)
                        end
                    else
                        if o.hp > o.maxhp * 0.2 then
                            PlaySound('damage00', 0.3, o.x / 200)
                        else
                            PlaySound('damage01', 0.8, o.x / 200)
                        end
                    end
                end
            end
        end
    end
    for i, o in ObjList(GROUP_NONTJT) do
        if o.colli == true then
            if Dist(self, o) < 800 and self.timer > 60 then
                Damage(o, 0.75)
                if o.dmgsound == 1 then
                    if o.dmg_factor then
                        if o.hp > 100 then
                            PlaySound('damage00', 0.3, o.x / 200)
                        else
                            PlaySound('damage01', 0.6, o.x / 200)
                        end
                    else
                        if o.hp > o.maxhp * 0.2 then
                            PlaySound('damage00', 0.3, o.x / 200)
                        else
                            PlaySound('damage01', 0.8, o.x / 200)
                        end
                    end
                end
            end
        end
    end
end

----------------------------------------
---一些自机组件

player_bullet_straight = Class(object)

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

player_spell_mask = Class(object)

function player_spell_mask:init(r, g, b, t1, t2, t3)
    self.x = 0
    self.y = 0
    self.group = GROUP_GHOST
    self.layer = LAYER_BG + 1
    self.img = "player_spell_mask"
    self.bcolor = { ["blend"] = "mul+add", ["a"] = 0, ["r"] = r, ["g"] = g, ["b"] = b }
    task.New(self, function()
        for i = 1, t1 do
            self.bcolor.a = i * 255 / t1
            task.Wait(1)
        end
        task.Wait(t2)
        for i = t3, 1, -1 do
            self.bcolor.a = i * 255 / t3
            task.Wait(1)
        end
        Del(self)
    end)
end

function player_spell_mask:frame()
    task.Do(self)
end

function player_spell_mask:render()
    local w = lstg.world
    local c = self.bcolor
    SetImageState(self.img, c.blend, Color(c.a, c.r, c.g, c.b))
    RenderRect(self.img, w.l, w.r, w.b, w.t)
end

player_death_ef = Class(object)

function player_death_ef:init(x, y)
    self.x = x
    self.y = y
    self.img = "player_death_ef"
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
        if self.type == "second" then
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
    --稍微减少了死亡反色圈的分割数，视觉效果基本不变，减少性能消耗（原分割数为180）
    if self.type == "first" then
        rendercircle(self.x, self.y, self.size, 60)
        rendercircle(self.x + 35, self.y + 35, self.size1, 60)
        rendercircle(self.x + 35, self.y - 35, self.size1, 60)
        rendercircle(self.x - 35, self.y + 35, self.size1, 60)
        rendercircle(self.x - 35, self.y - 35, self.size1, 60)
    elseif self.type == "second" then
        rendercircle(self.x, self.y, self.size, 60)
    end
end

----------------------------------------
---加载自机

---player列表
---{显示名, 类名(score用), 简称(rep显示用)}
---@class THlib.player_list
player_list = {
    { "Hakurei Reimu", "reimu_player", "Reimu" },
    { "Kirisame Marisa", "marisa_player", "Marisa" },
    --{ "Kirisame Marisa", "sakuya_player", "Sakuya" },
}

Include("THlib/player/reimu.lua")
Include("THlib/player/marisa.lua")
--Include("THlib/player/sakuya.lua")
