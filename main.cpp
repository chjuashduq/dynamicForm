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
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QFile>
#include <QDir>
#include <QQuickWindow>
#include <QWidget>
#include <FelgoApplication>
#include <FelgoHotReload>
#include "utils/FileHelper.h"
#include "generator/CodeGenerator.h"
#endif

using namespace std;
int main(int argc, char *argv[])
{


    QApplication a(argc, argv);
    FelgoApplication felgo;
    QQmlApplicationEngine *engine = new QQmlApplicationEngine();
    felgo.initialize(engine); // 传 engine 指针即可

    // Initialize Felgo Live Client
    //static FelgoLiveClient liveClient(engine);

    // 添加 QML 模块搜索路径
    engine->addImportPath(QDir::currentPath() + "/qml");
    engine->addImportPath(QDir::currentPath() + "/qml/Common");
    engine->addImportPath("D:/SoftWare/Felgo/Felgo/mingw_64/qml");



    // 注册 C++ 单例对象
    // qmlRegisterSingletonType<MySqlHelper>("App.Native", 1, 0, "CppMySqlHelper",
    //                                       [](QQmlEngine *, QJSEngine *) -> QObject * { return new MySqlHelper; });

    // qmlRegisterSingletonType<MySqlConnectionManager>("App.Native", 1, 0, "CppMySqlConnectionManager",
    //                                                  [](QQmlEngine *, QJSEngine *) -> QObject * { return MySqlConnectionManager::getInstance(); });

    // qmlRegisterSingletonType<FileHelper>("App.Native", 1, 0, "CppFileHelper",
    //                                      [](QQmlEngine *, QJSEngine *) -> QObject * { return new FileHelper; });

    // qmlRegisterSingletonType<CodeGenerator>("App.Native", 1, 0, "CppCodeGenerator",
    //                                         [](QQmlEngine *, QJSEngine *) -> QObject * { return new CodeGenerator; });

    // Register as context properties for hybrid support (Mock/Real)
    engine->rootContext()->setContextProperty("$MySqlHelper", new MySqlHelper());
    engine->rootContext()->setContextProperty("$FileHelper", new FileHelper());
    engine->rootContext()->setContextProperty("$CodeGenerator", new CodeGenerator());

    // 读取 JSON 文件 (优先从资源读取)
    QFile file(":/form_config.json");
    QString jsonStr;
    if(file.open(QIODevice::ReadOnly)) {
        jsonStr = QString(file.readAll());
        file.close();
    }
    engine->rootContext()->setContextProperty("formJson", jsonStr);

    QFile file2(":/qml/components/components.json");
    QString jsonStr2;
    if(file2.open(QIODevice::ReadOnly)) {
        jsonStr2 = QString(file2.readAll());
        file2.close();
    }
    engine->rootContext()->setContextProperty("componentJson", jsonStr2);

    //engine->load(QUrl("qrc:/qml/main.qml"));
    FelgoHotReload felgoHotReload(engine);
    /*
/*
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
    */
    return a.exec();
}

 
