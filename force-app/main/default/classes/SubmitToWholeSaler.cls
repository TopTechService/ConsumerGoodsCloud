/**
 * @Author : Gunwant Patidar
 * @created date : 29/4/2013
 * @description : This class change the status of Sales order and sales order Products based on Whole Salers.
 *                  If Whole saler is ILG then change Sales Order's Status to 'New Sales Order-ILG' and same Status in Sales Order Products as well.
                    I Whole saler is ALM them change status of Sales Order only to Order Placed to ALM.
 */
global class SubmitToWholeSaler {
    
    /**
     * @author : Gunwant Patidar
     * @created date : 29/4/2013
     * @description : Change status of Sales Order and Sales Order Products 
     *                  If Whole saler is ALM then make a webervice all and send the order details to ALM
                        If Wholesaler is ILG then Change Status__c on Sales Order and Sales Order Products only
     */
    webservice static String changeOrdersStatus(Id salesOrderId){
        list<Sales_Order__c> salesOrderList = new list<Sales_Order__c>();
        list<Sales_Order__c> salesOrderToBeUpdated = new list<Sales_Order__c>();
        list<Sales_Order_Product__c> salesOrderProductsToBeUpdated = new list<Sales_Order_Product__c>();    
        String ILG_NEW_SALES_ORDER_STATUS = 'New Sales Order-ILG';
        String ILG_SUCCESS_SALES_ORDER_STATUS = 'Order placed in ILG';
        String NEW_SALES_ORDER_STATUS = 'New Sales Order Created';
        String ILG_PARTIAL_STATUS = 'Partially Succeeded';
        String ILG_FAILED_STATUS = 'Order failed in ILG';
        String ALM_FAILED_STATUS = 'Order failed in ALM';
        
        String silg_newSalesOrderStatus = 'New Sales Order-SILG';
        System.debug('Logged In user: ' + userinfo.getUserName());
        salesOrderList = [Select Id, Status__c, Name, WholeSaler_Type__c,
                            (Select Id, Name, Status__c 
                                FROM Sales_Order_Products__r) 
                            FROM Sales_Order__c
                            WHERE Id =: salesOrderId]; 
                            
        for(Sales_Order__c salesOrder : salesOrderList){
            if(salesOrder.WholeSaler_Type__c == 'ILG'){
                if(salesOrder.Status__c == NEW_SALES_ORDER_STATUS || salesOrder.Status__c == ILG_FAILED_STATUS){
                    salesOrder.Status__c = ILG_NEW_SALES_ORDER_STATUS;
                    salesOrderToBeUpdated.add(salesOrder);
                } else {
                	if(salesOrder.Status__c == ILG_SUCCESS_SALES_ORDER_STATUS){
                		return 'Order placed';
                	}
                	
                	if(salesOrder.Status__c == ILG_PARTIAL_STATUS){
                		return 'Partially succeeded';
                	}
                }
            
                for(Sales_Order_Product__c salesOrderProduct : salesOrder.Sales_Order_Products__r){
                	if(salesOrder.Status__c == ILG_NEW_SALES_ORDER_STATUS){
	                    if(salesOrderProduct.Status__c != ILG_NEW_SALES_ORDER_STATUS && salesOrderProduct.Status__c != ILG_SUCCESS_SALES_ORDER_STATUS){
	                        salesOrderProduct.Status__c = ILG_NEW_SALES_ORDER_STATUS;
	                        // populate sales order number 
	                        String datestring = String.valueOf(system.now());
	        		
			        		String withouthHypen = datestring.replace('-','');
			        		String withoutspace = withouthHypen.replace(' ','');
			        		String withoutColon = withoutspace.replace(':','');
	                        salesOrderProduct.Sales_Order_Number__c = 'S'+salesOrderProduct.Name.RIGHT(4)+withoutColon;
	                        salesOrderProductsToBeUpdated.add(salesOrderProduct);
	                    }
                	}
                }
            }
            // TODO: add same logic for SILG orders but with different Status
            
            //TODO : add logic for ALM ,make webservice call
            
            if(salesOrder.WholeSaler_Type__c == 'ALM' && (salesOrder.Status__c == NEW_SALES_ORDER_STATUS || salesOrder.Status__c == ALM_FAILED_STATUS)){
            	AlmHttpRequest almRequest = new AlmSoapRequestHandler(salesOrder.id);
            	almRequest.invokeHttpRequest();
            }
        }
        System.debug('Sales Order to be updated: ' + salesOrderList);
        
        if(salesOrderToBeUpdated.size() > 0){
            Database.SaveResult[] salesOrderSr = Database.update(salesOrderToBeUpdated,false);
        }
        if(salesOrderProductsToBeUpdated.size() > 0){
            Database.SaveResult[] salesOrderProductSr = Database.update(salesOrderProductsToBeUpdated,false);
        }                   
        return 'New Sales Order-ILG';
    }
    /**
     * @Author : Gunwant Patidar
     * @createddate : 06/05/2013
     * @description : THis method update failed line item's status to 'New Sales Order-ILG'.
     					So that this line items again pushed to ILG server
     	@return String: Status changed message				
     */
    webservice static string changeLineItemStatustoNewSalesOrder(Id salesOrderProductId){
    	String ILG_NEW_SALES_ORDER_STATUS = 'New Sales Order-ILG';
    	String ILG_SUCCESS_SALES_ORDER_STATUS = 'Order placed in ILG';
    	String ALM_FAILED_STATUS = 'Order failed in ALM';
    	
    	list<Sales_Order_Product__c> salesOrderproductList = new list<Sales_Order_Product__c>();
    	list<Sales_Order_Product__c> salesOrderproductTobeUpdated = new list<Sales_Order_Product__c>();
    	
    		
    	salesOrderproductList = [Select Id, Name,Status__c, Wholesaler_Type__c 
                                	FROM Sales_Order_Product__c
                                	WHERE Id =: salesOrderProductId];
                              	
	        for(Sales_Order_Product__c salesOrderProduct : salesOrderproductList){
	        	if(salesOrderProduct.Wholesaler_Type__c == 'ILG'){
	        		system.debug('salesOrderProduct.Status__c: '   +salesOrderProduct.Status__c );
		        	if(salesOrderProduct.Status__c != ILG_NEW_SALES_ORDER_STATUS && salesOrderProduct.Status__c != ILG_SUCCESS_SALES_ORDER_STATUS){
		        		salesOrderProduct.Status__c = ILG_NEW_SALES_ORDER_STATUS;
		        		String datestring = String.valueOf(system.now());
		        		
		        		String withouthHypen = datestring.replace('-','');
		        		String withoutspace = withouthHypen.replace(' ','');
		        		String withoutColon = withoutspace.replace(':','');
		        		system.debug('Sales Order number: ' + salesOrderProduct.Name+withoutColon);
		        		salesOrderProduct.Sales_Order_Number__c = 'S'+salesOrderProduct.Name.RIGHT(4)+withoutColon;
		        		salesOrderproductTobeUpdated.add(salesOrderProduct);
		        	}
	        	} else if(salesOrderProduct.Wholesaler_Type__c == 'ALM' && salesOrderProduct.Status__c == ALM_FAILED_STATUS){
	        		AlmHttpRequest almRequest = new AlmSoapRequestHandler(salesOrderProduct.id);
            		almRequest.invokeHttpRequest();
	        	}
	        }                        	
	        
	    	Database.SaveResult[] salesOrderSr = Database.update(salesOrderproductTobeUpdated,false);
       
    	return 'Status Changed';
    }
    
}