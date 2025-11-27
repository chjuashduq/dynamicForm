#ifndef CODEGENERATOR_H
#define CODEGENERATOR_H

#include <QObject>
#include <QJsonObject>
#include <QJsonArray>
#include <QVariantMap>
#include <QDir>
#include <QFile>
#include <QTextStream>
#include <QRegularExpression>
#include <QDebug>

class CodeGenerator : public QObject
{
    Q_OBJECT
public:
    explicit CodeGenerator(QObject *parent = nullptr);

    Q_INVOKABLE bool generate(const QJsonObject &config);

private:
    QString render(const QString &templateContent, const QVariantMap &data);
    QString processSection(const QString &content, const QVariantMap &data);
    
    QString camelCase(const QString &str, bool upperFirst);
    QVariantMap prepareData(const QJsonObject &config);
    bool writeToFile(const QString &fileName, const QString &content);
};

#endif // CODEGENERATOR_H
