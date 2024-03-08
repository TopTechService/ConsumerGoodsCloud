public class CloneTask_Controller {
    
    @AuraEnabled
	public static string cloneObject(Id recordId,Id AccountId) {

		String result;
		result = Object_Clone.cloneObjectSingle(recordId,false); 
  		
        Task taskToUpdate = new Task();
        taskToUpdate = [Select id, Status, Description, Closed_Date__c, Closed_Date_Time__c, WhatId, Case_1__c, Case_2__c, Case_3__c, of_Participant__c, 
                             Activation_Type__c, Display_1__c, Display_2__c, Display_3__c, Shelf_Price_1__c, Shelf_Price_2__c, Shelf_Price_3__c,
                        	Activation_End_Date__c, Activation_Start_Date__c, Completion_Comments__c , Support_Deal_1_Number__c,
                			Support_Deal_2_Number__c , Training_Brand__c 
                            FROM Task 
                            WHERE Id = :result];
            
            taskToUpdate.Status = 'Allocated'; 
            taskToUpdate.Description = ''; 
            taskToUpdate.Closed_Date__c = null; 
            taskToUpdate.Closed_Date_Time__c = null; 
            taskToUpdate.WhatId = AccountId; 
            taskToUpdate.Case_1__c = null; 
            taskToUpdate.Case_2__c = null; 
            taskToUpdate.Case_3__c = null; 
            taskToUpdate.of_Participant__c = null; 
            taskToUpdate.Activation_Type__c = null; 
            taskToUpdate.Display_1__c = false; 
            taskToUpdate.Display_2__c = false; 
            taskToUpdate.Display_3__c = false; 
            taskToUpdate.Shelf_Price_1__c = null; 
            taskToUpdate.Shelf_Price_2__c = null; 
            taskToUpdate.Shelf_Price_3__c = null; 
        	taskToUpdate.Activation_End_Date__c  = null;
            taskToUpdate.Activation_Start_Date__c  = null;
			taskToUpdate.Activation_Type__c  = null;
            taskToUpdate.Completion_Comments__c  = null;
            taskToUpdate.Support_Deal_1_Number__c  = null;
            taskToUpdate.Support_Deal_2_Number__c  = null;
            taskToUpdate.Training_Brand__c  = null;
            taskToUpdate.Participant_Type__c = null;
        
        update taskToUpdate;
        
        //taskToUpdate.OwnerId = taskToUpdate.CreatedById; 
        	
        //update taskToUpdate;
        
		return result;
  
    }
}