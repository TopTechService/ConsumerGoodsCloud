/*Created By-:Sourav Nema
  Description-:PromotionOutlet is junction object,populate value in outlet and account lookup

*/






trigger PromotionOutlet on Promotion_Outlet__c (before insert, before update) {
  
   list<string> promotionId        = new list<string>();
   list<string> outLetId          = new list<string>();
   
   DataLoaderHelper helper     = new DataLoaderHelper();
   
   map<string, string> promotionPrdctIdMap  = new  map<string, id>();
   map<string, account> outletIdMap  = new map<string, account>();
  
   for(Promotion_Outlet__c outlet : trigger.new){ 
        
      outLetId.add(outlet.Outlet_ID__c);  
      promotionId.add(outlet.Promotion_ID__c);
    
   }      
   
   //Get id of corresponding  Account and promotion products
        
     promotionPrdctIdMap.putAll(helper.getPromotionProductMap(promotionId));
     outletIdMap.putAll(helper.getWholesalerOutletMapId(outLetId));
   
      
  //Assign outlet account and Promotion Product  
  
   for(Promotion_Outlet__c outlet:trigger.new){
    
   
     if( outletIdMap.get(outlet.Outlet_ID__c)!=null && promotionPrdctIdMap.get(outlet.Promotion_ID__c)!= null){ 
       outlet.Promotion__c           =  promotionPrdctIdMap.get(outlet.Promotion_ID__c);
       
      if(trigger.isInsert) 
       outlet.Outlet_Account__c      =  outletIdMap.get(outlet.Outlet_ID__c).id;
     }
     else{
       if(promotionPrdctIdMap.get(outlet.Promotion_ID__c)== null){
          outlet.Promotion_ID__c.addError('Invalid Promotion Id');
       }
       else{
         
         outlet.Outlet_ID__c.addError('Invalid Outlet Id');
         
       }
      }
       
   }  
}