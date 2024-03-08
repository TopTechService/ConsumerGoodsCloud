/**
* @Description : This batch class is for delete duplicate sales record and keep the latest record  
*/
global class DeleteDuplicateSalesBatch implements Database.Batchable<sObject>,database.stateful {
	
	public string query;
    global String emailBody ='' ;      
    
    /**
    *  Constructor 
    */
    global DeleteDuplicateSalesBatch(){
		query = 'SELECT IsDulpicate__c,CreatedDate,Id,Name'+
		          ' FROM Sale_MySales__c WHERE IsDulpicate__c = true';      
	        
    }  
       
    /**
    * Start Method
    */ 
    global Database.QueryLocator start(Database.BatchableContext BC){   
    	return Database.getQueryLocator(query);
    }
      
      
      
    /**
    * Execute Logic
    */      
    global void execute(Database.BatchableContext BC, List<Sale_MySales__c>scope){
        
        for(Sale_MySales__c sale : scope){
 			emailBody = emailBody + sale.id +','+sale.Name + '\n';
 		}
 		delete scope;
 	}
     
       
     /**  
     *  Finish - Send email contain deleted SalesId and Name to campari@arxxus.com
     */  
     global void finish(Database.BatchableContext BC){
       	emailBody = 'ID,Name \n' + emailBody ;
         // Get custom settings emails for errors sending
         String configEmail = Email_Configuration__c.getInstance('NotificationEmails').Email_Ids__c;
         List<String> configEmails = configEmail.split(',');
                
 		sendEmail('Duplicate SalesMysales deleted at-'+System.today(),configEmails,emailBody);
 	}
   	   
   	/**
   	* This methode is used to send email to campari@arxxus.com with deleted Sales Id and name 
   	*/ 
    private void sendEmail(String subject, String [] toAddress, String emailBody) {
    	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();     
        mail.setToAddresses(toAddress);
        mail.setSubject(subject);      
        mail.setPlainTextBody('Duplicate Sales deleted at' + System.today());
        mail.setUseSignature(false);       
        String testBody = emailBody; 
        Blob b = Blob.valueOf(emailBody);
		// Create the email attachment
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName('DeletedSales-'+System.today()+'.csv');
        efa.setBody(b);
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
 }