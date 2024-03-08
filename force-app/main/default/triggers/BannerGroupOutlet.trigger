/*Created By -:Sourav Nema
  Purpose-:Populate values on account look-up of Outlet and Banner record type on  Banner_Group_Outlet__c object 
  
  */

trigger BannerGroupOutlet on Banner_Group_Outlet__c (before insert,before update) {
   
   list<account>  accountToBeUpdate   = new list<account>();
   list<string> outletId              = new list<string>();
   set<string> bannerId              = new set<string>();
   
   DataLoaderHelper helper            = new DataLoaderHelper();
   
   map<string, account> outletIdMap        =  new map<string, account>();
   
   map<string, account> bannerIdMap        =  new map<string, account>();
   
   
   for(Banner_Group_Outlet__c bannerOutlet:trigger.new){
    
      
      outletId.add(bannerOutlet.Outlet_ID__c);
      bannerId.add(bannerOutlet.Banner_Group_ID__c);
    
   }  
   
   //Get id of corresponding account
   
    outletIdMap.putAll(helper.getWholesalerOutletMapId (outletId));
    system.debug('+++++++++++++++++ account'+ outletIdMap); 
    bannerIdMap.putAll(helper.getBannerIdMap(bannerId));
      
  //Assign account
  
   for(Banner_Group_Outlet__c bannerOutlet:trigger.new){
   
    if(outletIdMap.get(bannerOutlet.Outlet_ID__c)!= null){
     bannerOutlet.Outlet_Account__c        = outletIdMap.get(bannerOutlet.Outlet_ID__c).id;
    }
    else{
      bannerOutlet.Outlet_ID__c.addError('Invalid Outlet Id');
    } 
    
    if( bannerIdMap.get(bannerOutlet.Banner_Group_ID__c)!= null &&  outletIdMap.get(bannerOutlet.Outlet_ID__c) != null){  
     bannerOutlet.Banner_Group_Account__c  = bannerIdMap.get(bannerOutlet.Banner_Group_ID__c).id;
     
     //associate outlet account and banner group account
     outletIdMap.get(bannerOutlet.Outlet_ID__c).Banner_Group__c    = bannerIdMap.get(bannerOutlet.Banner_Group_ID__c).id;
     outletIdMap.get(bannerOutlet.Outlet_ID__c).Banner_Group_ID__c = bannerIdMap.get(bannerOutlet.Banner_Group_ID__c).Banner_Group_ID__c;
     accountToBeUpdate.add( outletIdMap.get(bannerOutlet.Outlet_ID__c));
     
    }
    else{
    
     bannerOutlet.Banner_Group_ID__c.addError('Invalid Banner Group Id');
    } 
     
    
   }  
   
   //update outlet account
   
   if(StaticVariableHandler.updateBannerGroupOutlet ){
    StaticVariableHandler.updateBannerGroupOutlet = false;
    update  accountToBeUpdate;
    
   }
   
   
}