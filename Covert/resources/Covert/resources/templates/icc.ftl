//Automatically Generated
module ICC 

<#list apps as app>
open ${app.name}
</#list>


<#list intents as intent>
one sig ${intent.name} extends Intent{}{
//  ${intent.callAt}
    ${intent.sender}
	${intent.component}
	${intent.action}
	${intent.categories}
	${intent.dataType}
	${intent.dataScheme}
	${intent.detailedPathsName}
}
</#list>


fact {
existingApps.apps = ${counter.appNames}
}

check privEscal for 1 but exactly ${counter.app?c} Application, exactly ${(counter.comp_activity + counter.comp_service + counter.comp_receiver)?c} Component, exactly ${counter.filter?c} IntentFilter, exactly ${counter.intent?c} Intent, exactly ${counter.path?c} DetailedPath 

check InfoLeaksInterApp for 1 but exactly ${counter.app?c} Application, exactly ${(counter.comp_activity + counter.comp_service + counter.comp_receiver)?c} Component, exactly ${counter.filter?c} IntentFilter, exactly ${counter.intent?c} Intent, exactly ${counter.path?c} DetailedPath 

check InfoLeaksIntraAppTransitive1 for 1 but exactly ${counter.app?c} Application, exactly ${(counter.comp_activity + counter.comp_service + counter.comp_receiver)?c} Component, exactly ${counter.filter?c} IntentFilter, exactly ${counter.intent?c} Intent, exactly ${counter.path?c} DetailedPath 
check InfoLeaksIntraAppTransitive2 for 1 but exactly ${counter.app?c} Application, exactly ${(counter.comp_activity + counter.comp_service + counter.comp_receiver)?c} Component, exactly ${counter.filter?c} IntentFilter, exactly ${counter.intent?c} Intent, exactly ${counter.path?c} DetailedPath 
check InfoLeaksIntraAppTransitive3 for 1 but exactly ${counter.app?c} Application, exactly ${(counter.comp_activity + counter.comp_service + counter.comp_receiver)?c} Component, exactly ${counter.filter?c} IntentFilter, exactly ${counter.intent?c} Intent, exactly ${counter.path?c} DetailedPath 
check InfoLeaksIntraAppTransitive4 for 1 but exactly ${counter.app?c} Application, exactly ${(counter.comp_activity + counter.comp_service + counter.comp_receiver)?c} Component, exactly ${counter.filter?c} IntentFilter, exactly ${counter.intent?c} Intent, exactly ${counter.path?c} DetailedPath 


pred generateInfoLeak{
 some GeneratedExp
}
//The exact number of each element is the one shown minus one (except Service & Receiver (=), and DetailedPath (=-2))
run generateInfoLeak for 1 but exactly ${(counter.app + 1)?c} Application, exactly ${(counter.comp_activity + 1)?c} Activity, exactly ${(counter.comp_service)?c} Service, exactly ${(counter.comp_receiver)?c} Receiver, exactly ${(counter.filter + 1)?c} IntentFilter, exactly ${(counter.intent + 1)?c} Intent, exactly ${(counter.path + 2)?c} DetailedPath

pred generateActivityLunch{
 some GeneratedExpActivityLunch
}
//The exact number of each element is the one shown minus one (except Service, Receiver & IntentFilter (=))
run generateActivityLunch for 1 but exactly ${(counter.app + 1)?c} Application, exactly ${(counter.comp_activity + 1)?c} Activity, exactly ${(counter.comp_service)?c} Service, exactly ${(counter.comp_receiver)?c} Receiver, exactly ${(counter.filter)?c} IntentFilter, exactly ${(counter.intent + 1)?c} Intent, exactly ${(counter.path + 1)?c} DetailedPath


pred generateIntentHijack{
	some GeneratedExpIntentHijack
}
//The exact number of each element is the one shown minus one (except Service & Receiver)
run generateIntentHijack for 1 but exactly ${(counter.app + 1)?c} Application, exactly ${(counter.comp_activity + 1)?c} Activity, exactly ${(counter.comp_service)?c} Service, exactly ${(counter.comp_receiver)?c} Receiver, exactly ${(counter.filter + 1)?c} IntentFilter, exactly ${(counter.intent)?c} Intent, exactly ${(counter.path + 1)?c} DetailedPath
