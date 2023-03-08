# NightHawk - Time Tracking for NeoVim

## INTRODUCTION

[//]: # "@todo Remove following sentence with the first release of Nighthawk" 

WORK IN PROGRESS. FIRST VERSION IS STILL NOT FINALIZED.

NightHawk is a plugin for NeoVim on UNIX based operating systems that lets 
the editor track how much time is spend editing individual files.

The plugin exposes Lua functions that accumulate that information for all
files in a directory tree and provide the basis to track the time that was
spend on working in different workspaces or for different projects.

Those and other service functions can be used in other plugins (e.g. Neo-Tree)
to visualize the information or to use it to create project reports or fill
out time cards.

## Functionality

NightHawk observes activities  of Vim buffers and  as long as the  user is not
idle for a longer  period of time it will accumulate  and remember the editing
time for files that belongs to corresponding buffers.

Time  spend on  buffers that  have no  file attached  (e.g. Neo-Tree,  Tagbar,
Terminal, ...) will also be tracked  and automatically be added to the numbers
of the last file worked on.

Filenames and accumulated work time will be stored in a  SQLite database which
will  preserve  the data  even  if  no  NeoVim  instance is  active.  Multiple
instances of NeoVim will all store the data in one database.

Stored data of the database can be deleted with NeoVim commands  as soon as it
is not required anymore.

## Installation


## Further Documentation

Nighthawk's  documentation  is available  through  Vim's  help. Use  following
command to access it:

    :help nighthawk

FAQ's  and information  about issues  or current  activities of  the Nighthawk
project can be found in

    https://github.com/ernst-bablick/nighthawk/wiki

## License

MIT License

Copyright (c) 2022-2023 Ernst Bablick

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
