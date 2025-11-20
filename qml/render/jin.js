// 根据用户名查询并填充表单
var doc_type = getControlValue('docCode');
var country_region_code = getControlValue('country');
var doc_num = getControlValue('docNum');
if (formAPI.areControlsValid(['docCode', 'country', 'docNum'])) {
    try {
        var result = MySqlHelper.select('docInfo', [], 'doc_type= ' + 
            doc_type + " and  country_region_code = " + country_region_code 
            + " and doc_num = " + doc_num);
        if (result.length > 0) {
            var user = result[0];
            setControlValue('age', user.age);
            setControlValue('name', user.name);
            setControlValue('location', user.location);
            setTempValue('docInfoId', user.docInfoId);
        } else {
            resetControl('age')
            resetControl('name')
            resetControl('location')
            setTempValue('docInfoId', null);
            showMessage('未找到该用户', 'warning');
        }
    } catch (e) {
        showMessage('查询失败: ' + e, 'error');
    }
}