({
    doInit : function(component, event, helper){  
        
    helper.getUploadedFiles(component, event);
    
    },  

	sortByName: function(component, event, helper) {

        helper.sortBy(component, "Name_cocktail__c");
    },
    
    
    sortBySKU: function(component, event, helper) {

        helper.sortBy(component, "SKU__c");
    },
    
    
    sortByBrand: function(component, event, helper) {

        helper.sortBy(component, "Brand__c");
    },
    
    
    
    
  	editCoilList : function(component, event, helper){
        component.set('v.GoToScreen',333);
        component.set('v.selectedRecord', event.currentTarget.id);
        var actionClicked = "NEXT";
        var navigate = component.get('v.navigateFlow');
      	navigate(actionClicked);
  
    },
       
    editSelectedFile : function(component, event, helper){
        component.set('v.GoToScreen',222);
        component.set('v.selectedRecord', event.currentTarget.id);
        var actionClicked = "NEXT";
        var navigate = component.get('v.navigateFlow');
      	navigate(actionClicked);
  
    },
    
    displaySelectedFile : function(component, event, helper){
        component.set('v.GoToScreen',444);
        component.set('v.selectedRecord', event.currentTarget.id);
        var actionClicked = "NEXT";
        var navigate = component.get('v.navigateFlow');
      	navigate(actionClicked);
  
    },
    
    
    deleteSelectedFile : function(component, event, helper){
        if( confirm("Confirm deleting this cocktail?")){
            component.set("v.showSpinner", true); 
            helper.deleteUploadedFile(component, event);                  
        }
    }
    
  
    
    
    
 })