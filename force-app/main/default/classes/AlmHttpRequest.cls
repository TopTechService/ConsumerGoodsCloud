/**
 * Author :Gunwant patidar
 * @created date : 9/4/2013
 * Description : This class make callout to ALM server and recieve response
 * @modified: Geeta Kushwaha 23 Jan, 2014 When ALM server is down, the request sent should be captured and appropriate notification should be sent to Owner
 */
public abstract class AlmHttpRequest {
  Public String request;
  Public static Integer statusCode;
  Public String responseBody;
   
  //Private String userName;
  //Private String passWord;
  Private String contentType;
  Private String encoding;
  Private Integer timeOut;
  Private Boolean resendRequest;
  
  Public AlmHttpRequest(){
    if(ALM_Configuration__c.getInstance('Configuration') != null) {
      if(ALM_Configuration__c.getInstance('Configuration').Username__c != null) {
        //username = ALM_Configuration__c.getInstance('Configuration').Username__c;
      }
      if(ALM_Configuration__c.getInstance('Configuration').Password__c != null) {
        //password = ALM_Configuration__c.getInstance('Configuration').Password__c;
      }
      if(ALM_Configuration__c.getInstance('Configuration').ContentType__c != null) {
        contentType = ALM_Configuration__c.getInstance('Configuration').ContentType__c;
      }
            
      if(ALM_Configuration__c.getInstance('Configuration').Encoding__c != null) {
        encoding = ALM_Configuration__c.getInstance('Configuration').Encoding__c;
        timeout = integer.valueOf(ALM_Configuration__c.getInstance('Configuration').Timeout__c);
      }
      
      resendRequest = false;
    } 
  }
  
  Public abstract String getUserName();
  
  Public abstract String getPassword();
  
  // abstract methods
  // creates order's xml soap request
  Public abstract String makeSoapRequest();
  // fetches SoapAction url
  Public abstract String getSoapAction();
  // fetches Soap header 
  Public abstract String getSoapHeader();
  // fetches EntPoint of webservice
  Public abstract String getEndPoint();
  // parse response received from webservice
  Public abstract void parseResponse(String response, String request);
  
  Public abstract void updatesalesordertoSendEmail(String req, String resp);
  	
  Public abstract void resendRequest();  	
  
  Public abstract void updatesalesordertoSendEmailUnexpectedStatusCode(String req, String resp, Integer codeOfStatus, String status );
  
  /**
   * Author : Gunwant Patidar
   * @created date : 06/05/2013
   * @description : this method send order xml to ALM server and get response from ALM
       Calls parseResponse() method to parse the response 
   */
  Public void invokeHttpRequest(){

	HttpRequest httpReq;
	try {    	
      responseBody = null;
      
      httpReq = new HttpRequest();
      httpReq.setMethod('POST');
      httpReq.setEndPoint(getEndPoint()); 
      httpReq.setHeader('SOAPAction',getSoapAction()); 
      httpReq.setHeader('Content-type', contentType);
      httpReq.setHeader('Encoding', encoding);
      
      if (timeOut != null && timeout > 0) {
          httpReq.setTimeout(timeout);
      } else {
        httpReq.setTimeout(120000);
      }
      
      String s = makeSoapRequest();
      
      httpReq.setBody(s);
      
      request = httpReq.getBody();
    
      //Send http request
      Http htp = new Http();
      HttpResponse response;      
      if(Test.isRunningTest()){
      	 response = new HttpResponse();
      }else{
      	 response = htp.send(httpReq);
      }
      processResponse(response, httpReq);
     
    } catch (CalloutException ex) {
    	try {
    		// Retry send in case of time out
 		      Http htp = new Http();    		
			  HttpResponse response;      
		      if(Test.isRunningTest()){
		      	 response = new HttpResponse();
		      }else{
		      	 response = htp.send(httpReq);
		      }
		      processResponse(response, httpReq);
    	} catch (Exception e) {
    		responseBody = 'Failed to send order to ALM : ' + e.getMessage() + ' ' + e.getCause();
    		updatesalesordertoSendEmail(request, responseBody);    
    	}    	 
    }
	     
  }
  	
  public void processResponse(HttpResponse response, HttpRequest httpReq) {
  	  statusCode = response.getStatusCode();
      responseBody = response.getBody();      
      
      if(statusCode == 200){

        responseBody = responseBody.replace('<?xml version="1.0" encoding="UTF-8"?><SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"><SOAP-ENV:Body><ns0:submitSupplierOrderReturn xmlns:ns0="http://services.metcash.com/xsd/ALMiPortal"><ns0:submitSupplierOrderReturn>&lt;?xml version="1.0" encoding="UTF-8"?&gt;','');
        responseBody = responseBody.replace('</ns0:submitSupplierOrderReturn></ns0:submitSupplierOrderReturn></SOAP-ENV:Body></SOAP-ENV:Envelope>','');
        responseBody = responseBody.replace('&gt;','>');
        responseBody = responseBody.replace('&lt;','<');
        responseBody = responseBody.replace('\n','');
        // send response to parse it and update the sales order records          
        parseResponse(responseBody,httpReq.getBody());
        
      }
	  /*
	   * @author Geeta Kushwaha
	   * This is default handler when ALM HTTP response code is unexpected
	   * This code executes when ALM server is down
	   */ 
      
      /*
       * When there is validation error or authentication failed status code returned by server is 500
       */
      else if(statusCode == 500){
      	  // resend the request with diffrent 
          if (!resendRequest) {
    //      updatesalesordertoSendEmail(httpReq.getBody(), responseBody);	          	
          	resendRequest = true;
          	resendRequest();
			invokeHttpRequest();	          		
          } else {
          	updatesalesordertoSendEmail(httpReq.getBody(), responseBody);
          }
          
      } else {      	
  		updatesalesordertoSendEmailUnexpectedStatusCode(httpReq.getBody(), responseBody, statusCode, response.getStatus()  );
   	 }
  }
}