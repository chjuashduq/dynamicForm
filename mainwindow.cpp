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

}

MainWindow::~MainWindow()
{
    delete ui;
}
