Map<Id,ProductCategory> mapOfCategories = new Map<Id,ProductCategory>([SELECT Id, Name FROM ProductCategory]);
Map<String,Id> mapOfCategoriesByName = new Map<String,Id>();
for (Id categoryId : mapOfCategories.keySet()) {
    mapOfCategoriesByName.put(mapOfCategories.get(categoryId).Name, categoryId);
}
List<Product2> products = [SELECT Id, cgcloud__Category__c FROM Product2 WHERE cgcloud__Product_Level__c = 'Product'];

List<ProductCategoryProduct> toInsert = new List<ProductCategoryProduct>();

for(Product2 product : products) {
    if(mapOfCategoriesByName.containsKey(product.cgcloud__Category__c)) {
        ProductCategoryProduct newRelationship = new ProductCategoryProduct();
        newRelationship.ProductId = product.Id;
        newRelationship.ProductCategoryId = mapOfCategoriesByName.get(Product.cgcloud__Category__c);
        toInsert.add(newRelationship);
    }
    
}

Database.SaveResult[] results = Database.insert(toInsert, false);