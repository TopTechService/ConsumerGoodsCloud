public  without sharing  class cocktailsListByPVS {
	@AuraEnabled  
     public static List<PVS_Cocktails_on_menu__c> getFiles(String recordId){ 
   
                 
         List<PVS_Cocktails_on_menu__c> cocktailsList = [Select Name_cocktail__c, SKU__c, Brand__c from PVS_Cocktails_on_menu__c where PVS__c = :recordId];
        
         
         
         /*     
       Contact contact1 = [select accountId, id, firstname from contact where id = :recordId];
        
        system.debug('contact1.firstname: ' + contact1.firstname); 
         
        List<Warranty__c> Warranties = [SELECT Name, address__c, Property__Street__s, Account__r.name, Coils_Colours_Text__c, Account__c, Project_Name__c,
                                        Property_Owner__c, Type__c, Rollformer__c, Rollformer__r.Name, Installer__c,Status__c, Id FROM Warranty__c 
                                          where account__c = :contact1.accountId
                                        Order by Project_Name__c DESC
                                       ]; 
        
         system.debug('Warranties.Account.Name: ' + Warranties[0].Account__r.name); 
     */    
        return cocktailsList;
    } 
    
    @AuraEnabled  
    public static void deleteQuote(String deleteRecordId){ 
        List<PVS_Cocktails_on_menu__c> deleteRecords = [Select id from PVS_Cocktails_on_menu__c where id = :deleteRecordId];
        if(deleteRecords.size()>0){		
        	delete deleteRecords;
        }
        
    }  
}