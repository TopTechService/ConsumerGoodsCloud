public class accountTriggerHandler{
    
    private boolean m_isExecuting = false;
    private integer batchSize = 50;
    private Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Outlet').getRecordTypeId(); //see if we bring this validation to the handler
  
    
    public accountTriggerHandler(boolean isExecuting, integer size){
        
        m_isExecuting = isExecuting;
        batchSize = size;// CodeReview - debug. Batch size variable of 50 is not supposed to be used?
        System.debug('AccTrig batchSize>>> '+ batchSize);
    }

    private List<Account> checkRecordType(List<Account> accounts){
        List<Account> newAccountList = new  List<Account>();

        for(Account acc: accounts){
            if(acc.recordTypeId == devRecordTypeId){
                newAccountList.add(acc);
            }  
        } 
        return newAccountList;
    }
    // Allows unit tests (or other code) to disable this trigger for the transaction
    public static Boolean TriggerDisabled = false;

    public void beforeInsert(List<Account> newAccounts){//CodeReview - Set/change some fields before inserting an account (Volume__c, Banner_Group_ID__c, Parent_Hierarchy__c,Unallocated__c)
        List<Account> accounts = checkRecordType(newAccounts);
        Set <Id> parentAccountsId = new Set<Id>();
        //List<Account> accountstoUpdate = new List<Account>();
        set<string> postCodeList = new set<string>();
        
        for(Account acc : accounts){
            if(acc.ParentId != null){
                parentAccountsId.add(acc.ParentId);                
            }
            //if (acc.BillingPostalCode <> NULL && acc.BillingCity <> NULL) {
            //    string postCodeMerged = acc.BillingPostalCode + ' - ' + acc.BillingCity;
            //    postCodeList.add(postCodeMerged);
            //}
        }
       
        Map<Id, Account>   parentAccountMap = new Map<Id,Account>([SELECT Id,Parent_Hierarchy__c FROM Account WHERE Id IN: parentAccountsId] );
        System.debug(' AccTrig Before insert parentAccountMap>>> '+ parentAccountMap);
        
        //List<Post_Code_Region__c> post_Codes = [SELECT Id, Name, Post_Code_Merged__c, Territory_Owner__c FROM Post_Code_Region__c WHERE Post_Code_Merged__c IN :postCodeList];
        //Map<string,id> pcId = new Map<string,id>();
        //Map<string,id> territoryOwId = new Map<string,id>();
        //String defaultOwnerId ;
                
        //for(Post_Code_Region__c pc : post_Codes){
        //        pcId.put(pc.Post_Code_Merged__c, pc.id); 
        //        territoryOwId.put(pc.Post_Code_Merged__c,pc.Territory_Owner__c);
        //}

        for (Account acc : accounts) {
            if(acc.Volume__c != null) {             
                  acc.Volume__c = acc.Volume__c.setScale(2);
            }
            if(acc.Banner_Group__c != null) { 
                acc.Banner_Group_ID__c = acc.Banner_Group__r.Banner_Group_ID__c;
            }
            if(acc.ParentId != null && parentAccountMap.containsKey(acc.ParentId)){
                acc.Parent_Hierarchy__c = parentAccountMap.get(acc.ParentId).Parent_Hierarchy__c +'*,'+ acc.My_Sales_Id__c +',*';
            } else {                
                acc.Parent_Hierarchy__c =  '*,'+ acc.My_Sales_Id__c +',*';//CodeReview - if has no sales it inserts with null like 	*,null,*
            }
            if(acc.ASM_User_ID__c == null || acc.ASM_User_ID__c == ''){
                acc.Unallocated__c = true;
        	} else {              
                acc.Unallocated__c = false;
            } 
            //if(pcId.get(acc.Post_Code_Merged__c) <> null){
            //    acc.Post_Code_Region__c = pcId.get(acc.Post_Code_Merged__c);
            //    acc.Pending_Post_Code__c = FALSE;
            //    
            //    if(territoryOwId.get(acc.Post_Code_Merged__c)<>null){
            //    acc.OwnerId = territoryOwId.get(acc.Post_Code_Merged__c);
            //   } else if(Default_Account_Owner__c.getAll() != null && !Default_Account_Owner__c.getAll().values().isEmpty()){
            //            defaultOwnerId = Default_Account_Owner__c.getAll().values()[0].ownerId__c;
            //            acc.OwnerId = defaultOwnerId;
            //       }else{
            //            defaultOwnerId = userinfo.getuserid();
            //            acc.OwnerId = defaultOwnerId;
            //        }
            //}else{
            //    acc.Pending_Post_Code__c = TRUE;
            //}
               
           // System.debug('beforeInsert accOwner'+ acc.OwnerId);      
           // System.debug('beforeInsert territoryOwId'+ territoryOwId); 
            //System.debug('beforeInsert pcId'+ pcId); 
                
        }
    }
    
    public void beforeUpdate(Map<Id, Account> accountsNew, Map<Id, Account> accountsOld){
        List<Account> accounts = checkRecordType(accountsNew.values());
        if (RecursiveTriggerController.outletCount > 1){
           // system.debug('accountTriggerHandler beforeUpdate RecursiveTriggerController.outletCount>>> '+RecursiveTriggerController.outletCount);
    		return;
        } 
        
        Set <Id> parentAccountsId = new Set<Id>();
        
        //Set<string> postCodeList = new Set<string>();
        
        //for(Account acc : accounts){ //Added on CodeReview Carnac aug,2022 to fix the parentAccountMap
        //    if(acc.ParentId != null && acc.ParentId != accountsOld.get(acc.Id).ParentId){
        //        parentAccountsId.add(acc.ParentId);                
        //    }
        //    if ((accountsOld.get(acc.Id).BillingPostalCode != acc.BillingPostalCode || accountsOld.get(acc.Id).BillingCity != acc.BillingCity) && acc.BillingPostalCode <> NULL && acc.BillingCity <> NULL) {
        //        postCodeList.add(Acc.Post_Code_Merged__c);
        //    }
        //} 
        
       // system.debug('AccTrig BeforeUpdate postCodeList'+ postCodeList);
        
        Map<Id, Account> parentAccountMap = new Map<Id,Account>([SELECT Id,Parent_Hierarchy__c FROM Account WHERE Id IN: parentAccountsId]);                                                              
       // System.debug('AccTrig beforeupdate parentAccountMap >>>'+ parentAccountMap);
    
        //List<Post_Code_Region__c> post_Codes = [SELECT Id, Name, Post_Code_Merged__c, Territory_Owner__c FROM Post_Code_Region__c WHERE Post_Code_Merged__c IN :postCodeList];
        //Map<string,id> pcId = new Map<string,id>();
        //Map<string,id> territoryOwId = new Map<string,id>();
            
        //for(Post_Code_Region__c pc : post_Codes){
        //        pcId.put(pc.Post_Code_Merged__c, pc.id); 
        //        territoryOwId.put(pc.Post_Code_Merged__c,pc.Territory_Owner__c);
        //}
        //System.debug('AccTrig beforeupdate pcId >>>'+ pcId);
        //System.debug('AccTrig beforeupdate territoryOwId >>>'+ territoryOwId);
        

        for (Account acc : accounts) {
            if(acc.Volume__c != null && acc.Volume__c != accountsOld.get(acc.Id).Volume__c) {             
                acc.Volume__c = acc.Volume__c.setScale(2);
            }
            if(acc.Banner_Group__c != accountsOld.get(acc.Id).Banner_Group__c) {                  
                acc.Banner_Group_ID__c = acc.Banner_Group__r.Banner_Group_ID__c;
            }           
            if(acc.ParentId != null && parentAccountMap.containsKey(acc.ParentId)){
                acc.Parent_Hierarchy__c = parentAccountMap.get(acc.ParentId).Parent_Hierarchy__c +'*,'+ acc.My_Sales_Id__c +',*';
            } else {                
                acc.Parent_Hierarchy__c =  '*,'+ acc.My_Sales_Id__c +',*';
            }
            if(acc.ASM_User_ID__c == null || acc.ASM_User_ID__c == ''){
                acc.Unallocated__c = true;
            } else {              
                acc.Unallocated__c = false;
            }    
            //if(pcId.get(acc.Post_Code_Merged__c) <> null){// check what happens when the post code merged do not match
            //    acc.Post_Code_Region__c = pcId.get(acc.Post_Code_Merged__c);
            //    acc.Pending_Post_Code__c = FALSE;
            //    if(territoryOwId.get(acc.Post_Code_Merged__c)<>null){
            //        acc.OwnerId = territoryOwId.get(acc.Post_Code_Merged__c);
            //    }    
            //}else{
            //    acc.Pending_Post_Code__c = TRUE;
            //}
        }
        //System.debug('AccTrig Before update acc 2 checkdml>>> '+ acc);     
    }                   
     
    public void afterUpdate(Map<Id, Account> accountsNew, Map<Id, Account> accountsOld){
        //Update related outlet
        if (RecursiveTriggerController.outletCount >= 1){
          //  system.debug('accountTriggerHandler afterUpdate RecursiveTriggerController.outletCount>>> '+RecursiveTriggerController.outletCount);
    		return;
        } 
        
        List<Account> accounts = checkRecordType(accountsNew.values());
    
        Set<String> outletId = new Set<String>();    
        Set<String> accId = new Set<String>();
        Map<Id, Account> accMap= new Map <Id,Account>();
        for(Account acc : accounts){ //Added on CodeReview Carnac aug,2022 to fix the parentAccountMap
            if(acc.Outlet_ID__c != null && (acc.ASM_User_ID__c != accountsOld.get(acc.Id).ASM_User_ID__c||
                                            acc.OwnerId != accountsOld.get(acc.Id).OwnerId||
                                            acc.Name != accountsOld.get(acc.Id).Name||
                                            acc.Territory__c != accountsOld.get(acc.Id).Territory__c||
                                            acc.Called_On__c != accountsOld.get(acc.Id).Called_On__c||
                                            acc.Ownership_Group__c != accountsOld.get(acc.Id).Ownership_Group__c||
                                            acc.On_Premise_Segmentation__c != accountsOld.get(acc.Id).On_Premise_Segmentation__c||
                                            acc.Channel__c != accountsOld.get(acc.Id).Channel__c||
                                            acc.Consumer_Motivations__c != accountsOld.get(acc.Id).Consumer_Motivations__c
                                            )){             
                outletId.add(acc.Outlet_ID__c);  
                accId.add(acc.Id);
                accMap.put(acc.id, acc); 

                //system.debug('AccTrigHandler update outlet fields Name>>> '+ accountsOld.get(acc.Id).Name +'new> ' + acc.Name );
                //system.debug('AccTrigHandler update outlet fields Owner>>> '+ accountsOld.get(acc.Id).OwnerId +'new> ' + acc.OwnerId );
            }
        }
        system.debug('AccTriggerHandler afterUpdate outletId>>> '+outletId);
        
        if(outletId.size()>0){
            system.debug('AccTriggerHandler afterUpdate outletId.size>>> '+ outletId.size());
          //  system.debug('AccTriggerHandler afterUpdate accMap>>> '+ accMap);
            //system.debug('AccTriggerHandler afterUpdate accMap>>> '+ accountsNew);
            //UpdateOutlet handler = new UpdateOutlet(Trigger.isExecuting, Trigger.size);
            //handler.updateRelatedOutlet(outletId, accMap, accId);
            updateRelatedOutlet(outletId, accMap, accId);
        }

       
        //Create/delete related Product_Range if Called_on changed 
        Map<Id, Account> accOutlet = new Map<Id, Account>();
        for(Account acc: accounts){
            accOutlet.put(acc.Id, acc);
        }
        system.debug('AccTriggerHandler afterUpdate accOutlet.size' + accOutlet.size());
        afterUpdateAccountSetUp(accOutlet, accountsOld);       //Codereview  - check and evaluate replace by flow
    }
    
    public void afterInsertAccountSetUp(List<Account> newAccounts) {
        List<Account> accounts = checkRecordType(newAccounts);
	    // Check if the new Account is set to Called_On, and therefore needs the Product Range set.
        Set<Id> accountIds 	= new Set<Id>();
        List<Product__c> liProducts = new List<Product__c>();
        
        for (Account acc : accounts){
            // Build the Set of the Prodcuts being in the Standard Range          
            if( acc.Called_On__c == true ){
                accountIds.add(acc.id);
            }
        }
        if (accountIds.size() > 0){
            for(Product__c p : [SELECT id  FROM Product__c WHERE Standard_Range__c = true]){
             //CodeReview - 96records
                liProducts.add(p);
            }
            system.debug('AccTriggerHandler afterInsertAccountSetUp liProducts.size' + liProducts.size());
    
            productRangeCreate(accountIds, liProducts);
        }
    }
    
    public void afterUpdateAccountSetUp(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) { 
        
        // Check if the new Product is set to Standard Range or remove from Range.
        //
        Set<Id> newAccountIds = new Set<Id>();
        Set<Id> oldAccountIds = new Set<Id>();
        List<Product__c> liProducts = new List<Product__c>();
        
        for (Id setAccountId : newItems.keyset()){
            // Build the Set of the Account being upadted to be in or out of Called_On__c territories        
            if( newItems.get( setAccountId ).get(Account.Called_On__c  ) == true 
               && oldItems.get( setAccountId ).get(Account.Called_On__c  ) == false){
                newAccountIds.add(setAccountId);
            } else if( newItems.get( setAccountId ).get(Account.Called_On__c  ) == false && oldItems.get( setAccountId ).get(Account.Called_On__c  ) == true){
                oldAccountIds.add(setAccountId);
            }
        }
        
        if (newAccountIds.size() > 0){
            
            for(Product__c p : [SELECT id  FROM Product__c WHERE Standard_Range__c = true]){
                liProducts.add(p);
            }
            system.debug('AccTriggerHandler afterUpdateAccountSetUp liProducts.size' + liProducts.size());
            productRangeCreate(newAccountIds, liProducts);
        }
        
        if (oldAccountIds.size() > 0){
            productRangeDelete(oldAccountIds);
        }
        
    }
    
    public void productRangeCreate(Set<Id> liAccounts, List<Product__c> liProducts){
       
        
        List<Product_Range__c> liProductRange = new List<Product_Range__c>();
        for(Id a : liAccounts){
            for(Product__c p : liProducts){
                Product_Range__c pr = new Product_Range__c();
                pr.Account__c = a;
                pr.Product__c = p.id;
                liProductRange.Add(pr);
            } 
        }
        system.debug('AccTriggerHandler productRangeCreate liProductRange.size' + liProductRange.size());
        insert liProductRange;
    }
    
    public void productRangeDelete(Set<Id> liAccounts){
        
        List<Product_Range__c> liProductRange = new List<Product_Range__c>();
        
        for(Product_Range__c pr : [SELECT Id FROM Product_Range__c WHERE Account__c IN: liAccounts]){
            Product_Range__c npr = new Product_Range__c();
            npr.Id = pr.id;
            liProductRange.Add(npr);
        } 
        if(liProductRange.size()>0){
            system.debug('AccTriggerHandler productRangeDelete liProductRange.size>>> '+ liProductRange.size());
            delete liProductRange;
        }
    }
    
    public void updateRelatedOutlet (Set <String> outlet,Map<Id, Account> accountsNew, set<string> acId){
        
        DataLoaderHelper helper = new DataLoaderHelper();
        Map<String, Outlet__c> outletMap = new Map<String, outlet__c>();
        List<Outlet__c> otletList = new List<Outlet__c>();
        List<Id> accountWithoutOutletList = new List<Id>();
        
        outletMap.putAll(helper.getIdOutletMap(outlet));
        //System.debug('updateOutlet updaterelatedOutlet outletMap>>> ' + outletMap);
        //Map<String, List<Banner_Group_Outlet__c>> bgOutletMap = new Map<String, List<Banner_Group_Outlet__c>>(); // Codereview - commented as not working 118 commented
        //List<Banner_Group_Outlet__c> updatableBGOutlet = new List<Banner_Group_Outlet__c>();
        //bgOutletMap.putAll(helper.getbgoAccountMap(acId));
        //System.debug('updateOutlet updaterelatedOutlet bgOutletMap keySet ' + bgOutletMap.keySet());
        System.debug('AccTriggerHandler updaterelatedOutlet outletMap keySet ' + outletMap.keySet());
        
        if(!outletMap.isEmpty()){
            for(Account acc : accountsNew.values()){        //CodeReview -      
                if(outletMap.get(acc.Outlet_ID__c)!= null){
                    Outlet__c ot = outletMap.get(acc.Outlet_ID__c);
                    ot.ASM_User_ID__c     =  acc.Owner_Employee_Number__c;
                    ot.OwnerId            =  acc.OwnerId;      
                    ot.Outlet_Name__c     =  acc.Name;
                    ot.Territory__c       =  acc.Territory__c;
                    ot.Called_On__c       =  acc.Called_On__c;
                    ot.Segmentation__c    =  acc.On_Premise_Segmentation__c;
                    ot.Channel__c         =  acc.Channel__c;
                    ot.Ownership_Group_Id__c   =  acc.Ownership_Group__c;
                    ot.Consumer_Motivations__c =  acc.Consumer_Motivations__c;
                    otletList.add(ot);
                }  else{
                    accountWithoutOutletList.add(acc.Id);
                }
            }
            if(otletList.size()>0){
                system.debug('AccTriggerHandler updateRelatedOutlet otletList.size>>> '+ otletList.size());
                try {
                    List<Database.SaveResult> uResults = Database.update(otletList, false);
                    // Iterate through each returned result
                    for (Database.SaveResult sr : uResults) {
                        if (sr.isSuccess()) {
                            // Operation was successful, so get the ID of the record that was processed
                           // System.debug('Successfully updated outlet. Outlet ID: ' + sr.getId());
                        }
                        else {
                            // Operation failed, so get all errors                
                            for(Database.Error err : sr.getErrors()) {
                                System.debug('The following error has occurred.');                    
                                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                System.debug('Outlet fields that affected this error: ' + err.getFields());
                            }
                        }           
                    }
                } catch(Exception e) {
                    System.debug('The following exception has occurred: ' + e.getMessage());
                } 
            } 
            if(accountWithoutOutletList.size()>0){
                system.debug('AccTriggerHandler updateRelatedOutlet accountWithoutOutletList.size>>> '+ accountWithoutOutletList.size());
            } 
        } else {
            system.debug('AccTriggerHandler updateRelatedOutlet There are no Outlets related to these accounts');
        }
    } 
}