<%
    ui.decorateWith("appui", "standardEmrPage")
    ui.includeJavascript("isanteplusreports", "healthQualExportToExcel.js")
%>

<script type="text/javascript">
    var breadcrumbs = [
        { icon: "icon-home", link: '/' + OPENMRS_CONTEXT_PATH + '/index.htm' },
        { label: "${ ui.escapeJs(ui.message("reportingui.reportsapp.home.title")) }", link: emr.pageLink("reportingui", "reportsapp/home") },
        { label: "${ ui.message("isanteplusreports.weeklymonitoringreport.indicator.label") }", link: '${ ui.thisUrl() }' }
    ];
    var jq = jQuery;

    jq(document).ready(function() {
        jq('#indicatorsForm').submit(function(event) {            
            runReport();
        });
        jq('#buttonToPdf').click(function(event) {
            event.preventDefault();                            
            savePdf();
        });
        jq('#buttonToExcel').click(function(event) {
            event.preventDefault();                            
            saveExcel();
        });
        
        var checkBox = document.getElementById("check");
         jq('#check').change(function(event) {
            
             if (checkBox.checked == true){
                jq('.opts').prop("checked", true);
             } else {
                jq('.opts').prop("checked", false);
            }
        });
    });
 
    function saveExcel() {
        var worksheet = "";
        jq("#divWithReportTables").find("table").each(function(i, table) {
            worksheet += jq(this).html();
            worksheet += "<tr></tr>"; // table separation
        });

        saveToExcel(worksheet, 'workbenchName', generateExcelName());
    }

    function generateExcelName() {
        return "AlertePrecoceReport" + formatDate(new Date()) + ".xls";
    }

    function generatePdfName() {
        return "AlertePrecoceReport" + formatDate(new Date()) + ".pdf";
    }

    function formatDate(date) {
        return jq.datepicker.formatDate('yy-mm-dd', date) + '_' + date.toLocaleTimeString();
    }

    function runReport() {
        var form = jq('#indicatorsForm');
        var indicators = parseIndicators(form);
        
        jq("#codedIndicators").remove();    // if it exists
        form.append("<input id='codedIndicators' type='hidden' name='indicatorList' value='" + JSON.stringify(indicators) + "'/>");
    }

    function parseIndicators(form) {
        var parsedIndicators = [];
        var indicators = form.find(".indicator");

        indicators.each(function() {
            var indicator = jq(this);
            if (indicator.find("[name=selection]").prop('checked') === true) {
                var map = new Object();
                indicator.find('[name=options]').each(function() {
                    map[indicator.find('[name=options] :selected').attr('name')] = indicator.find('[name=options] :selected').val();
                });
                parsedIndicators.push(
                    createIndicator(
                        indicator.attr('id'),
                        map
                    )
                );
            }
        });
        return parsedIndicators;
    }

    function createIndicator(uuidValue, optionValue) {
        return {
            uuid: uuidValue,
            options: optionValue
        };
    }
</script>

<style type="text/css">
.clearfix::after {
    content: "";
    clear: both;
    display: table;
}

.indicatorsHeader {
    text-align: center;
    background-color: #fefad3;
    font-style: italic;
}

#indicators thead th {
    background-color: #fdf59a;
}

#divWithReportTables th, #divWithReportTables td {
    padding: 5pt;
    border-color: black;
    border-style: solid;
    border-top-width: 1px;
    border-left-width: 1px;
    border-right-width: 0px;
    border-bottom-width: 0px;
}

#divWithReportTables th:last-child, #divWithReportTables td:last-child {
    border-right-width: 1px;
}

#divWithReportTables tr:last-child th, #divWithReportTables tr:last-child td {
    border-bottom-width: 1px;
}

#divWithReportTables th, #divWithReportTables td {
    white-space: normal;
}

.indicatorLabel {
    text-align: center;
    color: blue;
}

.label {
    text-align: center;
}

.total {
    color: blue;
}

#divWithReportTables table {
    border-collapse: separate;
    border-spacing: 0;
    empty-cells: hide;
    margin: 10pt auto;
    width: auto;
}
</style>

<div>

    <h1>${ ui.message("isanteplusreports.weeklymonitoringreport.indicator.label") }</h1>
    <div class="running-reports">

        <form id="indicatorsForm" class="clearfix" method="post">
            <fieldset id="run-report" style="float:right; min-width: 450px; margin-left: 10px;">
                <legend>
                    ${ ui.message("reportingui.runReport.run.legend") }
                </legend>
               
                <p id="parameterSection">
                    ${ ui.includeFragment("uicommons", "field/datetimepicker", [ "id": "startDateField", "label": "From Date", "formFieldName": "startDate", "defaultDate": startDate, "useTime": false ]) }
                    ${ ui.includeFragment("uicommons", "field/datetimepicker", [ "id": "endDateField", "label": "To Date", "formFieldName": "endDate", "defaultDate": endDate, "useTime": false ]) }
                <p>
                <button id="submit" type="submit">${ ui.message("reportingui.runButtonLabel") }</button>
            </fieldset>

            <table id="indicators" style="display:block; width: 100%; padding-top: 11px;">
                <thead>
                    <tr>
                        <th colspan="2" style="width:100%">${ ui.message("isanteplusreports.weeklymonitoringreport.indicator.label") }</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <th class="indicatorsHeader" colspan="2">
                            <% if (startDate != null || endDate != null) { %>
                            	${ ui.message("isanteplusreports.from") } ${ ui.format(startDate) } ${ ui.message("isanteplusreports.to") } ${ ui.format(endDate) }
                            <% } %>
                        </th>
                    </tr>
                     
					<% nonCodedRows.each { %>
			            <tr id="obs-id-${ it.getColumnValue("Indicateur") }">
			                <td>
			                    ${ ui.format(it.getColumnValue("Indicateur")) }
			                </td>
			                 <td>
			                    <a href="${ "/" + contextPath + "/" }isanteplusreports/weeklyMonitoringReportPatientList.page?id=${ ui.format(it.getColumnValue("id")) }&startDate=${ ui.format(date_debut) }&endDate=${ ui.format(date_fin) }" onclick="window.open(this.href, 'windowName', 'width=1000, height=700, left=24, top=24, scrollbars, resizable'); return false;">
			                      ${ ui.format(it.getColumnValue("Total")) }
			                    </a>
			                </td>
			                
			            </tr>
			        <% } %>
                </tbody>
            </table>
        </form>
   </div>
   
</div>
