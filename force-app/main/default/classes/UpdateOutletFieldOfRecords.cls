/**
* Description : class to merge outlets if MigratedToOutletId__c is set and valid
* class updates the reference of child records and deletes the merged outlet.
* if error occurred while updating ref of child records do not delete the outlet
* 
* Objects moved:
* 		Contacts
* 		Tasks
* 		Events - YB - Added 31/01/2019
* 		Sales Orders
* 		Sales MySales
* 		Wholeseller Branch Outlet
* 		Banner Group Outlets
* 		Promotion Outlets
* 		Attachments
* 		Files - YB - Added 31/01/2019
*		Asset Register - YB - Added 31/01/2019
*/ 
global class UpdateOutletFieldOfRecords implements Database.Batchable<sObject>, Database.Stateful {
    global final String query;        				
    global List<String> listOfErrorMessages;        // To maintain all failed records with error messag 
    global Set<Id> errorOutletIds;
    global String exceptionError; 
    global Set<Id> successOutletIds;    
    
    global UpdateOutletFieldOfRecords(String q) {
        // 	query = 'SELECT Id, DeletedBy__c, name, MigratedToOutletId__c, Outlet_My_Sales_Id__c  FROM Outlet__c WHERE DeletedBy__c != null'
        //							 +'AND  MigratedToOutletId__c != null';
        query = q;
        listOfErrorMessages = new List<String>();
        errorOutletIds = new Set<Id>();
        exceptionError = '';
        successOutletIds = new Set<Id>();
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {    		
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Outlet__c> scope) {
        // batch size 1
        System.debug('=========scope=========' + scope);   
        if (null == scope) {
            return;
        }
        Map<Id, Account> outletMap = new Map<Id ,Account>();
        Map<String, Id> outletIdvsSfId = new Map<String, Id>();
        List<Outlet__c> deleteOutletList = new List<Outlet__c>();
        
        try {				
            outletMap = getOutletMap(scope);
            outletIdvsSfId = getOutletIdVsSfIdMap(outletMap);
            if (null == outletMap || null == outletIdvsSfId) {
                return;
            }
            
            for (Outlet__c outlet : scope) {
                Id fromOutletId = outletIdvsSfId.get(outlet.name);
                Id toOutletId = outletIdvsSfId.get(outlet.migratedToOutletId__c);
                String toMySalesOutletId = outlet.migratedToOutletId__c;			    	
                if (null == fromOutletId) {
                    System.debug('Outlet Account not found for outlet id :' + outlet.name);
                } else if (null == toOutletId) {
                    System.debug('Outlet Account not found for outlet id :' + outlet.migratedToOutletId__c);			   			
                } else {
                    updateTasksAccount(toOutletId, fromOutletId);		// Task are not included in AND logic because of
                    // Unique field can cause validation exception during ref change 
                    updateEventsAccount(toOutletId, fromOutletId);		// Events are not included in AND logic because of
                    // Unique field can cause validation exception during ref change 
                    System.debug('## Before If Statement');
                    if (updateContactsAccount(toOutletId, fromOutletId) &&
                        updateSalesOrdersAccount(toOutletId, fromOutletId) &&
                        updateSalesMySalesAccount(toMySalesOutletId, fromOutletId) &&
                        //updateNoteAndAttachmentsAccount(toOutletId, fromOutletId) &&
                        updateFilesAccount(toOutletId, fromOutletId) &&
                        updateAssetRegistersAccount(toOutletId, fromOutletId) &&
                        updateWholesalerBranchOutlet(toOutletId,outlet.name)
                       ) { 
                            System.debug('## In If Statement');
                            List<Banner_Group_Outlet__c> bgOutletsToUpdate = checkBannerGroupOutlets(outletMap.get(fromOutletId), toOutletId);
                            List<Promotion_Outlet__c> promotionOutletsToUpdate = checkPromotionOutlets(outletMap.get(fromOutletId), toOutletId);
                            if (!promotionOutletsToUpdate.isEmpty()) {
                                updatePromotionOutlets(promotionOutletsToUpdate, outletMap.get(toOutletId)); 
                            }
                            if (!bgOutletsToUpdate.isEmpty()) {
                                updateBannerGroupOutlets(bgOutletsToUpdate, outletMap.get(toOutletId));
                            }
                            
                            successOutletIds.add(fromOutletId);				    				 		
                            deleteOutletList.add(outlet);					// Outlet Accounts are deleted from trigger					 
                            if(System.Test.isRunningTest()) {				// To test exception condition
                                errorOutletIds.add(fromOutletId);
                            }
                        } else {
                            System.debug('Error during merging for outlet :' + outlet.id);  //Delete outlet after successful merging.	
                            errorOutletIds.add(fromOutletId);       			
                        } 
                    System.debug('toOutletId : '+toOutletId+ ' fromOutletId :' + fromOutletId);
                }
            }
            
            if (!deleteOutletList.isEmpty()) {
                System.debug('Deleting outlet :' + deleteOutletList);  		// Delete outlet after successful merging.
                delete deleteOutletList;
                //	delete deleteOutletAccountList;
            }
            
        } catch (Exception e) {
            System.debug('**Exception while updating ' + e.getMessage());
            errorOutletIds.add(scope[0].id);							// Assuming batch size 1
            exceptionError = exceptionError +'============================' + e.getMessage();  	
        }			
    }
    
    global void finish(Database.BatchableContext BC){
        if (!listOfErrorMessages.isEmpty()) {
            System.debug('****Error Messages****' +listOfErrorMessages);
        }
        if (!errorOutletIds.isEmpty()) {
            List<String> toAddresses = new List<String>();
            // Get custom settings emails for errors sending
            String configEmails = Email_Configuration__c.getInstance('NotificationEmails').Email_Ids__c;
            toAddresses = configEmails.split(',');
            
            List<String> ccAddresses = new List<String>();
            String msg = '';
            for (Id err : errorOutletIds) {					
                msg += ' '+ err + ';';					
            }
            String body = 'Following outlets have not been deleted :' + msg + 'This ia due to following error' + exceptionError;
            SendEmail em = new SendEmail();
            em.sendEmailToUsers(toAddresses, ccAddresses, 'Exception occurred while Merging records : Accounts (Outlet)', body, body);		    			
        }
        if (!successOutletIds.isEmpty()) {
            List<String> toAddresses = new List<String>();
            
            // Get custom settings emails for errors sending
            String configEmails = Email_Configuration__c.getInstance('NotificationEmails').Email_Ids__c;
            toAddresses = configEmails.split(',');
            List<String> ccAddresses = new List<String>();
            System.debug('successOutletIds' +successOutletIds);
            String msg = '';
            for (Id s : successOutletIds) {					
                msg += ' '+ s + ';';					
            }		
            String body = 'Following outlets have been deleted successfully:' + msg;
            SendEmail em = new SendEmail();
            System.debug('toAddresses ' +toAddresses);
            System.debug('ccAddresses ' +ccAddresses);
            System.debug('body ' +body);
            em.sendEmailToUsers(toAddresses, ccAddresses, 'Outlet merging has been completed : Accounts (Outlet)', body, body);	    			
        }	    	
    }
    
    private Map<Id, Account> getOutletMap(List<Outlet__c> scope) {
        Id recTypeId = Utilities.getRecordTypeId('Account', 'Outlet');
        Map<Id, Account> outletMap = new Map<Id, Account>();
        Map<String, Id> outletIdvsSfId = new Map<String, Id>();
        for (Outlet__c out : scope) {
            if (null == out.Outlet_My_Sales_Id__c) {
                return null;
            }
            String outletMySalesId = string.valueof(out.Outlet_My_Sales_Id__c.round());
            outletIdvsSfId.put(outletMySalesId, null);					// Putting both 'To' and 'From'
            outletIdvsSfId.put(out.MigratedToOutletId__c, null);		// Outlet Id's
        }
        outletMap.putAll([SELECT id, name, outlet_ID__c, Banner_Group__c FROM Account WHERE outlet_ID__c IN : outletIdvsSfId.keySet()
                          AND recordTypeId = : recTypeId]);
        return outletMap;
    }
    
    private Map<String, Id> getOutletIdVsSfIdMap(Map<Id, Account> outletMap) {
        Map<String, Id> outletIdvsSfId = new Map<String, Id>();
        if (null == outletMap.values()) {
            return null;
        }			    
        System.debug(outletMap);
        for (Account acc : outletMap.values()) {
            outletIdvsSfId.put(acc.outlet_id__c, acc.id);
        }
        System.debug(outletIdvsSfId);
        return outletIdvsSfId;
    }    
    
    private List<Id> processSaveResult(Database.SaveResult[] srList, String objName) {
        // Iterate through each returned result
        List<Id> successList = new List<Id>();
        List<Id> errorList = new List<Id>();
        
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully inserted '+objName+'.  ID: ' + sr.getId());
                successList.add(sr.getId());
            }
            else {
                // Operation failed, get errors
                errorList.add(sr.getId());
                for (Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Account fields that affected this error: ' + err.getFields());
                    listOfErrorMessages.add(err.getMessage());
                }
            }
        }        
        return errorList;
    }
    
    private Boolean updateTasksAccount(Id toOutletId, Id fromOutletId) {
        List<Task> taskList = [SELECT id, WhatId FROM task WHERE AccountId = :fromOutletId AND isDeleted = false ALL ROWS];
        if (null == taskList) {
            System.debug('**No records found');
            return true;
        }         
        for (Task t : taskList) {
            t.WhatId = toOutletId;
        }
        Database.SaveResult[] sr = Database.update(taskList, false);
        List<Id> errorList = processSaveResult(sr, 'Task');
        if (!errorList.isEmpty()) {
            return false;
        } 
        return true;
    }
    
    public Boolean updateEventsAccount(Id toOutletId, Id fromOutletId) {
        List<Event> eventList = [SELECT id, WhatId FROM event WHERE AccountId = :fromOutletId AND isDeleted = false ALL ROWS];
        if (null == eventList) {
            System.debug('**No records found');
            return true;
        }         
        for (Event t : eventList) {
            t.WhatId = toOutletId;
        }
        Database.SaveResult[] sr = Database.update(eventList, false);
        List<Id> errorList = processSaveResult(sr, 'Event');
        System.debug('**errorList - Event');
        if (!errorList.isEmpty()) {
            return false;
        } 
        return true;
    }
    
    private Boolean updateContactsAccount(Id toOutletId, Id fromOutletId) {
        List<Contact> contactList = [SELECT id, AccountId, name, OwnerId FROM Contact WHERE AccountId =: fromOutletId];
        if (null == contactList) {
            System.debug('**No records found');
            return true;
        }        
        for (Contact con: contactList) {
            con.AccountId = toOutletId;
        }
        Database.SaveResult[] sr = Database.update(contactList, false);
        List<Id> errorList = processSaveResult(sr, 'Contacts');	
        for(database.saveresult er : sr){
            exceptionError = exceptionError +'============================' + er.getErrors(); 
        } 
        
        if (!errorList.isEmpty()) {
            errorOutletIds.add(fromOutletId);     
            return false;
        } 
        return true;
    }
    
    private Boolean updateSalesOrdersAccount(Id toOutletId, Id fromOutletId) {
        List<Sales_Order__c> salesOrdersList = [SELECT id, Outlet_Name__c, name FROM Sales_Order__c
                                                WHERE Outlet_Name__c =: fromOutletId];
        if (null == salesOrdersList) {
            System.debug('**No records found');
            return true;
        }
        for (Sales_Order__c so: salesOrdersList) {
            so.Outlet_Name__c = toOutletId;
        }
        Database.SaveResult[] sr = Database.update(salesOrdersList, false);
        List<Id> errorList = processSaveResult(sr, 'SalesOrders');	
        
        for(database.saveresult er : sr){
            exceptionError = exceptionError +'============================' + er.getErrors(); 
        } 
        
        if (!errorList.isEmpty()) {
            errorOutletIds.add(fromOutletId);  
            return false;
        } 
        return true;
    }
    
    //	to update salesMySales we need MySalesOutletId
    private Boolean updateSalesMySalesAccount(String toMySalesOutletId, Id fromOutletId) {
        List<Sale_MySales__c> salesList = [SELECT id, Outlet__c, OutletID__c, name, OwnerId FROM Sale_MySales__c
                                           WHERE Outlet__c =: fromOutletId];
        if (null == salesList) {
            System.debug('**No records found');
            return true;
        }     		
        for (Sale_MySales__c sales: salesList) {
            sales.OutletID__c = toMySalesOutletId;
        }
        Database.SaveResult[] sr = Database.update(salesList, false);
        List<Id> errorList = processSaveResult(sr, 'SalesMySales');	
        
        for(database.saveresult er : sr){
            exceptionError = exceptionError +'============================' + er.getErrors(); 
        } 
        
        if (!errorList.isEmpty()) {
            errorOutletIds.add(fromOutletId);  
            return false;
        } 
        return true;
    }
    
    //	to update Wholesaler Branch Outlet 
    private Boolean updateWholesalerBranchOutlet(String toOutletId, String fromOutletId) {
        System.debug('**toOutletId' + toOutletId);
        System.debug('**NfromOutletId' + fromOutletId);
        List<Wholesaler_Branch_Outlet__c> WholesalerBranchOutlets = [SELECT CreatedById,CreatedDate,Customer_Number__c,DeletedBy__c,End_Date__c,Id,
                                                                     Name,Outlet_Account__c,Outlet_ID__c,WholeSalerAccountId__c,
                                                                     Wholesaler_Branch_ID__c,
                                                                     Wholesaler_Branch_My_Sales_Id__c,Wholesaler_Branch__c 
                                                                     FROM Wholesaler_Branch_Outlet__c 
                                                                     WHERE Outlet_ID__c =: fromOutletId];
        
        Account acct = [SELECT ID,Name,Outlet_ID__c
                        FROM Account 
                        WHERE ID = : toOutletId LIMIT 1];
        
        if (null == WholesalerBranchOutlets) {
            System.debug('**No records found');
            return true;
        }     		
        for (Wholesaler_Branch_Outlet__c wbo: WholesalerBranchOutlets) {
            wbo.Outlet_Account__c = acct.id;
            wbo.Outlet_ID__c = acct.Outlet_ID__c;
        } 
        Database.SaveResult[] sr = Database.update(WholesalerBranchOutlets, false);
        
        System.debug('**Database.SaveResult[] sr' + sr);
        system.debug('==WholesalerBranchOutlets=' + WholesalerBranchOutlets);
        List<Id> errorList = processSaveResult(sr, 'Wholesaler_Branch_Outlet__c');	 
        for(database.saveresult er : sr){
            exceptionError = exceptionError +'============================' + er.getErrors(); 
        } 
        if (!errorList.isEmpty()) {
            errorOutletIds.add(fromOutletId);
            return false;
        }  
        return true;
    }
    
    /*private Boolean updateNoteAndAttachmentsAccount(Id toOutletId, Id fromOutletId) {
        List<Note> notesList = [SELECT Title, SystemModstamp, ParentId, OwnerId, LastModifiedDate, LastModifiedById,
                                IsPrivate, IsDeleted, Id, CreatedDate, CreatedById, Body
                                FROM Note WHERE parentId =: fromOutletId];
        if (null == notesList) {
            System.debug('**No records found for notes');
            notesList = new List<Note>();
        }        
        List<Note> newNoteList = new List<Note>();
        List<Note> delNoteList = new List<Note>();       
        for (Note no: notesList) {
            Note newNote = no.clone(false, false);
            newNote.parentId = toOutletId;
            newNoteList.add(newNote);
            delNoteList.add(no);            
        }
        List<Attachment> attachList = [SELECT SystemModstamp, ParentId, OwnerId, Name, 
                                       LastModifiedDate, LastModifiedById, IsPrivate, IsDeleted, 
                                       Id, Description, CreatedDate, CreatedById, ContentType, 
                                       BodyLength, Body FROM Attachment WHERE parentId =: fromOutletId];
        
        if (null == attachList) {
            System.debug('**No records found for Attachment');
            attachList = new List<Attachment>();
        }    		
        List<Attachment> newAttachList = new List<Attachment>();
        List<Attachment> delAttachList = new List<Attachment>(); 
        List<Id> errorList = new List<Id>();
        List<Id> errorList1 = new List<Id>();
        
        for (Attachment attach: attachList) {
            Attachment newAttach = attach.clone(false, false);
            newAttach.parentId = toOutletId;
            newAttachList.add(newAttach);
            delAttachList.add(attach);            
        }
        
        if (!newNoteList.isEmpty()) {
            Database.SaveResult[] sr = Database.insert(newNoteList, false);        		
            errorList = processSaveResult(sr, 'Note'); 
            for(database.saveresult er : sr){
                exceptionError = exceptionError +'============================' + er.getErrors(); 
            }              			
        }
        if (!newAttachList.isEmpty()) {
            Database.SaveResult[] sr1 = Database.insert(newAttachList, false);
            errorList1 = processSaveResult(sr1, 'Attachment');
            for(database.saveresult er : sr1){
                exceptionError = exceptionError +'============================' + er.getErrors(); 
            } 
        }			
        if (!delNoteList.isEmpty()) {
            delete delNoteList;				
        }
        if (!delAttachList.isEmpty()) {
            delete delAttachList;				
        }
        if (errorList.isEmpty() && errorList1.isEmpty()) 
            return true;
        errorOutletIds.add(fromOutletId); 
        
        
        return false;
    }*/
    
    private Boolean updateFilesAccount(Id toOutletId, Id fromOutletId) {
        List<ContentDocumentLink> fileList = [SELECT ContentDocumentId,Id,IsDeleted,LinkedEntityId,ShareType,SystemModstamp,Visibility FROM ContentDocumentLink WHERE LinkedEntityId = :fromOutletId AND isDeleted = false ALL ROWS];
        if (null == fileList) {
            System.debug('**No records found');
            return true;
        } 
        
        List<ContentDocumentLink> insertLinks = new List<ContentDocumentLink>();
        List<ContentDocumentLink> deleteLinks = new List<ContentDocumentLink>();
        
        for (ContentDocumentLink t : fileList) {
            //t.LinkedEntityId = toOutletId;
            
            ContentDocumentLink newclnk = t.clone();
  			newclnk.linkedentityid = toOutletId; //This ID is the Account the file needs to be move to.
            insertLinks.add(newclnk);
           deleteLinks.add(t);
           
        }
    
		//Insert the new ContentDocumentLink Linked to the new account.
        Database.SaveResult[] sr = Database.insert(insertLinks, false);

		//Delete the old ContentDocumentLink Linked to the old account.
        Database.SaveResult[] sr1 = Database.update(deleteLinks, false);

        List<Id> errorList = processSaveResult(sr, 'ContentDocumentLink');
		List<Id> errorList2 = processSaveResult(sr1, 'ContentDocumentLink');
        if (!errorList.isEmpty() || !errorList2.isEmpty()) {
            return false;
        } 
        return true;
    }
    
    private Boolean updateAssetRegistersAccount(Id toOutletId, Id fromOutletId) {
        List<Asset_Register__c > assetList = [SELECT Id, Account__c FROM Asset_Register__c WHERE Account__c = :fromOutletId AND isDeleted = false ALL ROWS];
        if (null == assetList) {
            System.debug('**No records found');
            return true;
        }         
        for (Asset_Register__c  t : assetList) {
            t.Account__c  = toOutletId;
        }
        Database.SaveResult[] sr = Database.update(assetList, false);
        List<Id> errorList = processSaveResult(sr, 'Asset_Register__c');
        if (!errorList.isEmpty()) {
            return false;
        } 
        return true;
    }
    
    /**
*Method to returns list of Banner_Group_Outlet__c to update there outlet account ref
*when there is no record for corresponding promotion on new outlet.
*If there is record for corresponding Banner group on new outlet then the Banner_Group_Outlet__c
*record will not be updated and will get deleted with parent Outlet account (due to master detail relationship)
*/	
    public List<Banner_Group_Outlet__c>  checkBannerGroupOutlets(Account oldOutlet, Id newOutletId) {
        List<Banner_Group_Outlet__c> bgOutletListForOldOutlet = new List<Banner_Group_Outlet__c>();
        List<Banner_Group_Outlet__c> bgOutletListForNewOutlet = new List<Banner_Group_Outlet__c>();
        bgOutletListForOldOutlet = [SELECT id, name, Banner_Group_Account__c FROM Banner_Group_Outlet__c
                                    WHERE Outlet_Account__c =: oldOutlet.id];
        bgOutletListForNewOutlet = [SELECT id, name, Banner_Group_Account__c FROM Banner_Group_Outlet__c 
                                    WHERE Outlet_Account__c =: newOutletId];
        List<Banner_Group_Outlet__c> updateList = new List<Banner_Group_Outlet__c>();
        for (Banner_Group_Outlet__c bgOutletOld : bgOutletListForOldOutlet) {
            Boolean flag = false;
            // get Promotion_Outlet__c where Promotion is pOutlet.Promotion__c and Outlet is newOutletId
            for (Banner_Group_Outlet__c bgOutletNew : bgOutletListForNewOutlet) {
                if (bgOutletOld.Banner_Group_Account__c == bgOutletNew.Banner_Group_Account__c) {
                    //Record found for outlet promotion and newOutletId
                    flag = true;					
                    break;
                } 
            }
            if (!flag) {
                //Update the outlet ref of Banner_Group_Outlet__c
                updateList.add(bgOutletOld);			
            }			
        }
        System.debug('**checkBannerGroupOutlets updateList :' + updateList);
        return updateList;
    }	
    
    public Boolean updateBannerGroupOutlets(List<Banner_Group_Outlet__c> bgOutletList, Account toOutlet) {
        for (Banner_Group_Outlet__c bgOutlet : bgOutletList) {
            bgOutlet.outlet_account__c = toOutlet.id;
            bgOutlet.outlet_ID__c = toOutlet.outlet_ID__c;
        }
        Database.SaveResult[] sr = Database.update(bgOutletList, false);
        List<Id> errorList = processSaveResult(sr, 'Banner_Group_Outlet__c'); 
        if (errorList.isEmpty()) {
            return true;
        } else {
            return false;
        }		
    }
    
    /**
*Method to returns list of Promotion_Outlet__c to update there outlet account ref
*when there is no record for corresponding promotion on new outlet.
*If there is record for corresponding promotion on new outlet then the Promotion_Outlet__c
*record will not be updated and will get deleted with parent Outlet account (due to master detail relationship)
*/
    public List<Promotion_Outlet__c> checkPromotionOutlets(Account oldOutlet, Id newOutletId) {
        List<Promotion_Outlet__c> pOutletListForOldOutlet = new List<Promotion_Outlet__c>();
        List<Promotion_Outlet__c> pOutletListForNewOutlet = new List<Promotion_Outlet__c>();
        pOutletListForOldOutlet = [SELECT id, name, Promotion__c, Outlet_Account__c FROM Promotion_Outlet__c
                                   WHERE Outlet_Account__c =: oldOutlet.id];
        pOutletListForNewOutlet = [SELECT id, name, Promotion__c, Outlet_Account__c FROM Promotion_Outlet__c 
                                   WHERE Outlet_Account__c =: newOutletId];
        List<Promotion_Outlet__c> updateList = new List<Promotion_Outlet__c>();
        for (Promotion_Outlet__c pOutletOld : pOutletListForOldOutlet) {
            Boolean flag = false;		
            // get Promotion_Outlet__c where Promotion is pOutlet.Promotion__c and Outlet is newOutletId
            for (Promotion_Outlet__c pOutletNew : pOutletListForNewOutlet) {
                if (pOutletOld.Promotion__c == pOutletNew.Promotion__c) {
                    
                    //Record found for outlet promotion and newOutletId
                    flag = true;					
                    break;
                } 
            }
            if (!flag) {
                //Update the outlet ref of Promotion_Outlet__c
                updateList.add(pOutletOld);			
            }			
        }
        System.debug('**checkPromotionOutlets updateList :' + updateList);
        return updateList;
    }
    
    public Boolean updatePromotionOutlets(List<Promotion_Outlet__c> promotionOutletList, Account toOutlet) {		
        for (Promotion_Outlet__c prmOutlet : promotionOutletList) {
            prmOutlet.outlet_account__c = toOutlet.id;
            prmOutlet.outlet_id__c = toOutlet.outlet_ID__c;
        }
        
        /** 
* error test
*/	
        if (Test.isRunningTest()) {
            Promotion_Outlet__c prm = new Promotion_Outlet__c();
            promotionOutletList.add(prm);			
        }
        Database.SaveResult[] sr = Database.update(promotionOutletList, false);
        List<Id> errorList = processSaveResult(sr, 'Promotion_Outlet__c'); 
        if (errorList.isEmpty()) {
            return true;
        } else {
            return false;
        }	
    }		
}