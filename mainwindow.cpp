/*
 * @Author: 刘勇 yongliu_s@163.com
 * @Date: 2025-10-27 16:16:13
 * @LastEditors: 刘勇 yongliu_s@163.com
 * @LastEditTime: 2025-11-13 16:10:25
 * @FilePath: \DynamicFormQML\mainwindow.cpp
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
#include "mainwindow.h"
#include "ui_mainwindow.h"

using namespace std;

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
{
    ui->setupUi(this);

    // 设置窗口全屏
    this->showMaximized();
    // 或者使用 this->showFullScreen(); 来完全全屏（无标题栏）

    QQuickWidget *quickWidget = new QQuickWidget(this);
    quickWidget->setResizeMode(QQuickWidget::SizeRootObjectToView);
    setCentralWidget(quickWidget);
    // 获取 QQuickWidget 的 QQmlEngine
QQmlEngine *engine = quickWidget->engine();

// 加入 QRC 路径
engine->addImportPath("qrc:/qml");

    // 读取 JSON
    QFile file(":/form_config.json");
    QString jsonStr;
    if(file.open(QIODevice::ReadOnly)){
        jsonStr = QString(file.readAll());
        file.close();
    }
    qmlRegisterSingletonType<MySqlHelper>("mysqlhelper", 1, 0, "MySqlHelper", [](QQmlEngine *, QJSEngine *) -> QObject * {
        return new MySqlHelper;
    });
    qmlRegisterSingletonType<MySqlConnectionManager>("mysqlconnectionmanager", 1, 0, "MySqlConnectionManager", [](QQmlEngine *, QJSEngine *) -> QObject * {
        return MySqlConnectionManager::getInstance();
    });
    // 传入 QML
    
    quickWidget->rootContext()->setContextProperty("formJson", jsonStr);
    quickWidget->setSource(QUrl("qrc:/qml/main.qml"));
}

MainWindow::~MainWindow()
{
    delete ui;
}
