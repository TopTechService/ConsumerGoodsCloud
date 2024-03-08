public with sharing class RevertOwnerOfTasksHandler {
    
    @future
    public static void revertOwnerForPastTasks1(Map<Id,Id> taskOwnerMap) {
        Set<Task> updateTaskSet = new Set<Task>();
        for (Task t : [SELECT Id, Status, OwnerId, ActivityDate, WhatId FROM task 
                       WHERE Id IN :taskOwnerMap.keySet()
                       AND IsClosed = false
                       AND status != 'Completed' 
                       AND status != 'Executed']) {
                           System.debug('##_'+t.OwnerId+'_'+t.WhatId+'_'+taskOwnerMap.get(t.Id)); 
                           if(t.OwnerId <> taskOwnerMap.get(t.Id))
                           {
                               t.OwnerId = taskOwnerMap.get(t.Id);
                               updateTaskSet.add(t);
                           }
                       }  	
        System.debug('###_'+updateTaskSet.size());  		
        if (updateTaskSet.size() > 0) {
            List<Task> updateTaskList = new List<Task>(updateTaskSet);
            if (updateTaskList != null) {
                update updateTaskList;	  				
            }
        }  		
    }
}