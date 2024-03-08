@isTest
private class getControllingPicklistValueTest {
    
    private static testMethod void testCreateCocktails() {
            
        // Create test data
       // PVS_PSS_Brand__c brand = new PVS_PSS_Brand__c(Brand_Name__c = 'Campari');
     //   insert brand;
      
      //  PVS_Cocktails_on_menu__c cocktail = new PVS_Cocktails_on_menu__c(Cocktail_single__c = 'Test Cocktail', BrandSKU__c = 'Test SKU');
       // insert cocktail;
        
        Account acc = new account(Name='test account');
        insert acc;
        
        PVS__c newPVS = new PVS__c(Account__c = acc.id);
        insert newPVS;
        
        getControllingPicklistValue.FlowInformation flowInfo = new getControllingPicklistValue.FlowInformation();
        flowInfo.cocktail = 'Negroni';
        flowInfo.pvsId = newPVS.id;
        flowInfo.selectedSKUs = new List<String>{'Campari 1L','Campari 700ml'};
        flowInfo.customName = false;
        
        Test.startTest();
         getControllingPicklistValue.createCocktails(new list<getControllingPicklistValue.FlowInformation> {flowInfo});
        Test.stopTest();
        
        // Verify that the record was created
        List<PVS_Cocktails_on_menu__c> cocktails = [SELECT Id, Cocktail_single__c FROM PVS_Cocktails_on_menu__c WHERE Cocktail_single__c = 'Negroni'];
        System.assertEquals(2, cocktails.size());
        System.assertEquals('Negroni', cocktails[0].Cocktail_single__c);
        
        
        
        
    }
    
}