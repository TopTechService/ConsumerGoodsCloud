@isTest
private class Swap2WeeksBatchTest {
    @testSetup
    static void setup() {

        Account account = new Account();
		String recTypeId = Utilities.getRecordTypeId('Account','Outlet');
		account = TestFactory.getAccount('ALM outlet', recTypeId);

        Call_Cycle__c callCycle = new Call_Cycle__c(
            Name = 'Test Call Cycle',
            Call_cycle__c = 'Test Call Cycle',
            Start_date__c = Date.newInstance(2023, 11, 27),
            End_date__c = Date.newInstance(2023, 12, 8),
            Reporting_Start_Date__c = Date.newInstance(2023, 11, 27),
            Reporting_End_Date__c = Date.newInstance(2023, 12, 8),
            Location__c = 'Australia'
        );        
        insert callCycle;  

        Call_Cycle_Week__c callCycleWeek = new Call_Cycle_Week__c(
            Name = 'Week 1',
            Week__c = '1',
            Call_Cycle__c = callCycle.Id,
            Start_date__c = Date.today(),
            End_date__c = Date.today().addDays(6)
        );        
        insert callCycleWeek;  

        Event event = new Event(
            Subject = 'Test - Week 1',
            CC_Week__c = 'Week 1',
            ActivityDate = Date.today(),
            DurationInMinutes = 60,
            StartDateTime = system.now(),
            Call_Cycle_Id__c = callCycle.Id,
            OwnerId = UserInfo.getUserId(),
            WhatId = account.Id
        );
        insert event;

        Event event2 = new Event(
            Subject = 'Test - Week 2',
            CC_Week__c = 'Week 2',
            ActivityDate = Date.today().addDays(2),
            DurationInMinutes = 60,
            StartDateTime = system.now(),
            Call_Cycle_Id__c = callCycle.Id,
            OwnerId = UserInfo.getUserId(),
            WhatId = account.Id
        );
        insert event2;
     
    }

    @isTest 
    static void executeTest(){

        List<Event> events = [SELECT Id, Subject, CC_Week__c, ActivityDate, StartDateTime, WhatId, Call_Cycle_Id__r.Name, OwnerId FROM Event ORDER BY ActivityDate];

        User currentUser = [Select id, Country from User where Id =: UserInfo.getUserId()];    
        DayDateWeekCalculator dayDateWeekCalc = new DayDateWeekCalculator(currentUser.Country.toLowerCase());

        Test.startTest();
        Swap2WeeksBatch batch = new Swap2WeeksBatch(events, 'Week 2', 'Week 1',Events[0].Call_Cycle_Id__c, dayDateWeekCalc);
        Id jobId = Database.executeBatch(batch, 100);
        Test.stopTest();
        

        System.assertNotEquals(0, [SELECT count() FROM Event WHERE OwnerId =: events[0].OwnerId]);
    }
}