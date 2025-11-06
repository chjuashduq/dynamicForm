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
    // 启用 QML 调试（仅在调试模式下）
    #ifdef QT_DEBUG
    // QQmlDebuggingEnabler::enableDebugging(true); // 暂时禁用以避免闪退问题
    #endif
    
    // 设置中文编码支持 (Qt 6方式)
    #ifdef QT_DEBUG
    #ifdef _WIN32
        // Windows下分配控制台（仅调试模式）
        if (AllocConsole()) {
            freopen_s((FILE**)stdout, "CONOUT$", "w", stdout);
            freopen_s((FILE**)stderr, "CONOUT$", "w", stderr);
            SetConsoleOutputCP(CP_UTF8);
            SetConsoleCP(CP_UTF8);
        }
    #endif
    #endif
    
    // 设置应用程序区域设置
    QLocale::setDefault(QLocale(QLocale::Chinese, QLocale::China));
    
    MainWindow w;
    w.show();
    
    return a.exec();
}
