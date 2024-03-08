({  
    getUploadedFiles : function(component, event){
        var action = component.get("c.getFiles");  
        action.setParams({  
            "recordId": component.get("v.recordId") 
        });      
        action.setCallback(this,function(response){  
            var state = response.getState();  
            
            if(state=='SUCCESS'){  
                var result = response.getReturnValue();           
                
                if (result.length > 0) {
                
                component.set("v.files",result);  
                component.set("v.OriginalFiles",result);
                }else{
                    console.log("No files found.");
                }
            }  else {
                 console.log("Error: " + state);
            }
            
            
        });  
        $A.enqueueAction(action);  
    },
    
    
   deleteUploadedFile : function(component, event) {  
        var action = component.get("c.deleteQuote");           
        action.setParams({
            "deleteRecordId": event.currentTarget.id            
        });  
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state=='SUCCESS'){  
                this.getUploadedFiles(component);
                component.set("v.showSpinner", false); 
                // show toast on Warranty deleted successfully
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "message": "Cocktail has been deleted successfully!",
                    "type": "success",
                    "duration" : 2000
                });
                toastEvent.fire();
            }  
        });  
        $A.enqueueAction(action);  
    },  
	
    sortBy: function(component, field) {

        var sortAsc = component.get("v.sortAsc"),

            sortField = component.get("v.sortField"),

            records = component.get("v.files");

        sortAsc = sortField != field || !sortAsc;

        records.sort(function(a,b){

            var t1 = a[field] == b[field],

                t2 = (!a[field] && b[field]) || (a[field] < b[field]);

            return t1? 0: (sortAsc?-1:1)*(t2?1:-1);

        });

        component.set("v.sortAsc", sortAsc);

        component.set("v.sortField", field);

        component.set("v.files", records);

        this.renderPage(component);


    }




})