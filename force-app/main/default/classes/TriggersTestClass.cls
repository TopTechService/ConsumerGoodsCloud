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
(seealldata=false)
private class TriggersTestClass {

    static testMethod void myUnitTest() {
      
      system.debug('myUnitTest');
      PromotionProduct__c prmnpdct = TestFactory.createPromotionProduct();	
      
      //insert custom setting 
      Default_Account_Owner__c defaultOwner = new Default_Account_Owner__c();
      defaultOwner.name = 'Default account Owner';
      defaultOwner.OwnerId__c = UserInfo.getUserId();
      insert defaultOwner;

      //Get outlet account map
     
       Account OutletAcc = new Account(); 
       OutletAcc.Name = 'AusAccount';   
       OutletAcc.RecordTypeId =  Utilities.getRecordTypeId('account', 'Outlet');
       OutletAcc.Outlet_ID__c ='1234445' ;  
        OutletAcc.ShippingCountry = 'AUSTRALIA';
       insert OutletAcc;
      
      
      //Get wholesaler account
       Account wAccount = new Account();
       wAccount.Name = 'AUBAR';
       wAccount.RecordTypeId = Utilities.getRecordTypeId('account', 'Wholesaler');
       wAccount.Wholesaler_ID__c ='123';
        wAccount.ShippingCountry = 'AUSTRALIA';
       insert wAccount;	
      
      
        //Get banner account
       Account bAccount = new Account();
       bAccount.Name = 'AUBAR';
       bAccount.RecordTypeId = Utilities.getRecordTypeId('account', 'Banner Group');
       bAccount.Banner_Group_ID__c ='123';
       bAccount.ShippingCountry = 'AUSTRALIA';
       insert bAccount;	
       
       
       
      
      //Create Brand
      Brand__c brand= TestFactory.getBrand('123','127');
      
      insert brand;
      //Test Product
      Product__c product = TestFactory.createProductname(brand.Brand_ID__c, '9999999');
      insert product;
      
      //Test Pricing
      Pricing__c pric = TestFactory.createPricing(product.Product_ID__c);
      insert pric;
      
      //Test WholeSalerGroupProduct
      Wholesaler_Group_Product__c wgp = TestFactory.createWholeSalerGroupProductwithId(product.Product_ID__c, '67890');
      insert wgp;
      
      
      
      
      //Test WholeSalerBranch Trigger
      
       Wholesaler_Branch__c wBranche = TestFactory.createWholeSalerBranch('123');
       insert wBranche;
       
       
       
       //Create Region
       Region__c region = new Region__c(name ='rgn1', Region_ID__c ='123' ,Region_Abbr__c ='AUS');
       insert region;
       
       //Create OutLet Type
       Outlet_Type__c outletType = new Outlet_Type__c(name ='123499', Outlet_Type_Description__c ='bar',Type_ExtId__c = '123499');
       insert outletType;
       
       
      //create Outlet_Sub_Type__c trigger
      Outlet_Sub_Type__c oSubType = TestFactory.createOutletSubType(outletType.name);
      insert oSubType;
      
      //Test outletCategoryTrigger
      Outlet_Category__c category = TestFactory.createOutletCategory(oSubType.name);
      insert category;
      
      //Test State Trigger
       State__c stt = TestFactory.createState(region.Region_ID__c,'4'); 
      insert stt;
      
      //Test Outlet trigger
      
        Outlet__c outlet=TestFactory.createOutlet(stt.State_ID__c, category.Outlet_Category_Id__c);
        insert outlet;

        update outlet;
        
      //Test WholesalerBranchOutlet Trigger
      
       //Wholesaler_Branch_Outlet__c wbOutlet = TestFactory.createWholeSalerBranchOutlet(OutletAcc.Outlet_ID__c,wBranche.Wholesaler_Branch_Id__c);
       //insert wbOutlet;
       
       
       //Test WholeSalerBannerGroupTrigger
       
       //Wholesaler_Banner_Group__c wbg = new Wholesaler_Banner_Group__c(Wholesaler_ID__c = wAccount.Wholesaler_ID__c,
       //                                                                 Region_ID__c = region.Region_ID__c,
       //                                                                 Banner_Group_ID__c = bAccount.Banner_Group_ID__c,name='1245000');
       //insert wbg;
       
       //test PromotedRange
      
        //Promoted_Range__c prmtRange = TestFactory.createPromotedRange(brand.Brand_ID__c);
        
        //insert prmtRange; 
        
       //Test Promotion Trigger
       //Promotion__c  promotion = TestFactory.createPromotion(prmtRange.Promotion_Range_ID__c);
       //insert promotion; 
      
       //Test promotionBannerGroupTrigger 
       //Promotion_Banner_Group__c  pbGroup =TestFactory.createPromotionBannerGroup(wbg.name,promotion.name);
       //insert pbGroup;
       
       //Test PromotionOutlet Trigger 
       
       //Promotion_Outlet__c  pOutlet =TestFactory.createPromotionOutlet(OutletAcc.Outlet_ID__c,promotion.name);
       //insert pOutlet;
       
       
       //Test Banner Group  Trigger 
       
       //Banner_Group__c  bGroup = TestFactory.createBannerGroup(bAccount.Banner_Group_ID__c);
       //insert bGroup;
       //update bGroup;
       
        
       //Test createBannerGroupOutlet  Trigger 
       
       Banner_Group_Outlet__c  bgOutlet = TestFactory.createBannerGroupOutlet(OutletAcc.Outlet_ID__c,bAccount.Banner_Group_ID__c);
       bgOutlet.Outlet_Account__c = OutletAcc.id;
       insert bgOutlet;
      
       update bgOutlet;
       
      
    
        //DataLoaderHelper helper = new DataLoaderHelper();
        //list<string> promotionId = new list<string>();
        

       
      
    }
    
    static testMethod void myUnitTest2() {
      
      system.debug('myUnitTest');
      PromotionProduct__c prmnpdct = TestFactory.createPromotionProduct();	
      
      //insert custom setting 
      Default_Account_Owner__c defaultOwner = new Default_Account_Owner__c();
      defaultOwner.name = 'Default account Owner';
      defaultOwner.OwnerId__c = UserInfo.getUserId();
      insert defaultOwner;

      //Get outlet account map
     
       Account OutletAcc = new Account(); 
       OutletAcc.Name = 'AusAccount';   
       OutletAcc.RecordTypeId =  Utilities.getRecordTypeId('account', 'Outlet');
       OutletAcc.Outlet_ID__c ='1234445' ; 
        OutletAcc.ShippingCountry = 'AUSTRALIA';
       insert OutletAcc;
      
      
      //Get wholesaler account
       Account wAccount = new Account();
       wAccount.Name = 'AUBAR';
       wAccount.RecordTypeId = Utilities.getRecordTypeId('account', 'Wholesaler');
       wAccount.Wholesaler_ID__c ='123';
        wAccount.ShippingCountry = 'AUSTRALIA';
       insert wAccount;	
      
      
        //Get banner account
       Account bAccount = new Account();
       bAccount.Name = 'AUBAR';
       bAccount.RecordTypeId = Utilities.getRecordTypeId('account', 'Banner Group');
       bAccount.Banner_Group_ID__c ='123';
        bAccount.ShippingCountry = 'AUSTRALIA';
       insert bAccount;	
       
       
       
      
      //Create Brand
      Brand__c brand= TestFactory.getBrand('123','127');
      
      insert brand;
      //Test Product
      Product__c product = TestFactory.createProductname(brand.Brand_ID__c, '9999999');
      insert product;
      
      //Test Pricing
      Pricing__c pric = TestFactory.createPricing(product.Product_ID__c);
      insert pric;
      
      //Test WholeSalerGroupProduct
      Wholesaler_Group_Product__c wgp = TestFactory.createWholeSalerGroupProductwithId(product.Product_ID__c, '67890');
      insert wgp;
        
      //Create Region
       Region__c region = new Region__c(name ='rgn1', Region_ID__c ='123' ,Region_Abbr__c ='AUS');
       insert region;
      
      //Test State Trigger
       State__c stt = TestFactory.createState(region.Region_ID__c,'4'); 
      insert stt;
      
      
      //Test WholeSalerBranch Trigger
      
       Wholesaler_Branch__c wBranche = TestFactory.createWholeSalerBranch('123');
       insert wBranche;
        
                //Test DataLoader Helper
    
        DataLoaderHelper helper = new DataLoaderHelper();
        list<string> promotionId = new list<string>();
   
               //test getBannerGroupOutlet 
        list<Id> accList = new list<Id>();
        accList.add(OutletAcc.id);
        
        		list<Banner_Group_Outlet__c> bgo = helper.getBannerGroupOutlet (accList);
        
        //Test getIdOutletMap
        set<string> outLetId = new set<string>(); 
        outLetId.add('AusOutlet');
        		map<string, Outlet__c> bgoMap = helper.getIdOutletMap (outLetId);
        
        //Test getRegionStateMap 
        list<string> rgn = new list<string>();
        rgn.add(stt.Region_ID__c );
        system.debug('rgn: ' + rgn);
        	map<string,string> rgnState = helper.getRegionStateMap(rgn);
        
                //TEST getPromotionProduct method
        
        promotionId.add('568');
        PromotionProduct__c prmprdct = new PromotionProduct__c(name ='568',Pricing__c = pric.id, Product__c = product.id);
        insert prmprdct;
        list<PromotionProduct__c> prmnList =helper.getPromotionProduct(promotionId);
        
        //Test getPromotionProductPricingMap
        
        list<ID> prdctId = new list<ID>();
         prdctId.add(prmprdct.id);
         	map<id,Pricing__c> pricMap = helper.getPromotionProductPricingMap(prdctId);
        
    }
    
   
}