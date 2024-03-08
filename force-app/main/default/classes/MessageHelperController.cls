/**
 * @author    : Created by Geeta Kushwaha on 17 Jan, 2014  geeta.kushwaha@arxxus.com
 * @Purpose   : Controller for MessageHelper
 				If the error code is found in custom setting ALM_Error_Messages__c, then, get the message from Error_Message__c field of ALM_Error_Messages__c
 				otherwise display ALM_error__c field from given SObject
 * @Criteria  : 
 * @Modified  : Geeta Kushwaha on 17 Jan, 2014 geeta.kushwaha@arxxus.com
 */
public class MessageHelperController {
	
	public String errorCode {get; set;}
	
	public string orderId {get;set;}
	
	public String objectType {get;set;}
	
	public String message {get; set;}
	
	public String getMessageValue(){
		
		message = null;
		
		for(ALM_Error_Messages__c msg : ALM_Error_Messages__c.getall().values()){
			
			if(msg.Error_Code__c.equals(errorCode)){
				
				message = msg.Error_Message__c;
				
				break;
				
			}
			
		}
		
		if(message == null){
			
			list<Sobject> records = database.query('Select id, ALM_error__c from '+objectType+' where id =: orderId');
			
			if(null != records && records.size() > 0){
				
				if (null != records[0].get('ALM_error__c')) {
					if (null == errorCode)
						errorCode = '';					
					message = errorCode.contains('HTTP Status Code: ')? 'of '+((String) records[0].get('ALM_error__c')) + '.' : 'of ' + (String) records[0].get('ALM_error__c');
				}								
				
			}
			
		}
		
		return message;
		
	}
	
	public MessageHelperController(){
		message = null;		
		
	}

}