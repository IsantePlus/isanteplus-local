 <div id="lastSixForms">
	 <table>
	      <thead>
	            
	            	<tr>
	            	
		                <th>${ ui.message("isanteplusreports.visitDate") }</th>
		                <th>${ ui.message("isanteplusreports.visitType") }</th>
	                 
	           		 </tr>
	      </thead>
	      <tbody>
	      	<div>
			      	<% if (columns != null ) { %>
				    	<% columnsvalues.each { %>
				    		<tr>
				    			<% columns.each { colName -> %>
						    		<td>${ui.format(it.columnValues[colName])}</td>
					    		<% } %>
					    	</tr>
				    	<% } %>
				    <% } %>
		    </div>
		    <div class="info-body">
			   <% if (columnsfirstvisit != null ) { %>
			    	<% columnsvalues_b.each { %>
			    		<tr>
			    			<% columnsfirstvisit.each { colName -> %>
					    		<td>${ui.format(it.columnValues[colName])}</td>
				    		<% } %>
				    	</tr>
			    	<% } %>
		    	<% } %>
		    </div>
		  </tbody>
	</table>
	
</div>