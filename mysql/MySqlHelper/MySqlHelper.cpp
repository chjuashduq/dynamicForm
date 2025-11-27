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
        qCritical() << "Update failed" << query.lastError().text();
        return false;
    }
    return true;
}

// 转发调用
QVector<QVariantMap>  MySqlHelper::select(const QString& tableName, const QStringList& columns, const QString& where, const QVariantMap &bindValues){
    return select(tableName, 0, 0, columns, where, bindValues);
}

// [关键修改] 支持绑定参数的查询
QVector<QVariantMap> MySqlHelper::select(const QString& tableName, int pageNum, int pageSize, const QStringList& columns, const QString& where, const QVariantMap &bindValues)
{
    QVector<QVariantMap> results;
    QSqlDatabase& db = MySqlConnectionManager::getInstance()->getDatabase();
    QSqlQuery query(db);
    QString columnString = columns.isEmpty() ? "*" : columns.join(",");
    QString keyString = QString("SELECT %1 FROM %2").arg(columnString).arg(tableName);
    
    if(!where.isEmpty()){
        keyString += " WHERE " + where;
    }
    
    // Pagination
    if (pageNum > 0 && pageSize > 0) {
        int offset = (pageNum - 1) * pageSize;
        keyString += QString(" LIMIT %1 OFFSET %2").arg(pageSize).arg(offset);
    }
    
    // 使用 prepare
    query.prepare(keyString);
    
    // 绑定参数
    if (!bindValues.isEmpty()) {
        QMapIterator<QString, QVariant> i(bindValues);
        while (i.hasNext()) {
            i.next();
            QString placeholder = i.key();
            if (!placeholder.startsWith(":")) {
                placeholder = ":" + placeholder;
            }
            query.bindValue(placeholder, i.value());
        }
    }
    
    if(!query.exec()){
        qCritical() << "Select failed:" << query.lastError().text() << "SQL:" << keyString;
        return results;
    }
    
    QSqlRecord record = query.record(); 
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
        qCritical() << "Delete failed" << query.lastError().text();
        return false;
    }
    return true;
}

QJsonArray MySqlHelper::getDbTables()
{
    QJsonArray tables;
    QSqlDatabase& db = MySqlConnectionManager::getInstance()->getDatabase();
    QSqlQuery query(db);
    QString sql = "SELECT table_name, table_comment, create_time, update_time FROM information_schema.tables WHERE table_schema = (SELECT DATABASE())";
    
    if (!query.exec(sql)) {
        qCritical() << "Select tables failed:" << query.lastError().text();
        return tables;
    }

    while (query.next()) {
        QJsonObject table;
        QString tableName = query.value("table_name").toString();
        table["tableName"] = tableName;
        table["tableComment"] = query.value("table_comment").toString();
        table["createTime"] = query.value("create_time").toDateTime().toString("yyyy-MM-dd HH:mm:ss");
        table["updateTime"] = query.value("update_time").toDateTime().toString("yyyy-MM-dd HH:mm:ss");
        
        // Convert table name to entity name (e.g., sys_user -> SysUser)
        QString entityName;
        bool nextUpper = true;
        for(QChar c : tableName) {
            if (c == '_') {
                nextUpper = true;
            } else {
                if (nextUpper) {
                    entityName.append(c.toUpper());
                    nextUpper = false;
                } else {
                    entityName.append(c);
                }
            }
        }
        table["entityName"] = entityName;
        
        tables.append(table);
    }
    return tables;
}

QJsonArray MySqlHelper::getDbTableColumns(const QString &tableName)
{
    QJsonArray columns;
    QSqlDatabase& db = MySqlConnectionManager::getInstance()->getDatabase();
    QSqlQuery query(db);
    
    QString sql = "SELECT column_name, data_type, column_comment, is_nullable, column_key "
                  "FROM information_schema.columns "
                  "WHERE table_schema = (SELECT DATABASE()) AND table_name = :tableName "
                  "ORDER BY ordinal_position";
    
    query.prepare(sql);
    query.bindValue(":tableName", tableName);
    
    if (!query.exec()) {
        qCritical() << "Select columns failed:" << query.lastError().text();
        return columns;
    }

    while (query.next()) {
        QJsonObject col;
        QString columnName = query.value("column_name").toString();
        QString dataType = query.value("data_type").toString();
        
        col["columnName"] = columnName;
        col["dataType"] = dataType;
        col["columnComment"] = query.value("column_comment").toString();
        col["isNullable"] = query.value("is_nullable").toString();
        col["isPk"] = (query.value("column_key").toString() == "PRI");
        
        QString cppType = "String";
        if (dataType.contains("int")) {
            if (dataType == "bigint") cppType = "Long";
            else cppType = "Integer";
        } else if (dataType.contains("float") || dataType.contains("double") || dataType.contains("decimal")) {
            cppType = "Double";
        } else if (dataType.contains("date") || dataType.contains("time")) {
            cppType = "DateTime";
        } else if (dataType == "bit" || dataType == "boolean") {
            cppType = "Boolean";
        }
        col["cppType"] = cppType;
        
        QString cppField;
        bool nextUpper = false;
        for(QChar c : columnName) {
            if (c == '_') {
                nextUpper = true;
            } else {
                if (nextUpper) {
                    cppField.append(c.toUpper());
                    nextUpper = false;
                } else {
                    cppField.append(c);
                }
            }
        }
        col["cppField"] = cppField;
        
        columns.append(col);
    }
    return columns;
}

MySqlHelper::MySqlHelper()
{
}

MySqlHelper::~MySqlHelper()
{
}