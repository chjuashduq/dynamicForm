#include "{{ className }}.h"

/**
 * @file {{ className }}.cpp
 * @author {{ author }}
 * @date {{ createDate }}
 * @brief {{ tableName }} Entity Implementation
 */

{{ className }}::{{ className }}(QObject *parent) : QObject(parent)
{
}

// Getters and Setters
{{# columns }}
{{ cppType }} {{ className }}::get{{ cppFieldCap }}() const
{
    return m_{{ cppField }};
}

void {{ className }}::set{{ cppFieldCap }}(const {{ cppType }} &value)
{
    m_{{ cppField }} = value;
}

{{/ columns }}

// Serialization
QJsonObject {{ className }}::toJson() const
{
    QJsonObject json;
    {{# columns }}
    {{# isDateTime }}
    json["{{ cppField }}"] = m_{{ cppField }}.toString("yyyy-MM-dd HH:mm:ss");
    {{/ isDateTime }}
    {{^ isDateTime }}
    json["{{ cppField }}"] = QJsonValue::fromVariant(m_{{ cppField }});
    {{/ isDateTime }}
    {{/ columns }}
    return json;
}

{{ className }}* {{ className }}::fromJson(const QJsonObject &json, QObject *parent)
{
    {{ className }} *item = new {{ className }}(parent);
    {{# columns }}
    if (json.contains("{{ cppField }}")) {
        {{# isDateTime }}
        QString dateStr = json["{{ cppField }}"].toString();
        if (!dateStr.isEmpty()) {
            item->set{{ cppFieldCap }}(QDateTime::fromString(dateStr, "yyyy-MM-dd HH:mm:ss"));
        }
        {{/ isDateTime }}
        {{^ isDateTime }}
        item->set{{ cppFieldCap }}(json["{{ cppField }}"].toVariant().value<{{ cppType }}>());
        {{/ isDateTime }}
    }
    {{/ columns }}
    return item;
}