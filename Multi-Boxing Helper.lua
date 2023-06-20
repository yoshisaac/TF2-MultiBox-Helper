-- Bot helper by __null
-- Forked by Dr_Coomer -- I want people to note that some comments were made by me, and some were made by the original author. I try to keep what is mine and what was by the original as coherent as possible, even if my rambalings themselfs are not. Such as this long useless comment. The unfinished medi gun and inventory manager is by the original auther and such. I am just possonate about multi-boxing, and when I found this lua I saw things that could be changed around or added, so that multiboxing can be easier and less of a slog of going to each client or computer and manually changing classes, loud out, or turning on and off features.

-- Settings:
-- Trigger symbol. All commands should start with this symbol.
local triggerSymbol = "!";

-- Process messages only from lobby owner.
local lobbyOwnerOnly = true;

-- Check if we want to me mic spamming or not.
local PlusVoiceRecord = false;

-- Global check for if we want to autovote
local AutoVoteCheck = false;

-- Global check for if we want ZoomDistance to be enabled
local ZoomDistanceCheck = false;

-- Keep the table of command arguments outside of all functions, so we can just jack this when ever we need anymore than a single argument.
local commandArgs;

-- Constants
local k_eTFPartyChatType_MemberChat = 1;
local steamid64Ident = 76561197960265728;
local partyChatEventName = "party_chat";
local playerJoinEventName = "player_spawn";
local availableClasses = { "scout", "soldier", "pyro", "demoman", "heavy", "engineer", "medic", "sniper", "spy", "random" };
local availableOnOffArguments = { "1", "0", "on", "off" };
local availableSpam = { "none", "branded", "custom" };
local availableSpamSecondsString = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "50", "51", "52", "53", "54", "55", "56", "57", "58", "59", "60"} -- Made chatgpt write this lmao
local medigunTypedefs = {
    default = { 29, 211, 663, 796, 805, 885, 894, 903, 912, 961, 970 },
    quickfix = { 411 },
    kritz = { 35 }
};
 
-- Command container
local commands = {};
 
-- Found mediguns in inventory.
local foundMediguns = {
    default = -1,
    quickfix = -1,
    kritz = -1
};
 
-- Helper method that converts SteamID64 to SteamID3
local function SteamID64ToSteamID3(steamId64)
    return "[U:1:" .. steamId64 - steamid64Ident .. "]";
end
 
-- Thanks, LUA!
local function SplitString(input, separator)
    if separator == nil then
        separator = "%s";
    end

    local t = {};

    for str in string.gmatch(input, "([^" .. separator .. "]+)") do
            table.insert(t, str);
    end

    return t;
end
 
-- Helper that sends a message to party chat
local function Respond(input)
    client.Command("say_party " .. input, true);
end
 
-- Helper that checks if table contains a value
function Contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true;
        end
    end
 
    return false;
end

-- Game event processor
local function FireGameEvent(event)
    -- Validation.
    -- Checking if we've received a party_chat event.
    if event:GetName() ~= partyChatEventName then
        return;
    end
 
    -- Checking a message type. Should be k_eTFPartyChatType_MemberChat.
    if event:GetInt("type") ~= k_eTFPartyChatType_MemberChat then
        return;
    end
 
    local partyMessageText = event:GetString("text");
 
    -- Checking if message starts with a trigger symbol.
    if string.sub(partyMessageText, 1, 1) ~= triggerSymbol then
        return;
    end
 
    if lobbyOwnerOnly then
        -- Validating that message sender actually owns this lobby
        local senderId = SteamID64ToSteamID3(event:GetString("steamid"));
 
        if party.GetLeader() ~= senderId then
            return;
        end
    end
 
    -- Parsing the command
    local fullCommand = string.lower(string.sub(partyMessageText, 2, #partyMessageText));
    commandArgs = SplitString(fullCommand);
 
    -- Validating if we know this command
    local commandName = commandArgs[1];
    local commandCallback = commands[commandName];
 
    if commandCallback == nil then
        Respond("Unknown command [" .. commandName .. "]");
        return;
    end
 
    -- Removing command name
    table.remove(commandArgs, 1);
 
    -- Calling callback
    commandCallback(commandArgs);
end

-- ============= Commands' section ============= --
local function KillCommand(args)
    client.Command("kill", true);
    Respond("The HAEVY IS DEAD.");
end

local function ExplodeCommand(args)
    client.Command("explode", true);
    Respond("Kaboom!");
end

local function SwitchWeapon(args)
    local slotStr = args[1];

    if slotStr == nil then
        Respond("Usage: " .. triggerSymbol .. "slot <slot number>");
        return;
    end

    local slot = tonumber(slotStr);

    if slot == nil then
        Respond("Unknown slot [" .. slotStr .. "]. Available are 0-10.");
        return;
    end

    if slot < 0 or slot > 10 then
        Respond("Unknown slot [" .. slotStr .. "]. Available are 0-10.");
        return;
    end

    Respond("Switched weapon to slot [" .. slot .. "]");
    client.Command("slot" .. slot, true);
end

-- Follow bot switcher added by Dr_Coomer - Doctor_Coomer#4425
local function FollowBotSwitcher(args)
    local fbot = args[1];

    if fbot == nil then
        Respond("Usage: " .. triggerSymbol .. "fbot stop/friends/all");
        return;
    end

    fbot = string.lower(args[1]);

    if fbot == "stop" then
        Respond("Disabling followbot!");
        fbot = "none";
    end

    if fbot == "friends" then
        Respond("Following only friends!");
        fbot = "friends only";
    end

    if fbot == "all" then
        Respond("Following everyone!");
        fbot = "all players";
    end

    gui.SetValue("follow bot", fbot);
end

-- Loudout changer added by Dr_Coomer - Doctor_Coomer#4425
local function LoadoutChanger(args)
    local lout = args[1];

    if lout == nil then
        Respond("Usage: " .. triggerSymbol .. "lout A/B/C/D");
        return;
    end

    --Ahhhhh
    --More args, more checks, more statements.

    if string.lower(lout) == "a" then
        Respond("Switching to loudout A!");
        lout = "0";
    elseif lout == "1" then
        Respond("Switching to loudout A!");
        lout = "0"; --valve counts from zero. to make it user friendly since humans count from one, the args are between 1-4 and not 0-3
    end
    
    if string.lower(lout) == "b" then
        Respond("Switching to loutoud B!");
        lout = "1";
    elseif lout == "2" then
        Respond("Switching to loutoud B!");
        lout = "1"
    end

    if string.lower(lout) == "c" then
        Respond("Switching to loudout C!");
        lout = "2";
    elseif lout == "3" then
        Respond("Switching to loudout C!");
        lout = "2";
    end

    if string.lower(lout) == "d" then
        Respond("Switching to loudout D!");
        lout = "3";
    elseif lout == "4" then
        Respond("Switching to loudout D!");
        lout = "3";
    end

    client.Command("load_itempreset " .. lout, true);
end


-- Lobby Owner Only Toggle added by Dr_Coomer - Doctor_Coomer#4425
local function TogglelobbyOwnerOnly(args)
    local OwnerOnly = args[1]

    if OwnerOnly == nil or not Contains(availableOnOffArguments, OwnerOnly) then
        Respond("Usage: " .. triggerSymbol .. "OwnerOnly 1/0 or on/off");
        return;
    end

    if OwnerOnly == "1" then
        lobbyOwnerOnly = true;
    elseif string.lower(OwnerOnly) == "on" then
        lobbyOwnerOnly = true;
    end

    if OwnerOnly == "0" then
        lobbyOwnerOnly = false;
    elseif string.lower(OwnerOnly) == "off" then
        lobbyOwnerOnly = false;
    end

    Respond("Lobby Owner Only is now: " .. OwnerOnly)
end

-- Toggle ignore friends added by Dr_Coomer - Doctor_Coomer#4425
local function ToggleIgnoreFriends(args)
    local IgnoreFriends = args[1]

    if IgnoreFriends == nil or not Contains(availableOnOffArguments, IgnoreFriends) then
        Respond("Usage: " .. triggerSymbol .. "IgnoreFriends 1/0 or on/off")
        return;
    end

    if IgnoreFriends == "1" then
        IgnoreFriends = 1;
    elseif string.lower(IgnoreFriends) == "on" then
        IgnoreFriends = 1;
    end
    
    if IgnoreFriends == "0" then
        IgnoreFriends = 0;
    elseif string.lower(IgnoreFriends) == "off" then
        IgnoreFriends = 0;
    end

    Respond("Ignore Steam Friends is now: " .. IgnoreFriends)
    gui.SetValue("Ignore Steam Friends", IgnoreFriends)
end

-- connect to servers via IP re implemented by Dr_Coomer - Doctor_Coomer#4425
--Context: There was a registered callback for a command called "connect" but there was no function for it. So, via the name of the registered callback, I added it how I thought he would have.
local function Connect(args)
    local Connect = args[1]

    Respond("Joining server " .. Connect .. "...")

    client.Command("connect " .. Connect, true);
end

-- Chatspam switcher added by Dr_Coomer - Doctor_Coomer#4425
local function cspam(args)
    local cspam = args[1];

    if cspam == nil then
        Respond("Usage: " .. triggerSymbol .. "cspam none/branded/custom")
        return;
    end

    local cspamSeconds = table.remove(commandArgs, 2)
    cspam = string.lower(args[1])

    --Code:
    --Readable: N
    --Works: Y
    --I hope no one can see how bad this is, oh wait...

    if not Contains(availableSpam, cspam) then
        if Contains(availableSpamSecondsString, cspam) then
            print("switching seconds")
            Respond("Chat spamming with " .. cspam .. " second interval")
            gui.SetValue("Chat Spam Interval (s)", tonumber(cspam, 10))
            return;
        end

        Respond("Unknown chatspam: [" .. cspam .. "]")
        return;

    end

    if Contains(availableSpam, cspam) then
        if Contains(availableSpamSecondsString, cspamSeconds) then
            print("switching both")
            gui.SetValue("Chat Spam Interval (s)", tonumber(cspamSeconds, 10)) --I hate this god damn "tonumber" function. Doesn't do as advertised. It needs a second argument called "base". Setting it anything over 10, then giving the seconds input anything over 9, will then force it to be to that number. Seconds 1-9 will work just fine, but if you type 10 it will be forced to that number. --mentally insane explination
            gui.SetValue("Chat spammer", cspam)
            Respond("Chat spamming " .. cspam .. " with " .. tostring(cspamSeconds) .. " second interval")
            return;
        end
    end

    if not Contains(availableSpamSecondsString, cspam) then
        if Contains(availableSpam, cspam) then
            print("switching spam")
            gui.SetValue("Chat spammer", cspam)
            Respond("Chat spamming " .. cspam)
            return;
        end
    end
end


-- ZoomDistance from cathook, added by Dr_Coomer
-- Zoom Distance means that it will automatically zoomin when you are in a cirtant distance from a player
-- it will not change the visual zoom distance when scoping in
local IsInRange = false;
local closestplayer

local CurrentClosestX
local CurrentClosestY

local Distance = 500; --defaults distance

local function zoomdistance(args)
    local zoomdistance = args[1]
    local zoomdistanceDistance = tonumber(table.remove(commandArgs, 2))

    if zoomdistance == nil then
        Respond("Example: " .. triggerSymbol .. "zoomdistance on 650")
        return
    end

    zoomdistance = string.lower(args[1])

    if zoomdistance == "1" then
        ZoomDistanceCheck = true
    elseif zoomdistance == "on" then
        ZoomDistanceCheck = true
    end

    if zoomdistance == "0" then
        ZoomDistanceCheck = false
    elseif zoomdistance == "off" then
        ZoomDistanceCheck = false
    end

    if zoomdistanceDistance == nil then
        return;
    end

    Distance = zoomdistanceDistance

end

function DistanceFrom(x1, y1, x2, y2) --Maths :nerd:
    return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

local function GetPlayerLocations()
    ::Return:: --I don't trust the normal return when doing this

    local localp = entities.GetLocalPlayer()
    local players = entities.FindByClass("CTFPlayer")

    if ZoomDistanceCheck == false then
        return;
    end

    if localp == nil then
        return;
    end

    local localpOrigin = localp:GetAbsOrigin();
    local localX = localpOrigin.x
    local localY = localpOrigin.y

    for i, player in ipairs(players) do

        --Skip players we don't want to enumerate
        if not player:IsAlive() then
            goto Ignore
        end

        if player:IsDormant() then
            goto Ignore    
        end

        if player == localp then
            goto Ignore
        end
        if player:GetTeamNumber() == localp:GetTeamNumber() then
            goto Ignore
        end

        --Get the current enumerated player's vector2 from their vector3
        local Vector3Players = player:GetAbsOrigin()
        local X = Vector3Players.x
        local Y = Vector3Players.y

        if IsInRange == false then
            if DistanceFrom(localX, localY, X, Y) < Distance then --If we get someone that is in range then we save who they are and their vector2
                IsInRange = true;

                closestplayer = player;

                CurrentClosestX = closestplayer:GetAbsOrigin().x
                CurrentClosestY = closestplayer:GetAbsOrigin().y
            end
        end
        ::Ignore::
    end

    if IsInRange == true then

        CurrentClosestX = closestplayer:GetAbsOrigin().x
        CurrentClosestY = closestplayer:GetAbsOrigin().y

        if closestplayer:IsDormant() then
            CurrentClosestX = nil
            CurrentClosestY = nil
            closestplayer = nil;

            IsInRange = false;
            goto Return;
        end

        if not closestplayer:IsAlive() then --Check if the current closest player has died

            CurrentClosestX = nil
            CurrentClosestY = nil
            closestplayer = nil;

            IsInRange = false;
            goto Return;
        end

        if DistanceFrom(localX, localY, CurrentClosestX, CurrentClosestY) > Distance then --Check if they have left our range

            CurrentClosestX = nil
            CurrentClosestY = nil
            closestplayer = nil;

            IsInRange = false;
            goto Return;
        end
    end
end


-- Auto unzoom. Needs improvement. Took it from some random person in the telegram months ago.
local stopScope = false;
local countUp = 0;
local function AutoUnZoom(cmd)
    local localp = entities.GetLocalPlayer();

    if (localp == nil or not localp:IsAlive()) then
        return;
    end

    if IsInRange == true then
        if not (localp:InCond( TFCond_Zoomed)) then 
            cmd.buttons = cmd.buttons | IN_ATTACK2 
        end
    elseif IsInRange == false then
        if stopScope == false then
            if (localp:InCond( TFCond_Zoomed)) then 
                cmd.buttons = cmd.buttons | IN_ATTACK2 
                stopScope = true;
            end
        end
    end


    --Wait logic
    if stopScope == true then
        countUp = countUp + 1;
        if countUp == 66 then 
            countUp = 0;
            stopScope = false;
        end
    end
end

--Toggle noisemaker spam, Dr_Coomer
local function noisemaker(args)
    local nmaker = args[1];

    if nmaker == nil or not Contains(availableOnOffArguments, nmaker) then
        Respond("Usage: " .. triggerSymbol .. "nmaker 1/0 or on/off")
        return;
    end

    if nmaker == "1" then
        nmaker = 1;
    elseif string.lower(nmaker) == "on" then
        nmaker = 1;
    end
    
    if nmaker == "0" then
        nmaker = 0;
    elseif string.lower(nmaker) == "off" then
        nmaker = 0;
    end

    Respond("Noise maker spam is now: " .. nmaker)
    gui.SetValue("Noisemaker Spam", nmaker)
end

-- Autovote casting, added by Dr_Coomer, pasted from drack's autovote caster to vote out bots (proof I did this before drack887: https://free.novoline.pro/ouffcjhnm8yhfjomdf.png)
local function autovotekick(args) -- toggling the boolean
    local autovotekick = args[1]

    if autovotekick == nil or not Contains(availableOnOffArguments, autovotekick) then
        Respond("Usage: " .. triggerSymbol .. "autovotekick 1/0 or on/off")
        return;
    end

    if autovotekick == "1" then
        AutoVoteCheck = true;
    elseif string.lower(autovotekick) == "on" then
        AutoVoteCheck = true;
    end
    
    if autovotekick == "0" then
        AutoVoteCheck = false;
    elseif string.lower(autovotekick) == "off" then
        AutoVoteCheck = false;
    end

    Respond("Autovoting is now " .. autovotekick)
end

local timer = 0;
local function autocastvote() --all the logic to actually cast the vote
    if AutoVoteCheck == false then
        return;
    end
        if (gamerules.IsMatchTypeCasual() and timer <= os.time()) then
            timer = os.time() + 2
            local resources = entities.GetPlayerResources()
            local me = entities.GetLocalPlayer()
            if (resources ~= nil and me ~= nil) then
                local teams = resources:GetPropDataTableInt("m_iTeam")
                local userids = resources:GetPropDataTableInt("m_iUserID")
                local accounts = resources:GetPropDataTableInt("m_iAccountID")
                local partymembers = party.GetMembers()

                for i, m in pairs(teams) do
                    local steamid = "[U:1:" .. accounts[i] .. "]"
                    local playername = client.GetPlayerNameByUserID(userids[i])

                    if (me:GetTeamNumber() == m and userids[i] ~= 0 and steamid ~= partymembers[1] and
                            steamid ~= partymembers[2] and
                            steamid ~= partymembers[3] and
                            steamid ~= partymembers[4] and
                            steamid ~= partymembers[5] and
                            steamid ~= partymembers[6] and
                            steamid ~= "[U:1:0]" and
                            not steam.IsFriend(steamid) and
                            playerlist.GetPriority(userids[i]) > -1) then
                        --Respond("Calling Vote on player " .. playername .. " " .. steamid) --This gets spammed a lot
                        client.Command('callvote kick "' .. userids[i] .. ' cheating"', true)
                        goto CalledVote
                    end
                end
            end
        end
        ::CalledVote::
end

local function responsecheck_message(msg) --If the vote failed respond with the reason
    if AutoVoteCheck == true then
        if (msg:GetID() == CallVoteFailed) then
            local reason = msg:ReadByte()
            local cooldown = msg:ReadInt(16)

            if (cooldown > 0) then
                if cooldown == 65535 then
                    Respond("Something odd is going on, waiting even longer.")
                    cooldown = 35
                    timer = os.time() + cooldown
                    return;
                end

                Respond("Vote Cooldown " .. cooldown .. " Seconds") --65535
                timer = os.time() + cooldown
            end
        end
    end
end
--End of the Autovote casting functions

local function SwitchClass(args)
    local class = args[1];

    if class == nil then
        Respond("Usage: " .. triggerSymbol .. "class <" .. table.concat(availableClasses, ", ") .. ">");
        return;
    end

    class = string.lower(args[1]);

    if not Contains(availableClasses, class) then
        Respond("Unknown class [" .. class .. "]");
        return;
    end

    if class == "heavy" then
        -- Wtf Valve
        -- ^^ true true, I agree.
        class = "heavyweapons";
    end

    Respond("Switched to [" .. class .. "]");
    gui.SetValue("Class Auto-Pick", class); 
    client.Command("join_class " .. class, true);
end

local function Say(args)
    local msg = args[1];

    if msg == nil then
        Respond("Usage: " .. triggerSymbol .. "say <text>");
        return;
    end

    client.Command("say " .. string.gsub(msg, "|", " "), true);
end

local function SayTeam(args)
    local msg = args[1];

    if msg == nil then
        Respond("Usage: " .. triggerSymbol .. "say_team <text>");
        return;
    end
    
    client.Command("say_team " .. string.gsub(msg, "|", " "), true);
end

local function SayParty(args)
    local msg = args[1];

    if msg == nil then
        Respond("Usage: " .. triggerSymbol .. "say_party <text>");
        return;
    end

    client.Command("say_party " .. string.gsub(msg, "|", " "), true);
end

local function Taunt(args)
    client.Command("taunt", true);
end

local function TauntByName(args)
    local firstArg = args[1];

    if firstArg == nil then
        Respond("Usage: " .. triggerSymbol .. "tauntn <Full taunt name>.");
        Respond("For example: " .. triggerSymbol .. "tauntn Taunt: The Schadenfreude");
        return;
    end

    local fullTauntName = table.concat(args, " ");
    client.Command("taunt_by_name " .. fullTauntName, true);
end

-- Reworked Mic Spam, added by Dr_Coomer - Doctor_Coomer#4425
local function Speak(args)
    Respond("Listen to me!")
    PlusVoiceRecord = true;
    client.Command("+voicerecord", true)
end

local function Shutup(args)
    Respond("I'll shut up now...")
    PlusVoiceRecord = false;
    client.Command("-voicerecord", true)
end

local function MicSpam(event)

    if event:GetName() ~= playerJoinEventName then
        return;
    end

    if PlusVoiceRecord == true then
        client.Command("+voicerecord", true);
    end
end

-- StoreMilk additions

local function Leave(args)
	gamecoordinator.AbandonMatch();

    --Fall back. If you are in a community server then AbandonMatch() doesn't work.
    client.Command("disconnect" ,true)
end

local function Console(args)
    local cmd = args[1];

    if cmd == nil then
        Respond("Usage: " .. triggerSymbol .. "console <text>");
        return;
    end

    client.Command(cmd, true);
end

-- thyraxis's idea
local function ducktoggle(args)
    local duck = args[1]

    if duck == nil or not Contains(availableOnOffArguments, duck) then
        Respond("Usage: " .. triggerSymbol .. "duck 1/0 or on/off");
        return;
    end

    if duck == "on" then
        duck = 1;
        client.Command("+duck", true);
    elseif duck == "1" then
        duck = 1;
        client.Command("+duck", true);
    end
    
    if duck == "off" then
        duck = 0;
        client.Command("-duck", true);
    elseif duck == "0" then
        duck = 0;
        client.Command("-duck", true);
    end

    gui.SetValue("duck speed", duck);
    Respond("Ducking is now " .. duck)
end

local function spintoggle(args)
    local spin = args[1]

    if spin == nil or not Contains(availableOnOffArguments, spin) then
        Respond("Usage: " .. triggerSymbol .. "spin 1/0 or on/off");
        return;
    end

    if spin == "on" then
        spin = 1;
    elseif spin == "1" then
        spin = 1;
    end
    
    if spin == "off" then
        spin = 0;
    elseif spin == "0" then
        spin = 0;
    end

    gui.SetValue("Anti aim", spin);
    Respond("Anti-Aim is now " .. spin)
end

-- ============= End of commands' section ============= --

local function newmap_event(event) --reset what ever data we want to reset when we switch maps
    if (event:GetName() == "game_newmap") then
        timer = 0
        IsInRange = false;
        CurrentClosestX = nil
        CurrentClosestY = nil
        closestplayer = nil;
    end
end

-- This method is an inventory enumerator. Used to search for mediguns in the inventory.
local function EnumerateInventory(item)
    -- Broken for now. Will fix later.

    local itemName = item:GetName();
    local itemDefIndex = item:GetDefIndex();

    if Contains(medigunTypedefs.default, itemDefIndex) then
        -- We found a default medigun.
        --foundMediguns.default = item:GetItemId();
        local id = item:GetItemId();
    end

    if Contains(medigunTypedefs.quickfix, itemDefIndex) then
        -- We found a quickfix.
        -- foundMediguns.quickfix = item:GetItemId();
        local id = item:GetItemId();
    end

    if Contains(medigunTypedefs.kritz, itemDefIndex) then
        -- We found a kritzkrieg.
        --foundMediguns.kritz = item:GetItemId();
        local id = item:GetItemId();
    end
end

-- Registers new command.
-- 'commandName' is a command name
-- 'callback' is a function that's called when command is executed.
local function RegisterCommand(commandName, callback)
    if commands[commandName] ~= nil then
        error("Command with name " .. commandName .. " was already registered!");
        return; -- just in case, idk if error() acts as an exception
    end

    commands[commandName] = callback;
end

callbacks.Register("Draw", "test", function ()
    
end)

-- Sets up command list and registers an event hook
local function Initialize()
    -- Registering commands

    -- Suicide commands
    RegisterCommand("kill", KillCommand);
    RegisterCommand("explode", ExplodeCommand);

    -- Switching things
    RegisterCommand("slot", SwitchWeapon);
    RegisterCommand("class", SwitchClass);

    -- Saying things
    RegisterCommand("say", Say);
    RegisterCommand("say_team", SayTeam);
    RegisterCommand("say_party", SayParty);

    -- Taunting
    RegisterCommand("taunt", Taunt);
    RegisterCommand("tauntn", TauntByName);

    -- Attacking
    --RegisterCommand("attack", Attack); even more useless than Connect

    -- Registering event callback
    callbacks.Register("FireGameEvent", FireGameEvent);

	-- StoreMilk additions
	RegisterCommand("leave", Leave);
	RegisterCommand("console", Console);

    -- Broken for now! Will fix later.
    --inventory.Enumerate(EnumerateInventory);

    -- [[ Stuff added by Dr_Coomer - Doctor_Coomer#4425 ]] --

    -- Switch Follow Bot
    RegisterCommand("fbot", FollowBotSwitcher);

    -- Switch Loadout
    RegisterCommand("lout", LoadoutChanger);

    -- Toggle Owner Only Mode
    RegisterCommand("owneronly", TogglelobbyOwnerOnly);

    -- Connect to server via IP
    RegisterCommand("connect", Connect);

    -- Toggle Ignore Friends
    RegisterCommand("ignorefriends", ToggleIgnoreFriends);

    -- Switch chat spam
    RegisterCommand("cspam", cspam);

    -- Mic Spam toggle
    RegisterCommand("speak", Speak);
	RegisterCommand("shutup", Shutup);
    callbacks.Register("FireGameEvent", MicSpam);

    --Toggle noisemaker
    RegisterCommand("nmaker", noisemaker)

    --Autovoting
    RegisterCommand("autovotekick", autovotekick)
    callbacks.Register("Draw", "autocastvote", autocastvote)
    callbacks.Register("DispatchUserMessage", "responsecheck_message", responsecheck_message)

    --Zoom Distance
    RegisterCommand("zoomdistance", zoomdistance)
    callbacks.Register("CreateMove", "GetPlayerLocations", GetPlayerLocations)

    --Auto unzoom
    callbacks.Register("CreateMove", "unzoom", AutoUnZoom)

    --New Map Event
    callbacks.Register("FireGameEvent", "newmap_event", newmap_event)

        -- [[ Stuff added by thyraxis ]] --

    -- Duck Speed
    RegisterCommand("duck", ducktoggle)
    -- Spin
    RegisterCommand("spin", spintoggle)
end

Initialize();