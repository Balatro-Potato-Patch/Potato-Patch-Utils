# Potato-Patch-Utils
A util library for mods created by the Potato Patch with the explicit intent of being used for events run by the group

## What functionality does this mod add?

### Automatic File Loading
`PotatoPatchUtils.load_files(path, mod_id, blacklist)`
Will automatically load all `.lua` files within the passed in `path` (will typically be `SMODS.current_mod.path`)
- `path` (string) [REQUIRED] - The file path the file loader will start at. Will automatically open folders and load files within them as well
- `mod_id` (string) [REQUIRED] - The ID of the mod whose files are being loaded. Is used to display correct mod ID in the event of a crash
- `blacklist` (table) - A table of strings of file names that should be ignored on file loading (file extension, i.e. `.lua` must be included)

### Developer and Team objects
These objects are used for credits and calculating contexts outside of a traditional game object
`PotatoPatchutils.Team(args)`
`args` is a table of the following values:
- `name` (string) [REQUIRED] - The name of the Team
- `colour` (hex) - The Team name's text fill color
- `loc` (string/boolean) - Assigns the Team's display name to a localization key of your choosing. Will be assigned to `'PotatoPatchTeam_' .. args.name` if a boolean is passed
- `calculate` (function(self, context)) - A traditional calculate function, much like global mod calculate from Steamodded

`PotatoPatchutils.Developer(args)`
`args` is a table of the following values:
- `name` (string) [REQUIRED] - The name of the Developer
- `colour` (hex) - The Developer name's text fill color
- `loc` (string/boolean) - Assigns the Developer's display name to a localization key of your choosing. Will be assigned to `'PotatoPatchDev_' .. args.name` if a boolean is passed
- `calculate` (function(self, context)) - A traditional calculate function, much like global mod calculate from Steamodded
- `team` (string) - The name of the Team the Developer is a part of

### Credits
Adding these values to a game object will automatically add Credits to whoever is specified in the object's description box. The format should look something like this: `ppu_artist = {'Artist1', 'Artist2'}`

If the name of a Developer or Team object are used, the text will use the specified colour of the associated object. For example, if Developer `'Eremel'` exists with a `colour` property and a Joker contains `ppu_coder = {'Eremel'}`, the text will be coloured in with Eremel's defined `colour` property 
- `ppu_artist` (table) - The artist(s) of the Game Object
- `ppu_coder` (table) - The coders(s) of the Game Object
- `ppu_team` (table) - The team the Game Object was created for

### Localization Loading
This feature allows for multiple localization `.lua` files to be used in one project. This allows for much easier handling of localization files in collaborative efforts

`PotatoPatchUtils.LOC.process_loc_text(locPath, mod_id)`
- `locPath` (string) [REQUIRED] - A string of the path leading to the root localization folder
- `mod_id` (string)  [REQUIRED] - The ID of the mod whose files are being loaded. Is used to properly attribute the file to the mod
- 
Creating a folder within the localization folder that has a name that matches a valid localization code will be loaded automatically after running this function

<img width="132" height="91" alt="image" src="https://github.com/user-attachments/assets/742d5d25-a19f-45e8-ba5c-53727c72b01a" />

### Info Menu
