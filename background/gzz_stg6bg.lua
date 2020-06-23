gzz_stg6bg_background = Class(object)

function gzz_stg6bg_background:init()
    background.init(self, false)
    LoadImageFromFile('gzz6bg3', 'THlib\\background\\gzz_stg6bg\\gzz6bg3.png')
    SetImageState('gzz6bg3', 'mul+add', Color(0xA0FF0000))
    LoadImageFromFile('gzz6bg2', 'THlib\\background\\gzz_stg6bg\\gzz6bg2.png')
    SetImageState('gzz6bg2', 'mul+add', Color(0xA0FFFFFF))
    LoadImageFromFile('gzz6bg1', 'THlib\\background\\gzz_stg6bg\\gzz6bg1.png')
    SetImageState('gzz6bg1', '', Color(0x50FFFFFF))
    LoadImageFromFile('gzz6bg4', 'THlib\\background\\gzz_stg6bg\\gzz6bg4.png')
    LoadTexture('_gzz6bg5', 'THlib\\background\\gzz_stg6bg\\gzz6bg5.png')
    LoadImageGroup('gzz6bg5', '_gzz6bg5', 0, 0, 256, 32, 1, 8)
    for i = 1, 8 do
        SetImageState('gzz6bg5' .. i, 'mul+add', Color(0x40FFFFFF))
    end
    SetImageState('gzz6bg4', '', Color(0xFFFFFFFF))
    --set camera
    Set3D('eye', 0.00, 1.60, -1.40)
    Set3D('at', 0.00, 0.00, -0.20)
    Set3D('up', 0.00, 1.00, 0.00)
    Set3D('fovy', 0.62)
    Set3D('z', 1.00, 4.80)
    Set3D('fog', 2.00, 2.20, Color(0, 0, 0, 0))
    --
    self.zos = 0
    self.speed = 0.002
    self.changed = false
    gzz_stg6bg = self
    self.r1 = 0
    self.r2 = 0
    self.r3 = 0
    --
    --New(camera_setter)
end

function gzz_stg6bg_background:frame()
    task.Do(self)
    self.zos = self.zos + self.speed
    if self.timer < 600 then
        Set3D('fog', 2.0, 2.2 + 0.7 * self.timer / 600, Color(0, 0, 0, 0))
        Set3D('eye', 0, 1.6 - 0.6 * self.timer / 600, -1.4)
    end
    if self.timer > 3178 and self.timer < 3778 then
        local i = self.timer - 3178
        Set3D('fog', 2.0 + 0.4 * i / 600, 2.9, Color(0, 0, 0, 0))
        Set3D('eye', 0, 1.0 - 0.55 * i / 600, -1.4)
    end
    if self.timer > 3778 then
        self.r2 = self.r2 + 1.25
        if self.r2 > 750 then
            self.r2 = 0
        end
    end
    if self.timer > 3778 + 250 then
        self.r1 = self.r1 + 1.25
        if self.r1 > 750 then
            self.r1 = 0
        end
    end
    if self.timer > 3778 + 500 then
        self.r3 = self.r3 + 1.25
        if self.r3 > 750 then
            self.r3 = 0
        end
    end
end

function gzz_stg6bg_background:render()
    SetViewMode '3d'
    background.WarpEffectCapture()
    RenderClear(lstg.view3d.fog[3])
    local z = self.zos % 1
    --	Render4V('gzz6bg4',-1,0.5,2, 2,0.5,2, 2,-1.5,2,-1,-1.5,2)
    for i = -1, 2 do
        Render4V('gzz6bg1', -3, -0.6, 1 - z + i, -1, -0.6, 1 - z + i, -1, -0.6, 0 - z + i, -3, -0.6, 0 - z + i)
        Render4V('gzz6bg1', -1, -0.6, 1 - z + i, 2, -0.6, 1 - z + i, 2, -0.6, 0 - z + i, -1, -0.6, 0 - z + i)
    end
    for i = -1, 2 do
        Render4V('gzz6bg2', 0, -0.4, 0.8 - z + i, 2, -0.4, 0.8 - z + i, 2, -0.4, -0.2 - z + i, 0, -0.4, -0.2 - z + i)
        Render4V('gzz6bg2', -2, -0.4, 0.8 - z + i, 0, -0.4, 0.8 - z + i, 0, -0.4, -0.2 - z + i, -2, -0.4, -0.2 - z + i)
    end
    for i = -1, 2 do
        Render4V('gzz6bg3', -2, -0.3, 1 - z + i, 2, -0.3, 1 - z + i, 2, -0.3, 0 - z + i, -2, -0.3, 0 - z + i)
        Render4V('gzz6bg3', -2, -0.3, 1 - z + i, 2, -0.3, 1 - z + i, 2, -0.3, 0 - z + i, -2, -0.3, 0 - z + i)
    end
    for i = -1, 2 do
        Render4V('gzz6bg2', 0, -0.2, 1 - z + i, 2, -0.2, 1 - z + i, 2, -0.2, 0 - z + i, 0, -0.2, 0 - z + i)
        Render4V('gzz6bg2', -2, -0.2, 1 - z + i, 0, -0.2, 1 - z + i, 0, -0.2, 0 - z + i, -2, -0.2, 0 - z + i)
    end
    Render4V('gzz6bg4', -0.67, 0.4, 1, 1.13, 0.4, 1, 1.13, -0.1, 1, -0.67, -0.1, 1)

    background.WarpEffectApply()
    SetViewMode 'world'
    if self.changed == true then
        misc.RenderRing('gzz6bg5', 0, 195, max(self.r1 - 250, 0), min(self.r1, 500), 0, 16, 8)
        misc.RenderRing('gzz6bg5', 0, 195, max(self.r2 - 250, 0), min(self.r2, 500), 0, 16, 8)
        misc.RenderRing('gzz6bg5', 0, 195, max(self.r3 - 250, 0), min(self.r3, 500), 0, 16, 8)
    end

end
function gzz_stg6bg_background.bossmeet(self)
    --[[	task.New(self,function()
    --		for i=1,600 do
    --			Set3D('fog',2.0+0.4*i/600,2.9,Color(0,0,0,0))
    --			Set3D('eye',0,1.0-0.55*i/600,-1.4)
    --			task.Wait(1)
    --		end
    --		self.changed=true
            task.Wait(600)
            task.New(self,function()
                    task.Wait(250)
                    for i=1,_infinite do
                        self.r1=self.r1+1.25
                        if self.r1>750 then self.r1=0 end
                    task.Wait(1)
                    end

            end)
            task.New(self,function()
                    task.Wait(500)
                    for i=1,_infinite do
                        self.r3=self.r3+1.25
                        if self.r3>750 then self.r3=0 end
                    task.Wait(1)
                    end

            end)
            for i=1,_infinite do
                self.r2=self.r2+1.25
                if self.r2>750 then self.r2=0 end
                task.Wait(1)
            end
        end)
    ]]
end
