---from LuaSTG_er+ 1.02
---data/Thlib/misc/misc.lua
---comment by Xrysnow 2017.09.09


LoadTexture('misc', 'THlib\\misc\\misc.png')
LoadImage('player_aura', 'misc', 128, 0, 64, 64)
LoadImageGroup('bubble', 'misc', 192, 0, 64, 64, 1, 4)
LoadImage('boss_aura', 'misc', 0, 128, 128, 128)
SetImageState('boss_aura', 'mul+add', Color(0x80FFFFFF))
LoadImage('border', 'misc', 128, 192, 64, 64)
LoadImage('leaf', 'misc', 0, 32, 32, 32)
LoadImage('white', 'misc', 56, 8, 16, 16)
LoadTexture('particles', 'THlib\\misc\\particles.png')
LoadImageGroup('parimg', 'particles', 0, 0, 32, 32, 4, 4)
LoadImageFromFile('img_void', 'THlib\\misc\\img_void.png')

local int = int
local sin = sin
local cos = cos
local GROUP_GHOST = GROUP_GHOST
local object_render = object.render
local SetImageState = SetImageState
local Color = Color
local Render = Render
local Del = Del
local Render4V = Render4V

---@class THlib.misc
misc = {}

--TODO

---绘制圆环
---用于绘制 bossring
function misc.RenderRing(img, x, y, r1, r2, rot, n, nimg)
    local da = 360 / n
    for i = 1, n do
        local a = rot - da * i
        Render4V(img .. ((i - 1) % nimg + 1),
                 r1 * cos(a + da) + x, r1 * sin(a + da) + y, 0.5,
                 r2 * cos(a + da) + x, r2 * sin(a + da) + y, 0.5,
                 r2 * cos(a) + x, r2 * sin(a) + y, 0.5,
                 r1 * cos(a) + x, r1 * sin(a) + y, 0.5)
    end
end

---绘制Boss血条亮的部分
function misc.Renderhp(x, y, rot, la, r1, r2, n, c)
    RenderSector('hpbar1', x, y, rot, rot + la * c, r1, r2, n)
end

---绘制Boss血条暗的部分
function misc.Renderhpbar(x, y, rot, la, r1, r2, n, c)
    RenderSector('hpbar2', x, y, rot, rot + la * c, r1, r2, n)
end

---震屏
---t：时长（帧）
---s：幅度（像素）
function misc.ShakeScreen(t, s)
    if lstg.tmpvar.shaker then
        --震屏中重设参数
        lstg.tmpvar.shaker.time = t
        lstg.tmpvar.shaker.size = s
        lstg.tmpvar.shaker.timer = 0
    else
        New(shaker_maker, t, s)
    end
end

---
---停止粒子发射，存活数为0后删除自己
function misc.KeepParticle(o)
    o.class = ParticleKepper
    PreserveObject(o)
    ParticleStop(o)
    o.bound = false
    o.group = GROUP_GHOST
end

---具有显隐过渡效果的图片
---使用透明度过渡或垂直缩放过渡
---@class THlib.hinter:object
hinter = Class(object)

---
---img：图像名
---size：大小缩放
---x,y：位置
---t1：过渡显示时间
---t2：正常显示时间
---fade：为true使用透明度过渡，否则使用垂直缩放过渡
function hinter:init(img, size, x, y, t1, t2, fade)
    self.img = img
    self.x = x
    self.y = y
    self.t1 = t1
    self.t2 = t2
    self.fade = fade
    self.group = GROUP_GHOST
    self.layer = LAYER_TOP
    self.size = size
    self.t = 0
    self.hscale = self.size
end

function hinter:frame()
    if self.timer < self.t1 then
        --渐显
        self.t = self.timer / self.t1
    elseif self.timer < self.t1 + self.t2 then
        self.t = 1
    elseif self.timer < self.t1 * 2 + self.t2 then
        --渐隐
        self.t = (self.t1 * 2 + self.t2 - self.timer) / self.t1
    else
        Del(self)
    end
end

local _color_white = Color(0xFFFFFFFF)

function hinter:render()
    if self.fade then
        --透明度过渡
        SetImageState(self.img, '', Color(self.t * 255, 255, 255, 255))
        self.vscale = self.size
        object_render(self)
    else
        --垂直缩放过渡
        SetImageState(self.img, '', _color_white)
        self.vscale = self.t * self.size
        object_render(self)
    end
end

---具有过渡效果的图片
---大小和颜色逐渐变化
---@class THlib.bubble:object
bubble = xclass(object)
--bubble = Class(object)

function bubble:init(img, x, y, life_time, size1, size2, color1, color2, layer, blend)
    self.img = img
    self.x = x
    self.y = y
    self.group = GROUP_GHOST
    self.life_time = life_time
    self.size1 = size1
    self.size2 = size2
    self.color1 = color1
    self.color2 = color2
    self.layer = layer
    self.blend = blend or ''
end

--function bubble:render()
--    ---大小和颜色逐渐变化
--    local t = (self.life_time - self.timer) / self.life_time
--    local size = self.size1 * t + self.size2 * (1 - t)
--    local c = self.color1 * t + self.color2 * (1 - t)
--    SetImageState(self.img, self.blend, c)
--    Render(self.img, self.x, self.y, 0, size)
--end

function bubble:frame()
    local t = (self.life_time - self.timer) / self.life_time
    local size = self.size1 * t + self.size2 * (1 - t)
    local c = self.color1 * t + self.color2 * (1 - t)
    self.hscale = size
    self.vscale = size
    self.color = c
    if self.timer == self.life_time - 1 then
        Del(self)
    end
end

---具有过渡效果的图片
---大小和颜色逐渐变化
---会按一定速度移动
---@class THlib.bubble2:object
bubble2 = xclass(object)
--bubble2 = Class(object)

function bubble2:init(img, x, y, vx, vy, life_time, size1, size2, color1, color2, layer, blend)
    self.img = img
    self.x = x
    self.y = y
    self.vx = vx
    self.vy = vy
    self.group = GROUP_GHOST
    self.life_time = life_time
    self.size1 = size1
    self.size2 = size2
    self.color1 = color1
    self.color2 = color2
    self.layer = layer
    self.blend = blend or ''
end

function bubble2:frame()
    if self.timer == self.life_time - 1 then
        Del(self)
    end
    local t = (self.life_time - self.timer) / self.life_time
    local size = self.size1 * t + self.size2 * (1 - t)
    local c = self.color1 * t + self.color2 * (1 - t)
    self.color = c
    self.hscale = size
    self.vscale = size
end

--function bubble2:render()
--    local t = (self.life_time - self.timer) / self.life_time
--    local size = self.size1 * t + self.size2 * (1 - t)
--    local c = self.color1 * t + self.color2 * (1 - t)
--    SetImageState(self.img, self.blend, c)
--    Render(self.img, self.x, self.y, 0, size)
--end

---浮动文字
---大小和颜色逐渐变化
---会按一定速度移动
---@class THlib.float_text:object
float_text = Class(object)

function float_text:init(fnt, text, x, y, v, angle, life_time, size1, size2, color1, color2)
    self.fnt = fnt
    self.text = text
    self.x = x
    self.y = y
    self.vx = v * cos(angle)
    self.vy = v * sin(angle)
    self.group = GROUP_GHOST
    self.life_time = life_time
    self.size1 = size1
    self.size2 = size2
    self.color1 = color1
    self.color2 = color2
    self.layer = LAYER_TOP
end

function float_text:render()
    local t = (self.life_time - self.timer) / self.life_time
    local size = self.size1 * t + self.size2 * (1 - t)
    local c = self.color1 * t + self.color2 * (1 - t)
    SetFontState(self.fnt, '', c)
    RenderText(self.fnt, self.text, self.x, self.y, size, 'centerpoint')
end
function float_text:frame()
    if self.timer == self.life_time - 1 then
        Del(self)
    end
end

---震屏效果
---@class THlib.shaker_maker:object
shaker_maker = Class(object)
--local lstg = lstg

function shaker_maker:init(time, size)
    lstg.tmpvar.shaker = self
    self.time = time
    self.size = size
    self.l = lstg.world.l
    self.r = lstg.world.r
    self._b = lstg.world.b
    self.t = lstg.world.t
end

function shaker_maker:frame()
    local a = int(self.timer / 3) * 360 / 5 * 2--每3帧增加0.8pi
    local x = self.size * cos(a)
    local y = self.size * sin(a)
    lstg.world.l = self.l + x
    lstg.world.r = self.r + x
    lstg.world.b = self._b + y
    lstg.world.t = self.t + y
    if self.timer == self.time then
        Del(self)
    end
end

function shaker_maker:del()
    lstg.world.l = self.l
    lstg.world.r = self.r
    lstg.world.b = self._b
    lstg.world.t = self.t
    lstg.tmpvar.shaker = nil
end

function shaker_maker:kill()
    lstg.world.l = self.l
    lstg.world.r = self.r
    lstg.world.b = self._b
    lstg.world.t = self.t
    lstg.tmpvar.shaker = nil
end

local task_Do = task.Do
local task_New = task.New
local coroutine_status = coroutine.status

---任务类
---具有group属性，协程结束时执行Del
---@class THlib.tasker:object
tasker = Class(object)

function tasker:init(f, group)
    self.group = group or GROUP_GHOST
    task_New(self, f)
end
function tasker:frame()
    task_Do(self)
    if coroutine_status(self.task[1]) == 'dead' then
        Del(self)
    end
end

---@class THlib.ParticleKepper:object
ParticleKepper = Class(object)

function ParticleKepper:frame()
    if ParticleGetn(self) == 0 then
        Del(self)
    end
end

---全屏shutter效果
---@class THlib.shutter:object
shutter = Class(object)

function shutter:init(mode)
    self.layer = LAYER_TOP + 100
    self.group = GROUP_GHOST
    self.open = (mode == 'open')
end

function shutter:frame()
    if self.timer == 60 then
        Del(self)
    end
end

if setting.resx > setting.resy then
    function shutter:render()
        SetViewMode 'ui'
        SetImageState('white', '', Color(0xFF000000))
        if self.open then
            for i = 0, 15 do
                RenderRect('white',
                           (i + 1 - min(max(1 - self.timer / 30 + i / 16, 0), 1)) * 40,
                           (i + 1) * 40,
                           0,
                           480)
            end
        else
            for i = 0, 15 do
                RenderRect('white',
                           i * 40,
                           (i + min(max(self.timer / 30 - i / 16, 0), 1)) * 40,
                           0,
                           480)
            end
        end
    end
else
    function shutter:render()
        SetViewMode 'ui'
        SetImageState('white', '', Color(0xFF000000))
        if self.open then
            for i = 0, 15 do
                RenderRect('white', (i + 1 - min(max(1 - self.timer / 30 + i / 16, 0), 1)) * 24.75, (i + 1) * 24.75, 0, 528)
            end
        else
            for i = 0, 15 do
                RenderRect('white', i * 24.75, (i + min(max(self.timer / 30 - i / 16, 0), 1)) * 24.75, 0, 528)
            end
        end
    end
end

---全屏遮罩过渡效果
---@class THlib.mask_fader:object
mask_fader = Class(object)

function mask_fader:init(mode)
    self.layer = LAYER_TOP + 100
    self.group = GROUP_GHOST
    self.open = (mode == 'open')
end

function mask_fader:frame()
    if self.timer == 30 then
        Del(self)
    end
end

function mask_fader:render()
    SetViewMode 'ui'
    if self.open then
        SetImageState('white', '', Color(255 - self.timer * 8.5, 0, 0, 0))
    else
        SetImageState('white', '', Color(self.timer * 8.5, 0, 0, 0))
    end
    if setting.resx > setting.resy then
        RenderRect('white', 0, 640, 0, 480)
    else
        RenderRect('white', 0, 396, 0, 528)
    end
end

CopyImage('.white.star', 'white')
SetImageState('.white.star', 'mul+sub',
              Color(255, 255, 255, 255))

function renderstar(x, y, r, point)
    local ang = 360 / (2 * point)
    for angle = 360 / point, 360, 360 / point do
        local x1, y1 = x + r * cos(angle + ang) ^ 3, r * sin(angle + ang) ^ 3
        local x2, y2 = x + r * cos(angle - ang) ^ 3, r * sin(angle - ang) ^ 3
        Render4V('.white.star', x, y, 0.5,
                 x, y, 0.5,
                 x1, y1, 0.5,
                 x2, y2, 0.5)
    end
end

CopyImage('.white.rev', 'white')
SetImageState('.white.rev', 'add+sub',
              Color(255, 255, 255, 255))

---绘制圆形区域的反色效果，用于Miss效果
---使用绘制三角形近似圆形的方法
---@param x number
---@param y number
---@param r number
---@param point number
function rendercircle(x, y, r, point)
    --local ang = 360 / (2 * point)
    --for angle = 360 / point, 360, 360 / point do
    --    local x1, y1 = x + r * cos(angle + ang), y + r * sin(angle + ang)
    --    local x2, y2 = x + r * cos(angle - ang), y + r * sin(angle - ang)
    --    Render4V('.white.rev', x, y, 0.5,
    --            x, y, 0.5,
    --            x1, y1, 0.5,
    --            x2, y2, 0.5)
    --end
    RenderSector('.white.rev', x, y, 0, 360, 0, r, point)
end
