/*
 * @Author: 刘勇 yongliu_s@163.com
 * @Date: 2025-11-11 14:24:44
 * @LastEditors: 刘勇 yongliu_s@163.com
 * @LastEditTime: 2025-11-11 20:51:23
 * @FilePath: \DynamicFormQML\mysql\MySqlConnectionManager\MySqlConnectionManager.cpp
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
#include "mysqlconnectionmanager.h"
#include <QCoreApplication>
#include <QSqlError>

MySqlConnectionManager* MySqlConnectionManager::mySqlConnectionManager = nullptr;
std::mutex MySqlConnectionManager::mtx;

MySqlConnectionManager* MySqlConnectionManager::getInstance()
{
    if(mySqlConnectionManager == nullptr)
    {
        std::lock_guard<std::mutex> lock(mtx);
        if(mySqlConnectionManager == nullptr){
            mySqlConnectionManager = new MySqlConnectionManager();
        }
        return mySqlConnectionManager;
    }
    return mySqlConnectionManager;
}

MySqlConnectionManager::MySqlConnectionManager(){

    if(QSqlDatabase::contains("qt_mysql_connection")){
        db = QSqlDatabase::database("qt_mysql_connection");

    }else{
        qDebug() << "Library paths:" << QCoreApplication::libraryPaths();
        qDebug() << "Available drivers:" << QSqlDatabase::drivers();
        
        db = QSqlDatabase::addDatabase("QMYSQL","qt_mysql_connection");
        db.setHostName("127.0.0.1");       // 数据库地址
        db.setPort(3306);                  // 端口号
        db.setDatabaseName("test"); // 你的已经创建的数据库名
        db.setUserName("root");            // 你的已设置的用户名
        db.setPassword("123456");   // 你的已设置的连接密码
        if (!db.open()) {
            qCritical() << "Database open failed:" << db.lastError().text();
            qCritical() << "Driver loaded:" << db.driverName();
        } else {
            qDebug() << "Database connected successfully!";
        }
    }

    
}

MySqlConnectionManager::~MySqlConnectionManager(){
    if(db.open()){
        db.close();
    }
}
