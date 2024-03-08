/*Created By -:Sourav Nema
  Purpose-:Populate values on product look-up on Pricing object 
  
  */

trigger pricingTrigger on Pricing__c (before insert,before update, after insert) {
    

   list<string> prdctId = new list<string>();
   list<PromotionProduct__c> prdctList = new list<PromotionProduct__c>();
   
   DataLoaderHelper helper      = new DataLoaderHelper();
   
   map<string, id> productIdMap = new  map<string, id>();
  
   for(Pricing__c price:trigger.new){
    
      
      prdctId.add(price.Product_ID__c);
      
    
   }  
   
   //Get id of corresponding product
   
    productIdMap.putAll(helper.getProductMap(prdctId));
   
      
  //Assign product
  
   for(Pricing__c price:trigger.new ){
    
    if(productIdMap.get(price.Product_ID__c)!=null){
      if(trigger.isBefore){	 
        price.Product__c   = productIdMap.get(price.Product_ID__c);
      }
     }
     else{
        price.Product_ID__c.addError('Invalid Product Id');
     }
    
         
   }  
   
   //Create product on pricing insert
   if(trigger.isInsert && trigger.isAfter){
   	
   	 for(Pricing__c pric: trigger.new){
   	 	
   	 	system.debug('ppppppppppppppppp '+pric.Product__c);
   	 	PromotionProduct__c prdct  =  new PromotionProduct__c(Pricing__c = pric.id, Product__c = pric.Product__c);
   	 	prdctList.add(prdct);
   	 	
   	 }
   	
   	insert prdctList;
   }
   
}