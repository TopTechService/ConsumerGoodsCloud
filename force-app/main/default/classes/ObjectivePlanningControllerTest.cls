/**
 * @author    : Created by Geeta Kushwaha on 4 June, 2013  geeta.kushwaha@arxxus.com
 * @Purpose   : Test Class
 * @Criteria  : This is test class for ObjectivePlanningController
 * @Modified  : Modified by Geeta Kushwaha on 6 June, 2013  geeta.kushwaha@arxxus.com
 */
@isTest
public class ObjectivePlanningControllerTest{
    
    static testMethod void incorrectCountry(){
            
        User user1 = TestFactory.getUser('1standarduser1@testorg.com', 'Testing1', '1standt1', 'standarduser1@testorg.com', [select id from profile where name='Standard User'].Id, null );
        
        insert user1;
        
        test.startTest();
        
        System.runAs(user1){
      
         PageReference pageRef = Page.Objective_Planning;
        
           Test.setCurrentPage(pageRef);
         
           ObjectivePlanningController op = new ObjectivePlanningController();
            
           System.assert(ApexPages.getMessages().size() == 1); 
           
           System.assert(ApexPages.getMessages().get(0).getDetail()== 'User Location not found. This page is available to users from Australia only.'); 
           
           System.assert(ApexPages.getMessages().get(0).getSeverity()== ApexPages.Severity.ERROR);  
        
        }
        
        test.stopTest();
        
    }
    
    static testMethod void testHome(){
    	
    	ObjectivePlanningController cv = new ObjectivePlanningController();
    	
    	PageReference ref = cv.home();
    	
    	System.assert(ref.getUrl() == '/home/home.jsp');
    	
    }
    
    static testMethod void ausSendMailToManagerTest(){
        
        Profile p = [select id from profile where name='Standard User'];
        
        User user1 = TestFactory.getUser('1standarduser1@testorg.com', 'Testing1', '1standt1', 'standarduser1@testorg.com', p.Id, null );
        
        user1.Country = 'aus';
        
        insert user1;
        
        User user2 = TestFactory.getUser('2standarduser2@testorg.com', 'Testing2', '2standt2', 'standarduser2@testorg.com', p.Id, null );
        
        user2.Country = 'australia';
        
        insert user2;
        
        list <Call_Cycle__c> ccList = Test.loadData(Call_Cycle__c.sObjectType, 'CallCycles');
        
        Objective__c obj1 =  TestFactory.getObjective('Objective 1', null, 'State Objective', 'NSW', null,'5');
        
        Objective__c obj2 = TestFactory.getObjective('Objective 2', null, 'National Objective', null, null,'5') ;
        
        for(Call_Cycle__c cc : ccList) {
            
            if(cc.Start_Date__c == date.newInstance(2013,5 ,6)) {
                
                obj1.Call_Cycle__c = cc.Id;
                
                obj2.Call_Cycle__c = cc.Id;

                break;
                
            }    
            
        }
        
        insert obj1;
        
        insert obj2;
        
        System.runAs(user2){
        	
        	list <Account> accounts = Test.loadData(Account.sObjectType, 'Outlets');
        	
        }

        PageReference pageRef = Page.Objective_Planning;
        
        test.startTest();
        
        System.runAs(user2){
            
            ObjectivePlanningController cv = new ObjectivePlanningController();
            
            cv.downloadExcel();
            
            cv.sentMailToManager();
            
            user2.ManagerId = user1.Id;
            
            update user2;
            
            Test.setCurrentPage(pageRef);
            
            ObjectivePlanningController cv1 = new ObjectivePlanningController();
            
            cv1.selectedCallCycle = 'Call Cycle 2';
            
            cv1.selectedYear = '2015';
            
            cv1.sentMailToManager();    
            
            cv1.selectedCallCycle = 'Call Cycle 3';
            
            cv1.selectedYear = '2013';
            
            cv1.sentMailToManager();
            
            
        }
        
        System.runAs(user1){
        
           Test.setCurrentPage(pageRef);
           
           ApexPages.currentPage().getParameters().put('yr', '2013');
           
           ApexPages.currentPage().getParameters().put('uId', ''+user1.Id);
           
           ApexPages.currentPage().getParameters().put('scc', 'Call%20Cycle%204');
           
           ObjectivePlanningController cv = new ObjectivePlanningController();
            
           System.assertEquals(cv.selectedCallCycle, 'Call%20Cycle%204');
           
           System.assertEquals(cv.selectedOutlet, ''+user1.Id);  
           
           System.assertEquals(cv.selectedYear, '2013');     
        
        }
        
        test.stopTest();
        
    }
    
    static testMethod void sortShowHideCancelTest(){
 
        Id bannerGrpId = Utilities.getRecordTypeId('Account', 'Banner Group');
        
        Id accOutlet = Utilities.getRecordTypeId('Account', 'Outlet');
        
        Profile p = [select id from profile where name='System Administrator'];
        
        User user2 = TestFactory.getUser('2standarduser2@testorg.com', 'Testing2', '2standt2', 'standarduser2@testorg.com', p.Id, null );
        
        user2.Country = 'australia';
        
        insert user2;
        
        Account bannergrp1 = TestFactory.getAccount('Banner Grp 1', bannerGrpId);
        
        bannergrp1.My_Sales_Id__c = '1';
        
        insert bannergrp1;
        
        Account bannergrp2 = TestFactory.getAccount('Banner Grp 2', bannerGrpId);
        
        bannergrp1.My_Sales_Id__c = '2';
        
        insert bannergrp2; 
        
        Region__c region1 = TestFactory.getRegion('1', '001');
        
        insert region1;
        
        Region__c region2 = TestFactory.getRegion('2', '002');
        
        insert region2;
        
        State__c state1 = TestFactory.getState(region1.Region_ID__c);
        
        insert state1;
        
        State__c state2 = TestFactory.getState(region2.Region_ID__c);
        
        insert state2;
        
        Account acc1a, acc2a, acc3a, acc1c, acc2c, acc3c;
        
        system.runAs(user2){
            
            list <Account> accounts = Test.loadData(Account.sObjectType, 'Outlets');
            
            for(Account acc:accounts)
            
               acc.RecordTypeId = accOutlet;
            
            update accounts;
            
            list <Account> accList = new list<Account>();
        
            acc1a = TestFactory.getAccount('Acc 1', bannergrp1.Id, '12345', state1.Id, 'NSW', 10.0, 'A');
            
            acc1a.RecordTypeId = accOutlet;
            
            accList.add(acc1a);
            
            acc2a = TestFactory.getAccount('Acc 2', null, '01234', null, 'ACT', 1.0, 'D');
            
            acc1a.RecordTypeId = accOutlet;
            
            accList.add(acc2a);
            
            acc3a = TestFactory.getAccount('Acc 3', bannergrp2.Id, '9813', state2.Id, 'TAS', 4.0, 'B');
            
            acc1a.RecordTypeId = accOutlet;
            
            accList.add(acc3a);  
            
            insert accList;        
            
        }
        
        
        
        date todaysDate = date.newInstance(2013,6,6);
        
        todaysDate = todaysDate.addDays(-15);
                
        list <Call_Cycle__c> ccList = Test.loadData(Call_Cycle__c.sObjectType, 'CallCycles');
        
        Objective__c obj1 =  TestFactory.getObjective('Objective 1', null, 'State Objective', 'NSW', null,'5');
        
        Objective__c obj2 = TestFactory.getObjective('Objective 2', null, 'National Objective', null, null,'5') ;
        
        for(Call_Cycle__c cc : ccList) {
            
            if(cc.Start_Date__c == date.newInstance(2013,5 ,6)) {
                
                obj1.Call_Cycle__c = cc.Id;
                
                obj2.Call_Cycle__c = cc.Id;

                break;
                
            }    
            
        }
        
        insert obj1;
        
        insert obj2;
            
        
        test.startTest();
        
        PageReference pageRef = Page.Objective_Planning;
        
        
        
        //Aus
        
        System.runAs(user2){
            
            Test.setCurrentPage(pageRef);
            
            ObjectivePlanningController cv = new ObjectivePlanningController();
            
            cv.cityFlag =  cv.bannerGrpFlag  =  cv.volumeFlag = cv.gradingFlag  = false;
            
            cv.showHide();
            
            cv.first();
            
            cv.next();
            
            cv.last();
            
            cv.previous();
            
            cv.first();
            
            cv.sortAccount();
            
            cv.currentSortField = 'Outlet';
            
            cv.sortAccount();
            
            cv.currentSortField = 'Outlet';
            
            cv.sortAccount();
            
            cv.currentSortField = 'BannerGroup';
            
            cv.sortAccount();
            
            cv.currentSortField = 'BannerGroup';
            
            cv.sortAccount();
            
            cv.currentSortField = 'City';
            
            cv.sortAccount();
            
            cv.currentSortField = 'City';
            
            cv.sortAccount();
            
            cv.currentSortField = 'Volume';
            
            cv.sortAccount();
            
            cv.currentSortField = 'Volume';
            
            cv.sortAccount();
            
            cv.currentSortField = 'Grading';
            
            cv.sortAccount();
            
            cv.currentSortField = 'Grading';
            
            cv.sortAccount();
            
            cv.selectedBanerGroup = bannergrp1.Id;
            
            cv.searchAccounts();
            
        }
        
        test.stopTest();
        
    }
    
    static testMethod void searchAccountsTest(){
        
        Id bannerGrpId = Utilities.getRecordTypeId('Account', 'Banner Group');
    	
    	Id recordTypeObjectiveId = Utilities.getRecordTypeId('Task', 'Objective');
        
        Id accOutlet = Utilities.getRecordTypeId('Account', 'Outlet');
    	
        list <Call_Cycle__c> ccList = Test.loadData(Call_Cycle__c.sObjectType, 'CallCycles');
        
        User user1 = TestFactory.getUser('1standarduser1@testorg.com', 'Testing1', '1standt1', 'standarduser1@testorg.com', [select id from profile where name='System Administrator'].Id, null );
        
        user1.Country = 'aus';
        
        user1.Region__c = 'NSW';
        
        insert user1;
        
        Account bannergrp1 = TestFactory.getAccount('Banner Grp 1', bannerGrpId);
        
        bannergrp1.My_Sales_Id__c = '1';
        
        insert bannergrp1;
        
        Account bannergrp2 = TestFactory.getAccount('Banner Grp 2', bannerGrpId);
        
        bannergrp1.My_Sales_Id__c = '2';
        
        insert bannergrp2; 
        
        Region__c region1 = TestFactory.getRegion('1', '001');
        
        insert region1;
        
        Region__c region2 = TestFactory.getRegion('2', '002');
        
        insert region2;
        
        State__c state1 = TestFactory.getState(region1.Region_ID__c);
        
        insert state1;
        
        State__c state2 = TestFactory.getState(region2.Region_ID__c);
        
        insert state2;
        
        Objective__c obj1 =  TestFactory.getObjective('Objective 1', null, 'State Objective', 'NSW', null,'5');
        
        Objective__c obj2 = TestFactory.getObjective('Objective 2', null, 'National Objective', null, null,'5') ;
        
        for(Call_Cycle__c cc : ccList) {
            
            if(cc.Start_Date__c == date.newInstance(2013,5 ,6)) {
                
                obj1.Call_Cycle__c = cc.Id;
                
                obj2.Call_Cycle__c = cc.Id;

                break;
                
            }    
            
        }
        
        insert obj1;
        
        insert obj2;
        
        Account acc1a, acc2a, acc3a;
        
        System.runAs(user1){
            
            list <Account> accList = new list<Account>();
        
            acc1a = TestFactory.getAccount('Acc 1', bannergrp1.Id, '12345', state1.Id, 'NSW', 10.0, 'A');
            
            acc1a.RecordTypeId = accOutlet;
            
            accList.add(acc1a);
            
            acc2a = TestFactory.getAccount('Acc 2', null, '01234', null, 'ACT', 1.0, 'D');
            
            acc1a.RecordTypeId = accOutlet;
            
            accList.add(acc2a);
            
            acc3a = TestFactory.getAccount('Acc 3', bannergrp2.Id, '9813', state2.Id, 'TAS', 4.0, 'B');
            
            acc1a.RecordTypeId = accOutlet;
            
            accList.add(acc3a);  
            
            insert accList;  

            list <Task> t = new list<Task>{ TestFactory.getTask('Test Rec', acc1a.Id, date.newInstance(2013,6,6), recordTypeObjectiveId, 'In Progress'),
            	                            TestFactory.getTask('Test Rec', acc2a.Id, date.newInstance(2013,6,6), recordTypeObjectiveId, 'In Progress'),
            	                            TestFactory.getTask('Test Rec', acc3a.Id, date.newInstance(2013,6,6), recordTypeObjectiveId, 'In Progress')};
            	                            
            insert t;	                            
            
        
        }
        
        test.startTest();  
        
        System.runAs(user1){
        	
        	PageReference pageRef = Page.Objective_Planning;
        
            Test.setCurrentPage(pageRef);
         
            ObjectivePlanningController op = new ObjectivePlanningController();
            
            op.selectedGrading = 'A';
            
            op.searchAccounts();
            
            op.selectedGrading = 'All';
            
            op.selectedBanerGroup = bannergrp1.Id;
            
            op.searchAccounts();
            
            op.selectedBanerGroup = 'All';
            
            op.selectedObjective = obj1.Id;
            
            op.searchAccounts();
            
            op.selectedObjective = 'All';
            
            op.searchAccounts();
            
            op.objectiveId = obj1.Id;
            
            op.addAllTasks();
            
            op.saveTasks();
            
            op.objectiveId = obj1.Id;
            
            op.removeAllTasks();
            
            op.saveTasks();
            
            op.objectiveId = obj1.Id;
            
            op.accId = acc1a.Id;
            
            op.addTasks();
            
            op.objectiveId = obj1.Id;
            
            op.accId = acc2a.Id;
            
            op.addTasks();
            
            op.objectiveId = obj1.Id;
            
            op.accId = acc2a.Id;
            
            op.removeTasks();
            
            op.saveTasks();
            
            op.selectedTaskStatus = 'Allocated';
            
            op.searchAccounts();
            
            op.downloadExcel();
            
            op.accAddressId = acc3a.Id;
            
            op.addressInfo();
            
            op.getCurrentObjectivesMap();
            
            op.getYears();
            
            op.getGradings();
            
            op.getBannerGroups();
            
            op.getOutlets();
            
            op.getObjectives();
            
            op.getCallCycles();
            
            op.populateNewObjectives();
            
            op.objectiveIdClicked = obj1.Id;
            
            op.objectiveInfo();
        	
        } 
        
        test.stopTest();
    	
    }

}