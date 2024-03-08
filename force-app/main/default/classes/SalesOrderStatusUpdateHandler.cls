/**
 * @Description : This class update Sales Order's Status as "Order Palced in ILG" or "Transaction with ILG failed" or "Partially Succeeded"
 * 					based on Sales Order Product's Status 
 					If all Line item of sales order has status as "Order Placed in ILG" then update Sales Order's Status as "Order Placed in ILG"
 					If one line item's Status is "Order Placed in ILG " and one line item's status is "Transaction with ILG Failed" then 
 					Sales Order's Status will be "Partially Succeeded"
 					If all line item's Status is "Order Placed in ILG" then Sales Order's Status needs to be udpated as "Order Placed in ILG".
 */
public class SalesOrderStatusUpdateHandler {
	public static String ALM_WHOLESALER = 'ALM';
    public static String ILG_WHOLESALER = 'ILG';
    
    public static String ILG_SUCCESS_STATUS = 'Order placed in ILG';
	public static String ILG_FAILED_STATUS  = 'Order failed in ILG';
	public static String ILG_WAITING_STATUS = 'Waiting for ACK';
	public static String PARTIAL_STATUS 	= 'Partially Succeeded';
	public static String ILG_NEW_STATUS 	= 'New Sales Order-ILG';
	public static String ALM_SUCCESS_STATUS = 'Order placed in ALM';
	public static String ALM_FAILED_STATUS 	= 'Order failed in ALM';
	
	public static void  updateSalesOrderStatus(Set<Id> salesOrderIds){
		List<Sales_Order__c> salesOrderList = new List<Sales_Order__c>();
		Boolean isSuccess = false;
		Boolean isFailed  = false;
		Boolean isPartial = false;
		
		Boolean isAlmSuccess = false;
		Boolean isAlmFailed  = false;
		Boolean isAlmPartial = false;
		
		salesOrderList = [select Id, Status__c,
						 	(Select Id, Status__c 
							 FROM Sales_Order_Products__r)
						  FROM Sales_Order__c 
						  WHERE Id IN : salesOrderIds];
		
		for(Sales_Order__c salesOrder : salesOrderList){
			isSuccess 	 = false;
			isFailed 	 = false;
			isAlmSuccess = false;
			isAlmFailed  = false;
			for(Sales_Order_Product__c salesOrderProduct : salesOrder.Sales_Order_Products__r){
				// update status for ILG line items	
				if(salesOrderProduct.Status__c == ILG_SUCCESS_STATUS){
					isSuccess = true;
				}				
				if(salesOrderProduct.Status__c == ILG_FAILED_STATUS){
					isFailed = true;
				}
				if(salesOrderProduct.Status__c == ILG_WAITING_STATUS){
					isPartial = true;
				}
				
				// check status for ALM line items
				if(salesOrderProduct.Status__c == ALM_SUCCESS_STATUS){
					isAlmSuccess = true;
				}
				if(salesOrderProduct.Status__c == ALM_FAILED_STATUS){
					isAlmFailed = true;
				}
			}
			// for ILG
			// if some line items are success and some failed then sales order status should be 'Partially succeeded'.
			if(isSuccess == true && isFailed == true){
				salesOrder.Status__c = PARTIAL_STATUS;	
			} else if(isSuccess == true && isFailed == false && isPartial == false){
				// if all the line items are succeeded then sales order stats should be 'Order placed in ILG'.
				salesOrder.Status__c = ILG_SUCCESS_STATUS;
			} else if(isSuccess == false && isFailed == true && isPartial == false){
				//if all the line items are failed then sales order status should be 'order failed in ILG'.
				salesOrder.Status__c = ILG_FAILED_STATUS;
			} else if(isSuccess == true && isPartial == true){
				// if any one order line item is succeeded and another one is waitning for ack then sales order status should be 'Partially succeeded'
				salesOrder.Status__c = PARTIAL_STATUS;
			} else if(isSuccess == false && isFailed == false && isPartial == true){
				// if all are waiting for ack line items then sales order status should be 'New Sales Order-ILG'
				salesOrder.Status__c = ILG_NEW_STATUS;
			}
			
			// for ALM Line items
			if(isAlmSuccess == true && isAlmFailed == false){
				salesOrder.Status__c = ALM_SUCCESS_STATUS;	
			} else if(isAlmSuccess == false && isAlmFailed == true){
				salesOrder.Status__c = ALM_FAILED_STATUS;
			} else if(isAlmSuccess == true && isAlmFailed == true){
				salesOrder.Status__c = PARTIAL_STATUS;
				salesOrder.Send_email_for_Partial_ALM__c = true;
			}
		}
		
		Database.SaveResult[] salesOrderSr = Database.update(salesOrderList,false);
	}
	
	// update cases and units on sales order producst
	// if quantity is 27 then 
	// cases ordered = 27/12 which is 2
	// units ordered = remaining quantity will be unites which is 3 	
	public static void updateCasesUnitsOrdered(List<Sales_Order_Product__c> salesOrderProductList){
		Integer casesOrdered = 0;
		Decimal unitsOrdered = 0;
		Decimal quantity ;
		Integer totalcasesQuantity = 0;
		
		System.debug('salesOrderProductList: ' + salesOrderProductList);
		
		for(Sales_Order_Product__c salesOrderProduct: salesOrderProductList){
			if(salesOrderProduct.Quantity__c == null){
				salesOrderProduct.Quantity__c = 0;
			}
			quantity = salesOrderProduct.Quantity__c;			
			casesOrdered = quantity.intValue();
			
			if(String.valueOf(quantity).indexOf('.') != -1){
				//unitsOrdered = quantity-totalcasesQuantity;
				Decimal pointsvalue = Decimal.valueOf(String.valueOf(quantity).substring(String.valueOf(quantity).indexOf('.')));
				
				if(salesOrderProduct.Bottles_Per_Carton__c != null){
					System.debug('points value: ' + pointsvalue);
					System.debug('salesOrderProduct.Bottles_Per_Carton__c: ' + salesOrderProduct.Bottles_Per_Carton__c);
					
					unitsOrdered = (pointsvalue * salesOrderProduct.Bottles_Per_Carton__c).ROUND();
					System.debug('unitsOrdered: ' + unitsOrdered);
					totalcasesQuantity = casesOrdered * salesOrderProduct.Bottles_Per_Carton__c.intvalue();
				}
			}
			System.debug('casesOrdered:' + casesOrdered + 'unitsOrdered:' + unitsOrdered);
			salesOrderProduct.Cases_Ordered__c  = casesOrdered;
			salesOrderProduct.Units_Ordered__c  = unitsOrdered;
			salesOrderProduct.Units_ALM__c 		= totalcasesQuantity + unitsOrdered;
			
			String datestring = String.valueOf(System.now());
    		datestring = datestring.replace('-','');
    		datestring = datestring.replace(' ','');
    		datestring = datestring.replace(':','');
    		
    		if(salesOrderProduct.Bonus_Status__c != null && salesOrderProduct.Bonus_Status__c.equals('Dependent Master')) {                
                /*
                 * The quantity for ILG is quantity + bonus quantity
                 */                
                quantity = salesOrderProduct.Total_Quantity_Including_Bonus__c;            
	            casesOrdered = quantity.intValue();
	            
	            if(String.valueOf(quantity).indexOf('.') != -1){	                
	                Decimal pointsvalue = Decimal.valueOf(String.valueOf(quantity).substring(String.valueOf(quantity).indexOf('.')));	                
	                if(salesOrderProduct.Bottles_Per_Carton__c != null){	                    
	                    unitsOrdered = (pointsvalue * salesOrderProduct.Bottles_Per_Carton__c).ROUND();	                    
	                }	                
	            }                
                salesOrderProduct.Cases_Ordered_ILG__c = casesOrdered;                
                salesOrderProduct.Units_Ordered_ILG__c = unitsOrdered;                
            } else {    			
    			/*
    			 * Product does not have a corresponding bonus product or it's a independent bonus product or its Dependent Child
    			 */    			
    			salesOrderProduct.Cases_Ordered_ILG__c = salesOrderProduct.Cases_Ordered__c;    			
                salesOrderProduct.Units_Ordered_ILG__c = salesOrderProduct.Units_Ordered__c;    			
    		}    		
		}		
	}
	
	// update product code on sales order products	
	public static void populateProductCode(List<Sales_Order_Product__c> salesOrderProductList){
		Set<String> wholesalerGroupProductId = new Set<String>();
		String tempProductIdwsgid = '';
		List<Wholesaler_Group_Product__c> wholesalerGroupProductList = new List<Wholesaler_Group_Product__c>();
		Map<String,List<Sales_Order_Product__c>> wholesalerGroupMap  = new Map<String,List<Sales_Order_Product__c>>();
		
		for(Sales_Order_Product__c salesOrderProduct: salesOrderProductList){				
			tempProductIdwsgid = salesOrderProduct.Product_Id__c + '-' + salesOrderProduct.Wholesaler_Group_Id__c;
			wholesalerGroupProductId.add(tempProductIdwsgid);
			
			System.debug('wholesalerGroupProductId:' + wholesalerGroupProductId);
				
			if(wholesalerGroupMap.containsKey(tempProductIdwsgid)){
				wholesalerGroupMap.get(tempProductIdwsgid).add(salesOrderProduct);
			} else {
				wholesalerGroupMap.put(tempProductIdwsgid,new List<Sales_Order_Product__c>{salesOrderProduct});
			}
		}
		
		//fetches product code from wholesaler Group product     		
		wholesalerGroupProductList = [SELECT id, Product_ID__c, ProductId_WholesalerGroupId__c, Wholesaler_Product_Code__c
									  FROM Wholesaler_Group_Product__c
									  WHERE ProductId_WholesalerGroupId__c IN : wholesalerGroupProductId
									  ORDER BY LastModifiedDate ASC];
		//put product code fetched from wholesaler Group product to Sales Order line items								
		for(Wholesaler_Group_Product__c wsgp : wholesalerGroupProductList){
			for(Sales_Order_Product__c salesOrderProd : wholesalerGroupMap.get(wsgp.ProductId_WholesalerGroupId__c)){
				salesOrderProd.Product_Code__c = wsgp.Wholesaler_Product_Code__c;
			}
		}
	}
	
	/**
	 * @author : Gunwant patidar
	 * @description : this method place orders to wholesaler directly if order is gets Approved.
	 * i.e: if status is 'Order Approved' then IF wholesaler is ALM then send that order to ALM server
	 		if wholesaler is ILG then status of that order and order line item will be updated as 'New sales order-ILG'.
	 		this method will be called from salesOrderTrigger
	 */
	@future(callout=true)
	public static void sendApprovedOrderToWholesaler(Set<Id> salesOrderIds){
	 	
 		StaticVariableHandler.setSalesOrderTriggerRun = 2;
 		List<Sales_Order__c> salesOrderList 				= new List<Sales_Order__c>();
	 	List<Sales_Order_Product__c> salesOrderProducts 	= new List<Sales_Order_Product__c>();
    	List<Sales_Order__c> salesOrderIlg_needsTobeUpdated = new List<Sales_Order__c>();
    	
    	System.debug('salesOrderIds: ' +salesOrderIds);
    	
    	salesOrderList = [SELECT id, name, Drop_1_Date__c, Drop_2_Date__c, WholeSaler_Type__c,Status__c, VendorOrderId__c, 
    							Wholesaler_Account_Number__c, Customer_State_Code__c, Supplier_Reference__c,
                        		(SELECT id,name, Sales_Order_Number__c, Product_Code__c, Quantity__c, ILG_Response__c, Status__c  
                             	 FROM Sales_Order_Products__r)
                          FROM Sales_Order__c
                          WHERE Id IN : salesOrderIds];
    	
	 	for(Sales_Order__c salesOrder : salesOrderList){
	 		// send to ALM server if Wholsaler type is ALM
            if(salesOrder.WholeSaler_Type__c == ALM_WHOLESALER){
            	System.debug('--------------------------------- salesOrder to be submitted to ALM : ' +salesOrder.Id);                
                AlmHttpRequest almRequest = new AlmSoapRequestHandler(salesOrder.id);
                almRequest.invokeHttpRequest();             
            }  
            else if(salesOrder.WholeSaler_Type__c == ILG_WHOLESALER){ 
                //change status to ILG_NEW_SALES_ORDER_STATUS's value if wholesaler type is ILG
                // sot that SFDC ILG application(DOT NET Program) running on campari server will pick up these orders and 
                // send them to ILG FTP server 
                salesOrder.Status__c = ILG_NEW_STATUS;
                for(Sales_Order_Product__c salesOrderProduct : salesOrder.Sales_Order_Products__r){
                    salesOrderProduct.Status__c = ILG_NEW_STATUS;
                    String datestring 		= String.valueOf(System.now());
                    String withouthHypen 	= datestring.replace('-','');
			        String withoutspace 	= withouthHypen.replace(' ','');
			        String withoutColon 	= withoutspace.replace(':','');
	                salesOrderProduct.Sales_Order_Number__c = 'S'+salesOrderProduct.Name.RIGHT(4)+withoutColon;                    
                    System.debug('salesOrder:' + salesOrder);                    
                    salesOrderProducts.add(salesOrderProduct);  
                }
                salesOrderIlg_needsTobeUpdated.add(salesOrder);
            }
	 	}
	 	// udpate only Sales orders and sales order products where Wholesaler is ILG
	 	Database.SaveResult[] salesOrderSr 			= Database.update(salesOrderIlg_needsTobeUpdated,false);
	 	Database.SaveResult[] salesOrderProductSr 	= Database.update(salesOrderProducts,false);	 	
	}
}