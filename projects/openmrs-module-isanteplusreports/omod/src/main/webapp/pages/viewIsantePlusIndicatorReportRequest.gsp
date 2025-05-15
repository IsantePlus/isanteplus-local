<%
    ui.decorateWith("appui", "standardEmrPage")
    ui.includeJavascript("uicommons", "angular.min.js")
%>
<script type="text/javascript">
    var breadcrumbs = [
        { icon: "icon-home", link: '/' + OPENMRS_CONTEXT_PATH + '/index.htm' },
        { label: "${ ui.escapeJs(ui.message("reportingui.reportsapp.home.title")) }", link: emr.pageLink("reportingui", "reportsapp/home") },
        { label: "${ ui.message("reportingui.reportHistory.title") }", link: "${ ui.escapeJs(ui.thisUrl()) }" }
    ];

    var highlight = <%= param.request ? """ "${ ui.escapeJs(param.request[0])}" """ : "null" %>
    
    
</script>

<div class="result">
  	<% if(reportingValues != null) { %>
  	   <% if(reportName != null) { %>
  	   		<b>${ui.message(reportName)}</b>
  	   <% } %>
  		<br/>
  		<table>
  			
	    	<% parameter.each { %>
	    			<tr>
			    		<td><b> ${ui.format(it.getName())} </b></td>
			    		<td> ${ui.format(dataset.getContext().getParameterValue(it.getName()))} </td>
			    		
		    		</tr>
		    <% } %>
		    
		</table>
		<br>
  		<table>
	   		<% i = 0 %>
	    	<% reportingValues.each { reportingValue -> %>
    				<tr>
	    				<td>
	    					${ui.format(reportingValue.key)}
	    				</td>
			    		<td>
			    			<% if (reportingValue.value.denominator != null) { %>
				    			${ui.format(reportingValue.value.percentage)}% 
				    			( <a href="${ ui.pageLink("isanteplusreports", "indicatorReportPatientList") }?savedDataSetKey=${reportName}&savedColumnKey=${reportingValue.key.name}&columnKeyType=numerator" onclick="window.open(this.href, 'windowName', 'width=1000, height=700, left=24, top=24, scrollbars, resizable'); return false;">
				    				${ui.format(reportingValue.value.numerator)}
			    				</a>/
				    			<a href="${ ui.pageLink("isanteplusreports", "indicatorReportPatientList") }?savedDataSetKey=${reportName}&savedColumnKey=${reportingValue.key.name}&columnKeyType=denominator" onclick="window.open(this.href, 'windowName', 'width=1000, height=700, left=24, top=24, scrollbars, resizable'); return false;">
				    				${ui.format(reportingValue.value.denominator)}
			    				</a>)
		    				<% } else { %>
				    			<a href="${ ui.pageLink("isanteplusreports", "indicatorReportPatientList") }?savedDataSetKey=${reportName}&savedColumnKey=${reportingValue.key.name}&columnKeyType=numerator" onclick="window.open(this.href, 'windowName', 'width=1000, height=700, left=24, top=24, scrollbars, resizable'); return false;">
				    				${ui.format(reportingValue.value.numerator)}
			    				</a>		    				
		    				<% } %>
			    		</td>
    					<% i = i + 1 %>
	    			</tr>
	    	<% } %>
    	</table>
     <% } %> 
     <br/>
     <% if(i > 15) { %>
     Total : ${ui.format(i)}
     <% } %>
    </div>