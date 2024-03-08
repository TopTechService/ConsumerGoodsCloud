/**
 * @author    : Created by Geeta Kushwaha on 4 June, 2013  geeta.kushwaha@arxxus.com
 * @Purpose   : Test Class
 * @Criteria  : This is test class for DayDateWeekCalculator
 * @Modified  : Modified by Geeta Kushwaha on 4 June, 2013  geeta.kushwaha@arxxus.com
 */
@isTest
public class CallVisitPlanControllerTest {

    static testMethod void ausSendMailToManagerTest(){
        
        Profile p = [select id from profile where name='Standard user'];
        
        User user1 = TestFactory.getUser('1standarduser1@testorg.com', 'Testing1', '1standt1', 'standarduser1@testorg.com', p.Id, null );
        
        user1.Country = 'aus';
        //user1.State_Sales_Manager__c = userInfo.getUserId();
        insert user1;
        
        User user2 = TestFactory.getUser('2standarduser2@testorg.com', 'Testing2', '2standt2', 'standarduser2@testorg.com', p.Id, null );
        
        user2.Country = 'australia';
        
        insert user2;
        
        list <Call_Cycle__c> accounts = Test.loadData(Call_Cycle__c.sObjectType, 'CallCycles');

        PageReference pageRef = Page.Call_Planning_Lightning;
        
        test.startTest();
        
        
          
        
            user2.ManagerId = user1.Id;
            user2.State_Sales_Manager__c = user1.Id;
            update user2;
        
       System.runAs(user2){ 
           
            Test.setCurrentPage(pageRef);
            
            CallVisitPlanController cv1 = new CallVisitPlanController();
            
           
           ApexPages.currentPage().getParameters().put('yr', '2013');
           ApexPages.currentPage().getParameters().put('uId', ''+user2.Id);
           ApexPages.currentPage().getParameters().put('scc', 'Call%20Cycle%204');
           
           cv1 = new CallVisitPlanController();

            
            cv1.selectedYear = '2013';
           
            cv1.recalculateCallCycles();
           
            cv1.selectedYear = '2015';
           
            cv1.recalculateCallCycles();
           
            cv1.selectedSourceCallCycleYear = '2013';
           
            cv1.recalculateSourceCallCycles(); 
           
            cv1.selectedSourceCallCycleYear = '2015';
           
            cv1.recalculateSourceCallCycles(); 
           
            cv1.selectedNewCallCycleYear = '2013';
           
            cv1.recalculateDestinationCallCycles();  
           
            cv1.selectedNewCallCycleYear = '2015';
           
            cv1.recalculateDestinationCallCycles();   
            
            cv1.getnumberOfOutlets();       
            
        }
        
        System.runAs(user1){
        
           Test.setCurrentPage(pageRef);
           
           ApexPages.currentPage().getParameters().put('yr', '2013');
           
           ApexPages.currentPage().getParameters().put('uId', ''+user1.Id);
           
           ApexPages.currentPage().getParameters().put('scc', 'Call%20Cycle%204');
           
           CallVisitPlanController cv = new CallVisitPlanController();
            
           System.assertEquals(cv.selectedCallCycle, 'Call%20Cycle%204');
           
           //YB - 2019-01-24
           //System.assertEquals(cv.selectedOutlet, ''+user1.Id);  
           
           System.assertEquals(cv.selectedYear, '2013');     
        
        }
        
        test.stopTest();
        
    }
    
    static testMethod void testHome(){
        
        CallVisitPlanController cv = new CallVisitPlanController();
        
        PageReference ref = cv.home();
        
        System.assert(ref.getUrl() == '/home/home.jsp');
        
    }
    
    static testMethod void AusSortShowHideCancelTest(){
 
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
        

        list <Call_Cycle__c> accounts = Test.loadData(Call_Cycle__c.sObjectType, 'CallCycles');
        
        test.startTest();
        
        PageReference pageRef = Page.Call_Planning_Lightning;
        
        //Aus
        
        System.runAs(user2){
            
            Test.setCurrentPage(pageRef);
            
            CallVisitPlanController cv = new CallVisitPlanController();
            
            //cv.cityFlag =  cv.bannerGrpFlag  =  cv.volumeFlag = cv.gradingFlag = cv.isCalledOnCheck = false;
            cv.isCalledOnCheck = false;
            
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
            cv.reverseSortDirection();
            
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
            
            cv.currentSortField = 'postCode';
            
            cv.sortAccount();
            
            cv.currentSortField = 'postCode';
            
            cv.sortAccount();
            
            cv.selectedBanerGroup = bannergrp1.Id;
            
            cv.searchAccounts();
            
            cv.selectedPostcode = region1.Region_Abbr__c;
            
            cv.searchAccounts();
            
            cv.cancel();
            
            cv.selectedYear = '2015';
            
            cv.selectedCallCycle = 'Call Cycle 2';
            
            cv.searchAccounts();
            
            cv.saveevents();
            
            cv.selectedWeek = 'Week 2';
            
            cv.searchAccounts();
            
        }
        
        test.stopTest();
        
    }
    
    static testMethod void AusAddDelSaveTest(){
 
        Id bannerGrpId = Utilities.getRecordTypeId('Account', 'Banner Group');
        Id accOutlet = Utilities.getRecordTypeId('Account', 'Outlet');
        Id eventCallVisit = Utilities.getRecordTypeId('event', 'Visit');
        
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
            
            list <Account> accList = new list<Account>();
        
            acc1a = TestFactory.getAccount('Acc 1', bannergrp1.Id, '12345', state1.Id, 'NSW', 10.0, 'A');
            
            acc1a.RecordTypeId = accOutlet;
            //acc1a.Called_On__c = true;
            
            accList.add(acc1a);
            
            acc2a = TestFactory.getAccount('Acc 2', null, '01234', null, 'ACT', 1.0, 'B');
            
            acc2a.RecordTypeId = accOutlet;
            //acc2a.Called_On__c = true;
            
            accList.add(acc2a);
            
            acc3a = TestFactory.getAccount('Acc 3', bannergrp2.Id, '9813', state2.Id, 'TAS', 4.0, 'C');
            
            acc3a.RecordTypeId = accOutlet;
            //acc3a.Called_On__c = true;
            
            accList.add(acc3a);  
            
            insert accList;        
            
        }
        
        
        list <Call_Cycle__c> accounts = Test.loadData(Call_Cycle__c.sObjectType, 'CallCycles');
        
        list <event> eventList = new list <event>{
                                                TestFactory.getevent('test', acc1a.Id, date.newInstance(2013,2,1), eventCallVisit, 'Not Started'),
                                                TestFactory.getevent('test', acc2a.Id, date.newInstance(2013,2,1), eventCallVisit, 'In Progress'),
                                                TestFactory.getevent('test', acc3a.Id, date.newInstance(2013,2,1), eventCallVisit, 'Not Started'),
                                                TestFactory.getevent('test', acc1a.Id, date.newInstance(2013,2,4), eventCallVisit, 'Not Started'),
                                                TestFactory.getevent('test', acc2a.Id, date.newInstance(2013,2,4), eventCallVisit, 'Not Started'),
                                                
                                                TestFactory.getevent('test', acc1a.Id, date.newInstance(2013,4,1), eventCallVisit, 'Not Started'),
                                                TestFactory.getevent('test', acc2a.Id, date.newInstance(2013,4,1), eventCallVisit, 'Not Started'),
                                                TestFactory.getevent('test', acc3a.Id, date.newInstance(2013,4,1), eventCallVisit, 'Not Started'),
                                                TestFactory.getevent('test', acc1a.Id, date.newInstance(2013,4,16), eventCallVisit, 'Not Started'),
                                                TestFactory.getevent('test', acc2a.Id, date.newInstance(2013,4,16), eventCallVisit, 'Not Started'),
                                                
                                                TestFactory.getevent('test', acc1a.Id, date.newInstance(2013,6,4), eventCallVisit, 'Not Started'),
                                                TestFactory.getevent('test', acc2a.Id, date.newInstance(2013,6,4), eventCallVisit, 'Not Started'),
                                                TestFactory.getevent('test', acc3a.Id, date.newInstance(2013,6,4), eventCallVisit, 'Not Started'),
                                                TestFactory.getevent('test', acc1a.Id, date.newInstance(2013,6,14), eventCallVisit, 'Not Started'),
                                                TestFactory.getevent('test', acc2a.Id, date.newInstance(2013,6,14), eventCallVisit, 'Not Started')
                                                
                                                };
        
            
        
            
        insert eventList;
        
        event t = [select id, Status__c
                  from event
                  where ActivityDate =: date.newInstance(2013,6,14)
                  and RecordTypeId =: eventCallVisit
                  and WhatId =: acc2a.Id];
                  
        t.Status__c = 'Completed';
        
        update t;         
        
        test.startTest();
        
        PageReference pageRef = Page.Call_Planning_Lightning;
        
        
        //Aus
        
        System.runAs(user2){
            
            Test.setCurrentPage(pageRef);
            
            CallVisitPlanController cv = new CallVisitPlanController();
            
            cv.selectedCallCycle = 'Call Cycle 1';
            cv.selectedWeek = 'All';
            cv.searchAccounts();
            cv.selectedWeek = 'Week 1';
            cv.searchAccounts();
            cv.selectedCallCycle = 'Call Cycle 3';
            cv.selectedWeek = 'All';
            cv.searchAccounts();
            
            for(integer i= 0; i < cv.daysCheckBoxList.size() - 2; i++){
                cv.daysCheckBoxList[i] = true;
            }
            
            cv.accId = acc1a.Id;
            cv.weekName = 'Week 2';
            cv.addTempevent();
            cv.saveevents();
           
            
            for(integer i= 0; i < cv.daysCheckBoxList.size() - 2; i++){
                cv.daysCheckBoxList[i] = false;
            }
            
            cv.accId = acc1a.Id;
            cv.weekName = 'Week 2';
            cv.addTempevent();
            
            for(integer i= 0; i < cv.daysCheckBoxList.size() - 2; i++){
                cv.daysCheckBoxList[i] = true;
            }
            
            cv.accId = acc1a.Id;
            cv.weekName = 'Week 3';
            cv.addTempevent();
            
            for(integer i= 0; i < cv.daysCheckBoxList.size() - 2; i++){
                cv.daysCheckBoxList[i] = true;
            }
            
            cv.accId = acc1a.Id;
            cv.weekName = 'Week 3';
            cv.addTempevent();
            cv.cancel();
            cv.selectedCallCycle = 'Call Cycle 4';
            cv.searchAccounts();
            cv.accId = acc2a.Id;
            cv.weekName = 'Week 1';
            cv.daysCheckBoxList[0] = true;
            cv.daysCheckBoxList[1] = true;
            cv.eventDescription = 'Comment 1';
            cv.addTempevent();
            cv.saveevents();
            cv.accId = acc2a.Id;
            cv.weekName = 'Week 1';
            cv.daysCheckBoxList[0] = false;
            cv.daysCheckBoxList[1] = false;
            cv.eventDescription = 'Comment 1';
            cv.addTempevent();
            cv.saveevents();
            cv.accId = acc3a.Id;
            cv.weekName = 'Week 1';
            cv.daysCheckBoxList[0] = true;
            cv.daysCheckBoxList[1] = true;
            cv.eventDescription = 'Comment 2';
            cv.addTempevent();
            cv.getdaysHeader();
            cv.getWeeksHeader();
            cv.getPostCode();
            cv.getMonths();
            cv.getYears();
            cv.getGradings();
            cv.getBannerGroups();
            cv.getOutlets();
            cv.getWeeks();
            cv.getSourceCallCycles();
            cv.getCallCycles();
            cv.accAddressId = acc3a.Id;
            cv.addressInfo();
            cv.selectedSourceCallCycle = 'Default';
            cv.selectedSourceCallCycle = 'Call Cycle 3';
            cv.selectedSourceCallCycle = 'Call Cycle 3';
            cv.showDialog = false;
            
            // Test the deleteeventForDay Page Reference
            cv.addeventToeventMap(cv.accId, cv.weekName,'Mon',t);
            cv.weekDayname = ' Mon:';
            PageReference pr = cv.deleteeventForDay();
            t.Status__c = 'In Progress';
            update t;
            cv.weekDayname = ' Tue:';
            cv.addeventToeventMap(cv.accId, cv.weekName,'Tue',t);
            
            // Test the createeventForDay Page Reference
            cv.weekDayname = ' Mon:';
            pr = cv.createeventForDay();
            cv.getAccType();
              
        }
        
        test.stopTest();
        
    }


//====================Arxxus Advantage Added =======================//

static testMethod void AusRemoveAlleventsTest(){
 
        Id bannerGrpId = Utilities.getRecordTypeId('Account', 'Banner Group');
        Id accOutlet = Utilities.getRecordTypeId('Account', 'Outlet');
        Id eventCallVisit = Utilities.getRecordTypeId('Event', 'Visit');
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
            
            list <Account> accList = new list<Account>();
        
            acc1a = TestFactory.getAccount('Acc 1', bannergrp1.Id, '12345', state1.Id, 'NSW', 10.0, 'A');
            
            acc1a.RecordTypeId = accOutlet;
            acc1a.Called_On__c = true;
            
            accList.add(acc1a);
            
            acc2a = TestFactory.getAccount('Acc 2', null, '01234', null, 'ACT', 1.0, 'B');
            
            acc2a.RecordTypeId = accOutlet;
            acc2a.Called_On__c = true;
            
            accList.add(acc2a);
            
            acc3a = TestFactory.getAccount('Acc 3', bannergrp2.Id, '9813', state2.Id, 'TAS', 4.0, 'C');
            
            acc3a.RecordTypeId = accOutlet;
            acc3a.Called_On__c = true;
            
            accList.add(acc3a);  
            
            insert accList;        
            
        }
        
        
        list <Call_Cycle__c> accounts = Test.loadData(Call_Cycle__c.sObjectType, 'CallCycles');
        
        list <event> eventList = new list <event>{
                                                TestFactory.getevent('test', acc1a.Id, date.newInstance(2013,2,1), eventCallVisit, 'Not Started'),
                                                TestFactory.getevent('test', acc2a.Id, date.newInstance(2013,2,1), eventCallVisit, 'Not Started'),
                                                TestFactory.getevent('test', acc3a.Id, date.newInstance(2013,2,1), eventCallVisit, 'Not Started'),
                                                TestFactory.getevent('test', acc1a.Id, date.newInstance(2013,2,4), eventCallVisit, 'In Progress'),
                                                TestFactory.getevent('test', acc2a.Id, date.newInstance(2013,2,4), eventCallVisit, 'In Progress'),
                                                
                                                TestFactory.getevent('test', acc1a.Id, date.newInstance(2013,4,1), eventCallVisit, 'Not Started'),
                                                TestFactory.getevent('test', acc2a.Id, date.newInstance(2013,4,1), eventCallVisit, 'Not Started'),
                                                TestFactory.getevent('test', acc3a.Id, date.newInstance(2014,9,1), eventCallVisit, 'Not Started'),
                                                TestFactory.getevent('test', acc1a.Id, date.newInstance(2014,9,16), eventCallVisit, 'In Progress'),
                                                TestFactory.getevent('test', acc2a.Id, date.newInstance(2013,4,16), eventCallVisit, 'In Progress'),
                                                
                                                TestFactory.getevent('test', acc1a.Id, date.newInstance(2013,6,4), eventCallVisit, 'Not Started'),
                                                TestFactory.getevent('test', acc2a.Id, date.newInstance(2013,6,4), eventCallVisit, 'Not Started'),
                                                TestFactory.getevent('test', acc3a.Id, date.newInstance(2013,6,4), eventCallVisit, 'Not Started'),
                                                TestFactory.getevent('test', acc1a.Id, date.newInstance(2013,6,14), eventCallVisit, 'Not Started'),
                                                TestFactory.getevent('test', acc2a.Id, date.newInstance(2013,6,14), eventCallVisit, 'Not Started')
                                                
                                                };
        
            
        
            
        insert eventList;
        
        event t = [select id, Status__c
                  from event
                  where ActivityDate =: date.newInstance(2013,6,14)
                  and RecordTypeId =: eventCallVisit
                  and WhatId =: acc2a.Id];
                  
        t.Status__c = 'Not Started';
        
        update t;         
        
        test.startTest();
        
        PageReference pageRef = Page.Call_Planning_Lightning;
    
    System.runAs(user2){
        
        list <event> eventList1 = new list <event>{
                                                TestFactory.getevent('test', acc1a.Id, date.newInstance(2013,2,1), eventCallVisit, 'Not Started'),
                                                TestFactory.getevent('test', acc2a.Id, date.newInstance(2013,2,1), eventCallVisit, 'Not Started'),
                                                TestFactory.getevent('test', acc3a.Id, date.newInstance(2013,2,1), eventCallVisit, 'Not Started'),
                                                TestFactory.getevent('test', acc1a.Id, date.newInstance(2013,2,4), eventCallVisit, 'In Progress'),
                                                TestFactory.getevent('test', acc2a.Id, date.newInstance(2013,2,4), eventCallVisit, 'In Progress')
                                                    };
        insert eventList1;
            
            Test.setCurrentPage(pageRef);
            CallVisitPlanController cv = new CallVisitPlanController();
            cv.selectedCallCycle = 'Call Cycle 4';
            cv.clear = true;
            cv.selectedWeek = 'All';      
            cv.selectedBanerGroup = 'All';
            cv.selectedPostcode = 'All';  
            cv.selectedGrading = 'All';
            //cv.cityFlag =  cv.bannerGrpFlag  =  cv.volumeFlag = cv.gradingFlag  = false;              
            cv.searchAccounts();
        
            cv.weekName = 'Week 2';
            cv.getdaysHeader();
            cv.getWeeksHeader();
            cv.getPostCode();
            cv.getMonths();
            cv.getYears();
            cv.getGradings();
            cv.getBannerGroups();
            cv.getOutlets();
            cv.getWeeks();
            cv.getEventStatus();
            cv.getSourceCallCycles();
            cv.getDestinationCallCycles();
            cv.getCallCycles();
            cv.accAddressId = acc3a.Id;
            cv.addressInfo();
            cv.clear = true;
            cv.removeAllEvents();
            cv.selectedWeek = 'Week 2';
            cv.selectedEventStatus = 'Not Started';
            cv.clear = true;
            cv.currentPageNumber = 2;
            cv.searchAccounts();
            cv.populateInsertedEvents();
        
           
        }
        
        //Aus
        
        System.runAs(user2){
            
            Test.setCurrentPage(pageRef);
            CallVisitPlanController cv = new CallVisitPlanController();
            cv.clear = true;
            cv.selectedCallCycle = 'Call Cycle 1';
            cv.selectedWeek = 'All';
            cv.selectedBanerGroup = 'All';
            cv.selectedPostcode = 'All';  
            cv.selectedGrading = 'All';
            //cv.cityFlag =  cv.bannerGrpFlag  =  cv.volumeFlag = cv.gradingFlag  = false; 
            
            cv.searchAccounts();
            cv.selectedWeek = 'Week 1';
            cv.searchAccounts();
            cv.selectedCallCycle = 'Call Cycle 3';
            cv.selectedWeek = 'All';
            cv.searchAccounts();

            for(integer i= 0; i < cv.daysCheckBoxList.size() - 2; i++){
                cv.daysCheckBoxList[i] = true;
            }
            
            cv.accId = acc1a.Id;
            cv.weekName = 'Week 2';
            //cv.addTempevent();
            cv.saveevents();
            
            for(integer i= 0; i < cv.daysCheckBoxList.size() - 2; i++){
                cv.daysCheckBoxList[i] = false;
            }
            
            cv.accId = acc1a.Id;
            cv.weekName = 'Week 2';
            //cv.addTempevent();
            
            for(integer i= 0; i < cv.daysCheckBoxList.size() - 2; i++){
                cv.daysCheckBoxList[i] = true;
            }
            
            cv.accId = acc1a.Id;
            cv.weekName = 'Week 3';
            //cv.addTempevent();
            
            for(integer i= 0; i < cv.daysCheckBoxList.size() - 2; i++){
                cv.daysCheckBoxList[i] = true;
            }
            
            cv.accId = acc1a.Id;
            cv.weekName = 'Week 3';
            //cv.addTempevent();
            cv.cancel();
            cv.selectedCallCycle = 'Call Cycle 4';
            cv.searchAccounts();
            cv.accId = acc2a.Id;
            cv.weekName = 'Week 1';
            cv.daysCheckBoxList[0] = true;
            cv.daysCheckBoxList[1] = true;
            cv.eventDescription = 'Comment 1';
            //cv.addTempevent();
            cv.saveevents();
            cv.accId = acc2a.Id;
            cv.weekName = 'Week 1';
            cv.daysCheckBoxList[0] = false;
            cv.daysCheckBoxList[1] = false;
            cv.eventDescription = 'Comment 1';
            //cv.addTempevent();
            cv.getdaysHeader();
            cv.getWeeksHeader();
            cv.getPostCode();
            cv.getMonths();
            cv.getYears();
            cv.getGradings();
            cv.getBannerGroups();
            cv.getOutlets();
            cv.getWeeks();
            cv.getSourceCallCycles();
            cv.getCallCycles();
            cv.accAddressId = acc3a.Id;
            cv.addressInfo();

            cv.showDialog = false;
            //cv.setAsDefault();
            //cv.getAccType();
            //cv.geteventStatus();
            //cv.getDestinationCallCycles();
            //cv.validateNumberOfevents();
            //cv.removeAllevents();
                                  
        }
        
        test.stopTest();
        
    }

static testMethod void CallPlanningLightning(){
 
        Id bannerGrpId = Utilities.getRecordTypeId('Account', 'Banner Group');
        Id accOutlet = Utilities.getRecordTypeId('Account', 'Outlet');
        Id eventCallVisit = Utilities.getRecordTypeId('event', 'Visit');
        
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
            
            list <Account> accList = new list<Account>();
        
            acc1a = TestFactory.getAccount('Acc 1', bannergrp1.Id, '12345', state1.Id, 'NSW', 10.0, 'A');
            
            acc1a.RecordTypeId = accOutlet;
            //acc1a.Called_On__c = true;
            
            accList.add(acc1a);
            
            acc2a = TestFactory.getAccount('Acc 2', null, '01234', null, 'ACT', 1.0, 'B');
            
            acc2a.RecordTypeId = accOutlet;
            //acc2a.Called_On__c = true;
            
            accList.add(acc2a);
            
            acc3a = TestFactory.getAccount('Acc 3', bannergrp2.Id, '9813', state2.Id, 'TAS', 4.0, 'C');
            
            acc3a.RecordTypeId = accOutlet;
            //acc3a.Called_On__c = true;
            
            accList.add(acc3a);  
            
            insert accList;        
            
        }
        
        
        list <Call_Cycle__c> accounts = Test.loadData(Call_Cycle__c.sObjectType, 'CallCycles');
        
        list <event> eventList = new list <event>{
                                                TestFactory.getevent('test', acc1a.Id, date.newInstance(2013,2,1), eventCallVisit, 'Not Started'),
                                                TestFactory.getevent('test', acc2a.Id, date.newInstance(2013,2,1), eventCallVisit, 'In Progress'),
                                                TestFactory.getevent('test', acc3a.Id, date.newInstance(2013,2,1), eventCallVisit, 'Not Started'),
                                                TestFactory.getevent('test', acc1a.Id, date.newInstance(2013,2,4), eventCallVisit, 'Not Started'),
                                                TestFactory.getevent('test', acc2a.Id, date.newInstance(2013,2,4), eventCallVisit, 'Not Started'),
                                                
                                                TestFactory.getevent('test', acc1a.Id, date.newInstance(2013,4,1), eventCallVisit, 'Not Started'),
                                                TestFactory.getevent('test', acc2a.Id, date.newInstance(2013,4,1), eventCallVisit, 'Not Started'),
                                                TestFactory.getevent('test', acc3a.Id, date.newInstance(2013,4,1), eventCallVisit, 'Not Started'),
                                                TestFactory.getevent('test', acc1a.Id, date.newInstance(2013,4,16), eventCallVisit, 'Not Started'),
                                                TestFactory.getevent('test', acc2a.Id, date.newInstance(2013,4,16), eventCallVisit, 'Not Started'),
                                                
                                                TestFactory.getevent('test', acc1a.Id, date.newInstance(2013,6,4), eventCallVisit, 'Not Started'),
                                                TestFactory.getevent('test', acc2a.Id, date.newInstance(2013,6,4), eventCallVisit, 'Not Started'),
                                                TestFactory.getevent('test', acc3a.Id, date.newInstance(2013,6,4), eventCallVisit, 'Not Started'),
                                                TestFactory.getevent('test', acc1a.Id, date.newInstance(2013,6,14), eventCallVisit, 'Not Started'),
                                                TestFactory.getevent('test', acc2a.Id, date.newInstance(2013,6,14), eventCallVisit, 'Not Started')
                                                
                                                };
        
            
        
            
        insert eventList;
        
        event t = [select id, Status__c
                  from event
                  where ActivityDate =: date.newInstance(2013,6,14)
                  and RecordTypeId =: eventCallVisit
                  and WhatId =: acc2a.Id];
                  
        t.Status__c = 'Completed';
        
        update t;         
        
        test.startTest();
        
        PageReference pageRef = Page.Call_Planning_Lightning;
            
        
        //Aus
        
        System.runAs(user2){
            
            Test.setCurrentPage(pageRef);
            
            CallVisitPlanController cv = new CallVisitPlanController();
            
            cv.selectedCallCycle = 'Call Cycle 1';
            cv.selectedWeek = 'All';
            cv.searchAccounts();
            cv.selectedWeek = 'Week 1';
            cv.searchAccounts();
            cv.selectedCallCycle = 'Call Cycle 3';
            cv.selectedWeek = 'All';
            cv.searchAccounts();
            
            for(integer i= 0; i < cv.daysCheckBoxList.size() - 2; i++){
                cv.daysCheckBoxList[i] = true;
            }
            cv.saveFilterSettings();
            cv.executeSortOrder();
            cv.saveSortBy();
            cv.executeSortBy();
            cv.refreshAccounts();
            
            cv.populateAccounts();
            // Put Parameters into the current page Parameters for SaveAllEvents
            String AccountList =  '["'+acc1a.id+'"]';
            ApexPages.currentPage().getParameters().put('accountsArray',AccountList);
            ApexPages.currentPage().getParameters().put('weeksArray','["Week 1"]');
            ApexPages.currentPage().getParameters().put('daysArray','["1Mon"]');
            ApexPages.currentPage().getParameters().put('addOrRemoveArray','["true"]');
            cv.saveAllEvents();
            cv.reseteventMap();
            
            ApexPages.currentPage().getParameters().put('accountsArray',AccountList);
            ApexPages.currentPage().getParameters().put('weeksArray','["Week 1"]');
            ApexPages.currentPage().getParameters().put('daysArray','["1Mon"]');
            ApexPages.currentPage().getParameters().put('addOrRemoveArray','["false"]');
            cv.saveAllEvents();
            
            cv.toggleSectionFilter();
            cv.toggleSectionClone();
              
        }
        
        test.stopTest();
        
    }

    static testMethod void saveLoadFromTemplateTest(){

        test.startTest();
        Call_Cycle__c callCycle = new Call_Cycle__c(
            Name = 'Test Call Cycle',
            Call_cycle__c = 'Test Call Cycle',
            Start_date__c = Date.newInstance(2023, 11, 27),
            End_date__c = Date.newInstance(2023, 12, 22),
            Location__c = 'Australia'
        );        
        insert callCycle;  

        User currentUser = [Select id, Country from User where Id =: UserInfo.getUserId()];    
        DayDateWeekCalculator dayDateWeekCalc = new DayDateWeekCalculator(currentUser.Country.toLowerCase());

        Call_Cycle_Template__c callCycleTemplate = new Call_Cycle_Template__c(
            Name = 'Week 1',
            Subject__c = 'Week 1',
            Start_Date_Time__c = DateTime.now(),
            Assigned_To__c = UserInfo.getUserId(),
            CC_Week__c = '1',
            Day_of_the_Week__c = dayDateWeekCalc.getDayOfWeek( Date.today())
        );
        insert callCycleTemplate;

        CallVisitPlanController cv = new CallVisitPlanController();
        cv.selectedCurrentOrFutureCallCycle = [SELECT Id FROM Call_Cycle__c LIMIT 1].Id;
        
        cv.saveLoadFromTemplate();

        List<Call_Cycle_Template__c> callCycleTemplates = [SELECT ID, NAME FROM Call_Cycle_Template__c];

        //PageReference pageRef = Page.Call_Planning_Lightning;
        
        System.assert(callCycleTemplates.size() > 0); 
        test.stopTest();


    }

    


}