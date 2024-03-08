trigger PopulateDayOnTask on Task (before insert, before update) {
    
    Set<Id> objectiveIdSet = new Set<Id>();
    
    if(trigger.isBefore) { 
       
        system.debug('isBefore');
        DayDateWeekCalculator calc = new DayDateWeekCalculator();        
        Integer nm;        
        Map<Id, Objective__c> objMap = new Map<Id, Objective__c>();  
        Set<id> ObjSettList = new Set<id>();
        Integer recordCounter = 0;
	    
        for(Task t : trigger.new) {

            recordCounter++;
	        
            ///////////////////Replace process builder///////////////////
            t.Status__c = t.Status;
            if(t.Objective_Id__c != null && t.Objective_Setting__c == null) {
                 try{
                   	t.Objective_Setting__c = t.Objective_Id__c;
                 }
            	catch(exception e){
                	system.debug('Error: ' + e);
            	}
          	}
            
            if(t.isClosed == FALSE && t.Objective_Setting__c != null) { 
                	if(t.Objective_Setting__r.Category_of_Objective__c == 'Activation - DOTM'){
               			t.Activation_Type__c ='DOTM';}
                    t.Deal_1__c = t.Objective_Setting__r.Deal_1__c;
                    t.Deal_2__c = t.Objective_Setting__r.Deal_2__c;
                    t.Deal_3__c = t.Objective_Setting__r.Deal_3__c;
                    t.Distribution_1__c = t.Objective_Setting__r.Distribution_1__c;
                    t.Distribution_2__c = t.Objective_Setting__r.Distribution_2__c;
                    t.Distribution_3__c = t.Objective_Setting__r.Distribution_3__c;
                    t.Program_Name__c = t.Objective_Setting__r.Program_Name__c;
                    t.SRP_1__c = t.Objective_Setting__r.SRP_1__c;
                    t.Training_Brand__c = t.Objective_Setting__r.Training_Brand__c;
                    t.Volume_Product_1__c = t.Objective_Setting__r.Activation_1__c;
                    t.Volume_Product_2__c = t.Objective_Setting__r.Activation_2__c;
                    t.Volume_Product_3__c = t.Objective_Setting__r.Activation_3__c;                    
            }
            if(t.Description != null && t.Completion_Comments__c == null){
                if(t.Description.length() > 254){
                	t.Completion_Comments__c = t.Description.substring(0,254);
                }else{
                    t.Completion_Comments__c = t.Description;
                }
            }
            
            
            //////////////////////////////////////////////////////////////
            
            if(t.ActivityDate != null && t.Objective_Setting__c != null) {    
               
                    objMap.put(t.Objective_Id__c, null);
	               	ObjSettList.add(t.Objective_Setting__c); 
                    
                    // adding minutes to system date for uniqueness for each record
                	if(t.WhatId != null){
	               		 t.Unique_Field__c = t.WhatId+'-'+System.now().addMinutes(recordCounter)+'-'+t.Objective_Id__c;	                
	                }                 
              }
	           
	    }
        
        
        
        /*
         * Copy Type_of_Objective__c, Channel__c, Category_of_Objective__c, Product_Group__c, ROI__c & Execution_Standard__c
         * From Objective to task of record type Objective
         */
	    
        
        if(objMap.size() > 0){
	        
            system.debug('t.Objective_Setting__c <> 0');
            
            
            
	        objMap = new map <Id, Objective__c>([Select id, Type_of_Objective__c, Channel__c, Category_of_Objective__c, Product_Group__c, ROI__c, Execution_Standard__c
	                                             from Objective__c
	                                             where Id IN : objMap.keySet()]);
	        
            Map<id,id> SettObStat = new Map<id,id>();         

            For(Objective_Statistics__c ObStats : [Select id, ASM__c from Objective_Statistics__c where Objective__c IN : ObjSettList]){
                SettObStat.put(ObStats.ASM__c, ObStats.id);
                System.debug(ObStats.id + ' ASM: ' + ObStats.ASM__c);
            }
            
	        Objective__c obj = null;
	                                                                 
	        for(Task t : Trigger.new) {
	            
	            if(t.Objective_Setting__c != null && objMap.containsKey(t.Objective_Id__c)){
	                
	                obj =  objMap.get(t.Objective_Id__c);
	                
	                t.Type_of_Objective__c = obj.Type_of_Objective__c;
	                
	                t.Channel__c = obj.Channel__c;
	                
	                t.Category_of_Objective__c = obj.Category_of_Objective__c;
	                
	                t.Product_Group__c = obj.Product_Group__c;
	                
	                t.ROI__c = obj.ROI__c;
	                
	                t.Execution_Standard__c = obj.Execution_Standard__c;
	                
                    t.Objective_Statistics__c = SettObStat.get(t.OwnerId);
	            }
	            
	        }                                                        
	        
	    }
    
    }    
  
}