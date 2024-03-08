@isTest
public class CallCyleTriggerHandlerTest {

    @isTest 
    static void insertTest(){

        Test.startTest();

        Call_Cycle__c callCycle = new Call_Cycle__c(
            Name = 'Test Call Cycle',
            Call_cycle__c = 'Test Call Cycle',
            Start_date__c = Date.newInstance(2023, 11, 20),
            End_date__c = Date.newInstance(2023, 12, 8),
            Location__c = 'Australia'
        );        
        insert callCycle;  

        Test.stopTest();
        

        System.assertNotEquals(0, [SELECT count() FROM Call_Cycle__c]);
    } 
}