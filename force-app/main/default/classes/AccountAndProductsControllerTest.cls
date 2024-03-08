@isTest
private class AccountAndProductsControllerTest{
    
    @isTest static void test_InsertSkus() {
        RecordType outLetAccountType = [SELECT id, Name FROM RecordType WHERE DeveloperName = 'Outlet' LIMIT 1];

        Account acc = TestFactory.getAccount('TestName', outLetAccountType.id);
        insert acc;

        Brand__c brand = TestFactory.getBrand('Brand 5', 'Brand 5sap');
        insert brand;

        Product__c prod = TestFactory.getProduct('Product1','Brand 5','Pid123','Glass','Glen Grant Glass');
        prod.SKU_Active__c = TRUE;
        insert prod;

        PageReference pageRef = Page.AccountAndProducts;

        Test.setCurrentPage(pageRef);

        ApexPages.StandardController con = new ApexPages.StandardController(acc);

        AccountAndProductsController accProPageObj = new AccountAndProductsController(con);

        Test.startTest();

        //SKU is Inserted
        accProPageObj.productId = prod.id;

        accProPageObj.createProduct();

        Test.stopTest();

        Outlet_SKUs__c outLetInsertedToTest = [SELECT id, Product__c, OutletAccount__c FROM Outlet_SKUs__c WHERE Product__c = : prod.id AND OutletAccount__c = : acc.id];

        System.assertEquals(prod.id, outLetInsertedToTest.Product__c);
    }
    
    @isTest static void test_DeleteSkus() {
        RecordType outLetAccountType = [SELECT id, Name FROM RecordType WHERE DeveloperName = 'Outlet' LIMIT 1];

        Account acc = TestFactory.getAccount('TestName', outLetAccountType.id);
        insert acc;

        Brand__c brand = TestFactory.getBrand('Brand 5', 'Brand 5sap');
        insert brand;

        Product__c prod = TestFactory.getProduct('Product1','Brand 5','Pid123','Glass','Glen Grant Glass');
        prod.SKU_Active__c = TRUE;
        insert prod;

        PageReference pageRef = Page.AccountAndProducts;

        Test.setCurrentPage(pageRef);

        ApexPages.StandardController con = new ApexPages.StandardController(acc);

        AccountAndProductsController accProPageObj = new AccountAndProductsController(con);

        Test.startTest();
        
        // SKU is inserted
        accProPageObj.productId = prod.id;

        accProPageObj.createProduct();

        //SKU is deleted
        accProPageObj.productId = prod.id;

        accProPageObj.createProduct();
        Test.stopTest();

        List<Outlet_SKUs__c> outLetInsertedToTest = [SELECT id, Product__c, OutletAccount__c FROM Outlet_SKUs__c WHERE Product__c = : prod.id AND OutletAccount__c = : acc.id];

        System.assertEquals(0, outLetInsertedToTest.size());
    }
    
}