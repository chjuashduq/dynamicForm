pragma Singleton
import QtQuick 2.0

Item {
    function generate(config) {
        if (typeof $CodeGenerator !== "undefined" && $CodeGenerator) {
            return $CodeGenerator.generate(config);
        }
        console.log("Mock CodeGenerator.generate called with config:", JSON.stringify(config));
        return true;
    }
}
