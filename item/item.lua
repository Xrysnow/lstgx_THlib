--

LoadTexture('item', 'THlib\\item\\item.png')
--道具
LoadImageGroup('item', 'item', 0, 0, 32, 32, 2, 5, 8, 8)
--三角形指示 道具超出屏幕上方时使用
LoadImageGroup('item_up', 'item', 64, 0, 32, 32, 2, 5)
SetImageState('item8', 'mul+add', Color(0xC0FFFFFF))
LoadTexture('bonus1', 'THlib\\item\\item.png')
LoadTexture('bonus2', 'THlib\\item\\item.png')
LoadTexture('bonus3', 'THlib\\item\\item.png')

local rawset = rawset
local rawget = rawget
local int = math.floor
local max = math.max
local min = math.min
local sqrt = sqrt
local ran = ran
local cos = cos
local sin = sin
local New = New
local Del = Del
local Render = Render
local Color = Color
local BoxCheck = BoxCheck

---@class THlib.item:object 道具类
---@field sc_bonus_max number
---@field sc_bonus_base number
item = Class(object)

---
---x,y：位置 x会被限制在屏幕内
---t：资源序号
---v：移动速度 默认1.5
---angle：移动方向 默认90（向上）
function item:init(x, y, t, v, angle)
    x = min(max(x, lstg.world.l + 8), lstg.world.r - 8)
    self.x = x
    self.y = y
    angle = angle or 90
    v = v or 1.5
    SetV(self, v, angle)
    self.v = v
    self.group = GROUP_ITEM
    self.layer = LAYER_ITEM
    self.bound = false
    self.img = 'item' .. t
    self.imgup = 'item_up' .. t
    self.attract = 0
end

function item:render()
    local t = lstg.world.t
    if self.y > t then
        Render(self.imgup, self.x, t - 8)
    else
        object.render(self)
    end
end

function item:frame()
    if self.timer < 24 then
        --旋转变大
        self.rot = self.rot + 45
        self.hscale = (self.timer + 25) / 48
        self.vscale = self.hscale
        --限制速度
        if self.timer == 22 then
            self.vy = min(self.v, 2)
            self.vx = 0
        end
    elseif self.attract > 0 then
        --被自机吸引
        local a = Angle(self, player)
        self.vx = self.attract * cos(a) + player.dx * 0.5
        self.vy = self.attract * sin(a) + player.dy * 0.5
    else
        --加速度向下
        self.vy = max(self.dy - 0.03, -1.7)
    end
    if self.y < lstg.world.boundb then
        Del(self)
    end
end

function item:colli(other)
    if other == player then
        if self.class.collect then
            self.class.collect(self)
        end
        Kill(self)
        PlaySound('item00', 0.3, self.x / 200)
    end
end

---
---产生道具掉落
---x,y：位置
---drop：道具数量 {红,绿,蓝}
function item.DropItem(x, y, drop)
    local m
    if lstg.var.power == 400 then
        m = drop[1]
    elseif drop[1] >= 400 then
        m = drop[1]
    else
        m = drop[1] / 100 + drop[1] % 100
    end
    local n = m + drop[2] + drop[3]
    if n < 1 then
        return
    end
    --掉落总数越大越分散，近似在圆形中均匀分布
    local r = sqrt(n - 1) * 5
    --if lstg.var.power==500 then drop[2]=drop[2]+drop[1] drop[1]=0 end
    if drop[1] >= 400 then
        --合并400个小P点为F点
        local r2 = sqrt(ran:Float(1, 4)) * r
        local a = ran:Float(0, 360)
        New(item_power_full, x + r2 * cos(a), y + r2 * sin(a))
    else
        --合并100个小P点为大P点
        drop[4] = drop[1] / 100
        drop[1] = drop[1] % 100
        for i = 1, drop[4] do
            local r2 = sqrt(ran:Float(1, 4)) * r
            local a = ran:Float(0, 360)
            New(item_power_large, x + r2 * cos(a), y + r2 * sin(a))
        end
        for i = 1, drop[1] do
            local r2 = sqrt(ran:Float(1, 4)) * r
            local a = ran:Float(0, 360)
            New(item_power, x + r2 * cos(a), y + r2 * sin(a))
        end
    end
    for i = 1, drop[2] do
        local r2 = sqrt(ran:Float(1, 4)) * r
        local a = ran:Float(0, 360)
        New(item_faith, x + r2 * cos(a), y + r2 * sin(a))
    end
    for i = 1, drop[3] do
        local r2 = sqrt(ran:Float(1, 4)) * r
        local a = ran:Float(0, 360)
        New(item_point, x + r2 * cos(a), y + r2 * sin(a))
    end
end

item.sc_bonus_max = 2000000
item.sc_bonus_base = 1000000

---重置碎片奖励标志
function item.StartChipBonus()
    lstg.var.chip_bonus = true
    lstg.var.bombchip_bonus = true
end

---
---碎片奖励结算（默认）
function item.EndChipBonus(x, y)
    if lstg.var.chip_bonus and lstg.var.bombchip_bonus then
        --同时奖励时并排分开
        New(item_chip, x - 20, y)
        New(item_bombchip, x + 20, y)
    else
        if lstg.var.chip_bonus then
            New(item_chip, x, y)
        end
        if lstg.var.bombchip_bonus then
            New(item_bombchip, x, y)
        end
    end
end

---初始化自机信息（道具相关）
function item.PlayerInit()
    lstg.var.power = 100
    lstg.var.lifeleft = 2
    lstg.var.bomb = 3
    lstg.var.bonusflag = 0
    lstg.var.chip = 0
    lstg.var.faith = 0
    lstg.var.graze = 0
    lstg.var.score = 0
    lstg.var.bombchip = 0
    lstg.var.coun_num = 0
    lstg.var.pointrate = item.PointRateFunc(lstg.var)
    lstg.var.block_spell = false
    lstg.var.chip_bonus = false
    lstg.var.bombchip_bonus = false
    lstg.var.init_player_data = true
end
------------------------------------------

---重置部分自机信息（道具相关）
function item.PlayerReinit()
    lstg.var.power = 400
    lstg.var.lifeleft = 2
    lstg.var.chip = 0
    lstg.var.bomb = 2
    lstg.var.bomb_chip = 0
    lstg.var.block_spell = false
    lstg.var.init_player_data = true
    lstg.var.coun_num = min(9, lstg.var.coun_num + 1)
    lstg.var.score = lstg.var.coun_num
    --if lstg.var.score % 10 ~= 9 then item.AddScore(1) end
end
------------------------------------------

---HZC的收点系统
function item.playercollect(z)
    New(tasker, function()
        local Z = 0.5 + 0.03 * (z - 30)
        local var = lstg.var
        if z >= 30 and z < 80 then
            if lstg.var.bonusflag == 4 then
                task.Wait(45)
                local x = player.x
                local y = player.y
                PlaySound('pin00', 0.8)
                task.Wait(15)
                New(float_text, 'bonus', string.format('BONUS %.1f', Z),
                    x, y + 70, 0, 90, 120, 0.5, 0.5, Color(0xF033CC70), Color(0x0033CC70))
                New(float_text, 'bonus', string.format('%d', Z * z * var.pointrate),
                    x, y + 60, 0, 90, 120, 0.5, 0.5, Color(0xF033CC70), Color(0x0033CC70))
                var.score = var.score + var.pointrate * Z * z
                task.Wait(30)
                New(item_chip, x, y, 3, 90)
                lstg.var.bonusflag = 0
            else
                task.Wait(45)
                local x = player.x
                local y = player.y
                PlaySound('pin00', 0.8)
                task.Wait(15)
                New(float_text, 'bonus', string.format('BONUS %.1f', Z),
                    x, y + 70, 0, 90, 120, 0.5, 0.5, Color(0xF033CC70), Color(0x0033CC70))
                New(float_text, 'bonus', string.format('%d', Z * z * var.pointrate),
                    x, y + 60, 0, 90, 120, 0.5, 0.5, Color(0xF033CC70), Color(0x0033CC70))
                var.score = var.score + var.pointrate * Z * z
                task.Wait(30)
                New(item_bombchip, x, y, 3, 90)
                lstg.var.bonusflag = lstg.var.bonusflag + 1
            end
        elseif z > 0 and z < 30 then
            local x = player.x
            local y = player.y
            task.Wait(15)
            New(float_text, 'bonus', 'NO BONUS',
                x, y + 60, 0, 90, 120, 0.5, 0.5, Color(0xF0808080), Color(0x00808080))
        elseif z >= 80 then
            task.Wait(45)
            local x = player.x
            local y = player.y
            PlaySound('pin00', 0.8)
            task.Wait(15)
            New(float_text, 'bonus', 'BONUS 2.0',
                x, y + 70, 0, 90, 120, 0.5, 0.5, Color(0xF0FFFF00), Color(0x00FFFF00))
            New(float_text, 'bonus', string.format('%d', 2 * z * var.pointrate),
                x, y + 60, 0, 90, 120, 0.5, 0.5, Color(0xF0FFFF00), Color(0x00FFFF00))
            var.score = var.score + var.pointrate * 2 * z
            task.Wait(30)
            New(item_chip, x, y, 3, 90)
        end
        z = 0
    end)

end
-----------------------------

---处理Miss（道具相关）
function item.PlayerMiss()
    lstg.var.chip_bonus = false
    if lstg.var.sc_bonus then
        lstg.var.sc_bonus = 0
    end
    player.protect = 360
    lstg.var.lifeleft = lstg.var.lifeleft - 1
    lstg.var.power = math.max(lstg.var.power - 50, 100)
    lstg.var.bomb = 3
    if lstg.var.lifeleft > 0 then
        for i = 1, 7 do
            local a = 90 + (i - 4) * 18 + player.x * 0.26
            New(item_power, player.x, player.y + 10, 3, a)
        end
    else
        New(item_power_full, player.x, player.y + 10)
    end
end

---处理Bomb（道具相关）
function item.PlayerSpell()
    if lstg.var.sc_bonus then
        lstg.var.sc_bonus = 0
    end
    lstg.var.bombchip_bonus = false
end

---处理擦弹（道具相关）
---擦弹数+1 分数+50
function item.PlayerGraze()
    lstg.var.graze = lstg.var.graze + 1
    lstg.var.score = lstg.var.score + 50
end

---计算最大得点
function item.PointRateFunc(var)
    local r = 10000 + int(var.graze / 10) * 10 + int(lstg.var.faith / 10) * 10
    return r
end

---
---获得P点时增加Power
---v：点数 单位为1
function GetPower(v)
    local before = int(lstg.var.power / 100)
    lstg.var.power = min(400, lstg.var.power + v)
    local after = int(lstg.var.power / 100)
    if after > before then
        PlaySound('powerup1', 0.5)
    end
    if lstg.var.power >= 400 then
        lstg.var.score = lstg.var.score + v * 100
    end
    --if lstg.var.power==500 then
    --    for i,o in ObjList(GROUP_ITEM) do
    --        if o.class==item_power or o.class==item_power_large then
    --            o.class=item_faith
    --            o.img='item5'
    --            o.imgup='item_up5'
    --            New(bubble,'parimg12',o.x,o.y,16,0.5,1,Color(0xFF00FF00),Color(0x0000FF00),LAYER_ITEM+50)
    --        end
    --    end
    --end
end

---P点（小）
---@class THlib.item_power:object
item_power = Class(item)

function item_power:init(x, y, v, a)
    item.init(self, x, y, 1, v, a)
end
function item_power:collect()
    GetPower(1)
end

---P点（大）
---@class THlib.item_power_large:object
item_power_large = Class(item)

function item_power_large:init(x, y, v, a)
    item.init(self, x, y, 6, v, a)
end
function item_power_large:collect()
    GetPower(100)
end

---F点
---@class THlib.item_power_full:object
item_power_full = Class(item)

function item_power_full:init(x, y)
    item.init(self, x, y, 4)
end
function item_power_full:collect()
    GetPower(400)
end

---1UP
---@class THlib.item_extend:object
item_extend = Class(item)

function item_extend:init(x, y)
    item.init(self, x, y, 7)
end
function item_extend:collect()
    --残机数
    lstg.var.lifeleft = lstg.var.lifeleft + 1
    PlaySound('extend', 0.5)
    --显示"Extend!!"
    New(hinter, 'hint.extend', 0.6, 0, 112, 15, 120)
end

---残机碎片
---@class THlib.item_chip:THlib.item
item_chip = Class(item)

function item_chip:init(x, y)
    assert(type(x) == 'number')
    item.init(self, x, y, 3)
    --PlaySound('bonus',0.8)
end
function item_chip:collect()
    --残机碎片数
    lstg.var.chip = lstg.var.chip + 1
    if lstg.var.chip == 5 then
        lstg.var.lifeleft = lstg.var.lifeleft + 1
        lstg.var.chip = 0
        PlaySound('extend', 0.5)
        New(hinter, 'hint.extend', 0.6, 0, 112, 15, 120)
    end
end

---Bomb碎片
---@class THlib.item_bombchip:THlib.item
item_bombchip = Class(item)
function item_bombchip:init(x, y)
    item.init(self, x, y, 9)
    --PlaySound('bonus2',0.8)
end
function item_bombchip:collect()
    lstg.var.bombchip = lstg.var.bombchip + 1
    if lstg.var.bombchip == 5 then
        lstg.var.bomb = lstg.var.bomb + 1
        lstg.var.bombchip = 0
        PlaySound('cardget', 0.8)
    end
end

---Bomb
---@class THlib.item_bomb:THlib.item
item_bomb = Class(item)

function item_bomb:init(x, y)
    item.init(self, x, y, 10)
end
function item_bomb:collect()
    lstg.var.bomb = lstg.var.bomb + 1
    PlaySound('cardget', 0.8)
end

---绿点
---@class THlib.item_faith:THlib.item
item_faith = Class(item)

function item_faith:init(x, y)
    item.init(self, x, y, 5)
end
function item_faith:collect()
    local var = lstg.var
    --收取时显示浮动文字
    New(float_text, 'item', '10000',
        self.x, self.y + 6, 0.75, 90, 60, 0.5, 0.5, Color(0x8000C000), Color(0x0000C000))
    var.faith = var.faith + 100
    --var.score=var.score+10000
end

local item8 = FindResSprite('item8')

---绿点（小）
---@class THlib.item_faith_minor:object
item_faith_minor = Class(object)

function item_faith_minor:init(x, y)
    self.x = x
    self.y = y
    local w = lstg.world
    self.vx = ran:Float(-0.15, 0.15)
    self._vy = ran:Float(3.25, 3.75)
    if not BoxCheck(self, w.l, w.r, w.b, w.t) then
        RawDel(self)
    else
        self.img = item8
        self.group = GROUP_ITEM
        self.layer = LAYER_ITEM
        self.bound = false
        rawset(self, 'flag', 1)
        rawset(self, 'attract', 0)
        --self.flag = 1
        --self.attract = 0
    end
end
function item_faith_minor:frame()
    if self.status == 'del' then
        return
    end
    --刚刚Miss时不能收点
    local timer = self.timer
    local death = player.death
    if death > 80 and death < 90 then
        self.flag = 0
        self.attract = 0
    end
    if timer < 45 then
        --由_vy减速到0
        self.vy = self._vy * (1 - timer / 45)
    end
    if timer >= 54 and self.flag == 1 then
        --直接向自机运动
        SetV(self, 8, Angle(self, player))
    end
    if timer >= 54 and self.flag == 0 then
        local attract = self.attract
        if attract > 0 then
            --被自机吸引
            local a = Angle(self, player)
            self.vx = attract * cos(a) + player.dx * 0.5
            self.vy = attract * sin(a) + player.dy * 0.5
        else
            --加速度向下
            self.vy = max(self.dy - 0.03, -2.5)
            self.vx = 0
        end
        if self.y < -256 then
            Del(self)
        end
    end
end
function item_faith_minor:collect()
    local var = lstg.var
    var.faith = var.faith + 10
    var.score = var.score + 500
end
local _item_faith_minor_collect = item_faith_minor.collect
function item_faith_minor:colli(other)
    if other == player then
        --if self.class.collect then
        --    self.class.collect(self)
        --end
        _item_faith_minor_collect(self)
        Kill(self)
        PlaySound('item00', 0.3, self.x / 200)
    end
end

---蓝点
---@class THlib.item_point:THlib.item
item_point = Class(item)

function item_point:init(x, y)
    item.init(self, x, y, 2)
end
function item_point:collect()
    local var = lstg.var
    if self.attract == 8 then
        --蓝点得分最大（在收点线以上）
        New(float_text, 'item', var.pointrate,
            self.x, self.y + 6, 0.75, 90, 60, 0.5, 0.5, Color(0x80FFFF00), Color(0x00FFFF00))
        var.score = var.score + var.pointrate
    else
        New(float_text, 'item', int(var.pointrate / 20) * 10,
            self.x, self.y + 6, 0.75, 90, 60, 0.5, 0.5, Color(0x80FFFFFF), Color(0x00FFFFFF))
        var.score = var.score + int(var.pointrate / 20) * 10
    end
end
