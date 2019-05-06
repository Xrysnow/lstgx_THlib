---@class THlib.scdebugger.stage_init:core.stage
stage_init = stage.New('init', true, true)

function stage_init:init()
    menu_items = {}
    for i, v in ipairs(player_list) do
        table.insert(menu_items, { player_list[i][1], function()
            menu.FlyOut(menu_player_select, 'left')
            lstg.var.player_name = player_list[i][2]
            task.New(stage_init, function()
                task.Wait(30)
                New(mask_fader, 'close')
                task.Wait(30)
                stage.group.PracticeStart('SC Debugger@SC Debugger')
            end)
        end })
    end
    menu_player_select = New(simple_menu, 'Select Player', menu_items)
    New(mask_fader, 'open')
    menu.FlyIn(menu_player_select, 'right')
end

function stage_init:render()
    ui.DrawMenuBG()
end

stage.group.New('menu', {}, "SC Debugger",
        { lifeleft = 7, power = 400, faith = 50000, bomb = 2 }, false)
stage.group.AddStage('SC Debugger', 'SC Debugger@SC Debugger',
        { lifeleft = 7, power = 400, faith = 50000, bomb = 2 }, false)
stage.group.DefStageFunc('SC Debugger@SC Debugger', 'init', function(self)
    _init_item(self)
    New(mask_fader, 'open')
    New(_G[lstg.var.player_name])
    task.New(self, function()
        do
            LoadMusic('spellcard', music_list.spellcard[1], music_list.spellcard[2], music_list.spellcard[3])
            New(bamboo_background)
        end
        task._Wait(60)
        _play_music("spellcard")
        local _boss_wait = true
        local _ref = New(_editor_class[_boss_class_name], _editor_class[_boss_class_name].cards)
        last = _ref
        if _boss_wait then
            while IsValid(_ref) do
                task.Wait()
            end
        end
        task._Wait(180)
    end)
    task.New(self, function()
        while coroutine.status(self.task[1]) ~= 'dead' do
            task.Wait()
        end
        New(mask_fader, 'close')
        _stop_music()
        task.Wait(30)
        stage.group.FinishStage()
    end)
end)
