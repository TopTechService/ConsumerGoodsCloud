/**
* @author    : Created by Geeta Kushwaha on 23 Apr, 2013  geeta.kushwaha@arxxus.com
* @Purpose   : Test Factory class
* @Criteria  : 
* @Modified  : 
*/
@isTest
public class TestFactory {
    
    public static Account getAccount(String accName, Id recTypeId) {
        
        Account acc = new Account();
        
        acc.Name = accName;
        
        acc.RecordTypeId = recTypeId;
        
        return acc;                   
        
    }
    
    public static Contact getContact(String lastName, Id accId){
        
        Contact con = new Contact();
        
        con.LastName = lastName;
        
        con.AccountId = accId;
        
        return con;
        
    }
    
    public static Account getAccount(String Name, Id Banner_Group_Id, string BillingPostalCode, Id stateId, String BillingCity, decimal Volume, String Account_Grading ) {
        
        Account acc = new Account();
        
        acc.Name = Name;
        
        acc.Banner_Group__c = Banner_Group_Id;
        
        acc.BillingPostalCode = BillingPostalCode;
        
        acc.State__c = stateId;
        
        acc.BillingCity = BillingCity;
        
        acc.Volume__c = volume;
        
        acc.Account_Grading__c = Account_Grading;
        
        acc.Called_On__c = true;
        
        acc.Active__c = true;
        
        return acc;                   
        
    }
    
    
    public static State__c getState(String regionId){
        
        State__c st = new State__c();
        
        st.Region_ID__c = regionId;
        
        return st;
        
    }
    
    public static Region__c getRegion(String Region_Abbr, String Region_ID){
        
        Region__c region = new Region__c();
        
        region.Region_Abbr__c = Region_Abbr;
        
        region.Region_ID__c = Region_ID;
        
        return region;
        
    }
    
    public static Task getTask(String subject, Id WhatId, date activityDate, Id recType, String Status){
        
        Task t = new Task();
        
        t.Subject = subject;
        
        t.WhatId = WhatId;
        
        t.ActivityDate = activityDate;
        
        t.RecordTypeId = recType;
        t.Status=Status;
        
        return t;
        
    }
    
    public static Event getEvent(String subject, Id WhatId, date activityDate, Id recType, String Status){
        
        Event t = new Event();
        t.Subject = subject;
        t.WhatId = WhatId;
        t.ActivityDate = activityDate;
        t.RecordTypeId = recType;
        t.Status__c = Status;
        t.DurationInMinutes = 3600;
        t.StartDateTime = activityDate + 6/24;
        t.Type_of_Call__c = 'Outlet Visit';
        return t;
        
    }
    
    public static Call_Cycle__c createCallCycle(String Call_Cycle, Date Start_Date, Date End_Date, String Location, String Month, String Year){
        
        Call_Cycle__c cc = new Call_Cycle__c();
        
        cc.Call_Cycle__c = Call_Cycle;
        
        cc.End_Date__c = End_Date;
        
        cc.Start_Date__c = Start_Date;
        
        cc.Location__c = Location;
        
        cc.Month__c = Month;
        
        cc.Year__c = Year;
        
        return cc;
        
    }
    
    public static Objective__c getObjective(String name, Id callCycle, String typeOfObjective, String region, String product, String priority){
        
        Objective__c o = new Objective__c();
        
        o.Name = name;
        
        o.Call_Cycle__c = callCycle;
        
        o.Type_of_Objective__c = typeOfObjective;
        
        o.Region__c = region;
        
        o.Product__c = product;
        
        o.Priority_KPI__c = priority;
        
        return o;
        
    }
    
    public static Attachment getAttachment(String name, Id parentId, blob body, String contentType){
        
        Attachment attachment = new Attachment();
        
        attachment.name = name;
        
        attachment.ParentId = parentId;
        
        attachment.Body = body;
        
        attachment.ContentType = contentType;
        
        return attachment;
        
    }
    
    public static Brand__c getBrand(String brandId, String sapCode ){
        
        Brand__c b = new Brand__c();
        
        b.Brand_ID__c = brandId;
        
        b.SAP_Brand_Code__c = sapCode;
        
        return b;
        
    }
    
    public static User getUser(String username, String lastname, String alias, String email, Id profileId, Id userRoleId){
        
        User u = new User();
        
        u.username = 'Campz' + username;
        
        u.lastname = lastname;
        
        u.alias = alias;
        
        u.email = email;
        
        u.profileid = profileId;
        
        u.UserRoleId = userRoleId;
        
        u.emailencodingkey = 'UTF-8';
        
        u.languagelocalekey = 'en_US';
        
        u.localesidkey = 'en_US';
        
        u.timezonesidkey = 'America/Los_Angeles';
        
        return u;       
        
    }
    
    public static UserRole getUserRole(String name, Id parentRole){
        
        UserRole ur = new UserRole();
        
        ur.Name = name;
        
        ur.ParentRoleId = parentRole;
        
        return ur;
        
    }
    
    
    
    
    // Create Banner_Group_Outlet__c
    public static Banner_Group_Outlet__c createBannerGroupOutlet(string outletId, string bannerGroupId){
        
        Banner_Group_Outlet__c  bgo  =  new Banner_Group_Outlet__c ();
        
        bgo.Outlet_ID__c            =  outletId;
        bgo.Banner_Group_ID__c      =  bannerGroupId;
        bgo.Banner_Group_Outlet_ID_My__c = decimal.valueOf(outletId + bannerGroupId);
        
        return bgo;
        
    }
    
    
    
    //Create Banner_Group__c
    public static Banner_Group__c createBannerGroup(string parentbannerGroupId){
        
        Banner_Group__c bg             =  new  Banner_Group__c();
        bg.Parent_Banner_Group_ID__c   =  parentbannerGroupId;
        bg.Banner_Group_ID__c		   =  parentbannerGroupId + '1';
        return bg;
        
    }
    
    // Create Outlet_Category__c
    
    public static Outlet_Category__c createOutletCategory(string subTypeId){
        
        
        Outlet_Category__c  oc  =  new Outlet_Category__c(Outlet_SubType_ID__c  =  subTypeId , Outlet_Category_Id__c = subTypeId);
        return oc;
        
    }
    
    
    // Create Outlet_Sub_Type__c
    
    public static Outlet_Sub_Type__c createOutletSubType(string outLetId){
        
        Outlet_Sub_Type__c ost  =  new Outlet_Sub_Type__c(Outlet_Type_Id__c  = outLetId, name = outLetId);
        return ost;
        
    }
    
    //create outlet
    
    public static Outlet__c createOutlet(string stateId, string outletCategoryId){
        
        Outlet__c otlt   = new Outlet__c(State_ID__c =  stateId , Outlet_Category_Id__c  = outletCategoryId, name ='AusOutlet', Outlet_My_Sales_Id__c = integer.valueOf(stateId) + integer.valueOf(outletCategoryId) , Outlet_Name__c ='AusOutlet');
        return otlt;
        
    }
    
    //Create pricing
    
    public static Pricing__c createPricing(string prdctId){
        
        
        Pricing__c  prc =   new Pricing__c(Product_ID__c = prdctId,Start_Date__c = Date.today(),End_Date__c = Date.today().addDays(4),Maximum_Discount__c = 500, Pricing_MySales_ID__c = integer.valueOf(prdctId)); 
        return prc;
    }
    
    public static Product__c getProduct(String productName, string brandId, String Product_ID, String classification, String subClassification){
        
        Product__c  prdct=  new Product__c(name = productName, Brand_ID__c = brandId, Product_ID__c = Product_ID, Classification__c = classification, Sub_Classification__c = subClassification);
        return prdct;
    }
    
    public static Sale_MySales__c getSalesMySales(decimal nineLe, Id Banner_Group, String outlet, String product, date salesDate){
        
        Sale_MySales__c mySales = new Sale_MySales__c();
        
        mySales.Nine_LE__c = nineLe;
        
        mySales.Banner_Group__c = Banner_Group;
        
        mySales.OutletID__c = outlet;
        
        mySales.ProductID__c = product;
        
        mySales.Sale_Date__c = salesDate;
        
        return mySales;
        
    }
    
    public static Sale_MySales__c getSalesMySaleswithID(decimal nineLe, Id Banner_Group, String outlet, String product, date salesDate, string SaleID){
        
        Sale_MySales__c mySales = new Sale_MySales__c();
        
        mySales.Nine_LE__c = nineLe;
        
        mySales.Banner_Group__c = Banner_Group;
        
        mySales.OutletID__c = outlet;
        
        mySales.ProductID__c = product;
        
        mySales.Sale_Date__c = salesDate;
        
        mySales.Sale_ExtId__c = SaleID;
        
        return mySales;
        
    }    
    //Create product
    
    public static Product__c createProduct(string brandId){
        
        Product__c  prdct=  new Product__c(Brand_ID__c = brandId,Product_ID__c ='123');
        return prdct;
    }
    
    public static Product__c createProductname(string brandId,string name){
        
        Product__c  prdct=  new Product__c(Brand_ID__c = brandId,Product_ID__c = name);
        return prdct;
    }
    
    //Create promoted range
    
    public static Promoted_Range__c createPromotatedRange(string brandId){
        
        Promoted_Range__c  pr=  new Promoted_Range__c(Brand_ID__c = brandId); 
        
        return pr;
        
        
    }
    
    
    //  create promotionBannerGroup
    
    public static Promotion_Banner_Group__c createPromotionBannerGroup(string bnrId, string prmtnId){
        
        Promotion_Banner_Group__c pbg  =  new Promotion_Banner_Group__c(Wholesaler_Banner_Group_ID__c = bnrId,Promotion_Banner_Group_MySales_Id__c = integer.valueOf(bnrId), Promotion_ID__c= prmtnId);
        return pbg;
        
    }
    
    //created PromotionOutlet     
    public static Promotion_Outlet__c createPromotionOutlet(string otltId, string prmtnId){
        system.debug('outletIdd....'+otltId);
        
        Promotion_Outlet__c po  =  new Promotion_Outlet__c(Outlet_ID__c = otltId, Promotion_ID__c= prmtnId, PromotionOutlet_MySales_Id__c = 999999999);
        return po;
        
        
    }
    
    //created Promotion__c
    public static Promotion__c createPromotion(string prmtRange){
        
        Promotion_Type__c prmType = new Promotion_Type__c(name ='99999999', Promotion_Type_My_Sales_ID__c = 99999999 ,  Promotion_Type_Desc__c ='abcd');
        insert prmType;
        Spend_Type__c spndType = new Spend_Type__c(name ='989', Spend_Type_Desc__c ='abcd');
        insert spndType;
        Promotion__c prtmn  =  new Promotion__c(name ='1234',Promoted_Range_ID__c = prmtRange, Promotion_Type_ID__c = prmType.name,
                                                Spend_Type_Id__c =spndType.name,Buy_Period_Start_Date__c =Date.today(), 
                                                Buy_Period_End_Date__c = Date.today().addDays(5),
                                                Promotion_ExtId__c = '1234');
        return prtmn;
        
        
    }
    
    //Created PromotedRange
    public static Promoted_Range__c createPromotedRange(string brandId){
        
        Promoted_Range__c prtmn  =  new Promoted_Range__c(Promotion_Range_ID__c = '123', name = '200ml',Brand_ID__c = brandId);
        return prtmn;
        
        
    } 
    
    //Created PromotionType
    /* public static Promotion__c createPromotion(string prmtRange, string prmtnType, string spndType){

Promotion__c prtmn  =  new Promotion__c(Promoted_Range_ID__c = prmtRange, Promotion_Type_ID__c = prmtnType, Spend_Type_Id__c =spndType);
return prtmn;


}

//Created SpendType
public static Promotion__c createPromotion(string prmtRange, string prmtnType, string spndType){

Promotion__c prtmn  =  new Promotion__c(Promoted_Range_ID__c = prmtRange, Promotion_Type_ID__c = prmtnType, Spend_Type_Id__c =spndType);
return prtmn;


}*/
    
    
    
    //created salesOrderProduct
    public static Sales_Order_Product__c createsalesOrderProduct(string prmtmnPrdct){
        
        Sales_Order_Product__c sop  =  new Sales_Order_Product__c(PromotionProduct__c = prmtmnPrdct);
        return sop;
        
        
    }
    
    //created salesOrder
    public static Sales_Order__c createSalesOrder(string whlSaler, string otltName){
        
        Sales_Order__c slsOrder  =  new Sales_Order__c(Wholesaler__c = whlSaler, Outlet_Name__c = otltName);
        return slsOrder;
        
        
    } 
    
    //created state
    public static State__c createState(string region, string state){
        
        State__c stt  =  new State__c(Region_ID__c = region, State_ID__c = state);
        
        
        return stt; 
        
        
    }
    
    //created user
    public static user createUser(string regionId){
        
        User testUser = new User();
        testUser.Username= 'testUser1@company.com';
        testUser.Email = 'testuser1@company.com';
        testUser.Lastname = 'user';
        testUser.Firstname = 'test';
        testUser.Alias = 'test';
        testUser.CommunityNickname = '12346';
        testUser.UserRole = [ select id from userrole where name like 'Managing Director BU Asia Pacific'];
        SObject prof = [ select id from profile where name like  'Area Sales Manager - AUS' ];
        testUser.ProfileId = (ID) prof.get('ID');
        
        //testUser.CurrencyIsoCode = 'USD';
        testUser.TimeZoneSidKey = 'GMT';
        testUser.LocaleSidKey = 'en_US';
        testUser.EmailEncodingKey = 'ISO-8859-1';
        testUser.LanguageLocaleKey = 'en_US';
        testUser.RegionID__c =  regionId;
        
        return testUser;    
        
        
    }
    
    
    //created wholeSaler Banner Group
    public static Wholesaler_Banner_Group__c createWholeSalerBannerGroup(string Wholesaler, string Region, string bannerId){
        
        Wholesaler_Banner_Group__c wBanner  =  new Wholesaler_Banner_Group__c(Wholesaler_ID__c = Wholesaler, Region_ID__c = Region,
                                                                              Banner_Group_ID__c =bannerId, name ='9999999', 
                                                                              Wholesaler_Banner_Group_My_Sales_ID__c = 9999999);
        return wBanner;
        
        
    } 
    
    
    //created WholesalerBranchOutlet
    public static Wholesaler_Branch_Outlet__c createWholeSalerBranchOutlet(string outlet, string wBranch){
        
        Wholesaler_Branch_Outlet__c wbOutlet  =  new Wholesaler_Branch_Outlet__c(Outlet_ID__c = outlet, Wholesaler_Branch_ID__c = wBranch,Customer_Number__c ='556', Wholesaler_Branch_My_Sales_Id__c = '9999999');
        return wbOutlet;
        
        
    } 
    
    //created  WholesalerBranch
    public static Wholesaler_Branch__c createWholeSalerBranch(string wSaler){
        
        Wholesaler_Branch__c wBranch  =  new Wholesaler_Branch__c(Wholesaler_ID__c = wSaler,Wholesaler_Branch_Name__c ='Aus Branch',Wholesaler_Branch_ID__c ='1234');
        return wBranch;
        
        
    } 
    
    
    
    //created  WholeSalerGroupProduct 
    public static Wholesaler_Group_Product__c createWholeSalerGroupProduct (string prdctId){
        
        Wholesaler_Group_Product__c prdct  =  new Wholesaler_Group_Product__c(Product_ID__c = prdctId,Wholesaler_Group_ID__c ='123', Wholesaler_Product_Code__c ='123', Wholesale_Group_Product_My_Sales_ID__c = 123);
        return prdct;
        
    } 
    
    //created  WholeSalerGroupProduct 
    public static Wholesaler_Group_Product__c createWholeSalerGroupProductwithId (string prdctId, string groupid){
        
        Wholesaler_Group_Product__c prdct  =  new Wholesaler_Group_Product__c(Product_ID__c = prdctId,Wholesaler_Group_ID__c = groupid, Wholesaler_Product_Code__c = groupid, Wholesale_Group_Product_My_Sales_ID__c = integer.valueOf(groupid));
        return prdct;
        
    } 
    
    
    //created  Wholesaler 
    public static list<Wholesaler__c> createWholeSaler(){
        
        list<Wholesaler__c> wSalerList = new list<Wholesaler__c>();
        
        Wholesaler_Group__c wGroup = new Wholesaler_Group__c(Wholesaler_Group_ID__c = '123');
        insert wGroup;
        
        string wholeSalerGroupId = '123';
        Wholesaler__c wsaler1  =  new Wholesaler__c(Wholesaler_Group_ID__c = wholeSalerGroupId, Wholesaler_ID__c ='123');
        wSalerList.add(wsaler1);
        Wholesaler__c wsaler2  =  new Wholesaler__c(Wholesaler_Group_ID__c = '123', Wholesaler_ID__c ='12');
        wSalerList.add(wsaler2);
        return wSalerList;
        
        
    } 
    
    //create promotion product
    
    public static PromotionProduct__c createPromotionProduct(){
        Pricing__c pric = new Pricing__c(Start_Date__c =Date.today(), End_Date__c = Date.today().addDays(5),name ='RedWine');
        PromotionProduct__c prmprdct = new PromotionProduct__c();
        return prmprdct;
    }
    
    public static Email_Configuration__c createEmailonfiguration(){
        
        Email_Configuration__c newConfig = new Email_Configuration__c();
        newConfig.Name = 'NotificationEmails';
        newConfig.Email_Ids__c = 'test@test.com';
        return newConfig;
    }
    
        public static Email_Configuration__c createEmailonfiguration(string name){
        
        Email_Configuration__c newConfig = new Email_Configuration__c();
        newConfig.Name = name;
        newConfig.Email_Ids__c = 'test@test.com';
        return newConfig;
    }
    
}