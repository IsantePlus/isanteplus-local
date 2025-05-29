<%
    ui.decorateWith("appui", "standardEmrPage")
    ui.includeCss("reportingui", "reportsapp/home.css")

    def appFrameworkService = context.getService(context.loadClass("org.openmrs.module.appframework.service.AppFrameworkService"))
    def overviews = appFrameworkService.getExtensionsForCurrentUser("org.openmrs.module.reportingui.reports.overview")
    def monitoringReports = appFrameworkService.getExtensionsForCurrentUser("org.openmrs.module.reportingui.reports.monitoring")
    def dataQualityReports = appFrameworkService.getExtensionsForCurrentUser("org.openmrs.module.reportingui.reports.dataquality")
    def dataExports = appFrameworkService.getExtensionsForCurrentUser("org.openmrs.module.reportingui.reports.dataexport")
	def other = appFrameworkService.getExtensionsForCurrentUser("org.openmrs.module.isanteplusreports.reports.other")
	def antenatal = appFrameworkService.getExtensionsForCurrentUser("org.openmrs.module.isanteplusreports.reports.antenatal")
	def patientsStatus = appFrameworkService.getExtensionsForCurrentUser("org.openmrs.module.isanteplusreports.reports.patientsstatus")
    def alertPrecoce = appFrameworkService.getExtensionsForCurrentUser("org.openmrs.module.isanteplusreports.reports.alertprecoce")
    def dashboard = appFrameworkService.getExtensionsForCurrentUser("org.openmrs.module.isanteplusreports.reports.dashboard")
    def ptme = appFrameworkService.getExtensionsForCurrentUser("org.openmrs.module.isanteplusreports.reports.ptme")
    def psychosocial = appFrameworkService.getExtensionsForCurrentUser("org.openmrs.module.isanteplusreports.reports.psychosocial")
    def contextModel = [:]
%>

<script type="text/javascript">
    var breadcrumbs = [
        { icon: "icon-home", link: '/' + OPENMRS_CONTEXT_PATH + '/index.htm' },
        { label: "${ ui.message("reportingui.reportsapp.home.title") }", link: "${ ui.pageLink("reportingui", "reportsapp/home") }" }
    ];
</script>


<div class="reportBox">
    <% if (overviews) { %>
        <p>${ ui.message("reportingui.reportsapp.overviewReports") }</p>
        <ul>
            <% overviews.each { %>
                <li>
                    ${ ui.includeFragment("uicommons", "extension", [ extension: it, contextModel: contextModel ]) }
                </li>
            <% } %>
        </ul>
    <% } %>
    
    <% if (antenatal) { %>
        <p>${ ui.message("isanteplusreports.reportsapp.antenatal") }</p>
        <ul>
            <% antenatal.each { %>
            <li>
                ${ ui.includeFragment("uicommons", "extension", [ extension: it, contextModel: contextModel ]) }
            </li>
            <% } %>
        </ul>
    <% } %>

    <% if (monitoringReports) { %>
    <p>${ ui.message("reportingui.reportsapp.monitoringReports") }</p>
    <ul>
        <% monitoringReports.each { %>
        <li>
            ${ ui.includeFragment("uicommons", "extension", [ extension: it, contextModel: contextModel ]) }
        </li>
        <% } %>
    </ul>
    <% } %>

    <% if (dataQualityReports) { %>
        <p>${ ui.message("reportingui.reportsapp.dataQualityReports") }</p>
        <ul>
            <% dataQualityReports.each { %>
                <li>
                    ${ ui.includeFragment("uicommons", "extension", [ extension: it, contextModel: contextModel ]) }
                </li>
            <% } %>
        </ul>
    <% } %>
</div>

<div class="reportBox">
	<% if (patientsStatus) { %>
        <p>${ ui.message("isanteplusreports.reportsapp.patientsStatus") }</p>
        <ul>
            <% patientsStatus.each { %>
            <li>
                ${ ui.includeFragment("uicommons", "extension", [ extension: it, contextModel: contextModel ]) }
            </li>
            <% } %>
        </ul>
    <% } %>
    <% if (alertPrecoce) { %>
        <p>${ ui.message("isanteplusreports.reportsapp.alertprecoce") }</p>
        <ul>
            <% alertPrecoce.each { %>
            <li>
                ${ ui.includeFragment("uicommons", "extension", [ extension: it, contextModel: contextModel ]) }
            </li>
            <% } %>
        </ul>
    <% } %>

    <% if (dataExports) { %>
        <p>${ ui.message("reportingui.reportsapp.dataExports") }</p>
        <ul>
            <% dataExports.each { %>
            <li>
                ${ ui.includeFragment("uicommons", "extension", [ extension: it, contextModel: contextModel ]) }
            </li>
            <% } %>
        </ul>
    <% } %>
    
    <% if (dashboard) { %>
        <p>${ ui.message("isanteplusreports.reportsapp.dashboard") }</p>
        <ul>
            <% dashboard.each { %>
            <li>
                ${ ui.includeFragment("uicommons", "extension", [ extension: it, contextModel: contextModel ]) }
            </li>
            <% } %>
        </ul>
    <% } %>
    
    <% if (ptme) { %>
        <p>${ ui.message("isanteplusreports.reportsapp.ptme") }</p>
        <ul>
            <% ptme.each { %>
            <li>
                ${ ui.includeFragment("uicommons", "extension", [ extension: it, contextModel: contextModel ]) }
            </li>
            <% } %>
        </ul>
    <% } %>
    
    <% if (psychosocial) { %>
        <p>${ ui.message("isanteplusreports.reportsapp.psychosocial") }</p>
        <ul>
            <% psychosocial.each { %>
            <li>
                ${ ui.includeFragment("uicommons", "extension", [ extension: it, contextModel: contextModel ]) }
            </li>
            <% } %>
        </ul>
    <% } %>
    
     <% if (other) { %>
        <p>${ ui.message("isanteplusreports.reportsapp.other") }</p>
        <ul>
            <% other.each { %>
            <li>
                ${ ui.includeFragment("uicommons", "extension", [ extension: it, contextModel: contextModel ]) }
            </li>
            <% } %>
        </ul>
    <% } %>
  
</div>