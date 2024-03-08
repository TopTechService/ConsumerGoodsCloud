/**
 * @author    : Created by Geeta Kushwaha on 23 Apr, 2013  geeta.kushwaha@arxxus.com
 * @Purpose   : Test Class for PopulateDayOnTask Trigger
 * @Criteria  : 
 * @Modified  : Last Modified by Geeta Kushwaha on 22 May, 2013
 */
@isTest
public class PopulateDayOnTaskTest {

    /*the static testMethod void checkDaysTest() {
         
        Account acc = TestFactory.getAccount('Outlet 1', Utilities.getRecordTypeId('Account', 'Outlet'));
        
        insert acc;
        
        Id callVisitRecType = Utilities.getRecordTypeId('Task', 'Standard Task');
        
        Task tMon = TestFactory.getTask('Other', acc.Id, date.newInstance(2013,4,22), callVisitRecType, 'In Progress');
        
        insert tMon;
        
        Task tTue = TestFactory.getTask('Other', acc.Id, date.newInstance(2013,4,23), callVisitRecType, 'In Progress');
        
        insert tTue;
        
        Task tWed = TestFactory.getTask('Other', acc.Id, date.newInstance(2013,4,24), callVisitRecType, 'In Progress');
        
        insert twed;
        
        Task tThu = TestFactory.getTask('Other', acc.Id, date.newInstance(2013,4,25), callVisitRecType, 'In Progress');
        
        insert tThu;
        
        Task tFri = TestFactory.getTask('Other', acc.Id, date.newInstance(2013,4,26), callVisitRecType, 'In Progress');
        
        insert tFri;
        
        Task tSat = TestFactory.getTask('Other', acc.Id, date.newInstance(2013,4,27), callVisitRecType, 'In Progress');
        
        insert tSat;
        
        Task tSun = TestFactory.getTask('Other', acc.Id, date.newInstance(2013,4,28), callVisitRecType, 'In Progress');
        
        insert tSun;
        
        test.startTest();
        
        Task tMon1 = [Select Id, Day__c
                      from Task where Id =: tMon.Id];
                      
        System.assertEquals(tMon1.Day__c,'Mon');              
        
        Task tTue1 = [Select Id, Day__c
                      from Task where Id =: tTue.Id];
                      
        System.assertEquals(tTue1.Day__c,'Tue');              
        
        
        Task tWed1 = [Select Id, Day__c
                      from Task where Id =: tWed.Id];
                      
        System.assertEquals(tWed1.Day__c,'Wed');              
        
        
        Task tThu1 = [Select Id, Day__c
                      from Task where Id =: tThu.Id];
                      
        System.assertEquals(tThu1.Day__c,'Thu');              
        
        
        Task tFri1 = [Select Id, Day__c
                      from Task where Id =: tFri.Id];
                      
        System.assertEquals(tFri1.Day__c,'Fri');              
        
        Task tSat1 = [Select Id, Day__c
                      from Task where Id =: tSat.Id];
                      
        System.assertEquals(tSat1.Day__c,'Sat');   
        
        Task tSun1 = [Select Id, Day__c
                      from Task where Id =: tSun.Id];
                      
        System.assertEquals(tSun1.Day__c,'Sun');   
                 
        
        test.stopTest();
        
        
    }*/
    
    static testMethod void oneTaskPerDayPerAccountTest() {
        
        Account acc = TestFactory.getAccount('Outlet 1', Utilities.getRecordTypeId('Account', 'Outlet'));
        
        insert acc;
        
        Id callVisitRecType = Utilities.getRecordTypeId('Task', 'Standard Task');
        
        test.startTest();
        
        Task t1 = TestFactory.getTask('Other', acc.Id, null, callVisitRecType, 'In Progress');
        
        insert t1;
        
        Task t2 = TestFactory.getTask('Other', acc.Id, null, callVisitRecType, 'In Progress');
        
        insert t2;
        
        Task t3 = TestFactory.getTask('Other', acc.Id, date.newInstance(2013,4,24), callVisitRecType, 'In Progress');
        
        insert t3;
        
        Task t4 = TestFactory.getTask('Other', acc.Id, date.newInstance(2013,4,24), callVisitRecType, 'In Progress');
        
        try {
            
            insert t4;
        
        }
        
        catch(DMLException e) {
        	
        }
        
        System.assertNotEquals(t4.id,null);
        
        Task t5 = TestFactory.getTask('Other', acc.Id, date.newInstance(2013,4,25), callVisitRecType, 'In Progress');
        
        insert t5;
        
        test.stopTest();
        
    }
    
    static testMethod void uniqueFieldTestTask() {
    
        Account acc = TestFactory.getAccount('Outlet 1', Utilities.getRecordTypeId('Account', 'Outlet'));
        
        insert acc;
        
        Id objectiveRecType = Utilities.getRecordTypeId('Task', 'Objective');
        
        Objective__c obj1 = TestFactory.getObjective('Objective 1', null, 'National Objective', null, null, '1');
        
        insert obj1;
        
        Objective__c obj2 = TestFactory.getObjective('Objective 2', null, 'National Objective', null, null,'2');
        
        insert obj2;
        
        test.startTest();
        
        
        Task t3 =  TestFactory.getTask('Other', acc.Id, null, objectiveRecType, 'In Progress');
        
        t3.Objective_Id__c = obj1.Id;
        
        insert t3;
        
        Task t4 =  TestFactory.getTask('Other', acc.Id, date.newInstance(2013,4,24), objectiveRecType, 'In Progress');
        
        t4.Objective_Id__c = obj2.Id;
        
        insert t4;
        
        List <Task> uniqueFieldTaskList = [Select Id, Unique_Field__c
                                           from Task
                                           where Task.Unique_Field__c != null];
        
        set <Id> taskId = new set<Id>();
        
        for(Task t : uniqueFieldTaskList)        
        
            taskId.add(t.Id);  
        
        /*List <Event> uniqueFieldEventList = [Select Id, Unique_Field__c
                                           from Event
                                           where Unique_Field__c != null];
        
        set <Id> eventID = new set<Id>();
        
        for(Event t : uniqueFieldEventList)        
        
            eventID.add(t.Id);*/
                
        System.assertEquals(true, taskId.contains(t4.Id));
                
        System.assertEquals(false, taskId.contains(t3.Id));  

        t4.Status = 'Executed';
        
        //update t4;
        
        t4.ActivityDate = date.today();
        
        try {
        
            update t4;
            
        }
        
        catch(DMLException e) {
        }
        
        Task t41 = [Select ActivityDate
                    from Task
                    where Id =: t4.Id];
                    
        System.assertEquals(t41.ActivityDate, date.today());                            
        
        test.stopTest();
    }
    
    static testMethod void uniqueFieldTestEvent() {
    
        Account acc = TestFactory.getAccount('Outlet 1', Utilities.getRecordTypeId('Account', 'Outlet'));
        
        insert acc;
        
        Id callVisitRecType = Utilities.getRecordTypeId('Event', 'Visit');
                
        Objective__c obj1 = TestFactory.getObjective('Objective 1', null, 'National Objective', null, null, '1');
        
        insert obj1;
        
        Objective__c obj2 = TestFactory.getObjective('Objective 2', null, 'National Objective', null, null,'2');
        
        insert obj2;
        
        test.startTest();
        
        Event t1 = TestFactory.getEvent('Other', acc.Id, date.newInstance(2013,4,23), callVisitRecType, 'In Progress');
        t1.Unique_Field__c = 'xxxt1';
        insert t1;
        
        Event t2 = TestFactory.getEvent('Other', acc.Id, date.newInstance(2013,4,24), callVisitRecType, 'In Progress');
        t2.Unique_Field__c = 'xxxt2';
        insert t2;
        

        
        List <Event> uniqueFieldEventList = [Select Id, Unique_Field__c
                                           from Event
                                           where Unique_Field__c != null];
        
        set <Id> eventID = new set<Id>();
        
        for(Event t : uniqueFieldEventList)        
        
            eventID.add(t.Id);
                
        System.assertEquals(true, eventID.contains(t1.Id));
        

 
        test.stopTest();
    }
    
    static testMethod void completeTaskTest() {
        
        Account acc = TestFactory.getAccount('Outlet 1', Utilities.getRecordTypeId('Account', 'Outlet'));
        
        insert acc;
        
        Id callVisitRecType = Utilities.getRecordTypeId('Task', 'Standard Task');
        Id objectiveRecType = Utilities.getRecordTypeId('Task', 'Objective');
        
        Objective__c obj2 = TestFactory.getObjective('Objective 2', null, 'National Objective', null, null,'2');
        
        insert obj2;
        
        test.startTest();
        
        Task t1 = TestFactory.getTask('Other', acc.Id, null, callVisitRecType, 'In Progress');
        t1.Objective_Setting__c = obj2.id;
        insert t1;
        
        Task t2 = TestFactory.getTask('Other', acc.Id, null, objectiveRecType, 'In Progress');
        
        insert t2;
        
        t1.Status = 'Executed';
        update t1;
        
        t2.Status = 'Executed';
        update t2;
    }
    
    static testMethod void updateDateTaskTest() {
        
        Account acc = TestFactory.getAccount('Outlet 1', Utilities.getRecordTypeId('Account', 'Outlet'));
        
        insert acc;
        
        Id callVisitRecType = Utilities.getRecordTypeId('Event', 'Visit');
        Id objectiveRecType = Utilities.getRecordTypeId('Task', 'Objective');
            
        Objective__c obj1 = TestFactory.getObjective('Objective 2', null, 'National Objective', null, null,'5') ;           
        Call_Cycle__c testCC = new Call_Cycle__c(
        						name = 'CC11',
        						call_cycle__c = 'CC1',
        						start_date__c = date.newInstance(2013,5 ,6),
        						end_date__c = date.newInstance(2013,6,21),
        						location__c = 'Australia'
        						);        
        insert testCC;        
        
        obj1.Call_Cycle__c = testCC.Id;       
        obj1.Channel__c = 'All';
        obj1.End_Date__c = testCC.end_date__c;
        obj1.Start_Date__c = testCC.Start_Date__c;
        insert obj1;        
        
        test.startTest();
        
        Event t1 = TestFactory.getEvent('CC1', acc.Id, date.newInstance(2013,5,24), callVisitRecType, 'In Progress');
        //t1.Objective_Setting__c = obj1.id;
        t1.Subject = 'CC1';
        t1.DurationInMinutes = 3600;
        t1.StartDateTime = t1.activityDate + 6/24;
        insert t1;
        system.debug('### T1 :' + t1);

        t1.ActivityDate = date.newInstance(2013,5,25);
        update t1;
        
        delete t1;

    }
}