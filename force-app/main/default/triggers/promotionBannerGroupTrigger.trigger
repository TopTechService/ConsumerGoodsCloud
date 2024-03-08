/*Created By -:Sourav Nema
  Purpose-:Populate values on Wholesaler_Banner_Group__c and PromotionProduct__c look-up on Promotion Banner Group object
  
  */

trigger promotionBannerGroupTrigger on Promotion_Banner_Group__c (before insert, after insert,after update) {
  if(trigger.isInsert && trigger.isBefore){   
       list<string> groupId        = new list<string>();
       list<string> prdctId        = new list<string>();
   
       DataLoaderHelper helper     = new DataLoaderHelper();
   
       map<string, id> groupIdMap  = new  map<string, id>();
       map<string, string> prdctIdMap  = new map<string, id>();
  
       for(Promotion_Banner_Group__c pbGroup : trigger.new){
          groupId.add(pbGroup.Wholesaler_Banner_Group_ID__c); 
          prdctId.add(pbGroup.Promotion_ID__c);
       }     
   
       //Get id of corresponding Wholesaler Banner Groups and promotion products
   
       groupIdMap.putAll(helper.getWholeSalerBannerGroupMap(groupId));
       prdctIdMap.putAll(helper.getPromotionProductMap(prdctId));
   
      
      //Assign Wholesaler Banner Groups and Promotion Product
  
       for(Promotion_Banner_Group__c pbGroup:trigger.new){
    
         if( groupIdMap.get(pbGroup.Wholesaler_Banner_Group_ID__c)!=null && prdctIdMap.get(pbGroup.Promotion_ID__c)!= null){ 
             pbGroup.Wholesaler_Banner_Group__c   =  groupIdMap.get(pbGroup.Wholesaler_Banner_Group_ID__c);
             pbGroup.Promotion__c    =  prdctIdMap.get(pbGroup.Promotion_ID__c);
         }
         else{
             if(groupIdMap.get(pbGroup.Wholesaler_Banner_Group_ID__c)==null){
              pbGroup.Wholesaler_Banner_Group_ID__c.addError('Invalid WholeSaler Banner Group Id');
             }
             else{
               pbGroup.Promotion_ID__c.addError('Invalid Promotion Id');
             }
          }
       
       } 
  }
  // is after
     if(trigger.isAfter){
       	set<Id> promotionIds = new set<Id>();
       	for(Promotion_Banner_Group__c pbGroup:trigger.new){
        	promotionIds.add(pbGroup.Promotion__c);
       	}
       
    	PromotionColspanClass.checkOverlapDates(promotionIds,'isAfter');          
            
     }   
}