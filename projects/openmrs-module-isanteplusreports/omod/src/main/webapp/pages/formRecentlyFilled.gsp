<%
    ui.decorateWith("appui", "standardEmrPage")
    ui.includeJavascript("coreapps", "fragments/datamanagement/codeDiagnosisDialog.js")
    ui.includeJavascript("uicommons", "datatables/jquery.dataTables.min.js")
    ui.includeJavascript("isanteplusreports", "isanteplusReport.js")
    ui.includeCss("uicommons", "datatables/dataTables_jui.css")

%>

<script type="text/javascript">
    var breadcrumbs = [
        { icon: "icon-home", link: '/' + OPENMRS_CONTEXT_PATH + '/index.htm' },
        { label: "${ ui.escapeJs(ui.message("reportingui.reportsapp.home.title")) }", link: emr.pageLink("reportingui", "reportsapp/home") },
        { label: "${ ui.message("isanteplusreports.form_recently_filled") }", link: "${ ui.thisUrl() }" }
    ];
</script>

<style type="text/css">
	.sorting {
    	background: url(${ ui.resourceLink("isanteplusreports", "images/sort_both.png") }) no-repeat center right;
	}
	.sorting_asc {
    	background: url('${ ui.resourceLink("isanteplusreports", "images/sort_asc.png") }') no-repeat center right;
	}
	.sorting_desc {
    	background: url('${ ui.resourceLink("isanteplusreports", "images/sort_desc.png") }') no-repeat center right;
	}
</style>

<div ng-app="formRecentlyFilled" ng-controller="FormRecentlyFilledPageController">

	 <div class="running-reports">
     
          <form id="nonCodedForm" method="post">
    <fieldset id="run-report">
        <legend>
            ${ ui.message("reportingui.runReport.run.legend") }
        </legend>

        <% for (int i=0; i<reportManager.parameters.size(); i++) {
            def parameter = reportManager.parameters.get(i); %>
            <p id="parameter${i}Section">
                <% if (parameter.name == "total") { %>
                ${ ui.includeFragment("uicommons", "field/text", [ "id": "totalField", "label": parameter.label, "formFieldName": "total", classes: ['required'], initialValue: 100, "min": 1, "max": 1000, "cssClasses": [ "number", "numeric-range" ] ]) }
                <% } %>
              <% } %>
        <p>
            <button id="submit" type="submit" class="disab">${ ui.message("reportingui.runButtonLabel") }</button>
        </p>
    </fieldset>

</form>
        
        <% if (total != null) { %>
    <h3>
        ${ ui.message("isanteplusreports.form_recently_filled", ui.format(total)) }
    </h3>
 <% if (formRecentlyFilled != null ) { %>
    <table id="non-coded-diagnoses" width="100%" border="1" cellspacing="0" cellpadding="2">
        <thead>
            
            	<tr>
            	
	                <th>${ ui.message("isanteplusreports.st_id") }</th>
	                <th>${ ui.message("isanteplusreports.user") }</th>
	                <th>${ ui.message("isanteplusreports.form") }</th>
	                <th>${ ui.message("isanteplusreports.date_created") }</th>
	                <th>${ ui.message("isanteplusreports.last_date_updated") }</th>
	                <th>${ ui.message("isanteplusreports.form") }</th>
                 
           		 </tr>
        </thead>
        <tbody>
        <% if (formRecentlyFilled == null ) { %>
            <tr>
                <td colspan="3">${ ui.message("isanteplusreports.no_result") }</td>
            </tr>
        <% } else formRecentlyFilled.each { %>
            <tr id="obs-id-${ it.getColumnValue("numero") }">
                <td>
                	<a target="_blank" href="${ "/" + contextPath + dashboardUrlWithoutQueryParams }?patientId=${ui.format(it.getColumnValue("patient_id"))}" target="_blank">
                    	${ ui.format(it.getColumnValue("numero")) }
                    </a>
                </td>
                 <td>
                     ${ ui.format(it.getColumnValue("utilisateur")) }
                </td>
                 <td>
                     ${ ui.format(it.getColumnValue("fiche")) }
                   
                </td>
                <td>
                      ${ ui.format(it.getColumnValue("creation")) }
                    
                </td>
                <td>
                    ${ ui.format(it.getColumnValue("modification")) }
                </td>
                <td>
                    <a href="${ "/" + contextPath + "/" }htmlformentryui/htmlform/editHtmlFormWithStandardUi.page?patientId=${ ui.format(it.getColumnValue("patient_id")) }&formUuid=${ ui.format(it.getColumnValue("form_uuid")) }&encounterId=${ ui.format(it.getColumnValue("encounter_uuid")) }" target="_blank">
                    	${ ui.format(it.getColumnValue("fiches")) }
                    </a>
                </td>
            </tr>
        <% } %>
        </tbody>
    </table>
   <% } %>
<% } %>
           
   </div>
   
</div>