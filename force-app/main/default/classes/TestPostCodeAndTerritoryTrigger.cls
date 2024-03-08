@isTest
public class TestPostCodeAndTerritoryTrigger {

 	@testSetUp public static void testStageValidation() {
    	
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
    	
        Territory__c Territory = new Territory__c(Name = 'OriginalTerritory', ownerid = user1.id);
            insert Territory;
         
        Territory__c Territory2 = new Territory__c(Name = 'NewTerritory', ownerid = user2.id);
            insert Territory2;
         
        Post_Code_Region__c PostCode1 = new Post_Code_Region__c(Name = '2097 - Collaroy', Post_Code__c = '2097', Locality__c = 'Collaroy', Territory__c = Territory.id);
            insert PostCode1;
                
        Post_Code_Region__c PostCode2 = new Post_Code_Region__c(Name = '2095 - Manly', Post_Code__c = '2095', Locality__c = 'Manly', Territory__c = Territory.id)  ;
            insert PostCode2;
            
     	Account Acc = new Account(  
            Name = 'New Account',
            RecordTypeId =  Utilities.getRecordTypeId('account', 'Outlet'),
            Post_Code_Region__c = PostCode1.id,
            Outlet_ID__c ='12346',
            ShippingCountry = 'AUSTRALIA');
            insert Acc ;
    
    }
    
   
    private static testMethod void UpdateAccountPostCodeTest() {
     	
        Account acc = [Select id, name from account limit 1];
        
        Post_Code_Region__c PostCode2 = [Select id, Name, Post_Code__c, Territory__c from Post_Code_Region__c Where Name = '2095 - Manly' limit 1];
        
     	Test.startTest();
            acc.Post_Code_Region__c = PostCode2.id;
     		Update Acc;     	
     	Test.stopTest();
 }
   
     private static testMethod void UpdateTerritoryOwner() {
			
        Territory__c Territory = [Select id, name from Territory__c where Name = 'OriginalTerritory' limit 1];
      	User newOwner = [Select id from User where firstname = 'CDE' limit 1];         
         
     	Test.startTest();
                	         
            Territory.ownerid = newOwner.id;
            update Territory;
           
    	Test.stopTest();
 }
    
    
    private static testMethod void UpdatePostCodeTerritory() {
		
         Post_Code_Region__c PostCode = [Select id, Name, Post_Code__c, Territory__c from Post_Code_Region__c Where Name = '2097 - Collaroy' limit 1];
       	 Territory__c NewTerritory = [Select id, name from Territory__c where Name = 'NewTerritory' limit 1];
        
        
        Test.startTest();
           
        	PostCode.Territory__c = NewTerritory.id;
        	update PostCode;
           
        Test.stopTest();
 }
    
    
}