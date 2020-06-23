lake_background = Class(background)

function lake_background:init()
    background.init(self, false)
    LoadTexture('lake_leaf', 'THlib\\background\\lake\\lake_1.png')
    LoadImage('lake_leaf', 'lake_leaf', 0, 0, 256, 256)
    LoadTexture('lake_b1', 'THlib\\background\\lake\\lake_2.png')
    LoadImage('lake_b1', 'lake_b1', 0, 0, 256, 256)
    LoadTexture('lake_b2', 'THlib\\background\\lake\\lake_3.png')
    LoadImage('lake_b2', 'lake_b2', 0, 0, 256, 256)
    SetImageState('lake_b1', 'mul+add', Color(0x60FFFFFF))
    Set3D('z', 1.8, 4.5)
    Set3D('eye', 0.35, -2.2, 2)
    Set3D('at', 0.1, 0, -0.4)
    Set3D('up', 0.2, 0, 0.6)
    Set3D('fovy', 0.35)
    Set3D('fog', 0, 0, Color(0x00000000))
    self.yos = 0
    self.speed = 0.001
end

function lake_background:frame()
    self.yos = self.yos + self.speed
end

function lake_background:render()
    Set3D('z', 1.8, 4.5)
    Set3D('eye', 0.35, -2.2, 2)
    Set3D('at', 0.1, 0, -0.4)
    Set3D('up', 0.2, 0, 0.6)
    Set3D('fovy', 0.35)
    SetViewMode '3d'
    background.WarpEffectCapture()

    RenderClear(lstg.view3d.fog[3])
    local y = self.yos % 1
    local yy = (self.yos % 1) / 2
    for i = -4, 6 do
        Render4V('lake_b2', 0, 0 - y + i, -0.2, 0, 1 - y + i, -0.2, 1, 1 - y + i, -0.2, 1, -y + i, -0.2)
        Render4V('lake_b2', -1, 0 - y + i, -0.2, -1, 1 - y + i, -0.2, 0, 1 - y + i, -0.2, 0, -y + i, -0.2)
    end
    for i = -4, 6 do
        Render4V('lake_b1', -0.15 - yy + i, -0.15, 0, -0.15 - yy + i, -1.15, 0, -1.15 - yy + i, -1.15, 0, -1.15 - yy + i, -0.15, 0)
        Render4V('lake_b1', 0.85 - yy + i, 0.85, 0, 0.85 - yy + i, -0.15, 0, -0.15 - yy + i, -0.15, 0, -0.15 - yy + i, 0.85, 0)
        Render4V('lake_b1', 0, 0 - y + i, 0, 0, 1 - y + i, 0, 1, 1 - y + i, 0, 1, -y + i, 0)
        Render4V('lake_b1', -1, 0 - y + i, 0, -1, 1 - y + i, 0, 0, 1 - y + i, 0, 0, -y + i, 0)
    end
    for i = -4, 6 do
        Render4V('lake_leaf', 0.5, 0 - yy + i / 2, 0, 0.5, 0.5 - yy + i / 2, 0, 1, 0.5 - yy + i / 2, 0, 1, -yy + i / 2, 0)
        Render4V('lake_leaf', 0, 0 - yy + i / 2, 0, 0, 0.5 - yy + i / 2, 0, 0.5, 0.5 - yy + i / 2, 0, 0.5, -yy + i / 2, 0)
        Render4V('lake_leaf', -0.5, 0 - yy + i / 2, 0, -0.5, 0.5 - yy + i / 2, 0, 0, 0.5 - yy + i / 2, 0, 0, -yy + i / 2, 0)
        Render4V('lake_leaf', -1, 0 - yy + i / 2, 0, -1, 0.5 - yy + i / 2, 0, -0.5, 0.5 - yy + i / 2, 0, -0.5, -yy + i / 2, 0)
    end

    background.WarpEffectApply()
    SetViewMode 'world'
end
