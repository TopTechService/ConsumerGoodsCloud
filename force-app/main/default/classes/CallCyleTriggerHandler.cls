public with sharing class CallCyleTriggerHandler {
    
    public static void execute() {
        if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
            List<Call_Cycle__c> callCycles = new List<Call_Cycle__c>(); 
            Set<Id> callCycleIds = new Set<Id>();
            for (Call_Cycle__c callCycle : (List<Call_Cycle__c>) Trigger.new) {

                Call_Cycle__c oldCallCycle = new Call_Cycle__c();
                if(Trigger.isUpdate){
                    oldCallCycle = (Call_Cycle__c)Trigger.oldMap.get(callCycle.Id);
                }
                
                if(callCycle.Start_Date__c != null && callCycle.End_Date__c != null && (callCycle.Start_Date__c != oldCallCycle.Start_Date__c || callCycle.End_Date__c != oldCallCycle.End_Date__c)){
                    callCycles.add(callCycle); 
                    callCycleIds.add(callCycle.Id); 
                }  
            }

            system.debug('##callCycles' + json.serialize(callCycles));
            if(!callCycles.isEmpty()){
                deleteCallCycleWeeks(callCycleIds);
                insertCallCycleWeeks(callCycles);
            }
        }
    }

    private static void deleteCallCycleWeeks(Set<Id> callCycleIds){
        List<Call_Cycle_Week__c> callCycleWeeks = [SELECT Id, Name FROM Call_Cycle_Week__c WHERE Call_Cycle__c =: callCycleIds];

        if(!callCycleWeeks.isEmpty()){
            delete callCycleWeeks;
        }
    }

    private static void insertCallCycleWeeks(List<Call_Cycle__c> callCycles){
        List<Call_Cycle_Week__c> callCycleWeeks = new List<Call_Cycle_Week__c>();
        
        for(Call_Cycle__c cc :  callCycles){
            Integer days = 7;
            for(Integer week = 1; week <= cc.Number_Of_Weeks__c; week++){
                Call_Cycle_Week__c callCycleWeek = new Call_Cycle_Week__c();
                callCycleWeek.Name = 'Week ' + week;
                callCycleWeek.Week__c = String.valueOf(week);
                callCycleWeek.Call_Cycle__c = cc.Id;
                
                if(week == 1){
                    callCycleWeek.Start_Date__c = cc.Start_Date__c;
                    callCycleWeek.End_Date__c = cc.Start_Date__c.addDays(6);
                }
                else{
                    if(week > 2){
                        days += 7;
                    }

                    callCycleWeek.Start_Date__c = cc.Start_Date__c.addDays(days);
                    callCycleWeek.End_Date__c = callCycleWeek.Start_Date__c.addDays(6);
                }   
                
                callCycleWeeks.add(callCycleWeek);
            }            
        }

        system.debug('##callCycleWeeks' + json.serialize(callCycleWeeks));
        if(!callCycleWeeks.isEmpty()){
            insert callCycleWeeks;
        }
    }
}