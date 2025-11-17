#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QQuickWidget>
#include <QQmlContext>
#include <QFile>
#include <QLoggingCategory>
#include <QQmlEngine>
#include <QDebug>
#include <iostream>
#include <QQmlApplicationEngine>
#include "mysql/MySqlHelper/MySqlHelper.h"
#include "mysql/MySqlConnectionManager/MySqlConnectionManager.h"
QT_BEGIN_NAMESPACE
namespace Ui { class MainWindow; }
QT_END_NAMESPACE

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    MainWindow(QWidget *parent = nullptr);
    ~MainWindow();

private:
    Ui::MainWindow *ui;
};
#endif // MAINWINDOW_H
