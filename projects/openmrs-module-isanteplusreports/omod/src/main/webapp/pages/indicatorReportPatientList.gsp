<%
    ui.decorateWith("appui", "standardEmrPage")
    ui.includeJavascript("coreapps", "fragments/datamanagement/codeDiagnosisDialog.js")
    ui.includeJavascript("uicommons", "datatables/jquery.dataTables.min.js")
    ui.includeJavascript("isanteplusreports", "print.js")
    ui.includeJavascript("isanteplusreports", "isanteplusReport.js")
    ui.includeCss("uicommons", "datatables/dataTables_jui.css")
%>

<script type="text/javascript">
    var breadcrumbs = [
        { icon: "icon-home", link: '/' + OPENMRS_CONTEXT_PATH + '/index.htm' },
        { label: "${ ui.escapeJs(ui.message("reportingui.reportsapp.home.title")) }", link: emr.pageLink("reportingui", "reportsapp/home") },
        { label: "${ ui.message("reportingui.reportHistory.title") }", link: "${ ui.thisUrl() }" }
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

<div>
	<input type='button' id='btn' value='${ ui.message("isanteplusreports.print") }' onclick='printDiv();'/>&nbsp;&nbsp;
	<input type='button' id='btnExport' value='${ ui.message("isanteplusreports.export") }' onclick="tablesToExcel(['tab_excel'], ['Patients'], 'PatientsArvByPeriod.xls', 'Excel')"/>
</div><br/>
<div id="DivIdToPrint" ng-app="indicatorReport" ng-controller="IndicatorReportController">
	 ${ ui.message(reportName) } ${ ui.message("isanteplusreports.from") } ${ui.format(dataset.getContext().getParameterValue("startDate"))} ${ ui.message("isanteplusreports.to") } ${ui.format(dataset.getContext().getParameterValue("endDate"))} <br/><br/>
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
			    			<a target="_blank" href="${ "/" + contextPath + dashboardUrlWithoutQueryParams }?patientId=${ui.format(it.getColumnValue("patientId"))}">
			    				${ui.format(it.getColumnValue("Code ST"))}
			    		    </a>
			    		</td>
			    		<td>
			    			<a target="_blank" href="${ "/" + contextPath + dashboardUrlWithoutQueryParams }?patientId=${ui.format(it.getColumnValue("patientId"))}">
			    				${ui.format(it.getColumnValue("Code National"))}
			    		    </a>
			    		</td>
			    		<td>
			    			<a target="_blank" href="${ "/" + contextPath + dashboardUrlWithoutQueryParams }?patientId=${ui.format(it.getColumnValue("patientId"))}">
			    				${ui.format(it.getColumnValue("givenName"))}
			    		    </a>
			    		</td>
			    		<td>
			    			<a target="_blank" href="${ "/" + contextPath + dashboardUrlWithoutQueryParams }?patientId=${ui.format(it.getColumnValue("patientId"))}">
			    				${ui.format(it.getColumnValue("familyName"))}
			    		    </a>
			    		</td>
			    		<td>
			    			<a target="_blank" href="${ "/" + contextPath + dashboardUrlWithoutQueryParams }?patientId=${ui.format(it.getColumnValue("patientId"))}">
			    				${ui.format(it.getColumnValue("Age"))}
			    		    </a>
			    		</td>
			    		<td>
			    			<a target="_blank" href="${ "/" + contextPath + dashboardUrlWithoutQueryParams }?patientId=${ui.format(it.getColumnValue("patientId"))}">
			    				${ui.format(it.getColumnValue("gender"))}
			    		    </a>
			    		</td>
		    	</tr>
	    	<% } %>
	    </div>
	</table>
	</div>
</div>