@echo off
title Forever Engine Feather - Start
echo Welcome to the Forever Engine Feather Automatic Setup!
TIMEOUT 3 >nul
echo This will automatically install all of the needed libraries and dependencies for compiling.
TIMEOUT 2 >nul
pause
cls

title Forever Engine Feather Setup - Installing Haxe
echo Time to install Haxe - the open-source toolkit.
TIMEOUT 2 >nul
echo Make sure you download the latest version!
TIMEOUT 2 >nul
echo Redirecting to the Haxe download page...
TIMEOUT 2 >nul
start https://haxe.org/download/
TIMEOUT 4 >nul
echo Press any key to continue once you have finished installing Haxe.
pause >nul
cls

title Forever Engine Feather Setup - Installing HaxeFlixel
echo It is time to install the engine that Funkin' uses - HaxeFlixel.
TIMEOUT 2 >nul
echo Installing Haxeflixel...
haxelib install lime
haxelib install openfl
haxelib install flixel
haxelib run lime setup flixel
haxelib run lime setup
haxelib install flixel-tools
haxelib install flixel-addons
haxelib run flixel-tools setup
TIMEOUT 4 >nul
echo Press any key to continue once you have finished installing HaxeFlixel.
pause >nul
cls

title Forever Engine Feather Setup - Install Git
echo Now, we have to install Git - software for distributed version control.
TIMEOUT 2 >nul
echo Make sure you download the latest version!
TIMEOUT 2 >nul
echo Redirecting to the Git download page...
TIMEOUT 2 >nul
start https://git-scm.com/downloads/
TIMEOUT 4 >nul
echo Press any key to contiue once you have finished installing Git.
pause >nul
cls

title Forever Engine Feather Setup - Installing Additional Libraries
echo After installing Haxe, HaxeFlixel and Git, it is time to install the additional libraries needed for compiling.
TIMEOUT 2 >nul
echo Press any key to install hxcpp-debug-server.
pause >nul
haxelib install hxcpp-debug-server
echo Press any key to install hxCodec.
pause >nul
haxelib git hxCodec https://github.com/polybiusproxy/hxCodec.git
echo Press any key to install SScript.
pause >nul
haxelib git SScript https://github.com/AltronMaxX/SScript
echo Press any key to install discord-rpc.
haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc
pause >nul
echo Press any key to install polymod.
haxelib git polymod https://github.com/MasterEric/polymod
pause >nul
TIMEOUT 4 >nul
echo Press any key to continue with the installation of VSCommunity and its dependencies.
pause >nul
cls

title Forever Engine Feather Setup - Installing Windows Dependencies
echo Moving on from apps and libraries, it is time to install VSCommunity and the dependencies needed for compiling.
TIMEOUT 2 >nul
set /p menu="Would you like to install Visual Studio Community and components? [Y/N]"
       if %menu%==Y goto ProceedWithVSCommunityInstall
       if %menu%==y goto ProceedWithVSCommunityInstall
       if %menu%==N goto SkipVSCommunity
       if %menu%==n goto SkipVSCommunity
       cls

:ProceedWithVSCommunityInstall
title Forever Engine Feather Setup - Installing Windows Dependencies
set /p menu2="For which version of Windows would you like to install Visual Studio Community and components? [10/11]"
        if %menu2%==10 goto InstallVSCommunityWin10
        if %menu2%==11 goto InstallVSCommunityWin11
        cls

:InstallVSCommunityWin10
title Forever Engine Feather - Installing Visual Studio Community and Components (Windows 10)
curl -# -O https://download.visualstudio.microsoft.com/download/pr/5c9aef4f-a79b-4b72-b379-14273860b285/58398a76f32a0149d38fba79bbf71b6084ccd4200ea665bf2bcd954cdc498c7f/vs_Community.exe
vs_Community.exe --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.Windows10SDK.20348
del vs_Community.exe
echo Press any key to complete the setup.
pause >nul
goto SkipVSCommunity

:InstallVSCommunityWin11
title Forever Engine Feather - Instaling Visual Studio Community and Components (Windows 11)
curl -# -O https://download.visualstudio.microsoft.com/download/pr/5c9aef4f-a79b-4b72-b379-14273860b285/58398a76f32a0149d38fba79bbf71b6084ccd4200ea665bf2bcd954cdc498c7f/vs_Community.exe
vs_Community.exe --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.Windows11SDK.22621
del vs_Community.exe
echo Press any key to complete the setup.
pause >nul
goto SkipVSCommunity

:SkipVSCommunity
cls
title Forever Engine Feather Setup - Success
echo Setup successful. Press any key to exit.
pause >nul
exit
