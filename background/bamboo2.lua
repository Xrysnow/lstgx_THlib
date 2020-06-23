bamboo2_background = Class(object)

function bamboo2_background:init()
    --
    background.init(self, false)
    --resource
    LoadTexture('bamboo_ground2', 'THlib\\background\\bamboo2\\ground2.png')
    LoadImage('bamboo_ground2', 'bamboo_ground2', 0, 0, 256, 256, 0, 0)
    LoadTexture('bamboo2', 'THlib\\background\\bamboo2\\bamboo2.png')
    LoadImage('trunk2', 'bamboo2', 488, 0, 22, 512, 0, 0)

    SetImageCenter('trunk2', 12, 512)
    LoadImage('leave3', 'bamboo2', 0, 0, 256, 256, 0, 0)
    LoadImage('leave4', 'bamboo2', 0, 256, 320, 256, 0, 0)
    SetImageState('leave3', 'mul+add')
    SetImageState('leave4', 'mul+add')
    --set 3d camera and fog
    Set3D('eye', 0, 4.8, -8.9)
    Set3D('at', 0.1, 1.5, -0.60)
    Set3D('up', 0, 1.1, 0.1)
    Set3D('z', 2.1, 24)
    Set3D('fovy', 0.7)
    Set3D('fog', 7, 20, Color(0xFF000000))
    --
    self.list = {}
    self.liststart = 1
    self.listend = 0
    self.imgs = { 'trunk2', 'leave3', 'leave4' }
    self.speed = 0.3
    self.interval = 0.5
    self.acc = self.interval
    for i = 1, 400 do
        bamboo_background.frame(self)
    end
end

rnd = math.random

function bamboo2_background:frame()
    self.acc = self.acc + self.speed
    if self.acc >= self.interval then
        self.acc = self.acc - self.interval
        self.listend = self.listend + 1
        self.list[self.listend] = { 1, 0.9 + rnd() * 3, 0, rnd() * 0.4 - 0.2, 0.7 + 0.3 * rnd(), 24 + 0.1 * rnd() }
        self.listend = self.listend + 1
        self.list[self.listend] = { 1, -0.9 - rnd() * 3, 0, rnd() * 0.4 - 0.2, 0.7 + 0.3 * rnd(), 24 + 0.1 * rnd() }
        self.acc = self.acc - self.interval
        self.listend = self.listend + 1
        self.list[self.listend] = { rnd(2, 3), 1.5 + rnd() * 2, 1.6 + rnd(), rnd() * 0.6 - 0.3, -0.7 - 0.3 * rnd(), 24 + 0.1 * rnd() }
        self.listend = self.listend + 1
        self.list[self.listend] = { rnd(2, 3), -1.5 - rnd() * 2, 1.6 + rnd(), rnd() * 0.6 - 0.3, 0.7 + 0.3 * rnd(), 24 + 0.1 * rnd() }
    end
    for i = self.liststart, self.listend do
        self.list[i][6] = self.list[i][6] - self.speed
    end
    while true do
        if self.list[self.liststart][6] < -6 then
            self.list[self.liststart] = nil
            self.liststart = self.liststart + 1
        else
            break
        end
    end
end

function bamboo2_background:render()
    SetViewMode '3d'
    background.WarpEffectCapture()
    RenderClear(lstg.view3d.fog[3])

    for j = 0, 6 do
        local dz = j * 4 - math.mod(self.timer * self.speed, 4)
        for i = -2, 1 do
            Render4V('bamboo_ground2', i * 4, 0, dz, 4 + i * 4, 0, dz, 4 + i * 4, 0, -4 + dz, i * 4, 0, -4 + dz)
        end
    end
    for i = self.listend, self.liststart, -1 do
        local p = self.list[i]
        Render(self.imgs[p[1]], p[2], p[3], p[4] * 57, p[5], abs(p[5]), p[6])
        --Render(self.imgs[1],0,0,0,1,1,0)
    end

    background.WarpEffectApply()
    SetViewMode 'world'
end
