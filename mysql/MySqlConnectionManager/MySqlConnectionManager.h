#ifndef MYSQLCONNECTIONMANAGER_H
#define MYSQLCONNECTIONMANAGER_H


#include<QSqlDatabase>
#include<QDebug>
#include<mutex>
#include<QObject>

class MySqlConnectionManager : public QObject{
    Q_OBJECT
private:
    static MySqlConnectionManager* mySqlConnectionManager;
    static std::mutex mtx;
    QSqlDatabase db;
    MySqlConnectionManager();
    ~MySqlConnectionManager();
    /* data */
public:
    static MySqlConnectionManager* getInstance();
    QSqlDatabase& getDatabase(){ return db; }

};
#endif