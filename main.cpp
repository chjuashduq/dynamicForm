/*
 * @Author: 刘勇 yongliu_s@163.com
 * @Date: 2025-10-27 16:16:13
 * @LastEditors: 刘勇 yongliu_s@163.com
 * @LastEditTime: 2025-11-12 16:23:16
 * @FilePath: \DynamicFormQML\main.cpp
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
#include "mainwindow.h"
#include "MySqlConnectionManager.h"
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

 
