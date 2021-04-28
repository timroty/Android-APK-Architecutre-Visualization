module androidDeclaration

one sig existingApps{ //device
	apps: set  Application
//	intents: set Intent
}

 sig Application{
	// permissions that the application needs
	// changed for synthesizer
	usesPermissions: set Permission, // requiredPermission
	// permissions required to access components of this application
	// changed for synthesizer
	appPermissions: set Permission, 
	// permissions actually used by this application via calling APIs, obtained using PScout permission mapping 
	// changed for synthesizer
	APIPermissions: set Permission

//	components: set Component
}

abstract sig Component{
	app: one Application,
	//a component may have any number of filters, 
	//each one describing a different component's capability
	intentFilter: set IntentFilter,
	// permissions required to access this component -- changed to compPermissions from "permissions"
	// changed for synthesizer
	compPermissions: set Permission,
	// permissions actually used by this component via calling APIs (and Intents), obtained using PScout permission mapping 
	// changed for synthesizer
//	compUsesPermissions: set Permission,


	// sensitive datapath
	detailedPaths: set DetailedPath
}

 sig DetailedPath{
//	source, sink: one (Resource+IPC)
	source: one Resource,//+IntentFilter,
	sink: one Resource//+Intent
}


// Source and Sink resources
abstract sig Resource{}
//one sig NETWORK, EMAIL, IMEI, SMS, MIC, CALENDAR, ACCOUNT, SDCARD, CONTACTS, CAMERA, LOG, SIMCARD, LOCATION, IPC, DATABASE, GENERAL, BUNDLE, NEW, UNDEFINED, IPC_NEW extends Resource{} 
//one sig	NO_CATEGORY, HARDWARE_INFO, UNIQUE_IDENTIFIER,LOCATION_INFORMATION, NETWORK_INFORMATION, ACCOUNT_INFORMATION, EMAIL_INFORMATION, FILE_INFORMATION, BLUETOOTH_INFORMATION, VOIP_INFORMATION, DATABASE_INFORMATION, PHONE_INFORMATION, PHONE_CONNECTION, INTER_APP_COMMUNICATION, VOIP, PHONE_STATE, EMAIL, BLUETOOTH, ACCOUNT_SETTINGS, VIDEO, SYNCHRONIZATION_DATA, NETWORK, EMAIL_SETTINGS, FILE, LOG, AUDIO, SMS_MMS, CONTACT_INFORMATION, CALENDAR_INFORMATION, SYSTEM_SETTINGS, IMAGE, BROWSER_INFORMATION, NFC, IPC, NEW, UNDEFINED, IPC_NEW, BUNDLE, WIDGET extends Resource{} 
one sig	NO_CATEGORY, HARDWARE_INFO,  FILE_INFORMATION, BLUETOOTH_INFORMATION, VOIP_INFORMATION, INTER_APP_COMMUNICATION, VOIP, PHONE_STATE,  SYNCHRONIZATION_DATA, EMAIL_SETTINGS, FILE,   SYSTEM_SETTINGS, IMAGE, IPC, NEW, UNDEFINED, IPC_NEW, BUNDLE extends Resource{} 

abstract sig SIGResource extends Resource{}
one sig UNIQUE_IDENTIFIER, LOCATION_INFORMATION, NETWORK_INFORMATION, ACCOUNT_INFORMATION, EMAIL_INFORMATION,DATABASE_INFORMATION, PHONE_INFORMATION, PHONE_CONNECTION,EMAIL, BLUETOOTH, ACCOUNT_SETTINGS, VIDEO,NETWORK, LOG,AUDIO, SMS_MMS, CONTACT_INFORMATION, CALENDAR_INFORMATION,BROWSER_INFORMATION, NFC, WIDGET extends SIGResource{}

// To inform the system which implicit intents they can handle, 
// components can have one or more intent filters.
 sig IntentFilter{
	// A filter may list more than one [actions]
	// The list cannot be empty
	actions: some Action,
	// changed for synthesizer
	//data: one Data,	 // set Data,	
	dataType: some DataType,
	dataScheme: some DataScheme,
	// For an intent to pass the category test, every category 
	// in the Intent object must match a category in the filter. 
	// The filter can list additional categories, 
	//but it cannot omit any that are in the intent.
	categories: set Category,
	//Added for synthesizer, representing a path from this IntentFilter to an API call (by Flowdroid)
	// details of path, such as the particular API, are added, similar to Intents in the ICC module.
}



 sig Activity extends Component{
}

fact{

	// changed for synthesizer
  // each intent-filter belongs to exactly one component
  //all i:IntentFilter| one i.~intentFilter

  // to improve efficiency of Alloy we reuse repetative 
  all i:IntentFilter| some i.~intentFilter


// Three of the core components of an application, namely
// activities, services, and broadcast receivers, can
// have one or more intent filters.
//To exclude provider from having intent filters, 
//we add a separate fact constraint specification.
//  no i:IntentFilter| i.~intentFilter in Provider



	//An IntentFilter that has NoAction, do not include any other actions
	no i:IntentFilter| NoAction in i.actions && #i.actions > 1
//	no c:Component| NoAction in c.intentFilter.actions && #app.intentFilter.actions > 1

}


	// changed for synthesizer
 sig Service extends Component{}
 sig Receiver extends Component{}
 sig Provider extends Component{}


// Elements of an intent:
// Only three attributes of an Intent object are consulted 
// when it is tested against an intent filter:
// Action is a string that names the general action  to be performed.
 sig Action{}
// Category is a string containing additional information about the kind of
//component that should handle the intent
 sig Category{}
// Data is a tuple consisting of both the URI of the data to be acted on and its MIME media type. 
// This attribute indicates the data to be processed by the action.


// An intentFilter should have at least one action, we put this sig here to enable modeling those intentFilters do not have any action. 
one sig NoAction extends Action{}{

}

one sig android_intent_category_DEFAULT_C extends Category{} 
one sig android_intent_category_LAUNCHER_C extends Category{}
one sig android_intent_action_MAIN_A extends Action{}

abstract sig DataScheme{}
abstract sig DataType{}

one sig NoMIMEType extends DataType{}
one sig NoScheme extends DataScheme{}
one sig YesScheme extends DataScheme{}

 sig Intent{
	sender: one Component,
	component: lone Component,
	action: one Action, //lone Action,
	dataType: one DataType,
	dataScheme: one DataScheme, 
	categories: set Category, //some Category, 
//	extra: one Extra // for synthesizer, we assume the Intent from the Source App should be Yes
							// otherwise, we need to add another field representing whether the Intent contains data (by flowdroid) or not
	detailedPaths: set DetailedPath
}


abstract sig Extra{}
one sig Yes extends Extra{}
one sig No extends Extra{}

abstract sig Permission{}


sig GeneratedExp{
	disj c1, c2,b: Component,
	disj i1,i2:Intent,
	disj d1,d2,dIntent,dComponent:DetailedPath
}{
	i1.sender = c1 
	no i1.component // i1 is an implicit Intent
	b in newIntentResolver[i1]
 	i2.sender = b
	c2 in setExplicitIntent[i2] //newIntentResolver[i2]

	no c1.app & c2.app 
	no c1.app & b.app
	no c2.app & b.app 

	c1.app in existingApps.apps
	c2.app in existingApps.apps
	
//	some i1.detailedPaths && i1.detailedPaths.sink = IPC && i1.detailedPaths.source != IPC  && i1.detailedPaths.source != UNDEFINED
//	some c2.detailedPaths && c2.detailedPaths.source = IPC && c2.detailedPaths.sink != IPC  && c2.detailedPaths.sink != UNDEFINED
	dIntent in i1.detailedPaths && dIntent.sink = IPC && //dIntent.source != IPC  && dIntent.source != UNDEFINED
	dIntent.source in SIGResource  // to reduce warnings
	dComponent in c2.detailedPaths && dComponent.source = IPC && //dComponent.sink != IPC  && dComponent.sink != UNDEFINED
	dComponent.sink in SIGResource  // to reduce warnings
	not (b.app in existingApps.apps)

	

	b in Activity
	#b.detailedPaths = 1
	b.detailedPaths = d2

	#i2.detailedPaths = 1
	i2.detailedPaths = d1
	
	d1.source = IPC_NEW
	d1.sink = IPC_NEW
	one d1.source 
	one d1.sink 

	d2.source = IPC_NEW
	d2.sink = IPC_NEW
	one d2.source 
	one d2.sink 	
}


sig GeneratedExpActivityLunch{
	disj c2,b: one Component,
	i2: Intent,
	dComponent: one DetailedPath
}{
 	i2.sender = b
	c2 in setExplicitIntent[i2]

	no c2.app & b.app 

	c2.app in existingApps.apps
	not (b.app in existingApps.apps)
	
	some i2.detailedPaths && i2.detailedPaths.sink = IPC && i2.detailedPaths.source = NEW	
//	some c2.detailedPaths && c2.detailedPaths.source = IPC && c2.detailedPaths.sink != IPC  && c2.detailedPaths.sink != UNDEFINED
	dComponent in c2.detailedPaths && dComponent.source = IPC && //dComponent.sink != IPC  && dComponent.sink != UNDEFINED
	dComponent.sink in SIGResource  // to reduce warnings

	b in Activity
	no b.detailedPaths 
	no b.intentFilter
}

sig GeneratedExpIntentHijack{
	disj c1, b: Component,
	i1:Intent,
	disj d1, dIntent:DetailedPath
}{
	i1.sender = c1 
	no i1.component // i1 is an implicit Intent
	b in newIntentResolver[i1]

	no c1.app & b.app

	c1.app in existingApps.apps
	not (b.app in existingApps.apps)

//	some i1.detailedPaths && i1.detailedPaths.sink = IPC && i1.detailedPaths.source != IPC  && i1.detailedPaths.source != UNDEFINED
	dIntent in i1.detailedPaths && dIntent.sink = IPC && //dIntent.source != IPC  && dIntent.source != UNDEFINED
	dIntent.source in SIGResource  // to reduce warnings
	
	b in Activity
	#b.detailedPaths = 1
	b.detailedPaths = d1

	
	d1.source = IPC
	d1.sink = NEW // the sink in generated component could be anything, e.g. SMS
	one d1.source 
	one d1.sink 

	
}





fun setExplicitIntent(i:Intent): set Component{
	{c:Component| 	some i.detailedPaths &&   some f: IntentFilter| f.~intentFilter in c && 
	some c.detailedPaths && 
	c = i.component && i.categories = android_intent_category_DEFAULT_C  && i.action = NoAction && i.dataType = NoMIMEType && i.dataScheme = NoScheme 
 }
}

fun newIntentResolver(i:Intent): set Component{
	{c:Component| 	//some i.detailedPaths && 
		{
       // Explicit Intent
		some i.component  implies {c = i.component}
       // Implicit Intent
		else {
					some f: IntentFilter| f.~intentFilter in c && i.action in f.actions
												&& i.categories in f.categories
												&& (i.dataScheme in f.dataScheme && i.dataType in f.dataType)  }
   } 
  }
}


assert  privEscal{
		no disj src, dst: Component, i:Intent| 
				(src in i.sender) &&  
				(dst in newIntentResolver[i]) &&
				some (dst.detailedPaths.sink & Resource) && 
				// The target application has a permission missing in the sender application and not being checked in the target component
				(some p: dst.app.usesPermissions | not (p in src.app.usesPermissions)  && not ((p in dst.compPermissions)||(p in dst.app.appPermissions)))						
}

fact noSimilarGeneratedExp{
	no disj t1,t2 : GeneratedExp| 	t1.c1 = t2.c1 &&
													t1.c2 = t2.c2 &&
													t1.b = t2.b 
}


//Added by Alireza
assert  InfoLeaksInterApp{
		no disj cmp1, cmp2: Component, i:Intent, disj d1,d2: DetailedPath| 
				cmp2 in newIntentResolver[i] &&
				i.sender in cmp1 &&
				d1 in i.detailedPaths && 
				d2 in cmp2.detailedPaths && 
				d1.source != IPC && d1.sink = IPC && d1.source != UNDEFINED && d1.source != NO_CATEGORY &&
				d2.source = IPC && d2.sink != IPC && d2.sink != UNDEFINED && d2.sink != NO_CATEGORY &&
				cmp1.app != cmp2.app
}

assert  InfoLeaksIntraApp{
		no disj cmp1, cmp2: Component, i:Intent, disj d1,d2: DetailedPath| 
				i.sender in cmp1 &&
				d1 in i.detailedPaths && 
				d2 in cmp2.detailedPaths && d2.source = IPC &&
				cmp1.app = cmp2.app &&
				i.component = cmp2
}


assert  InfoLeaksIntraAppTransitive1{
		 no disj cmp1, cmp2: Component, i:Intent, disj d1,d2: DetailedPath| 
				i.sender in cmp1 &&
				d1 in i.detailedPaths && d1.sink = IPC && //d1.source != IPC && d1.source != UNDEFINED && d1.source != NO_CATEGORY &&
				d1.source  in SIGResource && // to reduce warnings

				d2 in cmp2.detailedPaths && d2.source = IPC && //d2.sink != IPC && d2.sink != UNDEFINED && d2.sink != NO_CATEGORY &&
				d2.sink  in SIGResource && // to reduce warnings

				cmp1.app = cmp2.app &&
				i.component = cmp2
}

assert  InfoLeaksIntraAppTransitive2{
		 no /*disj*/ cmp1, intCmp, cmp2: Component, disj i1,i2:Intent, d1,d2,d3: DetailedPath| 
				i1.sender in cmp1 &&
				d1 in i1.detailedPaths &&
				d1.source != IPC && d1.sink = IPC && //d1.source != UNDEFINED && d1.source != NO_CATEGORY &&
				d1.source  in SIGResource && // to reduce warnings
				i1.component = intCmp &&

				i2.sender in intCmp &&
				d2 in i2.detailedPaths &&
				d2.source = IPC && d2.sink = IPC &&
				i2.component = cmp2 &&
 
				d3 in cmp2.detailedPaths && d3.source = IPC && //d3.sink != IPC && d3.sink != UNDEFINED && d3.sink != NO_CATEGORY &&
				d3.sink  in SIGResource && // to reduce warnings

				cmp1.app = cmp2.app && cmp2.app=  intCmp.app 
}

assert  InfoLeaksIntraAppTransitive3{
		 no /*disj*/ cmp1, intCmp1, intCmp2, cmp2: Component, disj i1,i2,i3:Intent, d1,d2,d3,d4: DetailedPath| 
				i1.sender in cmp1 &&
				d1 in i1.detailedPaths &&
				d1.source != IPC && d1.sink = IPC && //d1.source != UNDEFINED && d1.source != NO_CATEGORY &&
				d1.source  in SIGResource && // to reduce warnings
				i1.component = intCmp1 &&

				i2.sender in intCmp1 &&
				d2 in i2.detailedPaths &&
				d2.source = IPC && d2.sink = IPC &&
				i2.component = intCmp2 &&

				i3.sender in intCmp2 &&
				d3 in i3.detailedPaths &&
				d3.source = IPC && d3.sink = IPC &&
				i3.component = cmp2 &&
 
				d4 in cmp2.detailedPaths && d4.source = IPC && //d4.sink != IPC && d4.sink != UNDEFINED && d4.sink != NO_CATEGORY &&
				d4.sink  in SIGResource && // to reduce warnings

				cmp1.app = cmp2.app && cmp2.app=  intCmp1.app && cmp2.app=  intCmp2.app 
}

assert  InfoLeaksIntraAppTransitive4{
		 no /*disj*/ cmp1, intCmp1, intCmp2, intCmp3, cmp2: Component, disj i1,i2,i3,i4:Intent, d1,d2,d3,d4,d5: DetailedPath| 
				i1.sender in cmp1 &&
				d1 in i1.detailedPaths &&
				d1.source != IPC && d1.sink = IPC && //d1.source != UNDEFINED && d1.source != NO_CATEGORY &&
				d1.source  in SIGResource && // to reduce warnings
				i1.component = intCmp1 &&

				i2.sender in intCmp1 &&
				d2 in i2.detailedPaths &&
				d2.source = IPC && d2.sink = IPC &&
				i2.component = intCmp2 &&

				i3.sender in intCmp2 &&
				d3 in i3.detailedPaths &&
				d3.source = IPC && d3.sink = IPC &&
				i3.component = intCmp3 &&
 
				i4.sender in intCmp3 &&
				d4 in i4.detailedPaths &&
				d4.source = IPC && d4.sink = IPC &&
				i4.component = cmp2 &&

				d5 in cmp2.detailedPaths && d5.source = IPC && //d5.sink != IPC && d5.sink != UNDEFINED && d5.sink != NO_CATEGORY &&
				d5.sink  in SIGResource && // to reduce warnings
				cmp1.app = cmp2.app && cmp2.app=  intCmp1.app && cmp2.app=  intCmp2.app && cmp2.app=  intCmp3.app 
}
pred show(){
//	some IntentFilter
//	some Activity
//	some Provider
}
run show for 20
