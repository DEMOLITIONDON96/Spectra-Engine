package base.system;

/*
Code Has Been Done By Chromasen And Erizur For Dave And Bambi.
*/

#if windows
@:cppFileCode('#include <stdlib.h>
#include <stdio.h>
#include <windows.h>
#include <winuser.h>
#include <dwmapi.h>
#include <strsafe.h>
#include <shellapi.h>
#include <iostream>
#include <string>

#pragma comment(lib, "Dwmapi")
#pragma comment(lib, "Shell32.lib")')
#elseif linux
@:cppFileCode('
#include <stdlib.h>
#include <stdio.h>
#include <iostream>
#include <string>
')
#end
class WindowsSystem
{
    #if windows
    @:functionCode('
        NOTIFYICONDATA m_NID;

        memset(&m_NID, 0, sizeof(m_NID));
        m_NID.cbSize = sizeof(m_NID);
        m_NID.hWnd = GetForegroundWindow();
        m_NID.uFlags = NIF_MESSAGE | NIIF_WARNING | NIS_HIDDEN;

        m_NID.uVersion = NOTIFYICON_VERSION_4;

        if (!Shell_NotifyIcon(NIM_ADD, &m_NID))
            return FALSE;
    
        Shell_NotifyIcon(NIM_SETVERSION, &m_NID);

        m_NID.uFlags |= NIF_INFO;
        m_NID.uTimeout = 1000;
        m_NID.dwInfoFlags = NULL;

        LPCTSTR lTitle = title.c_str();
        LPCTSTR lDesc = desc.c_str();

        if (StringCchCopy(m_NID.szInfoTitle, sizeof(m_NID.szInfoTitle), lTitle) != S_OK)
            return FALSE;

        if (StringCchCopy(m_NID.szInfo, sizeof(m_NID.szInfo), lDesc) != S_OK)
            return FALSE;

        return Shell_NotifyIcon(NIM_MODIFY, &m_NID);
    ')
    #elseif linux
    @:functionCode('
        std::string cmd = "notify-send -u normal \'";
        cmd += title.c_str();
        cmd += "\' \'";
        cmd += desc.c_str();
        cmd += "\'";
        system(cmd.c_str());
    ')
    #end
    static public function sendNotification(title:String = "", desc:String = "", res:Int = 0)    // TODO: Linux (found out how to do it so ill do it soon)
    {
        return res;
    }
}