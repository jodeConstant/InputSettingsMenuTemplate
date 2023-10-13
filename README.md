# Input Settings Menu and configuration template, WIP

This project contains a simple input cistomization interface that can be used for various games made in Godot. UI components purposefully do not require creation of new themes and should be fairly easy to add to a game project by copying the InputSettingsMenu folder to another project.

## Currently implemented features

- Configuration script that can:
  - Save and load input settings to/from a file
  - Restore defaults from prject settings
- Buttons for setting inputs:
  - 3 types, for keyboard, moouse with certain keyboard keys and controller
- Menu script that can:
  - Set up button variables / data
  - Check for conflicting input events between actions
  - Switch tabs, by setting visibility
  - Signal input configuration script to restore defaults

The menu is primarily intended to be used with a mouse. At the moment I don't have a controller to test it with, but that is something I would like to refine and test at some point.

TODO:

- Implement and / or test keyboard only and controller only usage

## Basic structure and key classes and scripts

Menu script contains an array of ActionBindingRef instances, each of which should correspond to a configurable action. Each ActionBindingRef instance in turn contains an array for each type of input configuration buttons. These references need to be set for the menu to function correctly

In the current implementation, input customization buttons are selected / activated to read an input with left mouse button and bindings are reset by clicking the customization button with the right mouse button.

### InputMapConfig class

- Intended to be used as an autoloaded node
- Manages input settings file saving and loading, generally at the launch and closing of the application
- Loads or generates a new settings file regardless of whether the settings menu is opened or not

Because this class is separate from the settings menu, it will not automatically know which actions can be configured. By default, it includes all non-built-in actions in the `ConfigFile` object and actual file.

*Non-built-in actions are added to the end of the list in InputMap, and can be obtained by retrieveing the list of actions from `InputMap`, and getting the slice from index 76 to the end: `InputMap.get_actions().slice(76)`*

#### `configure()` -method
  
- Called in `_ready()`, and can be called at any point to either load contents of the configuration file into a ConfigFile object, or generate ConfigFile object from project settings' default InputMap state

### Menu script

- Initializes buttons based on input settings
- Checks for conflicting input events / events used for more than one action

### Button scripts

- Read appropriate inputs when pressed selected, and assign them to InputMap singleton
- Different button scripts and scenes for:
  - Keyboard keys, with modifier keys (e.g. Ctrl, Shift)
  - Mouse buttons, with keyboard key modifiers
  - Controller inputs, without modifiers

### ActionBindingRef

- Contains references to input customization buttons for one specific action
  - An individual array for each type
