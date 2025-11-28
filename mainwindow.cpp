#include "mainwindow.h"
#include "ui_mainwindow.h"

#include <FelgoApplication>
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

    static FelgoApplication felgo;

    // 使用 QQmlApplicationEngine
    QQmlApplicationEngine *engine = new QQmlApplicationEngine(this);
    felgo.initialize(engine); // 传 engine 指针即可

    // 添加 QML 模块搜索路径
    engine->addImportPath(QDir::currentPath() + "/qml");
    engine->addImportPath(QDir::currentPath() + "/qml/Common");

    // 注册 C++ 单例对象
    qmlRegisterSingletonType<MySqlHelper>("mysqlhelper", 1, 0, "MySqlHelper",
                                          [](QQmlEngine *, QJSEngine *) -> QObject * { return new MySqlHelper; });

    qmlRegisterSingletonType<MySqlConnectionManager>("mysqlconnectionmanager", 1, 0, "MySqlConnectionManager",
                                                     [](QQmlEngine *, QJSEngine *) -> QObject * { return MySqlConnectionManager::getInstance(); });

    qmlRegisterSingletonType<FileHelper>("utils", 1, 0, "FileHelper",
                                         [](QQmlEngine *, QJSEngine *) -> QObject * { return new FileHelper; });

    qmlRegisterSingletonType<CodeGenerator>("generator", 1, 0, "CodeGenerator",
                                            [](QQmlEngine *, QJSEngine *) -> QObject * { return new CodeGenerator; });

    // 读取 JSON 文件
    QFile file("form_config.json");
    QString jsonStr;
    if(file.open(QIODevice::ReadOnly)) {
        jsonStr = QString(file.readAll());
        file.close();
    }
    engine->rootContext()->setContextProperty("formJson", jsonStr);

    QFile file2("qml/components/components.json");
    QString jsonStr2;
    if(file2.open(QIODevice::ReadOnly)) {
        jsonStr2 = QString(file2.readAll());
        file2.close();
    }
    engine->rootContext()->setContextProperty("componentJson", jsonStr2);

    // 创建 Window Container 嵌入 QMainWindow
    QQuickWindow *qmlWindow = qobject_cast<QQuickWindow*>(engine->rootObjects().isEmpty() ? nullptr : engine->rootObjects().first());
    if(!qmlWindow) {
        engine->load(QUrl::fromLocalFile(QDir::currentPath() + "/qml/Main.qml"));
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
