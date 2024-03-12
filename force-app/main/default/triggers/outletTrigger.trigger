//  Modified by daniel.peaper@viseo.com with the implementation of Consumer Goods Cloud

trigger outletTrigger on Outlet__c ( after update, before insert, after insert) {

    if (TriggerControl.isOutletTriggerFired) return;

    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            OutletTriggerHelper.insertOutlet(Trigger.new);
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
    TriggerControl.isOutletTriggerFired = true;
    TriggerControl.isStoreTriggerFired = true;
}