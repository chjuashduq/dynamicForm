/*
 * @Author: 刘勇 yongliu_s@163.com
 * @Date: 2025-11-11 16:33:02
 * @LastEditors: 刘勇 yongliu_s@163.com
 * @LastEditTime: 2025-11-13 16:12:26
 * @FilePath: \DynamicFormQML\mysql\MySqlHelper\MySqlHelper.h
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
#ifndef MYSQLHELPER_H
#define MYSQLHELPER_H
#include "MySqlConnectionManager.h"
#include <QSqlQuery>
#include <QString>
#include <QSqlRecord>
class MySqlHelper : public QObject
{
    Q_OBJECT
private:
    /* data */
public:
    Q_INVOKABLE static bool insert(const QString &tableName, const QMap<QString, QVariant> &data);
    static bool update(const QString &tableName, const QMap<QString, QVariant> &data, const QString &where);
    Q_INVOKABLE static QVector<QVariantMap> select(const QString &tableName, const QStringList &columns, const QString &where);
    static bool remove(const QString &tableName, const QString &where);
    MySqlHelper(/* args */);
    ~MySqlHelper();
};
#endif // MYSQLHELPER_H
