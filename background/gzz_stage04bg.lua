gzz_stage04bg_background = Class(object)

function gzz_stage04bg_background:init()
    --
    background.init(self, false)
    --resource
    LoadImageFromFile('gzz_stage03a', 'THlib\\background\\gzz_stage03bg\\gzz_stage03a.png')
    LoadTexture('gzz_stage03b', 'THlib\\background\\gzz_stage03bg\\gzz_stage03b.png')
    LoadImageGroup('china', 'gzz_stage03b', 1, 0, 255, 16, 1, 16)
    LoadImageFromFile('gzz_stage03g', 'THlib\\background\\gzz_stage03bg\\gzz_stage03g.png')
    LoadImageFromFile('gzz_stage03c', 'THlib\\background\\gzz_stage03bg\\gzz_stage03c.png')
    LoadTexture('gzz_stage03f', 'THlib\\background\\gzz_stage03bg\\gzz_stage03f.png')
    LoadImageGroup('gzz_3_light', 'gzz_stage03f', 0, 0, 32, 32, 4, 1)
    LoadTexture('gzz_stage03e', 'THlib\\background\\gzz_stage03bg\\gzz_stage03e.png')
    LoadImageGroup('gzz_3_cloud', 'gzz_stage03e', 0, 0, 256, 128, 1, 2)
    --set 3d camera and fog
    Set3D('eye', -0.67, 6.14, -9)
    Set3D('at', 1.71, 1.74, -0.3)
    Set3D('up', 0, 1, 0)
    Set3D('z', 1, 50)
    Set3D('fovy', 0.37)
    Set3D('fog', 8.5, 19.8, Color(255, 185, 188, 235))
    --
    self.speed = 0.015
    self.z = 0
    ---cloud
    self.list = {}
    self.liststart = 1
    self.listend = 0
    self.imgs = { 'gzz_3_cloud1', 'gzz_3_cloud2' }
    self.interval = 0.5
    self.acc = self.interval
end

function gzz_stage04bg_background:frame()
    self.z = self.z + self.speed
    self.acc = self.acc + self.speed

    if self.acc >= self.interval and self.timer % 100 == 0 then
        self.acc = self.acc - self.interval
        self.listend = self.listend + 1
        self.list[self.listend] = { 2, 1.6 + ran:Float(-1.3, 0.2), 0.8 + ran:Float(-0.2, 0.5), 12 + ran:Float(0, 5), 1.6 + ran:Float(-1, 0), ran:Int(0, 360) }
        self.listend = self.listend + 1
        self.list[self.listend] = { 1, 1.6 + ran:Float(-0.2, 1.3), 0.7 + ran:Float(-0.2, 0.5), 12 + ran:Float(0, 5), 1.6 + ran:Float(0, 1), ran:Int(0, 360) }
    end
    for i = self.liststart, self.listend do
        self.list[i][4] = self.list[i][4] - self.speed
        self.list[i][2] = self.list[i][5] + 0.5 * sin(self.timer / 3.5 + self.list[i][6])
        --[[
        if self.list[i][4]<3 then
        if self.list[i][1]==1 then
            self.list[i][2]=self.list[i][2]-0.005
        elseif self.list[i][1]==2 then
            self.list[i][2]=self.list[i][2]+0.005
        end
        end
        ]]
    end
    while true do
        if self.list[self.liststart][4] < -6 then
            self.list[self.liststart] = nil
            self.liststart = self.liststart + 1
        else
            break
        end
    end
end

function gzz_stage04bg_background:render()
    SetViewMode '3d'
    background.WarpEffectCapture()
    RenderClear(lstg.view3d.fog[3])

    do
        for j = -4, 5 do
            local dz = j * 2 - math.mod(self.z, 2)
            gzz_stage03bg.renderfloor(dz)
        end
        for j = -4, 5 do
            local dz = j * 2 - math.mod(self.z, 2)
            local t = self.timer
            gzz_stage03bg.renderlightR(4.135, 1, dz, 1.5, t)
        end
        for j = -4, 5 do
            local dz = j * 2 - math.mod(self.z, 2)
            gzz_stage03bg.renderwall(dz)

        end
        for j = -4, 5 do
            local dz = j * 4 - math.mod(self.z, 4)
            local t = self.timer
            gzz_stage03bg.renderlightL(3.625, 1, dz, 1.5, t)
        end
        for j = -4, 5 do
            local dz = j * 2 - math.mod(self.z, 2)
            gzz_stage03bg.renderstone(dz)

        end
        local offset = 0.2
        for j = -4, 5 do
            local dz = j * 2 - math.mod(self.z, 2)
            gzz_stage03bg.renderchina(2.65, 5.0, 2 + 2 + offset, 2.5 + 2.5 + offset, 2, dz)
        end
    end
    for i = self.listend, self.liststart, -1 do
        local p = self.list[i]
        SetImageState('gzz_3_cloud1', '', Color(255, 255, 255, 255))
        SetImageState('gzz_3_cloud2', '', Color(255, 255, 255, 255))
        Render(self.imgs[p[1]], p[2], p[3], 0, 0.8, 0.8, p[4])
        --Render(self.imgs[1],0,0,0,1,1,0)
    end

    background.WarpEffectApply()
    SetViewMode 'world'
end

function gzz_stage04bg_background.renderfloor(z)
    Render4V('gzz_stage03a', 4, 0, z - 1, 8, 0, z - 1, 8, 0, z + 1, 4, 0, z + 1)
    Render4V('gzz_stage03a', 0, 0, z - 1, 4, 0, z - 1, 4, 0, z + 1, 0, 0, z + 1)
    --Render4V('gzz_stage03a',0,0,z-1,-4,0,z-1,-4,0,z+1,0,0,z+1)
end

function gzz_stage04bg_background.renderstone(z)
    Render4V('gzz_stage03g', 3.05, 2.25, z, 3.25, 2.25, z, 3.25, 0, z, 3.05, 0, z)
    Render4V('gzz_stage03g', 3.05, 2.25, z + 2, 3.25, 2.25, z + 2, 3.25, 0, z + 2, 3.05, 0, z + 2)
end
function gzz_stage04bg_background.renderwall(z)
    Render4V('gzz_stage03c', 4, 2, z - 1, 4, 2, z + 1, 4, 0, z + 1, 4, 0, z - 1)
end

function gzz_stage04bg_background.renderchina(x1, x2, y1, y2, r, z)
    local i = 1
    for angle = -120, -67.5, 7.5 do
        local z01 = z + 1 + 2 * cos(angle)
        local y01 = y1 + 2 * sin(angle)
        local y11 = y2 + 2 * sin(angle)
        local z02 = z + 1 + 2 * cos(angle + 7.5)
        local y02 = y1 + 2 * sin(angle + 7.5)
        local y12 = y2 + 2 * sin(angle + 7.5)
        Render4V('china' .. i, x1, y01, z01,
                 x2, y11, z01,
                 x2, y12, z02,
                 x1, y02, z02)
        i = i + 1
    end
end

function gzz_stage04bg_background.renderlightL(x, y, z, size, t)
    SetImageState('gzz_3_light1', 'mul+alpha', Color(255, 255, 189, 255))
    SetImageState('gzz_3_light2', 'mul+add', Color(150 + 60 * sin(t * 2), 255, 255, 255))
    Render('gzz_3_light1', x, y, 0, 3, 3, z)
    Render('gzz_3_light2', x, y, 0, size, size, z)
end

function gzz_stage04bg_background.renderlightR(x, y, z, size, t)
    SetImageState('gzz_3_light1', 'mul+alpha', Color(250, 255, 189, 255))
    SetImageState('gzz_3_light2', 'mul+add', Color(150 + 60 * sin(t * 2), 255, 255, 255))
    Render('gzz_3_light1', x, y, 0, 3, 3, z)
    Render('gzz_3_light2', x, y, 0, size, size, z)
    Render('gzz_3_light1', x, y, 0, 3, 3, z + 2)
    Render('gzz_3_light2', x, y, 0, size, size, z + 2)
end

