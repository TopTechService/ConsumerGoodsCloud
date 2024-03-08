public class productTriggerHandler implements ITriggerHandler
{
    
    // Allows unit tests (or other code) to disable this trigger for the transaction
    public static Boolean TriggerDisabled = false;
    
    /*
Checks to see if the trigger has been disabled either by custom setting or by running code
*/
    public Boolean IsDisabled()
    {
        /*TriggerSettings__c ts = TriggerSettings__c.getOrgDefaults();

if (ts.AccountTriggerDisabled__c == true)
return true;
else*/
        return TriggerDisabled;
    }
    
    public void BeforeInsert(List<SObject> newItems) {}
    
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
    
    public void BeforeDelete(Map<Id, SObject> oldItems) {}
    
    public void AfterInsert(Map<Id, SObject> newItems) {
        
        // Check if the new Product is set to Standard Range.
        //
        Set<Id>          		productIds 		= new Set<Id>();
        List<Account>			liAccounts		= new List<Account>();
        List<Product2>    productsToInsert      = new List<Product2>();
        
        for (Id setProductId : newItems.keyset())
        {
            // Build the Set of the Prodcuts being in the Standard Range          
            if( newItems.get( setProductId ).get(Product__c.Standard_Range__c ) == true )
            {
                productIds.add(setProductId);
            }

        // Added by daniel.peaper@viseo.com 05/03/2024
        // CGC Project - Sync Product__c with Product2
            Product__c mySalesProduct = (Product__c)newItems.get(setProductId);
            Product2 newProduct = new Product2(Name = mySalesProduct.Name,
                                               IsActive = !mySalesProduct.Deactivate__c,
                                               cgcloud__Consumer_Goods_Product_Code__c = mySalesProduct.Product_ID__c,
                                               cgcloud__Product_Short_Code__c = mySalesProduct.SKU_Name__c,
                                               Product__c = mySalesProduct.Shor_Name_Flows__c,
                                               CPI_Name__c = mySalesProduct.CPI_Name__c,
                                               cgcloud__Product_Form__c = mySalesProduct.Classification__c,
                                               cgcloud__Container_Type__c = mySalesProduct.SKU_Format__c,
                                               PSS_Product__c = mySalesProduct.PSS_Product__c,
                                               PVS_Product__c = mySalesProduct.PVS_Product__c,
                                               cgcloud__Criterion_3_Product__c = mySalesProduct.Product2_Brand_Id__c,
                                               Reporting_Brand__c = mySalesProduct.Reporting_Brand__c,
                                               cgcloud__Category__c = mySalesProduct.Product_Category__c,
                                               cgcloud__Container_Size_Unit__c = 'ml',
                                               cgcloud__Pack_Size__c = mySalesProduct.Bottles_Per_Carton__c,
                                               Number_of_units_by_Case__c = mySalesProduct.Bottles_Per_Carton__c,
                                               cgcloud__Pack_Size_Unit__c = 'Carton',
                                               cgcloud__Consumer_Goods_External_Product_Id__c = mySalesProduct.SAP_Code__c,
                                               Promoted_Range_Id__c = mySalesProduct.PromotedRangeID__c,
                                               Core_Range__c = mySalesProduct.Standard_Range__c,
                                               Distribution_Range__c = mySalesProduct.SKU_Active__c,
                                               MySales_Product_Id__c = setProductId
                                               );

            if (mySalesProduct.MLs_Per_Bottle__c != null) {
                newProduct.cgcloud__Container_Size__c = Decimal.valueOf(mySalesProduct.MLs_Per_Bottle__c);
                newProduct.Volume_Litre_by_Unit__c = newProduct.cgcloud__Container_Size__c / 1000;
            }

            if (mySalesProduct.Product_Packsize__c != null) {
                switch on mySalesProduct.Product_Packsize__c {
                    when '1' {
                        newProduct.QuantityUnitOfMeasure = 'Each';                           
                    }
                    when else {
                        newProduct.QuantityUnitOfMeasure = 'Pack of ' + mySalesProduct.Product_Packsize__c;
                    }    
                }
            } else {
                newProduct.QuantityUnitOfMeasure = 'Each';
            }

            productsToInsert.add(newProduct);
        }

        Database.SaveResult[] newProductResults = Database.insert(productsToInsert, false);

        // *** End of changes by daniel.peaper@viseo.com ***
        
        if (productIds.size() > 0){
            Id OutletRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Outlet').getRecordTypeId();
            
            
            for(Account a : [SELECT id  FROM Account WHERE RecordTypeId = : OutletRecordTypeId AND Called_On__c = true])
                liAccounts.add(a);
            
            productRangeCreate(productIds, liAccounts);
        }
    }
    
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        
        // Check if the new Product is set to Standard Range or remove from Range.
        //
        Set<Id>          		newproductIds 		= new Set<Id>();
        Set<Id>          		oldproductIds 		= new Set<Id>();
        List<Account>			   liAccounts		= new List<Account>();

        // Added by daniel.peaper@viseo.com 7/03/2024
        // CGC Project - Sync Product__c with Product2

        List<product2> productsToUpdate = new List<Product2>();
        Map<String,Product2> mapOfMySalesProductIdToProduct2 = new Map<String,Product2>();

        //Get Product2 records that match the updated Product__c records
        Map<Id,Product2> mapOfProduct2 = new Map<Id,Product2>([SELECT Name, MySales_Product_Id__c 
                                                               FROM Product2
                                                               WHERE MySales_Product_Id__c IN :newItems.keySet()
                                                               ]);

        //Build map of mySales Product Ids to Product2
        for (Id product2Id : mapOfProduct2.keySet()) {
            Product2 obj = mapOfProduct2.get(product2Id);
            mapOfMySalesProductIdToProduct2.put(obj.MySales_Product_Id__c, obj);
        } 


        
        for (Id setProductId : newItems.keyset())
        {
            // Build the Set of the Prodcuts being upadted to be in the Standard Range          
            if( newItems.get( setProductId ).get(Product__c.Standard_Range__c ) == true 
               && oldItems.get( setProductId ).get(Product__c.Standard_Range__c ) == false)
            {
                newproductIds.add(setProductId);
            } 
            else if( newItems.get( setProductId ).get(Product__c.Deactivate__c  ) == true 
                    && oldItems.get( setProductId ).get(Product__c.Deactivate__c  ) == false)
            {
                oldproductIds.add(setProductId);
            }
            else if( newItems.get( setProductId ).get(Product__c.Standard_Range__c ) == false 
                    && oldItems.get( setProductId ).get(Product__c.Standard_Range__c ) == true)
            {
                oldproductIds.add(setProductId);
            }

            //Added by daniel.peaper@viseo.com 07/03/2024
            // CGC Project - Sync Product__c with Product2
            if (mapOfMySalesProductIdToProduct2.containsKey(setProductId)) {
                Product__c oldProduct = (Product__c)oldItems.get(setProductId);
                Product__c newProduct = (Product__c)newItems.get(setProductId);
                Product2 productToUpdate = mapOfMySalesProductIdToProduct2.get(setProductId);
                //Check for updated fields
                if (newProduct.Name != oldProduct.Name) {
                    productToUpdate.Name = newProduct.Name;
                }
                if (newProduct.Deactivate__c != oldProduct.Deactivate__c) {
                    productToUpdate.IsActive = !newProduct.Deactivate__c;
                }
                if (newProduct.Product_ID__c != oldProduct.Product_ID__c) {
                    productToUpdate.cgcloud__Consumer_Goods_Product_Code__c = newProduct.Product_ID__c;
                }
                if (newProduct.SKU_Name__c != oldProduct.SKU_Name__c) {
                    productToUpdate.cgcloud__Product_Short_Code__c = newProduct.SKU_Name__c;
                }
                if (newProduct.Shor_Name_Flows__c != oldProduct.Shor_Name_Flows__c) {
                    productToUpdate.Product__c = newProduct.Shor_Name_Flows__c;
                }
                if (newProduct.CPI_Name__c != oldProduct.CPI_Name__c) {
                    productToUpdate.CPI_Name__c = newProduct.CPI_Name__c;
                }
                if (newProduct.Classification__c != oldProduct.Classification__c) {
                    productToUpdate.cgcloud__Product_Form__c = newProduct.Classification__c;
                }
                if (newProduct.SKU_Format__c != oldProduct.SKU_Format__c) {
                    productToUpdate.cgcloud__Container_Type__c = newProduct.SKU_Format__c;
                }
                if (newProduct.PSS_Product__c != oldProduct.PSS_Product__c) {
                    productToUpdate.PSS_Product__c = newProduct.PSS_Product__c;
                }
                if (newProduct.PVS_Product__c != oldProduct.PVS_Product__c) {
                    productToUpdate.PVS_Product__c = newProduct.PVS_Product__c;
                }
                if (newProduct.Product2_Brand_Id__c != oldProduct.Product2_Brand_Id__c) {
                    productToUpdate.cgcloud__Criterion_3_Product__c = newProduct.Product2_Brand_Id__c;
                }
                if (newProduct.Reporting_Brand__c != oldProduct.Reporting_Brand__c) {
                    productToUpdate.Reporting_Brand__c = newProduct.Reporting_Brand__c;
                }
                if (newProduct.Product_Category__c != oldProduct.Product_Category__c) {
                    productToUpdate.cgcloud__Category__c = newProduct.Product_Category__c;
                }
                if (newProduct.Bottles_Per_Carton__c != oldProduct.Bottles_Per_Carton__c) {
                    productToUpdate.cgcloud__Pack_Size__c = newProduct.Bottles_Per_Carton__c;
                    productToUpdate.Number_of_units_by_Case__c = newProduct.Bottles_Per_Carton__c;
                }
                if (newProduct.PromotedRangeID__c != oldProduct.PromotedRangeID__c) {
                    productToUpdate.Promoted_Range_ID__c = newProduct.PromotedRangeID__c;
                }
                if (newProduct.Standard_Range__c != oldProduct.Standard_Range__c) {
                    productToUpdate.Core_Range__c = newProduct.Standard_Range__c;
                }
                if (newProduct.SKU_Active__c != oldProduct.SKU_Active__c) {
                    productToUpdate.Distribution_Range__c = newProduct.SKU_Active__c;
                }
                if (newProduct.MLs_Per_Bottle__c != oldProduct.MLs_Per_Bottle__c) {
                    if (newProduct.MLs_Per_Bottle__c != null) {
                        productToUpdate.cgcloud__Container_Size__c = Decimal.valueOf(newProduct.MLs_Per_Bottle__c);
                        productToUpdate.Volume_Litre_by_Unit__c = productToUpdate.cgcloud__Container_Size__c / 1000;
                    }
                }
                if (newProduct.Product_Packsize__c != oldProduct.Product_Packsize__c) {
                    if (newProduct.Product_Packsize__c != null) {
                        switch on newProduct.Product_Packsize__c {
                            when '1' {
                                productToUpdate.QuantityUnitOfMeasure = 'Each';
                            }
                            when else {
                                productToUpdate.QuantityUnitOfMeasure = 'Pack of ' + newProduct.Product_Packsize__c;
                            }
                        }
                    } else {
                        productToUpdate.QuantityUnitOfMeasure = 'Each';
                    }
                }
                productsToUpdate.add(productToUpdate);
            }
        }

        Database.SaveResult[] updatedProductResults = Database.update(productsToUpdate, true);

        // *** End of changes by daniel.peaper@viseo.com *** 
        
        
        if (newproductIds.size() > 0){
            Id OutletRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Outlet').getRecordTypeId();
            
            for(Account a : [SELECT id  FROM Account WHERE RecordTypeId = : OutletRecordTypeId AND Called_On__c = true])
                liAccounts.add(a);
            
            productRangeCreate(newproductIds, liAccounts);
        }
        
        if (oldproductIds.size() > 0){
            productRangeDelete(oldproductIds);
        }
        
    }
    
    public void AfterDelete(Map<Id, SObject> oldItems) {}
    
    public void AfterUndelete(Map<Id, SObject> oldItems) {}
    
    public void productRangeCreate(Set<Id> liProducts, List<Account> liAccounts){
        
        List<Product_Range__c> liProductRange = new List<Product_Range__c>();
        for(Id p : liProducts)
        {
            for(Account a : liAccounts)
            {
                Product_Range__c pr = new Product_Range__c();
                pr.Account__c = a.id;
                pr.Product__c = p;
                liProductRange.Add(pr);
            } 
        }
        insert liProductRange;
    }
    
    public void productRangeDelete(Set<Id> liProducts){
        
        List<Product_Range__c> liProductRange = new List<Product_Range__c>();
        
        for(Product_Range__c pr : [Select Id FROM Product_Range__c WHERE Product__c IN: liProducts])
        {
            Product_Range__c npr = new Product_Range__c();
            npr.Id = pr.id;
            liProductRange.Add(npr);
        } 
        delete liProductRange;
    }
    
}