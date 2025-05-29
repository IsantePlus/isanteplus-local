<%
    ui.decorateWith("appui", "standardEmrPage", [ title: ui.message("isanteplus.growthCharts") ])
%>

<script type="text/javascript">
	var breadcrumbs = [
        { icon: "icon-home", link: '/' + OPENMRS_CONTEXT_PATH + '/index.htm' },
        { label: "${ ui.message("coreapps.app.systemAdministration.label")}",
          link: "${ui.pageLink("coreapps", "systemadministration/systemAdministration")}"
        },
        { label: "${ ui.message('isanteplus.manageIsantePlus') }"}
    ];
</script>

${ ui.includeFragment("isanteplus", "isantePlusManager") }
