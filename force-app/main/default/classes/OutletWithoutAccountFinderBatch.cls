global class OutletWithoutAccountFinderBatch implements Database.Batchable<sObject> , Database.Stateful {

   global final String Query;
   global map<String,Outlet__c> outletWitoutAccountMap = new Map<String,Outlet__c>();
   global map<String,Outlet__c> outletWithDifferentAccountName = new map<String,Outlet__c>();
    global OutletWithoutAccountFinderBatch(){
        
       Query = 'SELECT Id,Name,Outlet_My_Sales_Id__c,Outlet_Name__c,OwnerId,Tele_Sales_User_ID__c FROM Outlet__c';
   }

   global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(query);
   }

   global void execute(Database.BatchableContext BC, List<Outlet__c> outlets){
       set<string> outletIds = new set<string>();
       for(Outlet__c outlet : outlets){
           outletIds.add(outlet.name);
       }
        system.debug('======outletIds=======' + outletIds);
       map<string,Account> OutletIdVsAccount = new map<string,Account>();
       for(Account acct : [SELECT Name,Outlet_ID__c FROM Account WHERE Outlet_ID__c in : outletIds]){
           
           if(! String.isEmpty(acct.Outlet_ID__c))
           OutletIdVsAccount.put(acct.Outlet_ID__c,acct);
       }
       system.debug('======OutletIdVsAccount=======' + OutletIdVsAccount);
       
       for(Outlet__c outlet : outlets){
           if(!OutletIdVsAccount.containsKey(outlet.name)){
               outletWitoutAccountMap.put(outlet.name,outlet);
           }else if(OutletIdVsAccount.get(outlet.name).name != outlet.Outlet_Name__c){
               outletWithDifferentAccountName.put(outlet.name,outlet);
           }
       }
       system.debug('====outletWitoutAccountMap in execute===' + outletWitoutAccountMap);
       system.debug('====outletWithDifferentAccountName in execute===' + outletWithDifferentAccountName);
   }

   global void finish(Database.BatchableContext BC){
   		
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();     
       if(Email_Configuration__c.getAll().isEmpty()){
           Email_Configuration__c cong = new Email_Configuration__c(name = 'Outlets without account Email',Email_Ids__c = 'campari@arxxus.com');
           insert cong;
       }
        Email_Configuration__c emailConfig = Email_Configuration__c.getInstance('Outlets without account Email');
        
        mail.setToAddresses(emailConfig.Email_Ids__c.split(','));
        mail.setSubject('Outlets without account ');      
        mail.setPlainTextBody('Please find attached csv file which contain all the outlets without account ' + Date.today() );
        mail.setUseSignature(false);       
        
        Blob b = Blob.valueOf(outletWithoutAccountBody());

        // Create the email 
        list< Messaging.EmailFileAttachment>  efaList = new list< Messaging.EmailFileAttachment>();
        // Attachment for attachment Outlets without accounts
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName('Outlets without accounts.csv');
        efa.setBody(b);
        efaList.add(efa);
        
        // Attachment for outlets with different account Name
        efa = new Messaging.EmailFileAttachment();
        efa.setFileName('Outlets with different account Name.csv');
        b = Blob.valueOf(outletWithDifferentNameBody()); 
        efa.setBody(b);
        efaList.add(efa);
        mail.setFileAttachments( efaList);
        List<Messaging.SendEmailResult> result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
   }

    /**
    * @desc - This method is responsible to get the body for outlets without account
    */
    private string outletWithoutAccountBody(){
        string bady = 'Id,OutletId,Outlet Name\n';
        for(string bdy : outletWitoutAccountMap.keySet()){
            bady = bady + outletWitoutAccountMap.get(bdy).id + ',' + bdy +',' +outletWitoutAccountMap.get(bdy).outlet_Name__c +'\n'; 
        }
       return  bady;
    }
    
    /**
    * @desc - This method is responsible to get the body for outlets with different account Name 
    */
    private string outletWithDifferentNameBody(){
        string bady = 'Id,OutletId,Outlet Name\n';
        for(string bdy : outletWithDifferentAccountName.keyset()){
            bady = bady + outletWithDifferentAccountName.get(bdy).id +','+bdy +',' +outletWithDifferentAccountName.get(bdy).outlet_Name__c +'\n'; 
        }
       return  bady;
        
    }
}