/*Created By -:Sourav Nema
  Purpose-:Populate values on account look-up of Wholesaler and Banner record type on Wholesaler_Banner_Group object 
  
  */


trigger WholeSalerBannerGroupTrigger on Wholesaler_Banner_Group__c (before insert, before update) {
   
   
   //Set value of Whole Saler Account
   list<string> groupId        = new list<string>();
   list<string> bannerId        = new list<string>();
   list<string> regionId        = new list<string>();
   
   DataLoaderHelper helper = new DataLoaderHelper();
   map<string, Account> wSalerAccountIdMap = new map<string, Account>();
   map<string, Account> bannerAccountIdMap = new map<string, Account>();
   map<string, Region__c> regionIdMap        = new map<string, Region__c>();
   
   for(Wholesaler_Banner_Group__c wsgroup :trigger.new){
    
      
      groupId.add(string.valueOf(wsgroup.Wholesaler_ID__c));
      bannerId.add(string.valueOf(wsgroup.Banner_Group_ID__c));
      
     
      regionId.add(wsgroup.Region_ID__c);
      
   }  
    system.debug('bbbbbbbbbbbbbbb....'+bannerId);  
   
   //Get id of corresponding account and region
    wSalerAccountIdMap.putAll(helper.getWholeSalerIdMap(groupId));
    
    Set <String> s = new set<String>();
    s.addAll(bannerId);   
    bannerAccountIdMap.putAll(helper.getBannerIdMap(s));
    regionIdMap.putAll(helper.getRegionIdMap(regionId));
      
  //Assign account and region
  
   for(Wholesaler_Banner_Group__c wsgroup :trigger.new){
     
     
     if( wSalerAccountIdMap.get(wsgroup.Wholesaler_ID__c) !=null && regionIdMap.get(wsgroup.Region_ID__c).id != null){
      wsgroup.Wholesaler_Account__c   = wSalerAccountIdMap.get(wsgroup.Wholesaler_ID__c).id;
      wsgroup.Region__c = regionIdMap.get(wsgroup.Region_ID__c).id;
     }
     else{
     
       if(wSalerAccountIdMap.get(wsgroup.Wholesaler_ID__c) ==null ){
         wsgroup.Wholesaler_ID__c.addError('Invalid Wholesaler id');
       }
       else{
       	
       	  wsgroup.Region_ID__c.addError('Invalid Region id');
       	
       }
     }
     
     system.debug('========== bannerMap '+bannerAccountIdMap);
     if( bannerAccountIdMap.get(wsgroup.Banner_Group_ID__c) != null){
       wsgroup.Banner_Group_Account__c = bannerAccountIdMap.get(wsgroup.Banner_Group_ID__c).id;
     
     }
     else{
     
        wsgroup.Banner_Group_ID__c.addError('Invalid Banner id');
     }
    
   
   
   
   
 }
}