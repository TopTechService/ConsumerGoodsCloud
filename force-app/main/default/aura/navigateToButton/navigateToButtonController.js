({ 
    init : function(component, event, helper) {
   // Get the record ID attribute
   var natEvt =  $A.get("e.force:navigateToSObject");
    natEvt.setParams({
      "recordId": component.get("v.recId"),
        "slideDevName": "related"
    });
    
       // Open the record
    natEvt.fire();
	}
})