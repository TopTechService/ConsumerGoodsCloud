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
public class SubmitToWholesalerTest {
	Id recTypeId;
	Sales_Order__c salesOrder;
	Account wholesaler;
	Sales_Order_Product__c salesOrderLineItemSuccess;
    public SubmitToWholesalerTest(){
    	Test.StartTest();
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
			outlet.OwnerId = userinfo.getUserId();
			
			insert outlet;
			system.debug('Outlet owner: ' + outlet.OwnerId);
		
			wholesaler = new Account();
			recTypeId = Utilities.getRecordTypeId('Account','Wholesaler');
			wholesaler = TestFactory.getAccount('ILG', recTypeId);
			wholesaler.Customer_Number__c = '12345';
			wholesaler.Wholesaler_ID__c = '1';
			
			insert wholesaler;
			
			salesOrder = new Sales_Order__c();
			Id salesOrderRecordType= Utilities.getRecordTypeId('Sales_Order__c', 'Trade Loader Sales Order Drop 1');
			salesOrder = TestFactory.createSalesOrder(wholesaler.id, outlet.Id);
			salesOrder.Status__c = 'New Sales Order Created';
			salesOrder.RecordTypeId = salesOrderRecordType;
			salesOrder.Drop_1_Date__c = system.today()-1;
			salesOrder.Wholesaler_Account_Number__c = '12345678';
			insert salesOrder;
			
			
			system.debug('salesOrder.Region__c: ' + salesOrder.Region__c);
			ALM_User_Name_and_Region__c almUserNameAndRegion = new ALM_User_Name_and_Region__c();
			almUserNameAndRegion.name = 'TAS';
			almUserNameAndRegion.Rep_Id__c = '175001';
			almUserNameAndRegion.Password__c = 'fjdsfd';
			insert almUserNameAndRegion;
			
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
			//list<Sales_Order_Product__c> salesOrderlineItemsList = new list<Sales_Order_Product__c>();
			
			salesOrderLineItemSuccess = new Sales_Order_Product__c();
			salesOrderLineItemSuccess = TestFactory.createsalesOrderProduct(promotionProduct.id);
			salesOrderLineItemSuccess.Sales_Order__c = salesOrder.id;
			salesOrderLineItemSuccess.Quantity__c = 6.66;
			salesOrderLineItemSuccess.Status__c = 'Order failed in ILG';
			//salesOrderlineItemsList.add(salesOrderLineItemSuccess);
			insert salesOrderLineItemSuccess;
						
			//insert salesOrderlineItemsList;
		Test.stopTest();
    	
    }
    
    public void testMethod1(){
    	SubmitToWholeSaler.changeOrdersStatus(salesOrder.id);
    	salesOrderLineItemSuccess.Status__c = 'Order failed in ILG';
    	
    	update salesOrderLineItemSuccess;
    	
    	SubmitToWholeSaler.changeLineItemStatustoNewSalesOrder(salesOrderLineItemSuccess.id);
    }
    
    public void testMethod2(){
    	salesOrder.Status__c = 'Order placed in ILG';
    	update salesOrder;
    	SubmitToWholeSaler.changeOrdersStatus(salesOrder.id);
    	
    	// partial updates 
    	salesOrder.Status__c = 'Partially Succeeded';
    	update salesOrder;
    	SubmitToWholeSaler.changeOrdersStatus(salesOrder.id);
    	   	
    }
    // for ALM
    public void testMethod3(){
    	
    	wholesaler.Name = 'ALM';
    	update wholesaler;
    	
    	SubmitToWholeSaler.changeOrdersStatus(salesOrder.id);
    	
    	SubmitToWholeSaler.changeLineItemStatustoNewSalesOrder(salesOrderLineItemSuccess.id);
    }
    
    static testMethod void myUnitTest1() {
        // TO DO: implement unit test
        SubmitToWholesalerTest test1 =  new SubmitToWholesalerTest();
        test1.testMethod1();
    }
    
    static testMethod void myUnitTest2() {
        // TO DO: implement unit test
        SubmitToWholesalerTest test1 =  new SubmitToWholesalerTest();
        test1.testMethod2();
    }
    // for ALM
    static testMethod void myUnitTest3() {
        // TO DO: implement unit test
        SubmitToWholesalerTest test1 =  new SubmitToWholesalerTest();
        test1.testMethod3();
    }
}