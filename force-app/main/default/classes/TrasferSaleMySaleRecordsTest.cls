@isTest
public class TrasferSaleMySaleRecordsTest {
    
    static testMethod void test1(){ 
         Sale_MySales__c sales = new Sale_MySales__c();
         Sales.Sale_Date__c = Date.today();
         Sales.Name = 'TestSales';
         Sales.OutletID__c = '23561';
         sales.ProductID__c = '12543';
         sales.Nine_LE__c = 12;
         sales.Sale_ExtId__c = 'TestSales';
         insert sales;
        
    	TrasferSaleMySaleRecords transfreSale = new TrasferSaleMySaleRecords(system.today().year());
          	database.executeBatch(transfreSale);
    }
}