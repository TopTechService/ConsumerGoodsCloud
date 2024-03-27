trigger SaleMySalesTrigger on Sale_MySales__c (before insert, before update) {

    if (Trigger.isBefore) {
        SaleMySalesTriggerHelper.setParentsOnSaleMySales(Trigger.new);
    } else if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            SaleMySalesTriggerHelper.assignObjectives(Trigger.new);
        }
    }
}