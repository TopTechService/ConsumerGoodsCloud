/**
 * @author : Gunwant Patidar
 * @created date : 06/05/2013
 * @description : This class Parse response received from ALM server and update  sales order product and sales orders
 */
public class AlmSoapResponseParser {
    public static Map<String,String> orderListMap ;
    public static Map<String,String> orderResponseMap ;
    public static String memberInvalidMessage = '';        
    public static Map<String,String> mapfield = new Map<String,String>();    

    public static Map<String,String> parseResponse(String response, Map<String,Sales_Order_Product__c> salesOrderProductMap){        
        orderResponseMap = new Map<String, String>();        
        XmlStreamReader reader = new XmlStreamReader(response);       
        orderResponseMap = parseStringXmlResponse(reader);        
        return orderResponseMap;
    }
    
    public static Map<String, String> parseStringXmlResponse(XmlStreamReader reader) {		
		Map<String, String> returnMap = new Map<String, String>();
		String tagName;
		while (reader.hasNext()) {	
			reader.next();
			if (reader.isStartElement()) {
				tagName = reader.getLocalName();
			} else if (reader.isCharacters())  {
				if (returnMap.containsKey(tagName)) {					
					returnMap.put(tagName, returnMap.get(tagName) + '. ' + reader.getText());
				} else  {
					returnMap.put(tagName, reader.getText());					
				}
			}
		}
		return returnMap;
	}
   

     public static Map<String,String> parseXMLResponse(XmlStreamReader reader) {
        String  startstring ='';
        
        while(reader.hasNext()) {            
            if (reader.getEventType() == XmlTag.START_ELEMENT) {
                startstring = reader.getLocalName();
                System.debug('********************* the tag is '+startstring);
               parseOrderResponse(reader,startstring);
            } 
            reader.next();
        }
        return mapfield;
    }
    
    public static void parseOrderResponse(XmlStreamReader reader,String startstring){    	
    	while(reader.hasNext()) {    		
    		if(reader.getEventType() == XmlTag.START_ELEMENT)
    			startstring = reader.getLocalName();
        	if (reader.getEventType() == XmlTag.END_ELEMENT) {        	
           		break;
        	} else if (reader.getEventType() == XmlTag.CHARACTERS) {        		
        		System.debug('************************ tag '+startString);        	    
        	    if(startstring.equals('WebOrderId') && mapfield.containsKey(startstring))        	    
        	       mapfield.put(startstring,mapfield.get(startstring)+','+reader.getText());        	    
        	    else        	    
           	 	  mapfield.put(startstring,reader.getText());
           	 	
           	 	if(startstring == 'LineId'){
           	 		//orderListMap.put(mapfield.get('LineId'),'Error');
        		}
        		if(startstring == 'WebOrderId')
        		
        		      memberInvalidMessage = '';		
        		// member number is no correct then error message appears in order header 
        		
        		if(startstring == 'HeaderMessageData'){
        			memberInvalidMessage += ' '+reader.getText();
        			mapfield.put(startstring,MemberInvalidMessage);
        		}
        		// if any error in line item then this part will put error message for each line item in a Map
        		 
        		if(startstring == 'ProductDescription'){
        			//orderListMap.put(mapfield.get('LineId'),reader.getText());
        			if(AlmSoapRequestHandler.orderSoapFieldMap.containsKey(mapfield.get('LineId')))
        			AlmSoapRequestHandler.orderSoapFieldMap.get(mapfield.get('LineId')).ILG_Response__c = memberInvalidMessage + reader.getText();
        			
        		} else if(startstring == 'LineMessageData'){
        			if(AlmSoapRequestHandler.orderSoapFieldMap.containsKey(mapfield.get('LineId'))){
        				
	        			AlmSoapRequestHandler.orderSoapFieldMap.get(mapfield.get('LineId')).ILG_Response__c +=  reader.getText();
	        			AlmSoapRequestHandler.orderSoapFieldMap.get(mapfield.get('LineId')).Status__c = 'Order failed in ALM';
        			}
        		}           	
        	}
        	reader.next();
     	}     
    }
}