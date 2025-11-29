pragma Singleton
import QtQuick 2.0

Item {
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
}
