/**
 */
@isTest
private class findUplicateSalesBatchTest {

    static testMethod void myUnitTest() {
        Test.startTest();
	        Sale_MySales__c  sales1 =  getCreatedSale('23454');
	        insert sales1; 
	        
	        Sale_MySales__c  sales2 =  getCreatedSale('23456');
	        insert sales2;
	           
	        //Sale_MySales__c  sales3 =  getCreatedSale('23456');
	        //insert sales3;
	        
	        
	        findUplicateSalesBatch bb = new findUplicateSalesBatch(); 
	        database.executeBatch(bb,200);
        Test.stopTest();  
        
        Sale_MySales__c sal1 = getExsitingSales(sales1.id);
        system.debug('====sal1=======' + sal1);
        system.assertEquals(sal1.isChecked__c, true);  
        system.assertEquals(sal1.IsDulpicate__c, false);
        
        Sale_MySales__c sal2 = getExsitingSales(sales2.id);
        system.debug('====sal2=======' + sal2); 
        system.assertEquals(sal2.isChecked__c, true);
        system.assertEquals(sal2.IsDulpicate__c, false);
        
        // Redundant - Sale_ExtId__c is now unique
        //Sale_MySales__c sal3 = getExsitingSales(sales3.id);
        //system.debug('====sal3=======' + sal3);
        //system.assertEquals(sal3.isChecked__c, true);
        //system.assertEquals(sal3.IsDulpicate__c, true);
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
    
    private static Sale_MySales__c getExsitingSales(Id idSet){
         String query = 'SELECT Banner_Group__c,isChecked__c,Carton_Count__c,IsDulpicate__c,CreatedDate,Discount_Value__c,Id,Name,Nine_LE__c,OutletID__c,Outlet__c,'+
	                             'Product__c,Region_Id_Abbr__c,Region_Id_Formula__c,Region_Id__c,Sale_Date__c,Sale_Month_Year__c,Start_Date__c,'+
	                             'Wholesaler_Branch_ID__c,Wholesaler_Branch__c,Year__c'+ 
                          ' FROM Sale_MySales__c WHERE Id =:idSet ORDER BY CreatedDate DESC';
        return database.query(query);  
    }
}