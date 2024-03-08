public with sharing class getCocktailBrands {

    @AuraEnabled
    public static List<String> getBrands() {
        List<String> brands = new List<String>();
        // Query for the distinct brands
        for (Cocktail_definition__c cocktail : [SELECT Brand__c FROM Cocktail_definition__c]) {
            brands.add(cocktail.Brand__c);
        }
        return brands;
    }

    @AuraEnabled
    public static List<String> getSkus(String selectedBrand) {
        List<String> skus = new List<String>();
        // Query for the distinct skus for the selected brand
        for (Cocktail_definition__c cocktail : [SELECT Sku__c FROM Cocktail_definition__c WHERE Brand__c = :selectedBrand]) {
            skus.add(cocktail.Sku__c);
        }
        return skus;
    }

    @AuraEnabled
    public static List<String> getCocktailsBySku(String selectedSku) {
        List<String> cocktails = new List<String>();
        // Query for the distinct cocktails for the selected sku
        for (Cocktail_definition__c cocktail : [SELECT Cocktail__c FROM Cocktail_definition__c WHERE Sku__c = :selectedSku]) {
            cocktails.add(cocktail.Cocktail__c);
        }
        return cocktails;
    }
}