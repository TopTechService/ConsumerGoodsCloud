@isTest
private class getCocktailBrandsTest {

    @testSetup
    static void setup() {
        // Create test records
        List<Cocktail_definition__c> testCocktails = new List<Cocktail_definition__c>();
        testCocktails.add(new Cocktail_definition__c(Brand__c = 'Campari', Sku__c = 'Campari 1L', Cocktail__c = 'Americano'));
        testCocktails.add(new Cocktail_definition__c(Brand__c = 'Aperol', Sku__c = 'Aperol 700ml', Cocktail__c = 'Aperol Spritz'));
        testCocktails.add(new Cocktail_definition__c(Brand__c = 'Campari', Sku__c = 'Campari 700ml', Cocktail__c = 'Campari Spritz'));
        insert testCocktails;
    }

    @isTest
    static void testGetBrands() {
        List<String> expectedBrands = new List<String>{'Campari', 'Aperol', 'Campari'};
        List<String> actualBrands = getCocktailBrands.getBrands();
        System.assertEquals(expectedBrands, actualBrands, 'Incorrect list of brands returned');
    }

    @isTest
    static void testGetSkus() {
        String selectedBrand = 'Campari';
        List<String> expectedSkus = new List<String>{'Campari 1L', 'Campari 700ml'};
        List<String> actualSkus = getCocktailBrands.getSkus(selectedBrand);
        System.assertEquals(expectedSkus, actualSkus, 'Incorrect list of skus returned');
    }

    @isTest
    static void testGetCocktailsBySku() {
        String selectedSku = 'Aperol 700ml';
        List<String> expectedCocktails = new List<String>{'Aperol Spritz'};
        List<String> actualCocktails = getCocktailBrands.getCocktailsBySku(selectedSku);
        System.assertEquals(expectedCocktails, actualCocktails, 'Incorrect list of cocktails returned');
    }
}