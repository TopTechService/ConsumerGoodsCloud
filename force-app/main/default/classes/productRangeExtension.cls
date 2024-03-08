public with sharing class productRangeExtension {
    
    public Account  theAccount {get;set;}
    public Product_Range__c [] productRangeList {get;set;}
    
    
    public productRangeExtension(ApexPages.StandardController controller) {
        
        // Get information about the BOM being worked on
        theAccount = [select Id, Name, Called_On__c from Account where Id = :controller.getRecord().Id limit 1];
        
        // If products were previously selected need to put them in the "selected products" section to start with
        productRangeList = [SELECT Id, Product__c , Product__r.Name, Account__c, Account__r.Name, count__c, 
                            In_Range__c, Last_Purchase_Date__c, Product__r.SKU_Name__c, Shelf_Price__c 
                            FROM Product_Range__c
                            WHERE Account__c =:theAccount.id 
                            ORDER by Product__r.Product_Category__c , Product__r.SKU_Name__c];
    }
    
    public PageReference onSave(){
        
        try{
            
            // Previously selected products may have new quantities and amounts, and we may have new products listed, so we use upsert here
            
            if(productRangeList.size()>0)
                upsert(productRangeList);
            
        }
        catch(Exception e){
            ApexPages.addMessages(e);
            return null;
        }
        
        // After save return the user to the Opportunity
        return new PageReference('/' + ApexPages.currentPage().getParameters().get('Id'));
    }
    
    public PageReference onCancel(){
        
        // If user hits cancel we commit no changes and return them to the Opportunity
        return new PageReference('/' + ApexPages.currentPage().getParameters().get('Id'));
    }
    
    
}