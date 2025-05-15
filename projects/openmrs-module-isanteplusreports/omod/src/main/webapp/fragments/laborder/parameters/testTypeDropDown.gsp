<%
    config.require("label")
    config.require("formFieldName")
%>

<label for="resultStatus-field">
    ${ ui.message(config.label) }
</label>
<select id="resultStatus-field" name="${ config.formFieldName }">
    <option value="-1">${ ui.message("isanteplusreports.parameters.lab_order.all_tests") }</option>
    <% tests.each { %>
        <option value="${ it.id }">${ it.name.name }</option>
    <% } %>
</select>