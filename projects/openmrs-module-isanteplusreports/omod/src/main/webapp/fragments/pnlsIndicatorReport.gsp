<%
    def indicator = config.indicator
%>
<tr id="${ indicator.getUuid() }" class="indicator">
    <td>
        ${ ui.format(indicator.getName()) }
    </td>
    <td style="text-align: center;">
        <div style="display:inline-block">
            <input name="selection" type="checkbox" class="opts"/>
        </div>
    </td>
</tr>