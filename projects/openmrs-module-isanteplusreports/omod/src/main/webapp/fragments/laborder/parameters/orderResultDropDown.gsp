<%
    config.require("label")
    config.require("formFieldName")
%>

<label for="resultStatus-field">
    ${ ui.message(config.label) }
</label>
<select id="resultStatus-field" name="${ config.formFieldName }" >
    <option value="ALL">${ ui.message("isanteplusreports.parameters.lab_order.all_result") }</option>
    <option value="COMPLETE">${ ui.message("isanteplusreports.parameters.lab_order.complete") }</option>
    <option value="INCOMPLETE">${ ui.message("isanteplusreports.parameters.lab_order.INCOMPLETE") }</option>
</select>