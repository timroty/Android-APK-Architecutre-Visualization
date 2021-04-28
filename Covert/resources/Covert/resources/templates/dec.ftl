//Automatically Generated
module appDeclaration 

open androidDeclaration

<#list categories as category>
<#if category??>
one sig ${category} extends Category{}
<#else></#if>
</#list>

<#list actions as action>
one sig ${action} extends Action{}
</#list>

<#list permissions as permission>
one sig ${permission} extends Permission{}
</#list>

<#list dataTypes as dataType>
<#if dataType??>
one sig ${dataType} extends DataType{}
<#else></#if>
</#list>

pred show{}
run show
