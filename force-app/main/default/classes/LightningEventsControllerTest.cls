@IsTest
public with sharing class LightningEventsControllerTest {

    @TestSetup
    private static void createTestData() {
        Event event = new Event(
            StartDateTime = System.now().addHours(1),
            EndDateTime = System.now().addHours(2),
            OwnerId = UserInfo.getUserId(),
            Type_of_Call__c = 'Phone Call'
        );
        insert event;

        event = new Event(
            StartDateTime = System.now().addDays(1),
            EndDateTime = System.now().addDays(1).addHours(1),
            OwnerId = UserInfo.getUserId(),
            Type_of_Call__c = 'Phone Call'
        );
        insert event;
    }

    @IsTest
    private static void getEventsCountTest() {
        Map<String, Integer> events = LightningEventsController.getEventsCount();

        System.assertEquals(1, events.get('today'));
        System.assertEquals(1, events.get('tomorrow'));
        System.assertEquals(2, events.get('week'));
        System.assertEquals(2, events.get('month'));
    }

    @IsTest
    private static void getEventsTest() {
        List<Event> events = LightningEventsController.getEvents('today');
        System.assertEquals(1, events.size());

        events = LightningEventsController.getEvents('tomorrow');
        System.assertEquals(1, events.size());

        events = LightningEventsController.getEvents('week');
        System.assertEquals(2, events.size());

        events = LightningEventsController.getEvents('month');
        System.assertEquals(2, events.size());
    }

    @IsTest
    private static void InsertEventTest() {
        Event event = new Event(
            Subject = 'CC1, Week2',
            StartDateTime = System.now().addDays(1),
            EndDateTime = System.now().addDays(1).addHours(1),
            OwnerId = UserInfo.getUserId(),
            Type_of_Call__c = 'Outlet Visit'
        );
        insert event;
    }
    
    @IsTest
    private static void InsertAndUpdateEventTest() {
        Event event = new Event(
             Subject = 'CC1, Week 2',
            StartDateTime = System.now().addDays(1),
            EndDateTime = System.now().addDays(1).addHours(1),
            OwnerId = UserInfo.getUserId(),
            Type_of_Call__c = 'Outlet Visit'
        );
        insert event;
        
        event.StartDateTime = System.now().addDays(60);
        event.EndDateTime = System.now().addDays(60).addHours(1);
        update event;
    }
}