--> apps.Navigator = "gs:navigator";
--> sect("navigator")

function at.navigator_relocate()
    if fresh then
        mem.splash = "Reading position..."
        dls(mem.jd_channel, {command = "get"});
    elseif channel == mem.jd_channel and msg.position then
        local p = msg.position;
        mem.splash = "Returned to Current Position"
        mem.target = {x=p.x,y=p.y,z=p.z}
        ret();
    end
end

function at.navigator_jump()
    ui_clear()
    local target = mem.target;
    if fresh then
        mem.splash = "Uploading position..."
        dls(mem.jd_channel, {command = "set", x=target.x,y=target.y,z=target.z,formupdate = true});
        interrupt(0.5);
    end
    if event.type == "interrupt" then
        mem.splash = "Testing..."
        dls(mem.jd_channel, {command = "simulate" });
    end
    if channel == mem.jd_channel then 
        if msg.success then 
            mem.splash = "Ready to jump";
            go "navigator_ok"
        else
            mem.splash = msg.msg;
            go "navigator_fail"
        end
    end
end

function at.navigator_dojump()
    if fresh then
        dls(mem.jd_channel, {command = "jump"});
        ui_clear()
        mem.splash = "Jumping...";
    end
    if mem.jd_channel == channel then 
        mem.splash = "Jump OK!";
        ret()
    end
end

function at.navigator_ok()
    if fresh then
        local q = 0.6
        ui_clear()
        ui {
            label="untitled",
            name="cords",
            command="addfield",
            default=mem.splash,
            X=1.5, Y=0.7, H=0.8, W=6.4,
        }
        ui_button ("ev:back", "Back", 1, 1+q, 4, 1)
        ui_button ("ev:jump", "Jump", 5, 1+q, 4, 1)
    end
    
    if uie.jump then
        -- TODO  this is too simple :P
        -- jumpdrive needs re-gotten
        -- confirmation of successful jump
        go "navigator_dojump";
    elseif uie.back then
        ret();
    end
end

function at.navigator_fail()
    local q = 0.6
    ui_clear()
    ui {
        label="untitled",
        name="cords",
        command="addfield",
        default=mem.splash,
        X=1.5, Y=0.7, H=0.8, W=6.4,
    }
    ui_button ("ev:back", "Back", 1, 1+q, 4, 1)
    ui_button ("ev:jump", "----", 5, 1+q, 4, 1)
    if uie.back then
        ret();
    end
end

function at.navigator()

    if fresh then
        -- noop
    else
        print ("cords, old="..mem.old.." >> "..tostring(uie.cords))
        if uie.cords and uie.cords ~= mem.old then
            mem.old = uie.cords;
            
            local a,x,y,z = parse4(uie.cords)
            local t = mem.target;
            mem.target_name = a;
            t.x = tonumber(x) or t.x;
            t.y = tonumber(y) or t.y;
            t.z = tonumber(z) or t.z;
            print ("cords: "..tostring(tonumber(z)))
            fresh = true
        end

        if uie.back then
            ret()
        elseif uie.addx then
            fresh = true
            mem.target.x = mem.target.x + mem.navg_inc
        elseif uie.subx then
            fresh = true
            mem.target.x = mem.target.x - mem.navg_inc

        elseif uie.addy then
            fresh = true
            mem.target.y = mem.target.y + mem.navg_inc
        elseif uie.suby then
            fresh = true
            mem.target.y = mem.target.y - mem.navg_inc

        elseif uie.addz then
            fresh = true
            mem.target.z = mem.target.z + mem.navg_inc
        elseif uie.subz then
            fresh = true
            mem.target.z = mem.target.z - mem.navg_inc
        elseif uie.reset then
            gosub "navigator_relocate";
        elseif uie.jump then
            gosub "navigator_jump";
        end
    end


    if fresh then
        mem.navg_inc = mem.navg_inc or 5
        local targ = mem.target;
        local cordstr = ("%s,%s,%s,%s"):format(mem.target_name or "label",targ.x,targ.y,targ.z);
        uie.old = cordstr
        ui_clear()
        ui {
            label="untitled",
            name="ev:cords",
            command="addfield",
            default=cordstr,
            X=1.5, Y=0.7, H=0.8, W=6.4,
        }
        local p = 0.1;
        local q = 0.6;
        ui_button ("ev:subx", "X-", 1-p, 1+q, 2, 1)
        ui_button ("ev:addx", "X+", 3-p, 1+q, 2, 1)
        ui_button ("ev:suby", "Y-", 1-p, 2+q, 2, 1)
        ui_button ("ev:addy", "Y+", 3-p, 2+q, 2, 1)
        ui_button ("ev:subz", "Z-", 1-p, 3+q, 2, 1)
        ui_button ("ev:addz", "Z+", 3-p, 3+q, 2, 1)

        ui_button ("ev:jump", "Test/Jump", 5+p, 1+q, 2, 1)
        ui_button ("ev:reset", "Reset", 7+p, 1+q, 2, 1) -- reset position to jd current
        ui_button ("ev:button1b", "", 5+p, 2+q, 2, 1)
        ui_button ("ev:button2b", "", 7+p, 2+q, 2, 1)
        ui_button ("ev:button1c", "", 5+p, 3+q, 2, 1)
        ui_button ("ev:button2c", "", 7+p, 3+q, 2, 1)
    end 
end