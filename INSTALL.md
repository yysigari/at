AT Installation
---------------

The AT code in this repository evolved from version 1.3 of the original code
and is now maintained by the 'atcollab' collaboration, involving people from
different research institutes.

The latest release can be found [on Github](https://github.com/atcollab/at/releases).

Installation process:

1. install git on your computer

2. download the latest version of AT

    `$ git clone https://github.com/atcollab/at.git`

3. start Matlab

4. Put the directories at/atmat and at/integrators in your Matlab path.  
Using Matlab graphical interface:  
`"Set path"` button, `"Add with Subfolders"` and select `atmat`  
Repeat for `atintegrators`

5. Compile all mexfunctions

    `>> atmexall`

6. Update helpfiles

    `>> atupdateContents`

You can now use `athelp` to list all main functions

7. Update html doc - not yet documented.
