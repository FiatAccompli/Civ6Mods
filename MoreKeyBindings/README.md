# Play the Keyboard: World Navigation v1.0.0

## For users

## For modders

### Keyboard target location control
Whenever the keyboard target plot is changed the following event is raised:

`LuaEvents.WorldNavigation_UpdateKeyboardTargetingPlot(plotX, plotY, implicit)`
* `plotX`, `ployY` are the x and y hex coordinates of the grid
* `implicit` is a boolean indicating the source of the update.  `false` if it was due to user input
  and `true` if the result of programmatic control (e.g. when moved automatically to an available 
  target on entering a UI mode)

If you wish to know the location of the keyboard target register a callback for this event and record the 
last location locally.

To go in the other direction and change the location of the keyboard target programmatically simply raise this event.

### Using keyboard plot selection in custom interface modes
This mod allows other mods to use the keyboard plot selection behavior in interface modes that it does 
not natively support via interaction with a few LuaEvents.  To enable keyboard plot selection 
for your interface mode you will need to:

* Generate an number for the interface mode.  It's recommended to stick with the game's convention that this 
  number is generated from `DB.MakeHash('INTERFACEMODE_WHATVER_YOU_WANT_TO_CALL_IT')`.  So really, just choose 
  some string for 'WHATEVER_YOU_WANT_TO_CALL_IT'.
* Determine when to switch into and out of the interface mode as appropriate by calling UI.SetInterfaceMode.
  This is entirely up to your code.
* Call `LuaEvents.WorldNavigation_RegisterInterfaceModeHandling(interfaceMode, useKeyboardTargeting, restrictedPlotSelection)`
  * `interfaceMode` is the number generated for the interface mode as described previously.
  * `useKeyboardTargeting` should be `true`.  It can be `false`, but that turns off keyboard targeting for the mode, 
    in which case I have to wonder why you're bothering to read this.  I guess it might be useful if you want to
    temporarily turn off targeting for your interface mode.
  * `restrictedPlotSelection` is optional and controls what types of plots can be selected.  If `false` or missing then 
    any plot on the map can be selected.  If `true`, only those plots set by a call to 
    `LuaEvents.WorldNavigation_RegisterSelectablePlots` can be selected.
* Call `LuaEvents.WorldNavigation_RegisterKeyboardTargetDisplaySettings(interfaceMode, icon, disabled)`.  This controls 
  how the keyboard target is disabled onscreen while the UI is in `interfaceMode`.
  * `interfaceMode` is the number generated for the interface mode as described previously.
  * `icon` is the icon that will be displayed in the middle of the keyboard target while the UI is in `interfaceMode`.
    Use `'ICON_MORE_KEY_BINDINGS_NONE'` for an empty icon.
  * `disabled` is optional.  If set to `true` it will disable the display of the keyboard target around the 
    icon while the UI is in `interfaceMode`.  It is *not* recommended to use this since it can be rather confusing
    to users to suddenly have the keyboard target disappear.
* Have a callback registered with `LuaEvents.WorldNavigation_PlotSelected(interfaceMode, plotId)`.  When a plot is selected (either with 
  the mouse or keyboard) this event will be raised.
  * `interfaceMode` is the interfaceMode active when the plot was selected.  If this isn't the interface mode your plugin
    is using you should ignore the event.  If it is the interface mode then proceed to execute whatever action 
    you want to do with the selected plot.
  * `plotId` is the id of the selected plot

