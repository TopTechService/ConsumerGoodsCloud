public without sharing class Swap2WeeksBatch implements Database.Batchable<SObject>{

    public List<Event> events;
    public String selectedCurrentOrFutureCallCycle;
    public String selectedWeekFrom;
    public String selectedWeekTo;
    public DayDateWeekCalculator dayDateWeekCalculator;

    public Swap2WeeksBatch(List<Event> events, String selectedWeekFrom, String selectedWeekTo, String selectedCurrentOrFutureCallCycle, DayDateWeekCalculator dayDateWeekCalc){
        this.events = events;
        this.selectedCurrentOrFutureCallCycle = selectedCurrentOrFutureCallCycle;
        this.selectedWeekFrom = selectedWeekFrom;
        this.selectedWeekTo = selectedWeekTo;
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
                if(eventWeek.CC_Week__c == this.selectedWeekFrom){
                    selectedWeekFromEvents.add(eventWeek);
                }

                if(eventWeek.CC_Week__c == this.selectedWeekTo){
                    selectedWeekToEvents.add(eventWeek);
                }
            }

            Map<String, List<Event>> eventWeekFromMap = new Map<String, List<Event>>();
            for(Event e : selectedWeekFromEvents){
                String dayOfWeek = this.dayDateWeekCalculator.getDayOfWeek(e.ActivityDate); 
                
                system.debug('##dayOfWeek ' + dayOfWeek);
  
                if(eventWeekFromMap.containsKey(dayOfWeek)){
                    eventWeekFromMap.get(dayOfWeek).add(e);
                }
                else{
                    eventWeekFromMap.put(dayOfWeek, new List<Event>{e});
                }
            }
            system.debug('#### eventWeekFromMap' + json.serialize(eventWeekFromMap));

            Map<String, List<Event>> eventWeekToMap = new Map<String, List<Event>>();
            for(Event eventWeekTo : selectedWeekToEvents){
                String dayOfWeek = this.dayDateWeekCalculator.getDayOfWeek(eventWeekTo.ActivityDate); 
                
                system.debug('##dayOfWeek ' + dayOfWeek);
               
                if(eventWeekToMap.containsKey(dayOfWeek)){
                    eventWeekToMap.get(dayOfWeek).add(eventWeekTo);
                }
                else{
                    eventWeekToMap.put(dayOfWeek, new List<Event>{eventWeekTo});
                }
                
            }
            system.debug('#### eventWeekToMap' + json.serialize(eventWeekToMap));

            List<String> weeks = new List<String>();
            weeks.add(this.selectedWeekFrom.Right(1));
            weeks.add(this.selectedWeekTo.Right(1));
            
            List<Call_Cycle_Week__c> callCycleWeeks = [SELECT Name, Week__c, Start_Date__c, End_Date__c, Call_Cycle__c, Call_Cycle__r.Call_Cycle__c, Call_Cycle__r.OwnerId FROM Call_Cycle_Week__c WHERE Call_Cycle__c =: selectedCurrentOrFutureCallCycle AND Week__c IN: weeks];

            Call_Cycle_Week__c callCycleWeekTO = new Call_Cycle_Week__c();
            Call_Cycle_Week__c callCycleWeekFrom = new Call_Cycle_Week__c();
            for(Call_Cycle_Week__c callCycleWeek : callCycleWeeks){
                if(callCycleWeek.Week__c == this.selectedWeekFrom.Right(1)){
                    callCycleWeekFrom = callCycleWeek;
                }
                else if(callCycleWeek.Week__c == this.selectedWeekTo.Right(1)){
                    callCycleWeekTo = callCycleWeek;
                }
            }    

            system.debug('#### callCycleWeekFrom' + json.serialize(callCycleWeekFrom));
            system.debug('#### callCycleWeekTO' + json.serialize(callCycleWeekTo));
            
            List<Date> dateOfWeekListWeekFrom = new List<Date>();
            if(callCycleWeekFrom != null){
                dateOfWeekListWeekFrom.add(callCycleWeekFrom.Start_Date__c);
                if(callCycleWeekFrom.Start_Date__c <= callCycleWeekFrom.End_Date__c){
                    for(integer i = 1; i <= 4; i++){
                        dateOfWeekListWeekFrom.add(callCycleWeekFrom.Start_Date__c.addDays(i));
                    }
                }
            }

            List<Date> dateOfWeekListWeekTo = new List<Date>();
            if(callCycleWeekTo != null){
                dateOfWeekListWeekTo.add(callCycleWeekTO.Start_Date__c);
                if(callCycleWeekTo.Start_Date__c <= callCycleWeekTo.End_Date__c){
                    for(integer i = 1; i <= 4; i++){
                        dateOfWeekListWeekTo.add(callCycleWeekTo.Start_Date__c.addDays(i));
                    }
                }
            }

            system.debug('#### eventWeekFromMap' + json.serialize(eventWeekFromMap));
            system.debug('#### eventWeekToMap' + json.serialize(eventWeekToMap));
            system.debug('#### dateOfWeekListWeekFrom' + json.serialize(dateOfWeekListWeekFrom));
            system.debug('#### dateOfWeekListWeekTo' + json.serialize(dateOfWeekListWeekTo));

            if(events.size() == 0)
                    return;

            List<Event> updateEvents = new List<Event>();
            for(Date dateOfWeek : dateOfWeekListWeekFrom){ 
                String day = dayDateWeekCalculator.getDayOfWeek(dateOfWeek);
                List<Event> oldEvent = eventWeekFromMap.get(day);
                system.debug('#### oldEvent' + json.serialize(oldEvent));
    
                if(oldEvent != null){
                    Integer dayNumber = dayDateWeekCalculator.getNumberOfDay(day);
                    Date activityDate = callCycleWeekTo.Start_Date__c.addDays(dayNumber-1); 
                    system.debug('#### activityDate FROM' + activityDate);

                    for(Event event : oldEvent){
                        String relatedTo = event.Subject.subString(13, event.Subject.length());
                        event.Subject = 'CC' + callCycleWeekTo.Call_Cycle__r.Call_Cycle__c.right(1) + ', '+ callCycleWeekTo.Name + ' - ' + relatedTo;
                        event.ActivityDate = activityDate;
                        event.StartDateTime =  DateTime.newinstance(activityDate, event.StartDateTime.time());
                        updateEvents.add(event); 
                    }
                }
            }    

            for(Date dateOfWeek : dateOfWeekListWeekTo){ 
                String day = dayDateWeekCalculator.getDayOfWeek(dateOfWeek);
                List<Event> oldEvent = eventWeekToMap.get(day);
                system.debug('#### oldEvent' + json.serialize(oldEvent));
    
                if(oldEvent != null){
                    Integer dayNumber = dayDateWeekCalculator.getNumberOfDay(day);
                    Date activityDate = callCycleWeekFrom.Start_Date__c.addDays(dayNumber-1); 
                    system.debug('#### activityDate' + activityDate);
                    
                    for(Event event : oldEvent){
                        String relatedTo = event.Subject.subString(13, event.Subject.length());
                        event.Subject = 'CC' + callCycleWeekFrom.Call_Cycle__r.Call_Cycle__c.right(1) + ', '+ callCycleWeekFrom.Name + ' - ' + relatedTo;
                        event.ActivityDate = activityDate;
                        event.StartDateTime =  DateTime.newinstance(activityDate, event.StartDateTime.time());
                        updateEvents.add(event); 
                    }
                }
            }  

            system.debug('#### updateEvents' + json.serialize(updateEvents));
            if(updateEvents.size() > 0)
                update updateEvents;


        } 
        catch(Exception e) {
            System.debug('##Error Swap2WeeksBatch batch' + e.getMessage());
        }
    }

    public void finish(Database.BatchableContext context) {
        try {
            System.debug('>> finish()');
        } catch (Exception ex) {
            System.debug('##Error List<Event> events' + ex.getMessage());
        }
    }
    
}