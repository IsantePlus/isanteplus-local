<%
    ui.decorateWith("appui", "standardEmrPage")
    ui.includeJavascript("coreapps", "fragments/datamanagement/codeDiagnosisDialog.js")
    ui.includeJavascript("uicommons", "datatables/jquery.dataTables.min.js")

%>

<script type="text/javascript">
    var breadcrumbs = [
        { icon: "icon-home", link: '/' + OPENMRS_CONTEXT_PATH + '/index.htm' },
        { label: "${ ui.escapeJs(ui.message("reportingui.reportsapp.home.title")) }", link: emr.pageLink("reportingui", "reportsapp/home") },
        { label: "${ ui.message("isanteplusreports.report.ddp") }", link: "${ ui.thisUrl() }" }
    ];
</script>


<div ng-app="ddpByPeriodReport" ng-controller="DdpByPeriodReportController">

	 <div class="running-reports">
     
          <form id="nonCodedForm" method="post">
    <fieldset id="run-report">
        <legend>
            ${ ui.message("reportingui.runReport.run.legend") }
        </legend>

        <% for (int i=0; i<reportManager.parameters.size(); i++) {
            def parameter = reportManager.parameters.get(i); %>
            <p id="parameter${i}Section">
                <% if (parameter.name == "startDate") { %>
                ${ ui.includeFragment("uicommons", "field/datetimepicker", [ "id": "startDateField", "label": parameter.label, "formFieldName": "startDate", "defaultDate": startDate, "useTime": false ]) }
                <% } else if (parameter.name == "endDate") { %>
                ${ ui.includeFragment("uicommons", "field/datetimepicker", [ "id": "endDateField", "label": parameter.label, "formFieldName": "endDate", "defaultDate": endDate, "useTime": false ]) }
                <% } %>
              <% } %>
        <p>
            <button id="submit" type="submit" class="disab">${ ui.message("reportingui.runButtonLabel") }</button>
        </p>
    </fieldset>

</form>
        
        <% if (startDate != null || endDate != null) { %>
    <h3>
        ${ ui.message("isanteplusreports.report.ddp", ui.format(startDate), ui.format(endDate)) }
    </h3>

    <table id="non-coded-diagnoses" width="100%" border="1" cellspacing="0" cellpadding="2">
        <thead>
            <tr>
                <th>${ ui.message("isanteplusreports.ddp") }</th>
                <th>${ ui.message("isanteplusreports.institution_communautaire") }</th>
                <th>${ ui.message("isanteplusreports.healthqual.result.percentage.label") }</th>
                 <th>${ ui.message("isanteplusreports.patient_unique") }</th>
            </tr>
        </thead>
        <tbody>
        <% if (ddpRows == null ) { %>
            <tr>
                <td colspan="3"></td>
            </tr>
        <% } else ddpRows.each { %>
            <tr id="obs-id-${ it.getColumnValue("ddp") }">
                <td>
                    <a href="${ "/" + contextPath + "/" }isanteplusreports/ddpByPeriodReportList.page?id=1065&startDate=${ ui.format(date_debut) }&endDate=${ ui.format(date_fin) }" onclick="window.open(this.href, 'windowName', 'width=1000, height=700, left=24, top=24, scrollbars, resizable'); return false;">
                      ${ ui.format(it.getColumnValue("ddp")) }
                    </a>
                </td>
                 <td>
                    <a href="${ "/" + contextPath + "/" }isanteplusreports/ddpByPeriodReportList.page?id=0&startDate=${ ui.format(date_debut) }&endDate=${ ui.format(date_fin) }" onclick="window.open(this.href, 'windowName', 'width=1000, height=700, left=24, top=24, scrollbars, resizable'); return false;">
                      ${ ui.format(it.getColumnValue("institution_com")) }
                    </a>
                </td>
                 <td>
                     ${ ui.format(it.getColumnValue("pourcentage")) }
                </td>
                 <td>
                    ${ ui.format(it.getColumnValue("pat_unique")) }
                </td>
            </tr>
        <% } %>
        </tbody>
    </table>

<% } %>
           
   </div>
   
</div>