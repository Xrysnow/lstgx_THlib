---弹型与判定可参考http://thwiki.cc/游戏攻略/STG判定数据

LoadTexture('bullet1', 'THlib\\bullet\\bullet1.png', true)
---发弹点 无判定
LoadImageGroup('preimg', 'bullet1',
               80, 0, 32, 32, 1, 8)
---鳞弹
LoadImageGroup('arrow_big', 'bullet1',
               0, 0, 16, 16, 1, 16, 2.5, 2.5)
---铳弹
LoadImageGroup('gun_bullet', 'bullet1',
               24, 0, 16, 16, 1, 16, 2.5, 2.5)
---铳弹（虚）
LoadImageGroup('gun_bullet_void', 'bullet1',
               56, 0, 16, 16, 1, 16, 2.5, 2.5)
---蝶弹
LoadImageGroup('butterfly', 'bullet1',
               112, 0, 32, 32, 1, 8, 4, 4)
---札弹
LoadImageGroup('square', 'bullet1',
               152, 0, 16, 16, 1, 16, 3, 3)
---小玉
LoadImageGroup('ball_mid', 'bullet1',
               176, 0, 32, 32, 1, 8, 4, 4)
---葡萄弹
LoadImageGroup('mildew', 'bullet1',
               208, 0, 16, 16, 1, 16, 2, 2)
---椭弹
LoadImageGroup('ellipse', 'bullet1',
               224, 0, 32, 32, 1, 8, 4.5, 4.5)

LoadTexture('bullet2', 'THlib\\bullet\\bullet2.png')
---星弹（小）
LoadImageGroup('star_small', 'bullet2',
               96, 0, 16, 16, 1, 16, 3, 3)
---星弹（大）
LoadImageGroup('star_big', 'bullet2',
               224, 0, 32, 32, 1, 8, 5.5, 5.5)
for i = 1, 8 do
    SetImageCenter('star_big' .. i, 15.5, 16)
end
--LoadImageGroup('ball_huge','bullet2',0,0,64,64,1,4,16,16)
--LoadImageGroup('fade_ball_huge','bullet2',0,0,64,64,1,4,16,16)
---中玉
LoadImageGroup('ball_big', 'bullet2',
               192, 0, 32, 32, 1, 8, 8, 8)
for i = 1, 8 do
    SetImageCenter('ball_big' .. i, 16, 16.5)
end
---点弹
LoadImageGroup('ball_small', 'bullet2',
               176, 0, 16, 16, 1, 16, 2, 2)
---米弹
LoadImageGroup('grain_a', 'bullet2',
               160, 0, 16, 16, 1, 16, 2.5, 2.5)
---针弹
LoadImageGroup('grain_b', 'bullet2',
               128, 0, 16, 16, 1, 16, 2.5, 2.5)

LoadTexture('bullet3', 'THlib\\bullet\\bullet3.png')
---刀弹
LoadImageGroup('knife', 'bullet3',
               0, 0, 32, 32, 1, 8, 4, 4)
---杆菌弹
LoadImageGroup('grain_c', 'bullet3',
               48, 0, 16, 16, 1, 16, 2.5, 2.5)
---链弹
LoadImageGroup('arrow_small', 'bullet3',
               80, 0, 16, 16, 1, 16, 2.5, 2.5)
---滴弹
LoadImageGroup('kite', 'bullet3',
               112, 0, 16, 16, 1, 16, 2.5, 2.5)
---伪激光
LoadImageGroup('fake_laser', 'bullet3',
               144, 0, 14, 16, 1, 16, 5, 5, true)
for i = 1, 16 do
    SetImageState('fake_laser' .. i, 'mul+add')
    SetImageCenter('fake_laser' .. i, 0, 8)
end

LoadTexture('bullet4', 'THlib\\bullet\\bullet4.png')
---10角星弹
LoadImageGroup('star_big_b', 'bullet4',
               32, 0, 32, 32, 1, 8, 6, 6)
---小玉b
LoadImageGroup('ball_mid_b', 'bullet4',
               64, 0, 32, 32, 1, 8, 4, 4)
for i = 1, 8 do
    SetImageState('ball_mid_b' .. i, 'mul+add', Color(200, 200, 200, 200))
end
---箭弹
LoadImageGroup('arrow_mid', 'bullet4',
               96, 0, 32, 32, 1, 8, 3.5, 3.5)
for i = 1, 8 do
    SetImageCenter('arrow_mid' .. i, 24, 16)
end
---心弹
LoadImageGroup('heart', 'bullet4',
               128, 0, 32, 32, 1, 8, 9, 9)
---刀弹b
LoadImageGroup('knife_b', 'bullet4',
               192, 0, 32, 32, 1, 8, 3.5, 3.5)
---小玉c
for i = 1, 8 do
    LoadImage('ball_mid_c' .. i, 'bullet4',
              232, i * 32 - 24, 16, 16, 4, 4)
end
---钱币
LoadImageGroup('money', 'bullet4',
               168, 0, 16, 16, 1, 8, 4, 4)
---小玉d
LoadImageGroup('ball_mid_d', 'bullet4',
               168, 128, 16, 16, 1, 8, 3, 3)
for i = 1, 8 do
    SetImageState('ball_mid_d' .. i, 'mul+add')
end
--------ball_light--------
LoadTexture('bullet5', 'THlib\\bullet\\bullet5.png')
---光玉
LoadImageGroup('ball_light', 'bullet5',
               0, 0, 64, 64, 4, 2, 11.5, 11.5)
LoadImageGroup('fade_ball_light', 'bullet5',
               0, 0, 64, 64, 4, 2, 11.5, 11.5)
LoadImageGroup('ball_light_dark', 'bullet5',
               0, 0, 64, 64, 4, 2, 11.5, 11.5)
LoadImageGroup('fade_ball_light_dark', 'bullet5',
               0, 0, 64, 64, 4, 2, 11.5, 11.5)
for i = 1, 8 do
    SetImageState('ball_light' .. i, 'mul+add')
end
--------------------------
--------ball_huge---------
LoadTexture('bullet_ball_huge', 'THlib\\bullet\\bullet_ball_huge.png')
---大玉
LoadImageGroup('ball_huge', 'bullet_ball_huge',
               0, 0, 64, 64, 4, 2, 13.5, 13.5)
LoadImageGroup('fade_ball_huge', 'bullet_ball_huge',
               0, 0, 64, 64, 4, 2, 13.5, 13.5)
LoadImageGroup('ball_huge_dark', 'bullet_ball_huge',
               0, 0, 64, 64, 4, 2, 13.5, 13.5)
LoadImageGroup('fade_ball_huge_dark', 'bullet_ball_huge',
               0, 0, 64, 64, 4, 2, 13.5, 13.5)
for i = 1, 8 do
    SetImageState('ball_huge' .. i, 'mul+add')
end
--------------------------
--------water_drop--------
---炎弹 有动画
LoadTexture('bullet_water_drop', 'THlib\\bullet\\bullet_water_drop.png')
for i = 1, 8 do
    LoadAnimation('water_drop' .. i, 'bullet_water_drop',
                  48 * (i - 1), 0, 48, 32, 1, 4, 4, 4, 4)
    SetAnimationState('water_drop' .. i, 'mul+add')
end
for i = 1, 8 do
    LoadAnimation('water_drop_dark' .. i, 'bullet_water_drop',
                  48 * (i - 1), 0, 48, 32, 1, 4, 4, 4, 4)
end
--------------------------
--------music-------------
---音符 有动画
LoadTexture('bullet_music', 'THlib\\bullet\\bullet_music.png')
for i = 1, 8 do
    LoadAnimation('music' .. i, 'bullet_music',
                  60 * (i - 1), 0, 60, 32, 1, 3, 8, 4, 4)
end
------silence-------------
LoadTexture('bullet6', 'THlib\\bullet\\bullet6.png')
---休止符
LoadImageGroup('silence', 'bullet6',
               192, 0, 32, 32, 1, 8, 4.5, 4.5)
--------------------------

LoadTexture('etbreak', 'THlib\\bullet\\etbreak.png')
---消弹图像
--LoadImageGroup('etbreak', 'etbreak',
--        0, 0, 64, 64, 4, 2, 0, 0)

---消弹效果颜色
local BulletBreakIndex = {
    Color(0xC0FF3030), --red
    Color(0xC0FF30FF), --purple
    Color(0xC03030FF), --blue
    Color(0xC030FFFF), --cyan
    Color(0xC030FF30), --green
    Color(0xC0FFFF30), --yellow
    Color(0xC0FF8030), --orange
    Color(0xC0D0D0D0), --gray
}
_G['BulletBreakIndex'] = BulletBreakIndex

---消弹图像
for i = 1, 16 do
    local name = 'etbreak' .. i
    --播放间隔3帧
    LoadAnimation(name, 'etbreak', 0, 0, 64, 64, 4, 2, 3)
    local c = Color(0x60000000)
    if i % 2 == 0 then
        SetAnimationState(name, 'mul+add', BulletBreakIndex[i / 2])
    elseif i == 15 then
        SetAnimationState(name, '', 0.5 * BulletBreakIndex[(i + 1) / 2] + c)
    else
        SetAnimationState(name, 'mul+add', 0.5 * BulletBreakIndex[(i + 1) / 2] + c)
    end
end
local _bbrnames = {}
for i = 1, 16 do
    _bbrnames[i] = 'etbreak' .. i
end

local int = math.floor
local max = math.max
local min = math.min
local ran = ran
local bubble2 = bubble2
local DefaultRenderFunc = DefaultRenderFunc
local New = New
local Del = Del
local SetImageState = SetImageState
local SetImgState = SetImgState
local Render = Render
local Color = Color
local BoxCheck = BoxCheck
local GetAttr = GetAttr
local SetAttr = SetAttr
--local task_Do = task.Do
local misc = misc
local rawget = rawget

---消弹效果
BulletBreak = Class(object)
local BulletBreak = BulletBreak

---BulletBreak:init(x,y,index)
---初始化消弹效果
---x,y：位置
---index：序号（颜色标识）
function BulletBreak:init(x, y, index)
    self.x = x
    self.y = y
    self.group = GROUP_GHOST
    self.layer = LAYER_ENEMY_BULLET - 50
    ---随机缩放
    local s = ran:Float(0.5, 0.75)
    self.hscale = s
    self.vscale = s
    ---随机旋转
    self.rot = ran:Float(0, 360)
    self.img = _bbrnames[index]
end

function BulletBreak:frame()
    if GetAttr(self, 'timer') == 23 then
        Del(self)
    end
end

--function BulletBreak:render()
--    DefaultRenderFunc(self)
--end
BulletBreak.render = DefaultRenderFunc
----

---
---@class bullet:object @子弹类
---@param imgclass img_class @弹型
---@param index number @颜色索引
---@param stay boolean @是否停滞
---@param destroyable boolean @是则分组为GROUP_ENEMY_BULLET，否则分组为GROUP_INDES
bullet = Class(object)
local bullet = bullet

function bullet:init(imgclass, index, stay, destroyable)
    --保存bullet class
    self.logclass = self.class
    ---@type img_class
    self.imgclass = imgclass
    self.class = imgclass
    if destroyable then
        self.group = GROUP_ENEMY_BULLET
    else
        self.group = GROUP_INDES
    end
    if type(index) == 'number' then
        self.colli = true
        self.stay = stay
        index = int(min(max(1, index), 16))
        self.layer = LAYER_ENEMY_BULLET_EF - imgclass.size * 0.001 + index * 0.00001
        self._index = index
        self.index = int((index + 1) / 2)
    end
    imgclass.init(self, index)

    self._last_blend = {}
end

--function bullet:frame()
--    task.Do(self)
--end
bullet.frame = task.Do

function bullet:kill()
    local x, y = GetAttr(self, 'x'), GetAttr(self, 'y')
    ---产生绿点（小）和消弹效果
    New(item_faith_minor, x, y)
    local w = lstg.world
    local _index = rawget(self, '_index')
    if _index and BoxCheck(self, w.boundl, w.boundr, w.boundb, w.boundt) then
        New(BulletBreak, x, y, _index)
    end
    local imgclass = rawget(self, 'imgclass')
    if imgclass.size == 2.0 then
        imgclass.del(self)
    end
end

function bullet:del()
    --self.imgclass.del(self)
    if self.imgclass.size == 2.0 then
        self.imgclass.del(self)
    end
    ---在屏幕内时产生消弹效果
    local w = lstg.world
    if self._index and BoxCheck(self, w.boundl, w.boundr, w.boundb, w.boundt) then
        New(BulletBreak, self.x, self.y, self._index)
    end
end

function bullet:render()
    --混合颜色
    local blend = rawget(self, '_blend')
    if blend then
        SetImgState(self, blend, self._a, self._r, self._g, self._b)
    end
    DefaultRenderFunc(self)
    --还原混合
    if blend then
        SetImgState(self, '', 255, 255, 255, 255)
    end
end
--bullet.render = DefaultRenderFunc

----------------------------------------------------------------
---弹型类，实现子弹的基本功能
---@class img_class:object
img_class = Class(object)
function img_class:frame()
    if not self.stay then
        ---timer<11时self.stay=nil
        ---只执行task
        --by OLC，修正了defaul action死循环的问题
        if not self._forbid_ref then
            self._forbid_ref = true
            self.logclass.frame(self)
            self._forbid_ref = nil
        end
        --self.logclass.frame(self)
    else
        self.x = self.x - self.vx
        self.y = self.y - self.vy
        self.rot = self.rot - self.omiga
    end
    if self.timer == 11 then
        --切换class为bullet，此后使用bullet类的回调
        self.class = self.logclass
        self.layer = LAYER_ENEMY_BULLET - self.imgclass.size * 0.001 + self._index * 0.00001
        --self.colli=true
        if self.stay then
            self.timer = -1
        end
    end
end

local bubble_color = Color(0xFFFFFFFF)
function img_class:del()
    --收缩效果，持续10帧
    New(bubble2, 'preimg' .. self.index, self.x, self.y, self.dx, self.dy, 11,
        self.imgclass.size, 0, bubble_color, bubble_color, self.layer, 'mul+add')
end

local img_class_del = img_class.del
function img_class:kill()
    --产生收缩效果，消弹效果和一个绿点（小）
    img_class_del(self)
    New(BulletBreak, self.x, self.y, self._index)
    New(item_faith_minor, self.x, self.y)
end

function img_class:render()
    --逐渐增加透明度
    if self._blend then
        SetImageState('preimg' .. self.index, self._blend,
                      Color(255 * self.timer / 11, 255, 255, 255))
    else
        SetImageState('preimg' .. self.index, '',
                      Color(255 * self.timer / 11, 255, 255, 255))
    end
    --从4倍大小逐渐变为1倍大小
    Render('preimg' .. self.index, self.x, self.y, self.rot,
           ((11 - self.timer) / 11 * 3 + 1) * self.imgclass.size)
    --[[
    SetImageState('preimg'..self.index,'',Color(255*self.timer/11,255,255,255))
    Render('preimg'..self.index,self.x,self.y,self.rot,((11-self.timer)/11*3+1)*self.imgclass.size)]]
end
----------------------------------------------------------------

---ChangeBulletImage(obj,imgclass,index)
---更改子弹弹型和颜色
function ChangeBulletImage(obj, imgclass, index)
    if obj.class == obj.imgclass then
        obj.class = imgclass
        obj.imgclass = imgclass
    else
        obj.imgclass = imgclass
    end
    obj._index = index
    imgclass.init(obj, obj._index)
end
----------------------------------------------------------------
bullet.gclist = {}
local bullet_gclist = bullet.gclist

local _c_white = Color(0xFFFFFFFF)
---ChangeBulletHighlight(imgclass,index,on)
---更改子弹高光设置
function ChangeBulletHighlight(imgclass, index, on)
    local ble = ''
    if on then
        ble = 'mul+add'
    end
    local obj = {}
    imgclass.init(obj, index)
    SetImageState(obj.img, ble, _c_white)
    if not bullet_gclist[imgclass] then
        bullet_gclist[imgclass] = {}
    end
    bullet_gclist[imgclass][index] = on
end
----------------------------------------------------------------
---粒子效果
particle_img = Class(object)
function particle_img:init(index)
    self.layer = LAYER_ENEMY_BULLET
    self.img = index
    self.class = self.logclass
end
function particle_img:del()
    misc.KeepParticle(self)
end
--function particle_img:kill()
--    particle_img.del(self)
--end
particle_img.kill = particle_img.del
----------------------------------------------------------------
local function createNames(str)
    local ret = {}
    for i = 1, 16 do
        table.insert(ret, str .. i)
    end
    return ret
end
local function createImgClass(name, size, half)
    local names = createNames(name)
    local c = Class(img_class)
    c.size = size
    if half then
        c.init = function(self, index)
            self.img = names[int((index + 1) / 2)]
        end
    else
        c.init = function(self, index)
            self.img = names[index]
        end
    end
    return c
end
local function createByDef(def)
    for i, v in ipairs(def) do
        _G[v[1]] = createImgClass(v[1], v[2], v[3])
    end
end
----------------------------------------------------------------
local def1 = {
    ---鳞弹
    { 'arrow_big', 0.6, false },
    ---箭弹
    { 'arrow_mid', 0.61, true },
    ---铳弹
    { 'gun_bullet', 0.4, false },
    ---铳弹（虚）
    { 'gun_bullet_void', 0.4, false },
    ---蝶弹
    { 'butterfly', 0.7, true },
    ---札弹
    { 'square', 0.8, false },
    ---小玉
    { 'ball_mid', 0.75, true },
    ---小玉b
    { 'ball_mid_b', 0.751, true },
    ---小玉c
    { 'ball_mid_c', 0.752, true },
    ---小玉d
    { 'ball_mid_d', 0.753, true },
    ---钱币
    { 'money', 0.753, true },
    ---葡萄弹
    { 'mildew', 0.401, false },
    ---椭弹
    { 'ellipse', 0.701, true },
    ---星弹（小）
    { 'star_small', 0.5, false },
    ---星弹（大）
    { 'star_big', 0.998, true },
    ---10角星弹
    { 'star_big_b', 0.999, true },
}
createByDef(def1)
----------------------------------------------------------------
---大玉
ball_huge = Class(img_class)
ball_huge.size = 2.0
function ball_huge:init(index)
    self.img = 'ball_huge' .. int((index + 1) / 2)
end
function ball_huge:frame()
    if not self.stay then
        self.logclass.frame(self)
    else
        self.x = self.x - self.vx
        self.y = self.y - self.vy
        self.rot = self.rot - self.omiga
    end
    if self.timer == 11 then
        self.class = self.logclass
        self.layer = LAYER_ENEMY_BULLET - 2.0 + self.index * 0.00001
        self.colli = true
        if self.stay then
            self.timer = -1
        end
    end
end
function ball_huge:render()
    ---逐渐增加透明度
    SetImageState('fade_' .. self.img, 'mul+add', Color(255 * self.timer / 11, 255, 255, 255))
    ---大小从2倍逐渐变为1倍
    Render('fade_' .. self.img, self.x, self.y, self.rot, (11 - self.timer) / 11 + 1)
end
local _bh_c1 = Color(0xFFFFFFFF)
local _bh_c2 = Color(0x00FFFFFF)
function ball_huge:del()
    ---收缩效果和逐渐透明
    New(bubble2, 'fade_' .. self.img, self.x, self.y, self.dx, self.dy, 11, 1, 0, _bh_c1, _bh_c2, self.layer, 'mul+add')
end
function ball_huge:kill()
    ball_huge.del(self)
end
----------------------------------------------------------------------------
---大玉（暗）
---参照ball_huge
ball_huge_dark = Class(img_class)
ball_huge_dark.size = 2.0
function ball_huge_dark:init(index)
    self.img = 'ball_huge_dark' .. int((index + 1) / 2)
end
function ball_huge_dark:frame()
    if not self.stay then
        self.logclass.frame(self)
    else
        self.x = self.x - self.vx
        self.y = self.y - self.vy
        self.rot = self.rot - self.omiga
    end
    if self.timer == 11 then
        self.class = self.logclass
        self.layer = LAYER_ENEMY_BULLET - 2.0 + self.index * 0.00001
        self.colli = true
        if self.stay then
            self.timer = -1
        end
    end
end
function ball_huge_dark:render()
    SetImageState('fade_' .. self.img, '', Color(255 * self.timer / 11, 255, 255, 255))
    Render('fade_' .. self.img, self.x, self.y, self.rot, (11 - self.timer) / 11 + 1)
end
local _del_c1 = Color(0xFFFFFFFF)
local _del_c2 = Color(0x00FFFFFF)
function ball_huge_dark:del()
    New(bubble2, 'fade_' .. self.img, self.x, self.y, self.dx, self.dy, 11, 1, 0, _del_c1, _del_c2, self.layer, '')
end
function ball_huge_dark:kill()
    ball_huge.del(self)
end
----------------------------------------------------------------
---光玉
---参照ball_huge
ball_light = Class(img_class)
local ball_light = ball_light
ball_light.size = 2.0
function ball_light:init(index)
    self.img = 'ball_light' .. int((index + 1) / 2)
end
function ball_light:frame()
    if not self.stay then
        self.logclass.frame(self)
    else
        self.x = self.x - self.vx
        self.y = self.y - self.vy
        self.rot = self.rot - self.omiga
    end
    if self.timer == 11 then
        self.class = self.logclass
        self.layer = LAYER_ENEMY_BULLET - 2.0 + self.index * 0.00001
        self.colli = true
        if self.stay then
            self.timer = -1
        end
    end
end
function ball_light:render()
    SetImageState('fade_' .. self.img, 'mul+add', Color(255 * self.timer / 11, 255, 255, 255))
    Render('fade_' .. self.img, self.x, self.y, self.rot, (11 - self.timer) / 11 + 1)
end
function ball_light:del()
    New(bubble2, 'fade_' .. self.img, self.x, self.y, self.dx, self.dy, 11, 1, 0, _del_c1, _del_c2, self.layer, 'mul+add')
end
--function ball_light:kill()
--    ball_light.del(self)
--end
ball_light.kill = ball_light.del
----------------------------------------------------------------
---光玉（暗）
---参照ball_huge
ball_light_dark = Class(img_class)
local ball_light_dark = ball_light_dark
ball_light_dark.size = 2.0
function ball_light_dark:init(index)
    self.img = 'ball_light_dark' .. int((index + 1) / 2)
end
function ball_light_dark:frame()
    if not self.stay then
        self.logclass.frame(self)
    else
        self.x = self.x - self.vx
        self.y = self.y - self.vy
        self.rot = self.rot - self.omiga
    end
    if self.timer == 11 then
        self.class = self.logclass
        self.layer = LAYER_ENEMY_BULLET - 2.0 + self.index * 0.00001
        self.colli = true
        if self.stay then
            self.timer = -1
        end
    end
end
function ball_light_dark:render()
    SetImageState('fade_' .. self.img, '', Color(255 * self.timer / 11, 255, 255, 255))
    Render('fade_' .. self.img, self.x, self.y, self.rot, (11 - self.timer) / 11 + 1)
end
function ball_light_dark:del()
    New(bubble2, 'fade_' .. self.img, self.x, self.y, self.dx, self.dy, 11, 1, 0, _del_c1, _del_c2, self.layer, '')
end
--function ball_light_dark:kill()
--    ball_light.del(self)
--end
ball_light_dark.kill = ball_light.del
----------------------------------------------------------------
local def2 = {
    ---中玉
    { 'ball_big', 1.0, true },
    ---心弹
    { 'heart', 1.0, true },
    ---点弹
    { 'ball_small', 0.402, false },
    ---米弹
    { 'grain_a', 0.403, false },
    ---针弹
    { 'grain_b', 0.404, false },
    ---杆菌弹
    { 'grain_c', 0.405, false },
    ---滴弹
    { 'kite', 0.406, false },
    ---刀弹
    { 'knife', 0.754, true },
    ---刀弹b
    { 'knife_b', 0.755, true },
    ---链弹
    { 'arrow_small', 0.407, false },
}
createByDef(def2)
----------------------------------------------------------------
---炎弹 有动画
water_drop = Class(img_class)   --2 4 6 10 12
water_drop.size = 0.702
function water_drop:init(index)
    self.img = 'water_drop' .. int((index + 1) / 2)
end
function water_drop:render()
    SetImageState('preimg' .. self.index, 'mul+add', Color(255 * self.timer / 11, 255, 255, 255))
    Render('preimg' .. self.index, self.x, self.y, self.rot, ((11 - self.timer) / 11 * 2 + 1) * self.imgclass.size)
end
----------------------------------------------------------------
---炎弹（暗） 有动画
water_drop_dark = Class(img_class)   --2 4 6 10 12
water_drop_dark.size = 0.702
function water_drop_dark:init(index)
    self.img = 'water_drop_dark' .. int((index + 1) / 2)
end
----------------------------------------------------------------
---音符 有动画
music = Class(img_class)
music.size = 0.8
function music:init(index)
    self.img = 'music' .. int((index + 1) / 2)
end
----------------------------------------------------------------
---休止符
silence = Class(img_class)
silence.size = 0.8
function silence:init(index)
    self.img = 'silence' .. int((index + 1) / 2)
end
----------------------------------------------------------------

----------------------------------------------------------------
straight = Class(bullet)
function straight:init(imgclass, index, stay, x, y, v, angle, omiga)
    self.x = x
    self.y = y
    SetV(self, v, angle, true)
    self.omiga = omiga or 0
    bullet.init(self, imgclass, index, stay, true)
end
----------------------------------------------------------------
straight_indes = Class(bullet)
function straight_indes:init(imgclass, index, stay, x, y, v, angle, omiga)
    self.x = x
    self.y = y
    SetV(self, v, angle, true)
    self.omiga = omiga or 0
    bullet.init(self, imgclass, index, stay, false)
    self.group = GROUP_INDES
end
----------------------------------------------------------------
straight_495 = Class(bullet)
function straight_495:init(imgclass, index, stay, x, y, v, angle, omiga)
    self.x = x
    self.y = y
    SetV(self, v, angle, true)
    self.omiga = omiga or 0
    bullet.init(self, imgclass, index, stay, true)
end
function straight_495:frame()
    if not self.reflected then
        local world = lstg.world
        local x, y = GetAttr(self, 'x'), GetAttr(self, 'y')
        if y > world.t then
            self.vy = -self.vy
            if self.acceleration and self.acceleration.ay then
                self.acceleration.ay = -self.acceleration.ay
            end
            self.rot = -self.rot
            self.reflected = true
            return
        end
        if x > world.r then
            self.vx = -self.vx
            if self.acceleration and self.acceleration.ax then
                self.acceleration.ax = -self.acceleration.ax
            end
            self.rot = 180 - self.rot
            self.reflected = true
            return
        end
        if x < world.l then
            self.vx = -self.vx
            if self.acceleration and self.acceleration.ax then
                self.acceleration.ax = -self.acceleration.ax
            end
            self.rot = 180 - self.rot
            self.reflected = true
            return
        end
    end
end
----------------------------------------------------------------
-- TODO: optimize ObjList / make Dist accept group

local ObjList = ObjList
local Dist = Dist
local Kill = Kill
--local GROUP_INDES = GROUP_INDES
--local GROUP_ENEMY_BULLET = GROUP_ENEMY_BULLET

bullet_killer = Class(object)
function bullet_killer:init(x, y, kill_indes)
    self.x = x
    self.y = y
    self.group = GROUP_GHOST
    self.hide = true
    self.kill_indes = kill_indes
end
function bullet_killer:frame()
    ---kill范围为圆形逐渐增大
    if self.timer == 40 then
        Del(self)
    end
    local range = self.timer * 20
    for i, o in ObjList(GROUP_ENEMY_BULLET) do
        if Dist(self, o) < range then
            Kill(o)
        end
    end
    if self.kill_indes then
        for i, o in ObjList(GROUP_INDES) do
            if Dist(self, o) < range then
                Kill(o)
            end
        end
    end
end
----------------------------------------------------------------
bullet_deleter = Class(object)
function bullet_deleter:init(x, y, kill_indes)
    self.x = x
    self.y = y
    self.group = GROUP_GHOST
    self.hide = true
    self.kill_indes = kill_indes
end
function bullet_deleter:frame()
    if self.timer == 60 then
        Del(self)
    end
    local range = self.timer * 20
    for i, o in ObjList(GROUP_ENEMY_BULLET) do
        if Dist(self, o) < range then
            Del(o)
        end
    end
    if self.kill_indes then
        for i, o in ObjList(GROUP_INDES) do
            if Dist(self, o) < range then
                Del(o)
            end
        end
    end
end
--------------------------------------------------------------
bullet_killer_SP = Class(object)
function bullet_killer_SP:init(x, y, kill_indes)
    self.x = x
    self.y = y
    self.group = GROUP_GHOST
    self.hide = false
    self.kill_indes = kill_indes
    self.img = 'yubi'
end
function bullet_killer_SP:frame()

    self.rot = -6 * self.timer
    if self.timer == 60 then
        Del(self)
    end
    for i, o in ObjList(GROUP_ENEMY_BULLET) do
        if Dist(self, o) < 60 then
            Kill(o)
        end
    end
    if self.kill_indes then
        for i, o in ObjList(GROUP_INDES) do
            if Dist(self, o) < 60 then
                Kill(o)
            end
        end
    end
end
--------------------------------------------------------------
bullet_deleter2 = Class(object)
function bullet_deleter:init(x, y, kill_indes)
    self.x = player.x
    self.y = player.y
    self.group = GROUP_GHOST
    self.hide = true
    self.kill_indes = kill_indes
end
function bullet_deleter2:frame()
    self.x = player.x
    self.y = player.y
    if self.timer == 30 then
        Del(self)
    end
    local range = self.timer * 5
    for i, o in ObjList(GROUP_ENEMY_BULLET) do
        if Dist(self, o) < range then
            Del(o)
        end
    end
    if self.kill_indes then
        for i, o in ObjList(GROUP_INDES) do
            if Dist(self, o) < range then
                Del(o)
            end
        end
    end
end
--------------------------------------------------------------
--------------------------------------------------------------
---Bomb消弹
bomb_bullet_killer = Class(object)
function bomb_bullet_killer:init(x, y, a, b, kill_indes)
    self.x = x
    self.y = y
    self.a = a
    self.b = b
    ---a不等于b则为矩形碰撞盒
    if a ~= b then
        self.rect = true
    end
    self.group = GROUP_PLAYER
    self.hide = true
    self.kill_indes = kill_indes
end
function bomb_bullet_killer:frame()
    ---只存在1帧
    if self.timer == 1 then
        Del(self)
    end
end
function bomb_bullet_killer:colli(other)
    local group = GetAttr(other, 'group')
    if rawget(self, 'kill_indes') then
        if group == GROUP_INDES then
            Kill(other)
        end
    end
    if group == GROUP_ENEMY_BULLET then
        Kill(other)
    end
end
--------------------------------------------------------------
COLOR_DEEP_RED = 1
COLOR_RED = 2
COLOR_DEEP_PURPLE = 3
COLOR_PURPLE = 4
COLOR_DEEP_BLUE = 5
COLOR_BLUE = 6
COLOR_ROYAL_BLUE = 7
COLOR_CYAN = 8
COLOR_DEEP_GREEN = 9
COLOR_GREEN = 10
COLOR_CHARTREUSE = 11
COLOR_YELLOW = 12
COLOR_GOLDEN_YELLOW = 13
COLOR_ORANGE = 14
COLOR_DEEP_GRAY = 15
COLOR_GRAY = 16
BULLETSTYLE = {
    arrow_big, arrow_mid, arrow_small, gun_bullet, butterfly, square,
    ball_small, ball_mid, ball_mid_c, ball_big, ball_huge, ball_light,
    star_small, star_big, grain_a, grain_b, grain_c, kite, knife, knife_b,
    water_drop, mildew, ellipse, heart, money, music, silence,
    water_drop_dark, ball_huge_dark, ball_light_dark
}--30
