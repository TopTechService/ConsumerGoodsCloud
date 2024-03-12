trigger RetailStoreTrigger on RetailStore (after Update ) {

    if (TriggerControl.isStoreTriggerFired) return;

    if (Trigger.isBefore) {
        if (Trigger.isInsert) {

        } else if (Trigger.isUpdate) {

        }
    } else if (Trigger.isAfter) {
        if (Trigger.isInsert) {

        } else if (Trigger.isUpdate) {
            RetailStoreTriggerHelper.updateOutlet(Trigger.newMap, Trigger.oldMap);
        }
    }
    //Prevent this trigger causing recursion
    TriggerControl.isStoreTriggerFired = true;
    TriggerControl.isOutletTriggerFired = true;
}