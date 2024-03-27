public with sharing class SaleMySalesTriggerHelper {

    public static void setParentsOnSaleMySales(List<Sale_MySales__c> newSales) {

        Set<String> productIds = new Set<String>();
        Set<String> wholesalerBranchIds = new Set<String>();
        Set<String> outletIds = new Set<String>();
        Set<String> bannerGroupIds = new Set<String>();

        for (Sale_MySales__c sale : newSales) {
            if (!String.isBlank(sale.ProductID__c)) {
                productIds.add(sale.ProductID__c);
            }
            if (!String.isBlank(sale.Wholesaler_Branch_ID__c)) {
                wholesalerBranchIds.add(sale.Wholesaler_Branch_ID__c);
            }
            if (!String.isBlank(sale.OutletID__c)) {
                outletIds.add(sale.OutletID__c);
            }
        }

        List<RetailStore> retailStores = [SELECT Id, Banner_Group__c, My_Sales_ID__c,
                                          Banner_Group__r.Banner_Group_ID__c, OwnerId 
                                          FROM RetailStore
                                          WHERE My_Sales_ID__c IN :outletIds
                                          ];

        List<Product2> products = [SELECT Id, MySales_Product_Id__c 
                                   FROM Product2
                                   WHERE MySales_Product_Id__c IN :productIds
                                   ];

        List<Wholesaler_Branch__c> wholesalerBranches = [SELECT Id, Wholesaler_Branch_Id__c 
                                                         FROM Wholesaler_Branch__c
                                                         WHERE Wholesaler_Branch_Id__c IN :wholesalerBranchIds
                                                         ];

        Map<String,RetailStore> outletIdMap = new Map<String,RetailStore>();
        Map<String,Id> productIdMap = new Map<String,Id>();
        Map<String,Id> wholesalerBranchIdMap = new Map<String,Id>();
        
        for (RetailStore store : retailStores) {
            outletIdMap.put(store.My_Sales_ID__c, store);
            bannerGroupIds.add(store.Banner_Group__r.Banner_Group_ID__c);
        }

        for (Product2 product : products) {
            productIdMap.put(product.MySales_Product_Id__c, product.Id);
        }

        for (Wholesaler_Branch__c branch : wholesalerBranches) {
            wholesalerBranchIdMap.put(branch.Wholesaler_Branch_Id__c, branch.Id);
        }

        Map<String,String> regionIdMap = new Map<String,String>();

        for(Wholesaler_Banner_Group__c wbp : [SELECT Banner_Group_ID__c, Region__r.Region_ID__c
                                              FROM Wholesaler_Banner_Group__c
                                              WHERE Banner_Group_ID__c IN: bannerGroupIds
                                              ]){
    
            regionIdMap.put(wbp.Banner_Group_ID__c,wbp.Region__r.Region_ID__c);
        }

        for (Sale_MySales__c newSale : newSales) {
            if (outletIdMap.containsKey(newSale.OutletID__c)) {
                newSale.Banner_Group__c = outletIdMap.get(newSale.OutletID__c).Banner_Group__c;
                newSale.Retail_Store__c = outletIdMap.get(newSale.OutletID__c).Id;
                newSale.OwnerId = outletIdMap.get(newSale.OutletID__c).OwnerId;

                if (regionIdMap.containsKey(outletIdMap.get(newSale.OutletID__c).Banner_Group__r.Banner_Group_ID__c)) {
                    newSale.Region_Id__c = regionIdMap.get(outletIdMap.get(newSale.OutletID__c).Banner_Group__r.Banner_Group_ID__c);
                }
            }
            if (productIdMap.containsKey(newSale.ProductID__c)) {
                newSale.Product2__c = productIdMap.get(newSale.ProductID__c);
            }
            if (wholesalerBranchIdMap.containsKey(newSale.Wholesaler_Branch_ID__c)) {
                newSale.Wholesaler_Branch__c = wholesalerBranchIdMap.get(newSale.Wholesaler_Branch_ID__c);
            }
        }
    }

    public static void assignObjectives(List<Sale_MySales__c> newSales) {

        Set<String> productIds = new Set<String>();
        List<Objective_MySales__c> objectivesMySales = new List<Objective_MySales__c>();

        for (Sale_MySales__c sale : newSales) {
            if (!String.isBlank(sale.Product2__c)) {
                productIds.add(sale.Product2__c);
            }   
        }

        List<Product_Objectives__c> productObjectives = [SELECT Id, Product2__c, Objective_Setting__c,
                                                         Current_Objective__c, Objective_Start_Date__c,
                                                         Objective_End_Date__c 
                                                         FROM Product_Objectives__c
                                                         WHERE Product2__c IN :ProductIds 
                                                         AND (Current_Objective__c =  true
                                                             OR (Objective_Start_Date__c = LAST_N_MONTHS:4
                                                                AND Objective_End_Date__c <= TODAY))
                                                         ];

        //Assign the SaleMySales record to the correct objective setting based on the dates.
        for (Sale_MySales__c newSale : newSales) {
            for (Product_Objectives__c objective : productObjectives) {
                if (newSale.Product2__c == objective.Product2__c
                    && newSale.Sale_Date__c >= objective.Objective_Start_Date__c
                    && newSale.Sale_Date__c <= objective.Objective_End_Date__c) {
                Objective_MySales__c objObjective = new Objective_MySales__c();
                objObjective.Objective_Setting__c = objective.Objective_Setting__c;
                objObjective.Sale_MySales__c = newSale.Id;
                objObjective.Retail_Store__c = newSale.Retail_Store__c;
                objObjective.Product_Objective__c = objective.Id;
                objObjective.Product2__c = objective.Product2__c;

                objectivesMySales.add(objObjective);
                }
            }
        }

        Database.SaveResult[] objectiveResults = Database.insert(objectivesMySales, false);
    }
}