/*Created By-:Sourav Nema
  Purpose-: Auto populate value in Wholesaler Group Product by Product
  Created Date-:4/18/2013 */


trigger WholeSalerGroupProduct on Wholesaler_Group_Product__c (before insert, before update) {
   
 
   list<string> prdctId        = new list<string>();
   
   DataLoaderHelper helper = new DataLoaderHelper();
   
   map<string, id> productMap =  new map<string, id>();
    
   for(Wholesaler_Group_Product__c prdct :trigger.new){
          
      prdctId.add(prdct.Product_ID__c);
     
   }  
   
   //Get id of corresponding product
   
    
    productMap.putAll(helper.getWholeSalerGroupProductMapId(prdctId));
      
  //Assign Product
  
   for(Wholesaler_Group_Product__c  prdct:trigger.new){
    
     prdct.Product__c  = productMap.get(prdct.Product_ID__c);
    
     
    
   }  
}