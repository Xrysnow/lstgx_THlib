
---srage.group
local group = {}
stage.group = group
stage.groups = {}

function group.New(title, stages, name, item_init, allow_practice, difficulty)
    local sg = { ['title'] = title, number = #stages }
    for i = 1, #stages do
        sg[i] = stages[i]
        local s = stage.New(stages[i])
        s.frame = stage.group.frame
        s.render = stage.group.render
        s.number = i
        s.group = sg
        sg[stages[i]] = s
        s.x, s.y = 0, 0
        s.name = stages[i]
    end
    if name then
        stage.groups[name] = sg
        table.insert(stage.groups, name)
    end
    if item_init then
        sg.item_init = item_init
    end
    sg.allow_practice = allow_practice or false
    sg.difficulty = difficulty or 1
    return sg
end
function group.AddStage(groupname, stagename, item_init, allow_practice)
    local sg = stage.groups[groupname]
    if sg ~= nil then
        sg.number = sg.number + 1
        table.insert(sg, stagename)
        local s = stage.New(stagename)
        if groupname == 'Spell Practice' then
            s.frame = stage.group.frame_sc_pr
        else
            s.frame = stage.group.frame
        end
        s.render = stage.group.render
        s.number = sg.number
        s.group = sg
        sg[stagename] = s
        s.x, s.y = 0, 0
        s.name = stagename
        if item_init then
            s.item_init = item_init
        end
        s.allow_practice = allow_practice or false
        return s
    end
end
function group.DefStageFunc(stagename, funcname, f)
    stage.stages[stagename][funcname] = f
end

function group.frame(self)
    ext.sc_pr = false
    if not lstg.var.init_player_data then
        error('Player data has not been initialized. (Call function item.PlayerInit.)')
    end
    --
    if lstg.var.lifeleft <= -1 then
        if ext.replay.IsReplay() then
            ext.pop_pause_menu = true
            ext.rep_over = true
            lstg.tmpvar.pause_menu_text = { 'Replay Again', 'Return to Title', nil }
        else
            PlayMusic('deathmusic', 0.8)
            ext.pop_pause_menu = true
            lstg.tmpvar.death = true
            lstg.tmpvar.pause_menu_text = { 'Continue', 'Quit and Save Replay', 'Restart' }
        end
        lstg.var.lifeleft = 0
    end
    --
    local order = ext.GetPauseMenuOrder()
    if order == 'Return to Title' then
        lstg.var.timeslow = nil
        stage.group.ReturnToTitle(false, 0)
    end
    if order == 'Replay Again' then
        lstg.var.timeslow = nil
        stage.Restart()
    end
    if order == 'Give up and Retry' then
        StopMusic('deathmusic')
        lstg.var.timeslow = nil
        if lstg.var.is_practice then
            stage.group.PracticeStart(self.name)
        else
            stage.group.Start(self.group)
        end
    end
    if order == 'Continue' then
        lstg.var.timeslow = nil
        StopMusic('deathmusic')
        if not Extramode then
            gamecontinueflag = true
            if lstg.var.block_spell then
                if lstg.var.is_practice then
                    stage.group.PracticeStart(self.name)
                else
                    stage.group.Start(self.group)
                end
                lstg.tmpvar.pause_menu_text = nil
            else
                --item.PlayerInit()
                -- START: modified by 二要 打分等代码修改记录
                local temp = lstg.var.score or 0
                lstg.var.score = 0
                item.PlayerReinit()
                lstg.tmpvar.hiscore = lstg.tmpvar.hiscore or 0
                if lstg.tmpvar.hiscore < temp then
                    lstg.tmpvar.hiscore = temp
                end
                -- END
                lstg.tmpvar.pause_menu_text = nil
                ext.pause_menu_order = nil
                if lstg.var.is_practice then
                    stage.group.PracticeStart(self.name)
                else
                    stage.stages[stage.current_stage.group.title].save_replay = nil
                end
            end
        else
            stage.group.Start(self.group)
            lstg.tmpvar.pause_menu_text = nil
        end
    end
    if order == 'Quit and Save Replay' then
        stage.group.ReturnToTitle(true, 0)
        lstg.tmpvar.pause_menu_text = nil
        lstg.tmpvar.death = true
        lstg.var.timeslow = nil
    end
    if order == 'Restart' then
        StopMusic('deathmusic')
        if lstg.var.is_practice then
            stage.group.PracticeStart(self.name)
        else
            stage.group.Start(self.group)
        end
        lstg.tmpvar.pause_menu_text = nil
        lstg.var.timeslow = nil
    end
end

function group.render(self)
    SetViewMode 'ui'
    ui.DrawFrame()
    if lstg.var.init_player_data then
        ui.DrawScore()
    end
    SetViewMode 'world'
    RenderClear(Color(0x00000000))
end

function group.frame_sc_pr(self)
    ext.sc_pr = true
    if not lstg.var.init_player_data then
        error('Player data has not been initialized. (Call function item.PlayerInit)')
    end
    if lstg.var.lifeleft <= -1 then
        if ext.replay.IsReplay() then
            ext.pop_pause_menu = true
            ext.rep_over = true
            lstg.tmpvar.pause_menu_text = { 'Replay Again', 'Return to Title', nil }
        else
            ext.pop_pause_menu = true
            lstg.tmpvar.death = true
            lstg.tmpvar.pause_menu_text = { 'Continue', 'Quit and Save Replay', 'Return to Title' }
        end
        lstg.var.lifeleft = 0
    end
    local order = ext.GetPauseMenuOrder()
    if order == 'Give up and Retry' then
        stage.Restart()
        lstg.tmpvar.pause_menu_text = nil
        lstg.var.timeslow = nil
    end
    if order == 'Return to Title' then
        stage.group.ReturnToTitle(false, 0)
        lstg.var.timeslow = nil
    end
    if order == 'Replay Again' then
        stage.Restart()
        lstg.var.timeslow = nil
    end
    if order == 'Continue' then
        stage.Restart()
        lstg.var.timeslow = nil
    end
    if order == 'Quit and Save Replay' then
        stage.group.ReturnToTitle(true, 0)
        lstg.tmpvar.pause_menu_text = nil
        lstg.tmpvar.death = true
        lstg.var.timeslow = nil
    end
end

function group.Start(group)
    lstg.var.is_practice = false
    stage.Set('save', group[1])
    stage.stages[group.title].save_replay = { group[1] }
end

function group.PracticeStart(stagename)
    lstg.var.is_practice = true
    stage.Set('save', stagename)
    stage.stages[stage.stages[stagename].group.title].save_replay = { stagename }
end

function group.FinishStage()
    local self = stage.current_stage
    local _group = self.group
    if self.number == _group.number or lstg.var.is_practice then
        if ext.replay.IsReplay() then
            ext.rep_over = true
            ext.pop_pause_menu = true
            lstg.tmpvar.pause_menu_text = { 'Replay Again', 'Return to Title', nil }
        else
            if lstg.var.is_practice then
                stage.group.ReturnToTitle(true, 0)
            else
                stage.group.ReturnToTitle(true, 1)
            end
        end
    else
        if ext.replay.IsReplay() then
            -- 载入关卡并执行录像
            --stage.Set('load',{ext.replay.sts.filename[1],'temp/'..group[self.number+1]})
            stage.Set('load',
                    ext.replay.GetReplayFilename(),
                    ext.replay.GetReplayStageName(ext.replay.GetCurrentReplayIdx() + 1))
        else
            -- 载入关卡并开始保存录像
            --stage.Set('save','temp/'..group[self.number+1],group[self.number+1])
            stage.Set('save', _group[self.number + 1])
            if stage.stages[_group.title].save_replay then
                table.insert(stage.stages[_group.title].save_replay, _group[self.number + 1])
            end
        end
    end
end
-----
function group.FinishReplay()
    local self = stage.current_stage
    local _group = self.group
    if self.number == _group.number or lstg.var.is_practice then
        if ext.replay.IsReplay() then
            ext.rep_over = true
            ext.pop_pause_menu = true
            lstg.tmpvar.pause_menu_text = { 'Replay Again', 'Return to Title', nil }
        end
    else
        if ext.replay.IsReplay() then
            -- 载入关卡并执行录像
            --stage.Set('load',{ext.replay.sts.filename[1],'temp/'..group[self.number+1]})
            stage.Set('load',
                    ext.replay.GetReplayFilename(),
                    ext.replay.GetReplayStageName(ext.replay.GetCurrentReplayIdx() + 1))
        end
    end
end
-----

function group.GoToStage(number)
    local self = stage.current_stage
    local _group = self.group
    number = number or self.number + 1
    if number > _group.number or lstg.var.is_practice then
        if lstg.var.is_practice then
            stage.group.ReturnToTitle(true, 0)
        else
            stage.group.ReturnToTitle(true, 1)
        end
    else
        if ext.replay.IsReplay() then
            --stage.Set('load',{ext.replay.sts.filename[1],'temp/'..group[number]})
            stage.Set('load', ext.replay.GetReplayFilename(), _group[number])
        else
            --stage.Set('save','temp/'..group[number],group[number])
            stage.Set('save', _group[number])
            if stage.stages[_group.title].save_replay then
                table.insert(stage.stages[_group.title].save_replay, _group[number])
            end
        end
    end
end

function group.FinishGroup()
    stage.group.ReturnToTitle(true, 1)
end

function group.ReturnToTitle(save_rep, finish)
    StopMusic('deathmusic')
    gamecontinueflag = false
    local self = stage.current_stage
    local title = stage.stages[self.group.title]
    title.finish = finish or 0
    if ext.replay.IsReplay() then
        title.save_replay = nil
    elseif not save_rep then
        title.save_replay = nil
        moveoverflag = true
    end
    stage.Set('none', self.group.title)
end
