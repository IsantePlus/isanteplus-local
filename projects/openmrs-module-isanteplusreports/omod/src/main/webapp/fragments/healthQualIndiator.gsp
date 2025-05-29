<%
    def indicator = config.indicator
%>
<tr id="${ indicator.getUuid() }" class="indicator">
    <td>
        ${ indicator.getName() }
    </td>
    <td style="white-space: nowrap; text-align: center;">
        <% if (indicator.getOption() != null) { %>
            <label style="display:inline-block;">
                ${ indicator.getOption().getLabel() }:
            </label> 
            <select name="options" style="display:inline-block; margin: 0; min-width:120px; ">
                <% indicator.getOption().getValues().each { optionValue -> %>
                    <option name="${ indicator.getOption().getParameterName() }" value="${ optionValue }">
                        ${ optionValue }
                    </option>
                <% } %>
            </select>
        <% } %>
    </td>
    <td style="text-align: center;">
        <div style="display:inline-block">
            <input name="selection" type="checkbox"/>
        </div>
    </td>
</tr>