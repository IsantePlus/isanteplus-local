<%
    ui.decorateWith("appui", "standardEmrPage", [ title: ui.message("isanteplusreports.patientSummary") ])
    ui.includeJavascript("isanteplusreports", "print.js")
%>

<script type="text/javascript">
	var breadcrumbs = [
        { icon: "icon-home", link: '/' + OPENMRS_CONTEXT_PATH + '/index.htm' },
        { label: "${ ui.message("isanteplusreports.back") }", link: "/" + OPENMRS_CONTEXT_PATH + "/coreapps/clinicianfacing/patient.page?patientId=${patient.uuid}"},
        { label: "${ ui.message('isanteplusreports.patientSummary') }"}
    ];
</script>

<style type="text/css">

b {
    text-align: center;
    color: blue;
    font-style: italic;
}
#info-header {
    text-align: right;
    font-style: italic;
}
</style>

${ ui.includeFragment("coreapps", "patientHeader", [ patient: patient ]) }

	<div>
		<input type='button' id='btn' value='${ ui.message("isanteplusreports.print") }' onclick='printDiv();'/>
	</div><br/>
	<div id="DivIdToPrint">
		<h2><b><center>${ ui.message("isanteplusreports.summaryMedicalData") }</center></b></h2>
		<div class="info-section">
		    <div id="info-header">
		        <p><h3>${ ui.message("isanteplusreports.patientSummary") }</h3> ${ui.format(patient.getGivenName())}, ${ui.format(patient.getFamilyName())} <br/>
		        <h3>${ui.format(location)}</h3>
		        </p> 
		    </div>
		    <div id="demographicsData">
			   <center><b>****************** ${ ui.message("isanteplusreports.demographicsData") } ******************</b></center><br/>
			   ${ ui.message("isanteplusreports.familyName") } : ${ui.format(patient.getFamilyName())} <br/>
			   ${ ui.message("isanteplusreports.name") }: ${ui.format(patient.getGivenName())} <br/>
			   ${ ui.message("isanteplusreports.sex") } : ${ui.format(patient.getGender())} <br/>
			   ${ ui.message("isanteplusreports.age") } : ${ui.format(patient.getAge())} <br/>
			   ${ ui.message("isanteplusreports.address") } : ${ui.format(patient.getPersonAddress())} <br/><br/>
		   </div><br/>
		   <div id="lastSixForms" width="50%">
		   		<center><b>****************** ${ ui.message("isanteplusreports.lastSixForms") } ******************</b></center><br/>
		   		${ ui.includeFragment("isanteplusreports", "lastSixForms", [ patientId: patient.patientId ]) }
		   </div><br/>
			<div id="clinicExams" width="50%">
				${ ui.includeFragment("isanteplusreports", "clinicExams", [ patientId: patient.patientId ]) }
			</div><br/>
		   <div id="labsResult" width="50%">
		   		<center><b>****************** ${ ui.message("isanteplusreports.labsResult") } ******************</b></center><br/>
		   		${ ui.includeFragment("isanteplusreports", "labsResult", [ patientId: patient.patientId ]) }
		   </div><br/>
		   <div id="motifsConsultation" width="50%">
				${ ui.includeFragment("isanteplusreports", "dispensingDrugs", [ patientId: patient.patientId ]) }
			</div><br/>
		   <div id="lastVitals" width="50%">
		   		<center><b>****************** ${ ui.message("isanteplusreports.lastVitals") } ******************</b></center><br/>
		   		${ ui.includeFragment("isanteplus", "isantePlusMostRecentVitals", [ patientId: patient.patientId ]) }
		   </div><br/>
			
			<div id="motifsConsultation" width="50%">
				${ ui.includeFragment("isanteplusreports", "motifsConsultation", [ patientId: patient.patientId ]) }
			</div><br/>
			<div id="impressionsCliniques" width="50%">
				${ ui.includeFragment("isanteplusreports", "impressionsCliniques", [ patientId: patient.patientId ]) }
			</div><br/>
			<div id="lastViralLoad">
				${ ui.includeFragment("isanteplus", "lastViralLoadTest", [ patientId: patient.patientId ]) }
			</div>
			 
	    </div>
</div>