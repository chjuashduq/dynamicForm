#include "mainwindow.h"
#include "mysql/MySqlConnectionManager/MySqlConnectionManager.h"
#include <QApplication>
#include <QLocale>
#include <QLoggingCategory>
#include <QDebug>
#include <iostream>
#include <QQmlDebuggingEnabler>
#include <QQuickStyle>
#ifdef _WIN32
#include <windows.h>
#include <io.h>
#include <fcntl.h>
#endif

using namespace std;
int main(int argc, char *argv[])
{
    // 强制添加 Felgo 插件路径 (根据您的日志路径)
    QCoreApplication::addLibraryPath("D:/SoftWare/Felgo/Felgo/mingw_64/plugins");

    QApplication a(argc, argv);
    
    // 设置 Qt Quick Controls 样式为 Basic，支持自定义
    QQuickStyle::setStyle("Basic");
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

 
