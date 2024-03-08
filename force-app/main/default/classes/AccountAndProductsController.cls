/*
@test Class: AccountProductPageControllerTest
*/
public class AccountAndProductsController{

    public List<Product__c> prodList {get;set;}
    public List<String> clasificationValues {get;set;}
    public Map<String, List<Product__c>> ClassificationVsProduct {get;set;}
    public Account account {get;set;}
    public Id productId {get;set;}
    public Map<id, ProductWrapper> prodIdVsProductWrapper {get;set;}
    public INTEGER width {get;set;}
    public Boolean toReresh {get;set;}
    
    public AccountAndProductsController(ApexPages.StandardController controller) {
        account = (Account)controller.getRecord();
        
        //Get All Products With Active Skus 
        prodList = [SELECT id, Name, SKU_Name__c, SKU_Active__c, Classification__c FROM Product__c WHERE SKU_Active__c = TRUE];
        clasificationValues = new List<String>();
        List<Product__c> productByClassification = new List<Product__c>();
        ClassificationVsProduct = new Map<String, List<Product__c>>();
        
        //Get Classification Picklist values dynamically            
        Schema.DescribeFieldResult fieldResult = Product__c.Classification__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                    
        for( Schema.PicklistEntry f : ple){
            clasificationValues.add(f.getValue());
        }       
        
        //Create Map of Classification values with list Product records
        for(String clasification: clasificationValues){
            productByClassification = new List<Product__c>();
            if(String.isBlank(clasification))
                break;
            for(Product__c prod : prodList){
                if(prod.Classification__c == clasification)
                    productByClassification.add(prod);
            }
            ClassificationVsProduct.put(clasification, productByClassification);
        }

        //Get width to for dynamic css on VF page
        width = 100 / ClassificationVsProduct.size();
        
        prodIdVsProductWrapper = new Map<id, ProductWrapper>();
        for(Product__c prod : prodList){
            prodIdVsProductWrapper.put(prod.id, new ProductWrapper(prod, false));
        }
        
        //Get Existing Skus with Wrapper object
        Map<id, Outlet_SKUs__c> existingSkuRecords = getExistingSkus();
        for(Outlet_SKUs__c outlets : existingSkuRecords.values()){
            if(prodIdVsProductWrapper.containsKey(outlets.Product__c))
                prodIdVsProductWrapper.get(outlets.Product__c).isPresent = TRUE;
        }
    }
    
    //Create OR Delete SKU Outlet Records
    public PageReference createProduct(){
        Outlet_SKUs__c[] exitingSkus = new List<Outlet_SKUs__c>();
        exitingSkus = [SELECT id, Name FROM Outlet_SKUs__c WHERE Product__c = : productId AND OutletAccount__c = : account.id];
        
        //If SKU exist withSame account and Product, Delete it else create new one
        if(exitingSkus.size() > 0){
            delete exitingSkus[0];
            toReresh = TRUE;
            system.debug('-=-=-=-toReresh-=-='+toReresh);
            if(prodIdVsProductWrapper.containsKey(productId))
                prodIdVsProductWrapper.get(productId).isPresent = FALSE;
        }else{
            Outlet_SKUs__c skuToInsert = new Outlet_SKUs__c();
            skuToInsert.Product__c = productId;
            skuToInsert.OutletAccount__c = account.id;
            insert skuToInsert;
            if(prodIdVsProductWrapper.containsKey(productId))
                prodIdVsProductWrapper.get(productId).isPresent = TRUE;
        }
        return NULL;
    }
    
    //Get Existing Outlet Skus
    public Map<id, Outlet_SKUs__c> getExistingSkus(){
        Map<id, Outlet_SKUs__c> existingSkuRecords = new Map<id, Outlet_SKUs__c>();
        existingSkuRecords = new Map<id, Outlet_SKUs__c>([SELECT id, Name, OutletAccount__c, Product__c 
                                                                                      FROM Outlet_SKUs__c
                                                                                      WHERE OutletAccount__c = : account.id
                                                                                     ]);
        return existingSkuRecords;
    }
     
    public Map<String, List<Product__c>> getClassificationVsProduct(){
        return ClassificationVsProduct;
    }
    
    //Wrapper Class
    public class ProductWrapper{
        public Product__c prodct {get;set;}
        public Boolean isPresent {get; set;} 
        
        public ProductWrapper(Product__c prodct, Boolean isPresent){
            this.prodct = prodct;
            this.isPresent = isPresent;
        }
    }
}