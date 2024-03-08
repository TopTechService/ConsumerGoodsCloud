public with sharing class XMLUtilities {
	
	public static Map<String, String> readXmlString(String xmlString) {
		XmlStreamReader reader = new XmlStreamReader(xmlString);
		Map<String, String> returnMap = parseResponse(reader);
		return returnMap;
	}
	
	private static Map<String, String> parseResponse(XmlStreamReader reader) {
		String tempPrdId = '';	
		Map<String,String> prdIDvsMsg = new Map<String,String>();		
		
		Map<String, List<String>> returnMap = new Map<String, List<String>>();
		String tagName;
		while (reader.hasNext()) {	
			reader.next();
			if (reader.isStartElement()) {
				tagName = reader.getLocalName();
			} else if (reader.isCharacters())  {
				//system.debug('reader tag : '+tagName);
                if (tagName == 'ProductCode') {                    
                    prdIDvsMsg.put(reader.getText(),null);
                    tempPrdId = reader.getText();
                } else if(tagName == 'LineMessageData' && tempPrdId != '#NIL#' && tempPrdId != '') {
                    prdIDvsMsg.put(tempPrdId,reader.getText());
                    tempPrdId = '#NIL#';                    
                }				                
				if (returnMap.containsKey(tagName)) {					
					returnMap.get(tagName).add(reader.getText());
				} else  {
					List<String> strList = new List<String>();
					strList.add(reader.getText());
					returnMap.put(tagName, strList);          	  	                                      
				}
			}
		}		
		//return returnMap;
		return prdIDvsMsg;
	}	
}