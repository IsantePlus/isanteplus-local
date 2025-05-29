 <div id="lastSixForms">
 	<center><b>****************** ${ ui.message("isanteplusreports.clinicExams") } ******************</b></center><br/>
	 <table>
	      <thead>
	            
	            	<tr>
	            	
		                <th>${ ui.message("isanteplusreports.visitDate") }</th>
		                <th>${ ui.message("isanteplusreports.clinicExams") }</th>
	                 	<th>${ ui.message("isanteplusreports.numberPatResult") }</th>
	                 	
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
		  </tbody>
	</table>
	
</div>