/**    
    Company:            Carnac Group 
    Description:        Get selected product's information   
    Date:               26-May-2021 
        
    TODO: 
    
*/
public class getProductInformation {

    @InvocableMethod(label='Get selected products' description='Get a records from id selection')
    public static List<List<Product__c>> searchEntries(List<ProductInformation> requests) {
        if (requests == NULL || requests.size() == 0) {
            return new List<List<Product__c>>();
        }
        
        ProductInformation request = requests[0];
        
        System.debug('request: ' + request);
        System.debug('request: ' + request.productsIDs);
        
        List<ID> ids = new List<Id>();
        for (String id : request.productsIDs.split(';')) {
            if (String.isNotBlank(id)) ids.add(id.trim());
        }
       
		System.debug('ids: ' + ids);
        
        return new List<List<Product__c>>{ [ SELECT Id, Name, PSS_value_Big_Box__c, PSS_class_Big_Box__c, PSS_class_Convenience__c, 
                                            PSS_class_Drive_thru__c, PSS_class_Specialty__c, PSS_Product__c, 
                                            PSS_value_Convenience__c,PSS_value_Drive_Thru__c, PSS_value_Specialty__c                                            
                 FROM Product__c 
                 WHERE Id in :ids]};
        
        
        /*
        List<Product__c> products = [ SELECT Id, Name 
                 FROM Product__c 
                 WHERE Id in :ids];
        
        System.debug('products: ' + products);
        return new List<List<Product__c>> {products};
          */  
            
    }
    
    public class ProductInformation {
 
        @InvocableVariable
        public String productsIDs;
  

    }
}