/**
* This class is responsible to handle the banner group trigger related actions 
*/
public with sharing class BannerGroupTriggerHandler {
    private DataLoaderHelper helper               = new DataLoaderHelper();
    private  map<string, Account> bannerGroupIdMap      = new map<string, Account>();
    
    public void updateBannerGroupParentAccount(list<Banner_Group__c> bannerGroups, map<string,Account> bannerGroupAccount,set<string> parentbannerGroupId){
        // this map will contain all parent account ids against parent banner group ids
        bannerGroupIdMap.putAll(helper.getBannerIdMap(parentbannerGroupId));
        
        string prntId;
        
        // populate parent account on child account
        for(Banner_Group__c banner:bannerGroups){
            
            if(bannerGroupIdMap.containsKey(banner.Parent_Banner_Group_ID__c)){
                 
                prntId  = bannerGroupIdMap.get(banner.Parent_Banner_Group_ID__c).Id;
                
            }
            
            else{
               
               if(banner.Parent_Banner_Group_ID__c != null){
                
                   banner.Parent_Banner_Group_ID__c.addError('Invalid Parent Banner Group Id');
               
               }
           
           }
            System.debug('bannerGroupAccount:' + bannerGroupAccount);
            
            if(bannerGroupAccount.get(banner.Banner_Group_ID__c) != null){
                
                bannerGroupAccount.get(banner.Banner_Group_ID__c).ParentId = prntId;
                
            }            
            
        }         
        
        if(bannerGroupAccount.size() > 0) {
        // account list with parent accounts is being updated
            update bannerGroupAccount.values();
        
        }
    }

}