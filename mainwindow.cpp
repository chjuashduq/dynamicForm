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

    QQuickWidget *quickWidget = new QQuickWidget(this);
    quickWidget->setResizeMode(QQuickWidget::SizeRootObjectToView);
    setCentralWidget(quickWidget);

    // 读取 JSON
    QFile file(":/form_config.json");
    QString jsonStr;
    if(file.open(QIODevice::ReadOnly)){
        jsonStr = QString(file.readAll());
        file.close();
    }

    // 传入 QML
    quickWidget->rootContext()->setContextProperty("formJson", jsonStr);
    quickWidget->setSource(QUrl("qrc:/qml/main.qml"));
}

MainWindow::~MainWindow()
{
    delete ui;
}
