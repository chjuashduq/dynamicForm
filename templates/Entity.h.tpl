#ifndef {{ className }}_H
#define {{ className }}_H

#include <QString>
#include <QDateTime>
#include <QJsonObject>
#include <QObject>

/**
 * @file {{ className }}.h
 * @author {{ author }}
 * @date {{ createDate }}
 * @brief {{ tableName }} Entity
 */
class {{ className }} : public QObject
{
    Q_OBJECT
    {{# columns }}
    Q_PROPERTY({{ cppType }} {{ cppField }} READ get{{ cppFieldCap }} WRITE set{{ cppFieldCap }})
    {{/ columns }}

public:
    explicit {{ className }}(QObject *parent = nullptr);
    
    // Getters and Setters
    {{# columns }}
    {{ cppType }} get{{ cppFieldCap }}() const;
    void set{{ cppFieldCap }}(const {{ cppType }} &value);
    {{/ columns }}
    
    // Serialization
    QJsonObject toJson() const;
    static {{ className }}* fromJson(const QJsonObject &json, QObject *parent = nullptr);

private:
    {{# columns }}
    {{ cppType }} m_{{ cppField }}; // {{ columnComment }}
    {{/ columns }}
};

#endif // {{ className }}_H
