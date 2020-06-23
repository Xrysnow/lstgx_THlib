LoadTexture('iceboard', 'THlib\\background\\icepool\\board.png')
LoadImage('iceboard', 'iceboard', 0, 0, 512, 512)
SetImageState('iceboard', 'mul+add')
icepool_background = Class(background)

function icepool_background:init()
    background.init(self, false)
    LoadTexture('icepool', 'THlib\\background\\icepool\\ice.png')
    LoadImage('icepool', 'icepool', 0, 0, 460, 460)
    Set3D('z', 1.8, 4.5)
    Set3D('eye', -0.05, -2.3, 1.1)
    Set3D('at', 0, 0, 0)
    Set3D('up', 0, 0, 1)
    Set3D('fovy', 0.35)
    Set3D('fog', 0, 0, Color(0x00000000))
    self.yos = 0
    self.speed = 0.008
    self.eye = -0.05
    stagebackground = 0
end

function icepool_background:frame()
    self.yos = self.yos + self.speed
    if stagebackground == 1 and self.eye <= 0.35 then
        self.eye = self.eye + 0.002
        Set3D('eye', self.eye, -2.3, 1.1)
    end
    if stagebackground == 2 and self.eye >= -0.35 then
        self.eye = self.eye - 0.002
        Set3D('eye', self.eye, -2.3, 1.1)
    end
    if stagebackground == 3 then
        self.speed = 0.003
    end
    if stagebackground == 4 then
        self.speed = 0.008
    end
end

function icepool_background:render()
    SetViewMode '3d'
    background.WarpEffectCapture()

    RenderClear(lstg.view3d.fog[3])
    local y = self.yos % 1
    for i = -1, 2 do
        Render4V('icepool', 0, 0 - y + i, 0, 0, 1 - y + i, 0, 1, 1 - y + i, 0, 1, -y + i, 0)
        Render4V('icepool', -1, 0 - y + i, 0, -1, 1 - y + i, 0, 0, 1 - y + i, 0, 0, -y + i, 0)
    end

    background.WarpEffectApply()
    SetViewMode 'world'
end
