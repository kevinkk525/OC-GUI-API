---
local version="0.1b"
local author="kevinkk525"
---

local component=require"component"

if not component.isAvailable("internet") then
    print("You need a internet card, quit with any key")
    local inp=io.read()
    os.exit()
end
if not component.internet.isHttpEnabled() then
    print("Http is not enabled, please ask your admin! quit with any key")
    local inp=io.read()
    os.exit()
end

print("downloading GUI-API")
os.execute("wget -f https://github.com/kevinkk525/OC-GUI-API/raw/master/shapes_default.lua /lib/shapes_default.lua")
os.execute("wget -f https://github.com/kevinkk525/OC-GUI-API/raw/master/GUI.lua /lib/GUI.lua")
os.execute("wget -f https://github.com/kevinkk525/OC-GUI-API/raw/master/term_mod.lua /lib/term_mod.lua")
os.execute("wget -f https://github.com/kevinkk525/OC-GUI-API/raw/master/tech_demo.lua /tech_demo.lua")

print("download finished")
