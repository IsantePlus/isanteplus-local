<style type="text/css">

b {
    text-align: center;
    color: blue;
    font-style: italic;
}
</style>
<% if (dispensingDrugs != null) { %>
<div class="info-section">
	
	<center><b>****************** ${ ui.message("isanteplusreports.dispensingDrugs") } ******************</b></center><br/>
    <table>
    	
	    	<tr><th>${ ui.message("isanteplusreports.visitDate") }</th><th>${ ui.message("isanteplusreports.dispensingDrugs") }</th></tr>
		    <div class="info-body">
		    	<% dispensingDrugs.each { %>
		    		<tr>
		    			<td>${ui.format(it.obsDatetime)}</td>
			    		<td>${ui.format(it.valueCoded)}</td>
			    	</tr>
		    	<% } %>
		    </div>
	   
    </table>
    
</div>
 <% } %>