<%
    ui.decorateWith("appui", "standardEmrPage")
    ui.includeJavascript("uicommons", "angular.min.js")
    ui.includeJavascript("uicommons", "datatables/jquery.dataTables.min.js")
    ui.includeJavascript("isanteplusreports", "isanteplusReport.js")
    ui.includeCss("uicommons", "datatables/dataTables_jui.css")

%>
<script type="text/javascript">
    var breadcrumbs = [
        { icon: "icon-home", link: '/' + OPENMRS_CONTEXT_PATH + '/index.htm' },
        { label: "${ ui.escapeJs(ui.message("reportingui.reportsapp.home.title")) }", link: emr.pageLink("reportingui", "reportsapp/home") },
        { label: "${ ui.message("reportingui.reportHistory.title") }", link: "${ ui.escapeJs(ui.thisUrl()) }" }
    ];

    var highlight = <%= param.request ? """ "${ ui.escapeJs(param.request[0])}" """ : "null" %>
    
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

<div class="result">
  	<% if(columnsvalues != null) { %>
  	   <% if(reportName != null) { %>
  	   		${ui.format(reportName)}
  	   <% } %>
  		<br/>
  		<table>
  			
	    	<% parameter.each { %>
	    			<tr>
			    		<td><b> ${ ui.format(it.getLabel()) } </b></td>
			    		<td> ${ui.format(dataset.getContext().getParameterValue(it.getName()))} </td>
			    		
		    		</tr>
		    <% } %>
		    
		</table>
		  <%  ui.resourceLink("isanteplusreports", "images/sort_asc.png") %>
		  
  		<table id="isanteplus-report">
  		<thead>
  			<tr>
	    			<% columns.each { %>
	    			<% if (!it.toString().contains("Patient Id")) { %>
			    		<th>${ui.format(it)}</th>
		    		<% } %>
		    		<% } %>
		    </tr>
		</thead>
		<tbody>
	    	<% columnsvalues.each { %>
	    		<% i = i + 1 %>
	    		<tr>
	    			<% def patientId = null %>
	    			<% columns.each { colName -> %>
		    			<% if (colName.toString().contains("Patient Id")) { %>
		    				<% patientId = it.columnValues[colName] %>
		    			<% } %>
		    			<% if (!colName.toString().contains("Patient Id")) { %>
			    		<td>
			    			<% if (patientId != null) { %>
			    				<a href="../coreapps/clinicianfacing/patient.page?patientId=${ui.format(patientId)}" target="_blank">${ui.format(it.columnValues[colName])}</a>
			    			<% } else { %>
			    				${ui.format(it.columnValues[colName])}
			    			<% } %>
			    		</td>		    				
		    			<% } %>
		    		
		    		<% } %>
		    	</tr>
	    	<% } %>
	    </tbody>
    	</table>
     <% } %> 
     <br/>
     <% if(i > 15) { %>
     Total : ${ui.format(i)}
     <% } %>
    </div>