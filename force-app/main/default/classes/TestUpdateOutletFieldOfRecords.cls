@isTest
public class TestUpdateOutletFieldOfRecords {
    
    static testmethod void test() {
        // The query used by the batch job.
        String query = 'SELECT Id, DeletedBy__c, MigratedToOutletId__c, Name, Outlet_My_Sales_Id__c FROM Outlet__c'+
            +' WHERE DeletedBy__c != null'
            +' AND  MigratedToOutletId__c != null';
        
        // Create a Config Email configuration
        insert TestFactory.createEmailonfiguration();
        
        prepareTestData();	
        
        Test.startTest();
        UpdateOutletFieldOfRecords c = new UpdateOutletFieldOfRecords(query); 
        Database.executeBatch(c, 1);
        Test.stopTest();
        
        Integer i = [SELECT COUNT() FROM Outlet__c];       	
        System.assertEquals(i, 1);
        
        Id recTypeId = Schema.SObjectType.account.getRecordTypeInfosByName().get('Outlet').getRecordTypeId();
        Integer i1 = [SELECT COUNT() FROM Account WHERE RecordTypeId = :recTypeId];	
        System.assertEquals(i1, 2);	
    }
    
    static testmethod void test2() {
        // The query used by the batch job.
        String query = 'SELECT Id, DeletedBy__c, MigratedToOutletId__c, Name, Outlet_My_Sales_Id__c FROM Outlet__c'+
            +' WHERE DeletedBy__c != null'
            +' AND  MigratedToOutletId__c != null';
        
        // Create a Config Email configuration
        insert TestFactory.createEmailonfiguration();
        
        prepareTestData2();	
        
        Test.startTest();
        UpdateOutletFieldOfRecords c = new UpdateOutletFieldOfRecords(query); 
        Database.executeBatch(c, 1);
        Test.stopTest();
        
        Integer i = [SELECT COUNT() FROM Outlet__c];       	
        System.assertEquals(i, 1);
        
        Id recTypeId = Schema.SObjectType.account.getRecordTypeInfosByName().get('Outlet').getRecordTypeId();
        Integer i1 = [SELECT COUNT() FROM Account WHERE RecordTypeId = :recTypeId];	
        System.assertEquals(i1, 2);	
    }
    
    static testmethod void test3() {
        // The query used by the batch job.
        String query = 'SELECT Id, DeletedBy__c, MigratedToOutletId__c, Name, Outlet_My_Sales_Id__c FROM Outlet__c'+
            +' WHERE DeletedBy__c != null'
            +' AND  MigratedToOutletId__c != null';
        
        // Create a Config Email configuration
        insert TestFactory.createEmailonfiguration();
        
        prepareTestData3();	
        
        Test.startTest();
        UpdateOutletFieldOfRecords c = new UpdateOutletFieldOfRecords(query); 
        Database.executeBatch(c, 1);
        Test.stopTest();
        
        Integer i = [SELECT COUNT() FROM Outlet__c];       	
        System.assertEquals(i, 1);
        
        Id recTypeId = Schema.SObjectType.account.getRecordTypeInfosByName().get('Outlet').getRecordTypeId();
        Integer i1 = [SELECT COUNT() FROM Account WHERE RecordTypeId = :recTypeId];	
        System.assertEquals(i1, 2);	
    }
    
    /**
* @ Method to create 2 outlets with related lists to be merged
*   
*/
    static void prepareTestData() {    	
        
        
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
        
        /*
* insert outlet with
* outlet id = 1234447
*/  
        
        List<Outlet__c> outletList = new List<Outlet__c>();
        Outlet__c outlet1 = TestFactory.createOutlet(stt.State_ID__c, category.Outlet_Category_Id__c);
        outlet1.Outlet_Name__c = 'AUSACCOUNT2';
        outlet1.name = '1234447';
        outlet1.Outlet_My_Sales_Id__c = 1234447;
        outletList.add(outlet1);
        
        /*
* insert outlet with
* outlet id = 1234446
* MigratedToOutletId__c = 1234447
* this outlet will be deleted
*/
        Outlet__c outlet2 = TestFactory.createOutlet(stt.State_ID__c, category.Outlet_Category_Id__c);
        outlet2.DeletedBy__c = 'dbo';
        outlet2.MigratedToOutletId__c = '1234447';        
        outlet2.Outlet_Name__c = 'AUSACCOUNT1';
        outlet2.Outlet_My_Sales_Id__c = 1234446;
        outlet2.name = '1234446';
        outletList.add(outlet2);
        
        insert outletList;
        
        // Covers OutletTriggerHelper
        outlet1.licence_class__c = 'ON/R1';
        update outlet1;
        
        
        Id recTypeId = Utilities.getRecordTypeId('account', 'Outlet');
        Account OutletAcc = [SELECT id, name, Outlet_ID__c FROM Account WHERE Outlet_ID__c = '1234446' AND RecordTypeId = :recTypeId];
        
        Account wholesaler = createWholesaler();
        insert wholesaler; 
        
        /**
* insert promotion for promotion outlet
*/
        Promotion__c promo = TestFactory.createPromotion('11');
        insert promo;
        
        /**
* insert parent banner group and product for my sales 
*/
        Account parentBanner = getBanerGroup();
        insert parentBanner;
        
        Sales_Order__c salesOrder = createSalesOrder(wholesaler, OutletAcc);
        insert salesOrder;
        
        //Attachment attachment = addAttachmentToParent(OutletAcc.id);
        //insert attachment;
        
        //Note testNote = addNoteToParent(OutletAcc.id);
        //insert testNote;
        
        Contact con = addContactToParent(OutletAcc.id);
        insert con;			
        
        Task testTask = addActivityToParent(OutletAcc.id);
        insert testTask;
        
        
    }
    
    static void prepareTestData2() {    	
        
        
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
        
        /*
* insert outlet with
* outlet id = 1234447
*/  
        
        List<Outlet__c> outletList = new List<Outlet__c>();
        Outlet__c outlet1 = TestFactory.createOutlet(stt.State_ID__c, category.Outlet_Category_Id__c);
        outlet1.Outlet_Name__c = 'AUSACCOUNT2';
        outlet1.name = '1234447';
        outlet1.Outlet_My_Sales_Id__c = 1234447;
        outletList.add(outlet1);
        
        /*
* insert outlet with
* outlet id = 1234446
* MigratedToOutletId__c = 1234447
* this outlet will be deleted
*/
        Outlet__c outlet2 = TestFactory.createOutlet(stt.State_ID__c, category.Outlet_Category_Id__c);
        outlet2.DeletedBy__c = 'dbo';
        outlet2.MigratedToOutletId__c = '1234447';        
        outlet2.Outlet_Name__c = 'AUSACCOUNT1';
        outlet2.Outlet_My_Sales_Id__c = 1234446;
        outlet2.name = '1234446';
        outletList.add(outlet2);
        
        insert outletList;
        
        // Covers OutletTriggerHelper
        outlet1.licence_class__c = 'ON/R1';
        update outlet1;
        
        
        Id recTypeId = Utilities.getRecordTypeId('account', 'Outlet');
        Account OutletAcc = [SELECT id, name, Outlet_ID__c FROM Account WHERE Outlet_ID__c = '1234446' AND RecordTypeId = :recTypeId];
        
        
        /**
* insert promotion for promotion outlet
*/
        Promotion__c promo = TestFactory.createPromotion('11');
        insert promo;
        
        /**
* insert parent banner group and product for my sales 
*/
        Account parentBanner = getBanerGroup();
        insert parentBanner;
        
        
        Promotion_Outlet__c prmOut = addPromotionOutlet(OutletAcc, promo);
        insert prmOut;
        //
        //Banner_Group_Outlet__c bannerGroupOutlet1 = addBannerGroupOutlet(OutletAcc, parentBanner);
        //bannerGroupOutlet1.banner_group_outlet_id_my__c = 12;
        //insert bannerGroupOutlet1;
    }
    
    static void prepareTestData3() {    	
        
        
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
        
        /*
* insert outlet with
* outlet id = 1234447
*/  
        
        List<Outlet__c> outletList = new List<Outlet__c>();
        Outlet__c outlet1 = TestFactory.createOutlet(stt.State_ID__c, category.Outlet_Category_Id__c);
        outlet1.Outlet_Name__c = 'AUSACCOUNT2';
        outlet1.name = '1234447';
        outlet1.Outlet_My_Sales_Id__c = 1234447;
        outletList.add(outlet1);
        
        /*
* insert outlet with
* outlet id = 1234446
* MigratedToOutletId__c = 1234447
* this outlet will be deleted
*/
        Outlet__c outlet2 = TestFactory.createOutlet(stt.State_ID__c, category.Outlet_Category_Id__c);
        outlet2.DeletedBy__c = 'dbo';
        outlet2.MigratedToOutletId__c = '1234447';        
        outlet2.Outlet_Name__c = 'AUSACCOUNT1';
        outlet2.Outlet_My_Sales_Id__c = 1234446;
        outlet2.name = '1234446';
        outletList.add(outlet2);
        
        insert outletList;
        
        // Covers OutletTriggerHelper
        outlet1.licence_class__c = 'ON/R1';
        update outlet1;
        
        
        Id recTypeId = Utilities.getRecordTypeId('account', 'Outlet');
        Account OutletAcc = [SELECT id, name, Outlet_ID__c FROM Account WHERE Outlet_ID__c = '1234446' AND RecordTypeId = :recTypeId];
        
        
        /**
* insert parent banner group and product for my sales 
*/
        Account parentBanner = getBanerGroup();
        insert parentBanner;
        
        Product__c product1 = getProduct();
        insert product1;
        
        List<Sale_MySales__c> mySalesList = getSalesMySales(parentBanner, OutletAcc, product1);
        insert mySalesList;
        
        Banner_Group_Outlet__c bannerGroupOutlet = addBannerGroupOutlet(OutletAcc, parentBanner);
        insert bannerGroupOutlet;
        
    }
    
    /** 
* @ Helper Methods for prepareTestData()
* 
*/
    
    public static Account createWholesaler() {
        Account wholesaler = new Account();        
        wholesaler = TestFactory.getAccount('ALM', Utilities.getRecordTypeId('Account','Wholesaler'));        
        wholesaler.Customer_Number__c = '111123';        
        wholesaler.Wholesaler_ID__c = '3'; 
        return wholesaler;
    }
    
    public static Sales_Order__c createSalesOrder(Account wholesaler, Account outlet2) {
        Id salesOrderRecordType= Schema.SObjectType.Sales_Order__c.getRecordTypeInfosByName().get('Trade Loader Sales Order Drop 1').getRecordTypeId();
        Sales_Order__c salesOrder1 = TestFactory.createSalesOrder(wholesaler.id, outlet2.Id);        
        salesOrder1.Status__c = 'New Sales Order Created';       
        salesOrder1.RecordTypeId = salesOrderRecordType;        
        salesOrder1.Drop_1_Date__c = system.today()-2;        
        salesOrder1.Wholesaler_Account_Number__c = '12345678';        
        return salesOrder1;    	
    }
    
    public static list <Sale_MySales__c> getSalesMySales(Account parentBanner, Account outletAccount, Product__c product1) {
        integer currentYear =  date.today().year();
        list<Sale_MySales__c> mySalesList = new list<Sale_MySales__c>();       
        mySalesList.add(TestFactory.getSalesMySaleswithID(10.4, parentBanner.Id, outletAccount.Outlet_ID__c, product1.Product_ID__c, date.newInstance(currentYear,1,1),'12'));
        return mySalesList;
    }
    
    public static Account getBanerGroup() {
        Id bannerId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Banner Group').getRecordTypeId();
        Account parentBanner = TestFactory.getAccount('IBA', bannerId);        
        parentBanner.My_Sales_Id__c = '11112';
        parentBanner.Banner_Group_ID__c = '11112';
        return parentBanner;    	
    }
    
    public static Product__c getProduct() {
        Brand__c brand = TestFactory.getBrand('Brand 15', 'Brand 5sap');
        insert brand;
        
        Product__c product1 = TestFactory.getProduct('Product1','Brand 15','Pid1123','Glass','Glen Grant Glass');
        product1.PromotedRangeID__c = '11';
        return product1;    	
    }
    
    private static Attachment addAttachmentToParent(Id parentId) {
        Blob b = Blob.valueOf('Test Data');
        
        Attachment attachment = new Attachment();
        attachment.ParentId = parentId;
        attachment.Name = 'Test Attachment for Parent';
        attachment.Body = b;    	
        return attachment;
    }
    
    private static Note addNoteToParent(Id parentId) {
        Note testNote = new Note();
        testNote.parentid = parentId;
        testNote.body = 'This is a test note';
        testNote.title = 'Test note';
        return testNote;
    }
    
    private static Contact addContactToParent(Id parentId) {
        Contact con = new Contact();
        con.lastname = 'Smith';
        con.firstname = 'David';
        con.accountid = parentId;
        return con;
    }
    
    private static Task addActivityToParent(Id parentId) {
        Task t = new Task();
        t.subject = 'Test task';
        t.activitydate = System.today();
        t.whatid = parentId;
        t.Status = 'Not Started';
        t.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Standard Task').getRecordTypeId();
        return t;
    }
    
    private static Banner_Group_Outlet__c addBannerGroupOutlet(Account outlet, Account bannerGroupId) {
        Banner_Group_Outlet__c  bgo  =  new Banner_Group_Outlet__c ();
        bgo.banner_group_id__c = bannerGroupId.my_sales_id__c;
        bgo.banner_group_outlet_id_my__c = 11;
        bgo.banner_group_account__c = bannerGroupId.id;
        bgo.outlet_account__c = outlet.id;
        bgo.outlet_id__c = outlet.outlet_id__c;
        return bgo;
    }
    
    private static Promotion_Outlet__c addPromotionOutlet(Account outlet, Promotion__c promo) {
        Promotion_Outlet__c  prm  =  new Promotion_Outlet__c ();
        prm.Name = 'prm outlet 1';
        prm.Promotion_ID__c = promo.name;
        prm.outlet_account__c = outlet.id;
        prm.outlet_id__c = outlet.outlet_id__c;
        prm.Promotion__c = promo.id;
        prm.PromotionOutlet_MySales_Id__c = 123123123;
        return prm;
    }    
}