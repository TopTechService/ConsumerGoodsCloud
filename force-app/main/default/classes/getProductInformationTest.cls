@isTest
public class getProductInformationTest {

    @isTest
    private static void getProductInformationTest() {
	  
        Test.startTest();
     
        Brand__c brn = new Brand__c(Name='Test Brand', Brand_ID__c = 'Brand12314');
        insert brn;
        
        System.debug('brandID: ' + brn.id);
        
        Product__c prod = new Product__c(Name='Test Product', Product_ID__c = '23456', Brand__c = brn.id, Brand_ID__c = 'Brand12314');
      
        insert prod;
         
        String IDList = prod.id;
    
        getProductInformation.ProductInformation s = new getProductInformation.ProductInformation();
        s.productsIDs = IDList;
      		
        List<List<Product__c>> Products = getProductInformation.searchEntries(new List<getProductInformation.ProductInformation> {s});        
        
        Test.stopTest();
                	
    
	}
        
        
        
  	  
}