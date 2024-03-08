/**
 * @author    : Created by Geeta Kushwaha on 10 Apr, 2013  geeta.kushwaha@arxxus.com
 * @Purpose   : Populate the Image url
 * @Criteria  : 
 * @Modified  : 
 */
trigger ImageAttachment on Attachment (after delete, after insert) {

    if(Trigger.isInsert)
    
        ImageURLFetcherHelper.setImageURLsToTextFieldsInsert(trigger.newMap);
         
    else if(Trigger.isDelete)
       
        ImageURLFetcherHelper.updateImageURLsAfterAttachDeletion(trigger.oldMap);
        
}