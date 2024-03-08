/*Created By -:Sourav Nema
  Purpose-:Populate values on account look-up of Wholesaler on Wholesaler_Branch__c object 
  
  */

trigger WholesalerBranchTrigger on Wholesaler_Branch__c (before insert,before update) {
    

   list<string> wholeSalerId = new list<string>();
   list<string> stateId      = new list<string>();   
   
   DataLoaderHelper helper   = new DataLoaderHelper();
   
   map<string, Account> wSalerAccountIdMap = new  map<string, Account>();
   map<string, id> stateIdMap   = new  map<string, id>();
  
   for(Wholesaler_Branch__c saler:trigger.new){
    
      
      wholeSalerId.add(saler.Wholesaler_ID__c);
      stateId.add(saler.State_ID__c);
    
   }  
   
   //Get id of corresponding account
   system.debug('-------------------------------sttlist '+stateId);
    wSalerAccountIdMap.putAll(helper.getWholeSalerIdMap(wholeSalerId ));
    stateIdMap.putAll(helper.getStateMap(stateId));
     system.debug('-------------------------------sttmap '+stateIdMap);
      
  //Assign account
  
   for(Wholesaler_Branch__c saler:trigger.new){
    
    if(wSalerAccountIdMap.get(saler.Wholesaler_ID__c)!=null || wSalerAccountIdMap.get(saler.State_ID__c)!=null){ 
      saler.Wholesaler_Account__c   = wSalerAccountIdMap.get(saler.Wholesaler_ID__c).id;
      saler.State__c =  stateIdMap.get(saler.State_ID__c);
     }
     else{
     
      if(wSalerAccountIdMap.get(saler.Wholesaler_ID__c)==null){
       saler.Wholesaler_ID__c.addError('Invalid Wholesaler Id');
       }
       else{
          saler.State__c.addError('Invalid State Id');
       
       }
     }
    
         
   }  
   
   
}