@isTest
private class SaveToTemplateBatchTest {
    @testSetup
    static void setup() {

        Account account = new Account();
		String recTypeId = Utilities.getRecordTypeId('Account','Outlet');
		account = TestFactory.getAccount('ALM outlet', recTypeId);

        Call_Cycle__c callCycle = new Call_Cycle__c(
            Name = 'Test Call Cycle',
            Call_cycle__c = 'Test Call Cycle',
            Start_date__c = Date.newInstance(2023, 11, 20),
            End_date__c = Date.newInstance(2023, 12, 8),
            Location__c = 'Australia'
        );        
        insert callCycle;  

        Event event = new Event(
            Subject = 'Test',
            CC_Week__c = 'Week 1',
            ActivityDate = Date.today(),
            DurationInMinutes = 60,
            StartDateTime = system.now(),
            Call_Cycle_Id__c = callCycle.Id,
            OwnerId = UserInfo.getUserId(),
            WhatId = account.Id
        );
        insert event;
     
    }

    @isTest 
    static void executeTest(){

        List<Event> events = [SELECT Id, Subject, CC_Week__c, ActivityDate, StartDateTime, WhatId, Call_Cycle_Id__r.Name, OwnerId FROM Event ORDER BY ActivityDate];

        User currentUser = [Select id, Country from User where Id =: UserInfo.getUserId()];    
        DayDateWeekCalculator dayDateWeekCalc = new DayDateWeekCalculator(currentUser.Country.toLowerCase());

        Test.startTest();
        SaveToTemplateBatch batch = new SaveToTemplateBatch(events);
        Id jobId = Database.executeBatch(batch, 100);
        Test.stopTest();
        

        System.assertNotEquals(0, [SELECT count() FROM Call_Cycle_Template__c WHERE Assigned_To__c =: events[0].OwnerId]);
    }
}