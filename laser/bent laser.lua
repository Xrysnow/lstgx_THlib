-- updated to ex+0.80d
-- except [pairs(Players(self))]

local max = max
local int = int

local task = task
local Del = Del
local Color = Color
local New = New
local Render = Render
local SetImageState = SetImageState
local PreserveObject = PreserveObject
local BentLaserData = BentLaserData
local BoxCheck = BoxCheck
local setmetatable = setmetatable

local mt = ObjTable().mt
local GetAttr = GetAttr
local SetAttr = SetAttr
local rawset = rawset
local function laser_bent_meta_newindex(t, k, v)
    if k == 'bound' then
        rawset(t, '_bound', v)
    elseif k == 'colli' then
        --from ex
        rawset(t, '_colli', v)
    else
        mt.__newindex(t, k, v)
    end
end
_G['laser_bent_meta_newindex'] = laser_bent_meta_newindex

---
---@class THlib.laser_bent:object
laser_bent = Class(object)

function laser_bent:init(index, x, y, l, w, sample, node)
    self.index = index
    self.x = x
    self.y = y
    self.l = max(int(l), 2)
    self.w = w
    self.group = GROUP_INDES
    self.layer = LAYER_ENEMY_BULLET
    ---@type lstg.GameObjectBentLaser
    self.data = BentLaserData()
    self.bound = false
    self._bound = true
    self.prex = x
    self.prey = y
    self.listx = {}
    self.listy = {}
    self.node = node or 0
    self._l = int(l / 4)
    self.img4 = 'laser_node' .. int((self.index + 1) / 2)
    if sample == 0 then
        self.class = laser_bent_elec
    end
    --from ex
    self.w0 = w
    self._w = w
    self.pause = 0
    self.a = 0
    self.b = 0
    self.dw = 0
    self.da = 0
    self.alpha = 1
    self.counter = 0
    self._colli = true
    self._blend, self._a, self._r, self._g, self._b = 'mul+add', 255, 255, 255, 255

    setmetatable(self, { __index = mt.__index, __newindex = laser_bent_meta_newindex })
end

function laser_bent:frame()
    task.Do(self)
    local player = player
    local lstg_world = lstg.world

    SetAttr(self, 'colli', self._colli and self.alpha > 0.999)
    if self.counter > 0 then
        self.counter = self.counter - 1
        self.w = self.w + self.dw
        self.alpha = self.alpha + self.da
    end

    local _l = self._l

    if self.pause > 0 then
        --self.pause=self.pause-1
    else
        --每4帧保存位置
        if self.timer % 4 == 0 then
            self.listx[(self.timer / 4) % _l] = self.x
            self.listy[(self.timer / 4) % _l] = self.y
        end
        --self.data:setColorMode(2,1)
        --local color = Color(255,
        --        (cos(self.timer * 5) / 2 + 0.5) * 255,
        --        (cos(self.timer * 5 + 120) / 2 + 0.5) * 255,
        --        (cos(self.timer * 5 + 240) / 2 + 0.5) * 255)
        self.data:setNodeLimit(self.l)
        self.data:pushHead(self.x, self.y, self.w)--, color)
    end

    if self.w ~= self._w then
        laser_bent.setWidth(self, self.w)
        self._w = self.w
    end

    if self.alpha > 0.999 and self._colli then
        --计算碰撞
        if self._colli and self.data:collisionCheck(player.x, player.y) then
            player.class.colli(player, self)
        end
        --计算擦弹
        if self.timer % 4 == 0 then
            if self._colli and self.data:collisionCheckExtendWidth(player.x, player.y, 24) then
                item.PlayerGraze()
                player.grazer.grazed = true
            end
        end
    end

    --出屏检测
    if self._bound and not self.data:boundCheck() and
            not BoxCheck(self, lstg_world.boundl, lstg_world.boundr, lstg_world.boundb, lstg_world.boundt) then
        Del(self)
    end
end

function laser_bent:setWidth(w)
    self.w = w
    self.data:setAllWidth(self.w)
end

local _c_white = Color(0xFFFFFFFF)
local laser3 = FindResTexture('laser3')
assert(laser3)

function laser_bent:render()
    local color = Color(self._a * self.alpha, self._r, self._g, self._b)
    self.data:render(laser3, self._blend, color,
                     0, self.index * 16 - 12, 256, 8)
    local timer = self.timer
    if timer < self._l * 4 and self.node then
        --绘制发弹源
        local img4 = self.img4
        SetImageState(img4, self._blend, color)
        local scale = (8 + timer % 3) * 0.125 * self.node / 8
        Render(img4, self.prex, self.prey, -3 * timer,
               scale)
        Render(img4, self.prex, self.prey, -3 * timer + 180,
               scale)
    end
end

function laser_bent:del()
    PreserveObject(self)
    if self.class ~= laser_bent_death_ef then
        self.class = laser_bent_death_ef
        self.group = GROUP_GHOST
        self.timer = 0
        task.Clear(self)
    end
end

function laser_bent:kill()
    PreserveObject(self)
    if self.class ~= laser_bent_death_ef then
        for i = 0, self._l do
            if self.listx[i] and self.listy[i] then
                --掉落和消弹效果
                New(item_faith_minor, self.listx[i], self.listy[i])
                if self.index and i % 2 == 0 then
                    New(BulletBreak, self.listx[i], self.listy[i], self.index)
                end
            end
        end
        self.class = laser_bent_death_ef
        self.group = GROUP_GHOST
        self.timer = 0
        task.Clear(self)
    end
end

---@class THlib.laser_bent_death_ef:object
laser_bent_death_ef = Class(object)

function laser_bent_death_ef:frame()
    if self.timer == 30 then
        Del(self)
    end
end

function laser_bent_death_ef:render()
    self.data:render(laser3, 'mul+add',
                     Color(255 - 8.5 * self.timer, 255, 255, 255),
                     0, self.index * 16 - 12, 256, 8)
end

function laser_bent_death_ef:del()
    self.data:release()
end
function laser_bent_death_ef:kill()
    self.data:release()
end
---------------------------------------------------
--TODO 合并
local laser5 = LoadTexture('laser_bent2', 'THlib/laser/laser5.png')
assert(laser5)

---雷电激光，与laser_bent的区别主要是无消弹特效
---@class THlib.laser_bent_elec:object
laser_bent_elec = Class(object)

function laser_bent_elec:init(index, x, y, l, w, sample, node)
    self.index = index
    self.x = x
    self.y = y
    self.l = max(int(l), 2)
    self.w = w
    self.group = GROUP_INDES
    self.layer = LAYER_ENEMY_BULLET
    self.data = BentLaserData()
    --self._data = BentLaserData()
    self.bound = false
    self._bound = true
    self.prex = x
    self.prey = y
    self.node = node or 0
    self.listx = {}
    self.listy = {}
    self._l = int(l / 4)
    self.img4 = 'laser_node' .. int((self.index + 1) / 2)
    setmetatable(self, { __index = GetAttr, __newindex = laser_bent_meta_newindex })
end

function laser_bent_elec:frame()
    task.Do(self)
    local player = player
    local lstg_world = lstg.world
    local _l = self._l
    if self.timer % 4 == 0 then
        self.listx[(self.timer / 4) % _l] = self.x
        self.listy[(self.timer / 4) % _l] = self.y
    end
    self.data:setNodeLimit(self.l)
    self.data:pushHead(self.x, self.y, self.w)
    if self.colli and self.data:collisionCheck(player.x, player.y) then
        player.class.colli(player, self)
    end
    if self.timer % 4 == 0 then
        if self.colli and self.data:collisionCheckExtendWidth(player.x, player.y, 24) then
            item.PlayerGraze()
            player.grazer.grazed = true
        end
    end
    if self._bound and not self.data:boundCheck() and
            not BoxCheck(self, lstg_world.boundl, lstg_world.boundr, lstg_world.boundb, lstg_world.boundt) then
        Del(self)
    end
end

function laser_bent_elec:render()
    self.data:render(laser5, 'mul+add', _c_white, 0, 32 * (int(0.5 * self.timer) % 4), 256, 32)
    if self.timer < self._l * 4 and self.node then
        --local c = Color(255, 255, 255, 255)
        --SetImageState(self.img4, 'mul+add', c)
        SetImageState(self.img4, 'mul+add', _c_white)
        local scale = (8 + self.timer % 3) * 0.125 * self.node / 8
        Render(self.img4, self.prex, self.prey, -3 * self.timer,
               scale)
        Render(self.img4, self.prex, self.prey, -3 * self.timer + 180,
               scale)
    end
end

function laser_bent_elec:del()
    PreserveObject(self)
    if self.class ~= laser_bent_death_ef then
        self.class = laser_bent2_death_ef
        self.group = GROUP_GHOST
        self.timer = 0
        task.Clear(self)
    end
end

function laser_bent_elec:kill()
    PreserveObject(self)
    if self.class ~= laser_bent_death_ef then
        for i = 0, self._l do
            if self.listx[i] and self.listy[i] then
                New(item_faith_minor, self.listx[i], self.listy[i])
            end
        end
        self.class = laser_bent2_death_ef
        self.group = GROUP_GHOST
        self.timer = 0
        task.Clear(self)
    end
end

---@class THlib.laser_bent2_death_ef:object
laser_bent2_death_ef = Class(object)

function laser_bent2_death_ef:frame()
    if self.timer == 30 then
        Del(self)
    end
end

function laser_bent2_death_ef:render()
    self.data:render(laser5, 'mul+add',
                     Color(255 - 8.5 * self.timer, 255, 255, 255),
                     0, 32 * (int(0.5 * self.timer) % 4), 256, 32)
end

function laser_bent2_death_ef:del()
    self.data:release()
end
function laser_bent2_death_ef:kill()
    self.data:release()
end

