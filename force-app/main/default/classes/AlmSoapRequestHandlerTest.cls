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
@isTest
public class AlmSoapRequestHandlerTest {
	Id recTypeId;
	Sales_Order_Product__c salesOrderLineItemSuccess;
	Sales_Order__c salesOrder;
	public AlmSoapRequestHandlerTest(){
		ALM_User_Name_and_Region__c almUserNameAndRegion = new ALM_User_Name_and_Region__c();
		almUserNameAndRegion.name = 'NSW';
		almUserNameAndRegion.Rep_Id__c = '175001';
		almUserNameAndRegion.Password__c = 'fjdsfd';
		insert almUserNameAndRegion;
		
		
		//insert custom settings
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
		
		// insert sales order data custom settings
		ALM_Sales_Order_Data__c almsalesorderdata = new ALM_Sales_Order_Data__c();
		almsalesorderdata.Name = 'Order';
		almsalesorderdata.Apply_Bonus__c = 'N';
		almsalesorderdata.ApplyQda__c = 'N';
		almsalesorderdata.Back_Order__c = 'N';
		almsalesorderdata.Order_Type__c = 'T';
		almsalesorderdata.Product_Code_Type__c = 'M';
		almsalesorderdata.Supplier_Rep_Id__c = '75245001';
		almsalesorderdata.Trn_Approved__c = 'Y';
		
		insert almsalesorderdata;
		

		Account outlet = new Account();
		
		recTypeId = Utilities.getRecordTypeId('Account','Outlet');
		
		outlet = TestFactory.getAccount('ALM outlet', recTypeId);
		outlet.My_Sales_Id__c = '12365';
		outlet.Outlet_ID__c = '2365836';
		outlet.RecordTypeId = recTypeId;
		outlet.Outlet_ID__c = '1';
		
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
		wholesalerBranch.Wholesaler_Account__c = wholesaler.Id;
		insert wholesalerBranch;			
		
		// create wholesaler Branch Outlet
		Wholesaler_Branch_Outlet__c wholesalerBranchOutlet = new Wholesaler_Branch_Outlet__c();
		wholesalerBranchOutlet = TestFactory.createWholeSalerBranchOutlet(outlet.id, wholesalerBranch.id);
		wholesalerBranchOutlet.Wholesaler_Branch_ID__c = '1';
		wholesalerBranchOutlet.Outlet_ID__c = '1';
		wholesalerBranchOutlet.Start_Date__c = system.today();
		wholesalerBranchOutlet.Customer_Number__c = '12800646';
		
		insert wholesalerBranchOutlet;			
		
		salesOrder = new Sales_Order__c();
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
		
		salesOrderLineItemSuccess = new Sales_Order_Product__c();
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
	}
	// response with headerMessageData
    public void testsalesOrder(){
			
		Test.setMock(HttpCalloutMock.class, new MockOrderResponseTest());
		system.debug('callout testing..');
		AlmHttpRequest almRequest = new AlmSoapRequestHandler(salesOrder.id);
	    almRequest.invokeHttpRequest();
		
    }
    // response without header message data test
    public void testsalesOrderWithoutHeaderMessage(){
			
		Test.setMock(HttpCalloutMock.class, new MockOrderWIthoutHeaderMessageTest());
		system.debug('callout testing..');
		AlmHttpRequest almRequest = new AlmSoapRequestHandler(salesOrder.id);
	    almRequest.invokeHttpRequest();
		
    }
    //success order test
    public void testsalesOrderSuccess(){
			
		Test.setMock(HttpCalloutMock.class, new MockOrderSuccessTest());
		system.debug('callout testing..');
		AlmHttpRequest almRequest = new AlmSoapRequestHandler(salesOrder.id);
	    almRequest.invokeHttpRequest();
		
    }
    // response with headerMessageData for sales order product
    public void testSalesOrderProduct(){
			
		Test.setMock(HttpCalloutMock.class, new MockOrderResponseTest());
		system.debug('callout testing..');
		AlmHttpRequest almRequest = new AlmSoapRequestHandler(salesOrderLineItemSuccess.id);
        almRequest.invokeHttpRequest();
            
    } 
    // response without header message data for sales order product
     public void testSalesOrderProductNoHeaderMessage(){
			
		Test.setMock(HttpCalloutMock.class, new MockOrderWIthoutHeaderMessageTest());
		system.debug('callout testing..');
		AlmHttpRequest almRequest = new AlmSoapRequestHandler(salesOrderLineItemSuccess.id);
        almRequest.invokeHttpRequest();
            
    }
    
    //success sales order product test
    public void testsalesOrderProductSuccess(){
			
		Test.setMock(HttpCalloutMock.class, new MockOrderSuccessTest());
		system.debug('callout testing..');
		AlmHttpRequest almRequest = new AlmSoapRequestHandler(salesOrderLineItemSuccess.id);
	    almRequest.invokeHttpRequest();
		
    }
    
    //Authentication failed test
    public void testAuthentication(){
			
		Test.setMock(HttpCalloutMock.class, new MockOrderAuthenticationFailedTest());
		system.debug('callout testing..');
		AlmHttpRequest almRequest = new AlmSoapRequestHandler(salesOrderLineItemSuccess.id);
	    almRequest.invokeHttpRequest();
		
    }           
    
       
     @isTest static void testCallout(){
     	
     	AlmSoapRequestHandlerTest calltest = new AlmSoapRequestHandlerTest();
     	test.startTest();
     	calltest.testSalesOrderProduct();
     	test.stopTest();
     	
     }
     
      @isTest static void testCallout2(){
     	AlmSoapRequestHandlerTest calltest2 = new AlmSoapRequestHandlerTest();
     	test.startTest();
     	calltest2.testsalesOrder();
     	test.stopTest();
     }
     
     @isTest static void testCallout3(){
     	AlmSoapRequestHandlerTest calltest2 = new AlmSoapRequestHandlerTest();
     	test.startTest();
     	calltest2.testsalesOrderWithoutHeaderMessage();
     	test.stopTest();
     }
     
     @isTest static void testCallout4(){
     	AlmSoapRequestHandlerTest calltest2 = new AlmSoapRequestHandlerTest();
     	test.startTest();
     	calltest2.testSalesOrderProductNoHeaderMessage();
     	test.stopTest();
     }
     
     @isTest static void testCallout5(){
     	AlmSoapRequestHandlerTest calltest2 = new AlmSoapRequestHandlerTest();
     	test.startTest();
     	calltest2.testsalesOrderSuccess();
     	test.stopTest();
     }
     
     @isTest static void testCallout6(){
     	AlmSoapRequestHandlerTest calltest2 = new AlmSoapRequestHandlerTest();
     	test.startTest();
     	calltest2.testsalesOrderProductSuccess();
     	test.stopTest();
     }
     
     @isTest static void testAuthenticationMethod(){
     	AlmSoapRequestHandlerTest calltest2 = new AlmSoapRequestHandlerTest();
     	test.startTest();
     	calltest2.testAuthentication();
     	test.stopTest();
     }
}