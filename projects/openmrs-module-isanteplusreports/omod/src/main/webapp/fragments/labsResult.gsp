<div class="info-section">
    <table>
    	<% if (labresult != null) { %>
	    	<tr><th>${ ui.message("isanteplus.testName") }</th><th>Date</th><th>${ ui.message("isanteplus.testResult") }</th></tr>
		    <div class="info-body">
		    	<% labresult.each { %>
		    		<tr>
			    		<td>${ui.format(it.obs.concept)}</td>
			    		<td>${ui.format(it.obs.obsDatetime)}</td>
			    		<td>${ui.format(it.obs.valueNumeric)} ${ui.format(it.obs.valueCoded)} ${ui.format(it.obs.valueText)} <% if(it.obs.valueNumeric > 0) { %> ${ui.format(it.conceptNumeric.units)} <% } %></td>
		    		</tr>
		    	<% } %>
		    </div>
	    <% } %>
    </table>
</div>