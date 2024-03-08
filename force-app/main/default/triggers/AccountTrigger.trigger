trigger AccountTrigger on Account (before insert, before update, after update, after insert){
    
    //Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Outlet').getRecordTypeId();
    ///Added by Carnac Group///
    
    // Check to prevent Account to update Outlet to update account again.
    RecursiveTriggerController.count++;
    //For(Account acc: Trigger.new){
        
        //If(acc.recordTypeId == devRecordTypeId){
            
            if( Trigger.isInsert ){
                if(Trigger.isAfter){
                    System.debug('AccTrig after insert RecursiveTriggerController.count>>>' + RecursiveTriggerController.count);
                    accountTriggerHandler handler = new accountTriggerHandler(Trigger.isExecuting, Trigger.size);
                    //handler.AfterInsert(Trigger.new);//Codereview fixing - replaced as after inserting is only calling one method 
                    handler.afterInsertAccountSetUp(Trigger.new);
                } else {
                    System.debug('AccTrig before insert RecursiveTriggerController.count>>>' + RecursiveTriggerController.count);
                    accountTriggerHandler handler = new accountTriggerHandler(Trigger.isExecuting, Trigger.size);
                    handler.beforeInsert(Trigger.new);
                }
            } else if (Trigger.isUpdate){
                if(Trigger.isAfter){
                    System.debug('AccTrig after update RecursiveTriggerController.count>>>' + RecursiveTriggerController.count);
                    accountTriggerHandler handler = new accountTriggerHandler(Trigger.isExecuting, Trigger.size);
                   handler.afterUpdate(trigger.newMap, trigger.oldMap); 
                } else {
                    System.debug('AccTrig before update RecursiveTriggerController.count>>>' + RecursiveTriggerController.count);
                    accountTriggerHandler handler = new accountTriggerHandler(Trigger.isExecuting, Trigger.size);
                    handler.beforeUpdate(trigger.newMap, trigger.oldMap);   
                }  
            }
       // }
    //}
}