# Mod Settings Manager v1.0.0

## Overview

Provides an easy way for other mods to declare user configurable settings and provides a ui for the user to change setting values. 
Setting values are persisted within game saves and if the user desires it is (relatively) easy to set a global default that applies across 
all saves.

## For Users

Mod Settings Manager adds a fairly standard looking "options" pinwheel to the "toolbar" above the minimap.  
When clicked this will bring up the settings popup that allows you to change all settings declared by other mods.  
When you have changed the settings use the "Confirm" button at the bottom to lock in the changes 
(if you press ESC or the back button at the upper right) the changes will be reverted.

### Saving settings as the default for all games.

To make the current settings the default for all games, click the "Show Saveable Config" button at the bottom left of the settings popup.  Follow the instructions it provides.

## For Modders

To use Mod Settings Manager in other mods:

1. Add a dependency to your mod on Mod Settings Manager.  In Modbuddy go to Project Settings > Associations > Dependencies > Add Mod.  Use Title = "Mod Settings Manager" and Id = "1cb1beaf-0428-4aad-b11d-e3168429c071". If you're authoring the .modinfo by hand, then add the following within the root `Mod` element
```
  <Dependencies>
    <Mod id="1cb1beaf-0428-4aad-b11d-e3168429c071" title="Mod Settings Manager" />
  </Dependencies>
```

  This causes 

2. In whichever lua files you want to use settings include the settings api
```
include ("ModSettings")
```
and contruct the settings you want

For an example mod that makes use of settings, see [Mod Settings Example](../SettingsManagerExample)

### Common Settings Api

#### Members
* `Value` - This is how the current value of the setting is accessed by your mod code.

#### Constructor arguments
* `categoryName` - A localizable string that provides the name of the settings tab within the ui.  It is recommended that this be similar to the mod name and that all settings in a mod use the same category.  (If there are a lot of settings in a mod it may be reasonable to split them up into multiple categories.)
* `settingName` - A localizable string that provides the name of the individual setting within the ui.  All setting names must be unique.  If two settings use the same categoryName/settingName pair then the ui assumes they are the same and will only show one of them in the ui.  (And if they don't have the same definition (type, defaultValue, etc.) then bad things will likely happen.)
* `tooltip` - A localizable string that is used as a tooltip for the setting.  For example, to provide more details about how the individual select items behave.  `nil` is a valid value if the setting name is sufficiently explanatory.
* `onChanged` - A function that is called when the setting `Value` is changed by the ui.

### Setting Types

* Boolean - A simple true/false value

  ```
  setting = ModSettings.Boolean:new(defaultValue, categoryName, settingName, tooltip, onChanged)
  ```

  * `defaultValue` should be either true or false

* Selection - Allows the user to choose the setting value from a provided list of possible values.

  ```
  setting = ModSettings.Select:new(values, defaultIndex, categoryName, settingName, tooltip, onChanged)
  ```

  * `values` is a lua array of the values the user can select.  Each item is treated as a localizable string for display.
  * `defaultIndex` is the index of the item within `values` that should be used as the setting default.

  The `Value` of the setting is one of the strings in the `values` array.
  
* Range - Allows the user to choose any value within a [min, max] range.
May be configured so that only regularly spaced values within the range are chooseable.

  ```
  setting = ModSettings.Range:new(defaultValue, min, max, steps, 
      categoryName, settingName, tooltip, onChanged, valueFormatter)
  ```
  
  * `defaultValue` should be a number within [min, max].
  * `min` and `max` define the limits of the range the user can select
  * `steps` restricts which values the user can select within the [min, max] range.  
  If `nil` the setting is continuous and the user can freely select any value in the range.  
  Otherwise it should be a positive integer and the range [min, max] is broken into `steps` chunks such that the only user selectable values are `min + (max - min) / steps * k` for `k` in [0, steps].
  * `valueFormatter` is a localizable string that defines how to format the current value to give ui feedback.  A reasonable default is provided if this is `nil`.

* Text - Allows the user to provide free-form text as the setting value.
  ```
  setting = ModSettings.Text:new(defaultValue, categoryName, settingName, tooltip, onChanged)
  ```
  * `defaultValue` should be a string