-- Bot helper by __null

-- Settings:
-- Trigger symbol. All commands should start with this symbol.
local triggerSymbol = "!";

-- Process messages only from lobby owner.
local lobbyOwnerOnly = true;

-- Check if we want to me mic spamming or not.
local PlusVoiceRecord;

-- Constants
local k_eTFPartyChatType_MemberChat = 1;
local steamid64Ident = 76561197960265728;
local partyChatEventName = "party_chat";
local availableClasses = { "scout", "soldier", "pyro", "demoman", "heavy", "engineer", "medic", "sniper", "spy" };
local availableSpam = { "none", "branded", "custom" };
local availableAttackActions = { "start", "stop" };
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
    local fullCommand = string.sub(partyMessageText, 2, #partyMessageText);
    local commandArgs = SplitString(fullCommand);
 
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
    local fbot = string.lower(args[1]);

    if fbot == nil then
        Respond("Usage: " .. triggerSymbol .. "fbot stop/friends/all");
        return;
    end

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

    --5/27/2023 -- used the string class in lua to remove a third of the checks

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

    if OwnerOnly == nil then
        Respond("Usage: " .. triggerSymbol .. "OwnerOnly 1/0 or true/false");
    end

    if OwnerOnly == "1" then
        lobbyOwnerOnly = true;
    elseif OwnerOnly == "true" then
        lobbyOwnerOnly = true;
    end

    if OwnerOnly == "0" then
        lobbyOwnerOnly = false;

    elseif OwnerOnly == "false" then
        lobbyOwnerOnly = false;
    end

    Respond("Lobby Owner Only is now: " .. OwnerOnly)
end

-- Toggle ignore friends added by Dr_Coomer - Doctor_Coomer#4425
local function ToggleIgnoreFriends(args)
    local IgnoreFriends = args[1]

    if IgnoreFriends == nil then
        Respond("Usage: " .. triggerSymbol .. "IgnoreFriends 1/0 or true/false")
        return;
    end

    if IgnoreFriends == "1" then
        IgnoreFriends = 1;
    elseif string.lower(IgnoreFriends) == "true" then
        IgnoreFriends = 1;
    end
    
    if IgnoreFriends == "0" then
        IgnoreFriends = 0;
    elseif string.lower(IgnoreFriends) == "false" then
        IgnoreFriends = 0;
    end

    Respond("Ignore Steam Friends is now: " .. IgnoreFriends)
    gui.SetValue("Ignore Steam Friends", IgnoreFriends)
end

--[[
callbacks.Register("Draw", "SwitchCheckForlobbyOwnerOnlyBool", function()
    print(lobbyOwnerOnly); --making sure this even works lmao
end)
--]]

-- connect to servers via IP re implemented by Dr_Coomer - Doctor_Coomer#4425
--Context: There was a registered callback for a command called "connect" but there was no function for it. So, via the name of the registered callback, I added it how I thought he would have.
local function Connect(args)
    local Connect = args[1]

    Respond("Joining server " .. Connect .. "...")

    client.Command("connect " .. Connect, true);
end

-- Chatspam switcher added by Dr_Coomer - Doctor_Coomer#4425
local function cspam(args)
    local cspam = string.lower(args[1])

    if cspam == nil then
        Respond("Usage: " .. triggerSymbol .. "cspam none/branded/custom")
        return;
    end

    if not Contains(availableSpam, cspam) then
        Respond("Unknown chatspam: [" .. cspam .. "]")
        return;
    end

    Respond("Chat spamming " .. cspam)
    gui.SetValue("Chat spammer", cspam)
end

local function SwitchClass(args)
    local class = string.lower(args[1]);

    if class == nil then
        Respond("Usage: " .. triggerSymbol .. "class <" .. table.concat(availableClasses, ", ") .. ">");
        return;
    end

    if not Contains(availableClasses, class) then
        Respond("Unknown class [" .. class .. "]");
        return;
    end

    if class == "heavy" then
        -- Wtf Valve
        class = "heavyweapons";
    end

    Respond("Switched to [" .. class .. "]");
    client.Command("join_class " .. class, true);
end

local function Say(args)
    local msg = args[1];

    if msg == nil then
        Respond("Usage: " .. triggerSymbol .. "say <text>");
        return;
    end

    client.Command("say " .. msg, true);
end

local function SayTeam(args)
    local msg = args[1];

    if msg == nil then
        Respond("Usage: " .. triggerSymbol .. "say_team <text>");
        return;
    end
    
    client.Command("say_team " .. msg, true);
end

local function SayParty(args)
    local msg = args[1];

    if msg == nil then
        Respond("Usage: " .. triggerSymbol .. "say_party <text>");
        return;
    end

    client.Command("say_party " .. msg, true);
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

local function Attack(args)
    local action = args[1];
    local buttonStr = args[2];

    if action == nil or buttonStr == nil then
        Respond("Usage: " .. triggerSymbol .. "attack <" .. table.concat(availableAttackActions, ", ") .. "> <button (1-3)>");
        return;
    end

    if not Contains(availableAttackActions, action) then
        Respond("Unknown attack option. Available options are: <" .. table.concat(availableAttackActions, ", ") .. ">");
        return;
    end

    local button = tonumber(buttonStr);

    if button == nil then
        Respond("Button is not valid. Available options are: 1-3");
        return;
    end

    if button < 0 or button > 3 then
        Respond("Button is not valid. Available options are: 1-3");
        return;
    end

    local modifier = "+";

    if action == "stop" then
        modifier = "-";
    end

    if button == 1 then
        client.Command(modifier .. "attack", true);
    else
        client.Command(modifier .. "attack" .. button, true);
    end
end

-- Reworked Mic Spam, added by Dr_Coomer - Doctor_Coomer#4425
local function Speak(args)
    Respond("Listen to me!")
    PlusVoiceRecord = true;
end

local function Shutup(args)
    Respond("I'll shut up now...")
    PlusVoiceRecord = false;
end

callbacks.Register("Draw", "MicSpam", function ()

    --we run this in a loop so it works even when you switch servers.
    --dont have to re type the command
    if PlusVoiceRecord == true then
        client.Command("+voicerecord", true);  -- although it fixes the main issue, it will spam the chat of the bot if the bot doesn't have premium. 
    elseif PlusVoiceRecord == false then -- A better way but a way that I cant be bothered with right now is to make a check for if the owner has enabled the mic spam, then when the when the bot joins the server
        client.Command("-voicerecord", true); -- it will only run "+voicerecord" once instead of every frame.
    end
end)

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

-- ============= End of commands' section ============= --

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
    RegisterCommand("attack", Attack);

    -- Registering event callback
    callbacks.Register("FireGameEvent", FireGameEvent);
	
	-- StoreMilk additions
	RegisterCommand("leave", Leave);
	RegisterCommand("speak", Speak);
	RegisterCommand("shutup", Shutup);
	RegisterCommand("console", Console);

    -- Broken for now! Will fix later.
    --inventory.Enumerate(EnumerateInventory);

    -- [[ Stuff added by Dr_Coomer - Doctor_Coomer#4425 ]] --
    -- Toggle Follow Bot
    RegisterCommand("fbot", FollowBotSwitcher);

    -- Switch Loadout
    RegisterCommand("lout", LoadoutChanger);

    -- Toggle Owner Only Mode
    RegisterCommand("OwnerOnly", TogglelobbyOwnerOnly);

    -- Connect to server via IP
    RegisterCommand("connect", Connect);

    -- Toggle Ignore Friends
    RegisterCommand("IgnoreFriends", ToggleIgnoreFriends);

    RegisterCommand("cspam", cspam);
end

Initialize();