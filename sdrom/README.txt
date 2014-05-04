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
 
2.3b (Dave)

Version: SDDOS V2.3E

Fixed a bug with *MENU not working after a cold boot
(due to $9E not being initialized, only affected AtomFPGA because RAM as a different init value)

See http://www.stardot.org.uk/forums/viewtopic.php?f=44&t=6313&start=60#p73347
