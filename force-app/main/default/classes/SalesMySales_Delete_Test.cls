@istest
public class SalesMySales_Delete_Test {
    
    static testMethod void deleteRecord() {
        
		Sale_MySales__c sale = new Sale_MySales__c();
         Sale.Sale_Date__c = Date.today();
         Sale.Name = 'TestSales';
         Sale.OutletID__c = '23561';
         sale.ProductID__c = '12543';
         sale.Nine_LE__c = 12;
         sale.Sale_ExtId__c = 'TestSales';
         insert sale;
        List<Sale_MySales__c> sales = new List<Sale_MySales__c>();
        sales.add(sale);
        
        SalesMySales_Delete.SalesMySales_Delete(sales);
    }
    
}