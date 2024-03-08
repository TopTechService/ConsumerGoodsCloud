trigger CallCycleTrigger on Call_Cycle__c (after insert, after update) {
    CallCyleTriggerHandler.execute();   
}