@echo off
echo Exomizing files...
.\tools\exomizer sfx sys out\retaliate-ce.prg -o out\ret-en.prg -x3

echo Building disk...
mkdir release
.\tools\mkd64 -orelease\retaliatece.d64 -mcbmdos -d"RETALIATE-CE" -fout\retaliate.prg -n"RETALIATE" -w -fout\ret-en.prg -n"RET-EN" -w -fout\retdata.prg -n"RETDATA" -w
