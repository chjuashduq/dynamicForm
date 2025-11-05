#include "mainwindow.h"

#include <QApplication>
#include <QLocale>
#include <QLoggingCategory>
#include <QDebug>
#include <iostream>
#include <QQmlDebuggingEnabler>

#ifdef _WIN32
#include <windows.h>
#include <io.h>
#include <fcntl.h>
#endif

using namespace std;

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    // ✅ 启用 QML 调试
    QQmlDebuggingEnabler::enableDebugging(true);
    // 启用所有Qt日志输出
    QLoggingCategory::setFilterRules("*=true");
    
    // 设置中文编码支持 (Qt 6方式)
    #ifdef _WIN32
        // Windows下分配控制台
        if (AllocConsole()) {
            freopen_s((FILE**)stdout, "CONOUT$", "w", stdout);
            freopen_s((FILE**)stderr, "CONOUT$", "w", stderr);
            freopen_s((FILE**)stdin, "CONIN$", "r", stdin);
            
            // 设置控制台标题
            SetConsoleTitleA("Dynamic Form QML Debug Console");
        }
        
        // Windows下设置控制台UTF-8支持
        SetConsoleOutputCP(CP_UTF8);
        SetConsoleCP(CP_UTF8);
        
        // 设置控制台字体为支持中文的字体
        CONSOLE_FONT_INFOEX cfi;
        cfi.cbSize = sizeof(cfi);
        cfi.nFont = 0;
        cfi.dwFontSize.X = 0;
        cfi.dwFontSize.Y = 16;
        cfi.FontFamily = FF_DONTCARE;
        cfi.FontWeight = FW_NORMAL;
        wcscpy_s(cfi.FaceName, L"Consolas");
        SetCurrentConsoleFontEx(GetStdHandle(STD_OUTPUT_HANDLE), FALSE, &cfi);
    #endif
    
    // 设置应用程序区域设置
    QLocale::setDefault(QLocale(QLocale::Chinese, QLocale::China));
    
    cout << "🚀 应用程序启动中..." << endl;
    cout << "📍 Qt版本: " << QT_VERSION_STR << endl;
    
    MainWindow w;
    w.show();
    
    cout << "✅ 主窗口显示完成" << endl;
    
    return a.exec();
}
