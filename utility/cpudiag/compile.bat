for %%I in (.) do set target=%%~nxI
echo %target%
retroassembler -x %target%.8080.asm
del ..\%target%.com
move %target%.bin ..\%target%.com
