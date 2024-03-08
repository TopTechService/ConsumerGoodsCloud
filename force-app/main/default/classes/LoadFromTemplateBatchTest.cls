@isTest
private class LoadFromTemplateBatchTest {
    @testSetup
    static void setup() {

        Account account = new Account();
		String recTypeId = Utilities.getRecordTypeId('Account','Outlet');
		account = TestFactory.getAccount('ALM outlet', recTypeId);

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
     
    }

    @isTest 
    static void executeTest(){

        List<Call_Cycle_Template__c> callCycleTemplates = [SELECT Id, Assigned_To__c,CC_Week__c, Start_Date_Time__c, Day_of_the_Week__c, Type_of_Call__c, Related_To__c, Subject__c FROM Call_Cycle_Template__c];

        Call_Cycle__c callCycle = [SELECT id, Start_Date__c FROM Call_Cycle__c LIMIT 1];

        User currentUser = [Select id, Country from User where Id =: UserInfo.getUserId()];    
        DayDateWeekCalculator dayDateWeekCalc = new DayDateWeekCalculator(currentUser.Country.toLowerCase());

        Test.startTest();
        LoadFromTemplateBatch batch = new LoadFromTemplateBatch(callCycleTemplates, callCycle, dayDateWeekCalc);
        Id jobId = Database.executeBatch(batch, 100);
        Test.stopTest();
        

        System.assertNotEquals(0, [SELECT count() FROM Event WHERE OwnerId =: callCycleTemplates[0].Assigned_To__c]);
    }
}