//Automatically Generated
open appDeclaration

one sig ${appName} extends Application{}{
	${app.usesPermissions}
	${app.appPermissions}
	${app.APIPermissions}
}


<#list components as component>
one sig ${component.name} extends ${component.type}{}{
	app in ${appName}
	${component.intentFiltersName}
	${component.detailedPathsName}
	${component.compPermissions}
}

</#list>

<#list filters as filter>
one sig ${filter.name} extends IntentFilter{}{
	${filter.actions}
	${filter.categories}
	${filter.dataType}
	${filter.dataScheme}
}
</#list>

<#list detailedPaths as detailedPath>
one sig ${detailedPath.name} extends DetailedPath{}{
<#--//	path: ${detailedPath.path} -->
/*${detailedPath.name}_calledAt
${detailedPath.sourceLocation}@
*/
	source = ${detailedPath.sourceDomain} <#-- //${detailedPath.source} -->
/*${detailedPath.name}_calledAt
${detailedPath.sinkLocation}@
*/
	sink = ${detailedPath.sinkDomain} <#-- //${detailedPath.sink} -->
}
</#list>

fact{
<#if counter.comp < 8>
#${appName}.~app = ${counter.comp?c} 
<#else>
//#${appName}.~app = ${counter.comp?c} 
</#if>  
}

pred show(){
#Application=1
<#if counter.comp < 8>
#Component=${counter.comp?c}
<#else>
//#Component=${counter.comp?c}
</#if>  
<#if counter.filter < 8>
#IntentFilter=${counter.filter?c}
<#else>
//#IntentFilter=${counter.filter?c}
</#if>  
<#if counter.path < 8>
#DetailedPath=${counter.path?c}
<#else>
//#DetailedPath=${counter.path?c}
</#if>  
#DataScheme=2
#existingApps.apps=1
no Intent
}
run show
