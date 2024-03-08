/*
 * Test class for :  DeleteMarkedOutlet, DeleteOutletsScheduler, OutletDeleteTrigger 
 * 
 * 
 */
@isTest
private class DeleteOutletsSchedulerTest {

    static testMethod void TestDeleteMarkedOutlet() {
    	prepareTestData();
    	
        Account OutletAccTest = [SELECT id FROM Account WHERE Outlet_ID__c = '1234446'];
        System.assert(OutletAccTest != null);  
        
       	Test.StartTest();
        DeleteOutletsScheduler sh1 = new DeleteOutletsScheduler();
        String sch =  '0 0 0 1 1 ?';
        system.schedule('Delete Marked Outlets1', sch, sh1);
        Test.stopTest();
        
        Boolean outletDeleted = false;
        try {
        Account OutletAccTest1 = [SELECT id FROM Account WHERE Outlet_ID__c = '1234446'];        	
        } catch(Exception e) {
        	outletDeleted = true;
        }
        //System.assert(outletDeleted);
    }
    
    /**
     * Creates Data with DeletedBy__c field set 
     */    
    static void prepareTestData() {
    	// Create a Config Email configuration
        insert TestFactory.createEmailonfiguration();
        
    	// CREATE MARKED OUTLETS
    	Account OutletAcc = new Account(); 
       	OutletAcc.Name = 'AusAccount';   
      	OutletAcc.RecordTypeId =  Utilities.getRecordTypeId('account', 'Outlet');
     	OutletAcc.Outlet_ID__c ='1234446' ; 
     	
       	insert OutletAcc;
       	
        Region__c region = new Region__c(name ='rgn1', Region_ID__c ='123' ,Region_Abbr__c ='AUS');
        insert region;
       	
       	State__c stt = TestFactory.createState(region.Region_ID__c, '4');
     	insert stt;
     	
      	Outlet_Type__c outletType = new Outlet_Type__c(name ='222', Outlet_Type_Description__c ='bar',Type_ExtId__c = '222');
       	insert outletType;     	
     	
	    Outlet_Sub_Type__c oSubType = TestFactory.createOutletSubType(outletType.name);
	    insert oSubType;
      	
   		Outlet_Category__c category = TestFactory.createOutletCategory(oSubType.name);
        insert category;
        
        Outlet__c outlet=TestFactory.createOutlet(stt.State_ID__c, category.Outlet_Category_Id__c);
        outlet.DeletedBy__c = 'dbo';
        //outlet.name = OutletAcc.outlet_id__c;
        outlet.name = '1234447';
        outlet.Outlet_My_Sales_Id__c = integer.valueof('1234447');
        insert outlet;
     	
     	// CREATE MARKED Wholesaler_Branch_Outlet__c     	
        Account wAccount = new Account();        
        wAccount.Name = 'AUBAR';       
        wAccount.RecordTypeId = Utilities.getRecordTypeId('account', 'Wholesaler');       
        wAccount.Wholesaler_ID__c ='123';
        insert wAccount;	     	
     	
     	Wholesaler_Branch__c wBranche = TestFactory.createWholeSalerBranch('123');
        insert wBranche;
     	
     	Wholesaler_Branch_Outlet__c wbOutlet = TestFactory.createWholeSalerBranchOutlet(OutletAcc.Outlet_ID__c,wBranche.Wholesaler_Branch_Id__c);
		wbOutlet.DeletedBy__c = 'dbo';     	
       	insert wbOutlet;
       	
       	// CREATE MARKED Promotion_Outlet__c       	       	
     	Brand__c brand= TestFactory.getBrand('123','127');      
        insert brand;       	
       	
        Promoted_Range__c prmtRange = TestFactory.createPromotedRange(brand.Brand_ID__c);        
        insert prmtRange;        	
       	
        Promotion__c  promotion = TestFactory.createPromotion(prmtRange.Promotion_Range_ID__c);
        insert promotion;        	
       	
	    Promotion_Outlet__c  pOutlet =TestFactory.createPromotionOutlet(OutletAcc.Outlet_ID__c,promotion.name);
	    pOutlet.DeletedBy__c = 'dbo'; 
	    insert pOutlet;
	    
	    // CREATE MARKED Banner_Group_Outlet__c
        Account bAccount = new Account();        
        bAccount.Name = 'AUBAR';       
        bAccount.RecordTypeId = Utilities.getRecordTypeId('account', 'Banner Group');       
        bAccount.Banner_Group_ID__c ='123';        
        insert bAccount;	
       	
        Banner_Group_Outlet__c  bgOutlet = TestFactory.createBannerGroupOutlet(OutletAcc.Outlet_ID__c,bAccount.Banner_Group_ID__c);
        bgOutlet.Outlet_Account__c = OutletAcc.id;
        bgOutlet.DeletedBy__c = 'dbo';
        insert bgOutlet;
        
        
    }
}