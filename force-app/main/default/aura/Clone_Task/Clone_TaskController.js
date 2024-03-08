({      
    doClone : function(component, event, helper) {
        var nameField = component.find("task");
        var expname = component.get("v.recordId");
        //var accountid = component.get("v.id");
        var accountid = component.get("v.selectedLookUpRecord").Id;
        var action = component.get("c.cloneObject");
        
        var btn = event.getSource();
        btn.set("v.disabled",true);//Disable the button
        btn.set("v.label","Cloning Task - Please wait");//Disable the button
        
        //alert("From expname: " + expname);
        //alert("From accountid: " + accountid);
        action.setParams({ "recordId" : expname , "AccountId" : accountid });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                //alert("From server: " + response.getReturnValue());
                var newTask= response.getReturnValue();
                
                // Display popup confirmation to the user
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Saved ",
                    "message": "The record was cloned."});
                resultsToast.fire();
                
                // Display newly cloned object
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": newTask ,
                    "slideDevName": "related"});
                navEvt.fire();
                
                // Display newly cloned object in edit mode
                //var editRecordEvent = $A.get("e.force:editRecord");
                //editRecordEvent.setParams({
                //  "recordId": newTask });
                //editRecordEvent.fire();
                
                
            }
            
            else if (state === "INCOMPLETE") {
            }
            
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        
        $A.enqueueAction(action);
    },
    
    
    save : function(component, event, helper) {
        
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/00T/o"
        });
        urlEvent.fire();
        
    },
    
})