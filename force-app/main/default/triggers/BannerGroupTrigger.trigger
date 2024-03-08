/*Created By -:Sourav Nema
  Purpose    -:Insert or update account based on inserted BannerGroup data
  */
  

trigger BannerGroupTrigger on Banner_Group__c (after insert,after update) {

    
    set<string> parentbannerGroupId                = new set<string>();
     
    DataLoaderHelper helper               = new DataLoaderHelper();
     
    map<string, Account> bannerGroupIdMap      = new map<string, Account>();
    list<account>   accountList           = new list<account>();
     
    list<string> nameList = new list<string>(); 
    
    map<string,Account> bannerGroupAccount = new map<string,Account>();
     
    string recordTypeId = Utilities.getRecordTypeId('Account','Banner Group');
   
   //   bannerGroupIdMap.putAll(helper.getBannerIdMap(parentbannerGroupId));
  
    if(trigger.isInsert){ 
        for(Banner_Group__c banner:trigger.new){            
            
            parentbannerGroupId.add(banner.Parent_Banner_Group_ID__c);
            
            account  acc  = new account(Banner_Group_ID__c = banner.Banner_Group_ID__c,Parent_Banner_Group_ID__c = banner.Parent_Banner_Group_ID__c,
                                        recordtypeid = recordTypeId ,name = banner.name,My_Sales_Id__c =  banner.Banner_Group_ID__c);
                                        
            if(banner.Parent_Banner_Group_ID__c != null){
                
                bannerGroupAccount.put(banner.Banner_Group_ID__c,acc);
                
            }
                                        
            accountList.add(acc); 
            
        }  
        
        insert accountList;
        
        BannerGroupTriggerHandler  handler= new BannerGroupTriggerHandler ();
        handler.updateBannerGroupParentAccount(Trigger.new,bannerGroupAccount,parentbannerGroupId);
	}
  
 
 
 /*******************Added Arxxus Advantage for case no  00013631 ************************/
  
      if(Trigger.isUpdate && Trigger.isAfter){
        parentbannerGroupId.clear();
        bannerGroupAccount.clear();
        map<String,string> bannerGroupIdVsName = new map<String,string>();
        for(Banner_Group__c  bannerGrp : trigger.new){
             parentbannerGroupId.add(bannerGrp.Parent_Banner_Group_ID__c);
             if(!String.isEmpty(bannerGrp.Banner_Group_ID__c)){
                 bannerGroupIdVsName.put(bannerGrp.Banner_Group_ID__c,bannerGrp.name); 
             }
        }
        
                
        list<Account> bannerGroupAccounts = [SELECT Banner_Group_ID__c ,Parent_Banner_Group_ID__c ,recordtypeid ,My_Sales_Id__c,ParentId 
                                             FROM Account WHERE recordtypeid =: recordTypeId 
                                                   and Banner_Group_ID__c in : bannerGroupIdVsName.keyset()];
                                                   
        for(Account acc : bannerGroupAccounts  ){
            if(acc.Banner_Group_ID__c!= null){
                bannerGroupAccount.put(acc.Banner_Group_ID__c,acc);
            }
            acc.name = bannerGroupIdVsName.get(acc.Banner_Group_ID__c);
        }
        
        BannerGroupTriggerHandler  handler= new BannerGroupTriggerHandler ();
        handler.updateBannerGroupParentAccount(Trigger.new,bannerGroupAccount,parentbannerGroupId);
        
        if(!bannerGroupAccounts.isEmpty()){
            update bannerGroupAccounts ; 
        }
        

      }
  
  /*******************End *******************************************/
  


//Update related account of  Wholesaler.
 
/*  if(trigger.isUpdate){
     accountList.clear();
     
    
     list<account>accountList2   = [select Parent_Banner_Group_ID__c,Banner_Group__c,Banner_Group_ID__c,name
                                    from account where Banner_Group_ID__c in:bannerGroupId];
                                  
                    
     map<string,account> idMap        = new Map<string,account>();
    
    for(account ac:accountList2){
    
       
        idMap.put(ac.name,ac);    
    
    }*/
                    
  /*  for(Banner_Group__c banner : trigger.new){
     
       
        system.debug('------------------- '+banner.name);*/
    /*    account ac                       = idMap.get(banner.name);
        
        
        ac.Parent_Banner_Group_ID__c     = banner.Parent_Banner_Group_ID__c;
     
        
        accountList.add(ac);
    
    
    }                
     
    update accountList;
  
  }*/
 }