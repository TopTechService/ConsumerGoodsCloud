/*
* Trigger Name : setParentHierarchy
* Description - This trigger is using to  set the All parents for SalesMySales .
* @author Debasish (debasish@arxxus.com)
* @revised : 17-05-2013 [created by Debasish]
* @revised : 11-06-3013 [Geeta Kuswaha, geeta.kushwaha@arxxus.com] Set Owner of Sales_MySales__c as owner of outlet
Set Volume on Account for current Year
13/09/2018 [Yoann Beurier] Set the MySales record to any active Product MySales record.
*/ 

trigger setParentsOnSaleMySales on Sale_MySales__c (before insert, before update, after insert, after update, after delete, after undelete) {
    
    
    if(trigger.isBefore) {
        
        set<string> productsId = new set<string>();
        set<string> wholesalerBranchId = new set<string>();
        set<string> outletIds = new set<string>();
        set<string> bannerGroupid = new set<string>();
        
        list<Account>accounts = new list<Account>();
        list<Product__c>products = new list<Product__c>();
        list<Wholesaler_Branch__c>wholesalerBranches = new list<Wholesaler_Branch__c>();
        list<Wholesaler_Banner_Group__c> wholeBannerGroup = new list<Wholesaler_Banner_Group__c>();
        
        
        map<string,Account> accountIdMap = new map<string,Account>();
        map<string,id> wholesalerBranchIdMap = new map<string,id>();
        map<string,id> productIdMap = new map<string,id>();
        map<string,string> regionIdMap = new map<string,string>();
        
        for(Sale_MySales__c saleMySale : trigger.new){
            if(saleMySale.ProductID__c != null){
                productsId.add(saleMySale.ProductID__c);
            }
            
            if(saleMySale.Wholesaler_Branch_ID__c != null){
                wholesalerBranchId.add(saleMySale.Wholesaler_Branch_ID__c);
            }
            
            if(saleMySale.OutletID__c != null){
                outletIds.add(saleMySale.OutletID__c);
            }
        }
        
        accounts                = [select id,Banner_Group__c,Banner_Group__r.Banner_Group_ID__c, Outlet_ID__c, OwnerId
                                   from Account 
                                   where  Outlet_ID__c IN: outletIds ];
        
        products                = [select id, Product_ID__c
                                   from Product__c
                                   where Product_ID__c IN: productsId];
        
        
        wholesalerBranches      = [select id,Wholesaler_Branch_Id__c
                                   from Wholesaler_Branch__c
                                   where Wholesaler_Branch_Id__c IN: wholesalerBranchId];
        
        
        for(Account acc : accounts){
            accountIdMap.put(acc.Outlet_ID__c,acc);
            bannerGroupid.add(acc.Banner_Group__r.Banner_Group_ID__c);
        }
        
        for(Product__c pro : products){
            productIdMap.put(pro.Product_ID__c,pro.id);
        }
        
        for(Wholesaler_Branch__c wBranch : wholesalerBranches){
            wholesalerBranchIdMap.put(wBranch.Wholesaler_Branch_Id__c,wBranch.id);
        }
        
        for(Wholesaler_Banner_Group__c wbp : [select Banner_Group_ID__c,
                                              Region__r.Region_ID__c
                                              from Wholesaler_Banner_Group__c
                                              where Banner_Group_ID__c IN: bannerGroupid]){
                                                  
                                                  regionIdMap.put(wbp.Banner_Group_ID__c,wbp.Region__r.Region_ID__c);
                                                  
                                              }
        
        for(Sale_MySales__c sms : trigger.new){
            if(accountIdMap.containskey(sms.OutletID__c)){
                sms.Banner_Group__c         = accountIdMap.get(sms.OutletID__c).Banner_Group__c;
                sms.Outlet__c               = accountIdMap.get(sms.OutletID__c).id;
                sms.OwnerId = accountIdMap.get(sms.OutletID__c).OwnerId;
                if(regionIdMap.containsKey(accountIdMap.get(sms.OutletID__c).Banner_Group__r.Banner_Group_ID__c)){
                    sms.Region_Id__c = regionIdMap.get(accountIdMap.get(sms.OutletID__c).Banner_Group__r.Banner_Group_ID__c);
                }
            }
            
            
            
            if(productIdMap.containskey(sms.ProductID__c)){
                sms.Product__c              = productIdMap.get(sms.ProductID__c);
            }
            if(wholesalerBranchIdMap.containskey(sms.Wholesaler_Branch_ID__c)){
                sms.Wholesaler_Branch__c    = wholesalerBranchIdMap.get(sms.Wholesaler_Branch_ID__c);
            }
        }
        
    }
    
    if(trigger.isAfter){
        
        integer thisYear = date.today().year();
        map <Id,Account> updateVolumeMap = new map<Id,Account>();
          
        /*if(trigger.isDelete){
            for(Sale_MySales__c sms : trigger.old){
                if(sms.Outlet__c != null && sms.Sale_Date__c.year() == thisYear)
                    updateVolumeMap.put(sms.Outlet__c, new Account(Id=sms.Outlet__c, Volume__c = 0));
            }
        }
        else {
            for(Sale_MySales__c sms : trigger.new){
                if(sms.Outlet__c != null && sms.Sale_Date__c.year() == thisYear)
                    updateVolumeMap.put(sms.Outlet__c, new Account(Id=sms.Outlet__c, Volume__c = 0));
            }
        }	*/
        
        /*if(updateVolumeMap.size() > 0) {
            list <Sale_MySales__c> smsList = [select id, Outlet__c, Nine_LE__c
                                              from Sale_MySales__c
                                              where Outlet__c IN : updateVolumeMap.keySet()
                                              and Year__c =: thisYear];
            
            for(Sale_MySales__c sms : smsList) {
                if(updateVolumeMap.containsKey(sms.Outlet__c)){
                    if(sms.Nine_LE__c == null)
                        sms.Nine_LE__c = 0;
                    updateVolumeMap.get(sms.Outlet__c).Volume__c +=  sms.Nine_LE__c ;
                }   
            } 
            update updateVolumeMap.values();                   
        }*/
        
        /* Yoann Beurier - Set the MySales record to any active Product MySales record */
        if(trigger.isInsert){
            
            set<string> productsId = new set<string>();
            
            list<Product_Objectives__c> productObjectives = new list<Product_Objectives__c>();
            list<Objective_MySales__c> objectiveMySales = new list<Objective_MySales__c>();
            
            for(Sale_MySales__c saleMySale : trigger.new){
                if(saleMySale.ProductID__c != null){
                    productsId.add(saleMySale.Product__c);
                }
            }
            
            productObjectives  = [SELECT id, Product__c, Objective_Setting__c ,Current_Objective__c, 
                                  Objective_Start_Date__c, Objective_End_Date__c 
                                  FROM Product_Objectives__c 
                                  WHERE  Product__c IN: productsId 
                                  AND ( Current_Objective__c = true
                                       OR (Objective_Start_Date__c  = LAST_N_MONTHS:4
                                           AND Objective_End_Date__c  <= Today)) ];
            
            system.debug('### productsId query : ' + productsId);
            system.debug('### productObjectives query : ' + productObjectives);
            
            // Assign the MySales Record to the correct Objective Settings, based on the SalesMySales date.
            // Loop through the trigger, the products asisgned to objectives, and create the appropriate records.           
            FOR(Sale_MySales__c saleMySale : trigger.new)
            {
                FOR(Product_Objectives__c prodObj : productObjectives)
                {
                    if(saleMySale.Product__c == prodObj.Product__c 
                       && saleMySale.Sale_Date__c >= prodObj.Objective_Start_Date__c
                       && saleMySale.Sale_Date__c <= prodObj.Objective_End_Date__c)
                    {
                        Objective_MySales__c oMS = new Objective_MySales__c();
                        oMs.Objective_Setting__c = prodObj.Objective_Setting__c;
                        oMS.Sale_MySales__c = saleMySale.Id;
                        oMS.Account__c = saleMySale.Outlet__c;
                        oMS.Product_Objective__c = prodObj.Id;
                        oMS.Product__c = prodObj.Product__c;
                        
                        objectiveMySales.add(oMS);
                    }
                }
            }
            insert objectiveMySales;
            
        }
        
    }
    
    
    
}