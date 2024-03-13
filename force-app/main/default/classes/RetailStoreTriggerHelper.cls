public with sharing class RetailStoreTriggerHelper {

    public static void updateNewStore(List<RetailStore> newStores) {

        List<String> postCodesMerged = new List<String>();
        Map<String,Id> mapPostCodeRegions = new Map<String,Id>();

        for (RetailStore store : newStores) {
            String postCodeMerged = store.PostalCode + ' - ' + store.City;
            postCodesMerged.add(postCodeMerged);
        }

        mapPostCodeRegions = mapPostCodes(postCodesMerged);

        for (RetailStore newStore : newStores) {
            String newPostCodeMerged = newStore.PostalCode + ' - ' + newStore.City;
            if (mapPostCodeRegions.containsKey(newPostCodeMerged)) {
                newStore.Postcode_Region__c = mapPostCodeRegions.get(newPostCodeMerged);
            }
        }
    }

    public static void updateStore(Map<Id,RetailStore> newMap, Map<Id,RetailStore> oldMap) {

        List<String> postCodesMerged = new List<String>();
        Map<String,Id> mapPostCodeRegions = new Map<String,Id>();

        for (Id retailStoreId : newMap.keySet()) {
            RetailStore newStore = newMap.get(retailStoreId);
            RetailStore oldStore = oldMap.get(retailStoreId);
            String newPostCodeMerged = newStore.PostalCode + ' - ' + newStore.City;
            String oldPostCodeMerged = oldStore.PostalCode + ' - ' + newStore.City;
            if (newPostCodeMerged != oldPostCodeMerged) {
                postCodesMerged.add(newPostCodeMerged);
            }
        }

        if (postCodesMerged.size() > 0) {
            mapPostCodeRegions = mapPostCodes(postCodesMerged);
            for (RetailStore newStore : newMap.values()) {
                String newPostCodeMerged = newStore.PostalCode + ' - ' + newStore.City;
                if (mapPostCodeRegions.containsKey(newPostCodeMerged)) {
                    newStore.Postcode_Region__c = mapPostCodeRegions.get(newPostCodeMerged);
                }
            }   
        }
    }

    public static void updateOutlet(Map<Id,RetailStore> newMap, Map<Id,RetailStore> oldMap) {

        List<String> mySalesIds = new List<String>();
        List<Outlet__c> outletsForUpdate = new List<Outlet__c>();
        Map<String, Outlet__c> mapOutletByMSId = new Map<String, Outlet__c>();

        for (RetailStore storeRecord : newMap.values()) {
            mySalesIds.add(storeRecord.My_Sales_ID__c);
        }

        //Get related outlet records
        List<Outlet__c> relatedOutlets = [SELECT Id, Name, ASM_User_ID__c, OwnerId, 
                                          Territory__c, Called_On__c, Ownership_Group_Id__c
                                          FROM Outlet__c
                                          WHERE Name IN :mySalesIds];

        //Map outlets by the Outlet ID
        for (Outlet__c relatedOutlet : relatedOutlets) {
            mapOutletByMSId.put(relatedOutlet.Name, relatedOutlet);
        }

        //Check for relevant changes on the Retail Store records
        for (Id retailStoreId : newMap.keySet()) {
            RetailStore newStore = newMap.get(retailStoreId);
            RetailStore oldStore = oldMap.get(retailStoreId);
            Outlet__c outletForUpdate = mapOutletByMSId.get(newStore.My_Sales_ID__c);

            if (newStore.Name != oldStore.Name) {
                if (newStore.Name != mapOutletByMSId.get(newStore.My_Sales_ID__c).Name) {
                    outletForUpdate.Name = newStore.Name;
                }                    
            }
            if (newStore.Owner_Employee_Number__c != oldStore.Owner_Employee_Number__c) {
                if (newStore.ASM_User_ID__c != mapOutletByMSId.get(newStore.My_Sales_ID__c).ASM_User_ID__c) {
                    outletForUpdate.ASM_User_ID__c = newStore.Owner_Employee_Number__c;
                }
            }
            if (newStore.OwnerId != oldStore.OwnerId) {
                if (newStore.OwnerId != mapOutletByMSId.get(newStore.My_Sales_ID__c).OwnerId) {
                    outletForUpdate.OwnerId = newStore.OwnerId;
                }
            }
            if (newStore.Territory__c != oldStore.Territory__c) {
                if (newStore.Territory__c != mapOutletByMSId.get(newStore.My_Sales_ID__c).Territory__c) {
                    outletForUpdate.Territory__c = newStore.Territory__c;
                }
            }
            if (newStore.Called_On__c != oldStore.Called_On__c) {
                if (newStore.Called_On__c != mapOutletByMSId.get(newStore.My_Sales_ID__c).Called_On__c) {
                    outletForUpdate.Called_On__c = newStore.Called_On__c;
                }
            }
            if (newStore.AccountId != oldStore.AccountId) {
                if (newStore.AccountId != mapOutletByMSId.get(newStore.My_Sales_ID__c).Ownership_Group_Id__c) {
                    outletForUpdate.Ownership_Group_Id__c = newStore.AccountId;
                }
            }
            outletsForUpdate.add(outletForUpdate);
        }
        
        if (outletsForUpdate.size() > 0) {
            System.debug('Outlets for update = ' + outletsForUpdate.size());
            Database.SaveResult[] outletUpdateResults = Database.update(outletsForUpdate, false);
        }
    }

    private static Map<String,Id> mapPostCodes(List<String> postCodesMerged) {

        Map<String,Id> mapPostCodeRegions = new Map<String,Id>();
        List<Post_Code_Region__c> postCodeRegions = [SELECT Id, Name 
                                                     FROM Post_Code_Region__c
                                                     WHERE Name IN :postCodesMerged
                                                     ];

        for (Post_Code_Region__c postCode : postCodeRegions) {
            mapPostCodeRegions.put(postCode.Name, postCode.Id);
        }
        return mapPostCodeRegions;                         
    }
}