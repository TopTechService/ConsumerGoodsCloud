/*Created By -:Sourav Nema
  Purpose-:Populate value of outlet category and state on  outlet object

  Modified by daniel.peaper@viseo.com with the implementation of Consumer Goods Cloud
  
  */

trigger outletTrigger on Outlet__c ( after update, before insert, after insert) {
       
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            OutletTriggerHelper.insertOutlet(Trigger.newMap);
        } else if (Trigger.isUpdate) {
            OutletTriggerHelper.updateOutlet(Trigger.newMap, Trigger.oldMap);
        }
    }
    if (Trigger.IsAfter) {
        if (Trigger.isUpdate) {
            OutletTriggerHelper.updateRelatedStore(Trigger.newMap,  Trigger.oldMap);
        } else if (Trigger.isInsert) {
            OutletTriggerHelper.insertRelatedStore(Trigger.newMap);
        }
    }
    /*
    if(trigger.IsBefore && trigger.isInsert){ 
        for(Outlet__c  otlt:trigger.new){
            if(stateIdMap.get(otlt.State_ID__c)!=null && outLetCategoryMap.get(otlt.Outlet_Category_Id__c)!=null){  
    
                if(otlt.Outlet_Name__c != null && otlt.Outlet_Name__c != ''){
                  otlt.Outlet_Name__c = otlt.Outlet_Name__c.toUpperCase();
                }  
                
                // all accounts are mapped to the business admin user.
                // DEfault business admin user will update the account in Salesforce manually.
                String defaultOwnerId ;
                system.debug('----Default_Account_Owner__c.getAll()----' + Default_Account_Owner__c.getAll()); //CodeReview - Default Account Owner is a custom setting
                

                if(Default_Account_Owner__c.getAll() != null && !Default_Account_Owner__c.getAll().values().isEmpty()){
                    defaultOwnerId = Default_Account_Owner__c.getAll().values()[0].ownerId__c;
                }else{
                    defaultOwnerId = userinfo.getuserid();
                }

                otlt.OwnerId = defaultOwnerId;
                   
                system.debug('---otlt.OwnerId----' + otlt.OwnerId);
                 
                
            } else {  
                if(stateIdMap.get(otlt.State_ID__c)==null){
                    otlt.State_ID__c.addError('Invalid State Id');
                } else {
                    otlt.Outlet_Category_Id__c.addError('Invalid Outlet Category Id');
                }
            }
        }
        
    } */
}