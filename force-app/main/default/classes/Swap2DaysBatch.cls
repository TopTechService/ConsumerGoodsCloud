public without sharing class Swap2DaysBatch implements Database.Batchable<SObject>{


    public List<Event> events;
    public String selectedCurrentOrFutureCallCycle;
    public String selectedDayFrom;
    public String selectedWeekFromDays;
    public String selectedDayTo;
    public String selectedWeekToDays;
    public DayDateWeekCalculator dayDateWeekCalculator;

    public Swap2DaysBatch(List<Event> events, String selectedDayFrom, String selectedWeekFromDays, String selectedDayTo, String selectedWeekToDays, String selectedCurrentOrFutureCallCycle, DayDateWeekCalculator dayDateWeekCalc){
        this.events = events;
        this.selectedCurrentOrFutureCallCycle = selectedCurrentOrFutureCallCycle;
        this.selectedDayFrom = selectedDayFrom;
        this.selectedWeekFromDays = selectedWeekFromDays;
        this.selectedDayTo = selectedDayTo;
        this.selectedWeekToDays = selectedWeekToDays;
        this.dayDateWeekCalculator = dayDateWeekCalc;
    }

    public Iterable<Event> start(Database.BatchableContext context) {
        System.debug('## Starting Batch');
        return events;
    }


    public void execute(Database.BatchableContext context, List<Event> events) {
        try {
            System.debug('## Execute Batch');
            System.debug('#### events' + json.serialize(events));
            
            List<Event> selectedWeekFromEvents = new List<Event>();
            List<Event> selectedWeekToEvents = new List<Event>();
            for(Event eventWeek : events){
                if(eventWeek.CC_Week__c == this.selectedWeekFromDays){
                    selectedWeekFromEvents.add(eventWeek);
                }

                if(eventWeek.CC_Week__c == this.selectedWeekToDays){
                    selectedWeekToEvents.add(eventWeek);
                }
            }

            Map<String, List<Event>> eventWeekFromMap = new Map<String, List<Event>>();
            for(Event e : selectedWeekFromEvents){
                String dayOfWeek = this.dayDateWeekCalculator.getDayOfWeek(e.ActivityDate); 
                
                system.debug('##dayOfWeek ' + dayOfWeek);
                system.debug('##selectedDayFrom ' + this.selectedDayFrom);
                if(dayOfWeek == this.selectedDayFrom){
                    
                    if(eventWeekFromMap.containsKey(dayOfWeek)){
                        eventWeekFromMap.get(dayOfWeek).add(e);
                    }
                    else{
                        eventWeekFromMap.put(dayOfWeek, new List<Event>{e});
                    }
                }
            }
            system.debug('#### eventWeekFromMap' + json.serialize(eventWeekFromMap));

            Map<String, List<Event>> eventWeekToMap = new Map<String, List<Event>>();
            for(Event eventWeekTo : selectedWeekToEvents){
                String dayOfWeek = this.dayDateWeekCalculator.getDayOfWeek(eventWeekTo.ActivityDate); 
                
                system.debug('##dayOfWeek ' + dayOfWeek);
                system.debug('##selectedDayTo ' + this.selectedDayTo);
                if(dayOfWeek == this.selectedDayTo){
                    
                    if(eventWeekToMap.containsKey(dayOfWeek)){
                        eventWeekToMap.get(dayOfWeek).add(eventWeekTo);
                    }
                    else{
                        eventWeekToMap.put(dayOfWeek, new List<Event>{eventWeekTo});
                    }
                }
            }
            system.debug('#### eventWeekToMap' + json.serialize(eventWeekToMap));

            List<String> weeks = new List<String>();
            weeks.add(this.selectedWeekFromDays.Right(1));
            weeks.add(this.selectedWeekToDays.Right(1));
            
            System.debug('#### this.selectedWeekFromDays.Right(1) ' + this.selectedWeekFromDays.Right(1));
            System.debug('#### this.selectedWeekToDays.Right(1) ' + this.selectedWeekToDays.Right(1));

            List<Call_Cycle_Week__c> callCycleWeeks = [SELECT Name, Week__c, Start_Date__c, End_Date__c, Call_Cycle__c, Call_Cycle__r.Start_Date__c, Call_Cycle__r.Call_Cycle__c, Call_Cycle__r.OwnerId 
                                                FROM Call_Cycle_Week__c WHERE Call_Cycle__c =: selectedCurrentOrFutureCallCycle AND Week__c IN: weeks];

            System.debug('#### callCycleWeeks' + json.serialize(callCycleWeeks));
            if(callCycleWeeks.size() == 0)
                return;


            Call_Cycle_Week__c callCycleWeekTo = new Call_Cycle_Week__c();
            Call_Cycle_Week__c callCycleWeekFrom = new Call_Cycle_Week__c();
            for(Call_Cycle_Week__c callCycleWeek : callCycleWeeks){
                if(callCycleWeek.Week__c == this.selectedWeekFromDays.Right(1)){
                    callCycleWeekFrom = callCycleWeek;
                }
                
                if(callCycleWeek.Week__c == this.selectedWeekToDays.Right(1)){
                    callCycleWeekTo = callCycleWeek;
                }
            }    
            
            system.debug('#### callCycleWeekTo' + json.serialize(callCycleWeekTo));
            system.debug('#### callCycleWeekFrom' + json.serialize(callCycleWeekFrom));

            List<Event> updateEvents = new List<Event>();
            List<Event> oldEventWeekFrom = eventWeekFromMap.get(this.selectedDayFrom);
            List<Event> oldEventWeekTo = eventWeekToMap.get(this.selectedDayTo);
            
            system.debug('#### oldEventWeekFrom ' + json.serialize(oldEventWeekFrom));
            system.debug('#### oldEventWeekTo ' + json.serialize(oldEventWeekTO));


            if(oldEventWeekFrom != null){
                Integer dayNumber = this.dayDateWeekCalculator.getNumberOfDay(this.selectedDayTo);
                system.debug('#### oldEventWeekFrom dayNumber' + dayNumber);
                Date activityDate = callCycleWeekTo.Start_Date__c.addDays(dayNumber-1);
                system.debug('#### oldEventWeekFrom activityDate' + activityDate);
                
                for(Event event : oldEventWeekFrom){
                    String relatedTo = event.Subject.subString(13, event.Subject.length());
                    event.Subject = 'CC' + callCycleWeekTO.Call_Cycle__r.Call_Cycle__c.right(1) + ', '+ callCycleWeekTO.Name + ' - ' + relatedTo;
                    event.ActivityDate = activityDate;
                    event.StartDateTime =  DateTime.newinstance(activityDate, event.StartDateTime.time());
                    updateEvents.add(event); 
                    System.debug('### Format Time: ' + DateTime.newinstance(activityDate, event.StartDateTime.time()).format());
                }

                system.debug('#### updateEvents FROM' + json.serialize(updateEvents));
            }

            if(oldEventWeekTo != null){
                Integer dayNumber = this.dayDateWeekCalculator.getNumberOfDay(this.selectedDayFrom);
                system.debug('#### oldEventWeekTo dayNumber' + dayNumber);
                Date activityDt = callCycleWeekFrom.Start_Date__c.addDays(dayNumber-1); 
                system.debug('#### oldEventWeekTo activityDate' + activityDt);
                
                for(Event eventTo : oldEventWeekTO){
                    String relatedTo = eventTo.Subject.subString(13, eventTo.Subject.length());
                    eventTo.Subject = 'CC' + callCycleWeekFrom.Call_Cycle__r.Call_Cycle__c.right(1) + ', '+ callCycleWeekFrom.Name + ' - ' + relatedTo;
                    eventTo.ActivityDate = activityDt;
                    eventTo.StartDateTime =  DateTime.newinstance(activityDt, eventTo.StartDateTime.time());
                    updateEvents.add(eventTo); 
                    
                    system.debug('#### eventTo.StartDateTime' + eventTo.StartDateTime);
                    system.debug('#### eventTo.StartDateTime.format(YYYY-MM-dd hh:mm:ss) ' + eventTo.StartDateTime.format('YYYY-MM-dd hh:mm:ss'));
                    
                }

                system.debug('#### updateEvents TO' + json.serialize(updateEvents));
            }

            system.debug('#### updateEvents' + json.serialize(updateEvents));


            if(updateEvents.size() > 0)
                update updateEvents;

        } 
        catch(Exception e) {
            System.debug('##Error Swap2DaysBatch batch' + e.getMessage());
        }
    }

    public void finish(Database.BatchableContext context) {
        try {
            System.debug('>> finish()');
        } catch (Exception ex) {
            System.debug('##Error Swap2DaysBatch' + ex.getMessage());
        }
    }

}