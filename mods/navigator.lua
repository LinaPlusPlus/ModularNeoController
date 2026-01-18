--> apps.Navigator = "gs:navigator";
--> sect("navigator")

function at.navigator()
    if fresh then
        ui_clear()
        ui_button("rt:","test",0,0,5,5)
    end
    if uie.stop then
        ret()
    end

end