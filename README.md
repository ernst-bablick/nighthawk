# NightHawk - Time Tracking for NeoVim

## Summary

[//]: # "@todo Move text sections than can be used for multiple parts of documentation"

[//]: # "@todo Remove following sentence with the first release of Nighthawk" 

WORK IN PROGRESS. FIRST VERSION IS STILL NOT FINALIZED.

NightHawk is a NeoVim plugin that lets the editor track how much time is spend
editing individual files.

The  plugin exposes  Lua functions  that accumulate  that time  for all
files in  a directory tree and  provide the basis  to track the time  that was
spend on working in different workspaces or for different projects.

Service functions can be used in other plugins (e.g. Neo-Tree)
to visualize the  information per node in a directory tree or the 
information can directly be used by people to create project  reports or fill
out time cards.

## How does it work?

NightHawk observes activities  of Vim buffers and  as long as the  user is not
idle for a longer  period of time it will accumulate  and remember the editing
time for files that belongs to corresponding buffers.

Time  spend on  buffers that  have no  file attached  (e.g. Neo-Tree,  Tagbar,
Terminal, ...) will also be tracked  and automatically be added to the numbers
of the last file worked on.

The editing time is collected with second granularity and stored in a sqlite database.

## How can this plugin be installed?

The plugin is available through Github.

```
git clone https://github.com/ernst-bablick/nighthawk
```

It depends on a SQLite/LuaJIT plugin that is also available as plugin for NeoVim

```
git clone https://github.com/kkharji/sqlite.lua
```

Either install the plugins manually, use your  favorite package manager, or  use Vim's
built-in package support.

## Where can more information be found?

Nighthawk's  documentation  is available  through  Vim's  help. Use  following
command to access it:

```
:help nighthawk
```

FAQ's  and information  about issues  or current  activities of  the Nighthawk
project can be found in

[GitHub's Wiki for Nighthawk](https://github.com/ernst-bablick/nighthawk/wiki).

## License

Copyright (c) 2022-2023 Ernst Bablick

For details have a look it the LICENSE file.
