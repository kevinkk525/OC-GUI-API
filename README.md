# OC-GUI-API

This readme will get updated soon and a short wiki will follow...

To use the API just drop the files GUI.lua and shapes_default.lua to your preffered lib folder e.g. /lib/
To see the tech_demo put the tech_demo.lua anywhere and run it (at the moment it does not demonstrate all features).

You can read more update it and its features here: http://oc.cil.li/index.php?/topic/580-gui-api-064beta


Changelog:
--------------------------------------------------------------------


Version 0.7.0b:
----------------------------------------
- added shapes (listing)
- added support for scroll events
- modified shapes to support scroll events (label,labelbox,listing)

Until 0.6.4b:
----------------------------------------
- shapes: rect_full,label,labelbox (labelbox=rect_full with referenced label and expanded function range)
- object functions: move, resize, toPosition, setClickEvent, removeClickEvent, setFCol, setBCol, setText, addReference, changeLayer, remove
- object orientation, layer support, dynamic updates, referencing system, clickEvents, global default color system, different ram/screen optimizations
