/* This trigger was replaced by Flow: Territory: After Update  - NOT USING IT ANYMORE CARNAC aug.2022
 */
trigger TerritoryTrigger on Territory__c (after update, after insert) {

     TerritoryTriggerHandler handler = new TerritoryTriggerHandler(Trigger.isExecuting, Trigger.size);
    
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
        if(Trigger.isBefore){
     		//        handler.OnBeforeUpdate(trigger.New);
        }
         else
        {
            List<Territory__c> Territories = new List<Territory__c>();
            for (Territory__c terr: Trigger.new) {
				Territory__c oldTerritory = Trigger.oldMap.get(terr.Id);
 				if(terr.OwnerId != oldTerritory.OwnerId) {
            		 Territories.add(terr);
                }
            }
                If(Territories.size() > 0){
                    system.debug('Territories ' + Territories);
                    handler.OnAfterUpdate(Territories);
                }
            
        }
    }

   
    
    
    
}