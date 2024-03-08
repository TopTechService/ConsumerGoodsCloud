public class productRangeUtility {
    
    @InvocableMethod(label='Update Core Product Range Product Range' 
                     description='Update the product range records for the Sales My Sales records sent to the method.')
    public static void upadteLastPurchaseDate(List<Sale_MySales__c> updatedSales)
    {
        List<Product_Range__c> updateProductRange = new List<Product_Range__c>();
        Set<Product_Range__c> updateProductRangeSet = new Set<Product_Range__c>();
        Set<Id> products = new Set<Id>();
        Set<Id> accounts = new Set<Id>();
        
        for(Sale_MySales__c mySales : updatedSales)
        {
            products.add(mySales.Product__c);
            accounts.add(mySales.Outlet__c);
        }
        
        for(Product_Range__c pr: [Select Id, Last_Purchase_Date__c, Account__c, Product__c, Name
                                  FROM Product_Range__c 
                                  WHERE Account__c =: accounts and Product__c =:products])
        {
            for(Sale_MySales__c mySales : updatedSales)
            {
                IF(mySales.Outlet__c == pr.Account__c 
                   && mySales.Product__c == pr.Product__c
                   && (MySales.Sale_Date__c > pr.Last_Purchase_Date__c || pr.Last_Purchase_Date__c == null))
                {
                    IF( updateProductRangeSet.Contains(pr))
                    {
                        for(Product_Range__c prs: updateProductRangeSet)
                        {
                            if(prs.id == pr.id && prs.Last_Purchase_Date__c < pr.Last_Purchase_Date__c)
                            {
                                updateProductRangeSet.remove(prs);
                                pr.Last_Purchase_Date__c = mySales.Sale_Date__c;
                                updateProductRangeSet.add(pr);
                            }
                        }
                    }
                    else
                    {
                        pr.Last_Purchase_Date__c = mySales.Sale_Date__c;
                        updateProductRangeSet.add(pr); 
                    }
                }
            }
        }
        //updateProductRangeSet.addAll(updateProductRange);
        //updateProductRange.clear();
        updateProductRange.addAll(updateProductRangeSet);
        
        update updateProductRange;
    }
}