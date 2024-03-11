//  Modified by daniel.peaper@viseo.com with the implementation of Consumer Goods Cloud

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
}