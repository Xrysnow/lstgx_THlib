BALL = Class(object)

function BALL:init()
    --
    background.init(self, false)
    --resource
    LoadImageFromFile('surface', 'THlib\\background\\ball\\surface.png')
    LoadImageFromFile('surfacell', 'THlib\\background\\ball\\surfacell.png')
    LoadImageFromFile('surfacell_', 'THlib\\background\\ball\\surfacell_.png')
    LoadImageFromFile('red', 'THlib\\background\\ball\\rectangle\\06.png')
    LoadImageFromFile('orange', 'THlib\\background\\ball\\rectangle\\05.jpg')
    LoadImageFromFile('yellow', 'THlib\\background\\ball\\rectangle\\04.png')
    LoadImageFromFile('blue', 'THlib\\background\\ball\\rectangle\\03.jpg')
    LoadImageFromFile('green', 'THlib\\background\\ball\\rectangle\\02.jpg')
    LoadImageFromFile('white', 'THlib\\background\\ball\\rectangle\\01.jpg')

    self.imglist = { 'red', 'orange', 'yellow', 'blue', 'green', 'white' }

    SetImageState(self.imglist[3], 'mul+add', Color(0xBF33FF00))
    SetImageState(self.imglist[5], 'mul+add', Color(0xB066FFCC))
    SetImageState(self.imglist[4], 'mul+add', Color(0xBF66FFCC))
    SetImageState(self.imglist[6], 'mul+add', Color(0xFFFFFFFF))
    SetImageState(self.imglist[1], 'mul+add')
    SetImageState(self.imglist[2], 'mul+add', Color(0xFFFFFFFF))
    SetImageState('surface', 'mul+add')
    SetImageState('surfacell', 'mul+add', Color(0xFF9900FF))
    SetImageState('surfacell_', 'mul+add', Color(0xFF66FFCC))
    --set 3d camera and fog
    Set3D('eye', 0, 20, 0)
    Set3D('at', 0, 1.7, 0)
    Set3D('up', 0, 1, 0)
    Set3D('z', 1, 10000)
    Set3D('fovy', 0.6)
    Set3D('fog', 1000, 1000, Color(0x8033FF00))
    --
    self.speed = 0
    self.z = 0
    self.angle_1 = 0
    self.angle_2 = 0
    self.angle_3 = 0
    self.rend_R = 3
    --rend_R1 = 2.6
end

function BALL:frame()
    --SIN_ = 0.5 * sin(self.timer * 1.5)
    --SIN_1 = 0.5 * sin(self.timer * 1.5 + 30)
    --SIN_2 = 0.5 * sin(self.timer * 1.5 + 45)
    --SIN_3 = 0.5 * sin(self.timer * 1.5 + 90)
    self.z = self.z + self.speed
    Set3D('eye', 23 * cos(self.angle_2), 15 + 7 * sin(self.timer / 20), 15 * sin(self.angle_2))
    self.angle_1 = self.angle_1 + 0.1
    self.angle_3 = self.angle_3 - 1
    self.angle_2 = self.angle_2 - 0.1
    if self.rend_R <= 15 and self.timer > 120 then
        self.rend_R = self.rend_R + 0.05
    end
    Set3D('eye', 3.70, 3.4, 3.7 * sin(self.timer))
end

function BALL:render()
    SetViewMode '3d'
    background.WarpEffectCapture()

    Magic_RingRender_V_('blue', 0, 2, 0, self.rend_R, self.angle_1)
    --Magic_RingRender_V_('surfacell',0,0,0,rend_R,self.angle_3)
    --Magic_RingRender_H_('surfacell_',0,0,0,rend_R1,self.angle_3)
    Magic_RingRender_V_(self.imglist[3], 0, 4, 0, 25, self.angle_2)

    background.WarpEffectApply()
    SetViewMode 'world'
end

function Get_point(i, j, r)
    local point = {}
    local x = r * sin(i) * cos(j)
    local y = 3 + r * sin(i) * sin(j)
    local z = r * cos(i)
    point[1] = x
    point[2] = y
    point[3] = z
    return point
end

function Get_point4(R, angle, range)
    local x0 = R * cos(angle)
    local y0 = 0.3 + R * sin(angle)
    local x1 = x0 + range * cos(angle - 45)
    local y1 = y0 + range * sin(angle - 45)
    local x2 = x0 + range * cos(angle - 45 + 90)
    local y2 = y0 + range * sin(angle - 45 + 90)
    local x3 = x0 + range * cos(angle - 45 + 90 + 90)
    local y3 = y0 + range * sin(angle - 45 + 90 + 90)
    local x4 = x0 + range * cos(angle - 45 + 90 + 90 + 90)
    local y4 = y0 + range * sin(angle - 45 + 90 + 90 + 90)
    local point = {}
    point[1] = { x1, y1 }
    point[2] = { x2, y2 }
    point[3] = { x3, y3 }
    point[4] = { x4, y4 }
    return (point)
end

function Magic_RingRender_V_(img, x, y, z, R, rot)
    local x0 = x
    local z0 = z
    local y0 = y
    local x1 = x0 + R * cos(rot - 45)
    local z1 = z0 + R * sin(rot - 45)
    local x2 = x0 + R * cos(rot - 45 + 90)
    local z2 = z0 + R * sin(rot - 45 + 90)
    local x3 = x0 + R * cos(rot - 45 + 90 + 90)
    local z3 = z0 + R * sin(rot - 45 + 90 + 90)
    local x4 = x0 + R * cos(rot - 45 + 90 + 90 + 90)
    local z4 = z0 + R * sin(rot - 45 + 90 + 90 + 90)
    local point = {}
    point[1] = { x1, y0, z1 }
    point[2] = { x2, y0, z2 }
    point[3] = { x3, y0, z3 }
    point[4] = { x4, y0, z4 }
    Render4V(img,
             point[1][1], point[1][2], point[1][3],
             point[2][1], point[2][2], point[2][3],
             point[3][1], point[3][2], point[3][3],
             point[4][1], point[4][2], point[4][3])
end

function Magic_RingRender_H_(img, x, y, z, R, rot)
    local x0 = x
    local z0 = z
    local y0 = y
    local x1 = x0 + R * cos(rot - 45)
    local y1 = y0 + R * sin(rot - 45)
    local x2 = x0 + R * cos(rot - 45 + 90)
    local y2 = y0 + R * sin(rot - 45 + 90)
    local x3 = x0 + R * cos(rot - 45 + 90 + 90)
    local y3 = y0 + R * sin(rot - 45 + 90 + 90)
    local x4 = x0 + R * cos(rot - 45 + 90 + 90 + 90)
    local y4 = y0 + R * sin(rot - 45 + 90 + 90 + 90)
    local point = {}
    point[1] = { x1, y1, z0 }
    point[2] = { x2, y2, z0 }
    point[3] = { x3, y3, z0 }
    point[4] = { x4, y4, z0 }
    Render4V(img,
             point[1][1], point[1][2], point[1][3],
             point[2][1], point[2][2], point[2][3],
             point[3][1], point[3][2], point[3][3],
             point[4][1], point[4][2], point[4][3])
end

