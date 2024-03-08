/*
 * Class Name - AutoApproveRecordsTest 
 * @author - Geeta Kushwaha (geeta.kushwaha@arxxus.com)
 * @Description - This class is test class for AutoApproveRecords
 * @created - 28-10-2013 [created by Geeta]
 * @modified - by Geeta Kushwaha on 7 Nov, 2013
 */
@isTest
private class AutoApproveRecordsTest {
	
	static void sendForApproval(Id recordId){        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();        
        req1.setComments('Submitting request for approval.');        
        req1.setObjectId(recordId);
        Approval.ProcessResult result = Approval.process(req1);        
        System.assert(result.isSuccess());
        System.assertEquals('Pending', result.getInstanceStatus(),'Instance Status'+result.getInstanceStatus());
    }
    
    static set<Id> insertSalesOrder(){
        Id recordTypeOutlet = Utilities.getRecordTypeId('Account', 'Outlet');        
        Id salesOrderRecordType= Utilities.getRecordTypeId('Sales_Order__c', 'Trade Loader Sales Order Drop 1');        
        Account acc1 = TestFactory.getAccount('Account1', recordTypeOutlet);           
        insert acc1;
        
        Account acc2 = TestFactory.getAccount('Account2', recordTypeOutlet);           
        insert acc2;
        
        Account wholesaler = new Account();        
        wholesaler = TestFactory.getAccount('ALM', Utilities.getRecordTypeId('Account','Wholesaler'));        
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
        
        return new set<Id>{salesOrder1.Id, salesOrder2.Id};        
    }

    static testMethod void approveRecordsTest() {    	
    	set<Id> salesOrderIdSet = insertSalesOrder();      	
    	for(Id soId : salesOrderIdSet)  {    		
    		sendForApproval(soId);    		
    	}   
                     
        test.startTest();        
        AutoApproveRecords.approveRecords(salesOrderIdSet);        
        test.stopTest();        
    }
    
    static testMethod void setX5_Hours_Since_Order_CreationToFalseTest() {
        set<Id> salesOrderIdSet = insertSalesOrder();          
        list <Sales_Order__c> soList = [select Id, X5_Hours_Since_Order_Creation__c
                                        from Sales_Order__c
                                        where Id IN: salesOrderIdSet];                                        
        for(Sales_Order__c so : soList) {            
            so.X5_Hours_Since_Order_Creation__c = true;            
        }      
        ALM_Configuration__c customConfigSetting = new ALM_Configuration__c ( name = 'Configuration', Username__c = 'TestUser', Password__c = 'pa$$wd');
        insert customConfigSetting;
		
		ALM_Sales_Order_Data__c customSalesOrderSetting = new ALM_Sales_Order_Data__c (name='Order', Supplier_Rep_Id__c = '789654123');
       	insert customSalesOrderSetting;
        
        update soList;
                     
        test.startTest();        
        AutoApproveRecords.setX5_Hours_Since_Order_CreationToFalse(salesOrderIdSet);        
        test.stopTest();
        
        list <Sales_Order__c> soList1 = [select Id, X5_Hours_Since_Order_Creation__c
                                        from Sales_Order__c
                                        where Id IN: salesOrderIdSet];                                        
        for(Sales_Order__c so : soList1) {        	
        	System.assertEquals(so.X5_Hours_Since_Order_Creation__c, false);        	
        }
    }
    
}