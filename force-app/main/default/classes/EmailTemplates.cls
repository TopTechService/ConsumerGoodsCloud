/**
 * @author    : Created by Geeta Kushwaha on 16 Mar, 2013  geeta.kushwaha@arxxus.com
 * @Purpose   : Generate email template text
 * @Criteria  :  
 * @Modified  : 
 */
public class EmailTemplates {
	

	/*
	 * This method populates the text to be sent to manager on click of 'Send Mail To Manager'
	 * Called From Call Planning & Objective Management
	 * This generates the body of mail to be sent along with the URL
	 */
	
	public list <String> submitPlanToManager(String managerName, String userName, String selectedCallCycle, String selectedYear,String selectedOutlet,
												String pageUrl, String translatedMonth, String month, String embed){
		
		list <String> body = new list<string>();
		
		integer index = pageUrl.indexOf('?');
		
		if(index != -1) {
		
		    pageUrl = pageUrl.substring(0,index);
		
		}
		
		String urlStr = URL.getSalesforceBaseUrl().toExternalForm()+pageUrl+'?yr='+selectedYear+'&uId='+selectedOutlet;
		
		if(selectedCallCycle != '' && selectedCallCycle != null)
		
		  urlStr+='&scc='+selectedCallCycle;
		  
		if(month!='' && month != null)
		
		  urlStr += '&month='+month;  
        
        urlStr = urlStr.replaceAll(' ','%20');

        
        String textBody = label.Hi+' '+managerName+',\n\n'+UserInfo.getName();
        
		if(month != null  )  		
		    textBody += label.has+' '+ translatedMonth+' '+label.visitplan+' '+urlStr+' \n\n'+label.thankyou;		    
		else		
		     textBody += ' has sent '+embed+'plan for ' + selectedCallCycle+', '+selectedYear+'. URL is: '+urlStr;
            
		body.add(textBody);
        
        String htmlBody = '<html><font face="arial"><body>'+label.Hi+' '+managerName+',<br/><br/>'+UserInfo.getName();
        
        if(month != null  )            
            htmlBody += ' '+label.has+' '+translatedMonth+' '+label.visitplan+' <a href="'+urlStr+'">'+urlStr+'</a><br/><br/>'+label.thankyou+'</font></body></html>';        
        else        
            htmlBody += ' has sent ' + embed + 'plan for ' + selectedCallCycle + ', ' + selectedYear + '.<br/> URL is: <a href="'+urlStr+'">' + selectedCallCycle + '</a><br/><br/>' + label.thankyou + '</font></body></html>';
        
        htmlBody = htmlBody.replaceAll('null','');
        
        body.add(htmlBody);
        
        return body;
		
	}
	
	//THIS METHOD IS USED BY OBJECTIVE MANAGEMENT CONTROLLER
	public list <String> submitPlanToManagerForObjctiveMngmt(String managerName, String userName, String selectedYear,String selectedOutlet,
												String pageUrl, String translatedMonth, String month, String embed, String selectedObjChannel){
		
		list <String> body = new list<string>();
		
		integer index = pageUrl.indexOf('?');
		
		if(index != -1) {
		
		    pageUrl = pageUrl.substring(0,index);
		
		}
		
		String urlStr = URL.getSalesforceBaseUrl().toExternalForm()+pageUrl+'?yr='+selectedYear+'&uId='+selectedOutlet;
		
		if(selectedObjChannel !='' && selectedObjChannel != null){
			urlStr += '&objChannel='+selectedObjChannel;
		}


		  
		if(month!='' && month != null)
		
		  urlStr += '&month='+month;  
        
        urlStr = urlStr.replaceAll(' ','%20');

        
        String textBody = label.Hi+' '+managerName+',\n\n'+UserInfo.getName();
        
		if(month != null  )  		
		    textBody += label.has+' '+ translatedMonth+' '+label.visitplan+' '+urlStr+' \n\n'+label.thankyou;		    
		else		
		     textBody += ' has sent '+embed+'plan. URL is: '+urlStr;
            
		body.add(textBody);
        
        String htmlBody = '<html><font face="arial"><body>'+label.Hi+' '+managerName+',<br/><br/>'+UserInfo.getName();
        
        if(month != null  )            
            htmlBody += ' '+label.has+' '+translatedMonth+' '+label.visitplan+' <a href="'+urlStr+'">'+urlStr+'</a><br/><br/>'+label.thankyou+'</font></body></html>';        
        else        
            htmlBody += ' has sent ' + embed + 'plan.<br/> URL is: <a href="'+urlStr+'">Plan</a><br/><br/>' + label.thankyou + '</font></body></html>';
        
        htmlBody = htmlBody.replaceAll('null','');
        
        body.add(htmlBody);
        
        return body;
		
	}

}