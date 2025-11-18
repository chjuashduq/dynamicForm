/*
 * @Author: 刘勇 yongliu_s@163.com
 * @Date: 2025-11-11 16:33:08
 * @LastEditors: 刘勇 yongliu_s@163.com
 * @LastEditTime: 2025-11-18 20:15:35
 * @FilePath: \DynamicFormQML\mysql\MySqlHelper\MySqlHelper.cpp
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
#include "MySqlHelper.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QSqlError>
bool MySqlHelper::insert(const QString& tableName, const QMap<QString, QVariant>& data)
{
    if(data.isEmpty()){
        return false;
    }
    QSqlDatabase& db = MySqlConnectionManager::getInstance()->getDatabase();
    QSqlQuery query(db);
    QStringList keys;
    QStringList placeholds;
    for(auto i = data.constBegin();i!=data.constEnd();++i){
        keys << i.key();
        placeholds << ":" + i.key();
    }
    QString keyString = QString("INSERT INTO %1 (%2) VALUES (%3)").arg(tableName).arg(keys.join(",")).arg(placeholds.join(","));
    query.prepare(keyString);
    for (auto i = data.constBegin();i!=data.constEnd();++i) 
    {
        query.bindValue(":" + i.key(), i.value());
        /* code */
    }
    if (!query.exec()) {
        qCritical() << "Insert failed:" << query.lastError().text();
        qCritical() << "SQL:" << keyString;
        return false;
    }
    return true;
}
bool MySqlHelper::update(const QString& tableName, const QMap<QString,QVariant>& data, const QString& where){
    if(data.isEmpty()){
        return false;
    }
    QSqlDatabase& db = MySqlConnectionManager::getInstance()->getDatabase();
    QSqlQuery query(db);
    QStringList keys;
    for(auto i = data.constBegin();i!=data.constEnd();++i){
        keys << QString("%1 = :%1").arg(i.key());
    }
    QString keyString = QString("UPDATE %1 SET %2").arg(tableName).arg(keys.join(","));
    if(!where.isEmpty()){  
        keyString += " WHERE " + where;
    }
    query.prepare(keyString);
    for(auto i = data.constBegin();i!=data.constEnd();++i) 
    {
        query.bindValue(":" + i.key(), i.value());
    }
    if(!query.exec()){
        qCritical() << "Update failed" ;
        return false;
    }
    return true;
}
QVector<QVariantMap>  MySqlHelper::select(const QString& tableName, const QStringList& columns, const QString& where){
    QVector<QVariantMap> results;
    QSqlDatabase& db = MySqlConnectionManager::getInstance()->getDatabase();
    QSqlQuery query(db);
    QString columnString = columns.isEmpty() ? "*" : columns.join(",");
    QString keyString = QString("SELECT %1 FROM %2").arg(columnString).arg(tableName);
    if(!where.isEmpty()){
        keyString += " WHERE " + where;
    }
    if(!query.exec(keyString)){
        qCritical() << "Select failed" ;
        return results;
    }
    QSqlRecord record = query.record(); // 获取结果集的字段信息
    int fieldCount = record.count();
    while (query.next()) {
        QVariantMap row;
        for(int i=0;i<fieldCount;++i){
            QString fieldName = record.fieldName(i);
           
            QVariant value = query.value(i);

            if (value.metaType().id() == QMetaType::QByteArray) {
                QByteArray raw = value.toByteArray();
                QJsonParseError err;
                QJsonDocument doc = QJsonDocument::fromJson(raw, &err);
                if (err.error == QJsonParseError::NoError) {
                    if (doc.isObject())
                        row[fieldName] = doc.object().toVariantMap();
                    else if (doc.isArray())
                        row[fieldName] = doc.array().toVariantList();
                } else {
                    row[fieldName] = QString::fromUtf8(raw);
                }
            } else {
                row[fieldName] = value;
            }  
        }
        results.append(row);

    }

    return results;

}

bool MySqlHelper::remove(const QString& tableName, const QString& where){
    QSqlDatabase& db = MySqlConnectionManager::getInstance()->getDatabase();
    QSqlQuery query(db);
    QString keyString = QString("DELETE FROM %1").arg(tableName);
    if(!where.isEmpty()){
        keyString += " WHERE " + where;
    }
    if(!query.exec(keyString)){
        qCritical() << "Delete failed" ;
        return false;
    }
    return true;
}
MySqlHelper::MySqlHelper()
{
    
}

MySqlHelper::~MySqlHelper()
{
}