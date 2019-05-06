--

local REPLAY_DIR = "replay"
local REPLAY_SUB_DIR = REPLAY_DIR .. '/' .. setting.mod
if plus.isMobile() then
    --REPLAY_DIR = cc.FileUtils:getInstance():getWritablePath() .. "replay"
    REPLAY_DIR = plus.getWritablePath() .. "replay"
    REPLAY_SUB_DIR = REPLAY_DIR .. '/' .. setting.mod
end

plus.CreateDirectory(REPLAY_DIR)
plus.CreateDirectory(REPLAY_SUB_DIR)

local replayManager = plus.ReplayManager(REPLAY_SUB_DIR)

local replayFilename = nil  ---当前打开的Replay文件名称
local replayInfo = nil  ---当前打开的Replay文件信息
local replayStageIdx = 1  ---当前正在播放的关卡
local replayReader = nil  ---帧读取器
local replayTicker = 0  ---控制录像速度时有用
local slowTicker = 0    ---控制时缓的变量

local replayStages = {}  ---记录所有关卡的录像数据
local replayWriter = nil  ---帧记录器

---@class THlib.ext.Replay
local ext_replay = {}
ext.replay = ext_replay
function ext_replay.IsReplay()
    -- 兼容性接口
    return replayReader ~= nil
end

function ext_replay.IsRecording()
    return replayWriter ~= nil
end

function ext_replay.GetCurrentReplayIdx()
    return replayStageIdx
end

function ext_replay.GetReplayFilename()
    return replayFilename
end

function ext_replay.GetReplayStageName(idx)
    assert(replayInfo ~= nil)
    return replayInfo.stages[idx].stageName
end

function ext_replay.RefreshReplay()
    replayManager:Refresh()
end

function ext_replay.GetSlotCount()
    return replayManager:GetSlotCount()
end

function ext_replay.GetSlot(idx)
    return replayManager:GetRecord(idx)
end

function ext_replay.SaveReplay(stageNames, slot, playerName, finish)
    local stages = {}
    finish = finish or 0
    for _, v in ipairs(stageNames) do
        assert(replayStages[v])
        table.insert(stages, replayStages[v])
    end

    -- TODO: gameName和gameVersion可以被用来检查录像文件的合法性
    plus.ReplayManager.SaveReplayInfo(
            replayManager:MakeReplayFilename(slot),
            {
                gameName     = setting.mod,
                gameVersion  = 1,
                userName     = playerName,
                group_finish = finish,
                stages       = stages
            }
    )
end

function ext_replay.beforeSet()
    -- 针对上一个可能的场景保存其数据
    if replayWriter ~= nil then
        local recordStage = replayStages[lstg.var.stage_name]
        recordStage.score = lstg.var.score
        recordStage.stageTime = os.time() - recordStage.stageTime  -- TODO：这个方法只保存了大致时间，包括了暂停
        --TODO 应该在关卡开始时保存
        recordStage.stageExtendInfo = Serialize(lstg.var)
    end
    -- 关闭上一个场景的录像读写
    replayWriter = nil
    if replayReader then
        replayReader:Close()
        replayReader = nil
    end
    replayTicker = 0
    slowTicker = 0
end

function ext_replay.beforeLoad()
    replayFilename = nil  -- 装载时使用缓存的数据
    replayInfo = nil
    replayStageIdx = 0
end

function ext_replay.onLoad(path, stageName)
    if path ~= replayFilename then
        replayFilename = path
        replayInfo = plus.ReplayManager.ReadReplayInfo(path)  -- 重新读取录像信息以保证准确性
        assert(#replayInfo.stages > 0)
    end
    assert(replayInfo)

    -- 决定场景顺序
    if stageName then
        replayStageIdx = nil
        for i, v in ipairs(replayInfo.stages) do
            if replayInfo.stages[i].stageName == stageName then
                replayStageIdx = i
                break
            end
        end
        assert(replayStageIdx ~= nil)
    else
        replayStageIdx = 1
    end

    -- 加载数据
    local nextRecordStage = replayInfo.stages[replayStageIdx]
    replayReader = plus.ReplayFrameReader(path, nextRecordStage.frameDataPosition, nextRecordStage.frameCount)

    -- 加载数据
    lstg.var = DeSerialize(nextRecordStage.stageExtendInfo)
    assert(lstg.var.ran_seed == nextRecordStage.randomSeed)  -- 这两个应该相等

    return nextRecordStage.stageName
end

function ext_replay.onSave(stageName)
    local sg = string.match(stageName, '^.+@(.+)$')
    replayWriter = plus.ReplayFrameWriter()
    replayStages[stageName] = {
        stageName     = stageName, score = 0, randomSeed = lstg.var.ran_seed,
        stageTime     = os.time(), stageDate = os.time(), stagePlayer = lstg.var.rep_player,
        group_num     = stage.groups[sg].number,
        cur_stage_num = (stage.current_stage.number or 100),
        frameData     = replayWriter
    }
end

function ext_replay.recordKey(keyState)
    replayWriter:Record(keyState)
end

function ext_replay.loadKey(keyState)
    replayReader:Next(keyState)
    --assert(replayReader:Next(KeyState), "Unexpected end of replay file.")
end

function ext_replay.tic()
    replayTicker = replayTicker + 1
end

function ext_replay.ticSlow()
    slowTicker = slowTicker + 1
end

function ext_replay.isTic(n)
    return replayTicker % n == 0
end

function ext_replay.isTicSlow(n)
    return slowTicker % n == 0
end

