#include "mainwindow.h"
#include "ui_mainwindow.h"
#include <QQuickWidget>
#include <QQmlContext>
#include <QFile>
#include <QLoggingCategory>
#include <QQmlEngine>
#include <QDebug>
#include <iostream>

using namespace std;

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
{
    ui->setupUi(this);
    
    // 设置窗口全屏
    this->showMaximized();
    // 或者使用 this->showFullScreen(); 来完全全屏（无标题栏）

    // 启用QML控制台输出
    QLoggingCategory::setFilterRules("qml.debug=true");
    
    QQuickWidget *quickWidget = new QQuickWidget(this);
    quickWidget->setResizeMode(QQuickWidget::SizeRootObjectToView);
    setCentralWidget(quickWidget);

    // 读取 JSON
    QFile file(":/form_config.json");
    QString jsonStr;
    if(file.open(QIODevice::ReadOnly)){
        jsonStr = QString(file.readAll());
        file.close();
        cout << "📄 JSON配置文件加载成功，长度: " << jsonStr.length() << endl;
    } else {
        cout << "❌ 无法读取JSON配置文件" << endl;
    }

    // 传入 QML
    quickWidget->rootContext()->setContextProperty("formJson", jsonStr);
    quickWidget->setSource(QUrl("qrc:/qml/main.qml"));
    
    // 检查QML加载状态
    if (quickWidget->status() == QQuickWidget::Error) {
        cout << "❌ QML文件加载失败" << endl;
        auto errors = quickWidget->errors();
        for (const auto &error : errors) {
            cout << "错误: " << error.toString().toStdString() << endl;
        }
    } else {
        cout << "✅ QML界面加载成功" << endl;
    }
}

MainWindow::~MainWindow()
{
    delete ui;
}
