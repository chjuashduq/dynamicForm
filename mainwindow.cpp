#include "mainwindow.h"
#include "ui_mainwindow.h"
#include <QQuickWidget>
#include <QQmlContext>
#include <QFile>

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
{
    ui->setupUi(this);

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
