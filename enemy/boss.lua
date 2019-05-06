--

local int = int
local abs = abs
local min = min
local max = max
local sin = sin
local cos = cos
local task = task
local Kill = Kill
local Del = Del
local misc = misc
local Color = Color
local New = New
local IsValid = IsValid
local DefaultRenderFunc = DefaultRenderFunc
local PlaySound = PlaySound

LoadTexture('boss', 'THlib\\enemy\\boss.png')
LoadImageGroup('bossring1', 'boss', 80, 0, 16, 8, 1, 16)--Border of life
for i = 1, 16 do
    SetImageState('bossring1' .. i, 'mul+add', Color(0x80FFFFFF))
end
LoadImageGroup('bossring2', 'boss', 48, 0, 16, 8, 1, 16)--浅紫色
for i = 1, 16 do
    SetImageState('bossring2' .. i, 'mul+add', Color(0x80FFFFFF))
end
LoadImage('spell_card_ef', 'boss', 96, 0, 16, 128)
LoadImage('hpbar', 'boss', 116, 0, 8, 128)
--LoadImage('hpbar1','boss',116,0,2,2)
LoadImage('hpbar2', 'boss', 116, 0, 2, 2)
SetImageCenter('hpbar', 0, 0)
--封兽球
LoadTexture('undefined', 'THlib\\enemy\\undefined.png')
LoadImage('undefined', 'undefined', 0, 0, 128, 128, 16, 16)
SetImageState('undefined', 'mul+add', Color(0x80FFFFFF))

LoadImageFromFile('base_hp', 'THlib\\enemy\\ring00.png')
SetImageState('base_hp', '', Color(0xFFFF0000))
LoadTexture('lifebar', 'THlib\\enemy\\lifebar.png')
LoadImage('life_node', 'lifebar', 20, 0, 12, 16)
LoadImage('hpbar1', 'lifebar', 4, 0, 2, 2)
SetImageState('hpbar1', '', Color(0xFFFFFFFF))
SetImageState('hpbar2', '', Color(0x77D5CFFF))
LoadTexture('magicsquare', 'THlib\\enemy\\eff_magicsquare.png')
LoadImageGroup('boss_aura_3D', 'magicsquare', 0, 0, 256, 256, 5, 5)
LoadImageFromFile('dialog_box', 'THlib\\enemy\\dialog_box.png')

--

---@class THlib.boss:THlib.enemybase
boss = Class(enemybase)

function boss:init(x, y, name, cards, bg)
    enemybase.init(self, 999999999)
    self.x = x
    self.y = y
    self.img = 'undefined'--当前要渲染的图像
    self.ani_intv = 8
    self.lr = 1
    self.cast = 0
    self.aura_alpha = 255
    self.aura_alpha_d = 4

    --符卡/非符/move/escape
    self.cards = cards
    self.card_num = 0--当前符卡/非符序号
    self.dmg_factor = 0--伤害系数
    self.ui = New(boss_ui, self)
    self.ui.name = name or ''
    self.last_card = 1
    self.ui.sc_left = 0--剩余符卡数
    self.cast_t = 0
    self.sc_pro = 0
    self.lifepoint = 160
    self.hp_flag = 0
    self.sp_point = { }
    self.sc_bonus_max = item.sc_bonus_max--2000000
    self.sc_bonus_base = item.sc_bonus_base--1000000
    if self.difficulty == nil then
        self.difficulty = 'All'
    end
    for i, c in pairs(cards) do
        if c.is_combat then
            self.last_card = i
        end
        if c.is_sc then
            self.ui.sc_left = self.ui.sc_left + 1
        end
    end
    self.bg = bg
    lstg.tmpvar.boss = self

    --当前boss，全局变量
    _boss = self
    --if self.class.bgm ~= "" then
    --    LoadMusicRecord(self.class.bgm)
    --    _play_music(self.class.bgm)
    --end
    Kill(self)
    --open the first spell card. (= =|||)
end

function boss:frame()
    --enemybase.frame(self)
    self.hp = max(0, self.hp)
    SetAttr(self, 'colli', BoxCheck(
            self, lstg.world.boundl, lstg.world.boundr, lstg.world.boundb, lstg.world.boundt
    ) and self._colli)
    if self.hp <= 0 then
        if self.card_num == self.last_card and not (self.no_killeff) and not (self.killed) then
            --击破终符
            self.killed = true
            self.no_killeff = true
            local c = self.cards[self.card_num]
            task.Clear(c)
            task.Clear(self)
            PlaySound("enep01", 0.5, self.x / 256)
            self.colli = false
            self.hp = 0
            self.lr = 28
            task.New(self, function()
                local angle = ran:Float(10, 20)
                self.vx = 0.3 * cos(angle)
                self.vy = 0.3 * sin(angle)
                New(bullet_cleaner, self.x, self.y, 1500, 120, 60, true, true, 0)
                for i = 1, 120 do
                    self.hp = 0
                    self.timer = self.timer - 1
                    local lifetime = ran:Int(60, 90)
                    local l = ran:Float(200, 500)
                    New(boss_death_ef_unit, self.x, self.y, l / lifetime,
                            ran:Float(0, 360), lifetime, ran:Float(2, 3))
                    task.Wait(1)
                end
                New(deatheff, self.x, self.y, 'first')
                New(deatheff, self.x, self.y, 'second')
                Kill(self)
            end)
        else
            if not (self.killed) then
                Kill(self)
            end
        end
    end
    task.Do(self)
    --根据dx计算lr-----------------------------------------
    local dx
    if self.dx > 0.5
    then
        dx = 2
    elseif self.dx < -0.5
    then
        dx = -2
    else
        dx = 0
    end
    self.lr = self.lr + dx
    if self.lr > 28 then
        self.lr = 28
    end
    if self.lr < -28 then
        self.lr = -28
    end
    if self.lr == 0 then
        self.lr = self.lr + dx
    end
    if dx == 0 then
        --
        if self.lr > 1 then
            self.lr = self.lr - 1
        end
        if self.lr < -1 then
            self.lr = self.lr + 1
        end
    end
    --计算显示哪一帧-------------------------------------------------------------
    -----------------------n*4---------------------------
    if self.cast_t > 0 then
        self.cast = self.cast + 1
    elseif self.cast_t < 0 then
        self.cast = 0
        self.cast_t = 0
    end
    if self.dx ~= 0 then
        self.cast = 0
        self.cast_t = 0
    end
    if self.img4 then
        if self.cast > 0 and self.dx == 0 then
            if self.cast >= self.ani_intv * self.nn[4] then
                if self.mm[3] == 1 then
                    self.img = self.img4[self.nn[4]]
                else
                    self.img = self.img4[int(self.cast / self.ani_intv) % self.mm[3] + self.ani4 + 1]
                end
                self.cast_t = self.cast_t - 1
            else
                self.img = self.img4[int(self.cast / self.ani_intv) + 1]
            end
        elseif self.lr > 0 then
            if abs(self.lr) == 1 then
                self.img = self.img1[int(self.ani / self.ani_intv) % self.nn[1] + 1]
            elseif abs(self.lr) == 28 then
                if self.mm[1] == 1 then
                    self.img = self.img2[self.nn[2]]
                else
                    self.img = self.img2[int(self.ani / self.ani_intv) % self.mm[1] + self.ani2 + 1]
                end
            else
                if self.ani2 == 2 then
                    self.img = self.img2[int((abs(self.lr) + 2) / 10) + 1]
                elseif self.ani2 == 3 then
                    self.img = self.img2[int((abs(self.lr)) / 7) + 1]
                elseif self.ani2 == 4 then
                    self.img = self.img2[int((abs(self.lr) + 2) / 6) + 1]
                elseif self.ani2 > 4 then
                    self.img = self.img2[int((abs(self.lr) + 2) / 5) + 1]
                end
            end
        else
            if abs(self.lr) == 1 then
                self.img = self.img1[int(self.ani / self.ani_intv) % self.nn[1] + 1]
            elseif abs(self.lr) == 28 then
                if self.mm[2] == 1 then
                    self.img = self.img3[self.nn[3]]
                else
                    self.img = self.img3[int(self.ani / self.ani_intv) % self.mm[2] + self.ani3 + 1]
                end
            else
                if self.ani3 == 2 then
                    self.img = self.img3[int((abs(self.lr) + 2) / 10) + 1]
                elseif self.ani3 == 3 then
                    self.img = self.img3[int((abs(self.lr)) / 7) + 1]
                elseif self.ani3 == 4 then
                    self.img = self.img3[int((abs(self.lr) + 2) / 6) + 1]
                elseif self.ani3 > 4 then
                    self.img = self.img3[int((abs(self.lr) + 2) / 5) + 1]
                end
            end
        end
        --self.hscale=sign(1)
        ---------------------n*3---------------------------------
    elseif self.img3 then
        if self.cast > 0 and self.dx == 0 then
            if self.cast >= self.ani_intv * self.nn[3] then
                if self.mm[2] == 1 then
                    self.img = self.img3[self.nn[3]]
                else
                    self.img = self.img3[int(self.cast / self.ani_intv) % self.mm[2] + self.ani3 + 1]
                end
                self.cast_t = self.cast_t - 1
            else
                self.img = self.img3[int(self.cast / self.ani_intv) + 1]
            end
        elseif self.lr > 0 then
            if abs(self.lr) == 1 then
                self.img = self.img1[int(self.ani / self.ani_intv) % self.nn[1] + 1]
            elseif abs(self.lr) == 28 then
                if self.mm[1] == 1 then
                    self.img = self.img2[self.nn[2]]
                else
                    self.img = self.img2[int(self.ani / self.ani_intv) % self.mm[1] + self.ani2 + 1]
                end
            else
                if self.ani2 == 2 then
                    self.img = self.img2[int((abs(self.lr) + 2) / 10) + 1]
                elseif self.ani2 == 3 then
                    self.img = self.img2[int((abs(self.lr)) / 7) + 1]
                elseif self.ani2 == 4 then
                    self.img = self.img2[int((abs(self.lr) + 2) / 6) + 1]
                else
                    self.img = self.img2[int((abs(self.lr) + 2) / 5) + 1]
                end
            end
        else
            if abs(self.lr) == 1 then
                self.img = self.img1[int(self.ani / self.ani_intv) % self.nn[1] + 1]
            elseif abs(self.lr) == 28 then
                if self.mm[1] == 1 then
                    self.img = self.img2[self.nn[2]]
                else
                    self.img = self.img2[int(self.ani / self.ani_intv) % self.mm[1] + self.ani2 + 1]
                end
            else
                if self.ani2 == 2 then
                    self.img = self.img2[int((abs(self.lr) + 2) / 10) + 1]
                elseif self.ani2 == 3 then
                    self.img = self.img2[int((abs(self.lr)) / 7) + 1]
                elseif self.ani2 == 4 then
                    self.img = self.img2[int((abs(self.lr) + 2) / 6) + 1]
                else
                    self.img = self.img2[int((abs(self.lr) + 2) / 5) + 1]
                end
            end
        end
        local scale = abs(self.hscale)
        self.hscale = sign(self.lr) * scale
        ------------------n*2---------------------------------
    elseif self.img2 then
        if self.cast > 0 and self.dx == 0 then
            if self.cast >= self.ani_intv * self.nn[2] then
                if self.mm[1] == 1 then
                    self.img = self.img2[self.nn[2]]
                else
                    self.img = self.img2[int(self.cast / self.ani_intv) % self.mm[1] + self.ani2 + 1]
                end
                self.cast_t = self.cast_t - 1
            else
                self.img = self.img2[int(self.cast / self.ani_intv) + 1]
            end
        else
            if abs(self.lr) == 1 then
                self.img = self.img1[1]
            elseif abs(self.lr) == 28 then
                self.img = self.img1[self.nn[1]]
            else
                if self.ani2 == 2 then
                    self.img = self.img2[int((abs(self.lr) + 2) / 10) + 1]
                elseif self.ani2 == 3 then
                    self.img = self.img2[int((abs(self.lr)) / 7) + 1]
                elseif self.ani2 == 4 then
                    self.img = self.img2[int((abs(self.lr) + 2) / 6) + 1]
                else
                    self.img = self.img2[int((abs(self.lr) + 2) / 5) + 1]
                end
            end
        end
        local scale = abs(self.hscale)
        self.hscale = sign(self.lr) * scale
    end

    --------------------------------------------
    --if self.imgs then
    --    if self.cast>0 then
    --        self.cast=self.cast-1
    --        self.img=self.imgs[int(self.cast/8)+9]
    --    else
    --        if abs(self.lr)==1 then
    --            self.img=self.imgs[int(self.ani/self.ani_intv)%4+1]
    --        elseif abs(self.lr)==18 then
    --            self.img=self.imgs[8]
    --        else
    --            self.img=self.imgs[int((abs(self.lr)-2)/4)+5]
    --        end
    --    end
    --end
    --self.hscale=sign(self.lr)
    ----------------------------------------------
    --保护时间
    if self.sc_pro > 0 then
        self.sc_pro = self.sc_pro - 1
    end
    --底部指示器位置
    local world = lstg.world
    if world.l < self.x and self.x < world.r then
        self.ui.pointer_x = self.x
    else
        self.ui.pointer_x = nil
    end
    --计算aura透明度
    self.aura_alpha = self.aura_alpha + self.aura_alpha_d
    self.aura_alpha = min(max(0, self.aura_alpha), 128)

    if self.cards[self.card_num] then
        --非符或符卡
        local c = self.cards[self.card_num]
        c.frame(self)
        --计算伤害系数---------------------------------------------
        if player.nextspell > 0 and self.timer <= 0 then
            self.sc_pro = player.nextspell                      --
        end                                                     --
        if self.timer < self.sc_pro then
            self.dmg_factor = 0.1                               --
        end                                                     --
        if self.timer < c.t1 then
            self.dmg_factor = 0                                 --
        elseif self.timer < c.t2 then
            self.dmg_factor = (self.timer - c.t1) / (c.t2 - c.t1)--
        elseif self.timer < c.t3 then
            self.dmg_factor = 1                                 --
        else
            self.hp = 0                                         --
            lstg.var.card_timeout = true
        end                                                     --
        --Kill(self) end                                       --
        if c.is_extra and lstg.player.nextspell > 0 then
            self.dmg_factor = 0                                 --
        end                                                     --
        --时符----------------------------------------------------
        if c.t1 == c.t3 then
            self.dmg_factor = 0
            self.time_sc = true
            lstg.var.card_timeout = false
        else
            self.time_sc = false
        end
        ---------------------------
        --计算SCB
        if lstg.var.sc_bonus and lstg.var.sc_bonus > 0 and c.t1 ~= c.t3 and not (self.killed) then
            lstg.var.sc_bonus = lstg.var.sc_bonus - (self.sc_bonus_max - self.sc_bonus_base) / c.t3
        end
        --UI血条
        self.ui.hpbarlen = self.hp / self.maxhp
        --UI倒计时
        self.ui.countdown = (c.t3 - self.timer) / 60
        --隐藏血条
        if IsValid(lstg.player) and Dist(lstg.player, self) <= 70 then
            self.hp_flag = self.hp_flag + 1
        else
            self.hp_flag = self.hp_flag - 1
        end
        self.hp_flag = min(max(0, self.hp_flag), 18)
        --背景过渡和切换-----------------------------------------
        if self.bg then
            if c.is_sc then
                self.bg.alpha = min(1, self.bg.alpha + 0.025)
            else
                self.bg.alpha = max(0, self.bg.alpha - 0.025)
            end
            if lstg.tmpvar.bg then
                if self.bg.alpha == 1 then
                    lstg.tmpvar.bg.hide = true
                else
                    lstg.tmpvar.bg.hide = false
                end
            end
        end
        -------------------------------------------------------
    end
end

function boss:render()
    --SetImageState('boss_aura','mul+add',Color(self.aura_alpha,255,255,255))
    --Render('boss_aura',self.x,self.y,self.ani*5,1.8+0.4*sin(self.ani*2.5))
    for i = 1, 25 do
        SetImageState('boss_aura_3D' .. i, 'mul+add', Color(self.aura_alpha, 255, 255, 255))
    end
    Render('boss_aura_3D' .. self.ani % 25 + 1, self.x, self.y, self.ani * 0.75, 0.92, 0.8 + 0.12 * sin(90 + self.ani * 0.75))
    if self.cards[self.card_num] then
        self.cards[self.card_num].render(self)
    end
    if self.img1 then
        Render(self.img, self.x, self.y + sin(self.ani * 4) * 4, self.rot, self.hscale, self.vscale)
    else
        --封兽球
        Render('undefined', self.x + cos(self.ani * 6 + 180) * 3, self.y + sin(self.ani * 6 + 180) * 3, self.ani * 10)
        Render('undefined', self.x + cos(-self.ani * 6 + 180) * 3, self.y + sin(-self.ani * 6 + 180) * 3, -self.ani * 10)
        Render('undefined', self.x + cos(self.ani * 6) * 3, self.y + sin(self.ani * 6) * 3, self.ani * 20)
        Render('undefined', self.x + cos(-self.ani * 6) * 3, self.y + sin(-self.ani * 6) * 3, -self.ani * 20)
    end
end

function boss:take_damage(dmg)
    if not self.protect then
        self.hp = self.hp - dmg * self.dmg_factor
        lstg.var.score = lstg.var.score + 10
    end
end

function boss:kill()
    _kill_servants(self)
    self.sp_point = { }
    if self.cards[self.card_num] then
        local c = self.cards[self.card_num]
        c.del(self)
        if c.is_combat then
            if self.hp <= 0 or c.t1 == c.t3 then
                --drop
                if self.cards[self.card_num].drop then
                    item.DropItem(self.x, self.y, self.cards[self.card_num].drop)
                end
                --bonus
                item.EndChipBonus(self.x, self.y)
                if lstg.var.sc_bonus then
                    if lstg.var.sc_bonus > 0 then
                        --SCB
                        lstg.var.score = lstg.var.score + lstg.var.sc_bonus - lstg.var.sc_bonus % 10
                        PlaySound('cardget', 1.0, 0)
                        New(hinter_bonus, 'hint.getbonus', 0.6, 0, 112, 15, 120, true,
                                lstg.var.sc_bonus - lstg.var.sc_bonus % 10)
                        New(kill_timer, 0, 30, self.timer)
                        if not ext.replay.IsReplay() then
                            local score = scoredata.spell_card_hist[lstg.var.player_name][self.difficulty][c.name]
                            score[1] = score[1] + 1
                        end
                    else
                        --SCB failed
                        New(hinter, 'hint.bonusfail', 0.6, 0, 112, 15, 120)
                        New(kill_timer, 0, 60, self.timer)
                    end
                end
            else
                --SCB failed
                if lstg.var.sc_bonus then
                    New(hinter, 'hint.bonusfail', 0.6, 0, 112, 15, 120, 15)
                end
            end
            PlaySound('enep02', 0.4, 0)
            New(bullet_killer, lstg.player.x, lstg.player.y, true)
        end
        if c.is_sc then
            self.ui.sc_left = self.ui.sc_left - 1
        end
        if self.card_num == self.last_card then
            if self.cards[#self.cards].is_move then
                PlaySound('enep01', 0.4, 0)
            else
                New(boss_death_ef, self.x, self.y)
                self.hide = true
                self.colli = false
            end
        end
    end
    lstg.var.card_timeout = false
    self.card_num = self.card_num + 1
    if self.cards[self.card_num] then
        local c = self.cards[self.card_num]--即将进入的动作
        --获取上一张、下一张符卡/非符------------------------
        local ccc = nil--下一张符卡/非符，没有时为nil       --
        local cc = nil--上一张符卡/非符，没有时为nil        --
        local number = self.card_num                       --
        if self.cards[number + 1] --
                and not (self.cards[number + 1].is_combat) --
                and number ~= self.last_card then
            --
            number = number + 1                            --
        end                                                --
        ccc = self.cards[number + 1]                       --
        number = self.card_num                             --
        if self.cards[number - 1] then
            --
            if not (self.cards[number - 1].is_combat) then
                --
                number = number - 1                        --
            end                                            --
            cc = self.cards[number - 1]                    --
        end                                                --
        --决定血条绘制方式、处理scoredata-----------------------------------------
        if c.is_sc then
            if cc and cc.is_sc then
                self.ui.hpbarcolor1 = Color(0xFFFF8080)
                self.ui.hpbarcolor2 = nil
            elseif cc and not (cc.is_sc) then
                self.ui.hpbarcolor1 = Color(0xFFFF8080)
                self.ui.hpbarcolor2 = Color(0xFFFF8080)
            elseif not (cc) then
                self.ui.hpbarcolor1 = Color(0xFFFF8080)
                self.ui.hpbarcolor2 = nil
            end
            lstg.var.sc_bonus = self.sc_bonus_max
            --self.ui.hpbarcolor=Color(0xFFFF8080)
            New(spell_card_ef)--'Spell Card Attack!!'
            PlaySound('cat00', 0.5)
            if scoredata.spell_card_hist == nil then
                scoredata.spell_card_hist = { }
            end
            if scoredata.spell_card_hist[lstg.var.player_name] == nil then
                scoredata.spell_card_hist[lstg.var.player_name] = { }
            end
            local _hist_pname = scoredata.spell_card_hist[lstg.var.player_name]
            if _hist_pname[self.difficulty] == nil then
                _hist_pname[self.difficulty] = { }
            end
            if _hist_pname[self.difficulty][c.name] == nil then
                _hist_pname[self.difficulty][c.name] = { 0, 0 }
            end
            if not ext.replay.IsReplay() then
                _hist_pname[self.difficulty][c.name][2] = _hist_pname[self.difficulty][c.name][2] + 1
            end
            self.ui.sc_hist = _hist_pname[self.difficulty][c.name]
        elseif not (c.is_sc) and ccc and ccc.is_sc then
            lstg.var.sc_bonus = nil
            self.ui.hpbarcolor1 = Color(0xFFFF8080)
            self.ui.hpbarcolor2 = Color(0xFFFFFFFF)
        elseif not (c.is_sc) and ccc and not (ccc.is_sc) and ccc.is_combat then
            lstg.var.sc_bonus = nil
            self.ui.hpbarcolor1 = nil
            self.ui.hpbarcolor2 = Color(0xFFFFFFFF)
        else
            lstg.var.sc_bonus = nil
        end
        --else
        --    lstg.var.sc_bonus=nil
        --    self.ui.hpbarcolor=Color(0xFFFFFFFF)
        --end
        if c.is_combat then
            item.StartChipBonus()
        end
        if c.name ~= '' then
            self.ui.sc_name = c.name
        end
        self.ui.countdown = c.t3 / 60
        self.ui.is_combat = c.is_combat
        task.Clear(self.ui)
        task.Clear(self)
        c.init(self)
        self.timer = -1
        self.hp = c.hp
        self.maxhp = c.hp
        self.dmg_factor = 0
        PreserveObject(self)
    else
        --没有符卡或动作了，击破boss
        if self.ui then
            Del(self.ui)
        end
        if self.bg then
            Del(self.bg)
            self.bg = nil
        end
        if self.dialog_displayer then
            Del(self.dialog_displayer)
        end
        if lstg.tmpvar.bg then
            lstg.tmpvar.bg.hide = false
        end
        if self.class.defeat then
            self.class.defeat(self)
        end
    end
end

function boss:del()
    if self.ui then
        Del(self.ui)
    end
    if self.bg then
        Del(self.bg)
        self.bg = nil
    end
    if self.dialog_displayer then
        Del(self.dialog_displayer)
    end
    if lstg.tmpvar.bg then
        lstg.tmpvar.bg.hide = false
    end
end

---boss.MoveTowardsPlayer(t)
---大致向自机移动（x方向），保持在屏幕中上区域
---t：移动时间（帧）
function boss.MoveTowardsPlayer(t)
    local dirx, diry
    local self = task.GetSelf()
    if self.x > 64 then
        dirx = -1
    elseif self.x < -64 then
        dirx = 1
    else
        if self.x > lstg.player.x then
            dirx = -1
        else
            dirx = 1
        end
    end
    if self.y > 144 then
        diry = -1
    elseif self.y < 128 then
        diry = 1
    else
        diry = ran:Sign()
    end
    local dx = max(16, min(abs((self.x - lstg.player.x) * 0.3), 32))
    task.MoveTo(self.x + ran:Float(dx, dx * 2) * dirx, self.y + diry * ran:Float(16, 32), t)
end

function boss:show_aura(show)
    if show then
        self.aura_alpha_d = 4
    else
        self.aura_alpha_d = -4
    end
end

function boss:cast(cast_t)
    self.cast_t = cast_t + 0.5
    self.cast = 1
end

---@class THlib.boss.card
boss.card = {}

---新建符卡/非符
---name：符卡名，空则为非符
---t1：保护时间（秒）
---t2：全伤害时间（秒）
---t3：总时间（秒）
---  t1<t2<t3
---hp：血量
---drop：掉落 {红,绿,蓝}
---is_extra
function boss.card.New(name, t1, t2, t3, hp, drop, is_extra)
    local c = { }
    c.frame = boss.card.frame
    c.render = boss.card.render
    c.init = boss.card.init
    c.del = boss.card.del
    c.name = tostring(name)
    if t1 > t2 or t2 > t3 then
        error('t1<t2<t3 must be satisfied.')
    end
    c.t1 = int(t1) * 60
    c.t2 = int(t2) * 60
    c.t3 = int(t3) * 60
    c.hp = hp
    c.is_sc = (name ~= '')
    c.drop = drop
    c.is_extra = is_extra or false
    c.is_combat = true
    return c
end
function boss.card:frame()
end
function boss.card:render()
    local c = self.cards[self.card_num]
    if c and c.is_sc and c.t1 ~= c.t3 then
        for i = 1, 16 do
            SetImageState('bossring1' .. i, 'mul+add',
                    Color(self.aura_alpha, 255, 255, 255))
        end
        if self.timer < 90 then
            --设置bossring2（内环）颜色
            if _boss.fxr and _boss.fxg and _boss.fxb then
                local of = 1 - self.timer / 180
                for i = 1, 16 do
                    SetImageState('bossring2' .. i, 'mul+add',
                            Color(1.9 * self.aura_alpha, _boss.fxr * of, _boss.fxg * of, _boss.fxb * of))
                end
            else
                for i = 1, 16 do
                    SetImageState('bossring2' .. i, 'mul+add',
                            Color(self.aura_alpha, 255, 255, 255))
                end
            end
            --两个环逐渐扩大，旋转方向相反
            misc.RenderRing('bossring1', self.x, self.y,
                    self.timer * 2 + 270 * sin(self.timer * 2),
                    self.timer * 2 + 270 * sin(self.timer * 2) + 16,
                    self.ani * 3, 32, 16)
            misc.RenderRing('bossring2', self.x, self.y,
                    90 + self.timer * 1,
                    -180 + self.timer * 4 - 16,
                    -self.ani * 3, 32, 16)
        else
            if _boss.fxr and _boss.fxg and _boss.fxb then
                for i = 1, 16 do
                    SetImageState('bossring2' .. i, 'mul+add',
                            Color(1.9 * self.aura_alpha, _boss.fxr / 2, _boss.fxg / 2, _boss.fxb / 2))
                end
            else
                for i = 1, 16 do
                    SetImageState('bossring2' .. i, 'mul+add',
                            Color(self.aura_alpha, 255, 255, 255))
                end
            end
            local t = self.cards[self.card_num].t3
            --随时间缩小
            misc.RenderRing('bossring1', self.x, self.y,
                    (t - self.timer) / (t - 90) * 180,
                    (t - self.timer) / (t - 90) * 180 + 16,
                    self.ani * 3, 32, 16)
            misc.RenderRing('bossring2', self.x, self.y,
                    (t - self.timer) / (t - 90) * 180,
                    (t - self.timer) / (t - 90) * 180 - 16,
                    -self.ani * 3, 32, 16)
        end
    end
end
function boss.card:init()
end
function boss.card:del()
end

---@class THlib.boss.dialog
boss.dialog = {}

---
---新建boss对话，重载init方法来使用
---example：
---  _tmp_sc=boss.dialog.New(false)
---  function _tmp_sc:init()
---    lstg.player.dialog=true
---    self.dialog_displayer=New(dialog_displayer)
---      task.New(self,function()
---          boss.dialog.sentence(self,"image:xx","right","第一句话",180)
---          boss.dialog.sentence(self,"image:xx","right","第二句话",180)
---          LoadMusicRecord("boss")
---          _play_music("boss")
---          task.MoveTo(0,125,60,MOVE_NORMAL)
---      end)
---  end
---  table.insert(_editor_class["xxx"].cards,_tmp_sc)
---@param can_skip boolean
function boss.dialog.New(can_skip)
    local c = { }
    c.frame = boss.dialog.frame
    c.render = boss.dialog.render
    c.init = boss.dialog.init
    c.del = boss.dialog.del
    c.name = ''
    c.t1 = 999999999
    c.t2 = 999999999
    c.t3 = 999999999
    c.hp = 999999999
    c.is_sc = false
    c.is_extra = false
    c.is_combat = false
    _dialog_can_skip = can_skip
    return c
end

function boss.dialog:frame()
    if self.task and coroutine.status(self.task[1]) == 'dead' then
        Kill(self)
    end
end
function boss.dialog:render()
end
function boss.dialog:init()
    lstg.player.dialog = true
    self.dialog_displayer = New(dialog_displayer)
end
function boss.dialog:del()
    lstg.player.dialog = false
    Del(self.dialog_displayer)
    self.dialog_displayer = nil
end

--- 显示一句对话
---@param img string 立绘图像
---@param pos string 'left'或'right'
---@param text string 文本
---@param t number 持续时间（帧），默认为 60+#text*5
---@param hscale number 立绘水平缩放，默认由pos决定
---@param vscale number 立绘垂直缩放，默认为1
---@see THlib.boss.dialog.New
function boss.dialog:sentence(img, pos, text, t, hscale, vscale)
    if pos == 'left' then
        pos = 1
    else
        pos = -1
    end
    self.dialog_displayer.text = text
    self.dialog_displayer.char[pos] = img
    if self.dialog_displayer.active ~= pos then
        self.dialog_displayer.active = pos
        self.dialog_displayer.t = 16
    end
    self.dialog_displayer._hscale[pos] = hscale or pos
    self.dialog_displayer._vscale[pos] = vscale or 1
    task.Wait()
    t = t or (60 + #text * 5)
    for i = 1, t do
        if (KeyIsPressed 'shoot' or self.dialog_displayer.jump_dialog > 60) and _dialog_can_skip then
            --按一下或已持续按60帧射击键，跳过对话
            PlaySound('plst00', 0.35, 0, true)
            break
        end
        task.Wait()
    end
    task.Wait(2)
end

--

---@class THlib.dialog_displayer:object
dialog_displayer = Class(object)
function dialog_displayer:init()
    self.layer = LAYER_TOP
    self.char = { }
    self._hscale = { }
    self._vscale = { }
    self.t = 16
    self.death = 0
    self.co = 0
    self.jump_dialog = 0
end
function dialog_displayer:frame()
    task.Do(self)
    if self.t > 0 then
        self.t = self.t - 1
    end
    if self.active then
        self.co = max(min(60, self.co + 1.5 * self.active), -60)
    end
    if player.dialog == true and self.active then
        if KeyIsDown 'shoot' then
            self.jump_dialog = self.jump_dialog + 1
        else
            self.jump_dialog = 0
        end
    end
end
function dialog_displayer:render()
    if self.active then
        SetViewMode 'ui'
        if self.char[-self.active] then
            --设置立绘渐显/渐隐
            SetImageState(self.char[-self.active], '',
                    Color(0xFF404040)
                            + (self.t / 16) * Color(0xFFC0C0C0)
                            - (self.death / 30) * Color(0xFF000000))
            local t = (1 - self.t / 16) ^ 3
            --渲染立绘
            Render(self.char[-self.active],
                    224 + self.active * (-(1 - 2 * t) * 16 + 128) + self.death * self.active * 12,
                    240 - 65 - t * 16 - 25,
                    0, self._hscale[-self.active], self._vscale[-self.active])
        end
        if self.char[self.active] then
            SetImageState(self.char[self.active], '',
                    Color(0xFF404040)
                            + (1 - self.t / 16) * Color(0xFFC0C0C0)
                            - (self.death / 30) * Color(0xFF000000))
            local t = (self.t / 16) ^ 3
            Render(self.char[self.active],
                    224 + self.active * ((1 - 2 * t) * 16 - 128) - self.death * self.active * 12,
                    240 - 65 - t * 16 - 25,
                    0, self._hscale[self.active], self._vscale[self.active])
        end
        SetViewMode 'world'
    end
    if self.text and self.active then
        ---SetImageState('white','',Color(0xC0000000))
        local kx, ky1, ky2, dx, dy1, dy2
        kx = 168
        ky1 = -210
        ky2 = -90
        dx = 160
        dy1 = -144
        dy2 = -126
        --left：渐变为偏蓝，right：渐变为偏红
        SetImageState('dialog_box', '',
                Color(225, 195 - self.co, 150, 195 + self.co))
        Render('dialog_box', 0, -144 - self.death * 8)
        RenderTTF('dialog', self.text,
                -dx, dx, dy1 - self.death * 8, dy2 - self.death * 8,
                Color(0xFF000000), 'paragraph')
        if self.active > 0 then
            RenderTTF('dialog', self.text,
                    -dx, dx, dy1 - self.death * 8, dy2 - self.death * 8,
                    Color(255, 255, 200, 200), 'paragraph')--偏红
        else
            RenderTTF('dialog', self.text,
                    -dx, dx, dy1 - self.death * 8, dy2 - self.death * 8,
                    Color(255, 200, 200, 255), 'paragraph')--偏蓝
        end
    end
end
function dialog_displayer:del()
    PreserveObject(self)
    task.New(self, function()
        for i = 1, 30 do
            self.death = i
            task.Wait()
        end
        RawDel(self)
    end)
end
----------------------------------------
--[[
dialog_displayer=Class(object)
function dialog_displayer:init()
	self.layer=LAYER_TOP
	self.char={}
	self.t=16
	self.death=0
end
function dialog_displayer:frame()
	task.Do(self)
	if self.t>0 then self.t=self.t-1 end
end
function dialog_displayer:render()
	if self.active then
		if self.char[-self.active] then
			SetImageState(self.char[-self.active],'',Color(0xFF404040)+(  self.t/16)*Color(0xFFC0C0C0))
			local t=(1-self.t/16)^3
			Render(self.char[-self.active],self.active*(-(1-2*t)*16+128)+self.death*self.active*8,-65-t*16,0,-self.active,1)
		end
		if self.char[self.active] then
			SetImageState(self.char[ self.active],'',Color(0xFF404040)+(1-self.t/16)*Color(0xFFC0C0C0))
			local t=(  self.t/16)^3
			Render(self.char[ self.active],self.active*( (1-2*t)*16-128)-self.death*self.active*8,-65-t*16,0, self.active,1)
		end
	end
	if self.text then
		SetImageState('white','',Color(0xC0000000))
		RenderRect('white',-176,176,-176-self.death*8,-128-self.death*8)
		RenderTTF('dialog',self.text,-167,169,-179-self.death*8,-137-self.death*8,Color(0xFF000000),'paragraph')
		if self.active>0 then
			RenderTTF('dialog',self.text,-168,168,-178-self.death*8,-136-self.death*8,Color(0xFFA0FFFF),'paragraph')
		else
			RenderTTF('dialog',self.text,-168,168,-178-self.death*8,-136-self.death*8,Color(0xFFFFA0A0),'paragraph')
		end
	end
end
function dialog_displayer:del()
	PreserveObject(self)
	task.New(self,function()
		for i=1,30 do
			self.death=i
			task.Wait()
		end
		RawDel(self)
	end)
end
]]

---@class THlib.boss.move
boss.move = { }

---
---新建boss移动动作
---等价于task.MoveTo，一般用于对话开始前
---example：
---  table.insert(_editor_class["xxx"].cards,boss.move.New(0,0,60,MOVE_NORMAL))
---@param x number
---@param y number 目标点
---@param t number 所需时间（帧）
---@param m number 缓冲模式，见task.MoveTo
function boss.move.New(x, y, t, m)
    local c = { }
    c.frame = boss.move.frame
    c.render = boss.move.render
    c.init = boss.move.init
    c.del = boss.move.del
    c.name = ''
    c.t1 = 999999999
    c.t2 = 999999999
    c.t3 = 999999999
    c.hp = 999999999
    c.is_sc = false
    c.is_extra = false
    c.is_combat = false
    c.is_move = true
    c.x = x
    c.y = y
    c.t = t
    c.m = m
    return c
end
function boss.move:frame()
end
function boss.move:render()
end
function boss.move:init()
    local c = self.cards[self.card_num]
    task.New(self, function()
        task.MoveTo(c.x, c.y, c.t, c.m)
        Kill(self)
    end)
end
function boss.move:del()
end

---@class THlib.boss.escape
boss.escape = { }

---
---新建boss逃跑动作
---本质与boss.move.New相同
---@param x number
---@param y number
---@param t number
---@param m number
function boss.escape.New(x, y, t, m)
    local c = { }
    c.frame = boss.escape.frame
    c.render = boss.escape.render
    c.init = boss.escape.init
    c.del = boss.escape.del
    c.name = ''
    c.t1 = 999999999
    c.t2 = 999999999
    c.t3 = 999999999
    c.hp = 999999999
    c.is_sc = false
    c.is_extra = false
    c.is_combat = false
    c.is_escape = true
    c.x = x
    c.y = y
    c.t = t
    c.m = m
    return c
end
function boss.escape:frame()
end
function boss.escape:render()
end
function boss.escape:init()
    local c = self.cards[self.card_num]
    task.New(self, function()
        task.MoveTo(c.x, c.y, c.t, c.m)
        Kill(self)
    end)
end
function boss.escape:del()
end

---@class THlib.boss_ui:object
boss_ui = Class(object)

function boss_ui:init(b)
    self.layer = LAYER_TOP
    self.group = GROUP_GHOST
    self.boss = b
    self.sc_name = ''
    if b.class.sc_image then
        self.sc_image = New(b.class.sc_image)
    end
end

function boss_ui:render()
    SetViewMode 'world'
    local _dy = 0
    local alpha1 = 1 - self.boss.hp_flag / 30
    SetImageState('base_hp', '', Color(alpha1 * 255, 255, 0, 0))
    SetImageState('hpbar1', '', Color(alpha1 * 255, 255, 255, 255))
    SetImageState('life_node', '', Color(alpha1 * 255, 255, 255, 255))
    if self.is_combat then
        if self.hpbarlen then
            if not (self.boss.time_sc) then
                if not (self.hpbarcolor2) then
                    -- sp-'sp'
                    --当前为符卡，上一阶段也为符卡
                    misc.Renderhpbar(self.boss.x, self.boss.y, 90, 360, 60, 64, 360, 1)
                    --前60帧填充血条
                    misc.Renderhp(self.boss.x, self.boss.y, 90, 360, 60, 64, 360,
                            self.hpbarlen * min(1, self.boss.timer / 60))
                    --红色发光的两个同心圆
                    Render('base_hp', self.boss.x, self.boss.y, 0, 0.274, 0.274)
                    Render('base_hp', self.boss.x, self.boss.y, 0, 0.256, 0.256)
                    if self.boss.sp_point and #self.boss.sp_point ~= 0 then
                        --绘制分割点
                        for i = 1, #self.boss.sp_point do
                            Render('life_node',
                                    self.boss.x + 61 * cos(self.boss.sp_point[i]),
                                    self.boss.y + 61 * sin(self.boss.sp_point[i]),
                                    self.boss.sp_point[i] - 90, 0.5)
                        end
                    end
                elseif not (self.hpbarcolor1) then
                    --'non'-non
                    --当前为非符，下一阶段也为非符
                    misc.Renderhpbar(self.boss.x, self.boss.y, 90, 360, 60, 64, 360, 1)
                    misc.Renderhp(self.boss.x, self.boss.y, 90, 360, 60, 64, 360,
                            self.hpbarlen * min(1, self.boss.timer / 60))
                    Render('base_hp', self.boss.x, self.boss.y, 0, 0.274, 0.274)
                    Render('base_hp', self.boss.x, self.boss.y, 0, 0.256, 0.256)
                elseif self.hpbarcolor1 == self.hpbarcolor2 then
                    --non-'sp'
                    --非符-符卡组合，处于符卡阶段
                    misc.Renderhpbar(self.boss.x, self.boss.y, 90, 360, 60, 64, 360, 1)
                    misc.Renderhp(self.boss.x, self.boss.y, 90, self.boss.lifepoint - 90, 60, 64,
                            self.boss.lifepoint - 88, self.hpbarlen)
                    Render('base_hp', self.boss.x, self.boss.y, 0, 0.274, 0.274)
                    Render('base_hp', self.boss.x, self.boss.y, 0, 0.256, 0.256)
                elseif self.hpbarcolor1 ~= self.hpbarcolor2 then
                    --'non'-sp
                    --非符-符卡组合，处于非符阶段
                    misc.Renderhpbar(self.boss.x, self.boss.y, 90, 360, 60, 64, 360, 1)
                    if self.boss.timer <= 60 then
                        misc.Renderhp(self.boss.x, self.boss.y, 90, 360, 60, 64, 360,
                                self.hpbarlen * min(1, self.boss.timer / 60))
                    else
                        misc.Renderhp(self.boss.x, self.boss.y, 90, self.boss.lifepoint - 90,
                                60, 64, self.boss.lifepoint - 88, 1)
                        misc.Renderhp(self.boss.x, self.boss.y, self.boss.lifepoint, 450 - self.boss.lifepoint,
                                60, 64, 450 - self.boss.lifepoint, self.hpbarlen)
                    end
                    Render('base_hp', self.boss.x, self.boss.y, 0, 0.274, 0.274)
                    Render('base_hp', self.boss.x, self.boss.y, 0, 0.256, 0.256)
                    Render('life_node',
                            self.boss.x + 61 * cos(self.boss.lifepoint),
                            self.boss.y + 61 * sin(self.boss.lifepoint),
                            self.boss.lifepoint - 90, 0.55)
                    SetFontState('bonus', '', Color(255, 255, 255, 255))
                end
                if self.boss.show_hp then
                    --文字方式显示血量
                    SetFontState('bonus', '', Color(255, 0, 0, 0))
                    RenderText('bonus', int(max(0, self.boss.hp)) .. '/' .. self.boss.maxhp,
                            self.boss.x - 1, self.boss.y - 40 - 1, 0.6, 'centerpoint')--黑色文字做阴影
                    SetFontState('bonus', '', Color(255, 255, 255, 255))
                    RenderText('bonus', int(max(0, self.boss.hp)) .. '/' .. self.boss.maxhp,
                            self.boss.x, self.boss.y - 40, 0.6, 'centerpoint')
                end
            end
            --左上角显示boss名字
            RenderTTF('boss_name', self.name, -185, -185, 222, 222,
                    Color(0xFF000000), 'noclip')--白色文字做阴影
            RenderTTF('boss_name', self.name, -186, -186, 223, 223,
                    Color(0xFF80FF80), 'noclip')--浅绿色
            --左上角显示剩余符卡数量
            local m = int((self.sc_left - 1) / 8)
            if m >= 0 then
                for i = 0, m - 1 do
                    for j = 1, 8 do
                        Render('boss_sc_left', -194 + j * 12, 207 - i * 12, 0, 0.5)
                    end
                end
                for i = 1, int(self.sc_left - 1 - 8 * m) do
                    Render('boss_sc_left', -194 + i * 12, 207 - m * 12, 0, 0.5)
                end
            end
        end
    end
    local world = lstg.world
    if self.pointer_x then
        --绘制底部指示器
        SetViewMode 'ui'
        Render('boss_pointer', WorldToScreen(max(min(self.pointer_x, world.r - 24), world.l + 24), world.b))
        SetViewMode 'world'
    end
    --计算右上角UI透明度，x>0 & y>160 时增加透明度--------------
    local ax, ay = 0, 0
    if IsValid(lstg.player) then
        --
        ax = min(max(lstg.player.x * 0.05, 0), 0.9)
        ay = min(max((lstg.player.y - 160) * 0.05, 0), 0.9)
    end
    local alpha = 1 - ax * ay
    ---------------------------------------------------------
    SetFontState('time', '', Color(alpha * 255, 255, 255, 255))
    local world_w = world.r - world.l
    local xoffset = world_w
    if lstg.var.sc_bonus then
        xoffset = max(world_w - self.boss.timer * 7, 0)--从右向左进入
    else
        xoffset = min(world_w, (self.boss.timer + 1) * 7)--从左向右退出
    end

    if self.sc_name ~= '' then
        --渲染符卡名及背景
        SetImageState('boss_spell_name_bg', '', Color(alpha * 255, 255, 255, 255))
        Render('boss_spell_name_bg', 192 + xoffset, 236)
        RenderTTF('sc_name', self.sc_name, 193 + xoffset, 193 + xoffset, 226, 226,
                Color(alpha * 255, 0, 0, 0), 'right', 'noclip')
        RenderTTF('sc_name', self.sc_name, 192 + xoffset, 192 + xoffset, 227, 227,
                Color(alpha * 255, 255, 255, 255), 'right', 'noclip')
    end

    if lstg.var.sc_bonus then
        --显示有SCB的符卡信息：HISTORY  0/99  BONUS  1000000
        local b--BONUS信息
        if lstg.var.sc_bonus > 0 then
            b = string.format('%.0f', lstg.var.sc_bonus - lstg.var.sc_bonus % 10)--去掉小数点后，个位为0
        else
            b = 'FAILED '
        end
        SetFontState('bonus', '', Color(alpha * 255, 0, 0, 0))
        RenderText('bonus', b, 187 + xoffset, 207, 0.5, 'right')
        RenderText('bonus', string.format('%d/%d', self.sc_hist[1], self.sc_hist[2]),
                97 + xoffset, 207, 0.5, 'right')
        RenderText('bonus', 'HISTORY       BONUS', 137 + xoffset, 207, 0.5, 'right')
        SetFontState('bonus', '', Color(alpha * 255, 255, 255, 255))
        RenderText('bonus', b, 186 + xoffset, 208, 0.5, 'right')
        RenderText('bonus', string.format('%d/%d', self.sc_hist[1], self.sc_hist[2]),
                96 + xoffset, 208, 0.5, 'right')
        RenderText('bonus', 'HISTORY       BONUS', 136 + xoffset, 208, 0.5, 'right')
    end
    if self.is_combat then
        local cd = (self.countdown - int(self.countdown)) * 100
        local yoffset
        if lstg.var.sc_bonus then
            yoffset = max(20 - self.boss.timer, 0)--由上向下
        else
            yoffset = min(20, (self.boss.timer + 1))--由下向上
        end
        if self.countdown >= 10.0 then
            SetFontState('time', '', Color(alpha1 * 255, 255, 255, 255))
            --小数点前
            RenderText('time', string.format('%d', int(self.countdown)),
                    4, 192 + yoffset + _dy, 0.5, 'vcenter', 'right')
            --小数点后，两位
            RenderText('time', string.format(
                    '.%d%d', min(9, cd / 10), min(9, cd % 10)),
                    4, 189 + yoffset + _dy, 0.3, 'vcenter', 'left')
        else
            --10内显示为红色
            SetFontState('time', '', Color(alpha1 * 255, 255, 30, 30))
            RenderText('time', string.format(
                    '0%d', min(99.99, int(self.countdown))),
                    4, 192 + yoffset + _dy, 0.5, 'vcenter', 'right')
            RenderText('time', '.' .. string.format(
                    '%d%d', min(9, cd / 10), min(9, cd % 10)),
                    4, 189 + yoffset + _dy, 0.3, 'vcenter', 'left')
        end
    end
end

function boss_ui:frame()
    task.Do(self)
    local countdown = self.countdown
    if countdown then
        if countdown > 5 and countdown <= 10 and countdown % 1 == 0 then
            PlaySound('timeout', 0.6)
        end
        if countdown > 0 and countdown <= 5 and countdown % 1 == 0 then
            PlaySound('timeout2', 0.8)
            --Print(self.timer)
        end
    end
end

function boss_ui:kill()
    Del(self.sc_image)
end
boss_ui.del = boss_ui.kill

--- 用于显示'Spell Card Attack!!'
---@class THlib.spell_card_ef:object
spell_card_ef = Class(object)

function spell_card_ef:init()
    self.layer = LAYER_BG + 1
    self.group = GROUP_GHOST
    self.alpha = 0
    task.New(self, function()
        --透明度过渡
        for i = 1, 50 do
            task.Wait()
            self.alpha = self.alpha + 0.02
        end
        task.Wait(60)
        for i = 1, 50 do
            task.Wait()
            self.alpha = self.alpha - 0.02
        end
        Del(self)
    end)
end

function spell_card_ef:frame()
    task.Do(self)
end

function spell_card_ef:render()
    --共10行，每行5个，奇数行左移，偶数行右移，与x轴30度
    SetImageState('spell_card_ef', '', Color(255 * self.alpha, 255, 255, 255))
    for j = 1, 10 do
        local h = (j - 5.5) * 32
        for i = -2, 2 do
            local l = i * 128 + ((self.timer * 2) % 128) * (2 * (j % 2) - 1)
            Render('spell_card_ef', l * cos(30), l * sin(30) + h, -60)
        end
    end
end

---@class THlib.boss_cast_ef_unit:object
boss_cast_ef_unit = Class(object)

function boss_cast_ef_unit:init(x, y, v, angle, lifetime, size)
    self.x = x
    self.y = y
    self.rot = ran:Float(0, 360)
    SetV(self, v, angle)
    self.lifetime = lifetime
    self.omiga = 5
    self.layer = LAYER_ENEMY - 50
    self.group = GROUP_GHOST
    self.bound = false
    self.img = 'leaf'
    self.hscale = size
    self.vscale = size
end

function boss_cast_ef_unit:frame()
    if self.timer == self.lifetime then
        Del(self)
    end
end

function boss_cast_ef_unit:render()
    if self.timer > self.lifetime - 15 then
        --渐隐
        SetImageState('leaf', 'mul+add',
                Color((self.lifetime - self.timer) * 12, 255, 255, 255))
    else
        --快速渐显
        SetImageState('leaf', 'mul+add',
                Color((self.timer / (self.lifetime - 15)) ^ 6 * 180, 255, 255, 255))
    end
    DefaultRenderFunc(self)
end

--- 符卡开始时叶子聚集的效果
---@class THlib.boss_cast_ef:object
boss_cast_ef = Class(object)

function boss_cast_ef:init(x, y)
    self.hide = true
    PlaySound('ch00', 0.5, 0)
    for i = 1, 50 do
        local angle = ran:Float(0, 360)
        local lifetime = ran:Int(50, 80)
        local l = ran:Float(300, 500)
        New(boss_cast_ef_unit,
                x + l * cos(angle),
                y + l * sin(angle),
                l / lifetime,
                angle + 180,
                lifetime,
                ran:Float(2, 3))
    end
    Del(self)
end

---@class THlib.boss_death_ef_unit:object
boss_death_ef_unit = Class(object)

function boss_death_ef_unit:init(x, y, v, angle, lifetime, size)
    self.x = x
    self.y = y
    self.rot = ran:Float(0, 360)
    SetV(self, v, angle)
    self.lifetime = lifetime
    self.omiga = 3
    self.layer = LAYER_ENEMY + 50
    self.group = GROUP_GHOST
    self.bound = false
    self.img = 'leaf'
    self.hscale = size
    self.vscale = size
end

function boss_death_ef_unit:frame()
    if self.timer == self.lifetime then
        Del(self)
    end
end

function boss_death_ef_unit:render()
    if self.timer < 15 then
        --渐显
        SetImageState('leaf', 'mul+add',
                Color(self.timer * 12, 255, 255, 255))
    else
        --渐隐
        SetImageState('leaf', 'mul+add',
                Color(((self.lifetime - self.timer) / (self.lifetime - 15)) * 180, 255, 255, 255))
    end
    DefaultRenderFunc(self)
end

--- 击破boss时叶子散开的效果，与boss_cast_ef类似
---@class THlib.boss_death_ef:object
boss_death_ef = Class(object)

function boss_death_ef:init(x, y)
    PlaySound('enep01', 0.4, 0)
    self.hide = true
    misc.ShakeScreen(30, 15)
    for i = 1, 70 do
        local angle = ran:Float(0, 360)
        local lifetime = ran:Int(40, 120)
        local l = ran:Float(100, 500)
        New(boss_death_ef_unit, x, y, l / lifetime, angle, lifetime, ran:Float(2, 4))
    end
    Del(self)
end

---------------------------render----------------------------------
--

---
--- 绘制圆环的一部分（梯形）
function Render_RIng_4(angle, r, angle_offset, x0, y0, r_, imagename)
    local A_1 = angle + angle_offset
    local A_2 = angle - angle_offset
    local R_1 = r + r_
    local R_2 = r - r_
    local x1, x2, x3, x4, y1, y2, y3, y4
    x1 = x0 + (R_1) * cos(A_1)
    y1 = y0 + (R_1) * sin(A_1)

    x2 = x0 + (R_1) * cos(A_2)
    y2 = y0 + (R_1) * sin(A_2)

    x3 = x0 + (R_2) * cos(A_2)
    y3 = y0 + (R_2) * sin(A_2)

    x4 = x0 + (R_2) * cos(A_1)
    y4 = y0 + (R_2) * sin(A_1)
    Render4V(imagename, x1, y1, 0.5, x2, y2, 0.5, x3, y3, 0.5, x4, y4, 0.5)
end

--- 用于显示 '击破时间  00.00s'
---@class THlib.kill_timer:object
kill_timer = Class(object)

function kill_timer:init(x, y, t)
    self.t = t
    self.x = x
    self.y = y
    self.yy = y
    self.alph = 0
end
function kill_timer:frame()
    if self.timer <= 30 then
        self.alph = self.timer / 30
        self.y = self.yy - 30 * cos(3 * self.timer)
    end
    if self.timer > 120 then
        self.alph = 1 - (self.timer - 120) / 30
    end
    if self.timer >= 150 then
        Del(self)
    end
end
function kill_timer:render()
    SetViewMode 'world'
    local alpha = self.alph
    SetFontState('time', '', Color(alpha * 255, 0, 0, 0))
    RenderText('time', string.format("%.2f", self.t / 60) .. 's',
            41, self.y - 1, 0.5, 'centerpoint')
    SetFontState('time', '', Color(alpha * 255, 200, 200, 200))
    RenderText('time', string.format("%.2f", self.t / 60) .. 's',
            40, self.y, 0.5, 'centerpoint')
    SetImageState('kill_time', '', Color(alpha * 255, 255, 255, 255))
    Render('kill_time', -40, self.y - 2, 0.6, 0.6)
end

--- 用于显示：
---'Get Spell Card Bonus'
---    '1,000,000'
---与kill_timer同时显示
---'Bonus Failed...'则由hinter显示
---@class THlib.hinter_bonus:object
hinter_bonus = Class(object)

function hinter_bonus:init(img, size, x, y, t1, t2, fade, bonus)
    self.img = img
    self.x = x
    self.y = y
    self.t1 = t1
    self.t2 = t2
    self.fade = fade
    self.group = GROUP_GHOST
    self.layer = LAYER_TOP
    self.size = size
    self.t = 0
    self.hscale = self.size
    self.bonus = bonus
end

function hinter_bonus:frame()
    if self.timer < self.t1 then
        self.t = self.timer / self.t1
    elseif self.timer < self.t1 + self.t2 then
        self.t = 1
    elseif self.timer < self.t1 * 2 + self.t2 then
        self.t = (self.t1 * 2 + self.t2 - self.timer) / self.t1
    else
        Del(self)
    end
end

function hinter_bonus:render()
    if self.fade then
        --透明度过渡
        SetImageState(self.img, '', Color(self.t * 255, 255, 255, 255))
        self.vscale = self.size
        SetFontState('score3', '', Color(self.t * 255, 255, 255, 255))
        RenderScore('score3', self.bonus, self.x + 1, self.y - 41, 0.7, 'centerpoint')
        object.render(self)
    else
        --垂直缩放过渡
        SetImageState(self.img, '', Color(0xFFFFFFFF))
        self.vscale = self.t * self.size
        SetFontState('score3', '', Color(255, 255, 255, 255))
        RenderScore('score3', self.bonus, self.x + 1, self.y - 41, 0.7, 'centerpoint')
        object.render(self)
    end
end
