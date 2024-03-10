/**
* Description - update's outlet accounts whenever outlet is updated 
*/
public with sharing class OutletTriggerHelper {
    public static Boolean outletTriggerFired = false;
    
    public void updateRelatedAccount(Map<Id, Outlet__c> newMap, Map<Id, Outlet__c> oldMap, 
                                                            Map<String, Id> outLetCategoryMap,
                                                            Map<String, Id> stateIdMap) {
    
        List<Account> accountOutlet = new List<Account>();
        List<Account> li_accountOutlet = new List<Account>();                                                        
        Id outletRecId = Utilities.getRecordTypeId('Account','Outlet'); 
        Map<String, Outlet__c> outletMap = new Map<String, Outlet__c>();
        Set<Id>  outletWithAccounts = new Set<Id>();                                                      
        
        for (Outlet__c out : newMap.values()) {
            if (out.Outlet_My_Sales_Id__c == null) {
               // System.debug('OutletTriggerHelper updateRelatedAccount Outlet_My_Sales_Id__c'+ out.Outlet_My_Sales_Id__c);
                return;
            }
            String outletMySalesId = string.valueof(out.Outlet_My_Sales_Id__c.round());
            outletMap.put(outletMySalesId, out);
        }           
        accountOutlet = [SELECT id, name, ASM_User_ID__c, BillingStreet, Licence_Class__c, Licence_Number__c,
                                                        Licence_Type_ID__c, LMAA_Code__c, New_Liquor_Licence_Number__c,
                                                        Outlet_Category_ID__c, BillingPostalCode, BillingCity,
                                                        recordtypeid, Outlet_Category__c, State__c, Outlet_ID__c                                                        
                                                        FROM Account WHERE recordTypeId =: outletRecId 
                                                        AND Outlet_ID__c IN : outletMap.keySet()];
        //System.debug('OutletTriggerHelper updateRelatedAccount accountOutlet: '+accountOutlet);

        
        for (Account acc : accountOutlet) {
            Outlet__c tempOutlet = new Outlet__c();
            tempOutlet = outletMap.get(acc.Outlet_ID__c);  
            //system.debug('tempOutlet Id, Name, OutletId : ' + tempOutlet.Id + ' - ' +tempOutlet.Name + ' - ' + tempOutlet.Outlet_Name__c );
            String add1  =  tempOutlet.Address_Line_1__c!=null?tempOutlet.Address_Line_1__c:'';      
            String add2  =  tempOutlet.Address_Line_2__c!=null?tempOutlet.Address_Line_2__c:'';  
            String post  =  tempOutlet.Post_Code__c!=null?tempOutlet.Post_Code__c:''; 
            String city  =  tempOutlet.Suburb__c!=null?tempOutlet.Suburb__c:'';
            
            acc.name = tempOutlet.Outlet_Name__c.toUpperCase();
            acc.Licence_Class__c = tempOutlet.Licence_Class__c;
            acc.Licence_Number__c = tempOutlet.Licence_Number__c;
            acc.Licence_Type_ID__c = tempOutlet.Licence_Type_ID__c;
            acc.LMAA_Code__c = tempOutlet.LMAA_Code__c;
            acc.New_Liquor_Licence_Number__c = tempOutlet.New_Liquor_Licence_Number__c;
            acc.BillingStreet = add1+''+add2;       
            acc.BillingPostalCode = post;
            acc.BillingCity = city;
            acc.Outlet_Category__c = outLetCategoryMap.get(tempOutlet.Outlet_Category_Id__c);
            acc.State__c = stateIdMap.get(tempOutlet.State_ID__c);
            acc.Outlet_ID__c = String.valueOf(Integer.valueOf(outletMap.get(acc.Outlet_ID__c).Outlet_My_Sales_Id__c));
            acc.Outlet__c = tempoutlet.Id;
            
                acc.ASM_User_ID__c = tempOutlet.ASM_User_ID__c;
                acc.Outlet_Category_ID__c = tempOutlet.Outlet_Category_Id__c;
                acc.recordtypeid = outletRecId;
                acc.OwnerId = tempOutlet.OwnerId;
                acc.Outlet__c = tempOutlet.Id;
                outletWithAccounts.add(tempOutlet.Id);
            //system.debug('UpdateAccount Id, Name, OutletId : ' + acc.Id + ' - ' +acc.Name + ' - ' + acc.Outlet_ID__c );
           
            li_accountOutlet.add(acc);
        }
                                                                
        for (Outlet__c tempOutlet : newMap.values()) {
            
            if(!outletWithAccounts.contains(tempOutlet.Id))
            {
                //System.debug('outletWithAccounts  : '+ outletWithAccounts);
                //System.debug('tempOutlet  : '+ tempOutlet);
                Account acc = new Account();                     
                String add1  =  tempOutlet.Address_Line_1__c!=null?tempOutlet.Address_Line_1__c:'';      
                String add2  =  tempOutlet.Address_Line_2__c!=null?tempOutlet.Address_Line_2__c:'';  
                String post  =  tempOutlet.Post_Code__c!=null?tempOutlet.Post_Code__c:''; 
                String city  =  tempOutlet.Suburb__c!=null?tempOutlet.Suburb__c:'';
            
            acc.name = tempOutlet.Outlet_Name__c;
            acc.Licence_Class__c = tempOutlet.Licence_Class__c;
            acc.Licence_Number__c = tempOutlet.Licence_Number__c;
            acc.Licence_Type_ID__c = tempOutlet.Licence_Type_ID__c;
            acc.LMAA_Code__c = tempOutlet.LMAA_Code__c;
            acc.New_Liquor_Licence_Number__c = tempOutlet.New_Liquor_Licence_Number__c;
            acc.BillingStreet = add1+''+add2;       
            acc.BillingPostalCode = post;
            acc.BillingCity = city;
            acc.Outlet_Category__c = outLetCategoryMap.get(tempOutlet.Outlet_Category_Id__c);
            acc.State__c = stateIdMap.get(tempOutlet.State_ID__c);
            acc.Outlet_ID__c = String.valueOf(Integer.valueOf(tempOutlet.Outlet_My_Sales_Id__c));
            acc.Outlet__c = tempoutlet.Id;
            
                acc.ASM_User_ID__c = tempOutlet.ASM_User_ID__c;
                acc.Outlet_Category_ID__c = tempOutlet.Outlet_Category_Id__c;
                acc.recordtypeid = outletRecId;
                acc.OwnerId = tempOutlet.OwnerId;
                acc.Outlet__c = tempOutlet.Id;
                
            li_accountOutlet.add(acc);
            //system.debug('acc: ' + acc);
                
            }
                
        }

        //System.debug('updateRelatedAccount accountOutlet updated: '+ accountOutlet);
        System.debug('OutletTriggerHelper updateRelatedAccount accountOutlet updated: '+ li_accountOutlet);
        //
        /*
        if(Test.isRunningTest() && StaticVariableHandler.crashTest) {   Purposely crash test.
            accounts.values()[0].Id = null;
        }*/  
        try {
            List<Database.upsertResult> uResults = Database.upsert(li_accountOutlet, false);
            // Iterate through each returned result
            for (Database.upsertResult sr : uResults) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                  //  System.debug('Successfully inserted/updated account. Account ID: ' + sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that affected this error: ' + err.getFields());
                    }
                }           
            }
        } catch(Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }                
    }

    public void updateRelatedStore(Map<Id, Outlet__c> newMap, Map<Id, Outlet__c> oldMap,
                                   Map<String, Id> outLetCategoryMap, Map<String, Id> stateIdMap) {


        Map<String, Outlet__c> mapOutletByMSid = new Map<String, Outlet__c>();

        for (Outlet__c outlet : newMap.values()) {
            if (outlet.Outlet_My_Sales_Id__c == null) {
                System.debug('Error: Outlet ' + outlet.Name + ' has no My Sales ID.');
            } else {
                String oMySalesId = String.valueOf(outlet.Outlet_My_Sales_Id__c.round());
                mapOutletByMSid.put(oMySalesId, outlet);
            }
        }

        List<RetailStore> retailStores = [SELECT Id, Name 
                                          FROM RetailStore
                                          WHERE My_Sales_ID__c IN :mapOutletByMSid.keySet()
                                          ];
    }

    public void insertRelatedStore(Map<Id, Outlet__c> newMap, Map<String,Id> stateIdMap,
                                   Map<String,Id> outLetCategoryMap) {

        List<RetailStore> storesToInsert = new List<RetailStore>();
        Id accountId;                                    

        for (Outlet__c outlet : newMap.values()) {
            if (outLetCategoryMap.get(outlet.Outlet_Category_Id__c) != null 
                && stateIdMap.get(outlet.State_ID__c) != null) {
                    RetailStore newStore = createNewStore(outlet, accountId);
                    storesToInsert.add(newStore);
                }
        }
    }

    private Static RetailStore createNewStore(Outlet__c outlet, Id parentId) {

        String oMySalesId;
        if (outlet.Outlet_My_Sales_Id__c == null) {
            System.debug('Error: Outlet ' + outlet.Name + ' has no My Sales ID.');
        } else {
            oMySalesId = String.valueOf(outlet.Outlet_My_Sales_Id__c.round());
        }

        //create address field 
        String add1  =  otlt.Address_Line_1__c!=null?otlt.Address_Line_1__c:'';
        String add2  =  otlt.Address_Line_2__c!=null?otlt.Address_Line_2__c:'';  
        String post  =  otlt.Post_Code__c!=null?otlt.Post_Code__c:''; 
        String city  =  otlt.Suburb__c!=null?otlt.Suburb__c:'';

        RetailStore newStore = new RetailStore(Name = outlet.Name,
                                               AccountId = parentId,
                                               My_Sales_ID__c = oMySalesId,
                                               ASM_User_ID__c = outlet.ASM_User_ID__c,
                                               Licence_Class__c = outlet.Licence_Class__c,
                                               Licence_Number__c = outlet.Licence_Number__c,
                                               Licence_Type_ID__c = outlet.Licence_Type_ID__c,
                                               LMAA_Code__c = outlet.LMAA_Code__c,
                                               New_Liqour_Licence_Number__c = outlet.New_Liqour_Licence_Number__c,
                                               Outlet_Category_ID__c = outlet.Outlet_Category_ID__c,
                                               Street = add1 + ' ' + add2,
                                               City = city,
                                               State = outlet.State_Name__c,
                                               PostalCode = outlet.Post_Code__c,
                                               OwnerId = outlet.OwnerId,
                                               Outlet__c = outlet.Id);
        if (String.isBlank(outlet.ASM_User_ID__c)) {
            newStore.Unallocated__c = true;
        }
        return newStore;
    }
}