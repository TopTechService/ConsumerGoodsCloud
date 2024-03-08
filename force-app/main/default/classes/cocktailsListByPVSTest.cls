@isTest
private class cocktailsListByPVSTest {

    @isTest
    static void testGetFiles() {
        // Insert test data
        // 
       Account acc = new account(Name = 'Test account');
        insert acc;
        // 
        // 
        PVS__c pvs = new PVS__c(Account__c = acc.id);
        insert pvs;

        PVS_Cocktails_on_menu__c cocktail1 = new PVS_Cocktails_on_menu__c(cocktail__c = 'Americano', SKU__c = 'Campari 1L', Brand__c = 'Campari', PVS__c = pvs.Id);
        PVS_Cocktails_on_menu__c cocktail2 = new PVS_Cocktails_on_menu__c(cocktail__c = 'Aperol Spritz', SKU__c = 'Aperol 700ml', Brand__c = 'Aperol', PVS__c = pvs.Id);
        insert new List<PVS_Cocktails_on_menu__c> {cocktail1, cocktail2};

        // Call the method being tested
        Test.startTest();
        List<PVS_Cocktails_on_menu__c> result = cocktailsListByPVS.getFiles(pvs.Id);
        Test.stopTest();

        // Verify the result
        System.assertEquals(2, result.size());
        //System.assertEquals('Americano', result[0].Name_cocktail__c);
        System.assertEquals('Campari 1L', result[0].SKU__c);
        System.assertEquals('Campari', result[0].Brand__c);
      //  System.assertEquals('Aperol Spritz', result[1].Name_cocktail__c);
        System.assertEquals('Aperol 700ml', result[1].SKU__c);
        System.assertEquals('Aperol', result[1].Brand__c);
    }

    @isTest
    static void testDeleteQuote() {
        // Insert test data
        
        // 
        Account acc2 = new account(Name = 'Test account 2');
        insert acc2;
        // 
        // 
        PVS__c pvs = new PVS__c(Account__c = acc2.id);
        insert pvs;

        PVS_Cocktails_on_menu__c cocktail = new PVS_Cocktails_on_menu__c(cocktail__c = 'Americano', SKU__c = 'Campari 1L', Brand__c = 'Campari', PVS__c = pvs.Id);
        insert cocktail;

        // Call the method being tested
        Test.startTest();
        cocktailsListByPVS.deleteQuote(cocktail.Id);
        Test.stopTest();

        // Verify the record is deleted
       
    }
}