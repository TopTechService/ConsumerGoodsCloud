global class Recalculate_LastPurchaseDate_Batch implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        return Database.getQueryLocator(
            'SELECT Id, Account__c, Product__c, Last_Purchase_Date__c FROM Product_Range__c'
        );
    }

    global void execute(Database.BatchableContext bc, List<Product_Range__c> scope){
        // process each batch of records
        Set<Id> productIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        for(Product_Range__c productRange : scope){
            productIds.add(productRange.Product__c);
            accountIds.add(productRange.Account__c);
        }

        Map<String, Sale_MySales__c> mapSaleMySales = new Map<String, Sale_MySales__c>();

        List<Sale_MySales__c> saleMySalesList = [
            SELECT Id, Sale_Date__c, Product__c, Outlet__c
            FROM Sale_MySales__c
            WHERE Product__c IN :productIds AND Outlet__c IN :accountIds
        ];

        for (Sale_MySales__c item : saleMySalesList) {
            if (mapSaleMySales.containsKey(item.Outlet__c + '&' + item.Product__c)) {
                Sale_MySales__c mapRecord = mapSaleMySales.get(item.Outlet__c + '&' + item.Product__c);
                if (mapRecord != null && mapRecord.Sale_Date__c < item.Sale_Date__c) {
                    mapSaleMySales.put(item.Outlet__c + '&' + item.Product__c, item);
                }
            } else {
                mapSaleMySales.put(item.Outlet__c + '&' + item.Product__c, item);
            }
        }

        // Create list to update
        List<Product_Range__c> listProductRangeToUpdate = new List<Product_Range__c>();
        for (Product_Range__c item : scope) {
            if (mapSaleMySales.containsKey(item.Account__c + '&' + item.Product__c)) {
                Sale_MySales__c mapRecord = mapSaleMySales.get(item.Account__c + '&' + item.Product__c);
                System.debug('Change Product_Range__c record : Id=' + item.Id + ' [ ' + item.Last_Purchase_Date__c + ' => ' + mapRecord.Sale_Date__c + ' ]');
                item.Last_Purchase_Date__c = mapRecord.Sale_Date__c;
                listProductRangeToUpdate.add(item);
            }
        }

        if (listProductRangeToUpdate.size() != 0) {
            update listProductRangeToUpdate;
        }
    }

    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }

}