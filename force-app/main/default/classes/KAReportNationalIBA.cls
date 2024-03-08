/*
 * Class Name : KAReportNationalIBA
 * Description - This class is used for sending proposed Ka Report by email on schedule
                 Applied filters are: IBA and National
 * @author Geeta Kushwaha (geeta.kushwaha@arxxus.com)
 * @revised : 24-12-2013 [created by Geeta Kushwaha]
 * 
 */ 
global class KAReportNationalIBA implements schedulable
{

    global final String bannerGroupName1;
    
    global final String bannerGroupName2;
    
    global final String bannerGroupName3;	
    
    global final String emailAddress;
    
    global final String bannerGroupId;
    
    public KAReportNationalIBA(){
    	
    	this.bannerGroupId = Utilities.getRecordTypeId('Account', 'Banner Group');
    	
    	this.bannerGroupName1 = 'IBA';
    	
    	this.bannerGroupName2 = 'LMG';
    	
    	this.bannerGroupName3 = 'LA';
    	
    	try {
    	
    	   this.emailAddress = KAReportEmail__c.getall().values()[0].Name;
    	   
    	}
    	
    	catch(Exception e){
    		
    		this.emailAddress = 'campari@arxxus.com';
    		
    	}   
    	
    }
	
    global void execute(SchedulableContext sc)
    {
    	
    	try {
    		
    		Account bannerGroup = [Select id, My_Sales_Id__c 
                                   from Account
                                   where RecordTypeId =: bannerGroupId
                                   and My_Sales_Id__c != null
                                   and Name =: bannerGroupName1
                                   order by Name ASC LIMIT 1];
    	
    	
	        KAReportBatchProcessor b = new KAReportBatchProcessor(bannerGroup.Id,bannerGroupName1,emailAddress, bannerGroup.My_Sales_Id__c );
	       
	        database.executebatch(b);
      
    	}
    	
    	catch(QueryException e) {
    		
    		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

	        mail.setToAddresses(new String[] {'campari@arxxus.com'});
	        mail.setSenderDisplayName('Batch Processing');
	        mail.setSubject('Batch Process Failed');
	        mail.setPlainTextBody('Could Not locate the Banner Group record with name '+bannerGroupName1);
	        
	        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    		
    	}
    	
    	try {
            
            Account bannerGroup = [Select id, My_Sales_Id__c 
                                   from Account
                                   where RecordTypeId =: bannerGroupId
                                   and My_Sales_Id__c != null
                                   and Name =: bannerGroupName2
                                   order by Name ASC LIMIT 1];
        
        
            KAReportBatchProcessor b = new KAReportBatchProcessor(bannerGroup.Id,bannerGroupName1,emailAddress, bannerGroup.My_Sales_Id__c );
           
            database.executebatch(b);
      
        }
        
        catch(QueryException e) {
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

            mail.setToAddresses(new String[] {'campari@arxxus.com'});
            mail.setSenderDisplayName('Batch Processing');
            mail.setSubject('Batch Process Failed');
            mail.setPlainTextBody('Could Not locate the Banner Group record with name '+bannerGroupName2);
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
        }
        
        try {
            
            Account bannerGroup = [Select id, My_Sales_Id__c 
                                   from Account
                                   where RecordTypeId =: bannerGroupId
                                   and My_Sales_Id__c != null
                                   and Name =: bannerGroupName3
                                   order by Name ASC LIMIT 1];
        
        
            KAReportBatchProcessor b = new KAReportBatchProcessor(bannerGroup.Id,bannerGroupName3,emailAddress, bannerGroup.My_Sales_Id__c );
           
            database.executebatch(b);
      
        }
        
        catch(QueryException e) {
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

            mail.setToAddresses(new String[] {'campari@arxxus.com'});
            mail.setSenderDisplayName('Batch Processing');
            mail.setSubject('Batch Process Failed');
            mail.setPlainTextBody('Could Not locate the Banner Group record with name '+bannerGroupName3);
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
        }
      
    }
    
}