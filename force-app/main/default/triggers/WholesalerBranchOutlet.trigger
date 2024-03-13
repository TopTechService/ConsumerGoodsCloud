trigger WholesalerBranchOutlet on Wholesaler_Branch_Outlet__c (before insert, before update) {

  if (Trigger.isBefore) {
      WholesalerBranchOutletTriggerHelper.updateStoreAndBranch(Trigger.new);
    }
}