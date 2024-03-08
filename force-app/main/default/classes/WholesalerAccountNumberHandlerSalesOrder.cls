/**
 * @author : Gunwant Patidar
 * @createddate : 07/05/2013
 * @description : This class populates Authorising_Rep__c, Supplier_Reference__c on sales order
 * @modified	: 25/02/2015
 *				  Truncate Supplier_Reference__c field to 20 chars, ALM accepts at most 20 chars for this field. 
 */
public class WholesalerAccountNumberHandlerSalesOrder {
    Public list<Sales_Order__c> salesOrderList = new list<Sales_Order__c>();
    Public list<Wholesaler_Branch__c> wholesalerBranchList = new list<Wholesaler_Branch__c>();
    Public list<Wholesaler_Branch_Outlet__c> wholesalerBranchoutletList = new list<Wholesaler_Branch_Outlet__c>();
    
    Public String outletId ;
    Public String WholesalerId ;
    Public set<String> wholesalerBranchIds = new set<String>();
    public String ownername = '';
    public String lastname = '';
    
    /**
     * @author : Gunwant
     * @createddate : 07/05/2013
     * @description : this method fetches customer number from Wholesaler Branch Outlet Object
     *              and update sales order's Wholesaler Account Number field
     */
    public void updateWholesalerNumber(set<Id> salesOrderIds){
        if(StaticVariableHandler.wholesalerAccountNumber == 1 ){
            // fetch sales order records 
            salesOrderList = [select id, name, Wholesaler_Account_Number__c, Supplier_Reference__c, Authorising_Rep__c,
                                Outlet_Name__r.Outlet_ID__c, Wholesaler__r.Wholesaler_ID__c,
                                Outlet_Name__r.Owner.LastName, Outlet_Name__r.Owner.FirstName
                                FROM Sales_Order__c
                                WHERE Id IN : salesOrderIds];
                                
            system.debug('salesOrderDetails:' + salesOrderList);                    
            if(salesOrderList.size() > 0){
                for(Sales_Order__c salesOrder : salesOrderList){
                    ownername = salesOrder.Outlet_Name__r.Owner.FirstName+salesOrder.Outlet_Name__r.Owner.LastName;
                    lastname = salesOrder.Outlet_Name__r.Owner.LastName;
                    
                    outletId = salesOrder.Outlet_Name__r.Outlet_ID__c;
                    WholesalerId = salesOrder.Wholesaler__r.Wholesaler_ID__c;
                    
                    salesOrder.Authorising_Rep__c = lastname.Left(6);
                    if (ownername.length() > 19)
                    	salesOrder.Supplier_Reference__c = ownername.substring(0, 19);
                    else
                    	salesOrder.Supplier_Reference__c = ownername;
					                    	                    
                    // updating vendorId
                    datetime todaysDate = system.now();
                    
                    salesOrder.VendorOrderId__c = salesOrder.Name + (''+todaysDate.year()).substring(0,2)+todaysDate.month()+todaysDate.day()
                                                  +todaysDate.hour()+todaysDate.minute()+todaysDate.second();
                }   
            }               
            StaticVariableHandler.wholesalerAccountNumber = 2;  
            Database.SaveResult[] salesOrderSr = Database.update(salesOrderList,false);
        }
    }
    
}