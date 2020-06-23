BG_A1_bg = Class(object)

function BG_A1_bg:init()
    --
    background.init(self, false)
    --resource
    LoadImageFromFile('BG_A1_a', 'THlib\\background\\BG_A1\\BG_A1_a.png')
    LoadImageFromFile('BG_A1_b', 'THlib\\background\\BG_A1\\BG_A1_b.png')
    LoadImageFromFile('BG_A1_c', 'THlib\\background\\BG_A1\\BG_A1_c.png')
    LoadImageFromFile('BG_A1_d', 'THlib\\background\\BG_A1\\BG_A1_d.png')
    ---LoadImageFromFile('BG_A1_e','THlib\\background\\BG_A1\\BG_A1_e.png')
    LoadImageFromFile('BG_A1_BLACK', 'THlib\\background\\BG_A1\\BG_A1_BLACK.png')
    --LoadTexture('BG_A1_BLACK_','THlib\\background\\BG_A1\\BG_A1_BLACK.png')
    --set 3d camera and fog
    Set3D('eye', 0, 24.0, -16.3)
    Set3D('at', 0, -2.5, 1.3)
    Set3D('up', 0, 1, 0)
    Set3D('z', 1, 100)
    Set3D('fovy', 0.6)
    Set3D('fog', 0.0, 26.0, Color(200, 205, 205, 205))
    --
    self.speed = 0.03
    self.z = 0
    A1_bg = self
    self.meetboss = false
end

function BG_A1_bg:frame()
    task.Do(self)
    self.z = self.z + self.speed
end

function BG_A1_bg:render()
    SetViewMode '3d'
    background.WarpEffectCapture()

    SetImageState('BG_A1_BLACK', '', Color(255, 0, 0, 0))
    Render4V('BG_A1_BLACK', -10, 0, 20,
             10, 0, 20,
             10, 0, -5,
             -10, 0, -5)
    SetImageState('BG_A1_BLACK', '', Color(255, 255, 255, 255))
    Render4V('BG_A1_BLACK', -20, 40, 40,
             20, 40, 40,
             20, -10, 40,
             -20, -10, 40)

    if self.meetboss == false then
        for j = -2, 3 do
            local dz = 6 * j - math.mod(self.z, 6)
            BG_A1_bg.renderground(dz)
        end
        local i = 3
        for j = -2, 3 do

            local dz = 6 * i - math.mod(self.z, 6)
            BG_A1_bg.rendernori(dz)
            BG_A1_bg.rendernori(dz + 0.1)
            i = i - 1
        end
    else
        -----boss战
        for j = -2, 4 do
            local dz = 6 * j - math.mod(self.z, 6)
            BG_A1_bg.renderground(dz)
        end

        local i = 1
        local dz = 6 * 4 - math.mod(self.z, 6)
        BG_A1_bg.renderShrine(dz)
        for j = -2, 1 do
            local dz = 6 * i - math.mod(self.z, 6)
            BG_A1_bg.rendernori(dz)
            BG_A1_bg.rendernori(dz + 0.1)
            i = i - 1
        end

    end

    background.WarpEffectApply()
    SetViewMode 'world'
end
local xl = 7
function BG_A1_bg.renderground(z)
    Render4V('BG_A1_c', -xl, 0, z + 1, xl, 0, z + 1, xl, 0, z - 1, -xl, 0, z - 1)
    Render4V('BG_A1_c', -xl, 0, z + 3, xl, 0, z + 3, xl, 0, z + 1, -xl, 0, z + 1)
    Render4V('BG_A1_c', -xl, 0, z - 1, xl, 0, z - 1, xl, 0, z - 3, -xl, 0, z - 3)
end
function BG_A1_bg.rendernori(z)
    ---SetImageState('BG_A1_d','',Color(255,0,0,0))
    RenderTexture('BG_A1_d', '',
                  { -3.3, 8, z + 2, 0, 0, Color(255, 0, 0, 0) },
                  { 3.3, 8, z + 2, 256, 0, Color(255, 0, 0, 0) },
                  { 3.3, 0, z + 1, 256, 222, Color(255, 50, 0, 0) },
                  { -3.3, 0, z + 1, 0, 222, Color(255, 50, 0, 0) })
    ----Render4V('BG_A1_d',-3,6,z+1.3,  3,6,z+1.3,  3,0,z+1,  -3,0,z+1)
end

function BG_A1_bg.renderShrine(z)
    RenderTexture('BG_A1_a', '',
                  { -6, 10, z + 2, 0, 0, Color(255, 255, 255, 255) },
                  { 6, 10, z + 2, 256, 0, Color(255, 255, 255, 255) },
                  { 6, -0.5, z + 1, 256, 222, Color(255, 255, 255, 255) },
                  { -6, -0.5, z + 1, 0, 222, Color(255, 255, 255, 255) })
end

---------------功能函数------------

------摄像机坐标改变(x,y,z)为终点坐标 false为不改变
function BG_A1_bg.eye_change(x, y, z, self, t)
    local x0 = lstg.view3d.eye[1]
    local y0 = lstg.view3d.eye[2]
    local z0 = lstg.view3d.eye[3]
    local tempx = x0
    local tempy = y0
    local tempz = z0
    local dx, dy, dz
    if x then
        dx = x - x0
    else
        dx = 0
    end
    if y then
        dy = y - y0
    else
        dy = 0
    end
    if z then
        dz = z - z0
    else
        dz = 0
    end
    task.New(self, function()
        for s = 1 / t, 1 + 0.5 / t, 1 / t do
            s = s * 2 - s * s
            if dx ~= 0 then
                x0 = tempx + s * dx
            end
            if dy ~= 0 then
                y0 = tempy + s * dy
            end
            if dz ~= 0 then
                z0 = tempz + s * dz
            end
            Set3D('eye', x0, y0, z0)
            coroutine.yield()
        end

    end)
end
------朝向坐标改变
function BG_A1_bg.at_change(x, y, z, self, t)
    local x0 = lstg.view3d.at[1]
    local y0 = lstg.view3d.at[2]
    local z0 = lstg.view3d.at[3]
    local tempx = x0
    local tempy = y0
    local tempz = z0
    local dx, dy, dz
    if x then
        dx = x - x0
    else
        dx = 0
    end
    if y then
        dy = y - y0
    else
        dy = 0
    end
    if z then
        dz = z - z0
    else
        dz = 0
    end
    task.New(self, function()
        for s = 1 / t, 1 + 0.5 / t, 1 / t do
            s = s * 2 - s * s
            if dx ~= 0 then
                x0 = tempx + s * dx
            end
            if dy ~= 0 then
                y0 = tempy + s * dy
            end
            if dz ~= 0 then
                z0 = tempz + s * dz
            end
            Set3D('at', x0, y0, z0)
            coroutine.yield()
        end
        --task.Clear(self)
    end)
end
------bossmeet
function BG_A1_bg.bossmeet(self, t)
    task.New(self, function()
        local tempv = self.speed
        BG_A1_bg.eye_change(false, 2.3, -17, self, 180)
        BG_A1_bg.at_change(false, 2.5, 1.7, self, 180)
        for i = 1, t do
            self.speed = self.speed - tempv / t
            coroutine.yield()
            task.Wait(1)
            if i == (t - 10) then
                A1_bg.meetboss = true
            end
        end
        BG_A1_bg.eye_change(false, 0.5, 1.4, self, 300)
        BG_A1_bg.at_change(false, 1.8, 9.4, self, 300)
        local a = 0.6
        task.Wait(300)
        BG_A1_bg.eye_change(false, 3.2, 1.4, self, 240)
        BG_A1_bg.at_change(false, 3, 9.4, self, 240)
        task.Wait(240)
        BG_A1_bg.eye_change(false, false, 7, self, 300)
        task.Wait(300)
        for i = 0, 65535 do
            Set3D('eye', 0.25 * sin(i / 4), 3.2, 6.5 + 0.5 * cos(i / 4))
            --BG_A1_bg.eye_change(0.4,2,2.4,self,300)
            --BG_A1_bg.eye_change(-0.4,false,2.4,self,300)
            task.Wait(1)
        end

    end)

end

