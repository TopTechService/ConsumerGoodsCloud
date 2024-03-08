public class SalesMySales_Delete {
    
    @InvocableMethod
    public static void SalesMySales_Delete(List<Sale_MySales__c> saleMySales)
    {
        delete saleMySales;
    }
    
}