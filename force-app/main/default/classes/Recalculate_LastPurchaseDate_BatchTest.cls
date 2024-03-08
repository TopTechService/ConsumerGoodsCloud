@isTest
public class Recalculate_LastPurchaseDate_BatchTest {
    
    @isTest
    private static void testBatch() {
        // Create Account
        List<Account> listAccount = new List<Account>();
        for (Integer i=0; i<5; i++) {
            Account account = new Account();
            account.Name = 'TEST ACCOUNT ' + i;
            listAccount.add(account);
        }
        insert listAccount;

        // Create Brand
        Brand__c brand = new Brand__c();
        brand.Name = 'TEST BRAND';
        brand.Brand_ID__c = '777';
        insert brand;

        // Create Product
        List<Product__c> listProduct = new List<Product__c>();
        for (Integer i=0; i<5; i++) {
            Product__c product = new Product__c();
            product.Name = 'TEST PRODUCT ' + i;
            product.Brand__c = brand.Id;
            product.Brand_ID__c = brand.Brand_ID__c;
            product.Product_ID__c = '777' + i;
            listProduct.add(product);
        }
        insert listProduct;

        // Create Sale_MySales__c
        List<Sale_MySales__c> listSaleMySales = new List<Sale_MySales__c>();
        for (Integer i=0; i<5; i++) {
            Sale_MySales__c saleMySales = new Sale_MySales__c();
            saleMySales.Name = 'TEST SALEMYSALES';
            saleMySales.Outlet__c = listAccount[i].Id;
            saleMySales.Product__c = listProduct[i].Id;
            saleMySales.Sale_Date__c = Date.newinstance(2019, 09, 1 + i);
            // saleMySales.Sale_Date__c = Date.today();
            saleMySales.OutletID__c = listAccount[i].Id;
            saleMySales.ProductID__c = listProduct[i].Id;
            saleMySales.Sale_ExtId__c = '101010101010' + i;
            listSaleMySales.add(saleMySales);
        }
        // Create duplicate of record 
        Sale_MySales__c newSaleMySales = new Sale_MySales__c();
        newSaleMySales.Name = 'TEST SALEMYSALES';
        newSaleMySales.Outlet__c = listAccount[0].Id;
        newSaleMySales.Product__c = listProduct[0].Id;
        newSaleMySales.Sale_Date__c = Date.newinstance(2019, 09,1);
        //newSaleMySales.Sale_Date__c = Date.today();
        newSaleMySales.OutletID__c = listAccount[0].Id;
        newSaleMySales.ProductID__c = listProduct[0].Id;
        newSaleMySales.Sale_ExtId__c = '1010101010107';
        listSaleMySales.add(newSaleMySales);
        insert listSaleMySales;

        // Create Product Range
        List<Product_Range__c> listProductRange = new List<Product_Range__c>();
        for (Integer i=0; i<5; i++) {
            Product_Range__c productRange = new Product_Range__c();
            productRange.Account__c = listAccount[i].Id;
            productRange.Product__c = listProduct[i].Id;
            productRange.Last_Purchase_Date__c = Date.newinstance(2017, 1, 1 + i);
            listProductRange.add(productRange);
        }
        insert listProductRange;


        listProductRange = [SELECT Id, Last_Purchase_Date__c FROM Product_Range__c ORDER BY Last_Purchase_Date__c ASC];
        for(Integer i=0; i<5; i++){
            System.assertEquals(2017, listProductRange[i].Last_Purchase_Date__c.year());
        }
        //Recalculate_LastPurchaseDate.runRecalculate();
        Test.startTest();
        Database.executeBatch(new Recalculate_LastPurchaseDate_Batch(), 200);
        Test.stopTest();

        listProductRange = [SELECT Id, Last_Purchase_Date__c FROM Product_Range__c ORDER BY Last_Purchase_Date__c ASC];
        for(Integer i=0; i<5; i++){
            System.assertEquals(2019, listProductRange[i].Last_Purchase_Date__c.year());
        }
    }

}