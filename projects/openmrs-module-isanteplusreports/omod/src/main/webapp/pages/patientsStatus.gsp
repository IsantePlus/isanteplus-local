<%
    ui.decorateWith("appui", "standardEmrPage")
    ui.includeJavascript("uicommons", "datatables/jquery.dataTables.min.js")
    ui.includeJavascript("isanteplusreports", "isanteplusReport.js")
     ui.includeJavascript("isanteplusreports", "datatable.js")
    ui.includeCss("uicommons", "datatables/dataTables_jui.css")
%>

<script type="text/javascript">
    var breadcrumbs = [
        { icon: "icon-home", link: '/' + OPENMRS_CONTEXT_PATH + '/index.htm' },
        { label: "${ ui.escapeJs(ui.message("reportingui.reportsapp.home.title")) }", link: emr.pageLink("reportingui", "reportsapp/home") },
        { label: "${ ui.message("isanteplusreports.patientStatus") }", link: "${ ui.thisUrl() }" }
    ];
    var highlight = <%= param.request ? """ "${ ui.escapeJs(param.request[0])}" """ : "null" %>
</script>

<script type="text/javascript">
 var tablesToExcel = (function() {
	    var uri = 'data:application/vnd.ms-excel;base64,'
	    , tmplWorkbookXML = '<?xml version="1.0"?><?mso-application progid="Excel.Sheet"?><Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet" xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet">'
	      + '<DocumentProperties xmlns="urn:schemas-microsoft-com:office:office"><Author>Axel Richter</Author><Created>{created}</Created></DocumentProperties>'
	      + '<Styles>'
	      + '<Style ss:ID="Currency"><NumberFormat ss:Format="Currency"></NumberFormat></Style>'
	      + '<Style ss:ID="Date"><NumberFormat ss:Format="Medium Date"></NumberFormat></Style>'
	      + '</Styles>' 
	      + '{worksheets}</Workbook>'
	    , tmplWorksheetXML = '<Worksheet ss:Name="{nameWS}"><Table>{rows}</Table></Worksheet>'
	    , tmplCellXML = '<Cell{attributeStyleID}{attributeFormula}><Data ss:Type="{nameType}">{data}</Data></Cell>'
	    , base64 = function(s) { return window.btoa(unescape(encodeURIComponent(s))) }
	    , format = function(s, c) { return s.replace(/{(\\w+)}/g, function(m, p) { return c[p]; }) }
	    return function(tables, wsnames, wbname, appname) {
	      var ctx = "";
	      var workbookXML = "";
	      var worksheetsXML = "";
	      var rowsXML = "";

	      for (var i = 0; i < tables.length; i++) {
	        if (!tables[i].nodeType) tables[i] = document.getElementById(tables[i]);
	        for (var j = 0; j < tables[i].rows.length; j++) {
	          rowsXML += '<Row>'
	          for (var k = 0; k < tables[i].rows[j].cells.length; k++) {
	            var dataType = tables[i].rows[j].cells[k].getAttribute("data-type");
	            var dataStyle = tables[i].rows[j].cells[k].getAttribute("data-style");
	            var dataValue = tables[i].rows[j].cells[k].getAttribute("data-value");
	            dataValue = (dataValue)?dataValue:tables[i].rows[j].cells[k].innerHTML;
	            var dataFormula = tables[i].rows[j].cells[k].getAttribute("data-formula");
	            dataFormula = (dataFormula)?dataFormula:(appname=='Calc' && dataType=='DateTime')?dataValue:null;
	            ctx = {  attributeStyleID: (dataStyle=='Currency' || dataStyle=='Date')?' ss:StyleID="'+dataStyle+'"':''
	                   , nameType: (dataType=='Number' || dataType=='DateTime' || dataType=='Boolean' || dataType=='Error')?dataType:'String'
	                   , data: (dataFormula)?'':dataValue
	                   , attributeFormula: (dataFormula)?' ss:Formula="'+dataFormula+'"':''
	                  };
	            rowsXML += format(tmplCellXML, ctx);
	          }
	          rowsXML += '</Row>'
	        }
	        ctx = {rows: rowsXML, nameWS: wsnames[i] || 'Sheet' + i};
	        worksheetsXML += format(tmplWorksheetXML, ctx);
	        rowsXML = "";
	      }

	      ctx = {created: (new Date()).getTime(), worksheets: worksheetsXML};
	      workbookXML = format(tmplWorkbookXML, ctx);

	console.log(workbookXML);

	      var link = document.createElement("A");
	      link.href = uri + base64(workbookXML);
	      link.download = wbname || 'Workbook.xls';
	      link.target = '_blank';
	      document.body.appendChild(link);
	      link.click();
	      document.body.removeChild(link);
	    }
	  })();

</script>

<style type="text/css">
	.sorting {
    	background: url(${ ui.resourceLink("isanteplusreports", "images/sort_both.jpg") }) no-repeat center right;
	}
	.sorting_asc {
    	background: url('${ ui.resourceLink("isanteplusreports", "images/sort_asc.jpg") }') no-repeat center right;
	}
	.sorting_desc {
    	background: url('${ ui.resourceLink("isanteplusreports", "images/sort_desc.jpg") }') no-repeat center right;
	}
</style>

<div id="patientStatusReport">

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
              <br/>
            <table>
            	<tr>
			       	<td> ${ ui.includeFragment("uicommons", "field/checkbox", [ "id": "regularOnArt", "label": "", "formFieldName": "regularOnArt", "checked": "checked" ]) }  ${ ui.message("isanteplusreports.parameters.hiv_status.regular_on_art") }</td>  
              		<td> ${ ui.includeFragment("uicommons", "field/checkbox", [ "id": "missingAppointment", "label": "", "formFieldName": "missingAppointment", "checked": "checked" ]) } ${ ui.message("isanteplusreports.parameters.hiv_status.missing_appointment") } </td>
              		<td> ${ ui.includeFragment("uicommons", "field/checkbox", [ "id": "lostOfFollowUp", "label": "", "formFieldName": "lostOfFollowUp", "checked": "checked" ]) } ${ ui.message("isanteplusreports.parameters.hiv_status.lost_of_follow_up_on_art") } </td>
			    </tr> 
			    <tr>   
			        <td> ${ ui.includeFragment("uicommons", "field/checkbox", [ "id": "deathOnArt", "label": "", "formFieldName": "deathOnArt", "checked": "checked" ]) } ${ ui.message("isanteplusreports.parameters.hiv_status.death_on_art") } </td>
			       	<td> ${ ui.includeFragment("uicommons", "field/checkbox", [ "id": "stoppedOnArt", "label": "", "formFieldName": "stoppedOnArt", "checked": "checked" ]) } ${ ui.message("isanteplusreports.parameters.hiv_status.stopped_on_art") } </td>
        			<td> ${ ui.includeFragment("uicommons", "field/checkbox", [ "id": "tranferedOnArt", "label": "", "formFieldName": "tranferedOnArt" ]) } ${ ui.message("isanteplusreports.parameters.hiv_status.transfered") } </td>
        		</tr>
        		<tr>	
        			<td> ${ ui.includeFragment("uicommons", "field/checkbox", [ "id": "transitionRecent", "label": "", "formFieldName": "transitionRecent" ]) } ${ ui.message("isanteplusreports.parameters.hiv_status.transitionRecent") } </td>
			       	<td> ${ ui.includeFragment("uicommons", "field/checkbox", [ "id": "transitionActive", "label": "", "formFieldName": "transitionActive" ]) } ${ ui.message("isanteplusreports.parameters.hiv_status.transitionActive") } </td>
			        <td> ${ ui.includeFragment("uicommons", "field/checkbox", [ "id": "transitionLostFollowUp", "label": "", "formFieldName": "transitionLostFollowUp" ]) } ${ ui.message("isanteplusreports.parameters.hiv_status.transitionLostFollowUp") } </td>
			    </tr>
			    <tr>   
			        <td> ${ ui.includeFragment("uicommons", "field/checkbox", [ "id": "transitionDeath", "label": "", "formFieldName": "transitionDeath" ]) } ${ ui.message("isanteplusreports.parameters.hiv_status.transitionDeath") } </td>
			       	<td> ${ ui.includeFragment("uicommons", "field/checkbox", [ "id": "transitionTranfered", "label": "", "formFieldName": "transitionTranfered" ]) } ${ ui.message("isanteplusreports.parameters.hiv_status.transitionTranfered") } </td>
          			<td></td>
          		<tr>
          </table>		
        <br/>
        <p>
            <button id="submit" type="submit" class="disab">${ ui.message("reportingui.runButtonLabel") }</button>
        </p>
    </fieldset>

</form>
  <div id="divpopup" class="modal"> 
  		 <div class="modal-content">   
        <% if (startDate != null || endDate != null) { %>
    <div>
	<input type='button' id='btn' value='${ ui.message("isanteplusreports.print") }' onclick='printDiv();'/>&nbsp;&nbsp;
	<input type='button' id='btnExport' value='${ ui.message("isanteplusreports.export") }' onclick="tablesToExcel(['isanteplus-report'], ['Patients_status'], 'PatientsStatus.xls', 'Excel')"/>
	</div><br/>
    <div id="DivIdToPrint">    
    <h3>
        ${ ui.message("isanteplusreports.patientStatus", ui.format(date_debut), ui.format(date_fin)) }
    </h3>
    <table>
    	<tr>
    		<td> ${ ui.message("isanteplusreports.parameters.startdate") } </td>
    		<td> ${ ui.format(date_debut) } </td>
    	</tr>
		<tr>
    		<td> ${ ui.message("isanteplusreports.parameters.enddate") } </td>
    		<td> ${ ui.format(date_fin) } </td>
    	</tr>
    	<tr>
    		<td> ${ ui.message("isanteplusreports.patientStatus") } </td>
    		<% if (message != null) { %>
    			<td> ${ ui.format(message) } </td>
    		<% } %>
    	</tr>
	</table>
	<%  ui.resourceLink("isanteplusreports", "images/sort_asc.png") %>
   <!-- <table id="isanteplus-report" width="100%" border="1" cellspacing="0" cellpadding="2">-->
      <table id="example">  
        <thead>
            <tr>
                <th>${ ui.message("isanteplusreports.code_st") }</th>
                <th>${ ui.message("isanteplusreports.code_national") }</th>
                <th>${ ui.message("isanteplusreports.familyName") }</th>
                <th>${ ui.message("isanteplusreports.name") }</th>
                <th>${ ui.message("isanteplusreports.sex") }</th>
                <th>${ ui.message("isanteplusreports.age") }</th>
                <th>${ ui.message("isanteplusreports.patientStatus") }</th>
                <th>${ ui.message("isanteplusreports.address") }</th>
                <th>${ ui.message("isanteplusreports.last_date") }</th>
                <th>${ ui.message("isanteplusreports.phone") }</th>
                <th>${ ui.message("isanteplusreports.contact") }</th>
                <th> ${ ui.message("isanteplusreports.nextVisit") }</th>
                 <th>${ ui.message("isanteplusreports.reason") }</th>
            </tr>
        </thead>
        <tbody>
        
        <% if (nonCodedRows == null ) { %>
            <tr>
                <td colspan="3"></td>
            </tr>
        <% } else nonCodedRows.each { %>
            <tr>
			    		<td>
			    			<a target="_blank" href="${ "/" + contextPath + dashboardUrlWithoutQueryParams }?patientId=${ui.format(it.getColumnValue("patient_id"))}">
			    				${ui.format(it.getColumnValue("st_id"))}
			    		    </a>
			    		</td>
			    		<td>
			    			<a target="_blank" href="${ "/" + contextPath + dashboardUrlWithoutQueryParams }?patientId=${ui.format(it.getColumnValue("patient_id"))}">
			    				${ui.format(it.getColumnValue("national_id"))}
			    		    </a>
			    		</td>
			    		<td>
			    			${ui.format(it.getColumnValue("nom"))}
			    		</td>
			    		<td>
			    			${ui.format(it.getColumnValue("prenom"))}
			    		   
			    		</td>
			    		<td>
			    			${ui.format(it.getColumnValue("sexe"))}
			    		</td>
			    		<td>
			    			${ui.format(it.getColumnValue("age"))}
			    		</td>
			    		<td>
			    			${ui.format(it.getColumnValue("statut"))}
			    		</td>
			    		<td>
			    			${ ui.format(it.getColumnValue("derniere_date"))}	
			    		</td>
			    		<td>
			    			${ui.format(it.getColumnValue("adresse"))}
			    		</td>
			    		<td>
			    			${ui.format(it.getColumnValue("telephone"))}
			    		</td>
			    		
			    		<td>
			    			${ui.format(it.getColumnValue("contact"))}
			    		</td>
			    		<td>
			    			${ui.format(it.getColumnValue("prochaine_visite"))}
			    		</td>
			    		<td>
			    			${ui.format(it.getColumnValue("raison"))}
			    		</td>
		    	</tr>
		    	<% i = i + 1 %>
        <% } %>
        </tbody>
    </table>

<% } %>
      <% if(i > 0) { %> 
     	Total : ${ui.format(i)}  <br/><br/>
     	<div>
			<input type='button' id='btn' value='${ ui.message("isanteplusreports.print") }' onclick='printDiv();'/>&nbsp;&nbsp;
			<input type='button' id='btnExport' value='${ ui.message("isanteplusreports.export") }' onclick="tablesToExcel(['tab_excel'], ['Patients_status'], 'PatientsStatus.xls', 'Excel')"/>
		</div>
     	
     <% } %>  
     </div> 
   </div>
   </div>
</div>
</div>