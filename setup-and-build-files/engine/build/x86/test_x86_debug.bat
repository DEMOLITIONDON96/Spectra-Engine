@echo off
color 0a
title FNF: Forever Engine Feather - Running Game (DEBUG MODE)
cd ..
cd ..
cd ..
echo BUILDING...
haxelib run lime test windows -debug -D HXCPP_M32
echo. 
echo DONE
pause