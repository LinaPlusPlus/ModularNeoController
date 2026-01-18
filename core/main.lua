--> load(section:tostring())()
function writef(fmt,...) table.insert(code,fmt:format(...)) end
local function writeh(fmt,...) io.write(fmt:format(...)) end

-- sect uses a preparser
-- for now it just passes as is
function sect(name)
    local sect = section:tostring()
    -- TODO add preprocesor here
    table.insert(code,sect);
end

writeh("%s\n",code_legal);
writeh("%s\n",code_globals);
writeh("%s\n",code_lur_header);
writeh("%s\n",code_uicontroller);
writeh("%s\n",code_lur);
writeh("%s\n",code_common);

if flag.debug then
    writeh("if event.type == \'program\' then mem = {} end\n")
    writeh("print(mem.at)\n")
end

code = {};
apps = {};
thread.onsettled();

code_home()
io.write(table.concat(code,"\n"))

io.write"\n\nreturn ready();\n"

--> code_globals = section:tostring()
local msg = event.msg
local channel = event.channel
local dls = digiline_send
local insert = table.insert;
local remove = table.remove;