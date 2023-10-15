# Input Settings Menu and configuration template, WIP

This project contains a simple input customization interface that can be used for various games made in Godot. UI components purposefully do not require creation of new themes and should be fairly easy to add to a game project by copying the **InputSettingsMenu folder** to another project, and then modifying as desired.

Made with and for Godot game engine, <https://godotengine.org/license>

## Currently implemented features overview

- Input configuration script, intended to be autoloaded as `CustomInputConfig`
- Buttons for setting keyboard, mouse button and controller buttons
- A script for bundling buttons that manage the same input
- A menu script that sets up button variables, can call configuration script to restore defaults and potentially switch tabs for types of inputs

The menu is primarily intended to be used with a mouse. At the moment I don't have a controller to test it with, but that is something I would like to refine and test at some point.

Menu example scene is almost certainly insufficient for a game, and is intended to serve as an example structure. Feel free to derive a more robust menu from it or build you own.

TODO:

- Implement and / or test keyboard only and controller only usage
- Add a functionality (tool script?) to easily set up button references

## Basic structure and key classes and scripts

Menu script contains an array of `ActionBindingRef` instances, each of which should correspond to a configurable action. Each `ActionBindingRef` instance in turn contains an array for each type of input configuration buttons. These references need to be set for the menu to function correctly

In the current implementation, input customization buttons are selected / activated to read an input with left mouse button and bindings are reset by clicking the customization button with the right mouse button.

Default input settings are assumed to be those set in project settings. This could be changed by altering the functions that generate initial configuration file and reset defaults, see `InputMapConfig` section below.

### `InputMapConfig` class

- Intended to be used as an autoloaded node
- Manages input settings file saving and loading, generally at the launch and closing of the application
- Loads or generates a new settings file regardless of whether the settings menu is opened or not

Because this class is separate from the settings menu, it will not automatically know which actions can be configured. By default, it includes all non-built-in actions in the `ConfigFile` object and actual file.

*Non-built-in actions are added to the end of the list in InputMap, and can be obtained by retrieveing the list of actions from `InputMap`, and getting the slice from index 76 to the end: `InputMap.get_actions().slice(76)`*

#### `initialize()` -method
  
Called in `_ready()` by default, but could be called at any point to either load contents of the configuration file into a `ConfigFile` object, if a file exists, or generate `ConfigFile` object from project settings' default InputMap state

### Button scripts

Buttons read appropriate inputs when pressed / selected, and assign them to InputMap singleton.

Different button scripts and scenes for:

- Keyboard keys, with modifier keys (e.g. Ctrl, Shift)
- Mouse buttons, with keyboard key modifiers, same as for keyboard key options
- Controller inputs, without modifiers

### `ActionBindingRef`

A "bundling" script for grouping buttons that manage the same action.

Instances contain references to input customization buttons for one specific action, with a separate array for each type:

- `kb_binding_buttons`
- `ms_binding_buttons`
- `ct_binding_buttons`

This script can also run a preliminary check to see if buttons for same action have same binding, when receiving a `input_set_preliminary(button)` signal from a button.

- Signals are connected automatically from managed buttons to the function `check_overlap(button: InputSettingsButton)`
- Removes older event setting to trim duplicates: setting keyboard option 2 to same as 1 will clear 1, efeectively moving the setting from 1 to 2

The node used by default is a Label that should display the action / binding name to the user. However, none of the Label functionalities are required for the script to work, so this could well be changed to, for example, RichTextLabel, or something else entirely, but parts of the script would need to be modified or removed.

### Menu script

Manages the general menu functionalities:

- Initializes `ActionBindingRef` instances' buttons based on input settings
- Checks for conflicting input events / events used for more than one action
  - Signal `input_set(button)` is connected from all buttons automatically to `_check_input_conflicts(button: InputSettingsButton)`
- Can change tabs, more specifically changing the visibility of nodes
  - Signals from (tab) buttons need to be connected manually to `_on_tab_changed(tab: int)` and tab nodes must be added to the exposed `all_tabs` array
- Has a function to call autoloaded InputMapConfig instance's function to restore defaults and update buttons
