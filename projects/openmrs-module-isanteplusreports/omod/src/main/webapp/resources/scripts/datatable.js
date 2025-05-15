jq().ready( function () {
	 $('#example').dataTable( {
		"bPaginate": false,
		"bFilter": false,
	    "bInfo": false,
        "aoColumns": [
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            { "sType": "date-uk" },
            null,
            null,
            { "sType": "date-uk" },
            null
          
        ]
    });
    
} );

jQuery.extend( jQuery.fn.dataTableExt.oSort, {
"date-uk-pre": function ( a ) {
    var ukDatea = a.split('-');
    return (ukDatea[2] + ukDatea[1] + ukDatea[0]) * 1;
},

"date-uk-asc": function ( a, b ) {
    return ((a < b) ? -1 : ((a > b) ? 1 : 0));
},

"date-uk-desc": function ( a, b ) {
    return ((a < b) ? 1 : ((a > b) ? -1 : 0));
}
} );

