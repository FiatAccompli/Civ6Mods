# UI Plugins Framework v1.0.0

## Overview
Adds ways for other mods to easily add UI elements to parts of the in-game UI without needing 
to overwrite the base game UI files. This makes other mods simpler and reduces the chances they 
are incompatible with one another.

## For Users

### Installation
* [Steam workshop]()
* [Manual install](https://github.com/FiatAccompli/Civ6Mods/releases)

## For Modders
Currently this mod supports two types of plugin points.
* Addition of toolbar buttons
* Addition of arbitrary panels in elements of the UI.

![Example Image](Documentation/UIPluginsExamples.jpg)

Buttons can be added to the:
* Launch bar ("toolbar" at top left with tech/civic/government/etc buttons).
* Partial screen bar ("toolbar" at top right with city states/trade routes/etc buttons).
* Minimap bar ("toolbar" at bottom left above minimap with lenses/strategy view/map tack/etc buttons).

### Panel plugin points
Panels can be added to the:
* Top panel
* World tracker

Additionally two additional plugin points for full-screen "panels" are provided that allow mods to 
add arbitrary UI at different points in the z-axis hierarachy of controls.

Panels are added to the game through an `AddUserInterface` within the `.modinfo` file, exactly
the same as adding a normal mod user interface.  Rather than using a `Context` of `InGame` the 
following values are used in place of `InGame`.
* `InGame_Screen` - Adds a context within the `Screens` element of `InGame`.
  Which means it is (on the z-axis) below the launch bar and a few other parts of the ui 
  such as popups.
* `InGame_PartialScreen` - Adds a context within the `PartialScreens` element of `InGame`.
  Which means it is (on the z-axis) below the partial screen toolbar as well as the launch 
  bar and a few other top-level ui elements (e.g. popups).
* `InGame_TopPanel` - Adds a custom panel to the info bar at the top of the screen (the one 
  that contains overall civilization yields and some other things).
* `InGame_WorldTracker` - Adds a custom panel within the world tracker.

In the case of `InGame_TopPanel` and `InGame_WorldTracker` plugin points it is necessary to
explicitly control the size of the top-level control (`ContextPtr` in lua code) as it 
seems that `Size` settings in the xml have no effect and auto-siz

* `InGame_TopPanel` plugins should use a height of 25 pixels and arbitrary width.
* `InGame_WorldTracker` plugins should use a width of 292 pixels and arbitrary height (should be
  >=22 or the expander icon will overlap weirdly.

`InGame_WorldTracker` plugins should also specify a `Name="something"` on the top-level 
`Context` element in the UI xml file. This string (after localization) is used the name of 
the panel when it is collapsed (and also the name of the panel in t

### Button plugin points
For each type of button there are 3 events that you need to interact with 
* `TYPE_RegisterAdditions` - Event notified when it is appropriate to register custom
  buttons with the toolbar.
* `TYPE_AddButton` - Event you call to add a custom button passing as an argument
  a specification for the button.
* `TYPE_CustomButtonClicked` - Event notified when a custom button is clicked to which 
  your code reacts and takes whatever action you desire.

#### Launch bar button events
* `LuaEvents.LaunchBar_RegisterAdditions()`
* `LuaEvents.LaunchBar_AddButton(buttonInfo)` - `buttonInfo` is a table that supports the 
  following properties.
  * `Id` - A string used to identify the button.
  * `IconTexture` - Table containing the specification for the icon to be displayed in the button.
    * `Sheet` - String name of a texture to use as the button icon.
    * `OffsetX`, `OffsetY` - Optional texture offsets.
    * `Icon` - String name of the icon to be used for the button.  An alternative to using `Sheet`.
    * `Color` - Optional foreground color for the icon/texture.
  * `BaseTexture`- Table containing the specification for the backgound of the button
    * `Sheet` - String name of a texture to use for the background.  Should probably be 
      one of the "LaunchBar_Hook_XXX" textures from the pantry unless you're really motivated 
      to draw a custom one.
    * `OffsetX`, `OffsetY` - Optional texture offsets.
    * `HoverOffsetX`, `HoverOffsetY` - Optional texture offsets when moused-over.
  * `Tooltip` - Optional tooltip for the button.
* `LuaEvents.LaunchBar_CustomButtonClicked(id)` - Event notified when a custom button is clicked.
  Id is the identifier from the specification used to construct the button.

Launch bar buttons are generally intended to launch mutually exclusive full-screen UI.
To support this standard use case a couple of extra events are involved.  (If using a launch 
bar button for a different purpose you don't need to interact with these.)
* `LuaEvents.LaunchBar_CloseAllExcept(id)` - Notified whenever a launchbar screen 
  is toggled on.  If the id of your custom screen is not the `id` argument then you should 
  close your screen (if it is open).
* `LuaEvents.LaunchBar_EnsureExclusive(id)` - If you open your launch bar screen through a method 
  other than via a click of the launch bar button (such as through a hotkey) then you should 
  invoke this event to ensure that all other launch bar screens are closed.

#### Partial Screen 