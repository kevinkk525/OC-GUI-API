---config section
local version="0.7.3b"
local author="kevinkk525"
local scrollLines=1
----
local unicode=require("unicode")
local colors=require("colors")
local s={} --all shapes
local g --reference to GUI-API

-- Never use floats as coordinates!
--7.2b: fcol/bcol for each line in listing, bugfix in textbox, added textbox (if works)
--7.3b: code changes to minimize lines and redundancy
-- don't try textboxes input in lua-interactive, not working there

------ local functions
function s.init(GUI) --gets removed on import
    g=GUI --GUI reference
end

local function randID() --id could be done by #objects+1?
    local id=tostring(math.random(1,1000))
    if g.ID_Status(id)==false then
        id=randID()
    end
    return id
end

local function scrollText(o,direction)
    if direction==1 then
        if o.getTextLine()~=1 then
            if o.getTextLine()-scrollLines<1 then
                o.cleanTextArea()
                o.setTextLine(1)
            else
                o.cleanTextArea()
                o.setTextLine(o.getTextLine()-scrollLines)
            end 
        end
    else
        if not o.getTextLine(true) then
            o.cleanTextArea()
            o.setTextLine(o.getTextLine()+scrollLines)
        end
    end
    g.update(o.getID())
end

local function create_self(x,y,rx,ry,fcol,bcol,scrollEvent,textflag,id,layer,coords,clickEvent,text,textLine)
    return {["x"]=x,["y"]=y,["rx"]=rx,["ry"]=ry,["fcol"]=fcol,["bcol"]=bcol,["scrollEvent"]=nil,["textflag"]=nil,
    ["id"]=randID(),["layer"]=layer,["coords"]=nil,["clickEvent"]=clickEvent,["text"]=nil,["textLine"]=1} --coords added in expansion, textflag==true --> last line printed
end

local function connect_functions(self,references,ref,update,updateCoords,show,cleanText)
    local r={["getX"]=function() return self.x end,["getY"]=function() return self.y end,["getRX"]=function() return self.rx end,
    ["getRY"]=function() return self.ry end,["remove"]=function(up) ref("remove",up) g.removeObject(self.id,up) self=nil end,["getID"]=function() return self.id end,
    ["update"]=update,["changeLayer"]=function(layer) ref("move",0,0,layer-self.layer,true) g.changeLayer(self.id,layer,false) end,["getLayer"]=function() return self.layer end,
    ["setLayer"]=function(layer) self.layer=layer end,["getCoords"]=function() return self.coords end,["move"]=function(rx,ry,layer,up) rx=rx or 0 ry=ry or 0 
    layer=layer or 0 g.removeFromScreen(self.id,up) self.layer=self.layer+layer self.x=self.x+rx self.y=self.y+ry ref("move",rx,ry,layer,false) show(up) end,["resize"]=function(rx,ry,up) rx=rx or 0 
    ry=ry or 0 g.removeFromScreen(self.id,false) self.rx=self.rx+rx self.ry=self.ry+ry ref("resize",rx,ry,true) show(up) end,["show"]=show,
    ["toPosition"]=function(x,y,layer,up) x=x or self.x y=y or self.y layer=layer or self.layer g.removeFromScreen(self.id,up) local rx=x-self.x local ry=y-self.y layer=layer-self.layer self.layer=self.layer+layer self.x=self.x+rx self.y=self.y+ry ref("move",rx,ry,layer,false) show(up) end,
    ["clickEvent"]=function(x,y,button,user,test) if test then if self.clickEvent~=nil then return true end return false end self.clickEvent(x,y,button,user) end,
    ["setClickEvent"]=function(f) self.clickEvent=f end,["removeClickEvent"]=function() self.clickEvent=nil end,["cleanTextArea"]=cleanText,
    ["setSize"]=function(rx,ry,up) rx=rx or self.rx ry=ry or self.ry ref("resize",rx-self.rx,ry-self.ry,true) self.rx=rx self.ry=ry show(up) end,
    ["getFCol"]=function() return self.fcol end,["getBCol"]=function() return self.bcol end,["setFCol"]=function(col,up) self.fcol=col ref("setFCol",col,true) if not up then g.update(self.id,self.layer) end end,
    ["setBCol"]=function(col,up) self.bcol=col ref("setBCol",col,true) if not up then g.update(self.id,self.layer) end end,["updateCoords"]=updateCoords,["getText"]=function() return self.text end,
    ["setText"]=function(text,...) cleanText() self.text=text:format(...) g.update(self.id) end,["addReference"]=function(shape,...) references[#references+1]=g[shape](...) end,["getReferences"]=function() return references end,
    ["scrollEvent"]=function(x,y,direction,user,test) if test then if self.scrollEvent~=nil then return true end return false end self.scrollEvent(x,y,direction,user) end,
    ["setScrollEvent"]=function(f) self.scrollEvent=f end,["removeScrollEvent"]=function() self.scrollEvent=nil end,
    ["getTextLine"]=function(flag) if flag then return self.textflag else return self.textLine end end,["setTextLine"]=function(line) self.textLine=line end}
    for a,b in pairs(g.objectFunctions()) do
        r[a]=b
    end
    return r
end
-------

------
-- Definition of all shape types
------  
 
function s.rect_full(x,y,rx,ry,layer,fcol,bcol,clickEvent,add) 
    ------
    -- this part can be copied to any shape and expanded like below
    ------
    layer=layer or g.getHighestLayer()+1
    local self=create_self(x,y,rx,ry,fcol,bcol,scrollEvent,textflag,id,layer,coords,clickEvent,text,textLine)
    
    local r
    local references={}
    local function ref(fc,...) for i=1,#references do if references[i][fc]~=nil then references[i][fc](...) end end end
    local set=function(x,y,rx,ry,text,bcol,fcol) g.set(x,y,rx,ry,self.layer,text,self.id,bcol,fcol) end
    local fill=function(x,y,rx,ry,text,bcol,fcol) g.fill(x,y,rx,ry,self.layer,text,self.id,bcol,fcol) end
    local update --dynamic range update - only add function in function are if you use it --> highly suggested to be implemented
    local updateCoords --only add function in function area if you use it
    local show --always define this
    local cleanText
    ------ 
    
    ------
    --object functions
    ------
    show=function(up) --must be implement in similar way in every function
    ------ modify between
        fill(self.x,self.y,self.rx,self.ry," ",self.bcol,self.fcol)
    ------
        if not up then
            g.update(self.id,self.layer+1) 
        end
    end
    
    update=function(x,y,rx,ry) 
        x=x or self.x y=y or self.y rx=rx or self.rx ry=ry or self.ry
        fill(x,y,rx,ry," ",self.bcol,nil) --no g.update here
    end
    --function table, copy to your new shape and modify/expand if needed
    r=connect_functions(self,references,ref,update,updateCoords,show,cleanText)
    r.getTextLine=nil r.setTextLine=nil r.setText=nil r.getText=nil r.cleanTextArea=nil--custom modification
    --
    g.addObject(r,add) --adds pointer to object functions for interaction with GUI
    return r
end

function s.label(x,y,rx,ry,layer,fcol,bcol,clickEvent,add,text,...) --maybe add style: center,left,right...,add dynamic w,h based on text?,line break word based?,bug: \n after line break because of rx
    --------------------------
    -- this part can be copied to any shape and expanded like below
    --------------------------
    layer=layer or g.getHighestLayer()+1
    if text then
        text=text:format(...)
    end
    local self=create_self(x,y,rx,ry,fcol,bcol,scrollEvent,textflag,id,layer,coords,clickEvent,text,textLine)
    self.text=text self.autoScroll=true self.textflag=nil
    
    local r
    local references={}
    local function ref(fc,...) for i=1,#references do if references[i][fc]~=nil then references[i][fc](...) end end end
    local set=function(x,y,rx,ry,text,bcol,fcol) g.set(x,y,rx,ry,self.layer,text,self.id,bcol,fcol) end
    local fill=function(x,y,rx,ry,text,bcol,fcol) g.fill(x,y,rx,ry,self.layer,text,self.id,bcol,fcol) end
    local update --dynamic range update - only add function in function are if you use it --> highly suggested to be implemented
    local updateCoords --only add function in function area if you use it
    local show --always define this
    local cleanText --custom function
    ------ 
    
    ------
    --object functions
    ------
    show=function(up) --must be implement in similar way in every function (keep frame)
    ------ modify between
        update()
    ------
        if not up then
            g.update(self.id,self.layer+1)
        end
    end
    ---
    
    update=function(x,y,rx,ry)
        if self.text then
            local j=1
            x=x or self.x y=y or self.y rx=rx or self.rx ry=ry or self.ry
            for i=1,self.ry+self.textLine do
                if j<=unicode.len(self.text) then
                    if unicode.sub(self.text,j,j)==" " then
                        j=j+1
                    end
                    local t=unicode.sub(self.text,j,j+self.rx)
                    local k=t:find("\n")
                    if k then
                        if self.y+i-self.textLine>=y and self.y+i-self.textLine<=y+ry and i>=self.textLine then
                            local output=unicode.sub(self.text,j,j+k-2)
                            set(self.x+x-self.x,self.y+i-self.textLine,0,0,unicode.sub(output,1+x-self.x,1+x-self.x+rx),self.bcol,self.fcol)
                        end
                        j=j+k
                    else
                        if self.y+i-self.textLine>=y and self.y+i-self.textLine<=y+ry and i>=self.textLine then
                            set(self.x+x-self.x,self.y+i-self.textLine,0,0,unicode.sub(t,1+x-self.x,1+x-self.x+rx),self.bcol,self.fcol)
                        end
                        j=j+self.rx+1
                    end
                else
                    break
                end
            end
            if j-1>=unicode.len(self.text) then
                self.textflag=true
            else
                self.textflag=false
            end
            if j-1>=unicode.len(self.text) and self.textLine==1 then
                if self.autoScroll then
                    self.scrollEvent=nil
                end
            else
                if self.autoScroll then
                    self.scrollEvent=function(x,y,direction,user) scrollText(r,direction) end
                end
            end
        end
    end
    
    cleanText=function(x,y,rx,ry)
        if self.text then
            local j=1
            x=x or self.x y=y or self.y rx=rx or self.rx ry=ry or self.ry
            for i=1,self.ry+self.textLine do
                if j<=unicode.len(self.text) then
                    if unicode.sub(self.text,j,j)==" " then
                        j=j+1
                    end
                    local t=unicode.sub(self.text,j,j+self.rx)
                    local k=t:find("\n")
                    if k then
                        if self.y+i-self.textLine>=y and self.y+i-self.textLine<=y+ry and i>=self.textLine then
                            local output=unicode.sub(self.text,j,j+k-2)
                            output=unicode.sub(output,1+x-self.x,2+x-self.x+rx)
                            fill(self.x+x-self.x,self.y+i-self.textLine,unicode.len(output)-1,0," ")--,self.bcol,self.fcol)
                        end
                        j=j+k
                    else
                        if self.y+i-self.textLine>=y and self.y+i-self.textLine<=y+ry and i>=self.textLine then
                            local output=unicode.sub(t,1+x-self.x,2+x-self.x+rx)
                            fill(self.x+x-self.x,self.y+i-self.textLine,unicode.len(output)-1,0," ")--,self.bcol,self.fcol)
                        end
                        j=j+self.rx+1
                    end
                else
                    break
                end
            end
        end
    end
    -------
    --function table, copy to your new shape and modify/expand if needed
    r=connect_functions(self,references,ref,update,updateCoords,show,cleanText)
    --
    g.addObject(r,add) --adds pointer to object functions for interaction with GUI
    return r
end

function s.labelbox(x,y,rx,ry,layer,fcol,bcol,clickEvent,add,text,...) --purely referenced object, having referenced objects and main object in the same layer is bad for clickEvents
    ------
    -- this part can be copied to any shape and expanded like below
    ------
    layer=layer or g.getHighestLayer()+1
    local r=s.rect_full(x,y,rx,ry,layer,fcol,bcol,clickEvent,add)
    r.addReference("label",x,y,rx,ry,layer+1,fcol,bcol,clickEvent,add,text,...)
    r.setText=function(text,...) r.getReferences()[1].setText(text,...) end
    r.getText=function() return r.getReferences()[1].getText() end
    r.setTextLine=function(line) return r.getReferences()[1].setTextLine(line) end
    r.getTextLine=function(i) return r.getReferences()[1].getTextLine(i) end
    r.setScrollEvent=function(f) return r.getReferences()[1].setScrollEvent(f) end
    r.setAutoScrollEvent=function(i) return r.getReferences()[1].setAutoScroll(i) end
    r.scrollEvent=function(x,y,direction,user) return r.getReferences()[1].scrollEvent(x,y,direction,user) end
    r.removeScrollEvent=function() return r.getReferences()[1].removeScrollEvent() end
    r.removeText=function() return r.getReferences()[1].removeText() end
    r.moveText=function(rx,ry)
        rx=rx or 0 ry=ry or 0
        if r.getReferences()[1].getX()+rx<r.getX() or r.getReferences()[1].getY()+ry<r.getY() or r.getReferences()[1].getX()+rx>r.getX()+r.getRX() or r.getReferences()[1].getY()+ry>r.getY()+r.getRY() then
            return false,"can't move outside border"
        elseif r.getReferences()[1].getRX()+r.getReferences()[1].getX()+rx>r.getX()+r.getRX() then 
            r.getReferences()[1].resize(r.getX()+r.getRX()-rx-r.getReferences()[1].getX()-r.getReferences()[1].getRX(),0,true)
        end
        if r.getReferences()[1].getRY()+r.getReferences()[1].getY()+ry>r.getY()+r.getRY() then
            r.getReferences()[1].resize(0,r.getY()+r.getRY()-ry-r.getReferences()[1].getY()-r.getReferences()[1].getRY(),true)
        end
        r.getReferences()[1].move(rx,ry) 
    end
    r.resizeText=function(rx,ry) 
        rx=rx or 0 ry=ry or 0 
        if r.getReferences()[1].getX()+r.getReferences()[1].getRX()+rx>r.getX()+r.getRX() then 
            rx=r.getX()+r.getRX()-r.getReferences()[1].getX()-r.getReferences()[1].getRX()
        elseif r.getReferences()[1].getX()<=r.getReferences()[1].getRX()+rx then
            rx=r.getReferences()[1].getX()-r.getReferences()[1].geRX()+1
        end 
        if r.getReferences()[1].getY()+r.getReferences()[1].getRY()+ry>r.getY()+r.getRY() then
            ry=r.getY()+r.getRY()-r.getReferences()[1].getY()-r.getReferences()[1].getRY()
        elseif r.getReferences()[1].getY()<=r.getReferences()[1].getRY()+ry then
            ry=r.getReferences()[1].getY()-r.getReferences()[1].getRY()+1
        end
        r.getReferences()[1].resize(rx,ry) 
    end
    r.setTextFCol=function(fcol) r.getReferences()[1].setFCol(fcol) end
    r.setTextBCol=function(bcol) r.getReferences()[1].setBCol(bcol) end
    r.getTextFCol=function() return r.getReferences()[1].getFCol() end
    r.getTextBCol=function() return r.getReferences()[1].getBCol() end
    r.getTextPosition=function() return r.getReferences()[1].getX(),r.getReferences()[1].getY() end
    
    g.addObject(r,add) --adds pointer to object functions for interaction with GUI
    return r
    --referenced object (text) does not need clickEvent because it gets skipped during check and clickEvent of main object is called.
end

function s.listing(x,y,rx,ry,layer,fcol,bcol,clickEvent,add,text) --maybe add style: center,left,right...,add dynamic w,h based on text?,line break word based?,bug: \n after line break because of rx
    --------------------------
    -- this part can be copied to any shape and expanded like below
    --------------------------
    layer=layer or g.getHighestLayer()+1
    if text then
        if type(text)~="table" then
            return false,"wrong textarray format, must be table"
        end
    end
    local self=create_self(x,y,rx,ry,fcol,bcol,scrollEvent,textflag,id,layer,coords,clickEvent,text,textLine)
    self["tltab"]={} self.fcol={[0]=fcol} self.bcol={[0]=bcol}
    self.text=text self.textlines=0 self.autoScroll=true 
    if text then for i=1,1000 do if text[i] then self.textlines=self.textlines+1 end end end
    
    local r --object
    local references={}
    local function ref(fc,...) for i=1,#references do if references[i][fc]~=nil then references[i][fc](...) end end end
    local set=function(x,y,rx,ry,text,bcol,fcol) g.set(x,y,rx,ry,self.layer,text,self.id,bcol,fcol) end
    local fill=function(x,y,rx,ry,text,bcol,fcol) g.fill(x,y,rx,ry,self.layer,text,self.id,bcol,fcol) end
    local update --dynamic range update - only add function in function area if you use it --> highly suggested to be implemented
    local updateCoords --only add function in function area if you use it
    local show --always define this
    local cleanText --custom function
    local start_elem=unicode.char(0x0387)
    ------ 
    
    ------
    --object functions
    ------
    show=function(up) --must be implement in similar way in every function (keep frame)
    ------ modify between
        update()
    ------
        if not up then
            g.update(self.id,self.layer+1)
        end
    end
    ---
    local function fcol(line)
        if self.fcol[line] then
            return self.fcol[line]
        else
            return self.fcol[0]
        end
    end
    local function bcol(line)
        if self.bcol[line] then
            return self.bcol[line]
        else 
            return self.bcol[0]
        end
    end
    
    update=function(x,y,rx,ry,clean) 
        if self.text then 
            self.tltab={}
            x=x or self.x y=y or self.y rx=rx or self.rx ry=ry or self.ry
            local i=1
            for line=1,self.textlines do
                local j=1
                if i<=self.ry+self.textLine then
                    if self.text[line] then
                        while true do
                            if j<=unicode.len(self.text[line]) then
                                if unicode.sub(self.text[line],j,j)==" " then
                                    j=j+1
                                end
                                local t=unicode.sub(self.text[line],j,j+self.rx)
                                local k=t:find("\n")
                                if k then
                                    if self.y+i-self.textLine<=y+ry then
                                        if j==1 or j==2 then
                                            local output=start_elem.." "
                                            output=output..unicode.sub(self.text[line],j,j+k-2)
                                            if i>=self.textLine then
                                                if not clean then
                                                    set(self.x+x-self.x,self.y+i-self.textLine,0,0,unicode.sub(output,1+x-self.x,1+x-self.x+rx),bcol(line),fcol(line))
                                                else
                                                    fill(self.x+x-self.x,self.y+i-self.textLine,unicode.len(unicode.sub(output,1+x-self.x,1+x-self.x+rx))-1,0," ")--,self.bcol,self.fcol)
                                                end
                                                self.tltab[i-self.textLine+1]=line
                                                if line==self.textlines and j+k-1>=unicode.len(self.text[line]) then
                                                    self.tltab[0]=1
                                                end
                                            end
                                            output=nil
                                        else
                                            if i>=self.textLine then
                                                if not clean then
                                                    set(self.x+x-self.x,self.y+i-self.textLine,0,0,unicode.sub(unicode.sub(self.text[line],j,j+k-2),1+x-self.x,1+x-self.x+rx),bcol(line),fcol(line))
                                                else
                                                    fill(self.x+x-self.x,self.y+i-self.textLine,unicode.len(unicode.sub(unicode.sub(self.text[line],j,j+k-2),1+x-self.x,1+x-self.x+rx))-1,0," ")--,self.bcol,self.fcol)
                                                end
                                                self.tltab[i-self.textLine+1]=line
                                                if line==self.textlines and j+k-1>=unicode.len(self.text[line]) then
                                                    self.tltab[0]=1
                                                end
                                            end
                                        end
                                    end
                                    j=j+k
                                    i=i+1
                                else
                                    local offs=0
                                    if self.y+i-self.textLine<=y+ry then
                                        if j==1 or j==2 then
                                            if i>=self.textLine then                                        
                                                local output=start_elem.." "
                                                output=output..t
                                                if not clean then
                                                    set(self.x+x-self.x,self.y+i-self.textLine,0,0,unicode.sub(output,1+x-self.x,1+x-self.x+rx),bcol(line),fcol(line))
                                                else
                                                    fill(self.x+x-self.x,self.y+i-self.textLine,unicode.len(unicode.sub(output,1+x-self.x,1+x-self.x+rx))-1,0," ")--,self.bcol,self.fcol)
                                                end
                                                output=nil
                                                self.tltab[i-self.textLine+1]=line
                                                if line==self.textlines and j+self.rx-offs>=unicode.len(self.text[line]) then
                                                    self.tltab[0]=1
                                                end
                                            end
                                            offs=2
                                        else
                                            if i>=self.textLine then
                                                if not clean then
                                                    set(self.x+x-self.x,self.y+i-self.textLine,0,0,unicode.sub(t,1+x-self.x,1+x-self.x+rx),bcol(line),fcol(line))
                                                else
                                                    fill(self.x+x-self.x,self.y+i-self.textLine,unicode.len(unicode.sub(t,1+x-self.x,1+x-self.x+rx))-1,0," ")
                                                end
                                                self.tltab[i-self.textLine+1]=line
                                                if line==self.textlines and j+self.rx-offs>=unicode.len(self.text[line]) then
                                                    self.tltab[0]=1
                                                end
                                            end
                                        end
                                    end                                    
                                    j=j+self.rx+1-offs
                                    i=i+1
                                end
                            else
                                break
                            end
                        end
                    end
                else
                    break
                end
            end
            if self.tltab[0] then
                self.textflag=true
            else
                self.textflag=nil
            end
            if self.autoScroll then
                if self.tltab[0] and self.textLine==1 then
                    self.scrollEvent=nil
                else
                    self.scrollEvent=function(x,y,direction,user) scrollText(r,direction) end 
                end
            end
        end
    end
    
    cleanText=function(x,y,rx,ry,line) --line currently unused
        update(x,y,rx,ry,true)
    end
    -------
    --function table, copy to your new shape and modify/expand if needed
    r=connect_functions(self,references,ref,update,updateCoords,show,cleanText)
    
    r["clickEvent"]=function(x,y,button,user,test) if test then if self.clickEvent~=nil then return true end return false end if self.tltab[y-self.y+1] and type(self.clickEvent)=="table" and self.clickEvent[self.tltab[y-self.y+1]] then self.clickEvent[self.tltab[y-self.y+1]](x,y,button,user,self.text[self.tltab[y-self.y+1]]) elseif type(self.clickEvent)=="function" then self.clickEvent(x,y,button,user,self.text) end end
    r["setClickEvent"]=function(f,line) if type(f)=="number" then return false,"function,line" end if not self.clickEvent then self.clickEvent={} end if line and type(self.clickEvent)=="table" then self.clickEvent[line]=f elseif line and type(self.clickEvent)=="function" then self.clickEvent={} self.clickEvent[line]=f elseif line then return false,"clickEvent={}" else self.clickEvent=f end end
    r["removeClickEvent"]=function(line) if line and type(self.clickEvent)=="table" then self.clickEvent[line]=nil else self.clickEvent=nil end end
    r["getText"]=function(i) if not i then return self.text end return self.text[i] end
    r["removeText"]=function(i) if i then self.text[i]=nil self.textlines=self.textlines-1 else self.text=nil self.textlines=0 end end
    r["setText"]=function(i,text,...) if not i or type(i)=="string" then return false,"no line specified" elseif type(text)=="table" then cleanText() self.text=text self.textlines=0 for i=1,1000 do if self.text[i] then self.textlines=self.textlines+1 end end else cleanText(nil,nil,nil,nil,i) if not self.text then self.text={} end if not self.text[i] then self.textlines=self.textlines+1 end self.text[i]=text:format(...) end g.update(self.id) end
    r["removeText"]=function(i) if type(i)=="number" then self.text[i]=nil else return false,"must be number" end end
    r["setAutoScroll"]=function(i) if type(i)~="boolean" then return false,"parameter has to be boolean" end self.autoScroll=i end
    r["getFCol"]=function(i) i=i or 0 return self.fcol[i] end r["getBCol"]=function(i) i=i or 0 return self.bcol[i] end 
    r["setFCol"]=function(col,i,up) i=i or 0 self.fcol[i]=col if i==0 then ref("setFCol",col,true) end if not up then g.update(self.id,self.layer) end end
    r["setBCol"]=function(col,i,up) i=i or 0 self.bcol[i]=col if i==0 then ref("setBCol",col,true) end if not up then g.update(self.id,self.layer) end end
    --
    g.addObject(r,up,add) --adds pointer to object functions for interaction with GUI
    return r
end

function s.textbox(x,y,rx,ry,layer,fcol,bcol,clickEvent,add,text) --maybe add style: center,left,right...,add dynamic w,h based on text?,line break word based?,bug: \n after line break because of rx
    --------------------------
    -- this part can be copied to any shape and expanded like below
    --------------------------
    layer=layer or g.getHighestLayer()+1
    local self={["password"]=nil,["text"]=text,["clickEvent"]=clickEvent} --custom self
    
    local r=g.rect_full(x,y,rx,ry,layer,fcol,bcol,clickEvent,true)
    local show_rect=r.show
    local update_r=r.update
    local up
    local references={}
    local function ref(fc,...) for i=1,#references do if references[i][fc]~=nil then references[i][fc](...) end end end
    local set=function(x,y,rx,ry,text,bcol,fcol) g.set(x,y,rx,ry,self.layer,text,self.id,bcol,fcol) end
    local fill=function(x,y,rx,ry,text,bcol,fcol) g.fill(x,y,rx,ry,self.layer,text,self.id,bcol,fcol) end
    local update --dynamic range update - only add function in function area if you use it --> highly suggested to be implemented
    local updateCoords --only add function in function area if you use it
    local show --always define this
    local cleanText --custom function
    local color_offset=0x040404
    ------ 
    
    ------
    --object functions
    ------
    show=function(up) --must be implement in similar way in every function (keep frame)
    ------ modify between
        update()
    ------
        if not up then
            g.update(self.id,self.layer+1)
        end
    end
    ---
    fill=function(x,y,rx,ry,text,bcol,fcol) g.fill(x,y,rx,ry,r.getLayer(),text,r.getID(),bcol,fcol) end
    set=function(x,y,rx,ry,text,bcol,fcol) g.set(x,y,rx,ry,r.getLayer(),text,r.getID(),bcol,fcol) end
    
    update=function(x,y,rx,ry)
        update_r(x,y,rx,ry)
        x=x or r.getX() y=y or r.getY() rx=rx or r.getRX() ry=ry or r.getRY()
        ry=0
        if y==r.getY() and r.getRY()>0 then y=y+1 end
        if x+rx==r.getX()+r.getRX() and r.getRX()>1 then rx=rx-1 end
        if x==r.getX() and r.getRX()>1 then x=x+1 end
        local color=r.getBCol()
        if color then color=color-color_offset end
        fill(x,y,rx,ry," ",color,nil) --did not work because of gui.fill not working without layer and id
        if self.text then
            set(x,y,0,0,unicode.sub(self.text,1,rx),color,r.getFCol()) --check rx or rx+1?
        end
    end
    
    cleanText=function(x,y,rx,ry) --clean text by updating rect_full in that area
        update_r(x,y,rx,ry)
    end
    -------
    --function table, copy to your new shape and modify/expand if needed
    r.setClickEvent=function(f) self.clickEvent=f end
    r.clickEvent=function(x,y,button,user,test) if test then if self.clickEvent~=nil then return true end return false end local yt=r.getY() if r.getRY()>1 then yt=yt+1 end local xt=r.getX() if r.getRX()>1 then xt=xt+1 end g.setCursor(r.getX()+1,yt) g.setCursorBlink(true) self.text=g.read(nil,false,nil,self.password,r.getFCol(),r.getBCol()-color_offset) 
    self.text=unicode.sub(self.text,1,unicode.len(self.text)-1) g.setCursorBlink(false) self.clickEvent(x,y,button,user,self.text) end
    r.removeClickEvent=function() self.clickEvent=nil end
    r.setText=function(text,...) cleanText() self.text=text:format(...) g.update(self.id) end
    r.getText=function() return self.text end
    r.password=function(b) if type(b)~="boolean" then return false,"parameter must be boolean" end if b then self.password='*' else self.password=nil end end
    r["cleanTextArea"]=cleanText
    r.update=update
    r.show=show
    --
    g.addObject(r,up,add) --adds pointer to object functions for interaction with GUI
    up=nil
    return r
end

return s
