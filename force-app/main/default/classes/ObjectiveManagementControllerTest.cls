@isTest
public class ObjectiveManagementControllerTest {
    
    
    static testMethod void testHome(){    	
        ObjectiveManagementController objMgmtController = new ObjectiveManagementController();    	
        PageReference ref = objMgmtController.home();    	
        System.assert(ref.getUrl() == '/home/home.jsp');    	
    }
    
    static testMethod void ausSendMailToManagerTest(){        
        User user1 = TestFactory.getUser('1standarduser1@testorg.com', 'Testing1', '1standt1', 'standarduser1@testorg.com', [select id from profile where name='Standard User'].Id, null );        
        user1.Country = 'aus';
        insert user1;    
        
        User user2 = TestFactory.getUser('2standarduser2@testorg.com', 'Testing2', '2standt2', 'standarduser2@testorg.com', [select id from profile where name='Standard User'].Id, null );        
        user2.Country = 'australia'; 
        user2.State_Sales_Manager__c = user1.id;
        insert user2;    
        
        List<Call_Cycle__c> ccList = Test.loadData(Call_Cycle__c.sObjectType, 'CallCycles');        
        Objective__c obj1 =  TestFactory.getObjective('Objective 1', null, 'State Objective', 'NSW', null,'5');        
        Objective__c obj2 = TestFactory.getObjective('Objective 2', null, 'National Objective', null, null,'5') ;  
        
        for(Call_Cycle__c cc : ccList) {            
            if(cc.Start_Date__c == date.newInstance(2013,5 ,6)) {                
                obj1.Call_Cycle__c = cc.Id;                
                obj2.Call_Cycle__c = cc.Id;
                break;                
            }               
        }
        
        obj1.Channel__c = 'All';
        obj2.Channel__c = 'All';
        
        insert obj1;        
        insert obj2;
        
        System.runAs(user2){        	
            List<Account> accounts = Test.loadData(Account.sObjectType, 'Outlets');        	
        }
        
        PageReference pageRef = Page.ObjectiveManagement;  
        
        test.startTest();
        
        System.runAs(user2){            
            
            /*
* Test for error message if manager id is not available for the user
*/
            ObjectiveManagementController objMgmtController1 = new ObjectiveManagementController();  
            objMgmtController1.selectedObjectiveChannel = 'All';        
            objMgmtController1.selectedGrading = 'A';            
            objMgmtController1.searchAccounts();
            objMgmtController1.downloadExcel();            
            objMgmtController1.sentMailToManager();            
            
            /*
* Update manager id for the running user
*/
            user2.ManagerId = user1.Id;
            update user2; 
            
            /*
* Test for sending mail to manager when required data is available
*/
            Test.setCurrentPage(pageRef);            
            ObjectiveManagementController objMgmtController2 = new ObjectiveManagementController();            
            objMgmtController2.selectedYear = '2015';            
            objMgmtController2.sentMailToManager();     
            
            objMgmtController2.selectedYear = '2013';            
            objMgmtController2.sentMailToManager();
        }
        
        System.runAs(user1){   
            
            /*
* Test to verify the url sent in mail to manager
*/
            Test.setCurrentPage(pageRef);           
            ApexPages.currentPage().getParameters().put('yr', '2013');           
            ApexPages.currentPage().getParameters().put('uId', ''+user1.Id);           
            ApexPages.currentPage().getParameters().put('scc', 'Call%20Cycle%204');           
            ObjectiveManagementController cv = new ObjectiveManagementController();            
            System.assertEquals(cv.selectedOutlet, ''+user1.Id);             
            System.assertEquals(cv.selectedYear, '2013');             
        }
        
        test.stopTest();        
    }
    
    static testMethod void sortShowHideTest(){ 
        
        Id bannerGrpId = Utilities.getRecordTypeId('Account', 'Banner Group');        
        Id accOutlet = Utilities.getRecordTypeId('Account', 'Outlet');          
        
        User user2 = TestFactory.getUser('2standarduser2@testorg.com', 'Testing2', '2standt2', 'standarduser2@testorg.com', [select id from profile where name='System Administrator'].Id, null );        
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
        
        System.runAs(user2){
            
            List<Account> accounts = Test.loadData(Account.sObjectType, 'Outlets');            
            for(Account acc:accounts)            
                acc.RecordTypeId = accOutlet;
            
            update accounts;
            
            List<Account> accList = new List<Account>();        
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
        
        List<Call_Cycle__c> ccList = Test.loadData(Call_Cycle__c.sObjectType, 'CallCycles');
        
        Objective__c obj1 =  TestFactory.getObjective('Objective 1', null, 'State Objective', 'NSW', null,'5');        
        Objective__c obj2 = TestFactory.getObjective('Objective 2', null, 'National Objective', null, null,'5') ;
        
        for(Call_Cycle__c cc : ccList) {            
            if(cc.Start_Date__c == date.newInstance(2013,5 ,6)) {                
                obj1.Call_Cycle__c = cc.Id;                
                obj2.Call_Cycle__c = cc.Id;
                break;                
            }                
        }
        
        
        
        obj1.Channel__c = 'All';
        obj2.Channel__c = 'All';
        
        insert obj1;        
        insert obj2;
        
        
        test.startTest();        
        
        /*
* Test for show/hide and sort functionality
*/
        System.runAs(user2){
            PageReference pageRef = Page.ObjectiveManagement;        
            Test.setCurrentPage(pageRef);
            ObjectiveManagementController cv = new ObjectiveManagementController();    
            cv.cityFlag =  cv.bannerGrpFlag  =  cv.volumeFlag = cv.gradingFlag  = false;  
            cv.selectedObjectiveChannel = 'All';        
            cv.selectedGrading = 'A';            
            cv.searchAccounts();
            cv.showHide();            
            cv.first();            
            cv.next();            
            cv.last();            
            cv.previous();            
            cv.first();            
            cv.sortAccount();            
            //cv.currentSortField = 'Outlet';            
            //cv.sortAccount();            
            //cv.currentSortField = 'Outlet';            
            //cv.sortAccount();            
            cv.currentSortField = 'BannerGroup';            
            //  cv.sortAccount();            
            //cv.currentSortField = 'BannerGroup';            
            //cv.sortAccount();            
            cv.currentSortField = 'City';            
            //  cv.sortAccount();            
            //cv.currentSortField = 'City';            
            //cv.sortAccount();            
            cv.currentSortField = 'Volume';            
            //  cv.sortAccount();            
            //cv.currentSortField = 'Volume';            
            //cv.sortAccount();            
            cv.currentSortField = 'Grading';            
            cv.sortAccount();            
            //cv.currentSortField = 'Grading';            
            //cv.sortAccount();     
            //system.assertEquals(false, ApexPages.hasMessages(), ApexPages.getMessages());
            cv.populateAccounts();
            cv.selectedBanerGroup = bannergrp1.Id;            
            cv.searchAccounts(); 
            cv.populateAccounts();
        }
        
        test.stopTest();        
    }
    
    // Arxxus Advantage Added This 
    static testMethod void sortShowHideTest1(){ 
        Id bannerGrpId = Utilities.getRecordTypeId('Account', 'Banner Group');        
        Id accOutlet = Utilities.getRecordTypeId('Account', 'Outlet');          
        
        User user2 = TestFactory.getUser('2standarduser2@testorg.com', 'Testing2', '2standt2', 'standarduser2@testorg.com', [select id from profile where name='System Administrator'].Id, null );        
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
        System.runAs(user2){
            
            List<Account> accounts = Test.loadData(Account.sObjectType, 'Outlets');            
            for(Account acc:accounts)            
                acc.RecordTypeId = accOutlet;
            
            update accounts;
            
            List<Account> accList = new List<Account>();        
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
        
        List<Call_Cycle__c> ccList = Test.loadData(Call_Cycle__c.sObjectType, 'CallCycles');
        
        Objective__c obj1 =  TestFactory.getObjective('Objective 1', null, 'State Objective', 'NSW', null,'5');        
        Objective__c obj2 = TestFactory.getObjective('Objective 2', null, 'National Objective', null, null,'5') ;
        
        for(Call_Cycle__c cc : ccList) {            
            if(cc.Start_Date__c == date.newInstance(2013,5 ,6)) {                
                obj1.Call_Cycle__c = cc.Id;                
                obj2.Call_Cycle__c = cc.Id;
                break;                
            }                
        }
        
        
        
        obj1.Channel__c = 'All';
        obj2.Channel__c = 'All';
        
        insert obj1;        
        insert obj2;
        
        
        test.startTest();              
        
        /*
* Test for show/hide and sort functionality
*/
        System.runAs(user2){  
            PageReference pageRef = Page.ObjectiveManagement;               
            Test.setCurrentPage(pageRef);            
            ObjectiveManagementController cv = new ObjectiveManagementController();            
            cv.cityFlag =  cv.bannerGrpFlag  =  cv.volumeFlag = cv.gradingFlag  = false;  
            cv.selectedObjectiveChannel = 'All';        
            cv.selectedGrading = 'A';            
            cv.searchAccounts();
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
        Call_Cycle__c testCC = new Call_Cycle__c(
            name = 'Test Call Cycle',
            call_cycle__c = 'Test Call Cycle',
            start_date__c = date.newInstance(2013,5 ,6),
            end_date__c = date.newInstance(2013,6,21),
            location__c = 'Australia'
        );        
        insert testCC;        
        
        obj1.Call_Cycle__c = testCC.Id;
        obj2.Call_Cycle__c = testCC.Id;
        
        obj1.Channel__c = 'All';
        obj2.Channel__c = 'All';
        
        insert obj1;        
        insert obj2;
        
        Account acc1a, acc2a, acc3a;
        
        System.runAs(user1){            
            List <Account> accList = new List<Account>();        
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
            
            List <Task> taskList = new List<Task>{ TestFactory.getTask('Test Rec', acc1a.Id, date.newInstance(2013,6,6), recordTypeObjectiveId,'Allocated'),
                TestFactory.getTask('Test Rec', acc2a.Id, date.newInstance(2013,6,6), recordTypeObjectiveId,'Executed'),
                TestFactory.getTask('Test Rec', acc3a.Id, date.newInstance(2013,6,6), recordTypeObjectiveId,'Executed')};            	                            
                    insert taskList;	       
        }
        
        test.startTest(); 
        
        
        
        
        System.runAs(user1){       
            
            // Create a Config Email configuration
            insert TestFactory.createEmailonfiguration();
            insert TestFactory.createEmailonfiguration('Objective Management Debug Log');
            
            PageReference pageRef = Page.ObjectiveManagement;        
            Test.setCurrentPage(pageRef);         
            ObjectiveManagementController op = new ObjectiveManagementController();            
            op.selectedObjectiveChannel = 'All';        
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
            op.isAllocated = True ;
            op.searchAccounts(); 
            op.getAccounts();            
            ObjectiveManagementController.addAllRemoteTasks(op.selectedGrading,  op.selectedBanerGroup, obj1.Id , obj1.name,obj1.priority_kpi__c, null, op.isCalledOnCheck);            
            op.saveStats();
            
            ObjectiveManagementController.removeAllRemoteTasks(op.selectedGrading,  op.selectedBanerGroup, obj1.Id, obj1.priority_kpi__c, null);            
            op.saveStats();            
            //ObjectiveManagementController.addRemoteTasks(acc1a.Id, obj1.Id, obj1.name, testCC.call_cycle__c ,'2013' ,obj1.priority_kpi__c, null);            
            //ObjectiveManagementController.addRemoteTasks(acc2a.Id, obj1.Id, obj1.name, testCC.call_cycle__c ,'2013' ,obj1.priority_kpi__c, null);            
            //ObjectiveManagementController.removeRemoteTasks(acc2a.Id, obj1.Id, testCC.call_cycle__c ,'2013');            
            //op.saveStats();
            
            op.selectedTaskStatus = 'Allocated';            
            op.searchAccounts();            
            op.downloadExcel();  
            op.downloadExcelForOutlet();
            op.accAddressId = acc3a.Id;            
            op.addressInfo();            
            op.getCurrentObjectivesMap();            
            op.getYears();            
            op.getGradings();            
            op.getBannerGroups();   
            op.getTaskStatus();
            op.getAccountChannels();
            op.getnumberOfOutlets();
            op.getPriorityKpi();
            
            
            String value = ObjectiveManagementController.getTaskRecordTypeId(String.valueOf(obj1.Id), String.valueOf(acc3a.id));
        } 
        
        
        
        test.stopTest();    	
    }	
    
    static testMethod void searchAccountsTest2(){
        
        Id bannerGrpId = Utilities.getRecordTypeId('Account', 'Banner Group');    	
        Id recordTypeObjectiveId = Utilities.getRecordTypeId('Task', 'Objective');        
        Id accOutlet = Utilities.getRecordTypeId('Account', 'Outlet');    	
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
        Call_Cycle__c testCC = new Call_Cycle__c(
            name = 'Test Call Cycle',
            call_cycle__c = 'Test Call Cycle',
            start_date__c = date.newInstance(2013,5 ,6),
            end_date__c = date.newInstance(2013,6,21),
            location__c = 'Australia'
        );        
        insert testCC;        
        
        obj1.Call_Cycle__c = testCC.Id;
        obj2.Call_Cycle__c = testCC.Id;
        
        obj1.Channel__c = 'All';
        obj2.Channel__c = 'All';
        
        insert obj1;        
        insert obj2;
        
        Account acc1a, acc2a, acc3a;
        
        System.runAs(user1){            
            List <Account> accList = new List<Account>();        
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
            
            List <Task> taskList = new List<Task>{ TestFactory.getTask('Test Rec', acc1a.Id, date.newInstance(2013,6,6), recordTypeObjectiveId,'Allocated'),
                TestFactory.getTask('Test Rec', acc2a.Id, date.newInstance(2013,6,6), recordTypeObjectiveId,'Executed'),
                TestFactory.getTask('Test Rec', acc3a.Id, date.newInstance(2013,6,6), recordTypeObjectiveId,'Executed')};            	                            
                    insert taskList;	       
        }
        
        test.startTest(); 
        
        insert TestFactory.createEmailonfiguration('Objective Management Debug Log');
        
        
        System.runAs(user1){        	
            PageReference pageRef = Page.ObjectiveManagement;        
            Test.setCurrentPage(pageRef);         
            ObjectiveManagementController op = new ObjectiveManagementController();            
            op.selectedObjectiveChannel = 'All';        
            op.selectedGrading = 'A';            
            op.searchAccounts();        
            op.selectedGrading = 'All';            
            op.selectedBanerGroup = bannergrp1.Id;            
            //op.searchAccounts();            
            op.selectedBanerGroup = 'All';            
            op.selectedObjective = obj1.Id;            
            //op.searchAccounts();            
            op.selectedObjective = 'All';    
            //op.searchAccounts(); 
            op.isAllocated = True ;
            op.searchAccounts();
            op.getAccounts();            
            //ObjectiveManagementController.addAllRemoteTasks(op.selectedGrading,  op.selectedBanerGroup, obj1.Id , obj1.name ,obj1.priority_kpi__c, null, op.isCalledOnCheck);            
            //op.saveStats();
            
            //ObjectiveManagementController.removeAllRemoteTasks(op.selectedGrading,  op.selectedBanerGroup, obj1.Id, testCC.call_cycle__c ,'2013' ,obj1.priority_kpi__c, null);            
            //op.saveStats();            
            ObjectiveManagementController.addRemoteTasks(acc1a.Id, obj1.Id, obj1.name ,obj1.priority_kpi__c, null);            
            ObjectiveManagementController.addRemoteTasks(acc2a.Id, obj1.Id, obj1.name ,obj1.priority_kpi__c, null);            
            ObjectiveManagementController.removeRemoteTasks(acc2a.Id, obj1.Id);   
            op.saveStats();
            
            //op.selectedTaskStatus = 'Allocated';            
            //op.searchAccounts();            
            
            op.getBannerGroups();            
            op.getOutlets();            
            op.getObjectives();            
            op.getCallCycles();            
            op.populateNewObjectives();            
            op.objectiveIdClicked = obj1.Id;            
            op.objectiveInfo();   
            
            op.countryNotFound();
        } 
        
        
        
        test.stopTest();    	
    }	
    
    static testMethod void searchAccountsTest3(){
        
        Id bannerGrpId = Utilities.getRecordTypeId('Account', 'Banner Group');    	
        Id recordTypeObjectiveId = Utilities.getRecordTypeId('Task', 'Objective');        
        Id accOutlet = Utilities.getRecordTypeId('Account', 'Outlet');    	
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
        Call_Cycle__c testCC = new Call_Cycle__c(
            name = 'Test Call Cycle',
            call_cycle__c = 'Test Call Cycle',
            start_date__c = date.newInstance(2013,5 ,6),
            end_date__c = date.newInstance(2013,6,21),
            location__c = 'Australia'
        );        
        insert testCC;        
        
        obj1.Call_Cycle__c = testCC.Id;
        obj2.Call_Cycle__c = testCC.Id;
        
        obj1.Channel__c = 'All';
        obj2.Channel__c = 'All';
        
        insert obj1;        
        insert obj2;
        
        Account acc1a, acc2a, acc3a;
        
        System.runAs(user1){            
            List <Account> accList = new List<Account>();        
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
            
            List <Task> taskList = new List<Task>{ TestFactory.getTask('Test Rec', acc1a.Id, date.newInstance(2013,6,6), recordTypeObjectiveId,'Allocated'),
                TestFactory.getTask('Test Rec', acc2a.Id, date.newInstance(2013,6,6), recordTypeObjectiveId,'Executed'),
                TestFactory.getTask('Test Rec', acc3a.Id, date.newInstance(2013,6,6), recordTypeObjectiveId,'Executed')};            	                            
                    insert taskList;	       
        }
        
        test.startTest(); 
        
        insert TestFactory.createEmailonfiguration('Objective Management Debug Log');
        
        
        System.runAs(user1){        	
            PageReference pageRef = Page.ObjectiveManagement;        
            Test.setCurrentPage(pageRef);         
            ObjectiveManagementController op = new ObjectiveManagementController();            
            op.selectedGrading = 'All';            
            op.selectedBanerGroup = 'All';            
            op.selectedObjective = 'All';    
            op.isAllocated = True ;
            op.searchAccounts();
            op.getAccounts();            
            ObjectiveManagementController.addAllRemoteTasks(op.selectedGrading,  op.selectedBanerGroup, obj1.Id , obj1.name ,'1', null, true);
            ObjectiveManagementController.removeAllRemoteTasks(acc1a.Id, obj1.Id, obj1.name ,obj1.priority_kpi__c, null);
            op.saveStats();
            
        } 
        
        
        
        test.stopTest();    	
    }
}