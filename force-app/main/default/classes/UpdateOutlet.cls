public class UpdateOutlet {

    
    private boolean m_isExecuting = false;
    private integer BatchSize = 20;
    
    
    public UpdateOutlet(boolean isExecuting, integer size){
        
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
       
    public void syncOutlet(List<Account> Accounts){   
        // Define Variables
        // 
        
        
        set<string> accountsMod = new set<string>();
                
        For(account acc : Accounts){
            system.debug ('Current record : ' + Acc.name);
      		system.debug ('Current id : ' + Acc.id);
            accountsMod.add(acc.id);
           }
        
        if(accountsMod.size() > 0){
            ProcessOutlets(accountsMod);
     	}
   	 }
       
    
    
    public static void ProcessOutlets(set<string> accounts) {
        
            list<Account> accountList = [select id,outlet_Id__c, Territory__c, Called_On__c, Ownership_Group__c, Outlet__c,
                                        On_Premise_Segmentation__c, Channel__c, Consumer_Motivations__c, OwnerId, Name  from account where id IN :accounts];
            
        	Set<id> outletNames = new Set<id>();
            map<String,account> outletNameVsAccountMap = new map<String,Account>();
            list<Outlet__c> outletToUpdate = new List<Outlet__c>();
          
        
            for(Account acc : accountList){
                if(acc.outlet_Id__c <> null && acc.outlet_Id__c <> ''){           
               system.debug('OUTLET ID ****** ' + acc.outlet_Id__c);
              
                outletNames.add(acc.Outlet__c);
                outletNameVsAccountMap.put(acc.Outlet__c,acc);
            	}
            }
            
			list<Outlet__c> outletList = [SELECT Name,Id,State_ID__c, Territory__c, Called_On__c,Ownership_Group_Id__c,
                                                          Segmentation__c, Channel__c, Consumer_Motivations__c, OwnerId, Outlet_Name__c  FROM Outlet__c
                                                          WHERE id IN :outletNames];                
        												      												
             for(Outlet__c outlet : outletList){
                
                 if(outlet.name != null || outlet.name != '') {
                     system.debug('Looping ' + outlet.id);
                    outlet__c newOutlet = new outlet__c();
                    newOutlet.Id = outlet.id;
                    newOutlet.Territory__c = outletNameVsAccountMap.get(outlet.id).Territory__c;
                	newOutlet.Called_On__c = outletNameVsAccountMap.get(outlet.id).Called_On__c;
               	 	newOutlet.Ownership_Group_Id__c = outletNameVsAccountMap.get(outlet.id).Ownership_Group__c;
                	newOutlet.Segmentation__c = outletNameVsAccountMap.get(outlet.id).On_Premise_Segmentation__c;
                	newOutlet.Channel__c = outletNameVsAccountMap.get(outlet.id).Channel__c;
               		newOutlet.Consumer_Motivations__c = outletNameVsAccountMap.get(outlet.id).Consumer_Motivations__c;
                	newOutlet.OwnerId = outletNameVsAccountMap.get(outlet.id).OwnerId;
                	newOutlet.Outlet_Name__c = outletNameVsAccountMap.get(outlet.id).Name;
               		outletToUpdate.add(newOutlet);

                }
            }    
            if(outletToUpdate.size()>0){ 
            	update outletToUpdate;
            }
        
        }
        
         
                        
      
        
    public void updateRelatedOutlet (Set <String> outlet,Map<Id, Account> AccountsNew, set<string> acId){
        
        DataLoaderHelper helper = new DataLoaderHelper();
        Map<String, Outlet__c> outletMap = new Map<String, outlet__c>();
        List<Outlet__c> otletList = new List<Outlet__c>();
        outletMap.putAll(helper.getIdOutletMap(outlet));
        Map<String, List<Banner_Group_Outlet__c>> bgOutletMap = new Map<String, List<Banner_Group_Outlet__c>>();
        List<Banner_Group_Outlet__c> updatableBGOutlet = new List<Banner_Group_Outlet__c>();
        bgOutletMap.putAll(helper.getbgoAccountMap(acId));
        System.debug('bgOutletMap keySet ' + bgOutletMap.keySet());
        
        for(Account acc : AccountsNew.values()){             
            if(outletMap.get(acc.Outlet_ID__c)!= null){
                Outlet__c ot = outletMap.get(acc.Outlet_ID__c);
                ot.ASM_User_ID__c     =  acc.ASM_User_ID__c;
        		ot.OwnerId            =  acc.OwnerId;      
        		ot.Outlet_Name__c     =  acc.Name;
                otletList.add(ot);
                }               
            
            	 //Update related banner group outlet             
                List<Banner_Group_Outlet__c> otList = bgOutletMap.get(acc.Id);               
                for(Banner_Group_Outlet__c bannerGroup: otList) {
                       if (acc.Banner_Group__c == null && acc.Banner_Group_ID__c == '')
                           continue;
                       bannerGroup.Banner_Group_ID__c       = acc.Banner_Group_ID__c;
                       bannerGroup.Banner_Group_Account__c  = acc.Banner_Group__c;                
                       updatableBGOutlet.add(bannerGroup);
                   }
               }             
    
        
        if(updatableBGOutlet.size() > 0){
      //      update updatableBGOutlet;
        }
       
        if(otletList.size()>0){
            update otletList;
        }
}   
	
}