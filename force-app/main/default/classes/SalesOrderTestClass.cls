/**
  Created by-:Sourav Nema
  Created Date -:6/4/2013
 */
@isTest
public class SalesOrderTestClass {
   //generate data
   
   static Account outletAcc;
   static  Account wAccount; 
      
    static testMethod void myUnitTest() {
    	/*CREATE TEST DATA */
    	
    	
    	 
      //Get wholesaler account
	       
	       wAccount = new Account();
	       wAccount.Name = 'AUBAR';
	       
	       wAccount.RecordTypeId = Utilities.getRecordTypeId('account', 'Wholesaler');
	       
	       wAccount.Wholesaler_ID__c ='123';
	       insert wAccount;	
	      
	    	
    	//Create account 
	       outletAcc = TestFactory.getAccount('AUS-Outlet', Utilities.getRecordTypeId('account', 'Outlet'));    
	       outletAcc.Outlet_ID__c = '123';
	       outletAcc.Banner_Group_ID__c ='123';
	       insert outletAcc;
    	 
    	 
    	//Create Brand
          Brand__c brand= TestFactory.getBrand('123','127');
    	  
    	  insert brand;
    	//Create PromotedRange
      
          Promoted_Range__c prmtRange = TestFactory.createPromotedRange(brand.Brand_ID__c);
        
        insert prmtRange; 
    	
    	
     
    	
       //Create Promotion 
	       Promotion__c  promotion = TestFactory.createPromotion(prmtRange.Promotion_Range_ID__c);
	       insert promotion; 
	   
	     //create  PromotionProduct__c
           PromotionProduct__c prmprdct = TestFactory.createPromotionProduct();
           prmprdct.Promotion__c = promotion.ID;
           insert prmprdct;
               
       //Create Promotion_Outlet__c 
       
            Promotion_Outlet__c pOutLet = new Promotion_Outlet__c(Promotion_ID__c =promotion.name, Promotion__c = promotion.id,
                                                                  Outlet_ID__c  = outletAcc.Outlet_ID__c,
                                                                  PromotionOutlet_MySales_Id__c = integer.valueOf(promotion.name));
       
            insert pOutLet;
            
            
            
       //Create Region
       Region__c region = new Region__c(name ='rgn1', Region_ID__c ='123' ,Region_Abbr__c ='AUS');
       insert region;
       
       //Get banner account
       Account bAccount = new Account();
        
       bAccount.Name = 'AUBAR';
       
       bAccount.RecordTypeId = Utilities.getRecordTypeId('account', 'Banner Group');
       
       bAccount.Banner_Group_ID__c ='123';
       insert bAccount;	
       
            
       //Create WholeSalerBannerGroupTrigger
       
        Wholesaler_Banner_Group__c wbg = new Wholesaler_Banner_Group__c(Wholesaler_ID__c = wAccount.Wholesaler_ID__c,
                                                                        Region_ID__c = region.Region_ID__c,
                                                                        Banner_Group_ID__c = bAccount.Banner_Group_ID__c,name='1245');
        insert wbg;
       
      
      //create promotion banner group
      
       //Promotion_Banner_Group__c  pbGroup =TestFactory.createPromotionBannerGroup(wbg.name,promotion.name);
       //insert pbGroup;
          
       
       Wholesaler_Group__c wg = new Wholesaler_Group__c(name ='Aus Group', Wholesaler_Group_ID__c ='1233');
    	insert wg;
    	
    	
    	
    	
       PageReference pageRef = Page.New_Sales_Order; 
       
       getWaccId();
     
       Test.setCurrentPage(pageRef);
       ApexPages.currentPage().getParameters().put('acId',outletAcc.id);
       ApexPages.currentPage().getParameters().put('recName','Standard Sales Order');	
       	
       NewSalesOrederController nwSales = new NewSalesOrederController();
        nwSales.sendApproval = true;
        nwSales.showWholesalerGroup(); 
        string wacc = nwSales.getwAccount();
        nwSales.setwAccount(wacc);
        nwSales.salesWrapper[0].product.Bonus_Product__c =2;
       	nwSales.save();
       
    }
      
    
      //Get wholesaler account
      
      public static void getWaccId(){
      	
      	//create wholesaler group
      	Wholesaler_Group__c wGroup = new Wholesaler_Group__c(name ='AusGroup',Wholesaler_Group_ID__c ='80');
      	insert wGroup;
      	
      	   
       //Create whole saler branch
       
       Wholesaler_Branch__c wBranch = new Wholesaler_Branch__c(Wholesaler_ID__c = '123', Wholesaler_Account__c = wAccount.id, 
                                                               Wholesaler_Branch_Name__c = 'AUBranch',  Wholesaler_Branch_Id__c ='123');
       insert wBranch;
       
       //create Wholesaler Branch Outlet
       
       Wholesaler_Branch_Outlet__c  branchOutlet = new Wholesaler_Branch_Outlet__c(Wholesaler_Branch_ID__c ='123', Wholesaler_Branch__c =wBranch.id ,
                                                                      Outlet_Account__c =outletAcc.id, Primary__c =true,Outlet_ID__c ='123',
                                                                      Customer_Number__c ='1345',
                                                                      Wholesaler_Branch_My_Sales_Id__c = '9134512312');
                                                                      
       insert branchOutlet;                                                               
       
      }
}