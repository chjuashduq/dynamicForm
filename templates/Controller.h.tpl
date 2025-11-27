#ifndef {{ className }}CONTROLLER_H
#define {{ className }}CONTROLLER_H

#include <QObject>
#include <QJsonArray>
#include <QJsonObject>

/**
 * @file {{ className }}Controller.h
 * @author {{ author }}
 * @date {{ createDate }}
 * @brief {{ tableName }} Controller
 */
class {{ className }}Controller : public QObject
{
    Q_OBJECT
public:
    explicit {{ className }}Controller(QObject *parent = nullptr);
    
    Q_INVOKABLE QJsonArray list(int pageNum, int pageSize, const QJsonObject &query);
    Q_INVOKABLE bool add(const QJsonObject &data);
    Q_INVOKABLE bool update(const QJsonObject &data);
    Q_INVOKABLE bool remove(const QString &ids);
    Q_INVOKABLE QJsonObject getById(const QString &id);

signals:
    void operationSuccess(const QString &message);
    void operationFailed(const QString &message);
};

#endif // {{ className }}CONTROLLER_H
