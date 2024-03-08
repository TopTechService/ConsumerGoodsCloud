/* Created By-: Sourav Nema
   Created Date -: 5/13/2013
   Purpose-:Populate last modified date custome field if region field is changed
 @Modified : Geeta Kushwaha, geeta.kushwaha@arxxus.com on 22 May, 2013 
             Sourav Nema, sourav.nema@arxxus.com on 27 May, 2013
   */


trigger UserTrigger on User (before insert, before update) {
    
    DataLoaderHelper helper = new DataLoaderHelper();
    
    map<string,string> stateMap = new map<string, string>();
    list<string> regionIdList = new list<string>();
    
    if(trigger.isUpdate){
        
        for(User u :trigger.new){
        
            u.Last_Modified_Date__c = Datetime.now();
            
            u.LastModifiedBy__c = UserInfo.getFirstName()+' '+UserInfo.getLastName();
            
            regionIdList.add(u.RegionID__c);
            
        }
        
    }
    
    else if(trigger.isInsert){
        
        for(User u : trigger.new){
            
            u.Last_Modified_Date__c = Datetime.now();
            
            u.CreatedBy__c = UserInfo.getFirstName()+' '+UserInfo.getLastName();
            
            u.LastModifiedBy__c = UserInfo.getFirstName()+' '+UserInfo.getLastName();
            
        }
        
    }
    
    stateMap.putAll(helper.getRegionStateMap(regionIdList));
    
    for(User u: trigger.new){
    
    
    //PUT STATE NAME BASED ON REGION ID 
     if(stateMap.get(u.RegionID__c)!=null){
        u.State__c =  stateMap.get(u.RegionID__c);
     }
     else{
        
        u.State__c =  '';
        
     }
    }
    
  
}