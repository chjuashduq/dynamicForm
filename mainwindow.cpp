#include "mainwindow.h"
#include "ui_mainwindow.h"

// #include <FelgoApplication>
// #include <FelgoLiveClient>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QFile>
#include <QDir>
#include <QQuickWindow>
#include <QWidget>

#include "utils/FileHelper.h"
#include "generator/CodeGenerator.h"

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
{
    ui->setupUi(this);

    // static FelgoApplication felgo;

    // 使用 QQmlApplicationEngine
    QQmlApplicationEngine *engine = new QQmlApplicationEngine(this);
    // felgo.initialize(engine); // 传 engine 指针即可
    
    // Initialize Felgo Live Client
    // static FelgoLiveClient liveClient(engine);

    // 添加 QML 模块搜索路径
    engine->addImportPath(QDir::currentPath() + "/qml");
    engine->addImportPath(QDir::currentPath() + "/qml/Common");
    engine->addImportPath("D:/SoftWare/Felgo/Felgo/mingw_64/qml");

    hotReload = new FelgoHotReload(engine, this);

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
    engine->rootContext()->setContextProperty("$MySqlHelper", new MySqlHelper(this));
    engine->rootContext()->setContextProperty("$FileHelper", new FileHelper(this));
    engine->rootContext()->setContextProperty("$CodeGenerator", new CodeGenerator(this));

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

    // 创建 Window Container 嵌入 QMainWindow
    QQuickWindow *qmlWindow = qobject_cast<QQuickWindow*>(engine->rootObjects().isEmpty() ? nullptr : engine->rootObjects().first());
    if(!qmlWindow) {
        // 使用资源路径加载，确保在构建后能找到文件
        engine->load(QUrl("qrc:/qml/main.qml"));
        if(!engine->rootObjects().isEmpty()) {
            qmlWindow = qobject_cast<QQuickWindow*>(engine->rootObjects().first());
        }
    }
    if(qmlWindow) {
        QWidget *container = QWidget::createWindowContainer(qmlWindow, this);
        container->setFocusPolicy(Qt::TabFocus);
        setCentralWidget(container);
        this->showMaximized();
    }
}

MainWindow::~MainWindow()
{
    delete ui;
}
