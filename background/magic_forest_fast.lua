magic_forest_fast_background = Class(background)

function magic_forest_fast_background:init()
    background.init(self, false)
    LoadTexture('magic_forest_ground', 'THlib\\background\\magic_forest_fast\\ground.png')
    LoadImage('magic_forest_ground', 'magic_forest_ground', 0, 0, 512, 512)
    LoadTexture('magic_forest_mask', 'THlib\\background\\magic_forest_fast\\mask.png')
    LoadImage('magic_forest_mask', 'magic_forest_mask', 0, 0, 256, 256)
    Set3D('z', 1.8, 4.5)
    Set3D('eye', 0.25, -2.2, 1.1)
    Set3D('at', 0.2, 0, 0)
    Set3D('up', 0, 0, 1)
    Set3D('fovy', 0.35)
    Set3D('fog', 0, 0, Color(0x00000000))
    self.yos = 0
    self.speed = 0.06
end

function magic_forest_fast_background:frame()
    self.yos = self.yos + self.speed
end

function magic_forest_fast_background:render()
    SetViewMode '3d'
    background.WarpEffectCapture()
    RenderClear(lstg.view3d.fog[3])
    local y = self.yos % 1
    for i = -1, 2 do
        Render4V('magic_forest_ground', 0, 0 - y + i, 0, 0, 1 - y + i, 0, 1, 1 - y + i, 0, 1, -y + i, 0)
        Render4V('magic_forest_ground', -1, 0 - y + i, 0, -1, 1 - y + i, 0, 0, 1 - y + i, 0, 0, -y + i, 0)
    end
    for i = -1, 3 do
        Render4V('magic_forest_mask', 0, 0 - y + i, -0.2, 0, 1 - y + i, -0.2, 1, 1 - y + i, -0.2, 1, -y + i, -0.2)
        Render4V('magic_forest_mask', -1, 0 - y + i, -0.2, -1, 1 - y + i, -0.2, 0, 1 - y + i, -0.2, 0, -y + i, -0.2)
    end

    background.WarpEffectApply()
    SetViewMode 'world'
end
