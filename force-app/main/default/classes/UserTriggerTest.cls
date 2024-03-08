/**
 * @author    : Created by Geeta Kushwaha on 3 June, 2013  geeta.kushwaha@arxxus.com
 * @Purpose   : Test Class
 * @Criteria  : This is test class for UserTrigger
 * @Modified  : Modified by Geeta Kushwaha on 3 June, 2013  geeta.kushwaha@arxxus.com
 */
@isTest
public class UserTriggerTest {

    static testMethod void myUnitTest() {
    	
    	Profile p = [select id from profile where name='Standard User'];
    	
    	Region__c region = TestFactory.getRegion('NSW', '1');
    	
    	insert region;
    	
    	State__c s1 = TestFactory.getState(region.Region_ID__c);
    	
    	insert s1;
        
        User user1 = TestFactory.getUser('campZ1standarduser1@testorg.com', 'Testing1', '1standt1', 'campZstandarduser1@testorg.com', p.Id, null );
        
        test.startTest();
               
        insert user1;
        
        User u1 = [Select id, Last_Modified_Date__c, LastModifiedBy__c
                  from User
                  where Id =: user1.Id];
                  
        System.assertNotEquals(u1.Last_Modified_Date__c, null) ;
        
        System.assertNotEquals(u1.LastModifiedBy__c, null) ; 
        
        User user2;       
        
        System.runAs(user1) {
            
	
        	user2 = TestFactory.getUser('campZ2standarduser2@testorg.com', 'Testing2', '2standt2', 'campZstandarduser2@testorg.com', p.Id, null );
               
            insert user2;
            
            User u2 = [Select id, Last_Modified_Date__c, LastModifiedBy__c, CreatedBy__c
                  from User
                  where Id =: user2.Id];
	                  
	        System.assertNotEquals(u2.Last_Modified_Date__c, null);
	        
	        System.assertEquals(u2.LastModifiedBy__c, UserInfo.getFirstName()+' '+UserInfo.getLastName());
	        
	        System.assertEquals(u2.CreatedBy__c, UserInfo.getFirstName()+' '+UserInfo.getLastName());
        	
        }   
        
        System.runAs(user2) {
        	
        	user2.RegionID__c = region.Region_ID__c;
            
            update user2;
            
            User u21 =  [Select id, Last_Modified_Date__c, LastModifiedBy__c, State__c, CreatedBy__c
                         from User
                         where Id =: user2.Id];
                         
            System.assertNotEquals(u21.Last_Modified_Date__c, null);
            
            System.assertEquals(u21.LastModifiedBy__c, UserInfo.getFirstName()+' '+UserInfo.getLastName());
            
            System.assertEquals(u21.State__c, region.Region_Abbr__c);  
        	
        }
        
        test.stopTest();
        
    }
    
}