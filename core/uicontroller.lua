--> code_uicontroller = section:tostring()

local _ui_updates = {};
local _ui_changed = false;


local function ui_clear()
    _ui_changed = true;

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
            name="ev:back",
            label="<><",
            H=0.8, W=0.8, Y=6.8, X=0,
        },
    };
    mem.ui_len = 2;

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

local clicker_admin;
local clicker_user;
local uie = {}; -- ui event
local msg_table = type(msg) == "table";
local msg_is_ui = msg_table and channel == mem.screen_channel;
if msg_is_ui then
    local clicker = msg.clicker;
    if clicker then
        clicker_admin = mem.admins[clicker];
        clicker_user = clicker_admin or mem.users[clicker];
    end

    if clicker_user then 
        for name,data in pairs(msg) do 
            local slug = name:sub(1,3);
            local target = name:sub(4);
            if slug == "tx:" then 
                mem.state[target] = data;
            elseif slug == "ev:" then
                uie[target] = data
            elseif slug == "gs:" then
                gosub(target);
            elseif slug == "go:" then
                go(target)
            end
        end
    end

end
