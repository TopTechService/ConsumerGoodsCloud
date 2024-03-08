/**
 * This test class is used to test FindOutDuplicateSalesRecordBatch class 
 */

@isTest
private class FindOutDuplicateSalesRecordBatchTest {
	
	private static integer nameCounter = 0;
    /**
    *  1 single record in database so no delete 
    */   
    static testMethod void Test1() {       
        Test.startTest();
        nameCounter = 0;
        list<Sale_MySales__c>  salesListTest =  getListOfCreatedSale(50);
        insert salesListTest; 
        FindOutDuplicateSalesRecordBatch bb = new FindOutDuplicateSalesRecordBatch();        
        database.executeBatch(bb,200);
        list<Sale_MySales__c> salesList = getExsitingSales(new set<String>{'23456','23459'});
        Test.stopTest(); 
        system.assertEquals(salesList.size(), 0);    
    }
    
    /**
    *  2 records in database but bot are different Name so duplicate no delete 
    */
    static testMethod void Test2() { 
        Test.startTest();
        nameCounter = 0;
        list<Sale_MySales__c>  salesListTest =  getListOfCreatedSale(1);
        insert salesListTest; 
        
        Sale_MySales__c  sales =  getCreatedSale('23456');
        insert sales; 
        
        
        FindOutDuplicateSalesRecordBatch bb = new FindOutDuplicateSalesRecordBatch();
        sales = getCreatedSale('23459');
        insert sales;  
        
        database.executeBatch(bb,200);
        Test.stopTest();  
        
        list<Sale_MySales__c> salesList = getExsitingSales(new set<String>{'23456','23459'});
        system.assertEquals(salesList.size(), 2);
        for(Sale_MySales__c sales1 : salesList){
        	system.assertEquals(sales1.IsDulpicate__c,false);
        }
        
    }
     /**
    *  3 records in data base but one is duplicate so this old duplicate will delete through this test and 
    * there will be only 2 records in the database 
    */
    static testMethod void Test3() { 
        Test.startTest();
        nameCounter = 0;
        list<Sale_MySales__c>  salesListTest =  getListOfCreatedSale(1);
        insert salesListTest; 
        
        Sale_MySales__c  sales =  getCreatedSale('23456');
        insert sales; 
        
        sales = getCreatedSale('23459');
        insert sales;
        //sales = getCreatedSale('23459');
        //insert sales;
          
        FindOutDuplicateSalesRecordBatch bb = new FindOutDuplicateSalesRecordBatch();
        database.executeBatch(bb,200);
        Test.stopTest();
        list<Sale_MySales__c> salesList = getExsitingSales(new set<String>{'23456','23459'});
        system.debug('====getExsitingSales======' + salesList);
    } 
    
    /**
    *  4 records in data base but 3 records are same so out of these 3 records 2 old will delete through this test and 
    * there will be only 2 records in the database 
    */
     static testMethod void Test4() { 
        Test.startTest();
        nameCounter = 0;
        list<Sale_MySales__c>  salesListTest =  getListOfCreatedSale(1);
        insert salesListTest; 
         
        Sale_MySales__c  sales =  getCreatedSale('23456');
        insert sales; 
        
        sales = getCreatedSale('23459');
        insert sales; 
        
        //sales = getCreatedSale('23459');
        //insert sales;
        
        //sales = getCreatedSale('23459');
        //insert sales;  
        
        FindOutDuplicateSalesRecordBatch bb = new FindOutDuplicateSalesRecordBatch(); 
        database.executeBatch(bb,200);
        Test.stopTest();   
        
        list<Sale_MySales__c> salesList = getExsitingSales(new set<String>{'23456','23459'});
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
    
    private static list<Sale_MySales__c> getListOfCreatedSale(Integer noOfSales){
    	list<Sale_MySales__c> salesList = new list<Sale_MySales__c>();
    	
    	for(Integer i=0;i<noOfSales;i++){
    		Sale_MySales__c sale = new Sale_MySales__c();
	    	sale.Name = string.valueOf(nameCounter++);
	    	sale.OutletID__c = '1235';
	    	sale.ProductID__c = '1';
	    	sale.Nine_LE__c = 1;
            sale.Sale_ExtId__c = string.valueOf(nameCounter++);
	    	salesList.add(sale);
    	}
    	return salesList;
    }
    
    private static list<Sale_MySales__c> getExsitingSales(set<string> idSet){
         String query = 'SELECT Banner_Group__c,Carton_Count__c,IsDulpicate__c,CreatedDate,Discount_Value__c,Id,Name,Nine_LE__c,OutletID__c,Outlet__c,'+
	                             'Product__c,Region_Id_Abbr__c,Region_Id_Formula__c,Region_Id__c,Sale_Date__c,Sale_Month_Year__c,Start_Date__c,'+
	                             'Wholesaler_Branch_ID__c,Wholesaler_Branch__c,Year__c'+ 
                          ' FROM Sale_MySales__c WHERE name IN:idSet ORDER BY CreatedDate DESC';
        return database.query(query);  
    }
}