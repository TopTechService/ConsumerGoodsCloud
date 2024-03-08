/*Created By -:Sourav Nema
  Purpose-:Populate values on brand look-up on Promoted_Range__c object
  
  */

trigger promotedRangeTrigger on Promoted_Range__c(before insert,before update) {
    

   list<string> brandId      = new list<string>();
   
   
   DataLoaderHelper helper   = new DataLoaderHelper();
   
   map<string, id> brandMap  = new  map<string, id>();
  
   for(Promoted_Range__c prdct : trigger.new){
    
      
      brandId.add(prdct.Brand_ID__c);
      
    
   }  
   
   //Get id of corresponding brand
   
     brandMap.putAll(helper.getBrandMap(brandId));
   
      
  //Assign brand
  
   for(Promoted_Range__c prdct:trigger.new){
    
    if(brandMap.get(prdct.Brand_ID__c)!=null){  
      prdct.Brand__c   =  brandMap.get(prdct.Brand_ID__c);
    }
    else{
    
      prdct.Brand_ID__c.addError('Invalid Brand Id');
    }
         
   }  
   
   
}