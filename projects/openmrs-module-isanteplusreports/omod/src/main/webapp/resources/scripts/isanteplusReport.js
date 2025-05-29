jq().ready(function(){
	jq("table#isanteplus-report, table#non-coded-diagnoses, table#tab_excel").dataTable({
	    "bPaginate": false,
	    "bLengthChange": false,
	    "bFilter": false,
	    "bSort": true,
	    "bInfo": false,
	    "bAutoWidth": false    	
	});
});