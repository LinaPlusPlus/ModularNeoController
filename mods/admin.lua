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
        for k,v in pairs(mem.users) do
            table.insert(babel,("%s: %s"):format(k,v));
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