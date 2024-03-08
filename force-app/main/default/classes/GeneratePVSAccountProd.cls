/**    
    Company:            Carnac Group 
    Description:        Generate PVS Account Products
    Date:               14-Jul-2021 
        
    
    
*/


public class GeneratePVSAccountProd {
           
    	@InvocableMethod(label='Get selected products records' description='Get corresponding records from ID list')
   		public static List<List<Product__c>> searchEntries(List<ProductInformation> requests) {
        if (requests == NULL || requests.size() == 0) {
            return new List<List<Product__c>>();
        }
        
        ProductInformation request = requests[0];
        
      //  System.debug('request: ' + request);
    //    System.debug('request: ' + request.productsIDs);
        
		List<string> SelectedProds = request.ListofProd;
	     
        return new List<List<Product__c>>{ [ SELECT Id, Name, PVS_value_Traditional__c, PVS_value_SmallCocktailBar__c, PVS_value_Premium__c, 
                                            PVS_value_Party__c, PVS_value_Nightclub_Event__c, PVS_value_Contemporary__c, PVS_value_Basic__c, 
                                            PVS_Product__c, PVS_class_Traditional__c, PVS_class_SmallCocktailBar__c, PVS_class_Premium__c, 
                                            PVS_class_Party__c, PVS_class_Nightclub_Event__c, PVS_class_Contemporary__c, PVS_class_Basic__c, 
                                            PSS_value_Specialty__c, PSS_value_Drive_Thru__c, PSS_value_Convenience__c, PSS_value_Big_Box__c, 
                                            PSS_Product__c, PSS_class_Specialty__c, PSS_class_Drive_thru__c, PSS_class_Convenience__c, 
                                            PSS_class_Big_Box__c
                 FROM Product__c 
                 WHERE Id in :SelectedProds]};
        
          
    }
    
    public class ProductInformation {
 
        
         
  		@InvocableVariable
        Public List<string> ListofProd;
	}
    
}