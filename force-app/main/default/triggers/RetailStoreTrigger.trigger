trigger RetailStoreTrigger on RetailStore (after Update ) {

    if (TriggerControl.isStoreTriggerFired) return;

    TriggerControl.isOutletTriggerFired = true;

    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            RetailStoreTriggerHelper.updateNewStore(Trigger.new);
        } else if (Trigger.isUpdate) {
            RetailStoreTriggerHelper.updateStore(Trigger.newMap, Trigger.oldMap);
        }
    } else if (Trigger.isAfter) {
        if (Trigger.isInsert) {

        } else if (Trigger.isUpdate) {
            RetailStoreTriggerHelper.updateOutlet(Trigger.newMap, Trigger.oldMap);
        }
    }
    //Prevent this trigger causing recursion
    TriggerControl.isStoreTriggerFired = true;
}