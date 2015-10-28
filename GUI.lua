--- config section
local version="0.7.2b"
local author="kevinkk525"
local back_color_std=0x000000
local fore_color_std=0xFFFFFF
local hook_as_permanent=true --only for req_handler, ignore
----

local component=require("component")
local term=require("term")
local term_read=require("term_mod") --modified term.read function preventing line shifting
local text=require("text")
local unicode=require("unicode")
local colors=require("colors")
local event=require("event")
local os=require("os")
local table=require("table")
local gpu=component.gpu
local g={} --GUI functions
local width,height=gpu.getResolution()
local f --req-handler-hook, not required, ignore this
local layerT={} --format: index/xy={index=object-ID-pointer},["layer"]={index/layer={index=object-pointer}}
local objects={} --format: index=ID,ID=object
-- object .coords-format: index={x,y}
local events={["touch"]="clickEvent",["scroll"]="scrollEvent"}


--- todo
--g.error
--internal functions printXY,center,objectCenter
-- add option for RGB color system
-- set optimal screen Resolution when receiving screen change event
--add option to "minimize" objects
--add g.print(text,x,y)
--add possibility to update specific x,rx,y,ry --> optimization for .move,... 
---



----local functions
local function getCoords(i) --probably unused
    local w,h=g.getResolution()
    if i>h*w then 
        return false,"too big"
    end
    local y,x=math.modf(i/w)
    x=i-y*w
    y=y+1
    if x==0 then
        y=y-1
        x=w
    end
    return x,y
end

local function getCoordsIndex(x,y)
    local w,h=g.getResolution()
    if x>w or y>h then
        return false,"too big"
    end
    local i=(y-1)*w+x
    return i
end

local function opt_res() --uses screen perfectly, not working atm..
    local maxw,maxh=gpu.maxResolution()
    local a_w,a_h=component.screen.getAspectRatio()
    local h=1
    local w=1
    for i=maxh,1,-1 do
        if i/a_h*a_w<=maxw then
            return maxw,i
        end
    end
end

local function getLayer(x,y,rx,ry,direction) --upgrade
    if x==nil or y==nil then
        return false --or nil?
    else
        rx=rx or 0
        ry=ry or 0
        local layer=100
        local ende
        if direction==1 then
            ende=300
        else
            ende=1
        end
        for i=layer,ende,direction do
            if layerT[i]~=nil then
                --for j=1,#layerT[i] do --add a way to check layer in x->rx,y->ry.. too lazy :D
                --if any object exists in that layer, no matter where, the layer is not empty..
                layer=i
            end
        end
        return layer
    end
end

----

function g.event(event,scr_addr,x,y,special,user) --special: touch:button, scroll:direction
    local checkLayer
    if not events[event] then
        return false,"event does not exist"
    end
    for i=300,1,-1 do
        if layerT[i]~=nil then
            for j=1,#layerT[i] do
                local k=layerT[i][j]
                if k.getCoords()~=nil then
                    for l=1,#k.getCoords() do 
                        if k.getCoords()[l][1]==x and k.getCoords()[l][2]==y then
                            if layerT[i][j][events[event]](nil,nil,nil,nil,true) then
                                k[events[event]](x,y,special,user)
                            end
                            return true
                        end
                    end
                else
                    if k.getX()<=x and k.getX()+k.getRX()>=x then
                        if k.getY()<=y and k.getY()+k.getRY()>=y then
                            if layerT[i][j][events[event]](nil,nil,nil,nil,true) then
                                k[events[event]](x,y,special,user)
                            end
                            return true
                        end
                    end
                end
            end
        end
    end           
end

function g.changeLayer(o,layer,up)
    if type(o)~="table" then
        o=objects[o]
    end
    for j=1,#layerT[o.getLayer()] do
        if layerT[o.getLayer()][j]==o then
            table.remove(layerT[o.getLayer()],j)
            if #layerT[o.getLayer()]==0 then
                layerT[o.getLayer()]=nil
            end
        end
    end
    if layerT[layer]==nil then
        layerT[layer]={}
    end
    layerT[layer][#layerT[layer]+1]=o
    o.setLayer(layer)
    o.show()
    gpu.setForeground(fore_color_std)
    gpu.setBackground(back_color_std)
    if not up then
        g.update(o,o.getLayer()+1,true)
    end
end

function g.objectFunctions() --returns the basic object functions
    return {} --at the moment no functions
end

function g.ID_Status(id) --if ID exists
    if objects[id]~=nil then
        return false
    end
    return true
end

function g.removeObject(ID,up)
    if objects[ID]==nil then
        return false,"does not exist"
    end
    local o=objects[ID]
    if o.getCoords()~=nil then
        for i=1,#o.getCoords() do
            local x=o.getCoords()[i][1]
            local y=o.getCoords()[i][2]
            gpu.set(x,y," ")
        end
    else
        gpu.fill(o.getX(),o.getY(),o.getRX()+1,o.getRY()+1," ")
    end
    for j=1,#layerT[o.getLayer()] do
        if layerT[o.getLayer()][j]==o then
            table.remove(layerT[o.getLayer()],j)
            if layerT[o.getLayer()][1]==nil then
                layerT[o.getLayer()]=nil
            end
        end
    end
    if not up then
        g.update(o,1,true)
    end
    for i=1,#objects do
        if objects[i]==o.getID() then
            table.remove(objects,i)
        end
    end
    objects[ID]=nil
end

function g.removeFromScreen(o,up)
    if type(o)~="table" then
        o=objects[o]
    end
    if o.getCoords()~=nil then
        for i=1,#o.getCoords() do
            local x=o.getCoords()[i][1]
            local y=o.getCoords()[i][2]
            gpu.set(x,y," ")
        end
    else
        gpu.fill(o.getX(),o.getY(),o.getRX()+1,o.getRY()+1," ")
    end
    for j=1,#layerT[o.getLayer()] do
        if layerT[o.getLayer()][j]==o then
            table.remove(layerT[o.getLayer()],j)
            if layerT[o.getLayer()][1]==nil then
                layerT[o.getLayer()]=nil
            end
        end
    end
    if not up then
        g.update(o,1,true)
    end
end

function g.addObject(obj,up,add_ov)
    local add=true
    for i=1,#objects do
        if objects[i]==obj.getID() then
            add=false
            break
        end
    end
    if add and not add_ov then
        objects[#objects+1]=obj.getID()
        objects[obj.getID()]=obj
    end
    if not up then
        g.update(obj,obj.getLayer()) 
    end
    return true
end

function g.getObject(id)
    return objects[id]
end

function g.setResolution(w,h)
    if h==nil or w==nil then
        w,h=opt_res()
    end
    gpu.setResolution(w,h)
end

function table.maxn(tab,highest)
    highest=highest or 300
    for i=highest,1,-1 do
        if tab[i]~=nil then
            return i
        end
    end
    return 1
end

function table.minn(tab,highest)
    highest=highest or 300
    for i=1,300 do 
        if tab[i]~=nil then
            return i
        end
    end
    return 1
end

function g.opt_layers() --code deprecated, low priority
    local w,h=gpu.getResolution()
    for i=100,300 do
        if g.getLayerStatus(1,1,w,h,i)=="empty" then
            for j=1,w*h do
                table.remove(scTable[j],i)
            end
            for j=1,#objects do
                if objects[objects[j]].getLayer()>i then
                    objects[objects[j]].setLayer(objects[objects[j]].getLayer()-1)
                end
            end
        end
    end
    for i=99,1,-1 do
        if g.getLayerStatus(1,1,w,h,i)=="empty" then
            for j=i,1,-1 do 
                for k=1,w*h do
                    scTable[k][j]=scTable[k][j-1]
                end
            end
            for j=1,#objects do
                if objects[objects[j]].getLayer()<i then
                    objects[objects[j]].setLayer(objects[objects[j]].getLayer()+1)
                end
            end
        end
    end 
end

function g.initShapes(import,override) --function to import shape files located in /lib
    local i=require(import)
    i.init(g)
    for a,b in pairs(i) do
        if g[a]~=nil and override~=true then
            print(a.." exists")
        else
            g[a]=b
        end
    end
end

function g.removeShape(name)
    if g[name]~=nil then
        g[name]=nil
    else
        print("does not exist")
    end
end

function g.initialize(hook,back_color,fore_color,req_priority)
    layerT={}
    f=hook
    if f==nil then
        print("warning: no request-handler, ignore")
    else
        f.addStatus("GUI",g.update,"false")
        local hook_as
        if hook_as_permanent then
            hook_as="permanent"
        end
        req_priority=req_priority or hook_as
        f.addTask(nil,nil,nil,"internal","GUI",nil,nil,req_priority)
    end
    back_color_std=back_color or back_color_std 
    fore_color_std=fore_color or fore_color_std
    term.setCursorBlink(false)
    term.clear()
    g.initShapes("shapes_default")
    event.listen("touch",g.event)
    event.listen("scroll",g.event)
end

function g.stopGUI()
    event.ignore("touch",g.event)
    event.ignore("scroll",g.event)
    for i=1,#objects do
        if objects[objects[i]]~=nil then
            objects[objects[i]].remove(true)
        end
    end
    term.clear()
    os.exit() --change this?
end
    
function g.setForeColor(color)
    color=color or fore_color_std
    gpu.setForeground(color)
end

function g.setBackColor(color)
    color=color or back_color_std
    gpu.setBackground(color)
end

function g.getResolution()
    local w,h=gpu.getResolution()
    if w~=width or h~=height then
        g.update()
    end
    return w,h
end

function g.getScreenTable()
    return layerT
end

function g.show() 
    term.clear()
    for i=1,300 do
        if layerT[i]~=nil then
            for j=1,#layerT[i] do
                layerT[i][j].show(true)
                gpu.setForeground(fore_color_std)
                gpu.setBackground(back_color_std)
            end
        end
    end
end

function g.update(o,start,self) --self: not execute self.show?
    if o==nil then 
        g.show()
        gpu.setForeground(fore_color_std)
        gpu.setBackground(back_color_std)
        return false
    end
    if type(o)~="table" then
        o=objects[o]
    end
    start=start or 1
    local update_list={}
    local w,h=gpu.getResolution()
    for i=1,#objects do
        if objects[objects[i]]~=o then
            local k=objects[objects[i]]
            if k.getLayer()>=start then
                if k.getX()<=o.getX()+o.getRX() and k.getX()+k.getRX()>=o.getX() then
                    if k.getY()<=o.getY()+o.getRX() and k.getY()+k.getRY()>=o.getY() then
                        if k.getCoords()==nil then
                            if update_list[k.getLayer()]==nil then
                                update_list[k.getLayer()]={}
                            end
                            update_list[k.getLayer()][#update_list[k.getLayer()]+1]=k
                        else
                            for j=1,#k.getCoords() do
                                if k.getCoords()[j][1]<=o.getX()+o.getRX() and k.getCoords()[j][1]>=o.getX() then
                                    if k.getCoords()[j][2]>=o.getY() and k.getCoords()[j][2]<=o.getY()+o.getRY() then
                                        if update_list[k.getLayer()]==nil then
                                            update_list[k.getLayer()]={}
                                        end
                                        update_list[k.getLayer()][#update_list[k.getLayer()]+1]=k
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
            end
        else
            if start<=o.getLayer() and self==nil then --not called after g.fill/g.set --> double execution
                if update_list[o.getLayer()]==nil then
                    update_list[o.getLayer()]={}
                end
                update_list[o.getLayer()][#update_list[o.getLayer()]+1]=o
            end
        end
    end
    for i=1,300 do
        if update_list[i]~=nil then
            for j=1,#update_list[i] do
                if update_list[i][j]~=nil then
                    if update_list[i][j].update~=nil then
                        local b=update_list[i][j]
                        local x,y,rx,ry
                        if b.getCoords()~=nil and b.updateCoords~=nil and b~=o then
                            for j=1,#b.getCoords() do
                                if b.getCoords()[j][1]<=o.getX()+o.getRX() and b.getCoords()[j][1]>=o.getX() then
                                    if b.getCoords()[j][2]>=o.getY() and b.getCoords()[j][2]<=o.getY()+o.getRY() then
                                        b.updateCoords(k.getCoords()[j][1],k.getCoords()[j][2])
                                        gpu.setForeground(fore_color_std)
                                        gpu.setBackground(back_color_std)
                                    end
                                end
                            end
                        elseif b~=o then
                            if b.getX()<o.getX() then
                                x=o.getX()
                                if o.getRX()+o.getX()>b.getRX()+b.getX() then
                                    rx=b.getX()+b.getRX()-o.getX()
                                else
                                    rx=o.getRX()
                                end
                            else
                                x=b.getX()
                                if b.getRX()+b.getX()>o.getRX()+o.getX() then
                                    rx=o.getRX()+o.getX()-b.getX()
                                else
                                    rx=b.getRX()
                                end
                            end
                            if b.getY()<o.getY() then
                                y=o.getY()
                                if o.getRY()+o.getY()>b.getRY()+b.getY() then
                                    ry=b.getRY()+b.getY()-o.getY()
                                else
                                    ry=o.getRY()
                                end
                            else
                                y=b.getY()
                                if b.getRY()+b.getY()>o.getRY()+o.getY() then
                                    ry=o.getRY()+o.getY()-b.getY()
                                else
                                    ry=b.getRY()
                                end
                            end
                            b.update(x,y,rx,ry)
                            gpu.setForeground(fore_color_std)
                            gpu.setBackground(back_color_std)
                        else
                            o.update()
                            gpu.setForeground(fore_color_std)
                            gpu.setBackground(back_color_std)
                        end
                    else
                        --complicated calculation of all objects in front of object that has no update() method..
                    end
                end
            end
        end
    end
    update_list={}
    --if g.getHighestLayer()>280 then  --currently unused, not needed with good GUI-design
        --g.opt_layers()
    --end
end

function g.getHighestLayer(x,y,rx,ry)
    x=x or 1 y=y or 1
    if rx==nil or ry==nil then
        local w,h=g.getResolution()
        rx=w-1
        ry=h-1
    end
    local layer=getLayer(x,y,rx,ry,1)
    return layer
end 

function g.getLowestLayer(x,y,rx,ry)
    x=x or 1 y=y or 1
    if rx==nil or ry==nil then
        local w,h=g.getResolution()
        rx=w-1
        ry=h-1
    end
    local layer=getLayer(x,y,rx,ry,-1)
    return layer
end

function g.getStdBCol()
    return back_color_std
end

function g.getStdFCol()
    return fore_color_std
end

function g.set(x,y,rx,ry,layer,text,ref,bcol,fcol)
    x=x or 1 y=y or 1 rx=rx or 0 ry=ry or 0
    if ref==nil then
        return false
    end
    text=text or " "
    layer=layer or g.getHighestLayer(x,y,rx,ry)
    local w,h=g.getResolution()
    local add=true
    if x>w or y>h then
        add=false
    elseif x+rx<1 then
        add=false
    elseif y+ry<1 then
        add=false
    end
    if add then
        for i=x,x+rx do
            for j=y,y+ry do
                if bcol~=nil then
                    gpu.setBackground(bcol)
                end
                if fcol~=nil then
                    gpu.setForeground(fcol)
                end
                gpu.set(i,j,text)
                gpu.setBackground(back_color_std)
                gpu.setForeground(fore_color_std)
            end
        end
    end
    if layerT[layer]==nil then
        layerT[layer]={}
    end
    local add=true
    for j=1,#layerT[layer] do
        if layerT[layer][j]==objects[ref] then
            add=false
            break
        end
    end
    if add then
        layerT[layer][#layerT[layer]+1]=objects[ref]
    end
end

function g.fill(x,y,rx,ry,layer,text,ref,bcol,fcol)
    x=x or 1 y=y or 1 rx=rx or 0 ry=ry or 0
    if ref==nil then
        return false
    end
    text=text or " "
    layer=layer or g.getHighestLayer(x,y,rx,ry)
    local w,h=g.getResolution()
    local add=true
    if x>w or y>h then
        add=false
    elseif x<1 and x+rx<1 then
        add=false
    elseif y<1 and y+ry<1 then
        add=false
    end
    if add then
        if bcol~=nil then
            gpu.setBackground(bcol)
        end
        if fcol~=nil then
            gpu.setForeground(fcol)
        end
        gpu.fill(x,y,rx+1,ry+1,text)
        gpu.setBackground(back_color_std)
        gpu.setForeground(fore_color_std)
    end
    if layerT[layer]==nil then
        layerT[layer]={}
    end
    local add=true
    for j=1,#layerT[layer] do
        if layerT[layer][j]==objects[ref] then
            add=false
            break
        end
    end
    if add then
        layerT[layer][#layerT[layer]+1]=objects[ref]
    end
end

function g.setStdForeColor(color)
    fore_color_std=color or fore_color_std
    g.show()
end

function g.setStdBackColor(color)
    back_color_std=color or back_color_std
    g.show()
end

function g.getLayerStatus(x,y,rx,ry,layer) --not used by any function
    if layerT[layer]==nil then
        return true --empty
    end
    for i=1,#layerT[layer] do
        if layerT[layer][i].getX()<x+rx and layerT[layer][i].getX()+layerT[layer][i].getRX()>x then
            if layerT[layer][i].getY()<y+ry and layerT[layer][i].getY()+layerT[layer][i].getRY()>y then
                return false
            end
        end
    end
    return true
end

function g.read(history,dobreak,hint,pwchar,fcol,bcol) return term_read(history,dobreak,hint,pwchar,fcol,bcol,fore_color_std,back_color_std) end
function g.setCursorBlink(bool) term.setCursorBlink(bool) end
function g.setCursor(x,y) term.setCursor(x,y) end

return g
