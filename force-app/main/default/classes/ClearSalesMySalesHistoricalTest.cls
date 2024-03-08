/**
 * Author :Geeta Kushwaha, geeta.kushwaha@arxxus.com
 * @created date : 23/12/2013
 * Description : This class is test class for ClearSalesMySalesHistorical 
 */
@isTest
private class ClearSalesMySalesHistoricalTest {

    static testMethod void myUnitTest() {
        
        List <Sale_MySales_Historical__c> sales = new List<Sale_MySales_Historical__c>();
        
        for(integer i = 0; i<200; i++){
        
            sales.add(new Sale_MySales_Historical__c(Name='Sample '+i));
        
        }
        
        insert sales;
        
        Test.startTest();
        
        Database.executeBatch(new ClearSalesMySalesHistorical());
        
        Test.stopTest();
        
        system.assertEquals(0, [select Id from Sale_MySales_Historical__c].size());
        
    }
}