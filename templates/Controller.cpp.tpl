#include "{{ className }}Controller.h"
#include "MySqlHelper.h"
#include <QDebug>

/**
 * @file {{ className }}Controller.cpp
 * @author {{ author }}
 * @date {{ createDate }}
 * @brief {{ tableName }} Controller Implementation
 */

{{ className }}Controller::{{ className }}Controller(QObject *parent) : QObject(parent)
{
}

QJsonArray {{ className }}Controller::list(int pageNum, int pageSize, const QJsonObject &query)
{
    QString where = "1=1";
    QVariantMap bindValues;
    
    {{# columns }}{{# isQuery }}
    if (query.contains("{{ cppField }}") && !query["{{ cppField }}"].toString().isEmpty()) {
        QString val = query["{{ cppField }}"].toString();
        
        {{# isQueryLike }}
        where += " AND {{ columnName }} LIKE :{{ cppField }}";
        bindValues[":{{ cppField }}"] = "%" + val + "%";
        {{/ isQueryLike }}
        {{# isQueryEqual }}
        where += " AND {{ columnName }} = :{{ cppField }}";
        bindValues[":{{ cppField }}"] = val;
        {{/ isQueryEqual }}
        {{# isQueryNE }}
        where += " AND {{ columnName }} != :{{ cppField }}";
        bindValues[":{{ cppField }}"] = val;
        {{/ isQueryNE }}
        {{# isQueryGT }}
        where += " AND {{ columnName }} > :{{ cppField }}";
        bindValues[":{{ cppField }}"] = val;
        {{/ isQueryGT }}
        {{# isQueryGE }}
        where += " AND {{ columnName }} >= :{{ cppField }}";
        bindValues[":{{ cppField }}"] = val;
        {{/ isQueryGE }}
        {{# isQueryLT }}
        where += " AND {{ columnName }} < :{{ cppField }}";
        bindValues[":{{ cppField }}"] = val;
        {{/ isQueryLT }}
        {{# isQueryLE }}
        where += " AND {{ columnName }} <= :{{ cppField }}";
        bindValues[":{{ cppField }}"] = val;
        {{/ isQueryLE }}
        {{# isQueryBetween }}
        QStringList parts = val.split(",");
        if (parts.size() == 2) {
             where += " AND {{ columnName }} BETWEEN :{{ cppField }}_start AND :{{ cppField }}_end";
             bindValues[":{{ cppField }}_start"] = parts[0];
             bindValues[":{{ cppField }}_end"] = parts[1];
        }
        {{/ isQueryBetween }}
        {{# isQueryIn }}
        QString safeVal = val.replace("'", ""); 
        where += " AND {{ columnName }} IN (" + safeVal + ")";
        {{/ isQueryIn }}
    }
    {{# isQueryIsNull }}
    if (query.contains("{{ cppField }}")) {
         where += " AND {{ columnName }} IS NULL";
    }
    {{/ isQueryIsNull }}
    {{# isQueryIsNotNull }}
    if (query.contains("{{ cppField }}")) {
         where += " AND {{ columnName }} IS NOT NULL";
    }
    {{/ isQueryIsNotNull }}
    {{/ isQuery }}{{/ columns }}
    
    QVector<QVariantMap> results = MySqlHelper::select("{{ tableName }}", pageNum, pageSize, QStringList(), where, bindValues);
    QJsonArray jsonArray;
    for(const auto &map : results) {
        QJsonObject item;
        {{# columns }}
        // map 使用数据库字段名 (columnName)，item 使用配置的属性名 (cppField)
        item["{{ cppField }}"] = QJsonValue::fromVariant(map["{{ columnName }}"]);
        {{/ columns }}
        jsonArray.append(item);
    }
    return jsonArray;
}

bool {{ className }}Controller::add(const QJsonObject &data)
{
    QVariantMap dbMap;
    {{# columns }}
    {{# isInsert }}
    // 强制跳过主键字段，由数据库自动生成ID
    {{^ isPk }}
    if (data.contains("{{ cppField }}")) {
        dbMap["{{ columnName }}"] = data["{{ cppField }}"].toVariant();
    }
    {{/ isPk }}
    {{/ isInsert }}
    {{/ columns }}

    bool success = MySqlHelper::insert("{{ tableName }}", dbMap);
    if (success) emit operationSuccess("Add success");
    else emit operationFailed("Add failed");
    return success;
}

bool {{ className }}Controller::update(const QJsonObject &data)
{
    QVariantMap dbMap;
    {{# columns }}
    {{# isEdit }}
    if (data.contains("{{ cppField }}")) {
        dbMap["{{ columnName }}"] = data["{{ cppField }}"].toVariant();
    }
    {{/ isEdit }}
    {{/ columns }}

    QString pkColName = "id";
    {{# columns }}{{# isPk }}pkColName = "{{ columnName }}";{{/ isPk }}{{/ columns }}
    
    QString pkField = "id";
    {{# columns }}{{# isPk }}pkField = "{{ cppField }}";{{/ isPk }}{{/ columns }}

    QString idVal = data[pkField].toVariant().toString();
    QString where = pkColName + " = '" + idVal + "'";
    
    bool success = MySqlHelper::update("{{ tableName }}", dbMap, where);
    if (success) emit operationSuccess("Update success");
    else emit operationFailed("Update failed");
    return success;
}

bool {{ className }}Controller::remove(const QString &ids)
{
    QString pkName = "id";
    {{# columns }}{{# isPk }}pkName = "{{ columnName }}";{{/ isPk }}{{/ columns }}
    
    QString where = pkName + " IN (" + ids + ")";
    bool success = MySqlHelper::remove("{{ tableName }}", where);
    if (success) emit operationSuccess("Delete success");
    else emit operationFailed("Delete failed");
    return success;
}

QJsonObject {{ className }}Controller::getById(const QString &id)
{
    QString pkName = "id";
    {{# columns }}{{# isPk }}pkName = "{{ columnName }}";{{/ isPk }}{{/ columns }}
    
    QString where = pkName + " = :pkId";
    QVariantMap bindValues;
    bindValues[":pkId"] = id;
    
    QVector<QVariantMap> results = MySqlHelper::select("{{ tableName }}", QStringList(), where, bindValues);
    if (!results.isEmpty()) {
        QVariantMap map = results.first();
        QJsonObject item;
        {{# columns }}
        item["{{ cppField }}"] = QJsonValue::fromVariant(map["{{ columnName }}"]);
        {{/ columns }}
        return item;
    }
    return QJsonObject();
}