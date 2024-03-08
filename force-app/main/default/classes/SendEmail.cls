/**
 * @author    : Created by Geeta Kushwaha on 15 May, 2013  geeta.kushwaha@arxxus.com
 * @Purpose   : Send Email to given email Id along with Attachment
 * @Criteria  : 
 * @Modified  : Geeta Kushwaha on 16 May, 2013 geeta.kushwaha@arxxus.com
 */
public class SendEmail {
	
	map <Id,UserRole> ur;
	
	list <User> recipients;
	
	/*
	 * Invoke this for sending a single email to multiple users not more than 10 
	 */    
    public void sendEmailToUsers(list<string> toAddresses, list<string> ccAddresses, string subject, string plainTextBody, string htmlbody){
        
        try{
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
            
            email.setToAddresses(toAddresses);
            
            email.setCcAddresses(ccAddresses);
            
            email.setBccSender(false);
            
            email.setSenderDisplayName(UserInfo.getName());
            
            email.setSubject(subject);
            
            email.setUseSignature(true);
            
            //email.setReplyTo('support@acme.com');
            
            email.setPlainTextBody(plainTextBody);
            
            email.setHtmlBody(htmlbody);
            
            Messaging.SendEmailResult [] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            
            Messaging.SendEmailError[] errors = new List<Messaging.SendEmailError>();
            
            String emailErrorReport = '';

			for( Messaging.SendEmailResult currentResult : results ) {
			
				errors = currentResult.getErrors();
				
				if( null != errors ) {
				
				   for( Messaging.SendEmailError currentError : errors ) {
				
				       emailErrorReport = emailErrorReport + '(' +  currentError.getStatusCode() + ') ' + currentError.getMessage() + '\r' ;
				
				   }
			
			    }
			
			}
			
			if(emailErrorReport != '') {
				
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error in sending email. Error details are : '+emailErrorReport));
				
			}
              
        }
        
        catch(exception e){
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error in sending email. Please try again later.'));
            
        }
        
    }
    
    /*
     * Send email to many users
     */
    public void sendEmailToManyUsers(list<string> toAddresses, string subject, list <string> plainTextBody, list <string> htmlbody){
        
        try{
        	
            list<Messaging.SingleEmailMessage> allMails = new list<Messaging.SingleEmailMessage>();
            
            integer currentEmail = 0;
            
          
            
            for(String to : toAddresses){
        	
	            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
	            
	            email.setToAddresses(new list <String> {to});
	            
	            email.setBccSender(false);
	            
	            email.setSenderDisplayName(UserInfo.getName());
	            
	            email.setSubject(subject);
	            
	            email.setUseSignature(true);
	            
	            email.setPlainTextBody(plainTextBody[currentEmail]);
	            
	            email.setHtmlBody(htmlbody[currentEmail]);
	            
	            if(email != null)
	               allMails.add(email);
	            
	            currentEmail++;
            
            }
            
            Messaging.SendEmailResult [] results = Messaging.sendEmail(allMails);
            
            Messaging.SendEmailError[] errors = new List<Messaging.SendEmailError>();
            
            String emailErrorReport = '';

            for( Messaging.SendEmailResult currentResult : results ) {
            
                errors = currentResult.getErrors();
                
                if( null != errors ) {
                
                   for( Messaging.SendEmailError currentError : errors ) {
                
                       emailErrorReport = emailErrorReport + '(' +  currentError.getStatusCode() + ') ' + currentError.getMessage() + '\r' ;
                
                   }
            
                }
            
            }
            
            if(emailErrorReport != '') {
                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error in sending email. Error details are : '+emailErrorReport));
                
            }
              
        }
        
        catch(exception e){
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error in sending email to manager. Please contact administrator.'));
            
        }
        
    }    
    
}