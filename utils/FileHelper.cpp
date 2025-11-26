#include "FileHelper.h"

FileHelper::FileHelper(QObject *parent) : QObject(parent)
{

}

bool FileHelper::write(const QString &source, const QString &data)
{
    QString path = getLocalPath(source);
    if (path.isEmpty())
        return false;

    QFile file(path);
    if (!file.open(QFile::WriteOnly | QFile::Truncate | QFile::Text)) {
        qDebug() << "FileHelper: Could not open file for writing:" << path;
        return false;
    }

    QTextStream out(&file);
    out.setEncoding(QStringConverter::Utf8);
    out << data;
    file.close();
    return true;
}

QString FileHelper::read(const QString &source)
{
    QString path = getLocalPath(source);
    if (path.isEmpty())
        return "";

    QFile file(path);
    if (!file.open(QFile::ReadOnly | QFile::Text)) {
        qDebug() << "FileHelper: Could not open file for reading:" << path;
        return "";
    }

    QTextStream in(&file);
    in.setEncoding(QStringConverter::Utf8);
    return in.readAll();
}

QString FileHelper::getLocalPath(const QString &url)
{
    QUrl qurl(url);
    if (qurl.isLocalFile()) {
        return qurl.toLocalFile();
    }
    // If it's already a path (e.g. Windows path), return it
    if (!url.startsWith("file:") && !url.startsWith("qrc:")) {
        return url;
    }
    return url;
}
