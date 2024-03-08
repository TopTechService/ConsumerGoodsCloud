/*
*   Author : Andrey Piasetski @ Carnac Group
*   Created : 09/09/2019
*
*   Description : First, form a map, where the key is a string of AccountID and ProductID.
*   If the map already has a record with the same key, then update the date. Then iterate through
*   each record of the Product_Range__c object and check the existence of the record in the map
*   with the AccountID and the ProductID. If the current date is less than the date from the map,
*   then update the record.
*
*   Method 1 : runRecalculate()
*
*/ 

public with sharing class Recalculate_LastPurchaseDate {

    public static void runRecalculate() {

        // Create map Sale_MySales__c
        Map<String, Sale_MySales__c> mapSaleMySales = new Map<String, Sale_MySales__c>();
        List<Sale_MySales__c> listSaleMySales = [
            SELECT Id, Sale_Date__c, Product__c, Outlet__c
            FROM Sale_MySales__c
        ];

        if (listSaleMySales.size() != 0) {
            for (Sale_MySales__c item : listSaleMySales) {
                if (mapSaleMySales.containsKey(item.Outlet__c + '&' + item.Product__c)) {
                    Sale_MySales__c mapRecord = mapSaleMySales.get(item.Outlet__c + '&' + item.Product__c);
                    if (mapRecord != null && mapRecord.Sale_Date__c < item.Sale_Date__c) {
                        mapSaleMySales.put(item.Outlet__c + '&' + item.Product__c, item);
                    }
                } else {
                    mapSaleMySales.put(item.Outlet__c + '&' + item.Product__c, item);
                }
            }
        }

        // Get list Product_Range__c
        List<Product_Range__c> listProductRange = [
            SELECT Id, IsDeleted, Name, Account__c, Product__c, Last_Purchase_Date__c
            FROM Product_Range__c
        ];

        // Create list to update
        if (listProductRange.size() != 0) {
            List<Product_Range__c> listProductRangeToUpdate = new List<Product_Range__c>();

            for (Product_Range__c item : listProductRange) {
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
    }
}