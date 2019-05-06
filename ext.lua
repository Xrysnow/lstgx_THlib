gamecontinueflag = false

---@class THlib.ext
---@field replay THlib.ext.Replay
---@field mask_color lstg.Color
---@field mask_alph table
---@field mask_x table
---@field pause_menu_text table
ext = { replay = {} }

ext.mask_color = Color(0, 255, 255, 255)
ext.mask_alph = { 0, 0, 0 }
ext.mask_x = { 0, 0, 0 }
ext.pause_menu_text = { { 'Return to Game', 'Return to Title', 'Give up and Retry' },
                        { 'Return to Game', 'Return to Title', 'Replay Again' } }

function ext.GetPauseMenuOrder()
    return ext.pause_menu_order
end

Include('THlib/ext/assets.lua')
Include('THlib/ext/replay.lua')
Include('THlib/ext/pause_menu.lua')
Include('THlib/ext/stage_group.lua')

local ext_replay = ext.replay
local e = lstg.eventDispatcher

--------------------------------------------------------------------------------


--实现录像系统
--当mode = none时，参数stage用于表明下一个跳转的场景
--当mode = load时，参数path有效，指明从path录像文件中加载场景stage的录像数据
--当mode = save时，参数path无效，使用stage指定场景名称并开始录像

e:addListener('onStageSet', function(param)
    local mode, path, stageName = param[1], param[2], param[3]
    ext.pause_menu_order = nil

    ext_replay.beforeSet()

    if mode ~= "load" then
        ext_replay.beforeLoad()
    end

    -- 刷新最高分
    if (not stage.current_stage.is_menu) and (not ext.replay.IsReplay()) then
        local str = stage.current_stage.stage_name .. '@' .. tostring(lstg.var.player_name)
        if scoredata.hiscore[str] == nil then
            scoredata.hiscore[str] = 0
        end
        scoredata.hiscore[str] = max(scoredata.hiscore[str], lstg.var.score)
    end

    -- 转场
    if mode == "save" then
        assert(stageName == nil)
        stageName = path
        -- 设置随机数种子
        lstg.var.ran_seed = ((os.time() % 65536) * 877) % 65536
        ran:Seed(lstg.var.ran_seed)
        -- 开始执行录像
        ext_replay.onSave(stageName)

        -- 转场
        lstg.var.stage_name = stageName
        stage.next_stage = stage.stages[stageName]
    elseif mode == "load" then
        local nextName = ext_replay.onLoad(path, stageName)
        -- 转场
        lstg.var.stage_name = nextName
        stage.next_stage = stage.stages[stageName]
    else
        assert(mode == "none")
        assert(stageName == nil)
        stageName = path

        -- 转场
        lstg.var.stage_name = stageName
        stage.next_stage = stage.stages[stageName]
    end
end, 0, 'ext.StageSet')

e:addListener('onStageRestart', function()
    stage.preserve_res = true  -- 保留资源在转场时不清空
    if ext.replay.IsReplay() then
        stage.Set("load", ext.replay.GetReplayFilename(), lstg.var.stage_name)
        --stage.Set("load", ext.replay.GetReplayStageName(1), lstg.var.stage_name)
    elseif ext.replay.IsRecording() then
        stage.Set("save", lstg.var.stage_name)
    else
        stage.Set("none", lstg.var.stage_name)
    end
end, 0, 'ext.StageRestart')

----------------------------------------------------------------------

e:addListener('onGetInput', function()
    if stage.next_stage then
        lstg.tmpvar = {}
        --SystemLog('clear lstg.tmpvar')

        KeyStatePre = {}
        if not stage.next_stage.is_menu then
            if scoredata.hiscore == nil then
                scoredata.hiscore = {}
            end
            lstg.tmpvar.hiscore = scoredata.hiscore[stage.next_stage.stage_name .. '@' .. tostring(lstg.var.player_name)]
        end
    else
        -- 刷新KeyStatePre
        for k, v in pairs(setting.keys) do
            KeyStatePre[k] = KeyState[k]
        end
        for k, v in pairs(setting.keysys) do
            KeyStatePre[k] = KeyState[k]
        end
    end

    -- 不是录像时更新按键状态
    if not ext.replay.IsReplay() then
        for k, v in pairs(setting.keys) do
            KeyState[k] = GetKeyState(v)
        end
        for k, v in pairs(setting.keysys) do
            KeyState[k] = GetKeyState(v)
        end
    end

    if ext.replay.IsRecording() then
        -- 录像模式下记录当前帧的按键
        ext_replay.recordKey(KeyState)
    elseif ext.replay.IsReplay() then
        -- 回放时载入按键状态
        ext_replay.loadKey(KeyState)
    end
end, 0, 'ext.GetInput')

local time_slow_level = { 1, 2, 3, 4 }--60/30/20/15  4个程度


e:addListener('onFrameFunc', function()
    -- 无暂停时执行场景逻辑
    if ext.pause_menu == nil then
        -- 处理录像速度与正常更新逻辑
        if ext.replay.IsReplay() then
            ext_replay.tic()
            ext_replay.ticSlow()
            if GetKeyState(setting.keysys.repfast) then
                DoFrame(true, false)
                ext.pause_menu_order = nil
                DoFrame(true, false)
                ext.pause_menu_order = nil
                DoFrame(true, false)
                ext.pause_menu_order = nil
                DoFrame(true, false)
                ext.pause_menu_order = nil
            elseif GetKeyState(setting.keysys.repslow) then
                if ext_replay.isTic(4) then
                    DoFrame(true, false)
                    ext.pause_menu_order = nil
                else
                    --DoFrame(false, false)
                end
            else
                if lstg.var.timeslow then
                    local tmp = math.clamp(lstg.var.timeslow, 1, 4)
                    if ext_replay.isTicSlow(time_slow_level[tmp]) then
                        DoFrame(true, false)
                    end
                else
                    DoFrame(true, false)
                end
                ext.pause_menu_order = nil
            end
        else
            ext_replay.ticSlow()
            if lstg.var.timeslow and lstg.var.timeslow > 0 then
                local tmp = math.clamp(lstg.var.timeslow, 1, 4)
                if ext_replay.isTicSlow(time_slow_level[tmp]) then
                    DoFrame(true, false)
                end
            else
                DoFrame(true, false)
            end
        end

        -- 按键弹出菜单
        if (GetLastKey() == setting.keysys.menu or ext.pop_pause_menu) and not stage.current_stage.is_menu then
            ext.pause.create()
        end
    else
        ext.pause.frame()
    end
end, 0, 'ext.FrameFunc')

e:addListener('onAfterRender', function()
    if ext.pause_menu then
        ext.pause.render()
    end
end, 0, 'ext.AfterRender')

e:addListener('onFocusLose', function()
    if ext.pause_menu == nil and stage.current_stage then
        if not stage.current_stage.is_menu then
            ext.pop_pause_menu = true
        end
    end
end, 0, 'ext.FocusLose')

