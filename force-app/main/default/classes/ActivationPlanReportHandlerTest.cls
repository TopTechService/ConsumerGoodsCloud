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
public class ActivationPlanReportHandlerTest {
	public id recTypeId;
	Account bannerGroupAccount;
    public ActivationPlanReportHandlerTest(){
    	
    	Banner_Group__c bannerGroup = new Banner_Group__c(Name = '001', Banner_Group_ID__c = '2');
    	
    	insert bannerGroup;
    	
    	bannerGroupAccount = new Account();
		
		recTypeId = Utilities.getRecordTypeId('Account','Banner Group');
		
		bannerGroupAccount = TestFactory.getAccount('ILG', recTypeId);
		bannerGroupAccount.My_Sales_Id__c = '12365';
		//bannerGroupAccount.Outlet_ID__c = '1';
		bannerGroupAccount.Banner_Group_ID__c = '2';
		//bannerGroupAccount.Banner_Group__c = bannerGroup.Id;
		bannerGroupAccount.RecordTypeId = recTypeId;
		
		insert bannerGroupAccount;
		
		// insert wholesaler group
		
		Wholesaler_Group__c wGroup = new Wholesaler_Group__c(Wholesaler_Group_ID__c = '2', Name = 'ILG');
   		insert wGroup;
		
		Account wholesaler = new Account();
		recTypeId = Utilities.getRecordTypeId('Account','Wholesaler');
		wholesaler = TestFactory.getAccount('ILG', recTypeId);
		wholesaler.Customer_Number__c = '12345';
		wholesaler.Wholesaler_ID__c = '2';
		wholesaler.Wholesaler_Group__c = wGroup.id;
		
		insert wholesaler;
		
		Region__c region = new Region__c();
		
		region = TestFactory.getRegion('QLD', '2');
		
		insert region;
		
		// insert wholesaler banner group 
		Wholesaler_Banner_Group__c wholeBannerGroup = TestFactory.createWholeSalerBannerGroup(Wholesaler.Wholesaler_ID__c, region.Region_ID__c, bannerGroupAccount.Banner_Group_ID__c);
		wholeBannerGroup.Banner_Group_ID__c = '2';
		insert wholeBannerGroup;
 		
		
		// insert  Brand 
		Brand__c brand = new Brand__c();
		brand = TestFactory.getBrand('12345', 'CSGSSS');
		
		insert brand;
		
		//insert promoted range
		Promoted_Range__c promotedRange =  new Promoted_Range__c();
		promotedRange  = TestFactory.createPromotatedRange(brand.id);
		promotedRange.Brand_ID__c = '12345';
        promotedRange.Promotion_Range_ID__c = '123';
		
		insert promotedRange;
		
		//get promotion record type id
		Id promotionRecordTypeId = Utilities.getRecordTypeId('Promotion__c','Standard Promotion');
		
		// insert Promotion__c
		Promotion__c promotion = new Promotion__c();
		promotion =  TestFactory.createPromotion(promotedRange.id);
		promotion.Promotion_Period_Start_Date__c = system.today();
		promotion.Promotion_Period_End_Date__c = system.today()+20;
		promotion.RecordTypeId = promotionRecordTypeId;
		
		insert promotion;
		
		// insert Promotion banner group
		
		Promotion_Banner_Group__c promotionBannerGroup = new Promotion_Banner_Group__c();
		promotionBannerGroup = TestFactory.createPromotionBannerGroup(wholeBannerGroup.Name, promotion.Name);
		
		insert promotionBannerGroup;
    }
    public void activationMethodTest1(){
    		PageReference pageRef = Page.activationPlan;
			Test.setCurrentPage(pageRef);
			
			ApexPages.currentPage().getParameters().put('years',Null);
			
			ActivationPlanReportHandler activationTest1 = new ActivationPlanReportHandler();
			activationTest1.getYears();
			activationTest1.getBannerGroupAccounts();
			activationTest1.selectedYear = System.today().year();
			activationTest1.stateSelected = new list<String>();
			activationTest1.stateSelected.add('NSW');
			activationTest1.selectedBannerGroupAccount = New list<String>();
			activationTest1.selectedBannerGroupAccount.add(bannerGroupAccount.Name);
			activationTest1.getOnGoingPromotions();
			
    }
    
    public void activationMethodTest2(){
    		PageReference pageRef = Page.activationPlan;
			Test.setCurrentPage(pageRef);
			
			ApexPages.currentPage().getParameters().put('years',string.valueOf(system.today().year()));
			
			ActivationPlanReportHandler activationTest1 = new ActivationPlanReportHandler();
			activationTest1.getYears();
			activationTest1.selectedYear = System.today().year();
			activationTest1.stateSelected = new list<String>();
			activationTest1.stateSelected.add('NSW');
			activationTest1.selectedBannerGroupAccount = New list<String>();
			activationTest1.selectedBannerGroupAccount.add(bannerGroupAccount.Name);
			activationTest1.getBannerGroupAccounts();
			activationTest1.getOnGoingPromotions();
			
    }
    
    
    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        ActivationPlanReportHandlerTest test1 = new ActivationPlanReportHandlerTest();
        test1.activationMethodTest1();
    }
    
     static testMethod void myUnitTest2() {
        // TO DO: implement unit test
        ActivationPlanReportHandlerTest test1 = new ActivationPlanReportHandlerTest();
        test1.activationMethodTest2();
    }
}