---tech demo for GUI-API
local version="0.7.3b"
local author="kevinkk525"
---

local computer=require"computer"

g=require"GUI"
g.initialize()
local w,h=g.getResolution()
local start_time=computer.uptime()
local clickcount=0
local running=true

local function incCount()
    clickcount=clickcount+1
    click_counter.setText("Clickcounter: %i",clickcount)
end
local function moveR1() test1.move(1) end
local function moveL1() test1.move(-1) end
local function moveUp1() test1.move(nil,-1) end
local function moveDown1() test1.move(nil,1) end
local function layerUp1() test1.move(nil,nil,1) showl1.setText("Layer yellow: %i",test1.getLayer()) end
local function layerDown1() test1.move(nil,nil,-1) showl1.setText("Layer yellow: %i",test1.getLayer()) end
local function moveR2() test2.move(1) end
local function moveL2() test2.move(-1) end
local function moveUp2() test2.move(nil,-1) end
local function moveDown2() test2.move(nil,1) end
local function layerUp2() test2.move(nil,nil,1) showl2.setText("Layer blue:   %i",test2.getLayer()) end
local function layerDown2() test2.move(nil,nil,-1) showl2.setText("Layer blue:   %i",test2.getLayer()) end
local function exitGUI() running=false end
local function chgFCol() g.setStdForeColor(0xFF0000) end
local function chgStdCol() g.setStdForeColor(0xFFFFFF) end
local function textoutput(x,y,button,user,text) textoutput_shape.setText(text) end

g.show()

welcome=g.label(math.floor(w/3),2,math.floor(w/3),4,nil,nil,nil,nil,nil,"Welcome to the tech demo of my GUI-API!\nI hope you enjoy it and get a taste of its potential,\nwell it is still beta..\ncould kill penguins, burn your house etc...:D")
features=g.labelbox(2,8,w-4,9,101,nil,0x00AAFF,nil,nil,"Some general features in beta:\nObject oriented, Layer support, Reference system\n\nSo in understandable words:\nYou can move objects, resize objects, change their layer, bind a text to a rect so they move and resize together,...\n\nCurrently added shapes:\nRect, Label, Labelbox, Listing, Textbox (working, but has some glitches)\nThe Community is encouraged to contribute shapes!")
counter=g.label(w-20,1,20,1,101,nil,nil,nil,nil,"Current uptime: %i",computer.uptime()-start_time)
click_counter=g.label(w-20,2,20,0,101,nil,nil,nil,nil,"Clickcounter: %i",clickcount)
clickbox=g.labelbox(w/2-5,20,10,2,101,nil,0xFFAA00,incCount,nil,"Click me!")
clickbox.moveText(1,1)
exit=g.labelbox(w-3,h,3,1,101,nil,0x00AAAA,exitGUI,nil,"Exit")
test1=g.rect_full(70,30,20,10,nil,nil,0xFFFF00)
test2=g.rect_full(80,35,20,10,101,nil,0x00FFFF)
moveR1l=g.labelbox(6,h-6,4,0,101,nil,0x00AAFF,moveR1,nil,"Right")
moveL1l=g.labelbox(2,h-6,3,0,101,nil,0x00AAF0,moveL1,nil,"Left")
moveUp1l=g.labelbox(5,h-7,1,0,101,nil,0x00AA0F,moveUp1,nil,"Up")
moveDown1l=g.labelbox(4,h-5,3,0,101,nil,0x00AAF0,moveDown1,nil,"Down")
layerUp1l=g.labelbox(3,h-10,6,0,101,nil,0x00AAFF,layerUp1,nil,"LayerUp")
layerDown1l=g.labelbox(2,h-9,8,0,101,nil,0x00AA00,layerDown1,nil,"LayerDown")
moveR2l=g.labelbox(18,h-6,4,0,101,nil,0x00AAFF,moveR2,nil,"Right")
moveL2l=g.labelbox(14,h-6,3,0,101,nil,0x00AAF0,moveL2,nil,"Left")
moveUp2l=g.labelbox(17,h-7,1,0,101,nil,0x00AA0F,moveUp2,nil,"Up")
moveDown2l=g.labelbox(16,h-5,3,0,101,nil,0x00AAF0,moveDown2,nil,"Down")
layerUp2l=g.labelbox(15,h-2,6,0,101,nil,0x00AA00,layerUp2,nil,"LayerUp")
layerDown2l=g.labelbox(14,h-3,8,0,101,nil,0x00AAFF,layerDown2,nil,"LayerDown")
showl1=g.label(5,h-15,16,0,101,nil,nil,nil,nil,"Layer yellow: %i",test1.getLayer())
showl2=g.label(5,h-14,16,0,101,nil,nil,nil,nil,"Layer blue:   %i",test2.getLayer())
local t="change foreground color to "
local f="0xFF0000"
changeFCol=g.labelbox(3,20,16,1,101,nil,0xFFAAFF,chgFCol,nil,t..f)
changeStdCol=g.labelbox(3,23,16,1,101,nil,0xFFAAFF,chgStdCol,nil,t.."standard")
scrollbox=g.listing(w-10,30,8,4,101,nil,0x00FFAA,nil,nil,{"Scroll me!","This is a long text so you can test the scrolling feature","And to show you the listing shape"})
textinput=g.textbox(w-10,36,8,4,101,nil,0xFFAA00,textoutput,nil,"insert text")
textoutput_shape=g.labelbox(w-10,42,8,5,101,nil,0xFF00AA,nil,nil,"input will be here")

while running do
    counter.setText("Current uptime: %i",computer.uptime()-start_time)
    os.sleep(0.7)
end
g.stopGUI()
os.exit()
