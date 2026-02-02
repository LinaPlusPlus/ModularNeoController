--> code_uicontroller = section:tostring()

local _ui_updates = {};
local _ui_changed = false;


local _swidth, _sheight = 10, 8 --screen width and height
local _BH = 0.8 -- _bh = button heightx``
local _R12 = _sheight / 12
local _C12 = _swidth / 12 -- 12 column grid width

local function ui_clear()
    _ui_changed = true;

    mem.splash_old = mem.splash;

    _ui_updates = {
        { command = "clear" },
        {command = "set", width = _swidth, height = _sheight, no_prepend = true, real_coordinates = true},
        {
            label=mem.splash or "ERROR!",
            name="splash",
            command="addbutton",
            X=0.6, Y=7, W=5, H=1, 
        },{
            image="digistuff_adwaita_edit-undo.png",
            command="addimage_button",
            name="ev:back",
            label="",
            X=0, Y=7, W=1, H=1,
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

local function ui_button(name,label,X,Y,W,H)
    ui{command="addbutton",name=name,label=label,X=X,Y=Y,H=H,W=W}
end

local function ui_image(name,label,image,X,Y,W,H)
    ui{command="addimage_button",image=image,name=name,label=label,X=X,Y=Y,H=H,W=W}
end

-----

local clicker_user;
local uie = {}; -- ui event
local msg_table = type(msg) == "table";
local msg_is_ui = msg_table and channel == mem.screen_channel;
if msg_is_ui then
    local clicker = msg.clicker;
    if clicker then
        clicker_user = mem.users[clicker];
    end

    if clicker_user == nil then
        mem.users[clicker] = false;
        clicker_user = false;
        mem.splash = ("welcome aboard, %s"):format(clicker)
    end

    if clicker_user or (mem.allow_guests and clicker_user == false) then
        for name,data in pairs(msg) do 
            if name == "splash" then name = "ev:back" end

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
            elseif slug == "tl:" then 
                --text lists that use 'CHG:<number>'
                uie[target] = tonumber(data:sub(5))
            end
        end
    else
        mem.splash = ("permission denied, %s"):format(clicker)
    end

end