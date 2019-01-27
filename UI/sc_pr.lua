stage.group.New('menu', {}, "Spell Practice", { lifeleft = 0, power = 400, faith = 50000, bomb = 0 }, false)
stage.group.AddStage('Spell Practice', 'Spell Practice@Spell Practice', { lifeleft = 0, power = 400, faith = 50000, bomb = 0 }, false)
stage.group.DefStageFunc('Spell Practice@Spell Practice', 'init', function(self)
    _init_item(self)
    New(mask_fader, 'open')
    New(_G[lstg.var.player_name])
    task.New(self, function()
        do
            if _editor_class[_sc_table[lstg.var.sc_index][1]].bgm ~= "" then
                LoadMusicRecord(_editor_class[_sc_table[lstg.var.sc_index][1]].bgm)
            else
                LoadMusic('spellcard', music_list.spellcard[1], music_list.spellcard[2], music_list.spellcard[3])
            end
            if _editor_class[_sc_table[lstg.var.sc_index][1]]._bg ~= nil then
                New(_editor_class[_sc_table[lstg.var.sc_index][1]]._bg)
            else
                New(bamboo_background)
            end
        end
        task._Wait(30)
        local _, bgm = EnumRes('bgm')
        for _, v in pairs(bgm) do
            if GetMusicState(v) ~= 'stopped' then
                ResumeMusic(v)
            else
                if _editor_class[_sc_table[lstg.var.sc_index][1]].bgm ~= "" then
                    _play_music(_editor_class[_sc_table[lstg.var.sc_index][1]].bgm)
                else
                    _play_music("spellcard")
                end
            end
        end
        local _boss_wait = true
        local _ref
        if _sc_table[lstg.var.sc_index][5] then
            _ref = New(_editor_class[_sc_table[lstg.var.sc_index][1]], {
                _editor_class[_sc_table[lstg.var.sc_index][1]].cards[_sc_table[lstg.var.sc_index][4] - 1],
                _sc_table[lstg.var.sc_index][3] })
            last = _ref
        else
            _ref = New(_editor_class[_sc_table[lstg.var.sc_index][1]], {
                boss.move.New(0, 144, 60, MOVE_DECEL),
                _sc_table[lstg.var.sc_index][3] })
            last = _ref
        end
        if _boss_wait then
            while IsValid(_ref) do
                task.Wait()
            end
        end
        task._Wait(150)
        if ext.replay.IsReplay() then
            ext.pop_pause_menu = true
            ext.rep_over = true
            lstg.tmpvar.pause_menu_text = { 'Replay Again', 'Return to Title', nil }
        else
            ext.pop_pause_menu = true
            lstg.tmpvar.death = false
            lstg.tmpvar.pause_menu_text = { 'Continue', 'Quit and Save Replay', 'Return to Title' }
        end
        task._Wait(60)
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
