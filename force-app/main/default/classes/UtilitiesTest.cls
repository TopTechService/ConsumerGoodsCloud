/**
 * @author    : Created by Geeta Kushwaha on 8 Apr, 2013  geeta.kushwaha@arxxus.com
 * @Purpose   : Test class for class: Utilities 
 * @Criteria  : 
 * @Modified  : Last modified by Geeta Kushwaha on 22 May, 2013
 */
@isTest
public class UtilitiesTest {

    static testMethod void getRecordTypeIdTest() {
    	
    	String sobjectName = 'Account';
    	
    	String recTypeName = 'Outlet';
    	        
        System.assertEquals([Select Id 
                             From RecordType 
                             Where SobjectType =: sobjectName and Name =:recTypeName].Id , Utilities.getRecordTypeId(sobjectName, recTypeName) );
    
    }
    
    static testMethod void getSalesforceIdPrefixTest(){
    	
    	System.assertEquals(Utilities.getSalesforceIdPrefix('Account'),'001');
    	
    	System.assertEquals(Utilities.getSalesforceIdPrefix('Object'),null);
    	
    }
    
    static testMethod void getRoleSubordinateUsersTest(){
    	
    	Profile p = [select id from profile where name='Standard User'];
                                     
    	UserRole userRoles = [select Id 
                              from UserRole where Name=: 'Managing Director BU Asia Pacific'];

		UserRole ur1 = TestFactory.getUserRole('test role1', userRoles.Id);
		
		insert ur1;
		
		UserRole ur2 = TestFactory.getUserRole('test role2', ur1.Id);
        
        insert ur2;
        
        UserRole ur3 = TestFactory.getUserRole('test role3', ur2.Id);
        
        insert ur3;
        
        test.startTest();
                
    	User user1 = TestFactory.getUser('camp1standarduser1@testorg.com', 'Testing1', '1standt1', 'campstandarduser1@testorg.com', p.Id, ur1.Id );
               
    	insert user1;
    	
    	User user2 = TestFactory.getUser('camp2standarduser2@testorg.com', 'Testing2', '2standt2', 'campstandarduser2@testorg.com', p.Id, ur2.Id );
               
        insert user2;
        
        User user3 = TestFactory.getUser('camp3standarduser3@testorg.com', 'Testing3', '3standt3', 'campstandarduser3@testorg.com', p.Id, ur3.Id );
               
        insert user3;
        
        list <User> usersList = Utilities.getRoleSubordinateUsers(ur2.Id);
        
        System.assertEquals(usersList.size(),2);
        
        test.stopTest();
        
    }
    
    static testMethod void getUsersTest(){
    	
    	Profile p = [select id 
    	             from profile 
    	             where name='Standard User'];
    	             
    	test.startTest();             
    	
    	User user1 = TestFactory.getUser('campZ1standarduser1@testorg.com', 'Testing1', '1standt1', 'campstandarduser1@testorg.com', p.Id, null );
               
        insert user1;
        
        User user2 = TestFactory.getUser('campZ2standarduser2@testorg.com', 'Testing2', '2standt2', 'campstandarduser2@testorg.com', p.Id, null);
               
        insert user2;
        
        User user3 = TestFactory.getUser('campZ3standarduser3@testorg.com', 'Testing3', '3standt3', 'campstandarduser3@testorg.com', p.Id, null );
               
        insert user3;
        
        Map<Id, User> usersMap = Utilities.getUsers(new set<Id>{user1.Id, user2.Id, user3.Id});
        
        System.assertEquals(usersMap.containsKey(user1.Id), true);
        
        System.assertEquals(usersMap.containsKey(user2.Id), true);
        
        System.assertEquals(usersMap.containsKey(user3.Id), true);
        
        Map<Id, User> usersMap1 = Utilities.getUsers(new set<Id>{null});
        
        System.assertEquals(usersMap1.size(), 0);
    	
    	test.stopTest();
    	
    }
    
}