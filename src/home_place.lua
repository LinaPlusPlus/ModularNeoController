--> load(section:tostring())()
function code_home()

    local i = 0;
    local j = 1;

    writef("\nfunction at.home1()\n")
    for name,action in pairs(apps) do
        local x = i % 3;
        local y = math.floor(i / 3);

        writef("ui_button(%q,%q,%s,%s,5,5)\n",action,name,x,y);

        i = i + 1;

        if i >= 9 then
            i = 0;
            j = j + 1;
            writef("\nend\n")
            writef("\nfunction at.home%s()",j)
        end

    end
    writef("\nend\n")

end