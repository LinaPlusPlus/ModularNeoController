--> apps.Admin = "gs:admin";
--> sect("admin")

function at.admin(state)
    if uie.back then
        ret();
    end

    if uie.drawer then
        state.selected = uie.drawer
    end

    if fresh then
        local babel = {};
        for k,vt in pairs(mem.users) do
            table.insert(babel,("%s: %s %s"):format(k,vt.interact and "" or "guest",vt.admin and "admin" or ""));
        end

        ui_clear()
        ui {
            label="untitled",
            command="addtextlist",
            selected_id=state.selected or 1,
            name="tl:drawer",
            listelements=babel,
            transparent=false,
            X=0, H=6.6, W=2.6, Y=0,
        }
    end
end