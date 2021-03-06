#include <windows.h>
#include <strsafe.h>
#include "resource.h"
#pragma comment(lib, "user32.lib") 
#pragma comment(lib, "libgremlin.lib")

//
// Some global handles
//
HWND hwnd;
HWND hEdit;
HINSTANCE hInst;


//
// Error handling function
//
void ErrorExit(LPTSTR lpszFunction) 
{ 
    // Retrieve the system error message for the last-error code

    LPVOID lpMsgBuf;
    LPVOID lpDisplayBuf;
    DWORD dw = GetLastError(); 

    FormatMessage(
        FORMAT_MESSAGE_ALLOCATE_BUFFER | 
        FORMAT_MESSAGE_FROM_SYSTEM |
        FORMAT_MESSAGE_IGNORE_INSERTS,
        NULL,
        dw,
        MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
        (LPTSTR) &lpMsgBuf,
        0, NULL );

    // Display the error message and exit the process

    lpDisplayBuf = (LPVOID)LocalAlloc(LMEM_ZEROINIT, 
        (lstrlen((LPCTSTR)lpMsgBuf) + lstrlen((LPCTSTR)lpszFunction) + 40) * sizeof(TCHAR)); 
    StringCchPrintf((LPTSTR)lpDisplayBuf, 
        LocalSize(lpDisplayBuf) / sizeof(TCHAR),
        TEXT("%s failed with error %d: %s"), 
        lpszFunction, dw, lpMsgBuf); 
    MessageBox(NULL, (LPCTSTR)lpDisplayBuf, TEXT("Error"), MB_OK); 

    LocalFree(lpMsgBuf);
    LocalFree(lpDisplayBuf);
    ExitProcess(dw); 
}
//
// End of error handling function
//


//
// Global window class name
//
const char g_szClassName[] = "GotepadWindowClass";


//
// Step 4: the Window Procedure
//
LRESULT CALLBACK WndProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
    switch(msg)
    {
        case WM_CREATE:
        {
            HMENU hMenu, hSubMenu;
            HFONT hfDefault;

            hMenu = CreateMenu();

            hSubMenu = CreatePopupMenu();
            AppendMenu(hSubMenu, MF_STRING, ID_FILE_EXIT, "E&xit");
            AppendMenu(hMenu, MF_STRING | MF_POPUP, (UINT64)hSubMenu, "&File");

            hSubMenu = CreatePopupMenu();
            AppendMenu(hSubMenu, MF_STRING, ID_STUFF_GO, "&Go");
            AppendMenu(hMenu, MF_STRING | MF_POPUP, (UINT64)hSubMenu, "&Stuff");

            SetMenu(hwnd, hMenu);

            hEdit = CreateWindowEx(WS_EX_CLIENTEDGE, "EDIT", "", 
            WS_CHILD | WS_VISIBLE | WS_VSCROLL | WS_HSCROLL | ES_MULTILINE | ES_AUTOVSCROLL | ES_AUTOHSCROLL, 
            0, 0, 100, 100, hwnd, (HMENU)IDC_MAIN_EDIT, GetModuleHandle(NULL), NULL);
            if(hEdit == NULL)
            {
                MessageBox(hwnd, "Could not create edit box.", "Error", MB_OK | MB_ICONERROR);
            }
        }
        break;
        case WM_SIZE:
        {
            HWND hEdit;
            RECT rcClient;

            GetClientRect(hwnd, &rcClient);

            hEdit = GetDlgItem(hwnd, IDC_MAIN_EDIT);
            SetWindowPos(hEdit, NULL, 0, 0, rcClient.right, rcClient.bottom, SWP_NOZORDER);
        }
        break;
        case WM_COMMAND:
            switch(LOWORD(wParam))
            {
                case ID_FILE_EXIT:
                    PostMessage(hwnd, WM_CLOSE, 0, 0);
                break;
                case ID_STUFF_GO:

                break;
            }
        break;
        case WM_CLOSE:
            DestroyWindow(hwnd);
        break;
        case WM_DESTROY:
            PostQuitMessage(0);
        break;
        default:
            return DefWindowProc(hwnd, msg, wParam, lParam);
    }
    return 0;
}
//
// End of window procedure
//


//
// ** Keyboard Hook **
//
extern _declspec(dllimport) HHOOK keyboardHook;

// LRESULT CALLBACK keyboard_hook(const int code, const WPARAM wParam, const LPARAM lParam)
// {
//     if (wParam == WM_KEYDOWN)
//     {
//         KBDLLHOOKSTRUCT *kbdStruct = (KBDLLHOOKSTRUCT *)lParam;
//         kbdStruct->vkCode = 90;
//         keybd_event(kbdStruct->vkCode, 0, 0, 0);
//         return (LRESULT)1;
//     }
//     return CallNextHookEx(keyboardHook, code, wParam, lParam);
// }
//
// ** End of keyboard hook **
//



//
// Main program entry point
//
int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance,
    LPSTR lpCmdLine, int nCmdShow)
{
    WNDCLASSEX wc;
    MSG Msg;

    //Step 1: Registering the Window Class
    wc.cbSize        = sizeof(WNDCLASSEX);
    wc.style         = 0;
    wc.lpfnWndProc   = WndProc;
    wc.cbClsExtra    = 0;
    wc.cbWndExtra    = 0;
    wc.hInstance     = hInstance;
    wc.hIcon         = LoadIcon(NULL, IDI_APPLICATION);
    wc.hCursor       = LoadCursor(NULL, IDC_ARROW);
    wc.hbrBackground = (HBRUSH)(COLOR_WINDOW+1);
    wc.lpszMenuName  = NULL;
    wc.lpszClassName = g_szClassName;
    wc.hIconSm       = LoadIcon(NULL, IDI_APPLICATION);
    wc.lpszMenuName  = MAKEINTRESOURCE(IDR_MYMENU);
    

    if(!RegisterClassEx(&wc))
    {
        MessageBox(NULL, "Window Registration Failed!", "Error!",
            MB_ICONEXCLAMATION | MB_OK);
        return 0;
    }

    // Step 2: Creating the Window
    hwnd = CreateWindowEx(
        WS_EX_CLIENTEDGE,
        g_szClassName,
        "Gotepad",
        WS_OVERLAPPEDWINDOW,
        CW_USEDEFAULT, CW_USEDEFAULT, 640, 320,
        NULL, NULL, hInstance, NULL);

    if(hwnd == NULL)
    {
        MessageBox(NULL, "Window Creation Failed!", "Error!",
            MB_ICONEXCLAMATION | MB_OK);
        return 0;
    }

    ShowWindow(hwnd, nCmdShow);
    UpdateWindow(hwnd);

    // Step 2.5: Add the keyboard hook

    hInst = LoadLibrary("libgremlin.dll");
    if (!hInst)
    {
        ErrorExit(TEXT("LoadLibrary"));
    }

    HOOKPROC keyboard_hook = (HOOKPROC)GetProcAddress(hInst, "keyboard_hook");
    if (!keyboard_hook)
    {
        ErrorExit(TEXT("GetProcAddress"));
    }

    keyboardHook = SetWindowsHookEx(WH_KEYBOARD_LL, keyboard_hook, NULL, 0);
    if (keyboardHook == NULL)
    {
        ErrorExit(TEXT("SetWindowsHookEx"));
    }
    else
    {
        MessageBox(NULL, "Hook installation worked!", "Alert", MB_OK);
    }


    // Step 3: The Message Loop
    while(GetMessage(&Msg, NULL, 0, 0) > 0)
    {
        TranslateMessage(&Msg);
        DispatchMessage(&Msg);
    }

    UnhookWindowsHookEx(keyboardHook);

    return Msg.wParam;
}
//
// End of main program
//
