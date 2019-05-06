---from LuaSTG_er+ 1.02
---data/Thlib/UI/debugger.lua
---comment by Xrysnow 2017.09.16

---用于编辑器调试
--[[
debugCode=string.format(
    "_debug_stage_name='%s@%s'\nInclude 'THlib\\\\UI\\\\debugger.lua'\n",
    Tree.data[stageNode:GetValue()].attr[1],
    Tree.data[groupNode:GetValue()].attr[1])
]]

---@class THlib.debugger.stage_init:core.stage
stage_init = stage.New('init', true, true)
function stage_init:init()
    menu_items = { }
    for i, v in ipairs(player_list) do
        table.insert(menu_items, {
            player_list[i][1], function()
                menu.FlyOut(menu_player_select, 'left')
                lstg.var.player_name = player_list[i][2]
                task.New(stage_init, function()
                    task.Wait(30)
                    New(mask_fader, 'close')
                    task.Wait(30)
                    stage.group.PracticeStart(_debug_stage_name)
                end)
            end
        })
    end
    menu_player_select = New(simple_menu, 'Select Player', menu_items)
    New(mask_fader, 'open')
    menu.FlyIn(menu_player_select, 'right')
end
function stage_init:render()
    ui.DrawMenuBG()
end
