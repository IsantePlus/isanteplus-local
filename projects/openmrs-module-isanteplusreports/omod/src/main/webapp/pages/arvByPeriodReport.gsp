<%
    ui.decorateWith("appui", "standardEmrPage")
    ui.includeJavascript("coreapps", "fragments/datamanagement/codeDiagnosisDialog.js")
    ui.includeJavascript("uicommons", "datatables/jquery.dataTables.min.js")

%>

<script type="text/javascript">
    var breadcrumbs = [
        { icon: "icon-home", link: '/' + OPENMRS_CONTEXT_PATH + '/index.htm' },
        { label: "${ ui.escapeJs(ui.message("reportingui.reportsapp.home.title")) }", link: emr.pageLink("reportingui", "reportsapp/home") },
        { label: "${ ui.message("isanteplusreports.patientArvByPeriod") }", link: "${ ui.thisUrl() }" }
    ];
</script>


<div ng-app="arvByPeriodReport" ng-controller="ArvByPeriodReportController">

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
        ${ ui.message("isanteplusreports.patientArvByPeriod", ui.format(startDate), ui.format(endDate)) }
    </h3>

    <table id="non-coded-diagnoses" width="100%" border="1" cellspacing="0" cellpadding="2">
        <thead>
            <tr>
                <th>${ ui.message("isanteplusreports.zero_thirty_days") }</th>
                <th>${ ui.message("isanteplusreports.thirty_one_sixty") }</th>
                <th>${ ui.message("isanteplusreports.sixty_one_ninety") }</th>
                <th>${ ui.message("isanteplusreports.ninety_one") }</th>
                <th>${ ui.message("isanteplusreports.one_hundred_twenty") }</th>
                 <th>${ ui.message("isanteplusreports.patient_unique") }</th>
            </tr>
        </thead>
        <tbody>
        <% if (nonCodedRows == null ) { %>
            <tr>
                <td colspan="3"></td>
            </tr>
        <% } else nonCodedRows.each { %>
            <tr id="obs-id-${ it.getColumnValue("0-35 jours") }">
                <td>
                    <a href="${ "/" + contextPath + "/" }isanteplusreports/arvByPeriodReportPatientList.page?id=35&startDate=${ ui.format(date_debut) }&endDate=${ ui.format(date_fin) }" onclick="window.open(this.href, 'windowName', 'width=1000, height=700, left=24, top=24, scrollbars, resizable'); return false;">
                      ${ ui.format(it.getColumnValue("0-35 jours")) }
                    </a>
                </td>
                 <td>
                    <a href="${ "/" + contextPath + "/" }isanteplusreports/arvByPeriodReportPatientList.page?id=90&startDate=${ ui.format(date_debut) }&endDate=${ ui.format(date_fin) }" onclick="window.open(this.href, 'windowName', 'width=1000, height=700, left=24, top=24, scrollbars, resizable'); return false;">
                      ${ ui.format(it.getColumnValue("36-89 jours")) }
                    </a>
                </td>
                 <td>
                    <a href="${ "/" + contextPath + "/" }isanteplusreports/arvByPeriodReportPatientList.page?id=120&startDate=${ ui.format(date_debut) }&endDate=${ ui.format(date_fin) }" onclick="window.open(this.href, 'windowName', 'width=1000, height=700, left=24, top=24, scrollbars, resizable'); return false;">
                      ${ ui.format(it.getColumnValue("90-120 jours")) }
                    </a>
                </td>
                <td>
                     <a href="${ "/" + contextPath + "/" }isanteplusreports/arvByPeriodReportPatientList.page?id=180&startDate=${ ui.format(date_debut) }&endDate=${ ui.format(date_fin) }" onclick="window.open(this.href, 'windowName', 'width=1000, height=700, left=24, top=24, scrollbars, resizable'); return false;">
                      ${ ui.format(it.getColumnValue("121-180 jours")) }
                    </a>
                </td>
                <td>
                    <a href="${ "/" + contextPath + "/" }isanteplusreports/arvByPeriodReportPatientList.page?id=181&startDate=${ ui.format(date_debut) }&endDate=${ ui.format(date_fin) }" onclick="window.open(this.href, 'windowName', 'width=1000, height=700, left=24, top=24, scrollbars, resizable'); return false;">
                      ${ ui.format(it.getColumnValue(">180")) }
                    </a>
                </td>
                 <td>
                    ${ ui.format(it.getColumnValue("patient_unique")) }
                </td>
            </tr>
        <% } %>
        </tbody>
    </table>

<% } %>
           
   </div>
   
</div>