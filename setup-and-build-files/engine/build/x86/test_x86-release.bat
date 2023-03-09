@echo off
color 0a
title FNF: Forever Engine Feather - Running Game (RELEASE MODE)
cd ..
cd ..
cd ..
echo BUILDING...
haxelib run lime test windows -release -D HXCPP_M32
echo.
echo DONE.
pause