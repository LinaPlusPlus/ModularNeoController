--> load(section:tostring())()
function code_home()

    local i = 0;
    local j = 1;

    writef("\nfunction at.home1() if fresh then\n")
    writef("mem.splash = \"Hello!\"\n")
    writef("ui_clear()\n");
    for name,action in pairs(apps) do
        local units = 3
        local size = 3.5
        local x = i % units;
        local y = math.floor(i / units);

        
        writef("ui_button(%q,%q,%s,%s,%s,1)\n",action,name,x*size,y,size);

        i = i + 1;

        if i >= 10 then
            i = 0;
            j = j + 1;
            writef("\nend end\n")
            writef("\nfunction at.home%s()",j)
            writef("ui_clear()\n");
        end

    end
    writef("\nend end\n")

end