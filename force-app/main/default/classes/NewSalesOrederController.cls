/**
* @author : Sourav Nema
* @created : 
* @Description : Controller for New Sales Order page 
* @modified : Geeta Kushwaha, geeta.kushwaha@arxxus.com on 31 OCt, 2013
              by Geeta Kushwaha on 14 Feb, 2014. Display promotions applicable to parent banner group as well
*/
public with sharing class NewSalesOrederController {    
    public NewSalesOrederController(ApexPages.StandardController controller) {

    }
    
    private static final String PROMOTION_ID_FOR_CASE_DEAL_EVERYDAY = '2';
    private Date todaysDate {get; set;}
    public String drop1DateValidOrNot {get; set;}    
    Boolean inCludeNone =true;
    public Integer coloredRow{set;get;} 
    public Integer greenColoredRow {set;get;} 
    public List<SalesOrderWrapper> salesWrapper {set;get;}
    private Set<Id> prdIdList  = new Set<Id>();
    private  Set<String> prdctList           = new Set<String>();
    private   Set<String> wholeSalerList      = new Set<String>();
    public Boolean sendApproval =false;
    private Boolean sendApproval2 =false;
    private String recordType;
    private List<Sales_Order_Product__c> bonusProductList = new List<Sales_Order_Product__c>();
    Map<id,Product__c> prdctMap  =  new Map<id,Product__c>([SELECT Brand__r.name,Product_ID__c,Brand_ID__c,MLs_Per_Bottle__c,name,Bottles_Per_Carton__c 
                                                            FROM Product__c]);
    private Set<String> wBranchList = new Set<String>(); 
    private Set<String> promotionIdSet = new Set<String>();
    public String acId {set;get;}    
    public Boolean wholesalerNotExist {get;set;}
    public Boolean hideRestItems {get;set;}
    public Sales_Order__c salesRecord {set;get;}    
    private Map<String,String> customerNumberMap = new Map<String,String>();
    private String customerNumberWBO;
    public List<SelectOption> Items{get;set;}  
    public List<Sales_Order_Product__c> product = new List<Sales_Order_Product__c>();
    public List<Sales_Order_Product__c>product2 = new List<Sales_Order_Product__c>();
    List<Wholesaler_Branch_Outlet__c> branchOutlet;
    //Create Wholesaler Picklist
    public String  waccId;  
    public List<SelectOption> tradeLoaderSelectOption{get;set;}
    private static final String DEFAULT_SELECT_OPTION = '';  

    public void setwAccount(String wacc) {
        customerNumberWBO = wacc;
        List<String> wholesalerBranchId = wacc.split(':');
        System.debug('wholesalerBranchId: ' + wholesalerBranchId);        
        this.waccId = wholesalerBranchId[0];
        System.debug('wacc id2 is: ' + waccId);
    }  
    
    public String getwAccount() {   
        System.debug('wacc id is: ' + waccId);
        return waccId;       
    }

    //CONSTRUCTOR
    public NewSalesOrederController(){
        greenColoredRow = 0;
        todaysDate = Date.today();

        try{
            salesWrapper =  new List<SalesOrderWrapper>();
            Items = new List<SelectOption>(); 
            tradeLoaderSelectOption = new List<SelectOption>();
            tradeLoaderSelectOption.add(new SelectOption(DEFAULT_SELECT_OPTION,DEFAULT_SELECT_OPTION));
            
            Schema.DescribeFieldResult tradeLoaderField = Sales_Order__c.Trade_Loader__c.getDescribe();
            for (Schema.PicklistEntry pickVal : tradeLoaderField.getPicklistValues()) {
                tradeLoaderSelectOption.add(new SelectOption(pickVal.getValue(),pickVal.getLabel()));
            }
    
            salesRecord = new Sales_Order__c (Outlet_Name__c= ApexPages.currentPage().getParameters().get('acid'));         
            salesRecord.recordTypeId = Utilities.getRecordTypeId('Sales_Order__c','Standard Sales Order');
            salesRecord.Status__c = 'New Sales Order Created';  
            acId = ApexPages.currentPage().getParameters().get('acid');
            List<String> promotionId   = new List<String>();        
            
            //CREATE List OF PROMOTION ID
            System.debug('account id.....'+acId);
            Account acnt =  [SELECT Outlet_ID__c,Banner_Group_ID__c, Region_Id__c, Banner_Group__r.Parent_Hierarchy__c 
                             FROM Account 
                             WHERE id =:  acId ];   
                          
            Set <String> bannerGrpIdSet = new Set<String>();    
            bannerGrpIdSet.add(acnt.Banner_Group_ID__c);            
            if(acnt.Banner_Group__r.Parent_Hierarchy__c  != null) {             
                String parent = acnt.Banner_Group__r.Parent_Hierarchy__c ;              
                Set <String> mysalesIdSet = new Set<String>();              
                for(String s : parent.split(',',parent.countMatches(','))) {
                    try {                       
                        mysalesIdSet.add(''+Integer.valueOf(s)); //We dont have to add ** or * values, only Integer values need to be added                     
                    } catch(Exception e){}                  
                }               
                if(!mysalesIdSet.isEmpty()) {               
                    for(Account banner : [SELECT Banner_Group_ID__c
                                          FROM Account
                                          WHERE My_Sales_Id__c IN : mysalesIdSet
                                            AND RecordTypeId =: Utilities.getRecordTypeId('Account','Banner Group')]) {                                         
                        bannerGrpIdSet.add(banner.Banner_Group_ID__c);                      
                    }               
                }               
            } 
            
            //CREATE List OF PROMOTION ID FROM PROMOTION OUTLET         
            List<Promotion_Outlet__c> pOutlet = [   SELECT Promotion_ID__c 
                                                    FROM Promotion_Outlet__c  
                                                    WHERE Outlet_ID__c =:acnt.Outlet_ID__c
                                                        AND Promotion__r.Buy_Period_Start_Date__c <=:Date.today()
                                                        AND Promotion__r.Buy_Period_End_Date__c>=:Date.today()];    
            for(Promotion_Outlet__c po:pOutlet){    
                promotionIdSet.add(po.Promotion_ID__c);
            }
            
            //create  List of promotion id FROM wholesaler banner group
            List<Wholesaler_Banner_Group__c> wbGroup  = [   SELECT Id, Banner_Group_ID__c,name, Region_Id__c,
                                                               (SELECT Promotion_ID__c, Promotion__r.Buy_Period_Start_Date__c,Promotion__r.Buy_Period_End_Date__c 
                                                                FROM Promotion_Banner_Groups__r) 
                                                            FROM Wholesaler_Banner_Group__c  
                                                            WHERE Banner_Group_ID__c IN : bannerGrpIdSet
                                                                AND Region_Id__c =: acnt.Region_Id__c];             
            if(wbGroup.size()>0 ){  
                for(Wholesaler_Banner_Group__c WBG : wbGroup){
                    System.debug('WBG.RegionId: ' + WBG.Region_Id__c + ' WBG: ' + WBG.id);  
                    List<Promotion_Banner_Group__c> pbGropup = WBG.Promotion_Banner_Groups__r;  
                    for(Promotion_Banner_Group__c pbg : pbGropup){  
                        promotionIdSet.add(pbg.Promotion_ID__c);    
                    }
                }
            }
            System.debug('promotionIdSet: ' + promotionIdSet);  
            List<PromotionProduct__c> promotionProd = new List<PromotionProduct__c>();  
            if(promotionIdSet.size()>0){    
                promotionProd = [   SELECT name,id,Product__c,Promotion__r.Discount_Amount_1__c,Product__r.Product_ID__c, 
                                            Promo_Start_Date__c,Promo_End_Date__c, Promotion__r.Promotion_Type_ID__c 
                                    FROM PromotionProduct__c
                                    WHERE Promotion__r.name in:promotionIdSet
                                        AND Promotion__r.Buy_Period_Start_Date__c <=:Date.today()
                                        AND Promotion__r.Buy_Period_End_Date__c>=:Date.today()
                                        AND Active__c = true
                						AND Product__r.deactivate__c = false
                                    ORDER BY Product__r.name];
                
                Map<String, List<PromotionProduct__c>> colorVsPromotionPrdt = new Map<String, List<PromotionProduct__c>>();
                colorVsPromotionPrdt.put('red', new List<PromotionProduct__c>());
                colorVsPromotionPrdt.put('green', new List<PromotionProduct__c>());
                for (PromotionProduct__c promoPrdt : promotionProd) {
                    System.debug('PromotionId for Promotion ' + promoPrdt.Promotion__c + ' is ' + promoPrdt.promotion__r.Promotion_Type_ID__c);
                    if (promoPrdt.promotion__r.Promotion_Type_ID__c == PROMOTION_ID_FOR_CASE_DEAL_EVERYDAY) {
                        colorVsPromotionPrdt.get('green').add(promoPrdt);
                    } else {
                        colorVsPromotionPrdt.get('red').add(promoPrdt);
                    }
                }
                
                promotionProd = new List<PromotionProduct__c>();
                promotionProd.addAll(colorVsPromotionPrdt.get('green'));
                promotionProd.addAll(colorVsPromotionPrdt.get('red'));              
                greenColoredRow = colorVsPromotionPrdt.get('green').size(); 
            }        
            
            for(PromotionProduct__c prpmd : promotionProd){
                prdIdList.add(prpmd.Product__c);    
            }             
            System.debug('coloredRow: ' + coloredRow + ' ' + promotionProd.size());
            coloredRow  =  promotionProd.size();  
            
            //SELECT PROMOTION PRODUCT OF PRICING
            List<PromotionProduct__c> promotionProdOfPricing = [SELECT name,id,Product__c,Promotion__r.Discount_Amount_1__c,Product__r.Product_ID__c,
                                                                       Promo_Start_Date__c,Promo_End_Date__c 
                                                                FROM PromotionProduct__c
                                                                WHERE Pricing__r.Start_Date__c <=:Date.today()
                                                                    AND Pricing__r.End_Date__c>=:Date.today()
                                                                    AND Pricing__r.Wholesaler_Price__c !=0
                                                                    AND Promotion__c =null 
                                                                    AND Product__c NOT IN :prdIdList
                                                                    AND Active__c = true
            														AND Product__r.deactivate__c = false 
                                                                ORDER BY Product__r.name];       
            for(PromotionProduct__c prd : promotionProdOfPricing){
                promotionProd.add(prd);
            }
    
            for(PromotionProduct__c prmPrdct :promotionProd){   
                prdctList.add(prmPrdct.Product__r.Product_ID__c);
                promotionId.add(prmPrdct.id);   
            }
    
            //GET CURRENT PRICING OF PRODUCTS OF PROMOTION PRODUCTS
            DataLoaderHelper helper =  new DataLoaderHelper();
            Map<id,Pricing__c> pricingMap = new  Map<id,Pricing__c>();
            pricingMap.putAll(helper.getPromotionProductPricingMap(promotionId));   
    
            // ITERATE PROMOTION PRODUCT AND PREAPRE WRAPPER            
            for(PromotionProduct__c prmProd : promotionProd) {              
                SalesOrderWrapper slsWrapper = new SalesOrderWrapper();
                slsWrapper.product   = new Sales_Order_Product__c(PromotionProduct__c = prmProd.id);
                slsWrapper.product2  = new Sales_Order_Product__c(PromotionProduct__c = prmProd.id);                
                if(prmProd.Promo_Start_Date__c!=null) {
                    slsWrapper.startDate = prmProd.Promo_Start_Date__c;
                }
                if(prmProd.Promo_End_Date__c !=null) {
                    slsWrapper.endDate   = prmProd.Promo_End_Date__c;
                }
                //Set CURRENT PROMOTION DISCOUNT
                if(prmProd.Promotion__r.Discount_Amount_1__c != null) {             
                    slsWrapper.promotionDiscount  = decimal.valueOf(prmProd.Promotion__r.Discount_Amount_1__c).setScale(2);
                } else {
                    slsWrapper.promotionDiscount = decimal.valueOf('0.00').setScale(2);
                }               
                //Set Price Maxdiscount,remaining value
                if(prmProd.Product__c !=null) {
                    slsWrapper.prdct = prdctMap.get(prmProd.Product__c);
                    //IF THIS PROMOTION PRODUCT's PRODUCT  HAVE PRICING OF CURRECT Date
                    if(pricingMap.get(prmProd.id)!=null) {
                        //IF PRICING wholesaler price not null
                        if(pricingMap.get(prmProd.id).Wholesaler_Price__c != null) {
                            decimal pric = decimal.valueOf(String.valueOf(pricingMap.get(prmProd.id).Wholesaler_Price__c));
                            slsWrapper.price = pric;
                        } else {
                            slsWrapper.price = 10;
                        }   
                        if(pricingMap.get(prmProd.id).Maximum_Discount__c != null) { 
                            slsWrapper.maxDiscount = decimal.valueOf(String.valueOf(pricingMap.get(prmProd.id).Maximum_Discount__c)).setScale(2);
                        } else {    
                            slsWrapper.maxDiscount = decimal.valueOf('0.00').setScale(2);
                        }
                        
                        if(pricingMap.get(prmProd.id).Maximum_Discount__c!=null && prmProd.Promotion__r.Discount_Amount_1__c != null) {
                            decimal remaining =   decimal.valueOf(String.valueOf(pricingMap.get(prmProd.id).Maximum_Discount__c))
                                                        - decimal.valueOf(String.valueOf(prmProd.Promotion__r.Discount_Amount_1__c));
                            slsWrapper.remainingDiscount = String.valueOf(remaining).remove('.00'); 
                        } else {
                            slsWrapper.remainingDiscount = '0'; 
                        }
                    } else {    
                        slsWrapper.price = 0;
                        slsWrapper.maxDiscount = 0;
                        slsWrapper.remainingDiscount = '0';
                    }
                } else {
                    slsWrapper.prdct  = new Product__c();
                    slsWrapper.price = 0;
                    slsWrapper.maxDiscount = 0;
                    slsWrapper.remainingDiscount = '0';
                }   
                salesWrapper.add(slsWrapper);
            }           
            // Set wholesaler branch name on picklist
            List<Wholesaler_Branch_Outlet__c> branchOutlet = [SELECT WholeSalerAccountId__c,Wholesaler_Branch__c,Primary__c,Wholesaler_Branch__r.Wholesaler_Branch_Name__c,
                                                                    Wholesaler_Branch__r.Wholesaler_Account__r.name, Customer_Number__c  
                                                              FROM Wholesaler_Branch_Outlet__c 
                                                              WHERE Outlet_Account__c =:acId
                                                                AND Customer_Number__c != null
                                                                AND (End_Date__c >=: System.today()
                                                                    OR End_Date__c = null)];        
            for(Wholesaler_Branch_Outlet__c outlet : branchOutlet) {                
                 if(outlet.Primary__c == true) {    
                    Items.add(new SelectOption(outlet.Wholesaler_Branch__c + ':' + outlet.Customer_Number__c,outlet.Wholesaler_Branch__r.Wholesaler_Branch_Name__c + '-' + outlet.Customer_Number__c));
                    customerNumberMap.put(outlet.Wholesaler_Branch__c + ':' + outlet.Customer_Number__c, outlet.Customer_Number__c);
                    inCludeNone = false;
                    break;
                }                
            }
          
            //If there is no primary key include none
            if(inCludeNone) {
                Items.add(new SelectOption('','--None--'));    
            }
            for(Wholesaler_Branch_Outlet__c outlet : branchOutlet) {             
                if(outlet.Primary__c != true) {
                    Items.add(new SelectOption(outlet.Wholesaler_Branch__c + ':' + outlet.Customer_Number__c,
                                            outlet.Wholesaler_Branch__r.Wholesaler_Branch_Name__c + '-' + outlet.Customer_Number__c));
                    customerNumberMap.put(outlet.Wholesaler_Branch__c + ':' + outlet.Customer_Number__c, outlet.Customer_Number__c);
                }
            } 
    
            for(Wholesaler_Branch_Outlet__c outlet : branchOutlet) {
                //Create whole saler group product code for initial value
                if(outlet.Primary__c == true) {
                  waccId = outlet.Wholesaler_Branch__c;
                  showWholesalerGroup();
                }   
                wBranchList.add(outlet.Wholesaler_Branch__c);
            }
            if(wBranchList.size() == 0) {
                wholesalerNotExist = true;
                hideRestItems = false;
                System.debug('++++++BranchList '+wBranchList.size()+'sise '+wholesalerNotExist+'hideRestItems :'+hideRestItems);
            } else {
                wholesalerNotExist = false;
                hideRestItems = true;
            }   
            wBranchList.clear();
        } catch(exception e) {
        }
    }
    
    public pagereference save() {  
        //get whole saler account of wholesaler branche
        Wholesaler_Branch__c whlsalerList = new Wholesaler_Branch__c();
        if(waccId != null) {
            whlsalerList  =  [SELECT Wholesaler_Account__c  FROM Wholesaler_Branch__c WHERE id =:waccId];
        }          
        //Set sales order record value
        // Set status to sent for approval
        // so that record does not go directly to wholesaler
        // if sales order does not go for approval then updates status to 'New Sales Order Created'
        salesRecord.Status__c = 'Sent for Approval';
        salesRecord.Wholesaler_Branch__c = waccId;
        salesRecord.Wholesaler__c  =  whlsalerList.Wholesaler_Account__c;
        salesRecord.Wholesaler_Account_Number__c =  customerNumberMap.get(customerNumberWBO);
                
        /** 
        * Arxxus Support
        * Changes to skip approval process for State Sales Manager - AUS profile
        */
       	Set<String> approvalSkipProfilesSet = new Set<String>();            
		for (Profile p : [SELECT Id FROM Profile
								WHERE Name IN : new List <String>{'State Sales Manager - AUS'}]) {                                 
    		approvalSkipProfilesSet.add(p.Id);                                
		}                                                                       
        
        try {
            if(sendApproval && !approvalSkipProfilesSet.contains(UserInfo.getProfileId()))               
                salesRecord.Send_Approval_for_discount__c = true;
               
            if(salesRecord.Drop_1_Date__c == null) {
                if (datetime.now().hour() < 12) {            
                    salesRecord.Drop_1_Date__c = todaysDate.addDays(1);              
                } else {                    
                    salesRecord.Drop_1_Date__c = todaysDate.addDays(2);                    
                }                      
            }               
            insert salesRecord; 
        } catch(exception e) {
            ApexPages.addMessages(e);
            return null;
        }
        Integer counter = 0;
                 
        for(SalesOrderWrapper wrap:salesWrapper) {          
            if(wrap.product.Quantity__c != null) {            
                wrap.product.Sales_Order__c   = salesRecord.id; 
    
                //Set total applied discount of promotion product.
    
                 
                if( decimal.valueOf(String.valueOf(wrap.promotionDiscount))<wrap.product.Discount__c){              
                    wrap.product.Total_Applied_Discount2__c  = wrap.product.Discount__c.setScale(2);
                }
                else{
                    wrap.product.Total_Applied_Discount2__c  = decimal.valueOf(String.valueOf(wrap.promotionDiscount)).setScale(2);
                }
    
                if(wrap.product.Total_Applied_Discount2__c == null)
                    
                    wrap.product.Total_Applied_Discount2__c = 0;
                    
                if(wrap.price == null) {
                 
                    wrap.price = 0 ;
                    
                }    
                    
                //Set total price of promotion product  
                wrap.product.Total_Price__c  = (wrap.price - wrap.product.Total_Applied_Discount2__c)*wrap.product.Quantity__c;                
                System.debug('-wrap.product.Total_Price__c-'+wrap.product.Total_Price__c);                
                if(wrap.maxDiscount < wrap.product.Total_Applied_Discount2__c || wrap.product.Bonus_Product__c != null)                
                    sendApproval = true; 
                
                product.add(wrap.product);              
                if(wrap.product.Bonus_Product__c != null && wrap.product.Bonus_Product__c > 0) {                    
                    Sales_Order_Product__c prd = new Sales_Order_Product__c();                  
                    prd.Sales_Order__c = wrap.product.Sales_Order__c;                   
                    prd.PromotionProduct__c = wrap.product.PromotionProduct__c;                 
                    prd.Discount__c  = 0;                   
                    prd.Quantity__c = wrap.product.Bonus_Product__c;                    
                    prd.Bonus_Product__c = wrap.product.Bonus_Product__c;                   
                    prd.Bonus_Status__c = 'Dependent Child';                    
                    wrap.product.Total_Quantity_Including_Bonus__c = wrap.product.Bonus_Product__c + wrap.product.Quantity__c;                  
                    wrap.product.Bonus_Status__c = 'Dependent Master';                  
                    wrap.product.ILG_Discount__c = ((wrap.product.Quantity__c * wrap.product.Total_Applied_Discount2__c 
                                                        + wrap.product.Bonus_Product__c * wrap.price)/wrap.product.Total_Quantity_Including_Bonus__c).setScale(2);                  
                    wrap.product.Bonus_Product__c = null;                   
                    product.add(prd);                   
                }
            } else if (wrap.product.Bonus_Product__c != null && wrap.product.Bonus_Product__c > 0) {                
                sendApproval = true;                 
                wrap.product.Sales_Order__c = salesRecord.id;                
                wrap.product.Quantity__c = wrap.product.Bonus_Product__c;                
                wrap.product.Discount__c = 0;                 
                wrap.product.Total_Quantity_Including_Bonus__c = wrap.product.Bonus_Product__c;                
                wrap.product.ILG_Discount__c = wrap.price.setScale(2);                
                wrap.product.Bonus_Status__c = 'Independent';                
                product.add(wrap.product);                
            }
        }
        try{
            insert product;
        } catch(dmlexception e) {        
        }
        //send approval process.  
        // if order is going for approval then do nothing
        // else update sales order status to 'New Sales Order Created' so that order can be directly placeed to wholesaler
        if(sendApproval && !approvalSkipProfilesSet.contains(UserInfo.getProfileId())) {           
            if(!salesRecord.Send_Approval_for_discount__c) {
                salesRecord.Send_Approval_for_discount__c = true;
                update salesRecord;
            }           
            sendApproval(salesRecord);
        } else {
            salesRecord.Status__c = 'New Sales Order Created';
            update salesRecord;
        }
        return new pagereference('/'+salesRecord.id);        
    }

    private void sendApproval(Sales_Order__c s) {      
        // Create an approval request for the account
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(s.id);

        // Submit the approval request for the account
        Approval.ProcessResult result = Approval.process(req1);
        // Verify the result
        System.assert(result.isSuccess());
        System.assertEquals(
                'Pending', result.getInstanceStatus(), 
                'Instance Status'+result.getInstanceStatus());
    }

    //show value of Wholesaler Group Product code when user change whole saler branch
    public void showWholesalerGroup() {        
        System.debug('wacc id3 is: ' + waccId);
        if(waccId!=null) {               
            Map<String,String> groupProuctMap  =  new Map<String, String>();
            Wholesaler_Branch__c branch = [SELECT Wholesaler_Account__c FROM Wholesaler_Branch__c WHERE id =:waccId];
            Account ac = [SELECT id,Wholesaler_Group__r.Wholesaler_Group_ID__c FROM Account WHERE id =:branch.Wholesaler_Account__c];
            wholeSalerList.add(ac.Wholesaler_Group__r.Wholesaler_Group_ID__c );
            DataLoaderHelper helper = new DataLoaderHelper();
            groupProuctMap.putAll(helper.getWholeSalerGroupProductMap(prdctList,wholeSalerList));
            for(SalesOrderWrapper wrap:salesWrapper){
                if(groupProuctMap.get(wrap.prdct.Product_ID__c+':'+ac.Wholesaler_Group__r.Wholesaler_Group_ID__c)!=null) {                    
                    wrap.wholeSalerGroupProduct = groupProuctMap.get(wrap.prdct.Product_ID__c                    
                                                        +':'+ac.Wholesaler_Group__r.Wholesaler_Group_ID__c);
                } else {
                    wrap.wholeSalerGroupProduct = '';
                }
            }
        } else {
            for(SalesOrderWrapper wrap:salesWrapper) {                
                wrap.wholeSalerGroupProduct = '';                
            }
        }
    }

    //Create bonus product
    void cloneSalesOrderProduct(List<Sales_Order_Product__c> prdctList) {
        List<Sales_Order_Product__c> prdList = new List<Sales_Order_Product__c>();
        for(Sales_Order_Product__c prdct :prdctList) {
            System.debug('-prdct.Bonus_Product__c1-'+prdct.Bonus_Product__c);
            if(prdct.Bonus_Product__c != 0 && prdct.Bonus_Product__c != null) {
                System.debug('-prdct.Bonus_Product__c-'+prdct.Bonus_Product__c);
                Sales_Order_Product__c prd = new Sales_Order_Product__c();
                prd.Sales_Order__c = prdct.Sales_Order__c;
                prd.PromotionProduct__c = prdct.PromotionProduct__c;
                prd.Discount__c = 0;
                prd.Quantity__c = prdct.Bonus_Product__c;
                prd.Bonus_Product__c = prdct.Bonus_Product__c;
                prdct.Bonus_Product__c = null;
                prdList.add(prd);
            }            
        }
        System.debug('prdList [' +prdList+ ']');
        insert prdList;
    }
    
    /**
     * @author : Geeta Kushwaha, geeta.kushwaha@arxxus.com
     * @Date : 23-12-2013
     * @Description : checks if a drop1 Date is valid or not AND sets appropriate result in 'drop1DateValidOrNot' field(String)
     * @parameter : None
     * @return : PageReference
     */
    public PageReference validateDrop1Date() {        
        drop1DateValidOrNot = '';
        if(salesRecord != null && salesRecord.Drop_1_Date__c != null) {            
            if(salesRecord.Drop_1_Date__c == todaysDate.addDays(1)) {                
                if (datetime.now().hour() < 12) {            
                    drop1DateValidOrNot = 'Yes';              
                } else {                    
                    drop1DateValidOrNot = 'No';                    
                }
            } else if(salesRecord.Drop_1_Date__c >= todaysDate.addDays(2)) {                
                drop1DateValidOrNot = 'Yes';                
            }        
        } else        
            drop1DateValidOrNot = '';        
        return null;        
    }
}