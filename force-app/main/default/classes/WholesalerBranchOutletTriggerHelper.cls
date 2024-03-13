//Written by daniel.peaper@viseo.com as part of the Consumer Goods Cloud project

public with sharing class WholesalerBranchOutletTriggerHelper {

    public Static void updateStoreAndBranch(List<Wholesaler_Branch_Outlet__c> newItems) {

        List<String> mySalesIds = new List<String>();
        list<string> branchIds = new list<string>();
        Map<String,String> mapStoresByMSId = new Map<String,String>();
        Map<String,Id> branchIdMap = new Map<String,Id>();
        DataLoaderHelper helper = new DataLoaderHelper();

        for (Wholesaler_Branch_Outlet__c wbo : newItems) {
            mySalesIds.add(wbo.Outlet_ID__c);
            branchIds.add(wbo.Wholesaler_Branch_ID__c);
        }

        mapStoresByMSId = mapRetailStores(mySalesIds);
        branchIdMap = helper.getWholesalerBranchIdMap(branchIds);

        for (Wholesaler_Branch_Outlet__c branchOutlet : newItems) {
            if (mapStoresByMSId.containsKey(branchOutlet.Outlet_ID__c)) {
                branchOutlet.Retail_Store__c = mapStoresByMSId.get(branchOutlet.Outlet_ID__c);
            } else {
                branchOutlet.Outlet_ID__c = 'Invalid MySales Id';
            }
            if (branchIdMap.containsKey(branchOutlet.Wholesaler_Branch_ID__c)) {
                branchOutlet.Wholesaler_Branch__c = branchIdMap.get(branchOutlet.Wholesaler_Branch_ID__c);
            } else {
                branchOutlet.Wholesaler_Branch_ID__c = 'Invalid Branch Id';
            }
            
        }

    }

    private static Map<String,String> mapRetailStores(List<String> mySalesIds) {

        Map<String,String> mapStoresByMSId = new Map<String,String>();
        List<RetailStore> retailStores = [SELECT Id, My_Sales_ID__c FROM RetailStore WHERE My_Sales_ID__c IN :mySalesIds];

        for (RetailStore store : retailStores) {
            mapStoresByMSId.put(store.My_Sales_ID__c, store.Id);
        }
        Return mapStoresByMSId;
    }
}