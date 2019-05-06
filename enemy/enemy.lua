--

local int = int
local abs = abs
local sin = sin
local cos = cos
local task = task
local Kill = Kill
local Color = Color
local New = New
local SetAttr = SetAttr
local IsValid = IsValid
local PlaySound = PlaySound
local SetImageState = SetImageState
local Render = Render

LoadTexture('enemy1', 'THlib/enemy/enemy1.png')
--小妖精
LoadImageGroup('enemy1_', 'enemy1', 0, 384, 32, 32, 12, 1, 8, 8)--红
LoadImageGroup('enemy2_', 'enemy1', 0, 416, 32, 32, 12, 1, 8, 8)--绿
LoadImageGroup('enemy3_', 'enemy1', 0, 448, 32, 32, 12, 1, 8, 8)--蓝
LoadImageGroup('enemy4_', 'enemy1', 0, 480, 32, 32, 12, 1, 8, 8)--黄
--女仆妖精
LoadImageGroup('enemy5_', 'enemy1', 0, 0, 48, 32, 4, 3, 8, 8)--蓝
LoadImageGroup('enemy6_', 'enemy1', 0, 96, 48, 32, 4, 3, 8, 8)--红
--大妖精
LoadImageGroup('enemy7_', 'enemy1', 320, 0, 48, 48, 4, 3, 16, 16)--棕
LoadImageGroup('enemy8_', 'enemy1', 320, 144, 48, 48, 4, 3, 16, 16)--青
--大蝴蝶
LoadImageGroup('enemy9_', 'enemy1', 0, 192, 64, 64, 4, 3, 16, 16)--白

LoadImageGroup('kedama', 'enemy1', 256, 320, 32, 32, 2, 2, 8, 8)
LoadImageGroup('enemy_x', 'enemy1', 192, 32, 32, 32, 4, 1, 8, 8)

LoadImageGroup('enemy_orb', 'enemy1', 192, 64, 32, 32, 4, 1, 8, 8)
LoadImageGroup('enemy_orb_ring', 'enemy1', 192, 96, 32, 32, 4, 1)
for i = 1, 4 do
    SetImageState('enemy_orb_ring' .. i, 'add+add', Color(0xFF404040))
end
LoadImageGroup('enemy_aura', 'enemy1', 192, 32, 32, 32, 4, 1)
for i = 1, 4 do
    SetImageState('enemy_aura' .. i, '', Color(0x80FFFFFF))
end

LoadTexture('enemy2', 'THlib/enemy/enemy2.png')
--小妖精
LoadImageGroup('enemy10_', 'enemy2', 0, 0, 32, 32, 12, 1, 8, 8)--蓝
LoadImageGroup('enemy11_', 'enemy2', 0, 32, 32, 32, 12, 1, 8, 8)--红
LoadImageGroup('enemy12_', 'enemy2', 0, 64, 32, 32, 12, 1, 8, 8)--黄
LoadImageGroup('enemy13_', 'enemy2', 0, 96, 32, 32, 12, 1, 8, 8)--紫
--大蝴蝶
LoadImageGroup('enemy14_', 'enemy2', 0, 128, 64, 64, 6, 2, 16, 16)--黑
--小妖精
LoadImageGroup('enemy15_', 'enemy2', 0, 288, 32, 32, 12, 1, 8, 8)--蓝
LoadImageGroup('enemy16_', 'enemy2', 0, 352, 32, 32, 12, 1, 8, 8)--红
LoadImageGroup('enemy17_', 'enemy2', 0, 416, 32, 32, 12, 1, 8, 8)--绿
LoadImageGroup('enemy18_', 'enemy2', 0, 480, 32, 32, 12, 1, 8, 8)--黄

LoadPS('ghost_fire_r', 'THlib/enemy/ghost_fire_r.psi', 'parimg1', 8, 8)
LoadPS('ghost_fire_b', 'THlib/enemy/ghost_fire_b.psi', 'parimg1', 8, 8)
LoadPS('ghost_fire_g', 'THlib/enemy/ghost_fire_g.psi', 'parimg1', 8, 8)
LoadPS('ghost_fire_y', 'THlib/enemy/ghost_fire_y.psi', 'parimg1', 8, 8)

LoadTexture('enemy3', 'THlib/enemy/enemy3.png')
LoadImageGroup('Ghost1', 'enemy3', 0, 0, 32, 32, 8, 1, 8, 8)--红
LoadImageGroup('Ghost3', 'enemy3', 0, 32, 32, 32, 8, 1, 8, 8)--绿
LoadImageGroup('Ghost2', 'enemy3', 0, 64, 32, 32, 8, 1, 8, 8)--蓝
LoadImageGroup('Ghost4', 'enemy3', 0, 96, 32, 32, 8, 1, 8, 8)--黄

local __mt = ObjTable().mt

---@class THlib.enemybase:object
enemybase = Class(object)

function enemybase:init(hp, nontaijutsu)
    self.layer = LAYER_ENEMY
    self.group = GROUP_ENEMY
    if nontaijutsu then
        self.group = GROUP_NONTJT
    end
    self.bound = false
    self.colli = false
    self.maxhp = hp or 1
    self.hp = hp or 1
    setmetatable(self, { __index = __mt.__index, __newindex = enemy_meta_newindex })
    -- => self._colli=true
    self.colli = true
    self._servants = {}
end

function enemy_meta_newindex(t, k, v)
    --修改 colli 属性时改为修改 _colli 属性
    if k == 'colli' then
        rawset(t, '_colli', v)
    else
        __mt.__newindex(t, k, v)
    end
end

function enemybase:frame()
    SetAttr(self, 'colli', BoxCheck(self, lstg.world.boundl, lstg.world.boundr, lstg.world.boundb, lstg.world.boundt) and self._colli)
    if self.hp <= 0 then
        Kill(self)
    end
    task.Do(self)
end

function enemybase:colli(other)
    if other.dmg then
        lstg.var.score = lstg.var.score + 10
        Damage(self, other.dmg)
        if self._master and self._dmg_transfer and IsValid(self._master) then
            --向master传递伤害
            Damage(self._master, other.dmg * self._dmg_transfer)
        end
    end
    other.killerenemy = self
    if not (other.killflag) then
        Kill(other)
        --if other.class['.classname'] then
        --    Print('kill ' .. other.class['.classname'])
        --else
        --    Print('kill '..tostring(other.class))
        --end
    end
    if not other.mute then
        --受击时播放声音
        if self.dmg_factor then
            if self.hp > 100 then
                PlaySound('damage00', 0.4, self.x / 200)
            else
                PlaySound('damage01', 0.6, self.x / 200)
            end
        else
            if self.hp > 60 then
                if self.hp > self.maxhp * 0.2 then
                    PlaySound('damage00', 0.4, self.x / 200)
                else
                    PlaySound('damage01', 0.6, self.x / 200)
                end
            else
                PlaySound('damage00', 0.35, self.x / 200, true)
            end
        end
    end
end

function enemybase:del()
    _del_servants(self)
end

---执行obj.class.base.take_damage(obj,dmg)
function Damage(obj, dmg)
    local take_damage = obj.class.base.take_damage
    if take_damage then
        take_damage(obj, dmg)
    end
end

---@class THlib.enemy:THlib.enemybase
enemy = Class(enemybase)
-- 1 2 3 4 -> 红 绿 蓝 黄
_enemy_aura_tb = { 1, 2, 3, 4, 3, 1, nil, nil, nil, 3, 1, 4, 1, nil, 3, 1, 2, 4, 3, 1, 2, 4, 1, 2, 3, 4, nil, nil, nil, nil, 1, 3, 2, 1 }
_death_ef_tb = { 1, 2, 3, 4, 3, 1, 1, 2, 1, 3, 1, 4, 1, 1, 3, 1, 2, 4, 3, 1, 2, 4, 1, 2, 3, 4, 1, 3, 2, 4, 1, 3, 2, 4 }
local _enemy_aura_tb = _enemy_aura_tb
local _death_ef_tb = _death_ef_tb

function enemy:init(style, hp, clear_bullet, auto_delete, nontaijutsu)
    enemybase.init(self, hp, nontaijutsu)
    self.clear_bullet = clear_bullet
    self.auto_delete = auto_delete
    self.style = style
    self.aura = _enemy_aura_tb[style]
    self.death_ef = _death_ef_tb[style]
    if style <= 18 then
        self.imgs = {}
        for i = 1, 12 do
            self.imgs[i] = 'enemy' .. style .. '_' .. i
        end
        self.ani_intv = 8
        self.lr = 1
    elseif style <= 22 then
        self.img = 'kedama' .. (style - 18)
        self.omiga = 12
    elseif style <= 26 then
        self.img = 'enemy_orb' .. (style - 22)
        self.omiga = 6
    elseif style == 27 or style == 31 then
        self.img = 'ghost_fire_r'
        self.rot = -90
    elseif style == 28 or style == 32 then
        self.img = 'ghost_fire_b'
        self.rot = -90
    elseif style == 29 or style == 33 then
        self.img = 'ghost_fire_g'
        self.rot = -90
    elseif style == 30 or style == 34 then
        self.img = 'ghost_fire_y'
        self.rot = -90
    end
end

function enemy:frame()
    enemybase.frame(self)
    if self.style <= 18 then
        --根据移动方向和速度决定播放哪一帧
        local dx
        if self.dx > 0.5 then
            dx = 1
        elseif self.dx < -0.5 then
            dx = -1
        else
            dx = 0
        end
        self.lr = self.lr + dx
        if self.lr > 18 then
            self.lr = 18
        end
        if self.lr < -18 then
            self.lr = -18
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
        if abs(self.lr) == 1 then
            self.img = self.imgs[int(self.ani / self.ani_intv) % 4 + 1]
        elseif abs(self.lr) == 18 then
            self.img = self.imgs[int(self.ani / self.ani_intv) % 4 + 9]
        else
            self.img = self.imgs[int((abs(self.lr) - 2) / 4) + 5]
        end
        self.hscale = sign(self.lr)--朝右移动则不翻转，朝左移动则翻转
    end
    if self.auto_delete and BoxCheck(self, lstg.world.boundl, lstg.world.boundr, lstg.world.boundb, lstg.world.boundt) then
        self.bound = true
    end
end

function enemy:render()
    if self._blend then
        --混合颜色
        SetImgState(self, self._blend, self._a, self._r, self._g, self._b)
    end
    if self.aura then
        --渲染aura
        if self._blend then
            SetImageState('enemy_aura' .. self.aura, '', Color(self._a, self._r, self._g, self._b))
        end
        Render('enemy_aura' .. self.aura, self.x, self.y, self.timer * 3, 1.25 + 0.15 * sin(self.timer * 6))
    end

    object.render(self)

    --阴阳玉
    if self.style > 22 and self.style <= 26 then
        --渲染圆环
        if self._blend then
            SetImageState('enemy_orb_ring' .. self.aura, 'mul+add', Color(self._a, self._r, self._g, self._b))
        end
        Render('enemy_orb_ring' .. self.aura, self.x, self.y, -self.timer * 6)
        Render('enemy_orb_ring' .. self.aura, self.x, self.y, self.timer * 4, 1.4)
    end

    --鬼火
    if self.style > 27 and self.style <= 30 then
        if self._blend then
            SetImageState('Ghost' .. (self.style - 26) .. int((self.timer / 4) % 8) + 1, '', Color(self._a, self._r, self._g, self._b))
        end
        Render('Ghost' .. (self.style - 26) .. int((self.timer / 4) % 8) + 1, self.x, self.y, 90)
    end
    if self.style > 30 then
        if self._blend then
            SetImageState('Ghost' .. (self.style - 30) .. int((self.timer / 4) % 8) + 1, '', Color(self._a, self._r, self._g, self._b))
        end
        Render('Ghost' .. (self.style - 30) .. int((self.timer / 4) % 8) + 1, self.x, self.y, 90)
    end
    if self._blend then
        SetImgState(self, 'mul+add', 255, 255, 255, 255)
    end
end

function enemy:take_damage(dmg)
    if not self.protect then
        self.hp = self.hp - dmg
    end
end

function enemy:kill()
    New(enemy_death_ef, self.death_ef, self.x, self.y)
    --掉落道具
    if self.drop then
        item.DropItem(self.x, self.y, self.drop)
    end
    --消弹
    if self.clear_bullet then
        New(bullet_killer, lstg.player.x, lstg.player.y, false)
    end
    _kill_servants(self)
end

---击破效果
---@class THlib.enemy_death_ef:object
enemy_death_ef = Class(object)

function enemy_death_ef:init(index, x, y)
    self.img = 'bubble' .. index
    self.layer = LAYER_ENEMY + 50
    self.group = GROUP_GHOST
    self.x = x
    self.y = y
    self.rot = 45
    PlaySound('enep00', 0.3, self.x / 200, true)
end

function enemy_death_ef:render()
    local alpha = 1 - self.timer / 30
    alpha = 255 * alpha ^ 2
    --逐渐透明
    SetImageState(self.img, '', Color(alpha, 255, 255, 255))
    --绘制三个椭圆，逐渐拉长
    Render(self.img, self.x, self.y, 15, 0.4 - self.timer * 0.01, self.timer * 0.1 + 0.7)
    Render(self.img, self.x, self.y, 75, 0.4 - self.timer * 0.01, self.timer * 0.1 + 0.7)
    Render(self.img, self.x, self.y, 135, 0.4 - self.timer * 0.01, self.timer * 0.1 + 0.7)
end

function enemy_death_ef:frame()
    if self.timer == 30 then
        Kill(self)
    end
end

Include 'THlib/enemy/boss.lua'

---@class THlib.EnemySimple:THlib.enemy
EnemySimple = Class(enemy)

--- 初始化EnemySimple对象
---@param style number 类型 1-34
---@param hp number 血量
---@param x number
---@param y number 位置
---@param drop table 道具数量 {红,绿,蓝}
---@param pro number 保护时间（帧）
---@param clr boolean 是否消弹
---@param bound boolean 是否执行出屏检查（自动销毁）
---@param tjt boolean 是否无体术判定
---@param tf function 创建对象后执行的函数
function EnemySimple:init(style, hp, x, y, drop, pro, clr, bound, tjt, tf)
    enemy.init(self, style, hp, clr, bound, tjt)
    self.x, self.y = x, y
    self.drop = drop
    task.New(self, function()
        self.protect = true
        task.Wait(pro)
        self.protect = false
    end)
    tf(self)
end
