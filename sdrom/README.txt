ChangeLog
---------

2.2 (Kees)

Version: SDDOS V2.2(C)KC

Original version, 18th March 2010

2.3 (Kees)

Version: SDDOS V2.3E (C)KC

Addressed at #E000 and to boot like AtomMMC does, using patched Kernel
(earlier versions were #A000 Utility ROMS)

2.3a (Kees)

Version: SDDOS V2.3E

Removed old SDDOS initialization command
(not needed, to save space)

Removed *COS and *DOS commands
(to save space)

Implemented Shift-BREAK
(this temporarily patches OSRDCH to inject *MENU)

Fixed a bug in *RUN and *<filename> which could cause a hang
(copy_params, $0D instead of #$0D beging checked as terminator)
 
