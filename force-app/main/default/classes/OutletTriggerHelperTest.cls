@isTest
public with sharing class OutletTriggerHelperTest {
  
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
        
    	
        Territory__c Territory = new Territory__c(Name = 'OriginalTerritory', ownerid = user1.id);
        insert Territory;
         
        Post_Code_Region__c PostCode1 = new Post_Code_Region__c(Name = '2000 - SYDNEY', Post_Code__c = '2000', Locality__c = 'SYDNEY', Territory__c = Territory.id);
        insert PostCode1;
                
        Outlet__c outlet = TestFactory.createOutlet(stt.State_ID__c, category.Outlet_Category_Id__c);
            outlet.Suburb__c= 'SYDNEY';
            outlet.Post_Code__c= '2000';
            outlet.Outlet_Name__c = 'Test Outlet';
            outlet.name = '123444';
            //outlet.State_ID__c = stt.State_ID__c;
            //outlet.Outlet_Category_Id__c = category.Outlet_Category_Id__c;
            outlet.Outlet_My_Sales_Id__c = 123444;
            //outlet.Outlet_My_Sales_Id__c = 1234446 + integer.valueOf(stt.State_ID__c);
        insert outlet;

        Outlet__c outlet2 = TestFactory.createOutlet(stt.State_ID__c, category.Outlet_Category_Id__c);
        outlet2.Suburb__c= 'SYDNEY';
        outlet2.Post_Code__c= '2000';
        outlet2.Outlet_Name__c = 'New test';
        outlet2.name = '123456';
        outlet2.Outlet_My_Sales_Id__c = 123456;
        insert outlet2;
    }
  
    static testMethod void updateRelatedAccountTest(){
        Outlet__c rec= [SELECT id, name, Outlet_Name__c  FROM Outlet__c WHERE name='123444' LIMIT 1]; 
        test.startTest(); 
        rec.Outlet_Name__c = 'New Account Test';
        update rec;
        test.stopTest(); 
    }
    
    /*static testMethod void createRelatedAccountTest(){
        Outlet__c rec2= [SELECT id, name, Outlet_Name__c FROM Outlet__c WHERE name='123456' LIMIT 1]; 
        Account acc= [SELECT id, name FROM account where Outlet__c =: rec2.id]; 
        //system.debug(acc);
       // acc.Outlet_ID__c = '1234567';
        test.startTest(); 
        rec2.Outlet_Name__c = 'New Outlet Test';
        update rec2;
        test.stopTest(); 

        Outlet__c outlet = [SELECT id, name, Outlet_Name__c FROM Outlet__c WHERE name='123456' LIMIT 1]; 

        System.assertEquals(rec2.Outlet_Name__c.toUpperCase(), outlet.Outlet_Name__c);
    }*/
    
}