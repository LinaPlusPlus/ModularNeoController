--> code_common = section:tostring()

if channel == mem.jd_channel and msg.position then
    mem.jd_position = msg.position;
    mem.splash = "jumpdrive OK";
end

--> 
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

        admins = {},
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
        mem.splash = ("hello %s :)"):format(msg.clicker);

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

