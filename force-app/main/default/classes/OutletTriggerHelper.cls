/**
* Description - update's outlet accounts whenever outlet is updated 
*/
public with sharing class OutletTriggerHelper {

    public static void insertOutlet(Map<Id,Outlet__c> newMap) {

        List<Default_Account_Owner__c> outletOwner = Default_Account_Owner__c.getAll().values();
        String outletOwnerId = outletOwner[0].Id;
        for(Outlet__c outlet : newMap.values()) {
            outlet.Outlet_Name__c = outlet.Outlet_Name__c.toUpperCase();
            outlet.OwnerId = outletOwnerId;
        }
    }

    public static void updateOutlet(Map<Id,Outlet__c> newMap, Map<Id,Outlet__c> oldMap) {

        for (Id outletId : newMap.keySet()) {
            Outlet__c newOutlet = newMap.get(outletId);
            Outlet__c oldOutlet = oldMap.get(outletId);
            if (newOutlet.Outlet_Name__c != oldOutlet.Outlet_Name__c) {
                newOutlet.Outlet_Name__c = newOutlet.Outlet_Name__c.toUpperCase();
            }
        }

    }

    public static void updateRelatedStore(Map<Id, Outlet__c> newMap, Map<Id, Outlet__c> oldMap) {

        Id accountId = getParentAccount();
        List<RetailStore> storesToUpdate = new List<RetailStore>();
        List<RetailStore> storesToInsert = new List<RetailStore>();
        Map<String, Outlet__c> mapOutletByMSid = new Map<String, Outlet__c>();
        Map<String, RetailStore> mapStoreByMSid = new Map<String, RetailStore>();
        Map<String, Id> mapChannelByGroupId = new Map<String, Id>();

        for (Outlet__c outlet : newMap.values()) {
            if (outlet.Outlet_My_Sales_Id__c == null) {
                System.debug('Error: Outlet ' + outlet.Name + ' has no My Sales ID.');
            } else {
                String oMySalesId = String.valueOf(outlet.Outlet_My_Sales_Id__c.round());
                mapOutletByMSid.put(oMySalesId, outlet);
            }
        }

        for (RetailLocationGroup rlg : [SELECT Id, Channel__c FROM RetailLocationGroup]) {
            mapChannelByGroupId.put(rlg.channel__c, rlg.Id);
        }

        List<RetailStore> retailStores = [SELECT Id, Name, ASM_User_ID__c, Street, Licence_Class__c, 
                                          Licence_Number__c, Licence_Type_ID__c, LMAA_Code__c, 
                                          New_Liquor_Licence_Number__c, Outlet_Category_ID__c, 
                                          PostalCode, City, recordtypeid, State, My_Sales_ID__c
                                          FROM RetailStore
                                          WHERE My_Sales_ID__c IN :mapOutletByMSid.keySet()
                                          ];
        
        for (RetailStore retailStore : retailStores) {
            mapStoreByMSid.put(retailStore.My_Sales_ID__c,retailStore);
        }

        for (Id outletId : newMap.keySet()) {
            String outletMySalesId = String.valueOf(newMap.get(outletId).Outlet_My_Sales_Id__c.round());
            //Check for corrosponding retail store
            if (mapStoreByMSid.containsKey(outletMySalesId)) {
                Outlet__c oldOutlet = oldMap.get(outletId);
                Outlet__c newOutlet = newMap.get(outletId);
                RetailStore storeToUpdate = mapStoreByMSid.get(outletMySalesId);

                //Check for updated Fields
                if (newOutlet.Outlet_Name__c != oldOutlet.Outlet_Name__c) {
                    storeToUpdate.Name = newOutlet.Outlet_Name__c;
                }
                if (newOutlet.Channel__c != oldOutlet.Channel__c) {
                    storeToUpdate.RetailLocationGroupId = mapChannelByGroupId.get(newOutlet.Channel__c);
                }
                if (newOutlet.Licence_Class__c != oldOutlet.Licence_Class__c) {
                    storeToUpdate.Licence_Class__c = newOutlet.Licence_Class__c;
                }
                if (newOutlet.Licence_Number__c != oldOutlet.Licence_Number__c) {
                    storeToUpdate.Licence_Number__c = newOutlet.Licence_Number__c;
                }
                if (newOutlet.Licence_Type_ID__c != oldOutlet.Licence_Type_ID__c) {
                    storeToUpdate.Licence_Type_ID__c = newOutlet.Licence_Type_ID__c;
                }
                if (newOutlet.LMAA_Code__c != oldOutlet.LMAA_Code__c) {
                    storeToUpdate.LMAA_Code__c = newOutlet.LMAA_Code__c;
                }
                if (newOutlet.New_Liquor_Licence_Number__c != oldOutlet.New_Liquor_Licence_Number__c) {
                    storeToUpdate.New_Liquor_Licence_Number__c = newOutlet.New_Liquor_Licence_Number__c;
                }
                if (newOutlet.Address_Line_1__c != oldOutlet.Address_Line_1__c ||
                    newOutlet.Address_Line_2__c != oldOutlet.Address_Line_2__c) {
                        String add1 = newOutlet.Address_Line_1__c != null ? newOutlet.Address_Line_1__c:'';
                        String add2 = newOutlet.Address_Line_2__c != null ? newOutlet.Address_Line_2__c:'';
                        storeToUpdate.Street = add1 + '' + add2;
                    }
                if (newOutlet.Post_Code__c != oldOutlet.Post_Code__c) {
                    String postCode = newOutlet.Post_Code__c != null ? newOutlet.Post_Code__c:'';
                    storeToUpdate.PostalCode = postCode;
                }
                if (newOutlet.Suburb__c != oldOutlet.Suburb__c) {
                    String city = newOutlet.Suburb__c != null ? newOutlet.Suburb__c:'';
                    storeToUpdate.City = city;
                }
                if (newOutlet.State_Name__c != oldOutlet.State_Name__c) {
                    storeToUpdate.State = newOutlet.State_Name__c;
                }
                if (newOutlet.ASM_User_ID__c != oldOutlet.ASM_User_ID__c) {
                    storeToUpdate.ASM_User_ID__c = newOutlet.ASM_User_ID__c;
                }
                if (newOutlet.OwnerId != oldOutlet.OwnerId) {
                    storeToUpdate.OwnerId = newOutlet.OwnerId;
                }
                storesToUpdate.add(storeToUpdate);
            } else {
                //Create a new retail store
                RetailStore newStore = createNewStore(newMap.get(outletId), accountId, mapChannelByGroupId);
                storesToInsert.add(newStore);
            }
        }
        if (storesToUpdate.size() > 0) {
            Database.SaveResult[] updatedStoreResults = Database.update(storesToUpdate, false);
        }
        if (storesToInsert.size() > 0) {
            Database.SaveResult[] insertStoreResults = Database.insert(storesToInsert, false);
        }
    }

    public static void insertRelatedStore(Map<Id, Outlet__c> newMap) {

        List<RetailStore> storesToInsert = new List<RetailStore>();
        Map<String, Id> mapChannelToId = new Map<String, Id>();
        Id accountId = getParentAccount();

        for (RetailLocationGroup rlg : [SELECT Id, Channel__C FROM RetailLocationGroup]) {
            mapChannelToId.put(rlg.Channel__c, rlg.Id);
        }

        for (Outlet__c outlet : newMap.values()) {
            RetailStore newStore = createNewStore(outlet, accountId, mapChannelToId);
            storesToInsert.add(newStore);
        }

        Database.SaveResult[] newStoreResults = Database.insert(storesToInsert, false);
    }

    private Static RetailStore createNewStore(Outlet__c outlet, Id parentId, Map<String,Id> mapGroup) {

        String oMySalesId;
        if (outlet.Outlet_My_Sales_Id__c == null) {
            System.debug('Error: Outlet ' + outlet.Name + ' has no My Sales ID.');
            return null;
        } else {
            oMySalesId = String.valueOf(outlet.Outlet_My_Sales_Id__c.round());
        }

        String storeRecordTypeId = Schema.SObjectType.RetailStore.getRecordTypeInfosByDeveloperName().get('Retail_Store').getRecordTypeId();
        //create address field 
        String add1  =  outlet.Address_Line_1__c!=null?outlet.Address_Line_1__c:'';
        String add2  =  outlet.Address_Line_2__c!=null?outlet.Address_Line_2__c:'';  
        String post  =  outlet.Post_Code__c!=null?outlet.Post_Code__c:''; 
        String city  =  outlet.Suburb__c!=null?outlet.Suburb__c:'';

        RetailStore newStore = new RetailStore(Name = outlet.Outlet_Name__c.toUpperCase(),
                                               RecordTypeId = storeRecordTypeId,
                                               AccountId = parentId,
                                               My_Sales_ID__c = oMySalesId,
                                               ASM_User_ID__c = outlet.ASM_User_ID__c,
                                               Licence_Class__c = outlet.Licence_Class__c,
                                               Licence_Number__c = outlet.Licence_Number__c,
                                               Licence_Type_ID__c = outlet.Licence_Type_ID__c,
                                               LMAA_Code__c = outlet.LMAA_Code__c,
                                               New_Liquor_Licence_Number__c = outlet.New_Liquor_Licence_Number__c,
                                               Territory__c = outlet.Territory__c,
                                               RetailLocationGroupId = mapGroup.get(outlet.Channel__c),
                                               Street = add1 + '' + add2,
                                               City = city,
                                               State = outlet.State_Name__c,
                                               PostalCode = outlet.Post_Code__c,
                                               Country = 'AU',
                                               OwnerId = outlet.OwnerId,
                                               Outlet__c = outlet.Id);

        if (String.isBlank(outlet.ASM_User_ID__c)) {
            newStore.Unallocated__c = true;
        }
        return newStore;
    }

    private static Id getParentAccount() {
        Id parentId;
        List<Account> parentAccount = [SELECT Id FROM Account WHERE Name = 'Orphaned Stores'];
        if (parentAccount.size() == 0) {
            Account newAccount = new Account(Name = 'Orphaned Stores',
                                             Active__c = true);
            insert newAccount;
            parentId = newAccount.Id;
        } else {
            parentId = parentAccount[0].Id;
        }
        return parentId;
    }
}