public class getControllingPicklistValue {
	
    
    @InvocableMethod(label='Create Cocktail' description='Create Cocktail with multiple Brands')
    public static void createCocktails(List<FlowInformation> requests) {
        if (requests == NULL || requests.size() == 0) {
     //       return new List<List<Product__c>>();
        }
        
       	flowInformation request = requests[0];
        String cocktail = request.cocktail;
        string pvsId = request.pvsId;
  		List<String> selectedSKUs = request.selectedSKUs;
        Boolean customName = request.customName;
        
		Map<string,string> brandsIds = new Map<string,string>();
        
      	String objectName = 'PVS_Cocktails_on_menu__c';
        String controllingField = 'Brand__c';
        String dependentField = 'SKU__c';
           
       //Prepare map Dependant-Controller
        Map<String, List<String>> controllingInfo = new Map<String, List<String>>();
		Map<String, String> Sku_Brands = new Map<String, String>();
        
   		Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);

        Schema.DescribeSObjectResult describeResult = objType.getDescribe();
        Schema.DescribeFieldResult controllingFieldInfo = describeResult.fields.getMap().get(controllingField).getDescribe();
        Schema.DescribeFieldResult dependentFieldInfo = describeResult.fields.getMap().get(dependentField).getDescribe();
    
        List<Schema.PicklistEntry> controllingValues = controllingFieldInfo.getPicklistValues();
        List<Schema.PicklistEntry> dependentValues = dependentFieldInfo.getPicklistValues();
    
        for(Schema.PicklistEntry currControllingValue : controllingValues)
        {
            System.debug('ControllingField: Label:' + currControllingValue.getLabel());
            controllingInfo.put(currControllingValue.getLabel(), new List<String>());
        }

            for(Schema.PicklistEntry currDependentValue : dependentValues)
            {
                String jsonString = JSON.serialize(currDependentValue);
        
                MyPickListInfo info = (MyPickListInfo) JSON.deserialize(jsonString, MyPickListInfo.class);
        
                String hexString = EncodingUtil.convertToHex(EncodingUtil.base64Decode(info.validFor)).toUpperCase();
        
                System.debug('DependentField: Label:' + currDependentValue.getLabel() + ' ValidForInHex:' + hexString + ' JsonString:' + jsonString);
        
                Integer baseCount = 0;
        
                for(Integer curr : hexString.getChars())
                {
                    Integer val = 0;
        
                    if(curr >= 65)
                    {
                        val = curr - 65 + 10;
                    }
                    else
                    {
                        val = curr - 48;
                    }
        
                    if((val & 8) == 8)
                    {
                        System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 0].getLabel());
                        controllingInfo.get(controllingValues[baseCount + 0].getLabel()).add(currDependentValue.getLabel());
                    }
                    if((val & 4) == 4)
                    {
                        System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 1].getLabel());
                        controllingInfo.get(controllingValues[baseCount + 1].getLabel()).add(currDependentValue.getLabel());                    
                    }
                    if((val & 2) == 2)
                    {
                        System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 2].getLabel());
                        controllingInfo.get(controllingValues[baseCount + 2].getLabel()).add(currDependentValue.getLabel());                    
                    }
                    if((val & 1) == 1)
                    {
                        System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 3].getLabel());
                        controllingInfo.get(controllingValues[baseCount + 3].getLabel()).add(currDependentValue.getLabel());                    
                    }
        
                    baseCount += 4;
                }            
            } 
   
        
        For(string brand : controllingInfo.keyset()){
            For(string skus : controllingInfo.get(brand)){
                Sku_Brands.put(skus,brand);
            }
        }
		
		
        List<PVS_PSS_Brand__c> brandList = [select id, Brand_Name__c from PVS_PSS_Brand__c];
        for(PVS_PSS_Brand__c brList : brandList){
            brandsIds.put(brList.Brand_Name__c, brList.id);
        }
 
		List<PVS_Cocktails_on_menu__c> newCocktailList = new List<PVS_Cocktails_on_menu__c>();
		
        for(string skus : selectedSKUs){
            
            system.debug('Cocktail: '+ cocktail);
            system.debug('SKU: '+ skus);
          //  system.debug('Brand: '+ controllingInfo.get(skus));
                        
            PVS_Cocktails_on_menu__c newCocktail = new PVS_Cocktails_on_menu__c();
            newCocktail.Use_Custom_Name__c = customName;
            if(newCocktail.Use_Custom_Name__c){
                newCocktail.Custom_Cocktail__c = cocktail;
            	}
            	else{
                	newCocktail.Cocktail_single__c = cocktail;
            	}
            newCocktail.Brand__c = Sku_Brands.get(skus);
            newCocktail.SKU__c = skus;
            newCocktail.PVS__c = pvsId;
            newCocktail.Brand_lookup__c = brandsIds.get(Sku_Brands.get(skus));
            
            newCocktailList.add(newCocktail); 
        }
            
        insert newCocktailList;
                        
     }
    

    public class MyPickListInfo
   {
        public String validFor;
   }
    
    
   public class FlowInformation {
      @InvocableVariable
        public string cocktail;
      @InvocableVariable
  		public List<string> selectedSKUs;
      @InvocableVariable
       	public boolean customName;
	  @InvocableVariable
       	public string customCocktailName;
      @InvocableVariable
       	public string pvsId;
    }
    
    
    
    

}