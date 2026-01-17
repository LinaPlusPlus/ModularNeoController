local SETUP_MOTD = [[
    the ISV group thanks you for using
    LURU OS!

    github link here...
]]

local LEGAL = [[
    //TODO
]]

--
-- luru_ShipOS
-- rewritten based on: https://github.com/MCLV-pandorabox/mt_ShipOS

--BEGIN Lur UI Core
local msg = event.msg
local channel = event.channel
local dls = digiline_send
local insert = table.insert;
local remove = table.remove;

local _ui_updates = {};
local _ui_changed = false;

local _swidth, _sheight = 10, 8 --screen width and height
local _C12 = _swidth / 12 -- 12 column grid width
local _R12 = _sheight / 12

local function ui_clear()

    local seekbar_pages = {};
    _ui_changed = true;

    if mem.show_headers ~= false then
        for i,v in pairs(mem.seekbar_pages) do
            seekbar_pages[i] = v[2];
        end
    end

    mem.splash_old = mem.splash;

    _ui_updates = {
        { command = "clear" },
        {
            label=mem.splash or "ERROR!",
            name="splash",
            command="addbutton",
            X=0.6, H=0.8, W=2.6, Y=6.8,
        },{
            image="wool_red.png",
            command="addimage_button",
            name="1ev:back",
            label="<><",
            H=0.8, W=0.8, Y=6.8, X=0,
        },
    };
    if mem.show_headers ~= false then
        table.insert(_ui_updates,{
        command = "add",
        element = "tabheader",
        X = 0,
        Y = 0,
        name = "tabheader",
        captions = seekbar_pages,
        current_tab = mem.active_page,
        transparent = false,
        draw_border = true
        })
    end
    mem.ui_len = 3;

    return l;
end

local function ui(cmd)
    _ui_changed = true;

    local index;
    if cmd.command ~= "replace" then
        index = mem.ui_len + 1;
        mem.ui_len = index;
    end

    insert(_ui_updates,cmd);

    return index;
end

local function ui_button(name,label,X,H,W,Y)
    ui{command="addbutton",name=name,label=label,X=X,H=H,W=W, Y=Y,}
end
-----

local function envoke_action(act,context)
    
    return false;
end


local clicker_admin;
local clicker_user;
local uievent = {};
local msg_table = type(msg) == "table";
local msg_is_ui = msg_table and channel == mem.screen_channel;
if msg_is_ui then
    local clicker = msg.clicker;
    if clicker then
        clicker_admin = mem.admins[clicker];
        clicker_user = clicker_admin or mem.users[clicker];
    end

    if clicker_user and msg.tabheader and mem.show_headers then
        mem.active_page = tonumber(msg.tabheader) or 1;
        local a = mem.seekbar_pages[mem.active_page];
        mem.uistk = {};
        mem.at = a[1];
    end

    if clicker_user then uievent = msg end
end


-----

local hup = false;
local iat = {}; --contains setup functions (old?)
local at = {};
local function go(place) mem.at,hup = place,false end

local function ready()
 while not hup do
  hup = true
  local aat = mem.at;
  (at[aat or "setup"] or at.lost)(mem.state)
 end

 if mem.splash ~= mem.splash_old then
    mem.splash_old = mem.splash;

    ui{
        command="replace",
        name="splash",
        element = "button",
        label = mem.splash,
        index = 1,
        X=0.6, H=0.8, W=2.6, Y=6.8,
    }
 end

 if _ui_changed then
    digiline_send(mem.screen_channel,_ui_updates);
 end

end

local function gosub(place)
    insert(mem.uistk,mem.at);
    mem.at,hup = place,false
end

local function ret(place)
    mem.at = remove(mem.uistk)
    hup = false
end

--END Lur UI Core

--BEGIN Core
if channel == mem.jd_channel and msg.position then
    mem.jd_position = msg.position;
    mem.splash = "jumpdrive OK";
end

--DEBUG
function at.lost()
    print("reached invalid place: "..tostring(mem.at));
    mem.splash = "lost at: "..tostring(mem.at);
end

function at.noop() end

function at.setup()
    mem = {
        log = {},
        seekbar_pages = {
            {"go:navigation","Navigation"},
            {"bookmarks","Bookmarks"},
            {"quarry","Quarry"},
            {"digi_console","DigiConsole"},
            {"notepad","Notepad"},
            {"settings_old", "Settings"}
        },

        screen_channel = "touch",
        jd_channel = "jumpdrive", -- help: enter fleet controller or jumpdrive digiline channel

        active_page = 1, --old?

        jd_radius = 1,
        jd_step = 11,

        admins = {},
        users = {},

        uistk = {}, -- a stack of pages, can be clobbered 

        show_headers = false, -- show the headers
        state = {}, -- stores UI states

        --old
        jd_msg = "",
        jd_command = "", -- next command we'd like to send to the jd by interrupt -- sometimes we need to wait before we can send (digilines)
        jd_target = "",
        jd_position = nil,
    };

    for k,v in pairs(iat) do
        v();
    end

    dls(mem.jd_channel, {command = "get"});
    mem.splash = "locating your jumpdrive...";

    go "page_setup";
end
--END

function at.page_setup(state)

    if mem.unwinding then
        mem.splash = "Nothing to do.";
        mem.unwinding = false;
    end

    if state.locked and event.type == "program" then
        go "setup"
        return
    end

    if msg and msg.done then
        if state.locked then return end;
        mem.splash = ("hello Master %s :)"):format(msg.clicker);

        mem.admins[msg.clicker] = true;

        go "page_home";
        return
    end

    if msg and msg.legal then
        state.text = LEGAL;
        state.label = "Legal";
        state.drawn = false;
    end

    if msg and msg.notmyship then
        state.drawn = false;
        mem.interrupt = false;
        state.locked = true;
        mem.splash = "ship is disabled!";
        state.label = "please reset your ship!";
        state.text = ([[
            Thank you %s :)

            This ship is now disabled until owner returns!
            please reprogram your ship to continue setup.
        ]]):format(msg.clicker);
    end

    if not state.drawn then
    state.drawn = true

    ui_clear(false);

    ui{
        command="addtextarea",
        name="maintext",
        label=state.label or "Welcome!",
        default=state.text or SETUP_MOTD,
        X=0.8, Y=0.8, W=9, H=4.6,
    }

    ui_button("done",state.locked and "{ Locked }" or "Lets Get Started!",3.6, 9.8, 2.8, 0.8)
    ui_button("notmyship","Not my ship",1.2,9.8,1.6,0.8)
    ui_button("legal","Lisense",7.2, 9.8,1.6, 0.8)
    end


    --go "noop"
end

function at.page_home()
    --
    ui_clear();
    ui_button("navigator","Navigate",1.2,9.8,1.6,0.8)

    if uievent.navigator then 
        gosub "navigator"
    end
end

function iat.common()
   --
end

function at.navigator()
    mem.splash = "Morty Navigator 1.0";

end

function at.navigator_()
    local refresh = false;
    if event.ui == "" then
    end
end

--TEMP HACK
--if event.type == "program" then print("reset") mem = {} end

return ready();