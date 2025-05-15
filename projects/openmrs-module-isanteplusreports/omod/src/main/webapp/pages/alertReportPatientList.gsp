<%
    ui.decorateWith("appui", "standardEmrPage")
    ui.includeJavascript("coreapps", "fragments/datamanagement/codeDiagnosisDialog.js")
    ui.includeJavascript("uicommons", "datatables/jquery.dataTables.min.js")
    ui.includeJavascript("isanteplusreports", "print.js")
%>

<script type="text/javascript">
    var breadcrumbs = [
        { icon: "icon-home", link: '/' + OPENMRS_CONTEXT_PATH + '/index.htm' },
        { label: "${ ui.escapeJs(ui.message("reportingui.reportsapp.home.title")) }", link: emr.pageLink("reportingui", "reportsapp/home") },
        { label: "${ ui.message("isanteplusreports.alert") }", link: "${ ui.thisUrl() }" }
    ];
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
<div>
	<input type='button' id='btn' value='${ ui.message("isanteplusreports.print") }' onclick='printDiv();'/>&nbsp;&nbsp;
	<input type='button' id='btnExport' value='${ ui.message("isanteplusreports.export") }' onclick="tablesToExcel(['tab_excel'], ['Patients_list'], 'List_of_patients.xls', 'Excel')"/>
</div><br/>
<div id="DivIdToPrint" ng-app="alertReportPatientList" ng-controller="AlertReportPatientListController">
	 ${ ui.message("isanteplusreports.alert") } <br/><br/>
	<div id="excel_div">
	<table id="tab_excel">
	    <tr> 
	    	<th>${ ui.message("isanteplusreports.code_st") }</th>
	    	<th>${ ui.message("isanteplusreports.identifier") }</th>
	    	<th>${ ui.message("isanteplusreports.name") }</th>
	    	<th>${ ui.message("isanteplusreports.familyName") }</th>
	    	<th>${ ui.message("isanteplusreports.age") }</th>
	    	<th>${ ui.message("isanteplusreports.sex") }</th>
	    </tr>
	    <div class="info-body">	
	    	<% columnsValues.each { %>
	    		<tr>
			    		<td>
			    			<a target="_blank" href="${ "/" + contextPath + dashboardUrlWithoutQueryParams }?patientId=${ui.format(it.getColumnValue("patient_id"))}">
			    				${ui.format(it.getColumnValue("st_id"))}
			    		    </a>
			    		</td>
			    		<td>
			    			<a target="_blank" href="${ "/" + contextPath + dashboardUrlWithoutQueryParams }?patientId=${ui.format(it.getColumnValue("patient_id"))}">
			    				${ui.format(it.getColumnValue("ID_National"))}
			    		    </a>
			    		</td>
			    		<td>
			    				${ui.format(it.getColumnValue("Nom"))}
			    		    
			    		</td>
			    		<td>
			    				${ui.format(it.getColumnValue("Prenom"))}
			    		    
			    		</td>
			    		<td>
			    			${ui.format(it.getColumnValue("Age"))}
			    		    
			    		</td>
			    		<td>
			    			${ui.format(it.getColumnValue("Sexe"))}
			 
			    		</td>
		    	</tr>
	    	<% } %>
	    </div>
	</table>
	</div>
</div>