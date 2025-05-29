<%
    ui.decorateWith("appui", "standardEmrPage", [ title: ui.message("isanteplusreports.patientImmunization") ])
    ui.includeJavascript("isanteplusreports", "print.js")
%>

<script type="text/javascript">
	var breadcrumbs = [
        { icon: "icon-home", link: '/' + OPENMRS_CONTEXT_PATH + '/index.htm' },
        { label: "${ ui.message("isanteplusreports.back") }", link: "/" + OPENMRS_CONTEXT_PATH + "/coreapps/clinicianfacing/patient.page?patientId=${patient.uuid}"},
        { label: "${ ui.message('isanteplusreports.patientImmunization') }"}
    ];
</script>


${ ui.includeFragment("coreapps", "patientHeader", [ patient: patient ]) }

	<div id="DivIdToPrint">
	<h3>${ ui.message("isanteplusreports.patientImmunization") }</h3><br/>
		 <table id="non-coded-diagnoses" width="100%" border="1" cellspacing="0" cellpadding="2">
       <thead>
  			<tr>
	    			<% columns.each { %>
	    				<th>${ui.format(it)}</th>
		    		<% } %>
		    </tr>
		</thead>
       <tbody>
	    	<% columnsvalues.each { %>
	    		<tr>
	    			<% columns.each { colName -> %>
			    		<td>
			    			${ui.format(it.columnValues[colName])}
			    		</td>
		    		
		    		<% } %>
		    	</tr>
	    	<% } %>
	    </tbody>
    </table>
		
	</div>