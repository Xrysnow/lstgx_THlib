galaxy_background = Class(background)

function galaxy_background:init()
    background.init(self, false)
    LoadImageFromFile('galaxy', 'THlib\\background\\galaxy\\galaxy.png')
    LoadImageFromFile('galaxy2', 'THlib\\background\\galaxy\\timg.jpg')
    Set3D('z', 0.8, 8)
    Set3D('eye', 0.0, -2, 0)
    Set3D('at', 0, 0, 2)
    Set3D('up', 0, 1, 0)
    Set3D('fovy', 0.35)
    Set3D('fog', 0, 0, Color(0x00000000))
    self.yos = 0
    self.speed = 0.03
end

function galaxy_background:frame()
    self.rot = self.rot - 0.03
end

function galaxy_background:render()
    --	SetViewMode'world'
    --	Render('galaxy2',0,0,0,0.7)
    SetViewMode '3d'
    background.WarpEffectCapture()

    --	RenderClear(lstg.view3d.fog[3])
    local rot = self.rot
    SetViewMode 'world'
    Render('galaxy2', 0, 0, 0, 0.7)
    SetViewMode '3d'
    Render4V('galaxy',
             cos(rot), sin(rot), 2,
             cos(rot - 90), sin(rot - 90), 2,
             cos(rot - 180), sin(rot - 180), 2,
             cos(rot - 270), sin(rot - 270), 2
    )

    background.WarpEffectApply()
    SetViewMode 'world'
end
