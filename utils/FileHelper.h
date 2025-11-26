#ifndef FILEHELPER_H
#define FILEHELPER_H

#include <QObject>
#include <QFile>
#include <QTextStream>
#include <QDebug>
#include <QUrl>

class FileHelper : public QObject
{
    Q_OBJECT
public:
    explicit FileHelper(QObject *parent = nullptr);

    Q_INVOKABLE bool write(const QString &source, const QString &data);
    Q_INVOKABLE QString read(const QString &source);
    Q_INVOKABLE QString getLocalPath(const QString &url);

};

#endif // FILEHELPER_H
