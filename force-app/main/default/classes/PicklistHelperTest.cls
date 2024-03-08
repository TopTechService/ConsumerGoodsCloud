/**
 * @author    : Created by Geeta Kushwaha on 3 June, 2013  geeta.kushwaha@arxxus.com
 * @Purpose   : Test Class
 * @Criteria  : This is test class for UserTrigger
 * @Modified  : Modified by Geeta Kushwaha on 4 June, 2013  geeta.kushwaha@arxxus.com
 */
@isTest
public class PicklistHelperTest {
	
	static testMethod void getNumberOfOutletsTest(){
    
        PicklistHelper helper = new PicklistHelper();
        
        System.assertEquals(helper.getNumberOfOutlets().size(), 4 );
        
    } 

    static testMethod void getYearsTest() {
        
        PicklistHelper helper = new PicklistHelper();
        
        System.assertEquals(helper.getYears().size(), date.today().year() + 1 - 2020 );
       
    }
    
    static testMethod void getBannerGroupsTest(){
        
        Id bannerGrpId = Utilities.getRecordTypeId('Account', 'Banner Group');

        Account bannergrp1 = TestFactory.getAccount('Banner Grp 1', bannerGrpId);
        
        bannergrp1.My_Sales_Id__c = '1';
        
        insert bannergrp1;
        
        Account bannergrp2 = TestFactory.getAccount('Banner Grp 2', bannerGrpId);
        
        bannergrp2.My_Sales_Id__c = '2';
        
        insert bannergrp2;
        
        PicklistHelper helper = new PicklistHelper();
        
        System.assertEquals(3, helper.getBannerGroups().size());
        
    }
    
    static testMethod void getGradingsTest(){
        
        PicklistHelper helper = new PicklistHelper();
        
        System.assertEquals(helper.getGradings().size(), 5);
        
    }
    
    static testMethod void getCallCycleAustraliaTest(){
        
        Call_Cycle__c cc1 = TestFactory.createCallCycle('Call Cycle 1',date.newInstance(2013,1,28), date.newInstance(2013, 3, 15), 'Australia', null, '2013');
        
        insert cc1;
        
        Call_Cycle__c cc2 = TestFactory.createCallCycle('Call Cycle 2',date.newInstance(2013,3,18), date.newInstance(2013, 5, 3), 'Australia', null, '2013');
        
        insert cc2;
        
        Call_Cycle__c cc3 = TestFactory.createCallCycle('Call Cycle 3',date.newInstance(2013,5,6), date.newInstance(2013, 6, 21), 'Australia', null, '2013');
        
        insert cc3;
        
        PicklistHelper helper = new PicklistHelper();
        
        System.assertEquals(3,helper.getCallCycleAustralia('Australia', '2013',  date.newInstance(2013,1,31)).size());
        
        system.assertEquals(helper.getcurrentCallCycle().Id, cc1.Id);
        
        System.assertEquals(3,helper.getCallCycleAustralia('Australia', '2013',  date.newInstance(2013,3,16)).size());
        
        //system.assertEquals(helper.getcurrentCallCycle().Id, cc2.Id); // this needs to be uncomment on 11 jan 2016
         
    }
    
    static testMethod void getOutletsTest(){
    
        Profile p = [select id from profile where name='Standard User'];
                                     
        UserRole userRoles = [select Id 
                              from UserRole where Name=: 'Managing Director BU Asia Pacific'];

        UserRole ur1 = TestFactory.getUserRole('test role1', userRoles.Id);
        
        insert ur1;
        
        UserRole ur2 = TestFactory.getUserRole('test role2', ur1.Id);
        
        insert ur2;
        
        UserRole ur3 = TestFactory.getUserRole('test role3', ur2.Id);
        
        insert ur3;
        
        User user1 = TestFactory.getUser('1standarduser1@testorg.com', 'Testing1', '1standt1', 'standarduser1@testorg.com', p.Id, ur1.Id );
               
        insert user1;
        
        User user2 = TestFactory.getUser('2standarduser2@testorg.com', 'Testing2', '2standt2', 'standarduser2@testorg.com', p.Id, ur2.Id );
               
        insert user2;
        
        User user3 = TestFactory.getUser('3standarduser3@testorg.com', 'Testing3', '3standt3', 'standarduser3@testorg.com', p.Id, ur3.Id );
               
        insert user3;
        
        PicklistHelper helper = new PicklistHelper();
        
        test.startTest();
        
        System.assertEquals(helper.getOutlets(user1.Id, user1.UserRoleId).size(), 0);  
        
        System.assertEquals(helper.getOutlets(user2.Id, user2.UserRoleId).size(), 0);
        
        System.assertEquals(helper.getOutlets(user3.Id, user3.UserRoleId).size(), 0);
        
        test.stopTest();
        
    }
    
    static testMethod void getObjectivesTest(){
        
        
        Call_Cycle__c cc1 = TestFactory.createCallCycle('Call Cycle 1',date.newInstance(2013,1,28), date.newInstance(2013, 3, 15), 'Australia', null, '2013');
        
        insert cc1;
        
        Call_Cycle__c cc2 = TestFactory.createCallCycle('Call Cycle 2',date.newInstance(2013,3,18), date.newInstance(2013, 5, 3), 'Australia', null, '2013');
        
        insert cc2;
        
        Objective__c obj1 = TestFactory.getObjective('Objective 1', cc1.Id, 'National Objective', null, null, '1');
        
        obj1.Priority_KPI__c = '1';
        
        obj1.Channel__c = 'All';
        
        insert obj1;
        
        Objective__c obj2 = TestFactory.getObjective('Objective 2', cc1.Id, 'National Objective', null, null,'2');
        
        obj1.Priority_KPI__c = '1';
        
        obj2.Channel__c = 'All';
        insert obj2;
        
        
        Objective__c obj3 = TestFactory.getObjective('Objective 3', cc1.Id, 'State Objective', 'NSW', null,'5');
        
        obj1.Priority_KPI__c = '1';
        
        obj3.Channel__c = 'All';
        insert obj3;
        
        Objective__c obj4 = TestFactory.getObjective('Objective 4', cc2.Id, 'State Objective', 'NSW', null,'5');
        
        obj1.Priority_KPI__c = '1';
        
        obj4.Channel__c = 'All';
        insert obj4;
        
        
        PicklistHelper helper = new PicklistHelper();
        
        test.startTest();
        
        System.assertEquals(helper.getObjectives('2013', 'Call Cycle 1', null, '1').size(), 2 );
        
        System.assertEquals(helper.getCurrentObjectivesMap().size(),1);
        
        System.assertEquals(helper.getCurrentObjectivesIdList().size(),1);
        
        System.assertEquals(helper.getObjectives('2013', 'Call Cycle 1', 'NSW','1').size(), 2);
        
        System.assertEquals(helper.getCurrentObjectivesMap().size(),1);
        
        System.assertEquals(helper.getCurrentObjectivesIdList().size(),1);
        
        
        //checking objective mngmt controller variables
        // YB - 20190103 - reduced values by 1 in this space, following complete removal of call cycle references.
        System.assertEquals(helper.getObjectivesForObjectMangmt('2013', null, '1','All').size(), 1 );
        
        System.assertEquals(helper.getCurrentObjectivesMap().size(),0);
        
        System.assertEquals(helper.getCurrentObjectivesIdList().size(),0);
        
        System.assertEquals(helper.getObjectivesForObjectMangmt('2013', 'NSW','1','All').size(), 1);
        
        System.assertEquals(helper.getCurrentObjectivesMap().size(),0);
        
        System.assertEquals(helper.getCurrentObjectivesIdList().size(),0);
        
        
        helper.getPriorityKPI();
        helper.geteventStatusCallVisit();
        helper.getAccountChannel();
        
        helper.getObjectiveSettingChannel();
        helper.getTaskStatusObjective();
        helper.getTaskStatusCallVisit();
        
        test.stopTest();
        
    }
    static testMethod void getTaskStatusValuesTest(){
        PicklistHelper helper = new PicklistHelper();
        List<String> taskStatusValues= new List<String>();
       List<String> statusList= helper.getTaskStatusValues();
        Schema.DescribeFieldResult fieldResult = Task.Status.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
			taskStatusValues.add(pickListVal.getLabel());
		} 
        System.assertEquals(statusList, taskStatusValues);
    }
    
}