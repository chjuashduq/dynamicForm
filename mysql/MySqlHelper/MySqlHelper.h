#ifndef MYSQLHELPER_H
#define MYSQLHELPER_H
#include "MySqlConnectionManager.h"
#include <QSqlQuery>
#include <QString>
#include <QSqlRecord>
#include <QJsonArray>
#include <QJsonObject>
#include <QVariantMap>

class MySqlHelper : public QObject
{
    Q_OBJECT
public:
    Q_INVOKABLE static bool insert(const QString &tableName, const QMap<QString, QVariant> &data);
    Q_INVOKABLE static bool update(const QString &tableName, const QMap<QString, QVariant> &data, const QString &where = "");
    
    // [修改] 增加 bindValues 参数，默认值为空 map
    Q_INVOKABLE static QVector<QVariantMap> select(const QString &tableName, const QStringList &columns = QStringList(), const QString &where = "", const QVariantMap &bindValues = QVariantMap());
    Q_INVOKABLE static QVector<QVariantMap> select(const QString &tableName, int pageNum, int pageSize, const QStringList &columns = QStringList(), const QString &where = "", const QVariantMap &bindValues = QVariantMap());
    
    Q_INVOKABLE static bool remove(const QString &tableName, const QString &where = "");
    Q_INVOKABLE QJsonArray getDbTables();
    Q_INVOKABLE QJsonArray getDbTableColumns(const QString &tableName);
    MySqlHelper();
    ~MySqlHelper();
};
#endif // MYSQLHELPER_H