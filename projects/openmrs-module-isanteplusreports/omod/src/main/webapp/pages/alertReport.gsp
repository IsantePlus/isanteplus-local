<%
    ui.decorateWith("appui", "standardEmrPage")
    ui.includeJavascript("coreapps", "fragments/datamanagement/codeDiagnosisDialog.js")
    ui.includeJavascript("uicommons", "datatables/jquery.dataTables.min.js")

%>

<script type="text/javascript">
    var breadcrumbs = [
        { icon: "icon-home", link: '/' + OPENMRS_CONTEXT_PATH + '/index.htm' },
        { label: "${ ui.escapeJs(ui.message("reportingui.reportsapp.home.title")) }", link: emr.pageLink("reportingui", "reportsapp/home") },
        { label: "${ ui.message("isanteplusreports.alert") }", link: "${ ui.thisUrl() }" }
    ];
</script>


<div ng-app="alertReport" ng-controller="AlertReportController">

	 <div class="running-reports">
 
    <table id="alert" width="100%" border="1" cellspacing="0" cellpadding="2">
        <thead>
            <tr>
                <th>Alert</th>
                <th>Total</th>
            </tr>
        </thead>
        <tbody>
        <% if (columnsValues == null ) { %>
            <tr>
                <td colspan="3">No result</td>
            </tr>
        <% } else columnsValues.each { %>
            <tr>
                <td>
                     ${ ui.format(it.getColumnValue("Alert")) }
                </td>
                 <td>
                    <a href="${ "/" + contextPath + "/" }isanteplusreports/alertReportPatientList.page?id=${ ui.format(it.getColumnValue("id_alert")) }" onclick="window.open(this.href, 'windowName', 'width=1000, height=700, left=24, top=24, scrollbars, resizable'); return false;">
                      ${ ui.format(it.getColumnValue("Total")) }
                    </a>
                </td>
                 
            </tr>
        <% } %>
        </tbody>
    </table>
           
   </div>
   
</div>