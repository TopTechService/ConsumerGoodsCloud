@isTest
private class ILGSplitBonusOrderTest {
    
    @isTest static void testSplitOrderForIndependentMaster() {
        Test.startTest();
        List<Sales_Order__c> salesOrders = insertSalesOrder();
        List<Sales_Order_Product__c> salesOrderProducts = insertIndepSalesOrderProducts(salesOrders);
        Set<id> orderIdSet = new Set<id>();
        for (Sales_Order__c ord : salesOrders) {
            orderIdSet.add(ord.id);
        }
        ILGSplitBonusOrder handler = new ILGSplitBonusOrder();			
        handler.splitOrder(orderIdSet);
        Test.stopTest();
    }
    
    @isTest static void testSplitOrderDependentMasterAndChild() {
        Set<Id> newOrderIdSet = new Set<Id>();
        Test.startTest();
        // Create a Config Email configuration
        insert TestFactory.createEmailonfiguration();
        
        List<Sales_Order__c> salesOrders = insertSalesOrder();
        List<Sales_Order_Product__c> salesOrderProducts = insertDepSalesOrderProducts(salesOrders);
        Set<id> orderIdSet = new Set<id>();
        for (Sales_Order__c ord : salesOrders) {
            orderIdSet.add(ord.id);
        }
        ILGSplitBonusOrder handler = new ILGSplitBonusOrder();			
        newOrderIdSet = handler.splitOrder(orderIdSet);
        Test.stopTest();
        System.assertEquals(newOrderIdSet.size(), 2);
    }
    
    
    @isTest static void testSplitOrderForIndependentChild() {
        
    }		
    
    @isTest static void testSplitOrderIndepMasterAndIndepChild() {
        // Implement test code
    }
    
    static List<Sales_Order__c> insertSalesOrder(){
        Id recordTypeOutlet = Utilities.getRecordTypeId('Account', 'Outlet');        
        Id salesOrderRecordType= Utilities.getRecordTypeId('Sales_Order__c', 'Standard Sales Order');        
        Account acc1 = TestFactory.getAccount('Account1', recordTypeOutlet);           
        insert acc1;
        
        Account acc2 = TestFactory.getAccount('Account2', recordTypeOutlet);           
        insert acc2;
        
        Account wholesaler = new Account();        
        wholesaler = TestFactory.getAccount('ILG', Utilities.getRecordTypeId('Account','Wholesaler'));        
        wholesaler.Customer_Number__c = '12345';        
        wholesaler.Wholesaler_ID__c = '1';        
        insert wholesaler;
        
        Sales_Order__c salesOrder1 = TestFactory.createSalesOrder(wholesaler.id, acc1.Id);        
        salesOrder1.Status__c = 'New Sales Order Created';
        
        salesOrder1.RecordTypeId = salesOrderRecordType;        
        salesOrder1.Drop_1_Date__c = system.today()-2;        
        salesOrder1.Wholesaler_Account_Number__c = '12345678';        
        salesOrder1.Send_Approval_for_discount__c = true;        
        insert salesOrder1;
        
        Sales_Order__c salesOrder2 = TestFactory.createSalesOrder(wholesaler.id, acc1.Id);        
        salesOrder2.Status__c = 'New Sales Order Created';        
        salesOrder2.RecordTypeId = salesOrderRecordType;        
        salesOrder2.Drop_1_Date__c = system.today()-2;        
        salesOrder2.Wholesaler_Account_Number__c = '12345678';        
        salesOrder2.Send_Approval_for_quantity__c = true;        
        insert salesOrder2;
        
        return new List<Sales_Order__c> {salesOrder1, salesOrder2};        
            }	
    
    static List<Sales_Order_Product__c> insertIndepSalesOrderProducts(List<Sales_Order__c> salesOrders) {
        PromotionProduct__c prmprdct = TestFactory.createPromotionProduct();
        List<Sales_Order_Product__c> productList = new List<Sales_Order_Product__c>();
        for (Sales_Order__c order : salesOrders) {						
            Sales_Order_Product__c product = new Sales_Order_Product__c();
            product.PromotionProduct__c = prmprdct.id;
            product.Bonus_Status__c = 'Independent';
            product.Sales_Order__c = order.id;
            product.Quantity__c = 10;
            // product.Total_Applied_Discount2__c       
            product.Discount__c = 5;
            productList.add(product);
        }				        
        insert productList;
        
        return productList;        
    }
    
    static List<Sales_Order_Product__c> insertDepSalesOrderProducts(List<Sales_Order__c> salesOrders) {
        PromotionProduct__c prmprdct = TestFactory.createPromotionProduct();
        List<Sales_Order_Product__c> productList = new List<Sales_Order_Product__c>();
        for (Sales_Order__c order : salesOrders) {						
            Sales_Order_Product__c product = new Sales_Order_Product__c();
            product.PromotionProduct__c = prmprdct.id;
            product.Bonus_Status__c = 'Dependent Master';		        
            product.Sales_Order__c = order.id;
            product.Quantity__c = 10;
            product.Total_Quantity_Including_Bonus__c = 15;
            // product.Total_Applied_Discount2__c       
            product.Discount__c = 5;
            product.Total_Applied_Discount2__c = 5;
            product.Total_Price__c = 100;
            
            Sales_Order_Product__c product1 = new Sales_Order_Product__c();
            product1.PromotionProduct__c = prmprdct.id;
            product1.Bonus_Status__c = 'Dependent Child';
            product1.Sales_Order__c = order.id;
            product1.Quantity__c = 5;
            // product.Total_Applied_Discount2__c       
            product1.Discount__c = 0;	
            product1.Total_Price__c = 0;
            product.Total_Applied_Discount2__c = 0;	        
            productList.add(product);
            productList.add(product1);
        }				        
        insert productList;
        
        return productList;        
    }    
    
    
}