pragma Singleton
import QtQuick 2.0

Item {
    function getDbTableColumns(tableName) {
        // Check if the C++ context property is available
        if (typeof $MySqlHelper !== "undefined" && $MySqlHelper) {
            console.log("Real MySqlHelper.getDbTableColumns called for", tableName);
            return $MySqlHelper.getDbTableColumns(tableName);
        }
        console.log("Mock MySqlHelper.getDbTableColumns called for", tableName);
        return [
            {
                "columnName": "id",
                "dataType": "bigint",
                "columnComment": "ID",
                "isNullable": "NO",
                "isPk": true,
                "cppType": "Long",
                "cppField": "Id"
            },
            {
                "columnName": "username",
                "dataType": "varchar",
                "columnComment": "Username",
                "isNullable": "NO",
                "isPk": false,
                "cppType": "String",
                "cppField": "Username"
            },
            {
                "columnName": "create_time",
                "dataType": "datetime",
                "columnComment": "Create Time",
                "isNullable": "YES",
                "isPk": false,
                "cppType": "DateTime",
                "cppField": "CreateTime"
            }
        ];
    }
    function getDbTables() {
        if (typeof $MySqlHelper !== "undefined" && $MySqlHelper) {
            console.log("Real MySqlHelper.getDbTables called");
            return $MySqlHelper.getDbTables();
        }
        console.log("Mock MySqlHelper.getDbTables called");
        return [
            {
                "tableName": "sys_user",
                "tableComment": "System User",
                "createTime": "2023-01-01",
                "updateTime": "2023-01-02",
                "entityName": "SysUser"
            },
            {
                "tableName": "sys_role",
                "tableComment": "System Role",
                "createTime": "2023-01-01",
                "updateTime": "2023-01-02",
                "entityName": "SysRole"
            }
        ];
    }
    function executeSql(sql) {
        if (typeof $MySqlHelper !== "undefined" && $MySqlHelper) {
            return $MySqlHelper.executeSql(sql);
        }
        console.log("Mock MySqlHelper.executeSql called:", sql);
        return [];
    }
    function getProjectRoot() {
        if (typeof $FileHelper !== "undefined" && $FileHelper) {
            return $FileHelper.getProjectRoot();
        }
        console.log("Mock FileHelper.getProjectRoot called");
        return "";
    }
    function getLocalPath(path) {
        if (typeof $FileHelper !== "undefined" && $FileHelper) {
            return $FileHelper.getLocalPath(path);
        }
        console.log("Mock FileHelper.getLocalPath called for", path);
        return path;
    }
    function read(path) {
        if (typeof $FileHelper !== "undefined" && $FileHelper) {
            return $FileHelper.read(path);
        }
        console.log("Mock FileHelper.read called for", path);
        return "";
    }
    function write(path, content) {
        if (typeof $FileHelper !== "undefined" && $FileHelper) {
            return $FileHelper.write(path, content);
        }
        console.log("Mock FileHelper.write called for", path);
        return true;
    }
    function select(tableName, columns, where) {
        if (typeof $MySqlHelper !== "undefined" && $MySqlHelper) {
            return $MySqlHelper.select(tableName, columns, where);
        }
        console.log("Mock MySqlHelper.select called for", tableName, "where", where);
        return [];
    }
    function remove(tableName, where) {
        if (typeof $MySqlHelper !== "undefined" && $MySqlHelper) {
            return $MySqlHelper.remove(tableName, where);
        }
        console.log("Mock MySqlHelper.remove called for", tableName, "where", where);
        return true;
    }
    function generate(config) {
        if (typeof $CodeGenerator !== "undefined" && $CodeGenerator) {
            return $CodeGenerator.generate(config);
        }
        console.log("Mock CodeGenerator.generate called with config:", JSON.stringify(config));
        return true;
    }
}
