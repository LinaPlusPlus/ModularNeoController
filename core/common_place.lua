--> code_common = section:tostring()

if channel and channel == mem.jd_channel and msg.position then
    mem.jd_position = msg.position;
    mem.splash = "jumpdrive OK";
end

--> sect("common_code")
function at.lost()
    print("reached invalid place: "..tostring(mem.at));
    mem.splash = "lost at: "..tostring(mem.at);
end

function at.setup()
    mem = {
        log = {},
        screen_channel = "touch",
        jd_channel = "jumpdrive", -- help: enter fleet controller or jumpdrive digiline channel

        active_page = 1, --old?

        jd_radius = 1,
        jd_step = 11,

        users = {},

        uistk = {}, -- a stack of pages, can be clobbered 
        state = {}, -- stores UI states

        jd_position = nil, -- recorded position of the JD
    };

    for k,v in pairs(iat) do
        v();
    end

    dls(mem.jd_channel, {command = "get"});
    mem.splash = "locating your jumpdrive...";

    go "_setup";
end
--END

function at._setup()
    if event.channel == mem.jd_channel then
        mem.splash = "jumpdrive OK.";
        if msg.position then
            local p = msg.position;
            mem.target = {x=p.x,y=p.y,z=p.z} --TODO, move this from {x=,y=,z=} to {X,Y,Z} format
        else
            mem.target = {x=-500,y=-500,z=100} -- senable default
        end
        go "page_setup";
    end
end

function at.page_setup(state)
    if event.type == "program" then
        go "setup"
        return
    end

    if msg_is_ui and msg.done then
        if state.locked then return end
        mem.users[msg.clicker] = "admin";
        state.text = nil; -- cleanup variable after use
        go "home1";
        return
    end

    if msg_is_ui and msg.legal then
        state.text = LEGAL;
        state.label = "Legal";
        fresh = true;
    end

    if msg_is_ui and msg.notmyship then
        fresh = true;
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

    if fresh then

    ui_clear(false);

    ui{
        command="addtextarea",
        name="maintext",
        label=state.label or "Welcome!",
        default=state.text or SETUP_MOTD,
        X=0.8, Y=0.8, W=9, H=4.6,
    }

    ui_button("done",state.locked and "{ Locked }" or "Lets Get Started!",3.6, 5.5, 2.8, 0.8)
    ui_button("notmyship","Not my ship",1.2,5.5,1.6,0.8)
    ui_button("legal","Lisense",7.2, 5.5,1.6, 0.8)
    end


    --go "noop"
end

function parse4(line)
    local j, h = 1

    h = line:find(",", j, true)
    local v1 = line:sub(j, (h or 0) - 1)
    if not h then return v1 end

    j = h + 1
    h = line:find(",", j, true)
    local v2 = line:sub(j, (h or 0) - 1)
    if not h then return v1, v2 end

    j = h + 1
    h = line:find(",", j, true)
    local v3 = line:sub(j, (h or 0) - 1)
    if not h then return v1, v2, v3 end

    local v4 = line:sub(h + 1)
    return v1, v2, v3, v4
end
