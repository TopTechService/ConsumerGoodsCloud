public without sharing class LoadFromTemplateBatch implements Database.Batchable<SObject>{

    public Call_Cycle__c callCycle;
    public List<Call_Cycle_Template__c> callCycleTemplates;
    public DayDateWeekCalculator dayDateWeekCalculator;

    public LoadFromTemplateBatch(List<Call_Cycle_Template__c> callCycleTemplateList, Call_Cycle__c callCycle, DayDateWeekCalculator dayDateWeekCalc){
        this.callCycle = callCycle;
        this.callCycleTemplates = callCycleTemplateList;
        this.dayDateWeekCalculator = dayDateWeekCalc;
    }

    public Iterable<Call_Cycle_Template__c> start(Database.BatchableContext context) {
        System.debug('## Starting Batch');
        return callCycleTemplates;
    }


    public void execute(Database.BatchableContext context, List<Call_Cycle_Template__c> callCycleTemplates) {
        try {
            System.debug('## Execute Batch - Load from Template');

            List<Event> events = new List<Event>();
            for(Call_Cycle_Template__c callCycleTemplate : callCycleTemplates){
                Integer dayNumber = this.dayDateWeekCalculator.getNumberOfDay(callCycleTemplate.Day_of_the_Week__c);
                Date activityDate = this.dayDateWeekCalculator.getActivityDate(dayNumber-1, 'Week ' + callCycleTemplate.CC_Week__c, callCycle.Start_Date__c); 
                system.debug('#### callCycle.Start_Date__c ' + callCycle.Start_Date__c);
                system.debug('#### here activityDate' + activityDate);

                //Create a event
                Event event = new Event();
                event.OwnerId = callCycleTemplate.Assigned_To__c;
                event.Type_of_Call__c = callCycleTemplate.Type_of_Call__c;
                event.RecordTypeId = Utilities.getRecordTypeId('event', 'Visit');
                event.Subject = callCycleTemplate.Subject__c;
                event.WhatId = callCycleTemplate.Related_To__c;
                event.Call_Cycle_Id__c = this.callCycle.Id;
                event.ActivityDate = activityDate;
                event.StartDateTime = DateTime.newinstance(activityDate, Datetime.now().Time());
                event.DurationInMinutes = 90;
                event.Status__c = 'Not Started';
                event.IsUnplanned__c = false;

                events.add(event);
            }

            system.debug('#### events' + json.serialize(events));

            if(events.size() > 0)
                upsert events;

        } 
        catch(Exception e) {
            System.debug('##Error saveLoadFromTemplate batch' + e.getMessage());
        }
    }

    public void finish(Database.BatchableContext context) {
        try {
            System.debug('>> finish()');
        } catch (Exception ex) {
            System.debug('##Error saveLoadFromTemplate' + ex.getMessage());
        }
    }

}