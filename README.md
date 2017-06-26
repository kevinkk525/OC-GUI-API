# OC-GUI-API

This prjoect won't get any updates, I'm sorry. If you think it is usefull, feel free to do with it as you wish.

To use the API just drop the files GUI.lua, shapes_default.lua and term_mod.lua to your preffered lib folder e.g. /lib/

To see the tech_demo put the tech_demo.lua anywhere and run it (at the moment it does not demonstrate all features).

You can read more update it and its features here: http://oc.cil.li/index.php?/topic/580-gui-api-064beta


Changelog:
--------------------------------------------------------------------

Version 0.7.3b (August 11):
----------------------------------------
- code changes to remove redundancy and minimize code lines
- minor bugfixes


Version 0.7.2b (June 15):
----------------------------------------
- added a textbox shape (finally an input method)
- several bugfixes for listings and labels and scrolling feature
- added a file with modified term.read function preventing shifts in input line and supporting color system.
- new feature: configure color per line in listing shape


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
