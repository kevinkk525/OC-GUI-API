# OC-GUI-API
GUI-API for OpenComputers with dynamic object updates and interaction

This readme will get updated soon.

Main features:
- Object oriented programming: myLabel=g.label(x,y,rx,ry,....), myLabel.move(1,1),...
- Private object attributes: can only be accessed by the functions provided by the object
- Layer support: You can hide an object behind another object or get it to the top of all objects
- Dynamic updates: If you change an object only objects below or on top of that object get updated and only in the affected area, not the complete objects --> reduces screen operations and makes the GUI very fast
- Referencing system: you can easily bind an object to another one so they move together, resize together,...
- Click Event support: if you click on something on the screen it will be passed to the corresponding object on the highest layer and executes the function defined in the object
- Predefined shapes/form elements like label,rect
- API allows simple adding of more shapes (hopefully someone contributes some^^)
- New shapes can be added on the basis of the default_shapes.lua code as it already provides all functions neccessary
- Change Text Color and Background Color for all objects that have not defined one (and therefore use the standard color)
- Support of shapes consisting of only coordinates not areas like a rect (support included but untested and no shapes using it available by now)
- No need of using component.gpu calls in your program, you can use the set/fill/getResolution/setResolution functions provided by the API


Changelog:
--------------------------------------------------------------------
Until 0.6.4b:
----------------------------------------
- shapes: rect_full,label,labelbox (labelbox=rect_full with referenced label and expanded function range)
- object functions: move, resize, toPosition, setClickEvent, removeClickEvent, setFCol, setBCol, setText, addReference, changeLayer, remove
- object orientation, layer support, dynamic updates, referencing system, clickEvents, global default color system, different ram/screen optimizations


Version 0.7.0b:
----------------------------------------
- added shapes (listing)
- added support for scroll events
- modified shapes to support scroll events (label,labelbox,listing)


