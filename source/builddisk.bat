@echo off
echo Exomizing files...
del *.bak
exomizer sfx sys retaliate-ce.prg -o retaliate-sfx.prg -x3
ren ret-en.prg ret-en.bak
ren retaliate-sfx.prg ret-en.prg

echo Building disk...
mkdir disk
mkd64 -odisk\retaliatece.d64 -mcbmdos -d"RETALIATE-CE" -fretaliate.prg -n"RETALIATE" -w -fret-en.prg -n"RET-EN" -w -fretdata.prg -n"RETDATA" -w
