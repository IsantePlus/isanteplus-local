<%
    config.require("label")
    config.require("formFieldName")
%>

<label for="resultStatus-field">
    ${ ui.message(config.label) }
</label>
<select id="resultStatus-field" name="${ config.formFieldName }">
    <option value="YES">${ ui.message("isanteplusreports.parameters.lab_order.yes") }</option>
    <option value="NO">${ ui.message("isanteplusreports.parameters.lab_order.no") }</option>
</select>