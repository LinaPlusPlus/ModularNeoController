--> apps.Navigator = "gs:navigator";
--> sect("navigator")


-- bread,8000,9530,5333:0
-- greek_home,10,12,27:18710
-- mclv_obby_ship,15,2,5:2126


function at.navigator_relocate()
    if fresh then
        mem.splash = "Reading position..."
        dls(mem.jd_channel, {command = "get"});
    elseif channel == mem.jd_channel and msg.position then
        local p = msg.position;
        mem.abs_target = {x=p.x,y=p.y,z=p.z}
        mem.mode = "torel"
        go "navigator_relocate_then"
        gosub "navigator_reltool"
    end
end

function at.navigator_relocate_then()
    mem.splash = "Returned to Current Position"
    ret();
end


function at.navigator_jump()
    -- funny stack miniputlation
    -- replaces the return location
    go "navigator_upload"
    mem.mode = "toabs"
    gosub "navigator_reltool"
end

function at.navigator_reltool()
        mem.splash = "Downloading Relitive..."
    if fresh then 
        if mem.target_rel and mem.target_rel > 0 then
            digiline_send(mem.nic_channel,{
                parse_json = true,
                url = ("https://pandorabox.io/api/areasid/%s?format=json"):format(mem.target_rel)
            })
        else 
            -- not translating position data if abs mode
            if mem.mode == "torel" then --HACK this should be shallow cloned, will cause bugs
                mem.target = mem.abs_target;
            else 
                mem.abs_target = mem.target;
            end
            return ret();
        end
    end
    if event.channel == mem.nic_channel then
        mem.dump = event;
        if msg.code ~= 200 or (not msg.data[1]) or (not msg.data[1].pos1) then --HACKy data parsing
            mem.splash = ("HTTP error"):format() --TODO more error details
            -- causes caller to jump to fail
            ret();
            go "navigator_fail";
            return
        end

        local pos1 = msg.data[1].pos1;
        if mem.mode == "torel" then
            mem.target = { 
                x = mem.abs_target.x - pos1.x,
                y = mem.abs_target.y - pos1.y,
                z = mem.abs_target.z - pos1.z,
            }
        else
            mem.abs_target = { 
                x = pos1.x + mem.target.x,
                y = pos1.y + mem.target.y,
                z = pos1.z + mem.target.z,
            }
        end

        return ret()
    end
end

function at.navigator_dorel()
    if uie.dcords then
        mem.dorel_cords = uie.dcords;
        fresh = true;
    end

    if fresh then
        local q = 0.6
        ui_clear()
        ui {
            label="area ID:",
            name="ev:dcords",
            command="addfield",
            default=tostring(mem.dorel_cords or ""),
            X=1.5, Y=0.7, H=0.8, W=6.4,
        }
        ui_button ("ev:back", "Back", 1, 1+q, 4, 1)
        ui_button ("ev:ok", "Relitivize", 5, 1+q, 4, 1)
    end

    if uie.ok then
        mem.mode = "torel"
        mem.target_rel = tonumber(mem.dorel_cords) or 0
        mem.abs_target = {
            x = mem.target.x,
            y = mem.target.y,
            z = mem.target.z,
        }
        go "navigator_dorel_then";
        gosub "navigator_reltool";
    elseif uie.back then
        ret();
    end
end

function at.navigator_dorel_then()
    mem.splash = "Relitivized"
    ret()
end

function at.navigator_doderel()
    mem.dorel_cords = mem.target_rel
    mem.target_rel = 0;
    mem.target = {
        x = mem.abs_target.x,
        y = mem.abs_target.y,
        z = mem.abs_target.z,
    }
    mem.splash = "De-Relitivized"
    ret()
end

function at.navigator_upload()
    ui_clear()
    local target = mem.abs_target;
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
        if uie.cords and uie.cords ~= mem.old then
            mem.old = uie.cords;
            
            local a,x,y,z,rel = parse5(uie.cords)
            local t = mem.target;
            mem.target_rel = tonumber(rel) or mem.target_rel or 0;
            mem.target_name = a;
            t.x = tonumber(x) or t.x;
            t.y = tonumber(y) or t.y;
            t.z = tonumber(z) or t.z;
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
        elseif uie.relv then
            if mem.target_rel > 0 then
                gosub "navigator_doderel";
                mem.mode = "toabs"
                gosub "navigator_reltool"
            else
                gosub "navigator_dorel";
            end
        end
    end


    if fresh then
        mem.navg_inc = mem.navg_inc or 5
        local targ = mem.target;
        local cordstr = ("%s,%s,%s,%s:%s"):format(mem.target_name or "label",targ.x,targ.y,targ.z,mem.target_rel or 0);
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
        ui_button ("ev:relv", "(De)Relitivize", 5+p, 2+q, 2, 1)
        ui_button ("ev:button2b", "", 7+p, 2+q, 2, 1)
        ui_button ("ev:button1c", "", 5+p, 3+q, 2, 1)
        ui_button ("ev:button2c", "", 7+p, 3+q, 2, 1)
    end 
end