@isTest
public class TestGeneratePVSAccountProd {


    private static testMethod void doTest() {

        Test.startTest();
        
        // Create Account        
       
         Brand__c brand = new Brand__c(Name = 'Test brand', Brand_ID__c = '2345');
                                                    
        insert brand;
        
        Product__c objProduct = new Product__c(Name = 'Test product1', brand__c= brand.id, Product_ID__c='Unique231', Brand_ID__c = brand.Brand_ID__c);
                                                    
        insert objProduct;
        
        List<Product__c> NewProds = new List<Product__c>();
        
        NewProds.add(objProduct);
        
       // PriceBookEntry objPBE = new PriceBookEntry(UnitPrice = 300, PriceBook2Id = Test.getStandardPricebookId(),
      //                                                  Product2Id = objProduct.Id, IsActive = true);
                                                               
      //  insert objPBE;
        
        List<string> prods = new List<string>();
        
        For(Product__c prod : NewProds){
            prods.add(prod.id);
            
        }
        
        
        
      
        
        GeneratePVSAccountProd.ProductInformation s = new GeneratePVSAccountProd.ProductInformation();
        s.ListofProd = prods;
        
        
        GeneratePVSAccountProd.searchEntries(new list<GeneratePVSAccountProd.ProductInformation> {s});

        Test.stopTest();


    }
    
}