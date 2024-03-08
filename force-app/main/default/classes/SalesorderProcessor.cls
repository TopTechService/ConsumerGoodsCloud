/**
 * @author: Gunwant patidar
 * @description : This class fetches sales order having Drop_1_Date__c or Drop_2_Date__c or Drop_3_Date__c within order pickup days.
                    If wholesaler type is ILG then just change the status of sales order and sales order products to 'New Sales order - ILG'.
                    If wholesaler type is ALM then send it to ALM server directly
 * @created date: 23/5/2013
 */
public class SalesorderProcessor {
    public static List<Sales_Order__c> salesOrderList = new List<Sales_Order__c>();
    public static List<Sales_Order__c> salesOrderIlg_needsTobeUpdated = new List<Sales_Order__c>();
    public static List<Sales_Order_Product__c> salesOrderProducts = new List<Sales_Order_Product__c>();
    
    private static final String ALM_WHOLESALER = 'ALM';
    private static final String ILG_WHOLESALER = 'ILG';     
    private static final String NEW_SALES_ORDER_STATUS = 'New Sales Order Created';
    private static final String ILG_NEW_SALES_ORDER_STATUS = 'New Sales Order-ILG';
    private static final String ORDER_APPROVED = 'Order Approved';
    private static final Integer ORDER_PICK_DAYS;
    private static final Set<String> ordersToProcess = new Set<String> {NEW_SALES_ORDER_STATUS, ORDER_APPROVED};
    
    static {
    	if(ALM_Sales_Order_Data__c.getInstance('Order') != null) {	      
	    	ORDER_PICK_DAYS = Integer.valueOf(ALM_Sales_Order_Data__c.getInstance('Order').Trade_Loader_Order_Pick_Up_Days__c);	      
	    }
    }
        
    @future(callout=true)
    public static void sendOrderToWholesaler(){
    	
    	Date orderDropDate = System.today() + ORDER_PICK_DAYS ;
        
      	// check whether wholesaler is ILG or ALM. based on the wholesaler do different operations.
      	for(Sales_Order__c salesOrder : [SELECT id, name, Drop_1_Date__c, Drop_2_Date__c, WholeSaler_Type__c,Status__c, VendorOrderId__c,
      										Wholesaler_Account_Number__c, Customer_State_Code__c, Supplier_Reference__c,
                            				(SELECT id,name, Product_Code__c, Quantity__c, ILG_Response__c, Status__c, Discount__c, Maximum_Discount__c  
                                				FROM Sales_Order_Products__r)
                            			FROM Sales_Order__c 
                            			WHERE Status__c IN : ordersToProcess
                            			AND (Drop_1_Date__c =: orderDropDate OR  Drop_2_Date__c =: orderDropDate OR  Drop_3_Date__c =: orderDropDate)
       									LIMIT 10]){
        	
        	// send to ALM server if Wholsaler type is ALM
            if(salesOrder.WholeSaler_Type__c == ALM_WHOLESALER){        		
            	// If order is not went for approval then send it to wholesaler
            	AlmHttpRequest almRequest = new AlmSoapRequestHandler(salesOrder.id);
            	almRequest.invokeHttpRequest();
            	
            } else if(salesOrder.WholeSaler_Type__c == ILG_WHOLESALER){ 
                
                salesOrder.Status__c = ILG_NEW_SALES_ORDER_STATUS;
                for(Sales_Order_Product__c salesOrderProduct : salesOrder.Sales_Order_Products__r){
                	salesOrderProduct.Status__c = ILG_NEW_SALES_ORDER_STATUS;
                    String datestring = String.valueOf(System.now());
                    String withouthHypen = datestring.replace('-','');
              		String withoutspace = withouthHypen.replace(' ','');
              		String withoutColon = withoutspace.replace(':','');              		
                    salesOrderProduct.Sales_Order_Number__c = 'S' + salesOrderProduct.Name.RIGHT(4) + withoutColon;                    
                    salesOrderProducts.add(salesOrderProduct);  
                }
               
                //put sales order in a List of sales order
                salesOrderIlg_needsTobeUpdated.add(salesOrder);               
            }
		}

    	//update sales order products for ILG, SILG  
	    DataBase.update(salesOrderProducts,false);
    	DataBase.update(salesOrderIlg_needsTobeUpdated,false);               
    }        
}