# Input Settings Menu template

This project contains a simple input cistomization interface that can be used for various games made in Godot. UI components purposefully do not require creation of new themes and should be fairly easy to add to a game project by copying the InputSettingsMenu folder to another project

## Basic structure and key classes and scripts

Menu script contains an array of ActionBindingRef instances, each of which should correspond to a configurable action. Each ActionBindingRef instance in turn contains an array for each type of input configuration buttons. These references need to be set for the menu to function correctly

### InputMapConfig class

- Intended to be used as an autoloaded node
- Manages input settings file saving and loading, generally at the launch and closing of the application
- Loads or generates a new settings file regardless of whether the settings menu is opened or not

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
