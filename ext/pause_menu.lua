---@class THlib.ext.pause
local pause = {}
ext.pause = pause

local min = min
local max = max
local Color = Color

function pause.create()
    ext.pop_pause_menu = nil
    ext.rep_over = false
    PlaySound('pause', 0.5)
    if not (ext.sc_pr) then
        local _, bgm = EnumRes('bgm')
        for _, v in pairs(bgm) do
            if GetMusicState(v) ~= 'stopped' and v ~= 'deathmusic' then
                PauseMusic(v)
            end
        end
    end
    ext.pause_menu = {
        pos         = 1,
        pos2        = 2,
        ok          = false,
        choose      = false,
        pos_pre     = 1,
        timer       = 0,
        t           = 30,
        eff         = 0,
        pos_changed = 0,
    }
    task.New(ext.pause_menu, function()
        ext.pause_menu.lock = true
        ext.mask_alph = { 0, 0, 0 }
        ext.mask_x = { 0, 0, 0 }
        for i = 1, 50 do
            ext.mask_color = Color(i * 4.1, 0, 0, 0)
            ext.mask_alph[1] = min(i * 8, 239)
            ext.mask_alph[2] = max(min((i - 10) * 8, 239), 0)
            ext.mask_alph[3] = max(min((i - 20) * 8, 239), 0)
            ext.mask_x[1] = min(-210 + i, -180)
            ext.mask_x[2] = min(-220 + i, -180)
            ext.mask_x[3] = min(-230 + i, -180)
            ext.font_alpha = i * 0.0333
            task.Wait(1)
        end
        ext.pause_menu.lock = nil
    end)
end

function pause.frame()
    -- 暂停菜单部分
    local m = ext.replay.IsReplay() and 2 or 1
    --
    local pause_menu_text
    if lstg.tmpvar.pause_menu_text then
        pause_menu_text = lstg.tmpvar.pause_menu_text
    else
        pause_menu_text = ext.pause_menu_text[m]
    end
    --
    local pause_menu = ext.pause_menu
    if GetLastKey() == setting.keys.up and pause_menu.t <= 0 and pause_menu then
        if not pause_menu.choose then
            pause_menu.pos = pause_menu.pos - 1
        else
            pause_menu.pos2 = pause_menu.pos2 - 1
        end
        PlaySound('select00', 0.3)
    end
    if GetLastKey() == setting.keys.down and pause_menu.t <= 0 and pause_menu then
        if not pause_menu.choose then
            pause_menu.pos = pause_menu.pos + 1
        else
            pause_menu.pos2 = pause_menu.pos2 + 1
        end
        PlaySound('select00', 0.3)
    end
    pause_menu.pos = (pause_menu.pos - 1) % (#pause_menu_text) + 1
    pause_menu.pos2 = (pause_menu.pos2 - 1) % (2) + 1
    --
    pause_menu.timer = pause_menu.timer + 1
    if pause_menu.t > 0 then
        pause_menu.t = pause_menu.t - 1
    end
    if pause_menu.choose then
        pause_menu.eff = min(pause_menu.eff + 1, 15)
    else
        pause_menu.eff = max(pause_menu.eff - 1, 0)
    end
    if pause_menu.pos_changed > 0 then
        pause_menu.pos_changed = pause_menu.pos_changed - 1
    end
    if pause_menu.pos_pre ~= pause_menu.pos then
        pause_menu.pos_changed = ui.menu.shake_time
    end
    pause_menu.pos_pre = pause_menu.pos
    --
    task.Do(pause_menu)
    --DoFrame(false, false)
    if IsValid(_menu_pause) then
        task.Do(_menu_pause)
    end
    local lastKey = GetLastKey()
    local t_key = { setting.keysys.menu, setting.keys.shoot, setting.keys.spell, setting.keysys.retry }
    if table.has(t_key, lastKey) and pause_menu and not pause_menu.lock then
        Del(_menu_pause)
        if lastKey == setting.keysys.retry then
            PlaySound('ok00', 0.3)
            lstg.tmpvar.death = false
            pause_menu.t = 60
            pause_menu.pos2 = 1
            if ext.replay.IsReplay() then
                ext.pause_menu_order = 'Replay Again'
            else
                ext.pause_menu_order = 'Give up and Retry'
            end
        end
        if lastKey == setting.keys.shoot and pause_menu.t < 1 then
            pause_menu.t = 15
            local disableHighlight = function()
                -- 将高光子弹混合类型改为空
                for img, v in pairs(bullet.gclist) do
                    for color, status in pairs(v) do
                        if status then
                            ChangeBulletHighlight(img, color, false)
                        end
                    end
                end
            end
            if not pause_menu.choose then
                PlaySound('ok00', 0.3)
                if pause_menu.pos == 1 then
                    lstg.tmpvar.death = false
                    ext.pause_menu_order = pause_menu_text[pause_menu.pos]
                    if pause_menu.pos ~= 1 then
                        disableHighlight()
                    end
                else
                    pause_menu.choose = true
                end
            else
                if pause_menu.pos2 == 1 then
                    PlaySound('ok00', 0.3)
                    pause_menu.t = 60
                    if not (ext.sc_pr) then
                        task.New(pause_menu, function()
                            local _, bgm = EnumRes('bgm')
                            for i = 1, 30 do
                                for _, v in pairs(bgm) do
                                    if GetMusicState(v) == 'playing' then
                                        SetBGMVolume(v, 1 - i / 30)
                                    end
                                end
                                task.Wait()
                            end
                        end)
                    end
                    pause_menu.t = 60
                    lstg.tmpvar.death = false
                    ext.pause_menu_order = pause_menu_text[pause_menu.pos]
                    if pause_menu.pos ~= 1 then
                        disableHighlight()
                    end
                else
                    pause_menu.choose = false
                    PlaySound('cancel00', 0.3)
                    pause_menu.t = 15
                end
            end
        end
        if lastKey == setting.keys.spell and pause_menu.t < 1 and pause_menu.choose == true then
            pause_menu.choose = false
            pause_menu.t = 15
            PlaySound('cancel00', 0.3)
        end
        if not lstg.tmpvar.death and (pause_menu.pos2 == 1 or pause_menu.pos == 1) then
            task.New(pause_menu, function()
                pause_menu.lock = true
                for i = 30, 1, -1 do
                    ext.mask_color = Color(i * 7, 0, 0, 0)
                    for j = 1, 3 do
                        ext.mask_alph[j] = i * 8
                    end
                    ext.font_alpha = i * 0.0333
                    task.Wait(1)
                end
                task.New(stage.current_stage, function()
                    task.Wait(1)
                    local _, bgm = EnumRes('bgm')
                    for _, v in pairs(bgm) do
                        if GetMusicState(v) ~= 'stopped' then
                            ResumeMusic(v)
                        end
                    end
                    --[[local sound,_=EnumRes('snd')
                        for _,v in pairs(sound) do
                            if GetSoundState(v)=='paused' then
                                ResumeSound(v)
                            end
                        end]]
                    --StopMusic('deathmusic')
                end)
                ext.pause_menu = nil
            end)
        end
    end
end

function pause.render()
    --暂停时变暗
    --		SetViewMode'ui'
    --		SetImageState('white','',ext.mask_color)
    --		RenderRect('white',0,640,0,480)
    SetViewMode 'world'
    local m = ext.replay.IsReplay() and 2 or 1

    SetImageState('pause_eff', '',
            Color(ext.mask_alph[1] / 3,
                    200 * ext.pause_menu.eff / 15 + 55,
                    200 * (1 - ext.pause_menu.eff / 15) + 55,
                    200 * (1 - ext.pause_menu.eff / 15) + 55))
    Render('pause_eff',
            -150 + 180 * ext.pause_menu.eff / 15,
            -90, 4 + 4 * sin(ext.pause_menu.timer * 3),
            0.4, 0.6)
    local pause_menu_text
    local pause_menu_choose = { 'yes', 'no' }
    if lstg.tmpvar.pause_menu_text then
        pause_menu_text = lstg.tmpvar.pause_menu_text
    else
        pause_menu_text = ext.pause_menu_text[m]
    end
    local textnumber = 0
    if pause_menu_text[3] then
        textnumber = 3
    else
        textnumber = 2
    end
    if pause_menu_text then
        local c1_dark = Color(ext.mask_alph[1] + 15, 100, 100, 100)
        local c1_bright = Color(ext.mask_alph[1] + 15, 255, 255, 255)
        local pause_title
        if lstg.tmpvar.pause_menu_text then
            if ext.rep_over then
                pause_title = 'pause_replyover'
            elseif not ext.sc_pr then
                pause_title = 'pause_gameover'
            end
        else
            if m == 1 then
                pause_title = 'pause_pausemenu'
            else
                pause_title = 'pause_replyover'
            end
        end
        if pause_title then
            if ext.pause_menu.choose then
                SetImageState(pause_title, '', c1_dark)
            else
                SetImageState(pause_title, '', c1_bright)
            end
            Render(pause_title, ext.mask_x[1], -30, 0, 0.7, 0.7)
        end

        for i = 1, textnumber do
            local pause_txt = 'pause_' .. pause_menu_text[i]
            local alph = ext.mask_alph[i] + 15
            if not (ext.pause_menu.choose) then
                if i == ext.pause_menu.pos and alph >= 245 then
                    SetImageState(pause_txt, '',
                            Color(alph,
                                    155 + 100 * sin(ext.pause_menu.timer * 4.5),
                                    255,
                                    222))
                else
                    SetImageState(pause_txt, '', Color(alph, 100, 100, 100))
                end
            else
                if i == ext.pause_menu.pos and alph >= 245 then
                    SetImageState(pause_txt, '', Color(55, 255, 255, 255))
                else
                    SetImageState(pause_txt, '', Color(55, 100, 100, 100))
                end
            end
            Render(pause_txt, ext.mask_x[i] + (1 + i) * 10, -30 - i * 40, 0, 0.62, 0.62)
        end
    end
    if ext.pause_menu.choose then
        Render('pause_really', 0, -50, 0, 0.62, 0.62)
        for i = 1, 2 do
            local pause_choose = 'pause_' .. pause_menu_choose[i]
            local alph = ext.mask_alph[i] + 15
            if i == ext.pause_menu.pos2 then
                SetImageState(pause_choose, '',
                        Color(alph,
                                155 + 100 * sin(ext.pause_menu.timer * 4.5),
                                255,
                                255))
            else
                SetImageState(pause_choose, '', Color(alph, 100, 100, 100))
            end
            Render(pause_choose, 15 + i * 10, -50 - i * 40, 0, 0.62, 0.62)
        end
    end
end



