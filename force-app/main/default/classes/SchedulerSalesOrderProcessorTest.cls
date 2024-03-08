/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
 
 /**
  * @author : Gunwant Patidar
  * @description : this class covers the following classes
  				 1 SalesOrderProcessor
  				 2 SchedulerSalesOrderProcessor
  				 3 WholesalerAccountNumberHandler
  */
@isTest
public class SchedulerSalesOrderProcessorTest {
	public id recTypeId;
	
	public SchedulerSalesOrderProcessorTest(){
		ALM_Sales_Order_Data__c almsalesorderdata = new ALM_Sales_Order_Data__c();
		almsalesorderdata.Name = 'Order';
		almsalesorderdata.Apply_Bonus__c = 'N';
		almsalesorderdata.ApplyQda__c = 'N';
		almsalesorderdata.Back_Order__c = 'N';
		almsalesorderdata.Order_Type__c = 'T';
		almsalesorderdata.Product_Code_Type__c = 'M';
		almsalesorderdata.Supplier_Rep_Id__c = '75245001';
		almsalesorderdata.Trn_Approved__c = 'Y';
		almsalesorderdata.Trade_Loader_Order_Pick_Up_Days__c = 2;
		insert almsalesorderdata;
		
		ALM_Configuration__c almConfig = new ALM_Configuration__c();
		almConfig.Name = 'Configuration';
		almConfig.ContentType__c = 'text/xml';
		almConfig.Encoding__c = 'UTF-8';
		almConfig.Endpoint__c = 'https://testservices.metcash.com/almiorders';
		almConfig.Password__c = 'metcash1';
		almConfig.SoapAction__c = '';
		almConfig.Timeout__c = 120000;
		almConfig.Username__c = '75245001';
		
		insert almConfig;
		
		
		// insert custom settings
		ALM_User_Name_and_Region__c almUserNameAndRegion = new ALM_User_Name_and_Region__c();
		almUserNameAndRegion.name = 'TAS';
		almUserNameAndRegion.Rep_Id__c = '175001';
		almUserNameAndRegion.Password__c = 'fjdsfd';
		insert almUserNameAndRegion;
	}
	
	public void testMethodALM(){
		Test.StartTest();
		
			Account outlet = new Account();
			
			recTypeId = Utilities.getRecordTypeId('Account','Outlet');
			
			outlet = TestFactory.getAccount('ALM', recTypeId);
			outlet.My_Sales_Id__c = '12365';
			outlet.Outlet_ID__c = '2365836';
			outlet.Outlet_ID__c = '1';
			outlet.RecordTypeId = recTypeId;
			outlet.OwnerId = userInfo.getUserId();
			
			insert outlet;
		
			Account wholesaler = new Account();
			recTypeId = Utilities.getRecordTypeId('Account','Wholesaler');
			wholesaler = TestFactory.getAccount('ALM', recTypeId);
			wholesaler.Customer_Number__c = '12345';
			wholesaler.Wholesaler_ID__c = '1';
			
			insert wholesaler;
			
			// insert wholesaler Branch record
			Wholesaler_Branch__c wholesalerBranch = new  Wholesaler_Branch__c();
			wholesalerBranch = TestFactory.createWholeSalerBranch(wholesaler.id);
			wholesalerBranch.Wholesaler_Branch_Id__c = '1';
			wholesalerBranch.Wholesaler_ID__c = '1';
			wholesalerBranch.Wholesaler_Account__c = wholesaler.id;
			insert wholesalerBranch;			
			
			// create wholesaler Branch Outlet
			Wholesaler_Branch_Outlet__c wholesalerBranchOutlet = new Wholesaler_Branch_Outlet__c();
			wholesalerBranchOutlet = TestFactory.createWholeSalerBranchOutlet(outlet.id, wholesalerBranch.id);
			wholesalerBranchOutlet.Wholesaler_Branch_ID__c = '1';
			wholesalerBranchOutlet.Outlet_ID__c = '1';
			wholesalerBranchOutlet.Start_Date__c = system.today();
			wholesalerBranchOutlet.Customer_Number__c = '12800646';
			
			insert wholesalerBranchOutlet;			
			
			Sales_Order__c salesOrder = new Sales_Order__c();
			Id salesOrderRecordType= Utilities.getRecordTypeId('Sales_Order__c', 'Trade Loader Sales Order Drop 1');
			salesOrder = TestFactory.createSalesOrder(wholesaler.id, outlet.Id);
			salesOrder.Status__c = 'New Sales Order Created';
			salesOrder.RecordTypeId = salesOrderRecordType;
			salesOrder.Drop_1_Date__c = system.today()-1;
			salesOrder.Wholesaler_Account_Number__c = '12345678';
			insert salesOrder;
			
			// test SchedulerSalesOrderProcessor class
			SchedulerSalesorderProcessor sh1 = new SchedulerSalesorderProcessor();
		    String sch = '0 0 23 * * ?';
		    system.schedule('Test Territory Check', sch, sh1);
		Test.stopTest();

	}
	
	public void testMethodILG(){
		Test.StartTest();
			String ILG_SUCCESS_STATUS = 'Order placed in ILG';
			String ILG_FAILED_STATUS  = 'Order failed in ILG';
			String ILG_WAITING_STATUS  = 'Waiting for ACK';
			String SILG_FAILED_STATUS  = 'Order failed in SILG';
			String PARTIAL_STATUS = 'Partially Succeeded';
			String ILG_NEW_STATUS = 'New Sales Order-ILG';
			String ALM_SUCCESS_STATUS = 'Order placed in ALM';
			String ALM_FAILED_STATUS = 'Order failed in ALM';
			
			Account outlet = new Account();
			
			recTypeId = Utilities.getRecordTypeId('Account','Outlet');
			
			outlet = TestFactory.getAccount('ILG', recTypeId);
			outlet.My_Sales_Id__c = '12365';
			outlet.Outlet_ID__c = '2365836';
			outlet.RecordTypeId = recTypeId;
			outlet.OwnerId = userInfo.getUserId();
			insert outlet;
		
			Account wholesaler = new Account();
			recTypeId = Utilities.getRecordTypeId('Account','Wholesaler');
			wholesaler = TestFactory.getAccount('ILG', recTypeId);
			wholesaler.Customer_Number__c = '12345';
			wholesaler.Wholesaler_ID__c = '1';
			
			insert wholesaler;
			
			Sales_Order__c salesOrder = new Sales_Order__c();
			Id salesOrderRecordType= Utilities.getRecordTypeId('Sales_Order__c', 'Trade Loader Sales Order Drop 1');
			salesOrder = TestFactory.createSalesOrder(wholesaler.id, outlet.Id);
			salesOrder.Status__c = 'New Sales Order Created';
			salesOrder.RecordTypeId = salesOrderRecordType;
			salesOrder.Drop_1_Date__c = system.today()-1;
			salesOrder.Wholesaler_Account_Number__c = '12345678';
			insert salesOrder;
			
			// insert  Brand 
			Brand__c brand = new Brand__c();
			brand = TestFactory.getBrand('12345', 'CSGSSS');
			
			insert brand;
			
			// insert products
			Product__c productTest = new Product__c();
			productTest = TestFactory.createProduct(brand.id);
			productTest.Bottles_Per_Carton__c = 6;
			productTest.MLs_Per_Bottle__c = '500 ml';
			productTest.Brand_ID__c = '12345';
			
			insert productTest;
			
			// insert promotion products
			PromotionProduct__c promotionProduct = new PromotionProduct__c();
			promotionProduct.Name = 'Promotion Test';
			promotionProduct.Product__c = productTest.id;
			
			
			// insert line items
			list<Sales_Order_Product__c> salesOrderlineItemsList = new list<Sales_Order_Product__c>();
			
			Sales_Order_Product__c salesOrderLineItemSuccess = new Sales_Order_Product__c();
			salesOrderLineItemSuccess = TestFactory.createsalesOrderProduct(promotionProduct.id);
			salesOrderLineItemSuccess.Sales_Order__c = salesOrder.id;
			salesOrderLineItemSuccess.Quantity__c = 6.66;
			salesOrderlineItemsList.add(salesOrderLineItemSuccess);
			
			Sales_Order_Product__c salesOrderLineItemFailed = new Sales_Order_Product__c();
			salesOrderLineItemFailed = TestFactory.createsalesOrderProduct(promotionProduct.id);
			salesOrderLineItemFailed.Sales_Order__c = salesOrder.id;
			salesOrderLineItemSuccess.Quantity__c = 6.66;
			salesOrderlineItemsList.add(salesOrderLineItemFailed);
			
			Sales_Order_Product__c salesOrderLineItemWaiting = new Sales_Order_Product__c();
			salesOrderLineItemWaiting = TestFactory.createsalesOrderProduct(promotionProduct.id);
			salesOrderLineItemWaiting.Sales_Order__c = salesOrder.id;
			salesOrderLineItemSuccess.Quantity__c = 6.66;
			salesOrderlineItemsList.add(salesOrderLineItemWaiting);
			
			insert salesOrderlineItemsList;
			
			SchedulerSalesorderProcessor sh1 = new SchedulerSalesorderProcessor();
		    String sch = '0 0 23 * * ?';
		    system.schedule('Test Territory Check', sch, sh1);
		    
		    
		    // update  sales order products with different status 
		   
	    	salesOrderlineItemsList[0].Status__c = ILG_SUCCESS_STATUS;
	    	salesOrderlineItemsList[1].Status__c = ILG_FAILED_STATUS;
	    	salesOrderlineItemsList[2].Status__c = ILG_WAITING_STATUS;
	    	
	    	update salesOrderlineItemsList;
	    	    	
	    	
	    	// update with failed status
	    	salesOrderlineItemsList[0].Status__c = ILG_FAILED_STATUS;
	    	salesOrderlineItemsList[1].Status__c = ILG_FAILED_STATUS;
	    	salesOrderlineItemsList[2].Status__c = ILG_FAILED_STATUS;
	    	
	    	update salesOrderlineItemsList;
	    	
	    	// update with waiting for ack status
	    	salesOrderlineItemsList[0].Status__c = ILG_WAITING_STATUS;
	    	salesOrderlineItemsList[1].Status__c = ILG_WAITING_STATUS;
	    	salesOrderlineItemsList[2].Status__c = ILG_WAITING_STATUS;
		    
		    update salesOrderlineItemsList;
		    
		    // update with waiting for ack and success status 
	    	salesOrderlineItemsList[0].Status__c = ILG_WAITING_STATUS;
	    	salesOrderlineItemsList[1].Status__c = ILG_SUCCESS_STATUS;
	    	salesOrderlineItemsList[2].Status__c = ILG_SUCCESS_STATUS;
		    
		    update salesOrderlineItemsList;
		    
		    	
		    // update sales order products with failed line items
	    	salesOrderlineItemsList[0].Status__c = ILG_SUCCESS_STATUS;
	    	salesOrderlineItemsList[1].Status__c = ILG_SUCCESS_STATUS;
	    	salesOrderlineItemsList[2].Status__c = ILG_SUCCESS_STATUS;
	    	
	    	update salesOrderlineItemsList;
	    	
		    
		Test.stopTest();

	}
	
	public void testSuccessFailedLineItemScenerioALM(){
		Test.StartTest();
			
			String ALM_SUCCESS_STATUS = 'Order placed in ALM';
			String ALM_FAILED_STATUS = 'Order failed in ALM';
			
			Account outlet = new Account();
			
			recTypeId = Utilities.getRecordTypeId('Account','Outlet');
			
			outlet = TestFactory.getAccount('ILG', recTypeId);
			outlet.RecordTypeId = recTypeId;
			outlet.My_Sales_Id__c = '12365';
			outlet.Outlet_ID__c = '2365836';
			outlet.OwnerId = userInfo.getUserId();
			
			insert outlet;
		
			Account wholesaler = new Account();
			recTypeId = Utilities.getRecordTypeId('Account','Wholesaler');
			wholesaler = TestFactory.getAccount('ILG', recTypeId);
			wholesaler.Customer_Number__c = '12345';
			wholesaler.Wholesaler_ID__c = '1';
			
			insert wholesaler;
			
			Sales_Order__c salesOrder = new Sales_Order__c();
			Id salesOrderRecordType= Utilities.getRecordTypeId('Sales_Order__c', 'Trade Loader Sales Order Drop 1');
			salesOrder = TestFactory.createSalesOrder(wholesaler.id, outlet.Id);
			salesOrder.Status__c = 'New Sales Order Created';
			salesOrder.RecordTypeId = salesOrderRecordType;
			salesOrder.Drop_1_Date__c = system.today()-1;
			salesOrder.Wholesaler_Account_Number__c = '12345678';
			insert salesOrder;
			
			// insert  Brand 
			Brand__c brand = new Brand__c();
			brand = TestFactory.getBrand('12345', 'CSGSSS');
			
			insert brand;
			
			// insert products
			Product__c productTest = new Product__c();
			productTest = TestFactory.createProduct(brand.id);
			productTest.Bottles_Per_Carton__c = 6;
			productTest.MLs_Per_Bottle__c = '500 ml';
			productTest.Brand_ID__c = '12345';
			
			insert productTest;
			
			// insert promotion products
			PromotionProduct__c promotionProduct = new PromotionProduct__c();
			promotionProduct.Name = 'Promotion Test';
			promotionProduct.Product__c = productTest.id;
			
			
			// insert line items
			list<Sales_Order_Product__c> salesOrderlineItemsList = new list<Sales_Order_Product__c>();
			
			Sales_Order_Product__c salesOrderLineItemSuccess = new Sales_Order_Product__c();
			salesOrderLineItemSuccess = TestFactory.createsalesOrderProduct(promotionProduct.id);
			salesOrderLineItemSuccess.Sales_Order__c = salesOrder.id;
			salesOrderLineItemSuccess.Quantity__c = 6.66;
			salesOrderlineItemsList.add(salesOrderLineItemSuccess);
			
			Sales_Order_Product__c salesOrderLineItemFailed = new Sales_Order_Product__c();
			salesOrderLineItemFailed = TestFactory.createsalesOrderProduct(promotionProduct.id);
			salesOrderLineItemFailed.Sales_Order__c = salesOrder.id;
			salesOrderLineItemSuccess.Quantity__c = 6.66;
			salesOrderlineItemsList.add(salesOrderLineItemFailed);
		
			insert salesOrderlineItemsList;
		
	    	
	    	salesOrderlineItemsList[0].Status__c = ALM_SUCCESS_STATUS;
	    	salesOrderlineItemsList[1].Status__c = ALM_FAILED_STATUS;
	    	
	    	update salesOrderlineItemsList;
	    	
	  
		  
		    
		    // update ALM Failed and 
	    	salesOrderlineItemsList[0].Status__c = ALM_FAILED_STATUS;
	    	salesOrderlineItemsList[1].Status__c = ALM_FAILED_STATUS;
	    	
		  	update salesOrderlineItemsList;
		
	    	
	    	// update ALM success and 
	    	salesOrderlineItemsList[0].Status__c = ALM_SUCCESS_STATUS;
	    	salesOrderlineItemsList[1].Status__c = ALM_SUCCESS_STATUS;
	    	
		  	update salesOrderlineItemsList;
		  	
		  	
		    
		Test.stopTest();
		
	
	}
	
	public void testApprovedILGOrders(){
		Test.StartTest();
			
			String ALM_SUCCESS_STATUS = 'Order placed in ALM';
			String ALM_FAILED_STATUS = 'Order failed in ALM';
			
			Account outlet = new Account();
			
			recTypeId = Utilities.getRecordTypeId('Account','Outlet');
			
			outlet = TestFactory.getAccount('ILG', recTypeId);
			outlet.My_Sales_Id__c = '12365';
			outlet.Outlet_ID__c = '2365836';
			outlet.RecordTypeId = recTypeId;
			outlet.OwnerId = userInfo.getUserId();
			
			insert outlet;
			
			// insert wholesaler group
			
			Wholesaler_Group__c wGroup = new Wholesaler_Group__c(Wholesaler_Group_ID__c = '1', Name = 'ILG');
       		insert wGroup;
		
			Account wholesaler = new Account();
			recTypeId = Utilities.getRecordTypeId('Account','Wholesaler');
			wholesaler = TestFactory.getAccount('ILG', recTypeId);
			wholesaler.Customer_Number__c = '12345';
			wholesaler.Wholesaler_ID__c = '1';
			wholesaler.Wholesaler_Group__c = wGroup.id;
			
			insert wholesaler;
			
			// insert wholesaler Group Product 
			Wholesaler_Group_Product__c whGroupProduct = new Wholesaler_Group_Product__c();
			whGroupProduct.Product_ID__c = '1';
			whGroupProduct.Wholesaler_Group_ID__c = '1';
			whGroupProduct.Wholesaler_Product_Code__c = '123456';
			
			system.debug('whGroupProduct: '  +whGroupProduct);
			
			
			Sales_Order__c salesOrder = new Sales_Order__c();
			Id salesOrderRecordType= Utilities.getRecordTypeId('Sales_Order__c', 'Trade Loader Sales Order Drop 1');
			salesOrder = TestFactory.createSalesOrder(wholesaler.id, outlet.Id);
			salesOrder.Status__c = 'New Sales Order Created';
			salesOrder.RecordTypeId = salesOrderRecordType;
			salesOrder.Drop_1_Date__c = system.today()-1;
			salesOrder.Wholesaler_Account_Number__c = '12345678';
			insert salesOrder;
			
			// insert  Brand 
			Brand__c brand = new Brand__c();
			brand = TestFactory.getBrand('12345', 'CSGSSS');
			
			insert brand;
			
			// insert products
			Product__c productTest = new Product__c();
			productTest = TestFactory.createProduct(brand.id);
			productTest.Bottles_Per_Carton__c = 6;
			productTest.MLs_Per_Bottle__c = '500 ml';
			productTest.Brand_ID__c = '12345';
			productTest.Product_ID__c = '1';
			
			insert productTest;
			
			// insert Pricing 
			Pricing__c testPricing =  new Pricing__c();
			testPricing = TestFactory.createPricing(productTest.Product_ID__c);
			testPricing.Name = '1';
			testPricing.Product_ID__c = '1';
        	testPricing.Pricing_MySales_ID__c = 1;
			insert testPricing;
			
			// insert promotion products
			PromotionProduct__c promotionProduct = new PromotionProduct__c();
			promotionProduct.Name = 'Promotion Test';
			promotionProduct.Product__c = productTest.id;
			promotionProduct.Pricing__c = testPricing.id;
			
			insert promotionProduct;
			
			// insert line items
			list<Sales_Order_Product__c> salesOrderlineItemsList = new list<Sales_Order_Product__c>();
			
			Sales_Order_Product__c salesOrderLineItemSuccess = new Sales_Order_Product__c();
			salesOrderLineItemSuccess = TestFactory.createsalesOrderProduct(promotionProduct.id);
			salesOrderLineItemSuccess.Sales_Order__c = salesOrder.id;
			salesOrderLineItemSuccess.Quantity__c = 6.66;
			salesOrderlineItemsList.add(salesOrderLineItemSuccess);
			
			Sales_Order_Product__c salesOrderLineItemFailed = new Sales_Order_Product__c();
			salesOrderLineItemFailed = TestFactory.createsalesOrderProduct(promotionProduct.id);
			salesOrderLineItemFailed.Sales_Order__c = salesOrder.id;
			salesOrderLineItemSuccess.Quantity__c = 6.66;
			salesOrderlineItemsList.add(salesOrderLineItemFailed);
		
			insert salesOrderlineItemsList;
		
	    	
	    	salesOrder.Status__c = 'Order Approved';
	    	update salesOrder;
	    	
		    
		Test.stopTest();
	}
	
	
	public void testApprovedALMOrders(){
		Test.StartTest();
			
			String ALM_SUCCESS_STATUS = 'Order placed in ALM';
			String ALM_FAILED_STATUS = 'Order failed in ALM';
			
			Account outlet = new Account();
			
			recTypeId = Utilities.getRecordTypeId('Account','Outlet');
			
			outlet = TestFactory.getAccount('ALM', recTypeId);
			outlet.My_Sales_Id__c = '12365';
			outlet.Outlet_ID__c = '2365836';
			outlet.RecordTypeId = recTypeId;
			outlet.OwnerId = userInfo.getUserId();
			
			insert outlet;
		
			Account wholesaler = new Account();
			recTypeId = Utilities.getRecordTypeId('Account','Wholesaler');
			wholesaler = TestFactory.getAccount('ALM', recTypeId);
			wholesaler.Customer_Number__c = '12345';
			wholesaler.Wholesaler_ID__c = '1';
			
			insert wholesaler;
			
			Sales_Order__c salesOrder = new Sales_Order__c();
			Id salesOrderRecordType= Utilities.getRecordTypeId('Sales_Order__c', 'Trade Loader Sales Order Drop 1');
			salesOrder = TestFactory.createSalesOrder(wholesaler.id, outlet.Id);
			salesOrder.Status__c = 'New Sales Order Created';
			salesOrder.RecordTypeId = salesOrderRecordType;
			salesOrder.Drop_1_Date__c = system.today()-1;
			salesOrder.Wholesaler_Account_Number__c = '12345678';
			insert salesOrder;
			
			// insert  Brand 
			Brand__c brand = new Brand__c();
			brand = TestFactory.getBrand('12345', 'CSGSSS');
			
			insert brand;
			
			// insert products
			Product__c productTest = new Product__c();
			productTest = TestFactory.createProduct(brand.id);
			productTest.Bottles_Per_Carton__c = 6;
			productTest.MLs_Per_Bottle__c = '500 ml';
			productTest.Brand_ID__c = '12345';
			
			insert productTest;
			
			// insert promotion products
			PromotionProduct__c promotionProduct = new PromotionProduct__c();
			promotionProduct.Name = 'Promotion Test';
			promotionProduct.Product__c = productTest.id;
			
			
			// insert line items
			list<Sales_Order_Product__c> salesOrderlineItemsList = new list<Sales_Order_Product__c>();
			
			Sales_Order_Product__c salesOrderLineItemSuccess = new Sales_Order_Product__c();
			salesOrderLineItemSuccess = TestFactory.createsalesOrderProduct(promotionProduct.id);
			salesOrderLineItemSuccess.Sales_Order__c = salesOrder.id;
			salesOrderLineItemSuccess.Quantity__c = 6.66;
			salesOrderlineItemsList.add(salesOrderLineItemSuccess);
			
			Sales_Order_Product__c salesOrderLineItemFailed = new Sales_Order_Product__c();
			salesOrderLineItemFailed = TestFactory.createsalesOrderProduct(promotionProduct.id);
			salesOrderLineItemFailed.Sales_Order__c = salesOrder.id;
			salesOrderLineItemSuccess.Quantity__c = 6.66;
			salesOrderlineItemsList.add(salesOrderLineItemFailed);
		
			insert salesOrderlineItemsList;
		
	    	
	    	salesOrder.Status__c = 'Order Approved';
	    	update salesOrder;
	    	
		    
		Test.stopTest();
	}
	 
    static testMethod void myUnitTestALM() {
        // TO DO: implement unit test
        SchedulerSalesOrderProcessorTest test1 = new SchedulerSalesOrderProcessorTest();
        test1.testMethodALM();
    }
    
    static testMethod void myUnitTestILG() {
        // TO DO: implement unit test
        SchedulerSalesOrderProcessorTest test1 = new SchedulerSalesOrderProcessorTest();
        test1.testMethodILG();
    }
    
    static testMethod void myUnitTestALMSUccessFailed() {
        // TO DO: implement unit test
        SchedulerSalesOrderProcessorTest test1 = new SchedulerSalesOrderProcessorTest();
        test1.testSuccessFailedLineItemScenerioALM();
    }
    
    static testMethod void myUnitTestILGApproved() { 
        // TO DO: implement unit test
        SchedulerSalesOrderProcessorTest test1 = new SchedulerSalesOrderProcessorTest();
        test1.testApprovedILGOrders();
    }
    
    static testMethod void myUnitTestALMApproved() {
        // TO DO: implement unit test
        SchedulerSalesOrderProcessorTest test1 = new SchedulerSalesOrderProcessorTest();
        test1.testApprovedALMOrders();
    }
    
}