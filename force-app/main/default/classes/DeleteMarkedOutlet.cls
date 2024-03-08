public with sharing class DeleteMarkedOutlet {
    
    public void delWholesalerBranchOutlet() {
        try {
            List<Wholesaler_Branch_Outlet__c> wboDeleteList = new List<Wholesaler_Branch_Outlet__c>();
            wboDeleteList = [SELECT id, name, Wholesaler_Branch_My_Sales_Id__c, DeletedBy__c 
                             FROM Wholesaler_Branch_Outlet__c WHERE DeletedBy__c != null];
            if (!wboDeleteList.isEmpty()) {
                delete wboDeleteList;
                sendOutletDeletedMessage(wboDeleteList);
            }						
        } catch (Exception e) {
            sendOutletDeleteErrordMessage('Wholesaler_Branch_Outlet__c', e.getMessage());
        }				
    }
    
    public void delPromotionOutlet() {
        try {
            List<Promotion_Outlet__c> promotionOutletList = new List<Promotion_Outlet__c>();
            promotionOutletList = [SELECT PromotionOutlet_MySales_Id__c, Name, Id, DeletedBy__c 
                                   FROM Promotion_Outlet__c WHERE DeletedBy__c != null];
            if (!promotionOutletList.isEmpty()) {
                delete promotionOutletList;	
                sendOutletDeletedMessage(promotionOutletList);
            }					
        } catch (Exception e) {
            sendOutletDeleteErrordMessage('Promotion_Outlet__c', e.getMessage());			
        }
    }
    
    public void delOutlet() {
        try {
            List<Outlet__c> outletList = new List<Outlet__c>();
            List<Outlet__c> outletsToDeleteList = new List<Outlet__c>();
            outletList = [SELECT Outlet_My_Sales_Id__c, Name, Id, DeletedBy__c, MigratedToOutletId__c FROM Outlet__c 
                          WHERE DeletedBy__c != null AND MigratedToOutletId__c = null];
            System.debug('Delete outlet list :' + outletList);
            if (!outletList.isEmpty()) {
                delete outletList;
                sendOutletDeletedMessage(outletList);				
            }
        } catch (Exception e) {
            sendOutletDeleteErrordMessage('Outlet__c', e.getMessage());			
        }
    }	
    
    public void delBannerGroupOutlet() {
        try {
            List<Banner_Group_Outlet__c> bannerGroupOutletList = new List<Banner_Group_Outlet__c>();
            bannerGroupOutletList = [SELECT Id, DeletedBy__c, Banner_Group_Outlet_ID_My__c 
                                     FROM Banner_Group_Outlet__c WHERE DeletedBy__c != null]; 
            if (!bannerGroupOutletList.isEmpty()) {
                delete bannerGroupOutletList;
                sendOutletDeletedMessage(bannerGroupOutletList);
            }					
        } catch (Exception e) {
            sendOutletDeleteErrordMessage('Banner_Group_Outlet__c', e.getMessage());			
        }
        
        if (Test.isRunningTest()) {
            sendOutletDeleteErrordMessage('Banner_Group_Outlet__c', 'test exception');
        }		
    }
    
    public void sendOutletDeletedMessage(List<Sobject> objList) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();	
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String objName = '';
        if (null != objList[0]){
            Schema.SObjectType p = objList[0].getSObjectType();
            objName = p.getDescribe().getName();
            
            String subject = 'Records have been deleted successfully : ' +objName;
            email.setSubject(subject);	
            String body = 'Number of records :' + objList.size();
            email.setPlainTextBody(body);	
            List<String> toAddresses = new List<String>();
            // Get custom settings emails for errors sending
            String configEmails = Email_Configuration__c.getInstance('NotificationEmails').Email_Ids__c;
            toAddresses = configEmails.split(',');
            email.setToAddresses(toAddresses);
            emails.add(email);
            if(!emails.isEmpty()){
                Messaging.sendEmail(emails);
            }			
        }	
    }
    
    public void sendOutletDeleteErrordMessage(String objName, String exc) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();	
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        
        String subject = 'Exception occurred while deleting records : ' +objName;
        email.setSubject(subject);	
        String body = 'Exception :' + exc;
        email.setPlainTextBody(body);	
        List<String> toAddresses = new List<String>();
        // Get custom settings emails for errors sending
            String configEmails = Email_Configuration__c.getInstance('NotificationEmails').Email_Ids__c;
            toAddresses = configEmails.split(',');
        email.setToAddresses(toAddresses);			
        emails.add(email);
        if(!emails.isEmpty()){
            Messaging.sendEmail(emails);
        }			
    }
    
    public void mergeOutlet() {		
        String query = 'SELECT Id, DeletedBy__c, MigratedToOutletId__c, Name, Outlet_My_Sales_Id__c FROM Outlet__c WHERE DeletedBy__c != null '
            +'AND  MigratedToOutletId__c != null';		
        UpdateOutletFieldOfRecords batchUpdateRecords = new UpdateOutletFieldOfRecords(query);		
        Database.executeBatch(batchUpdateRecords, 1);		
    }	
    
}