/**
 * @Description : This test class is used to test DeleteDuplicateSalesBatch class 
 *
 */
@isTest
private class DeleteDuplicateSalesBatchTest {

    /**
    *  1 single record in database so no delete  
    */
    static testMethod void Test1() { 
        Test.startTest();
        // Create a Config Email configuration
        insert TestFactory.createEmailonfiguration();
        
        Sale_MySales__c  sales =  getCreatedSale('23456');
        insert sales; 
        
        DeleteDuplicateSalesBatch bb = new DeleteDuplicateSalesBatch();
        database.executeBatch(bb,200);
        list<Sale_MySales__c> salesList = getExsitingSales();
        Test.stopTest(); 
        system.assertEquals(salesList.size(), 1);    
    }
    
    /**
    *  2 records in database but bot are different Name so duplicate no delete 
    */
    static testMethod void Test2() { 
        Test.startTest();
        
        // Create a Config Email configuration
        insert TestFactory.createEmailonfiguration();
        
        
        
        Sale_MySales__c  sales =  getCreatedSale('23456');
        insert sales; 
        
        DeleteDuplicateSalesBatch bb = new DeleteDuplicateSalesBatch();
        sales = getCreatedSale('23459');
        insert sales;  
        
        database.executeBatch(bb,200);
        Test.stopTest();  
        
        list<Sale_MySales__c> salesList = getExsitingSales();
        system.assertEquals(salesList.size(), 2);
        
    }
     /**
    *  3 records in data base but one is duplicate so this old duplicate will delete through this test and 
    * there will be only 2 records in the database 
    */
    static testMethod void Test3() { 
        Test.startTest();
        
        // Create a Config Email configuration
        insert TestFactory.createEmailonfiguration();
        
        
        
        Sale_MySales__c  sales =  getCreatedSale('23456');
        insert sales; 
        
        sales = getCreatedSale('23459');
        insert sales;
        
        DeleteDuplicateSalesBatch bb = new DeleteDuplicateSalesBatch();
        
        //sales = getCreatedSale('23459');
        //sales.IsDulpicate__c = true;
        //insert sales;  
        
        database.executeBatch(bb,200);
        Test.stopTest();
        list<Sale_MySales__c> salesList = getExsitingSales();
        system.assertEquals(salesList.size(), 2);
        
    }
    
      /**
    *  4 records in data base but 3 records are same so out of these 3 records 2 old will delete through this test and 
    * there will be only 2 records in the database 
    */
     static testMethod void Test4() { 
        Test.startTest();
         
         // Create a Config Email configuration
        insert TestFactory.createEmailonfiguration();
        
         
        Sale_MySales__c  sales =  getCreatedSale('23456');
        insert sales; 
        
        sales = getCreatedSale('23459');
        insert sales; 
        
        //sales = getCreatedSale('23459');
        //sales.IsDulpicate__c = true;
        //insert sales;
         
        DeleteDuplicateSalesBatch bb = new DeleteDuplicateSalesBatch(); 
        //sales = getCreatedSale('23459');
        //sales.IsDulpicate__c = true;
        //insert sales;  
        
        database.executeBatch(bb,200);
        Test.stopTest();  
        
        list<Sale_MySales__c> salesList = getExsitingSales();
        system.assertEquals(salesList.size(), 2);
        
    }
    
    
    /**
    * This methode is used to create new sales record and get that record
    */
    private static Sale_MySales__c getCreatedSale(String SaleName){
    	Sale_MySales__c sale = new Sale_MySales__c();
    	sale.Name = SaleName;
    	sale.OutletID__c = '1235';
    	sale.ProductID__c = '1';
    	sale.Nine_LE__c = 1;
        sale.Sale_ExtId__c = SaleName;
    	return sale;
    }
    
    private static list<Sale_MySales__c> getExsitingSales(){
         String query = 'SELECT Banner_Group__c,Carton_Count__c,CreatedDate,Discount_Value__c,Id,Name,Nine_LE__c,OutletID__c,Outlet__c,'+
	                             'Product__c,Region_Id_Abbr__c,Region_Id_Formula__c,Region_Id__c,Sale_Date__c,Sale_Month_Year__c,Start_Date__c,'+
	                             'Wholesaler_Branch_ID__c,Wholesaler_Branch__c,Year__c'+ 
                          ' FROM Sale_MySales__c ORDER BY CreatedDate DESC';
        return database.query(query);  
    }
}