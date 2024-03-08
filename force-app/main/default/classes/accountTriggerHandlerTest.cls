@isTest
public with sharing class accountTriggerHandlerTest {
 
   @testSetUp public static void createData() {
    	
        Profile pf= [Select Id from profile where Name='System Administrator']; 
        
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId; 
        User user1 =new User(firstname = 'ABC', 
                         lastName = 'XYZ', email = uniqueName + '@test' + orgId + '.org', Username = uniqueName + '@test5649D898' + orgId + '.org', 
                         EmailEncodingKey = 'ISO-8859-1', Alias = uniqueName.substring(18, 23), TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', ProfileId = pf.Id
                        );         
        insert user1;
     	User user2 =new User(firstname = 'CDE', 
                         lastName = 'WRT', email = uniqueName + '@test' + orgId + '.org', Username = uniqueName + '@test5649D' + orgId + '.org', 
                         EmailEncodingKey = 'ISO-8859-1', Alias = uniqueName.substring(18, 23), TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', ProfileId = pf.Id
                        );         
        insert user2;
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

        Brand__c brand = new Brand__c(Name= 'Brand Test', Brand_ID__c='10');
        insert brand;

        Product__c product = TestFactory.createProduct(brand.Brand_ID__c);
        product.Standard_Range__c =true;
        insert product;
        
    	
        Territory__c Territory = new Territory__c(Name = 'OriginalTerritory', ownerid = user1.id);
        insert Territory;
         
        Post_Code_Region__c PostCode1 = new Post_Code_Region__c(Name = '2000 - SYDNEY', Post_Code__c = '2000', Locality__c = 'SYDNEY', Territory__c = Territory.id);
        insert PostCode1;
                
        Outlet__c outlet = TestFactory.createOutlet(stt.State_ID__c, category.Outlet_Category_Id__c);
            outlet.Suburb__c= 'SYDNEY';
            outlet.Post_Code__c= '2000';
            outlet.name = '1234446';
            outlet.Outlet_Name__c = 'Test Outlet';
            outlet.ASM_User_ID__c = '18000098';
            outlet.Outlet_My_Sales_Id__c = 1234446; 
           // outlet.Outlet_My_Sales_Id__c = 1234446 + integer.valueOf(stt.State_ID__c);
        insert outlet;
    }

    static testMethod void insertAccountTest(){
        Post_Code_Region__c pcRec = [SELECT id FROM Post_Code_Region__c WHERE name='2000 - SYDNEY' LIMIT 1 ];
        Outlet__c rec= [SELECT id, name FROM Outlet__c WHERE name='1234446' LIMIT 1]; 
        Account accList= [SELECT id, Outlet_ID__c ,name FROM account where Outlet__c =: rec.id]; 

        test.startTest(); 
            Account acc = new Account(  
            Name = 'New Account',
            RecordTypeId =  Utilities.getRecordTypeId('account', 'Outlet'),
            Post_Code_Region__c = pcRec.id,
            Outlet_ID__c ='12346',
            BillingPostalCode = '2000',
            BillingCity = 'SYDNEY',
            Called_On__c = true,
            ParentId = accList.id);
            insert acc;
            acc.Called_On__c=false;
            update acc;
        test.stopTest(); 
    }
   
    static testMethod void updateRelatedOutletTest(){
        Outlet__c rec= [SELECT id, name FROM Outlet__c WHERE name='1234446' LIMIT 1]; 
        Account acc= [SELECT id, Outlet_ID__c ,name FROM account where Outlet__c =: rec.id]; 
        User user= [SELECT id FROM user WHERE firstname='CDE'];
        test.startTest(); 
        acc.OwnerId = user.id;
        acc.BillingPostalCode = '3000';
        acc.BillingCity = 'MELBOURNE';
        acc.Called_On__c = true;
        acc.Volume__c = 10;
        update acc;
        test.stopTest(); 
    }
    

}