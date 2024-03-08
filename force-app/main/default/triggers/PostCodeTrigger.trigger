/* This trigger was replaced by Flow: Post Code: After Update and Post Code: Before update  - NOT USING IT ANYMORE CARNAC aug.2022
 */
trigger PostCodeTrigger on Post_Code_Region__c (after insert, after update, before insert, before update) {

    
    PostCodeTriggerHandler handler = new PostCodeTriggerHandler(Trigger.isExecuting, Trigger.size);
    
    if( Trigger.isInsert )
    {
        if(Trigger.isBefore)
        {
      //      handler.OnBeforeInsert(trigger.New);
        }
        else
            
        {
    //        handler.OnAfterInsert(trigger.New);
        }
    }
    else if ( Trigger.isUpdate )
    {
        if(Trigger.isBefore)
        {
      		
            List<Post_Code_Region__c> PostCodes = new List<Post_Code_Region__c>();
            for (Post_Code_Region__c pcs: Trigger.new) {
                Post_Code_Region__c oldPost_Code = Trigger.oldMap.get(pcs.Id);
 				if(pcs.Territory__c != oldPost_Code.Territory__c) {                
                    PostCodes.add(pcs);
                }
            }
            If(PostCodes.size() > 0){
               
                handler.OnBeforeUpdate(PostCodes);
            }
            
        }
        else
        {	
            
        List<Post_Code_Region__c> PostCodes = new List<Post_Code_Region__c>();
            for (Post_Code_Region__c pcs: Trigger.new) {
                Post_Code_Region__c oldPost_Code = Trigger.oldMap.get(pcs.Id);
 				if(pcs.Territory__c != oldPost_Code.Territory__c) {
            		 PostCodes.add(pcs);
                }
            }
             If(PostCodes.size() > 0){
                
               handler.OnAfterUpdate(PostCodes);
                }
        
        
        }
    }

   
    
}