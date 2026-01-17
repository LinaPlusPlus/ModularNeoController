--> load(section:tostring())()

-- begin 
function writef(fmt,...) table.insert(code,fmt:format(...)) end

-- sect uses a preparser
-- for now it just passes as is
function sect(name)
    local _ = code; --await
    local sect = section:tostring()
    -- TODO add preprocesor here
    table.insert(code,sect);
end

io.write(code_legal);
io.write(code_globals);
io.write(code_uicontroller);
io.write(code_lur);
io.write(code_common);

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