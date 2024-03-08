public without sharing class SaveToTemplateBatch implements Database.Batchable<SObject>, Database.Stateful{

    public List<Event> events;
    public DayDateWeekCalculator dayDateWeekCalculator;

    public SaveToTemplateBatch(List<Event> events){
        this.events = events;
        this.dayDateWeekCalculator = new DayDateWeekCalculator();
    }

    public Iterable<Event> start(Database.BatchableContext context) {
        System.debug('## Starting Batch');
        return events;
    }


    public void execute(Database.BatchableContext context, List<Event> events) {
        try {
            System.debug('## Execute Batch');
            system.debug('#### events' + json.serialize(events));  

            List<Call_Cycle_Template__c> callCycleTemplates = new List<Call_Cycle_Template__c>();
            for(Event event : events){
                Call_Cycle_Template__c callCycleTemplate = new Call_Cycle_Template__c();
                callCycleTemplate.Name = event.Subject;
                callCycleTemplate.Subject__c = event.Subject;
                callCycleTemplate.Start_Date_Time__c = event.StartDateTime;
                callCycleTemplate.Day_of_the_Week__c = this.dayDateWeekCalculator.getDayOfWeek(event.StartDateTime.Date());
                callCycleTemplate.Assigned_To__c = event.OwnerId;
                callCycleTemplate.CC_Week__c = event.CC_week__c != null ? event.CC_week__c.Right(1) : '';
                callCycleTemplate.Related_To__c = event.WhatId;

                callCycleTemplates.add(callCycleTemplate);
            }

            system.debug('#### callCycleTemplates' + json.serialize(callCycleTemplates));      

            if(callCycleTemplates.size() > 0)
                insert callCycleTemplates;           

        } 
        catch(Exception e) {
            System.debug('##Error saveTemplate batch' + e.getMessage());
        }
    }

    public void finish(Database.BatchableContext context) {
        try {
            System.debug('>> finish()');
        } catch (Exception ex) {
            System.debug('##Error saveTemplate' + ex.getMessage());
        }
    }

}