/*Created By -:Sourav Nema
  Purpose-:Populate values on region look-up on  State object
  
  */

trigger stateTrigger on State__c (before insert,before update) {
    

   list<string> regionId      = new list<string>();
   
   
   DataLoaderHelper helper   = new DataLoaderHelper();
   
   map<string, Region__c> regionMap  = new  map<string, Region__c>();
  
   for(State__c stt: trigger.new){
    
      
      regionId.add(stt.Region_ID__c);
      
    
   }  
   
   //Get id of corresponding region
   
     regionMap.putAll(helper.getRegionIdMap(regionId));
   
      
  //Assign region
  
   for(State__c stt:trigger.new){
    
    if( regionMap.get(stt.Region_ID__c)!=null){  
      stt.State_Abbr__c   =  regionMap.get(stt.Region_ID__c).Region_Abbr__c;
      if(trigger.isInsert){
       stt.Region__c   =  regionMap.get(stt.Region_ID__c).id;
      }
    }
    else{
    
      stt.Region_ID__c.addError('Invalid Region Id');
    }
         
   }  
   
   
}