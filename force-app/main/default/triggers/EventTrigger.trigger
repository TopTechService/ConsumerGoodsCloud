trigger EventTrigger on Event (before insert, after insert, before update, after update) {
    
    //Id callTypeId = Utilities.getRecordTypeId('Event', 'Visit');    
    
   /* if(trigger.isBefore) { 
        
        Integer nm;
        Integer recordCounter = 0;
        Date twoWeekAgo = date.today().toStartOfWeek().addDays(-14);
        
        DayDateWeekCalculator calc = new DayDateWeekCalculator();        
        Map<Id, Objective__c> objMap = new Map<Id, Objective__c>();  
        
        list <Call_Cycle__c> callCycleList = [SELECT id, Reporting_Start_Date__c, Reporting_End_Date__c, Call_Cycle__c,Start_Date__c
                                                    FROM Call_Cycle__c
                                                    WHERE Location__c = 'Australia'
                                             		and End_Date__c >=: twoWeekAgo];
        
        
	    for(Event t : trigger.new) {
	        recordCounter++;
	        if(t.ActivityDate != null && t.WhatId != null ) {
	            
	            if( t.RecordTypeId == callTypeId ) {	
                    
                    //Convert the time to a local time to compare with CallCycle dates
                    //
                    Integer offset = UserInfo.getTimezone().getOffset(t.StartDateTime);
                    Datetime localStartDateTime = t.StartDateTime.addSeconds(offset/1000); 
	        
                    // There can be only one Planned Call per Account, per Day, Per Rep
                    IF(t.IsUnplanned__c == False)
	                t.Unique_Field__c = t.WhatId+'-'+t.ActivityDate +'-'+ t.OwnerId + '-' + t.IsUnplanned__c;
                    Else
                       t.Unique_Field__c = t.WhatId+'-'+ localStartDateTime +'-'+ t.OwnerId + '-' + t.IsUnplanned__c; 
	                
	                if(t.End_Date__c != null)
	                    t.End_Time__c = ''+t.End_Date__c.hour()+':'+t.End_Date__c.minute();
	                    
	                if(t.Start_Date__c != null)
	                    t.Start_Time__c = ''+t.Start_Date__c.hour()+':'+t.Start_Date__c.minute();   
	            
	               nm = math.MOD(date.newinstance(1900, 1, 7).daysBetween(t.ActivityDate),7);          
	                if(nm == 1){	                    
	                    t.Day__c = 'Mon';	                    
	                } else if(nm == 2){	                    
	                    t.Day__c = 'Tue';	                     
	                } else if(nm == 3){	                    
	                    t.Day__c = 'Wed';	                    
	                } else if(nm == 4){	                    
	                    t.Day__c = 'Thu';	                    
	                } else if(nm == 5){	                    
	                    t.Day__c = 'Fri';	                    
	                } else if(nm == 6){	                    
	                    t.Day__c = 'Sat';	                    
	                } else {	                    
	                    t.Day__c = 'Sun';	                    
	                }
                    
               
                    for(Call_Cycle__c ccl : callCycleList)
                    {
                        
                        system.debug('### localStartDateTime : ' + localStartDateTime);
                        if(ccl.Reporting_Start_Date__c <= localStartDateTime && ccl.Reporting_End_Date__c >= localStartDateTime)
                        {
                            t.Call_Cycle_Id__c = ccl.Id;
                            if( t.Type_Of_Call__c == 'Outlet Visit' && t.Subject.contains(', Week ') && t.Closed_Date_Time__c != null ) {
                            t.Subject = 'CC'+ccl.Call_Cycle__c.right(1)+', Week '+getWeek(t.Closed_Date_Time__c.date() , ccl);
                            }
                            
                        }
                    }
	                
	            } 
	           
	        }
        }
    }*/

/* Author : Eugene @ Carnac Group
* Created : 19/09/2019
* Description:
*   (88-182 lines) This code copies survey setup records to survey answer when creating an event associated with a call cycle.
* Also when creating suraey answer the type of account associated with the event is checked
*/
    /*if(trigger.isAfter && trigger.isInsert){
        Map<ID, List<Event>> eventMap = new Map<Id, List<Event>>();

        Set<Id> accIds = new Set<Id>();

        for(Event event : Trigger.new) {
            if (!eventMap.containsKey(event.Call_Cycle_Id__c)){
                eventMap.put(event.Call_Cycle_Id__c, new List<Event>());
            }
            accIds.add(event.AccountId);
            List<Event> lst = eventMap.get(event.Call_Cycle_Id__c);
            lst.add(event);
            eventMap.put(event.Call_Cycle_Id__c, lst);

        }

        List<Account> accounts = [SELECT id, Name, Channel__c FROM Account WHERE id IN : accIds];
        Map<Id, Account> accMap = new Map<Id, Account>();
        for(Account a : accounts){
            accMap.put(a.id, a);
        }

        List<Survey_Setup__c> surveys = [SELECT id, Name, Status__c, Question_Type__c, Question__c, Call_Cycle__c, Applicable_Channels__c, Question_order__c FROM Survey_Setup__c WHERE Call_Cycle__c IN : eventMap.keySet() AND Status__c =: 'Open'];

        List<Survey_Answer__c> answers = new List<Survey_Answer__c>();
        for(ID CurrentId : eventMap.keySet()){
            for(Event ev : eventMap.get(CurrentId)) {
                for(Survey_Setup__c setup : surveys) {
                    if (ev.Call_Cycle_Id__c == setup.Call_Cycle__c) {
                        if (setup.Applicable_Channels__c == 'All') {
                            Survey_Answer__c answer = new Survey_Answer__c();
                            answer.Question_Type__c = setup.Question_Type__c;
                            answer.Question__c = setup.Question__c;
                            answer.Question_order__c = setup.Question_order__c;
                            answer.EventID__c = ev.Id;
                            answer.Account__c = ev.AccountId;
                            answers.add(answer);
                        }
                        if (setup.Applicable_Channels__c == 'On-Premise' && accMap.get(ev.AccountId).Channel__c == 'On-Premise') {
                            Survey_Answer__c answer = new Survey_Answer__c();
                            answer.Question_Type__c = setup.Question_Type__c;
                            answer.Question__c = setup.Question__c;
                            answer.Question_order__c = setup.Question_order__c;
                            answer.EventID__c = ev.Id;
                            answer.Account__c = ev.AccountId;
                            answers.add(answer);
                        }
                        if (setup.Applicable_Channels__c == 'Off-Premise' && accMap.get(ev.AccountId).Channel__c == 'Off-Premise') {
                            Survey_Answer__c answer = new Survey_Answer__c();
                            answer.Question_Type__c = setup.Question_Type__c;
                            answer.Question__c = setup.Question__c;
                            answer.Question_order__c = setup.Question_order__c;
                            answer.EventID__c = ev.Id;
                            answer.Account__c = ev.AccountId;
                            answers.add(answer);
                        }
                        if (setup.Applicable_Channels__c == 'Hybrid' && accMap.get(ev.AccountId).Channel__c == 'Hybrid') {
                            Survey_Answer__c answer = new Survey_Answer__c();
                            answer.Question_Type__c = setup.Question_Type__c;
                            answer.Question__c = setup.Question__c;
                            answer.Question_order__c = setup.Question_order__c;
                            answer.EventID__c = ev.Id;
                            answer.Account__c = ev.AccountId;
                            answers.add(answer);
                        }
                        if (setup.Applicable_Channels__c == 'On-Premise & Hybrid') {
                            if(accMap.get(ev.AccountId).Channel__c == 'On-Premise' || accMap.get(ev.AccountId).Channel__c == 'Hybrid') {
                                Survey_Answer__c answer = new Survey_Answer__c();
                                answer.Question_Type__c = setup.Question_Type__c;
                                answer.Question__c = setup.Question__c;
                                answer.Question_order__c = setup.Question_order__c;
                                answer.EventID__c = ev.Id;
                                answer.Account__c = ev.AccountId;
                                answers.add(answer);
                            }
                        }
                        if (setup.Applicable_Channels__c == 'Off-Premise & Hybrid') {
                            if(accMap.get(ev.AccountId).Channel__c == 'Off-Premise' || accMap.get(ev.AccountId).Channel__c == 'Hybrid') {
                                Survey_Answer__c answer = new Survey_Answer__c();
                                answer.Question_Type__c = setup.Question_Type__c;
                                answer.Question__c = setup.Question__c;
                                answer.Question_order__c = setup.Question_order__c;
                                answer.EventID__c = ev.Id;
                                answer.Account__c = ev.AccountId;
                                answers.add(answer);
                            }
                        }

                    }
                }
            }

        }
        insert answers;
    }
    */
   /* if(trigger.isBefore && trigger.isUpdate) {
    	
    	   set <Id> EventIdActivityDateUpdatedSet = new set<Id>();
            
            //When Activity Date of Event Visit has been updated, then 
            // 1. subject should be updated according to the Activity Date (Week Number)
            // 2. A task should not be allowed to change Call Cycle
            //
            
            for(Event t : Trigger.new){
            	
                if( t.RecordTypeId == callTypeId && t.StartDateTime != trigger.oldMap.get(t.Id).StartDateTime )
                    EventIdActivityDateUpdatedSet.add(t.Id);
                    
            }
            
        	system.debug('### EventIdActivityDateUpdatedSet.size() : ' + EventIdActivityDateUpdatedSet.size());
            if(EventIdActivityDateUpdatedSet.size() > 0){
                
                // Get the range of call cycles the update is for.
                // Get the smallest min date & biggest end date
                date minDate, maxDate;
                minDate = maxDate = trigger.new[0].StartDateTime.date() ;
                 
                for(Id taskId : EventIdActivityDateUpdatedSet) {
                    
                    if(minDate < trigger.newMap.get(taskId).StartDateTime.date())
                       minDate = trigger.newMap.get(taskId).StartDateTime.date();
                       
                    if(maxDate > trigger.newMap.get(taskId).StartDateTime.date())
                       maxDate = trigger.newMap.get(taskId).StartDateTime.date();   
                    
                } 
                
                minDate = minDate.addDays(-49);
                system.debug('###minDate : ' + minDate);
                maxDate = maxDate.addDays(49);
                system.debug('###maxDate : ' + maxDate);
                
                list <Call_Cycle__c> callCycleList = [select id, Start_Date__c, End_Date__c, Call_Cycle__c
                                                      from Call_Cycle__c
                                                      where Location__c = 'Australia'
                                                      and Start_Date__c >=: minDate
                                                      and End_Date__c <=: maxDate];
                                                      
                //set <Id> subjectChanged = new set<Id>();  
                
                // Loop the Events being updated and the list of Call Cycles
    
                for(Id taskId : EventIdActivityDateUpdatedSet) {
                    
                    for(Call_Cycle__c cc : callCycleList) {
                        // Find the call cycle that matches the old version of the event
                        if(trigger.oldMap.get(taskId).StartDateTime.date()  >= cc.Start_Date__c 
                           && trigger.oldMap.get(taskId).StartDateTime.date()  <= cc.End_Date__c){
                 				// Check that the new date is still part of the call cycle
                               if(trigger.newMap.get(taskId).StartDateTime.date()  >= cc.Start_Date__c 
                           			&& trigger.newMap.get(taskId).StartDateTime.date()  <= cc.End_Date__c )
                               {   
                                	 trigger.newMap.get(taskId).Subject = 'CC'+cc.Call_Cycle__c.right(1)+', Week '+getWeek(trigger.newMap.get(taskId).StartDateTime.date() , cc);
                                     system.debug('### CC+cc.Call_Cycle__c.right(1)+, Week +getWeek(trigger.newMap.get(taskId).ActivityDate, cc) : ' + 'CC'+cc.Call_Cycle__c.right(1)+', Week '+getWeek(trigger.newMap.get(taskId).ActivityDate, cc) );            
                                	 
                               }
                               else { trigger.newMap.get(taskId).ActivityDate.addError('New Due Date does not belong to call cycle for which this meeting was created. MAx date is :' + cc.End_Date__c);
                                     return;}
                           }
                     
                    }
                    
                }                                      
                
                //
                //Check that ActivityDate of Call Cycle should remain in the Duration of the call cycle for which the call visit task was created
                //
                
                set <Id> callVisitWithErrors = new set<Id>();
                 
               for(Id taskId : EventIdActivityDateUpdatedSet) {
                	
                	//if(subjectChanged.contains(taskId)) {
                        
                        if(trigger.newMap.get(taskId).Subject.substring(0,3) != trigger.oldMap.get(taskId).Subject.substring(0,3)) {
                        	system.debug('## trigger.newMap.get(taskId).Subject.substring(0,3) : ' + trigger.newMap.get(taskId).Subject.substring(0,3));
                            system.debug('## trigger.oldMap.get(taskId).Subject.substring(0,3) : ' + trigger.oldMap.get(taskId).Subject.substring(0,3));
                            
                            trigger.newMap.get(taskId).ActivityDate.addError('New Due Date does not belong to call cycle for which this task had been defined.');
                            
                            callVisitWithErrors.add(taskId);
                        
                        }
                        
                }
                
                EventIdActivityDateUpdatedSet.removeAll(callVisitWithErrors);
                
                if(EventIdActivityDateUpdatedSet.size() > 0) {
                
                    list <Event> EventList = [select Id, ActivityDate, Subject, Call_Visit_Id__c
                                                     from Event
                                                     where Call_Visit_Id__c IN : EventIdActivityDateUpdatedSet
                                                     ];
                                                         
                    for(Event t : EventList){
                        
                        t.ActivityDate = trigger.newMap.get(t.Call_Visit_Id__c).ActivityDate;  
                        
                        //t.Subject = t.Subject.substring(0,t.subject.length() - 1) + trigger.newMap.get(t.Call_Visit_Id__c).Subject.substring(2,3);
                        
                        
                    }                        
                    
                    if(EventList.size() > 0)
                        update EventList;
                    
                }
            } 
        }*/
     
    
    /*Integer getWeek(Date dueDate, Call_Cycle__c cc){
    	
    	return (Integer)((Decimal) (cc.Start_Date__c.daysBetween(dueDate) + 1)).divide(7, 0, System.RoundingMode.CEILING);
    
    }*/
      
}