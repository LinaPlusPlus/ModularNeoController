--> code_lur_header = section:tostring()
local hup = false;
local iat = {}; --contains setup functions (old?)
local at = {};
local fresh;

local function go(place) 
    mem.at,hup = place,false 
end

local function gosub(place)
    insert(mem.uistk,mem.at);
    mem.at,hup = place,false
end

local function ret(place)
    mem.at = remove(mem.uistk)
    hup = false
end

--> code_lur = section:tostring()

local function ready()
 while not hup do
  hup = true
  local aat = mem.at;
  fresh = mem.oldat ~= aat
  if fresh then
     mem.oldat = aat;
  end
  (at[aat or "setup"] or at.lost)(mem.state)
  
 end

 if mem.splash ~= mem.splash_old then
    mem.splash_old = mem.splash;

    ui{
        command="replace",
        name="splash",
        element = "button",
        label = mem.splash,
        index = 1,
        X=0.6, H=0.8, W=2.6, Y=6.8,
    }
 end

 if _ui_changed then
    digiline_send(mem.screen_channel,_ui_updates);
 end

end

