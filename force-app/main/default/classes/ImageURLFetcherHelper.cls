/**
 * @author    : Created by Geeta Kushwaha on 10 Apr, 2013  geeta.kushwaha@arxxus.com
 * @Purpose   : Populate the Image url or delete the image url
 * @Criteria  : Valid Image formats considered are jpeg, png, gif, jpg & bmp 
 * @Modified  : 
 */
public with sharing class ImageURLFetcherHelper {
	
    private static String SF_STD_FILE_URL_PREFIX = URL.getSalesforceBaseUrl().toExternalForm() + '/servlet/servlet.FileDownload?file=';
    
    private static set<String> validImageFormats = new set<String>();
     
    static{
        validImageFormats.add('image/jpeg');
        validImageFormats.add('image/png');
        validImageFormats.add('image/gif');
        validImageFormats.add('image/jpg');
        validImageFormats.add('image/bmp');
    }
    
    /*
     * Checks if a given attachments are valid images and returns map of ParentId and Attachment Id
     */
    private static map <Id, Id> isValidAttachment(map<Id, Attachment> attchmentMap){
    	
    	Attachment attachRec = null;
        
        map <Id, Id> validImageAttachment = new map<Id, Id>();
        
        for(Id key : attchmentMap.keySet()){
            
            attachRec = attchmentMap.get(key);
            
            if(validImageFormats.contains(attachRec.ContentType)){
                
                validImageAttachment.put(attachRec.ParentId, attachRec.Id);
                
            }
            
        }
        
        return validImageAttachment;
    	
    }
    
    /*
     * This function will insert the attachment url in Product_Image_URL__c
     */
    public static void setImageURLsToTextFieldsInsert(map<Id, Attachment> attchmentMap ) {
    	
    	map <Id, Id> validImageAttachment = isValidAttachment(attchmentMap);
    	
    	if(validImageAttachment.size() > 0) {
    		
    		list <Product__c> productsList = [select id, Product_Image_URL__c
		                                      from Product__c 
		                                      where id IN : validImageAttachment.keySet()];

            for(Product__c prodRec : productsList)	{
            	
            	prodRec.Product_Image_URL__c = SF_STD_FILE_URL_PREFIX + validImageAttachment.get(prodRec.Id);
            	
            }                                      
	        
	        update productsList;  
	          
    	}
    	
    }
    
    /*
     * This function will delete the attachment url
     */
    public static void updateImageURLsAfterAttachDeletion(map<Id, Attachment> attchmentMap){
    	
    	map <Id, Id> validImageAttachment = isValidAttachment(attchmentMap);
        
        if(validImageAttachment.size() > 0) {
            
            list <Product__c> productsList = [select id, Product_Image_URL__c
                                              from Product__c 
                                              where id IN : validImageAttachment.keySet()];

            for(Product__c prodRec : productsList)  {
                
                prodRec.Product_Image_URL__c = null;
                
            }                                      
            
            update productsList;  
              
        }
    	
    }
    
}