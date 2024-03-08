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
public class TradeLoaderControllerTest {
	public id recTypeId;
    public TradeLoaderControllerTest(){
    
    }
    
    public void testmethod1(){
    	Test.StartTest();
			
			String ALM_SUCCESS_STATUS = 'Order placed in ALM';
			String ALM_FAILED_STATUS = 'Order failed in ALM';
			
			Account outlet = new Account();
			
			recTypeId = Utilities.getRecordTypeId('Account','Outlet');
			
			outlet = TestFactory.getAccount('ILG', recTypeId);
			outlet.My_Sales_Id__c = '12365';
			outlet.Outlet_ID__c = '1';
			outlet.RecordTypeId = recTypeId;
			
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
			
			// insert wholesaler Branch record
			Wholesaler_Branch__c wholesalerBranch = new  Wholesaler_Branch__c();
			wholesalerBranch = TestFactory.createWholeSalerBranch(wholesaler.id);
			wholesalerBranch.Wholesaler_Branch_Id__c = '1';
			wholesalerBranch.Wholesaler_ID__c = '1';
			wholesalerBranch.Wholesaler_Account__c = wholesaler.id;
			insert wholesalerBranch;
			
			// insert wholesaler Branch record
			Wholesaler_Branch__c wholesalerBranch2 = new  Wholesaler_Branch__c();
			wholesalerBranch2 = TestFactory.createWholeSalerBranch(wholesaler.id);
			wholesalerBranch2.Wholesaler_Branch_Id__c = '2';
			wholesalerBranch2.Wholesaler_ID__c = '1';
			wholesalerBranch2.Wholesaler_Account__c = wholesaler.id;
			insert wholesalerBranch2;			
			
			// create wholesaler Branch Outlet Primary 
			Wholesaler_Branch_Outlet__c wholesalerBranchOutlet = new Wholesaler_Branch_Outlet__c();
			wholesalerBranchOutlet = TestFactory.createWholeSalerBranchOutlet(outlet.id, wholesalerBranch2.id);
			wholesalerBranchOutlet.Wholesaler_Branch_ID__c = '1';
			wholesalerBranchOutlet.Outlet_ID__c = '1';
			wholesalerBranchOutlet.Start_Date__c = system.today();
			wholesalerBranchOutlet.Customer_Number__c = '12800646';
			wholesalerBranchOutlet.Wholesaler_Branch__c =  wholesalerBranch.id;
			wholesalerBranchOutlet.Outlet_Account__c = outlet.id;
			wholesalerBranchOutlet.Primary__c = true;
			
			insert wholesalerBranchOutlet;
			/*
			// create wholesaler Branch Outlet non primary
			Wholesaler_Branch_Outlet__c wholesalerBranchOutletNoPrimary = new Wholesaler_Branch_Outlet__c();
			wholesalerBranchOutletNoPrimary = TestFactory.createWholeSalerBranchOutlet(outlet.id, wholesalerBranch.id);
			wholesalerBranchOutletNoPrimary.Wholesaler_Branch_ID__c = '2';
			wholesalerBranchOutletNoPrimary.Outlet_ID__c = '1';
			wholesalerBranchOutletNoPrimary.Start_Date__c = system.today();
			wholesalerBranchOutletNoPrimary.Customer_Number__c = '12800646';
			wholesalerBranchOutlet.Wholesaler_Branch__c =  wholesalerBranch2.id;
			wholesalerBranchOutlet.Outlet_Account__c = outlet.id;
			wholesalerBranchOutletNoPrimary.Primary__c = false;
			
			insert wholesalerBranchOutletNoPrimary;	
			*/
			
			// insert wholesaler Group Product 
			Wholesaler_Group_Product__c whGroupProduct = new Wholesaler_Group_Product__c();
			whGroupProduct.Product_ID__c = '1';
			whGroupProduct.Wholesaler_Group_ID__c = '1';
			whGroupProduct.Wholesaler_Product_Code__c = '123456';
			
			system.debug('whGroupProduct: '  +whGroupProduct);
			
			
			// insert  Brand 
			Brand__c brand = new Brand__c();
			brand = TestFactory.getBrand('12345', 'CSGSSS');
			
			insert brand;
			
			//insert promoted range
			Promoted_Range__c promotedRange =  new Promoted_Range__c();
			promotedRange  = TestFactory.createPromotatedRange(brand.id);
			promotedRange.Brand_ID__c = '12345';
        	promotedRange.Promotion_Range_ID__c = 'testpromotedRange';
			
			insert promotedRange;
			
			//get promotion record type id
			Id promotionRecordTypeId = Utilities.getRecordTypeId('Promotion__c','Trade Loader Promotion');
			// insert Promotion__c
			Promotion__c promotion = new Promotion__c();
			promotion =  TestFactory.createPromotion(promotedRange.id);
			promotion.Promotion_Period_Start_Date__c = system.today();
			promotion.Promotion_Period_End_Date__c = system.today()+20;
			promotion.RecordTypeId = promotionRecordTypeId;
			
			insert promotion;
			
			
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
			testPricing.Maximum_Discount__c = 10;
			testPricing.Estimated_Discount__c = 10;
			insert testPricing;
			
			// insert promotion products
			PromotionProduct__c promotionProduct = new PromotionProduct__c();
			promotionProduct.Name = 'Promotion Test';
			promotionProduct.Product__c = productTest.id;
			promotionProduct.Pricing__c = testPricing.id;
			
			insert promotionProduct;
			
			PageReference pageRef = Page.SalesOrderTradeLoder;
			Test.setCurrentPage(pageRef);
			
			ApexPages.currentPage().getParameters().put('acId',outlet.id);
			
			TradeLoaderController testTradeLoader = new  TradeLoaderController();
			
			testTradeLoader.getOnPromotions();
			
			testTradeLoader.getwAccount();
		    
		Test.stopTest();
    }
    
    public void testMethod2(){
    	Test.StartTest();
					
			Account outlet = new Account();
			
			recTypeId = Utilities.getRecordTypeId('Account','Outlet');
			
			outlet = TestFactory.getAccount('ILG', recTypeId);
			outlet.My_Sales_Id__c = '12365';
			outlet.Outlet_ID__c = '1';
			outlet.RecordTypeId = recTypeId;
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
			
			// insert wholesaler Branch record
			Wholesaler_Branch__c wholesalerBranch = new  Wholesaler_Branch__c();
			wholesalerBranch = TestFactory.createWholeSalerBranch(wholesaler.id);
			wholesalerBranch.Wholesaler_Branch_Id__c = '1';
			wholesalerBranch.Wholesaler_ID__c = '1';
			wholesalerBranch.Wholesaler_Account__c = wholesaler.id;
			insert wholesalerBranch;			
			
			
			
			
			// insert wholesaler Group Product 
			Wholesaler_Group_Product__c whGroupProduct = new Wholesaler_Group_Product__c();
			whGroupProduct.Product_ID__c = '1';
			whGroupProduct.Wholesaler_Group_ID__c = '1';
			whGroupProduct.Wholesaler_Product_Code__c = '123456';
			
			system.debug('whGroupProduct: '  +whGroupProduct);
			
			
			// insert  Brand 
			Brand__c brand = new Brand__c();
			brand = TestFactory.getBrand('12345', 'CSGSSS');
			
			insert brand;
			
			//insert promoted range
			Promoted_Range__c promotedRange =  new Promoted_Range__c();
			promotedRange  = TestFactory.createPromotatedRange(brand.id);
			promotedRange.Brand_ID__c = '12345';
            promotedRange.Promotion_Range_ID__c = 'testpromotedRange';
			
			insert promotedRange;
			
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
			testPricing.Maximum_Discount__c = 10;
			testPricing.Estimated_Discount__c = 10;
			testPricing.Wholesaler_Price__c = 100;
			insert testPricing;
			
			// insert promotion products
			PromotionProduct__c promotionProduct = new PromotionProduct__c();
			promotionProduct.Name = 'Promotion Test';
			promotionProduct.Product__c = productTest.id;
			promotionProduct.Pricing__c = testPricing.id;
			
			insert promotionProduct;
			
			PageReference pageRef = Page.SalesOrderTradeLoder;
			Test.setCurrentPage(pageRef);
			
			ApexPages.currentPage().getParameters().put('acId',outlet.id);
			
			TradeLoaderController testTradeLoader = new  TradeLoaderController();
			
			
			testTradeLoader.getOnPromotions();
			
			
			testTradeLoader.setwAccount(wholesalerBranch.id);
			testTradeLoader.getwAccount();
			
			testTradeLoader.promtionId = promotionProduct.id;
			testTradeLoader.populateSalesOrderFields();
			
			
		    
		Test.stopTest();
    }
    
    public void testPopulatePromotionFields(){
    	Test.StartTest();
					
			Account outlet = new Account();
			
			recTypeId = Utilities.getRecordTypeId('Account','Outlet');
			
			outlet = TestFactory.getAccount('ILG', recTypeId);
			outlet.My_Sales_Id__c = '12365';
			outlet.Outlet_ID__c = '1';
			outlet.RecordTypeId = recTypeId;
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
			
			// insert wholesaler Branch record
			Wholesaler_Branch__c wholesalerBranch = new  Wholesaler_Branch__c();
			wholesalerBranch = TestFactory.createWholeSalerBranch(wholesaler.id);
			wholesalerBranch.Wholesaler_Branch_Id__c = '1';
			wholesalerBranch.Wholesaler_ID__c = '1';
			wholesalerBranch.Wholesaler_Account__c = wholesaler.id;
			insert wholesalerBranch;			
			
			
			
			
			// insert wholesaler Group Product 
			Wholesaler_Group_Product__c whGroupProduct = new Wholesaler_Group_Product__c();
			whGroupProduct.Product_ID__c = '1';
			whGroupProduct.Wholesaler_Group_ID__c = '1';
			whGroupProduct.Wholesaler_Product_Code__c = '123456';
			
			system.debug('whGroupProduct: '  +whGroupProduct);
			
			
			// insert  Brand 
			Brand__c brand = new Brand__c();
			brand = TestFactory.getBrand('12345', 'CSGSSS');
			
			insert brand;
			
			//insert promoted range
			Promoted_Range__c promotedRange =  new Promoted_Range__c();
			promotedRange  = TestFactory.createPromotatedRange(brand.id);
			promotedRange.Brand_ID__c = '12345';
            promotedRange.Promotion_Range_ID__c = 'testpromotedRange';
			
			insert promotedRange;
			
			// insert products
			Product__c productTest = new Product__c();
			productTest = TestFactory.createProduct(brand.id);
			productTest.Bottles_Per_Carton__c = 6;
			productTest.MLs_Per_Bottle__c = '500 ml';
			productTest.Brand_ID__c = '12345';
			productTest.Product_ID__c = '1';
			
			insert productTest;
			
			//get promotion record type id
			Id promotionRecordTypeId = Utilities.getRecordTypeId('Promotion__c','Trade Loader Promotion');
			// insert Promotion__c
			Promotion__c promotion = new Promotion__c();
			promotion =  TestFactory.createPromotion(promotedRange.id);
			promotion.Promotion_Period_Start_Date__c = system.today();
			promotion.Promotion_Period_End_Date__c = system.today()+20;
			promotion.RecordTypeId = promotionRecordTypeId;
			promotion.Deal_Size__c = '300';
			insert promotion;
			
			
			// insert Pricing 
			Pricing__c testPricing =  new Pricing__c();
			testPricing = TestFactory.createPricing(productTest.Product_ID__c);
			testPricing.Name = '1';
			testPricing.Product_ID__c = '1';
			testPricing.Maximum_Discount__c = 10;
			testPricing.Estimated_Discount__c = 10;
			testPricing.Wholesaler_Price__c = 100;
			insert testPricing;
			
			// insert promotion products
			PromotionProduct__c promotionProduct = new PromotionProduct__c();
			promotionProduct.Name = 'Promotion Test';
			promotionProduct.Product__c = productTest.id;
			promotionProduct.Pricing__c = testPricing.id;
			
			insert promotionProduct;
			
			PageReference pageRef = Page.SalesOrderTradeLoder;
			Test.setCurrentPage(pageRef);
			
			ApexPages.currentPage().getParameters().put('acId',outlet.id);
			
			TradeLoaderController testTradeLoader = new  TradeLoaderController();
			
			
			testTradeLoader.getOnPromotions();
			
			
			testTradeLoader.setwAccount(wholesalerBranch.id);
			testTradeLoader.getwAccount();
			
			testTradeLoader.promtionId = promotion.id;
			testTradeLoader.populateSalesOrderFields();
			testTradeLoader.showWholesalerGroup();
			
			//add selected products
			testTradeLoader.orderLineItemsToBeDisplayed[0].salesOrderProducts.Discount__c = 3;
			testTradeLoader.orderLineItemsToBeDisplayed[0].salesOrderProducts.Quantity__c = 20;
			testTradeLoader.orderLineItemsToBeDisplayed[0].salesOrderProducts.Quantity_2__c = 20;
			testTradeLoader.addSelectedProducts();
			
			
			// save button
			
			testTradeLoader.salesRecord.Wine_Drop_1__c = 10;
			testTradeLoader.salesRecord.RTD_Drop_1__c = 20;
			testTradeLoader.salesRecord.Glass_Spirits_Drop_1__c = 10;
			
			testTradeLoader.salesRecord.Wine_Drop_2__c = 1;
			testTradeLoader.salesRecord.RTD_Drop_2__c = 2;
			testTradeLoader.salesRecord.Glass_Spirits_Drop_2__c = 1;
			testTradeLoader.salesRecord.Drop_2_Date__c = system.today();
			
			testTradeLoader.save();
		    
		Test.stopTest();
    
    }
    
    // discount null or greater than maximum discount
    public  void testDiscountNullOrMore(){
    	Test.StartTest();
					
			Account outlet = new Account();
			
			recTypeId = Utilities.getRecordTypeId('Account','Outlet');
			
			outlet = TestFactory.getAccount('ILG', recTypeId);
			outlet.My_Sales_Id__c = '12365';
			outlet.Outlet_ID__c = '1';
			outlet.RecordTypeId = recTypeId;
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
			
			// insert wholesaler Branch record
			Wholesaler_Branch__c wholesalerBranch = new  Wholesaler_Branch__c();
			wholesalerBranch = TestFactory.createWholeSalerBranch(wholesaler.id);
			wholesalerBranch.Wholesaler_Branch_Id__c = '1';
			wholesalerBranch.Wholesaler_ID__c = '1';
			wholesalerBranch.Wholesaler_Account__c = wholesaler.id;
			insert wholesalerBranch;			
			
			
			
			
			// insert wholesaler Group Product 
			Wholesaler_Group_Product__c whGroupProduct = new Wholesaler_Group_Product__c();
			whGroupProduct.Product_ID__c = '1';
			whGroupProduct.Wholesaler_Group_ID__c = '1';
			whGroupProduct.Wholesaler_Product_Code__c = '123456';
			
			system.debug('whGroupProduct: '  +whGroupProduct);
			
			
			// insert  Brand 
			Brand__c brand = new Brand__c();
			brand = TestFactory.getBrand('12345', 'CSGSSS');
			
			insert brand;
			
			//insert promoted range
			Promoted_Range__c promotedRange =  new Promoted_Range__c();
			promotedRange  = TestFactory.createPromotatedRange(brand.id);
			promotedRange.Brand_ID__c = '12345';
         	promotedRange.Promotion_Range_ID__c = 'testpromotedRange';
			
			insert promotedRange;
			
			// insert products
			Product__c productTest = new Product__c();
			productTest = TestFactory.createProduct(brand.id);
			productTest.Bottles_Per_Carton__c = 6;
			productTest.MLs_Per_Bottle__c = '500 ml';
			productTest.Brand_ID__c = '12345';
			productTest.Product_ID__c = '1';
			
			insert productTest;
			
			//get promotion record type id
			Id promotionRecordTypeId = Utilities.getRecordTypeId('Promotion__c','Trade Loader Promotion');
			// insert Promotion__c
			Promotion__c promotion = new Promotion__c();
			promotion =  TestFactory.createPromotion(promotedRange.id); 
			promotion.Promotion_Period_Start_Date__c = system.today();
			promotion.Promotion_Period_End_Date__c = system.today()+20;
			promotion.RecordTypeId = promotionRecordTypeId;
			promotion.Deal_Size__c = '400';
			insert promotion;
			
			
			// insert Pricing 
			Pricing__c testPricing =  new Pricing__c();
			testPricing = TestFactory.createPricing(productTest.Product_ID__c);
			testPricing.Name = '1';
			testPricing.Product_ID__c = '1';
			testPricing.Maximum_Discount__c = 10;
			testPricing.Estimated_Discount__c = 10;
			testPricing.Wholesaler_Price__c = 100;
			insert testPricing;
			
			// insert promotion products
			PromotionProduct__c promotionProduct = new PromotionProduct__c();
			promotionProduct.Name = 'Promotion Test';
			promotionProduct.Product__c = productTest.id;
			promotionProduct.Pricing__c = testPricing.id;
			
			insert promotionProduct;
			
			PageReference pageRef = Page.SalesOrderTradeLoder;
			Test.setCurrentPage(pageRef);
			
			ApexPages.currentPage().getParameters().put('acId',outlet.id);
			
			TradeLoaderController testTradeLoader = new  TradeLoaderController();
			
			
			testTradeLoader.getOnPromotions();
			
			
			testTradeLoader.setwAccount(wholesalerBranch.id);
			testTradeLoader.getwAccount();
			
			testTradeLoader.promtionId = promotion.id;
			testTradeLoader.populateSalesOrderFields();
			testTradeLoader.showWholesalerGroup();
			
			//add selected products
			testTradeLoader.orderLineItemsToBeDisplayed[0].salesOrderProducts.Discount__c = null;
			testTradeLoader.orderLineItemsToBeDisplayed[0].salesOrderProducts.Quantity__c = 20;
			testTradeLoader.orderLineItemsToBeDisplayed[0].salesOrderProducts.Quantity_2__c = 20;
			testTradeLoader.addSelectedProducts();
			
			
			// save button
			
			testTradeLoader.salesRecord.Wine_Drop_1__c = 10;
			testTradeLoader.salesRecord.RTD_Drop_1__c = 20;
			testTradeLoader.salesRecord.Glass_Spirits_Drop_1__c = 10;
			
			testTradeLoader.salesRecord.Wine_Drop_2__c = 1;
			testTradeLoader.salesRecord.RTD_Drop_2__c = 2;
			testTradeLoader.salesRecord.Glass_Spirits_Drop_2__c = 1;
			testTradeLoader.salesRecord.Drop_2_Date__c = system.today();
			
			testTradeLoader.save();
			
			
			// discount more than maximum discount
			TradeLoaderController testTradeLoaderDiscountNull = new  TradeLoaderController();
						
			testTradeLoaderDiscountNull.promtionId = promotion.id;
			testTradeLoaderDiscountNull.populateSalesOrderFields();
			testTradeLoaderDiscountNull.showWholesalerGroup();
			
			//add selected products
			testTradeLoaderDiscountNull.orderLineItemsToBeDisplayed[0].salesOrderProducts.Discount__c = 20;
			testTradeLoaderDiscountNull.orderLineItemsToBeDisplayed[0].salesOrderProducts.Quantity__c = 20;
			testTradeLoaderDiscountNull.orderLineItemsToBeDisplayed[0].salesOrderProducts.Quantity_2__c = 20;
			testTradeLoaderDiscountNull.addSelectedProducts();
			
		    
		Test.stopTest();
    }
    
    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        TradeLoaderControllerTest test1 = new TradeLoaderControllerTest();
        test1.testmethod1();
    }
    
    // test for  no promotion exists and no primary  wholesaler branch outlet exist
    static testMethod void myUnitTest2(){
    	// TO DO: implement unit test
        TradeLoaderControllerTest test1 = new TradeLoaderControllerTest();
        test1.testmethod2();
    }
    // test for  no promotion exists and no primary  wholesaler branch outlet exist
    static testMethod void myUnitTest3(){
    	// TO DO: implement unit test
        TradeLoaderControllerTest test1 = new TradeLoaderControllerTest();
        test1.testPopulatePromotionFields();
    }
    
    // Test with discount as null or greater than maximum discount
    static testMethod void myUnitTest4(){
    	// TO DO: implement unit test
        TradeLoaderControllerTest test1 = new TradeLoaderControllerTest();
        test1.testDiscountNullOrMore();
    }
}