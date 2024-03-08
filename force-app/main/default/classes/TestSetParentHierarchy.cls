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
(seeallData=false)

public  class TestSetParentHierarchy {
    public id accrecordTypeId;
    
    public Account acc,acc2 ;
    public Account childAcc;
    public Outlet__c  outlet;
    
    static testMethod void setHierarchy (){
        
         test.startTest(); 
        // CREATE MARKED OUTLETS
        Account OutletAccParent = new Account();  
        OutletAccParent.Name = 'ParentAusAccount';   
        OutletAccParent.RecordTypeId =  Utilities.getRecordTypeId('account', 'Outlet');
        OutletAccParent.Outlet_ID__c ='12346' ; 
        OutletAccParent.ShippingCountry = 'AUSTRALIA';
        
        insert OutletAccParent ;
        
        
        Account OutletAcc = new Account();  
        OutletAcc.Name = 'AusAccount';   
        OutletAcc.RecordTypeId =  Utilities.getRecordTypeId('account', 'Outlet');
        OutletAcc.Outlet_ID__c ='1234446' ; 
        OutletAcc.Account_Type__c = 'National';
        //OutletAcc.Channel__c = 'On-Premise';
        //OutletAcc.On_Premise_Segmentation__c = 'Local Pub';
        OutletAcc.parentId = OutletAccParent.id;
        OutletAcc.Red_Flag_Description__c = 'test';
        OutletAcc.Volume__c = 3;
        OutletAcc.ShippingCountry = 'AUSTRALIA';
        insert OutletAcc;
        OutletAcc.ownerId = [SELECT id FROM User Where isactive = true and Profile.Name like '%System%' LIMIT 1].id;
        RecursiveTriggerController.count = 1;
        OutletAcc.Name = 'test';
        update OutletAcc;
        
		Region__c region = new Region__c(name ='rgn1', Region_ID__c ='123' ,Region_Abbr__c ='AUS');
        insert region;
        
        State__c stt = TestFactory.createState(region.Region_ID__c, '1');
        insert stt;
        
        Outlet_Type__c outletType = new Outlet_Type__c(name ='123', Outlet_Type_Description__c ='bar', Type_ExtId__c = '123');
        insert outletType;      
        
        Outlet_Sub_Type__c oSubType = TestFactory.createOutletSubType(outletType.name);
        insert oSubType;
        
        Outlet_Category__c category = TestFactory.createOutletCategory(oSubType.name);
        insert category; 
        
        Outlet__c outlet=TestFactory.createOutlet(stt.State_ID__c, category.Outlet_Category_Id__c);
        outlet.DeletedBy__c = 'dbo';
        outlet.name = OutletAcc.outlet_id__c;
        outlet.Outlet_My_Sales_Id__c = 1234446 + integer.valueOf(stt.State_ID__c);
        insert outlet;
      
          
        // CREATE MARKED Banner_Group_Outlet__c
        Account bAccount = new Account();        
        bAccount.Name = 'AUBAR';       
        bAccount.RecordTypeId = Utilities.getRecordTypeId('account', 'Banner Group');       
        bAccount.Banner_Group_ID__c ='123';  
        bAccount.ShippingCountry = 'AUSTRALIA';
        insert bAccount;
       
        
        Banner_Group_Outlet__c  bgOutlet = TestFactory.createBannerGroupOutlet(OutletAcc.Outlet_ID__c,bAccount.Banner_Group_ID__c);
        bgOutlet.Outlet_Account__c = OutletAcc.id;
        bgOutlet.DeletedBy__c = 'dbo';
        insert bgOutlet;         
        update bgOutlet;
        
       
        
        Account bAccount2 = new Account();        
        bAccount2.Name = 'AUBAR2';       
        bAccount2.RecordTypeId = Utilities.getRecordTypeId('account', 'Banner Group');       
        bAccount2.Banner_Group_ID__c ='1234'; 
        bAccount2.ShippingCountry = 'AUSTRALIA';
        insert bAccount2;
        update bAccount2;
        
        Banner_Group_Outlet__c  bgOutlet2 = TestFactory.createBannerGroupOutlet('1234446','1234');
        bgOutlet2.Outlet_Account__c = OutletAcc.id;     
        bgOutlet2.DeletedBy__c = 'dbo';
        insert bgOutlet2;
        update bgOutlet2;
        
        OutletAcc.Banner_Group__c = bAccount.id;
        
        update OutletAcc;
        
test.stopTest(); 
        
        
        
    }
    
    public void setHierarchy2 (){
        // CREATE MARKED OUTLETS
        Account OutletAccParent = new Account();  
        OutletAccParent.Name = 'ParentAusAccount';   
        OutletAccParent.RecordTypeId =  Utilities.getRecordTypeId('account', 'Outlet');
        OutletAccParent.Outlet_ID__c ='12346' ; 
        OutletAccParent.ShippingCountry = 'AUSTRALIA';
        
        insert OutletAccParent ;
        
        Account OutletAcc = new Account();  
        OutletAcc.Name = 'AusAccount';   
        OutletAcc.RecordTypeId =  Utilities.getRecordTypeId('account', 'Outlet');
        OutletAcc.Outlet_ID__c ='1234446' ; 
        OutletAcc.parentId = OutletAccParent.id;
        OutletAcc.Red_Flag_Description__c = 'test';
        OutletAcc.Volume__c = 3;
        OutletAcc.ShippingCountry = 'AUSTRALIA';
        insert OutletAcc;
        OutletAcc.ownerId = [SELECT id FROM User LIMIT 1].id;
        RecursiveTriggerController.count = 1;
        OutletAcc.Name = 'test';
        
        update OutletAcc;
        
        
        Region__c region = new Region__c(name ='rgn1', Region_ID__c ='123' ,Region_Abbr__c ='AUS');
        insert region;
        
        State__c stt = TestFactory.createState(region.Region_ID__c, '1');
        insert stt;
        
        Outlet_Type__c outletType = new Outlet_Type__c(name ='123', Outlet_Type_Description__c ='bar', Type_ExtId__c = '123');
        insert outletType;      
        
        Outlet_Sub_Type__c oSubType = TestFactory.createOutletSubType(outletType.name);
        insert oSubType;
        
        Outlet_Category__c category = TestFactory.createOutletCategory(oSubType.name);
        insert category; 
        
        Outlet__c outlet=TestFactory.createOutlet(stt.State_ID__c, category.Outlet_Category_Id__c);
        outlet.DeletedBy__c = 'dbo';
        outlet.name = OutletAcc.outlet_id__c;
        outlet.Outlet_My_Sales_Id__c = 1234446 + integer.valueOf(stt.State_ID__c);
        insert outlet;
        
        test.startTest(); 
        
        // CREATE MARKED Banner_Group_Outlet__c
        Account bAccount = new Account();        
        bAccount.Name = 'AUBAR';       
        bAccount.RecordTypeId = Utilities.getRecordTypeId('account', 'Banner Group');       
        bAccount.Banner_Group_ID__c ='123'; 
        bAccount.ShippingCountry = 'AUSTRALIA';
        insert bAccount;
        
        Account bAccount2 = new Account();        
        bAccount2.Name = 'AUBAR2';       
        bAccount2.RecordTypeId = Utilities.getRecordTypeId('account', 'Banner Group');       
        bAccount2.Banner_Group_ID__c ='1234';  
        bAccount2.ShippingCountry = 'AUSTRALIA';
        insert bAccount2;
        update bAccount2;
                
        OutletAcc.Banner_Group__c = bAccount.id;
        
        update OutletAcc;
        
        OutletAcc.Banner_Group__c = bAccount2.id;
        //OutletAcc.ownerId = [SELECT Id FROM User LIMIT 1].id;
        OutletAcc.Owner_Changed__c  = true;
        OutletAcc.Banner_Group_Changed__c = true;
        update OutletAcc;
        
        test.stopTest();
        
    }
       
    static testMethod void myUnitTest3() { 
        
        Region__c region = new Region__c(name ='rgn1', Region_ID__c ='123' ,Region_Abbr__c ='AUS');
        insert region;
       	
       	State__c stt = TestFactory.createState(region.Region_ID__c, '5');
     	insert stt;
     	
      	Outlet_Type__c outletType = new Outlet_Type__c(name ='333', Outlet_Type_Description__c ='bar', Type_ExtId__c = '333');
       	insert outletType;     	
     	
	    Outlet_Sub_Type__c oSubType = TestFactory.createOutletSubType(outletType.name);
	    insert oSubType;
      	
   		Outlet_Category__c category = TestFactory.createOutletCategory(oSubType.name);
        insert category;
        
        
        Outlet__c outlet1 = TestFactory.createOutlet(stt.State_ID__c, category.Outlet_Category_Id__c);
        outlet1.Outlet_Name__c = 'TestAccount';
        outlet1.name = '1234447';
        outlet1.Outlet_My_Sales_Id__c = 1234447;
        
        test.startTest();
        insert outlet1;
        /*Account OutletAccParent = new Account();  
        OutletAccParent.Name = 'ParentAusAccount';   
        OutletAccParent.RecordTypeId =  Utilities.getRecordTypeId('account', 'Outlet');
        OutletAccParent.Outlet_ID__c ='12346' ; 
        
        insert OutletAccParent ; */    
        
        List<Account> listacc = [Select Id, Name From account where Name = 'TestAccount' And Outlet_ID__c ='1234447' limit 1];
        //acc[0].Name = 'TestAcc';
        listacc[0].Called_on__c = True;
        listacc[0].Name = 'TestAccount1';
        RecursiveTriggerController.count = 0;
        update listacc;
        
        Test.stopTest();
    }
    
   
}