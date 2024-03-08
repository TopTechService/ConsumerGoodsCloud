/**
 * @author : Gunwant patidar
 * @created date : 06/05/2013
 * @description : This class creates order's xml and send it to AlmHttpRequest
 * @modified: Geeta Kushwaha, send email to user when sales order has not been placed in ALM on 24 Jan, 2014
 */
public class AlmSoapRequestHandler extends AlmHttpRequest{
	public Map<String,List<String>> xmlTagVsValues = new Map<String,List<String>>();
	public Map<String,String> prdIDvsMsg = new Map<String,String>();	
	
    public Map<String,String> orderUpdateMap = new Map<String,String>();
    public static Map<String,Sales_Order_Product__c> orderSoapFieldMap = new Map<String,Sales_Order_Product__c>();
    public List<String> orderFieldsLabelList;
    public List<Sales_Order__c> salesOrders = new List<Sales_Order__c>();
    public Sales_Order_Product__c salesOrderProduct = new Sales_Order_Product__c();
    public List<Sales_Order_Product__c> orderlineItemList = new List<Sales_Order_Product__c>();
    public String soapRequestXml = '';
    
    
    public String backOrder 		= '';
    public String productCodeType 	= '';
    public String supplierRepId 	= '';
    public String trnApproved 		= '';
    public Integer lineid 			= 0;
    private String userName;
  	private String passWord;
  	// added these field to resend request
  	private Id sOrderId;
  	private String region;
  	private Boolean isRetry;
    
    public AlmSoapRequestHandler(Id salesOrderId){
    	sOrderId = salesOrderId; 
    	isRetry = false;
    	region = null;
        fetchSalesOrder(salesOrderId);        
    }
    
    public void fetchSalesOrder(Id salesOrderId){
        // get custom setting values to variables
        if(ALM_Sales_Order_Data__c.getInstance('Order') != null) {            
            backOrder = ALM_Sales_Order_Data__c.getInstance('Order').Back_Order__c;            
            productCodeType = ALM_Sales_Order_Data__c.getInstance('Order').Product_Code_Type__c;            
            trnApproved = ALM_Sales_Order_Data__c.getInstance('Order').Trn_Approved__c;
        }
        
        // fetch sales order data
        salesOrders = [SELECT id, name,VendorOrderId__c,Region__c, Wholesaler_Account_Number__c, Customer_PO_Number__c, ALM_Order_Request_XML__c,
                      		Customer_State_Code__c, Supplier_Reference__c, ALM_Response_XML__c, Outlet_Name__c,
                        	(SELECT id,name, Order_Type__c, 
                        	 	Product_Code__c, Units_ALM__c, ILG_Response__c, Status__c, Total_Price__c, Total_Applied_Discount2__c  
                             FROM Sales_Order_Products__r
                             order by Name asc)
                       FROM Sales_Order__c 
                       WHERE Id =:salesOrderId];
                       
        //Sales order along with the line items               
        // if order is submitted from sales order then this part will create sales order and order line items
        if(salesOrders.size()>0){
        	if (null == region)
          		region = salesOrders[0].Region__c;
        	for(Sales_Order__c salesOrder : salesOrders){ 
            	// get username password from custom settings 
            	if(salesOrder.Region__c != null && salesOrder.Region__c != 'null' 
            				&& ALM_User_Name_and_Region__c.getInstance(region) != null){              		
            		userName = ALM_User_Name_and_Region__c.getInstance(region).Rep_Id__c;
             		passWord = ALM_User_Name_and_Region__c.getInstance(region).Password__c;
              		supplierRepId = ALM_User_Name_and_Region__c.getInstance(region).Rep_Id__c;
            	} else {
                  	userName = ALM_Configuration__c.getInstance('Configuration').Username__c;
                  	passWord = ALM_Configuration__c.getInstance('Configuration').Password__c;
                  	supplierRepId = ALM_Sales_Order_Data__c.getInstance('Order').Supplier_Rep_Id__c;
                }
                //call this method to add order in xml body
                createOrderXML(salesOrder);
                
                for(Sales_Order_Product__c salesOrdproduct : salesOrder.Sales_Order_Products__r){                	
                    orderlineItemList.add(salesOrdproduct);                    
                    //call this method to add this line item in xml body
                    createOrderLineXML(salesOrdproduct);                    
                }
            }
            //closes all the header elements
            appendHeaderEndElements();
        } else {
        	try {
                // If individual line item is submitted then this part will create order xml
                salesOrderProduct = [SELECT id, name, Order_Type__c,Region__c, Customer_State_Code__c, Supplier_Reference__c, ALM_Product_Error__c,
                                        Member_Number__c, Sales_Order_Number__c, Product_Code__c, Units_ALM__c, Customer_PO_Number__c,
                                        ILG_Response__c, Status__c, Total_Price__c, ALM_Order_Request_XML__c, ALM_Response_XML__c, Total_Applied_Discount2__c, Sales_Order__r.Outlet_Name__c
                                     FROM Sales_Order_Product__c
                                     WHERE Id =: salesOrderId
                                     order by Name asc];
                
                if(salesOrderProduct.Region__c != null && salesOrderProduct.Region__c != 'null' && ALM_User_Name_and_Region__c.getInstance(salesOrderProduct.Region__c) != null){
                	userName = ALM_User_Name_and_Region__c.getInstance(salesOrderProduct.Region__c).Rep_Id__c;
                  	passWord = ALM_User_Name_and_Region__c.getInstance(salesOrderProduct.Region__c).Password__c;
                  	supplierRepId = ALM_User_Name_and_Region__c.getInstance(salesOrderProduct.Region__c).Rep_Id__c;
                } else {
                  	userName = ALM_Configuration__c.getInstance('Configuration').Username__c;
                  	passWord = ALM_Configuration__c.getInstance('Configuration').Password__c;
                  	supplierRepId = ALM_Sales_Order_Data__c.getInstance('Order').Supplier_Rep_Id__c;
                }
                                        
                orderlineItemList.add(salesOrderProduct);                
                // calling this method to adding only line items in xml body
                createOrderLineItemsXml(salesOrderProduct);                
                // Close all the header elements 
                appendHeaderEndElements(); 
                               
            } catch (Exception ex){
 				// Changes : send mail if exception occured 			        
	          	List<String> toAddresses = new List<String>();
				toAddresses.add('campari@arxxus.com');
				List<String> ccAddresses = new List<String>();
				String body = 'Exception occurred while fetching Sales order : ' + ex.getTypeName() + ': ' + ex.getMessage() 
								+ ' -- ' + ex.getCause() + ' -- '+ ex.getStackTraceString(); 
				SendEmail em = new SendEmail();
				em.sendEmailToUsers(toAddresses, ccAddresses, 'Exception occurred while placing order in ALM', body, body);	            
            }
        }               
        
    }
    //adds order in xml body
    public void createOrderXML(Sales_Order__c salesOrder){
    	
        String vendorOrderId = salesOrder.customer_PO_Number__c;
        
        if (vendorOrderId != null && vendorOrderId.length() > 10) {
        	vendorOrderId = salesOrder.customer_PO_Number__c.substring(0,10);
        }
        soapRequestXml = '<soapenv:Body>'
                        + '<alm:submitSupplierOrder>'
                        + '<alm:submitSupplierOrder>'
                        + ' <![CDATA['
                        +'<Msg>'
                        + '<Order>'
                        + '<OrderHeader>'
                            + '<VendorOrderId>' + escapeXmlData(vendorOrderId) + '</VendorOrderId>'
                            + '<CustomerId>' + escapeXmlData(string.valueOf(salesOrder.Wholesaler_Account_Number__c)).RIGHT(6) + '</CustomerId>'
                            + '<CustomerStateCode>' + escapeXmlData(string.valueOf(salesOrder.Customer_State_Code__c)) + '</CustomerStateCode>'
                            + '<SupplierRepId>' + escapeXmlData(string.valueOf(supplierRepId)) + '</SupplierRepId>'
                            + '<SupplierReference>' + escapeXmlData(string.valueOf(salesOrder.Supplier_Reference__c)) + '</SupplierReference>'
                            + '<SupplierStateId>' + escapeXmlData(string.valueOf(salesOrder.Customer_State_Code__c)) + '</SupplierStateId>';
                            
          soapRequestXml += '<TrnApproved>' + escapeXmlData(string.valueOf(trnApproved)) + '</TrnApproved>';          
          soapRequestXml += '</OrderHeader>';                        
    }
    
    //adds order line items in xml body
    public void createOrderLineXML(Sales_Order_Product__c salesOrderProduct){
        lineid += 1;
        integer dealAmount ; // it should be in integer format beacuse decimal is not supported in ALM 
        
        // this Map contains lineid and line item objects so that when error occurs in line items then we use this Map to update line items as failed
        salesOrderProduct.Status__c 	  = 'Order placed in ALM';
        salesOrderProduct.ILG_Response__c = '';
        orderSoapFieldMap.put(string.valueOf(lineid),salesOrderProduct);
        
        if(salesOrderProduct.Order_Type__c == 'O'){
			// if discount is applied then deal amount should be in cents not in doller
			// if no discount is applied then deal amount as 0
			if(salesOrderProduct.Total_Applied_Discount2__c != null && salesOrderProduct.Total_Applied_Discount2__c != 0 && salesOrderProduct.Total_Applied_Discount2__c != 0.00){
	  			dealAmount = (100 * salesOrderProduct.Total_Applied_Discount2__c).intValue();
			} else {
				dealAmount = 0;
			}
        } else {
          	dealAmount = 0;
        }
        
        soapRequestXml += '<LineItem>'
                            + '<LineId>' + escapeXmlData(string.valueOf(lineid)) + '</LineId>'
                            + '<OrderType>' + escapeXmlData(string.valueOf(salesOrderProduct.Order_Type__c)) + '</OrderType>'
                            + '<BackOrder>' + escapeXmlData(string.valueOf(backOrder)) + '</BackOrder>'
                            + '<ProductCode>' + escapeXmlData(string.valueOf(salesOrderProduct.Product_Code__c)) + '</ProductCode>'
        			//		+ '<ProductCode>' + escapeXmlData('11111111') + '</ProductCode>'
                            + '<ProductCodeType>' + escapeXmlData(string.valueOf(productCodeType)) + '</ProductCodeType>'
                            + '<OrderQuantity>' + escapeXmlData(string.valueOf(salesOrderProduct.Units_ALM__c)) + '</OrderQuantity>'
                            + '<DealAmount>' + escapeXmlData(string.valueOf(dealAmount)) + '</DealAmount>'
                            + '<ApplyBonus>N</ApplyBonus>'
                            + '<ApplyQda>N</ApplyQda>'
                        + '</LineItem>';
    }
    // if order is sent from individual line items then this part will create xml body
    // e.g. If 1 out of 2 order line items failed then user will send only failed line item
    // in this case this will be considered as an order
    public void createOrderLineItemsXml(Sales_Order_Product__c salesOrderProduct){
        integer dealAmount ;
        if(salesOrderProduct.Order_Type__c == 'O'){
        	// if discount is applied then deal amount should be in cents not in doller
		  	// if no discount is applied then deal amount as 0
			if(salesOrderProduct.Total_Applied_Discount2__c != null && salesOrderProduct.Total_Applied_Discount2__c != 0 && salesOrderProduct.Total_Applied_Discount2__c != 0.00){
  				dealAmount = (100 * salesOrderProduct.Total_Applied_Discount2__c).intValue();
			} else {
				dealAmount = 0;
			}
        } else {
			dealAmount = 0;
        }
        
        String vendorOrderId = salesOrderProduct.customer_PO_Number__c;
        
        if (vendorOrderId != null && vendorOrderId.length() > 10) {
        	vendorOrderId = salesOrderProduct.customer_PO_Number__c.substring(0,10);
        }
        
        soapRequestXml =  '<soapenv:Body>'
                            + '<alm:submitSupplierOrder>'
                            + '<alm:submitSupplierOrder>'
                            + ' <![CDATA['
                                +'<Msg>'
                                    + '<Order>'
                                        + '<OrderHeader>'
                                            + '<VendorOrderId>' + escapeXmlData(vendorOrderId) + '</VendorOrderId>'
                                            + '<CustomerId>' + escapeXmlData(string.valueOf(salesOrderProduct.Member_Number__c)).RIGHT(6) + '</CustomerId>'
                                            + '<CustomerStateCode>' + escapeXmlData(string.valueOf(salesOrderProduct.Customer_State_Code__c)) + '</CustomerStateCode>'
                                            + '<SupplierRepId>' + escapeXmlData(string.valueOf(supplierRepId)) + '</SupplierRepId>'
                                            + '<SupplierReference>' + escapeXmlData(string.valueOf(salesOrderProduct.Supplier_Reference__c)) + '</SupplierReference>'
                                            + '<SupplierStateId>' + escapeXmlData(string.valueOf(salesOrderProduct.Customer_State_Code__c)) + '</SupplierStateId>';
     
        soapRequestXml += '<TrnApproved>' + escapeXmlData(string.valueOf(trnApproved)) + '</TrnApproved>';
     
     	soapRequestXml += '</OrderHeader>'
                                        + '<LineItem>'
                                            + '<LineId>' + escapeXmlData(string.valueOf(1)) + '</LineId>'
                                            + '<OrderType>' + escapeXmlData(string.valueOf(salesOrderProduct.Order_Type__c)) + '</OrderType>'
                                            + '<BackOrder>' + escapeXmlData(string.valueOf(backOrder)) + '</BackOrder>'
                                            + '<ProductCode>' + escapeXmlData(string.valueOf(salesOrderProduct.Product_Code__c)) + '</ProductCode>'
        							//		+ '<ProductCode>' + escapeXmlData('11111111') + '</ProductCode>'
                                            + '<ProductCodeType>' + escapeXmlData(string.valueOf(productCodeType)) + '</ProductCodeType>'
                                            + '<OrderQuantity>' + escapeXmlData(string.valueOf(salesOrderProduct.Units_ALM__c)) + '</OrderQuantity>'
                                            + '<DealAmount>' + integer.valueOf(escapeXmlData(string.valueOf(dealAmount))) + '</DealAmount>'
                                            + '<ApplyBonus>N</ApplyBonus>'
                                            + '<ApplyQda>N</ApplyQda>'
                                        + '</LineItem>';
        
    }
    
    public void appendHeaderEndElements(){        
        soapRequestXml += '</Order>'
                        + '</Msg>]]>'
                        + '</alm:submitSupplierOrder> '
                        + '</alm:submitSupplierOrder> '
                        + '</soapenv:Body>'
                        + '</soapenv:Envelope>';
    }
    
    public String escapeXmlData(String fieldValue){
        String excapedString;
        if(fieldValue != null){
            excapedString = fieldValue.replace('&', '&amp;');
            excapedString = excapedString.replace('<', '&lt;');
            excapedString = excapedString.replace('>', '&gt;');
            excapedString = excapedString.replace('"', '&quot;');
            excapedString = excapedString.replace('\'', '&apos;');
            excapedString = excapedString.replace('$', '');
            excapedString = excapedString.replace(',', '');
        }
        return excapedString;   
    }
    /**
     * @author : Gunwant Patidar
     * @created date : 06/05/2013
     * @description : this method fetches endpoint from custom setting(ALM_Configuration__c) send it to AlmHttpRequest class
     * @return String : endpoint 
     */ 
     public override String getEndPoint(){
        String endpoint ;
        if(ALM_Configuration__c.getInstance('Configuration').Endpoint__c != null){
            endpoint = ALM_Configuration__c.getInstance('Configuration').Endpoint__c;
        }
        return endpoint;
     }
     
     public override String getSoapAction(){     	
        String soapAction;         
        soapAction = '/ALMiPortal/InterfaceServices/ALMiPortal-service0.serviceagent/ALMiPortalPortEndpoint0/submitSupplierOrder';        
        return soapAction;
     }
   	/**
     * @author : Gunwant Patidar
     * @created date : 06/05/2013
     * @description : this method creates soap header and send it to AlmHttpRequest class
     * @return String : soapHeader 
     */ 
    public override String getSoapHeader(){
        String soapHeader;
        soapHeader = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:alm="http://services.metcash.com/xsd/ALMiPortal">'
                     + '<soapenv:Header>'
                     + '<alm:Authentication>'
                     + '<alm:B2BAccount>' + getuserName() + '</alm:B2BAccount>'
                     + '<alm:Password>' + getpassWord() + '</alm:Password>'
                     + '</alm:Authentication>'
                     + '</soapenv:Header>';                     
        return soapHeader;
    }     
     
    public override string getUserName(){       
    	return userName;
    }
	public override String getPassword() {       
    	return passWord;
  	}
  	    
    public override String makeSoapRequest(){
    	return getSoapHeader()+soapRequestXml;
    }
     
    /**
     * @author: Gunwant Patidar
     * description : this method updates sales order or sales order products as 'order placed in ALM' or 'Order failed in ALM'
     */
    public override void parseResponse(String response, String request){
    	System.debug('parseResponse response : ' +response+ '____ request :' + request);
        orderUpdateMap = AlmSoapResponseParser.parseResponse(response,orderSoapFieldMap);        
        //if order is submitted from sales order's submit to wholesaler button then this part will run
        if(salesOrders.size()>0){
        	salesOrders[0].ALM_Order_Request_XML__c = request;
        	salesOrders[0].ALM_Response_XML__c 		= response;        	
        	
        	// Map will contain the the product id and respective error msg
        	// assuming the product code is sent in response if there is error
        	prdIDvsMsg = XMLUtilities.readXmlString(response);
        	
            if (null != orderUpdateMap.get('HeaderMessageSeverity') && orderUpdateMap.get('HeaderMessageSeverity').contains('ERROR')) {
        		System.debug('Error received from ALM service');
        		// Order failed due to invalid product code can enter this block
        		
        	   /**
        		 * Arxxus Support : Changes to show Qnty out of stock msg in mail
        		 *  changes to enable mail sending in this type of failure.        		         		 
        		 */
        		if (null != orderUpdateMap.get('HeaderMessageData')) {
        			salesOrders[0].ALM_error__c = orderUpdateMap.get('HeaderMessageData');
        			if (salesOrders[0].ALM_error__c.length() >= 254) {
        				salesOrders[0].ALM_error__c = salesOrders[0].ALM_error__c.subString(0, 254);
        			}
        		}
        		
        		salesOrders[0].Send_Authentication_failed_email__c = true;
        		for(Sales_Order_Product__c sop : orderSoapFieldMap.values()) {
        			sop.status__c = 'Order failed in ALM';
        			if (null != prdIDvsMsg) {
        				System.debug('prdIDvsMsg set to :' +prdIDvsMsg+ 'and sop.Product_Code__c :' +sop.Product_Code__c);
        				if (prdIDvsMsg.containsKey(sop.Product_Code__c)) {
        					sop.ILG_Response__c = prdIDvsMsg.get(sop.Product_Code__c);
        					sop.ALM_Product_Error__c = prdIDvsMsg.get(sop.Product_Code__c);
        					System.debug('sop.ALM_Product_Error__c set to :' +sop.ALM_Product_Error__c);
        				}
        			}
        		}

        		
        	} else if (orderUpdateMap.get('WebOrderId') != '0'){
        		/**
        		 *  Arxxus support
        		 *  Changes to mark order failed in case of partial response
        		 */
        		for(Sales_Order_Product__c sop : orderSoapFieldMap.values()) {        			
        			if (null != prdIDvsMsg) {
        				System.debug('prdIDvsMsg set to :' +prdIDvsMsg+ 'and sop.Product_Code__c :' +sop.Product_Code__c);
        				if (prdIDvsMsg.containsKey(sop.Product_Code__c)) {
        					sop.ILG_Response__c = prdIDvsMsg.get(sop.Product_Code__c);
        					sop.status__c = 'Order failed in ALM';
        					sop.ALM_Product_Error__c = prdIDvsMsg.get(sop.Product_Code__c);
        					System.debug('sop.ALM_Product_Error__c set to :' +sop.ALM_Product_Error__c);
        				}
        			}
        		}        		
        		
            	String key = orderUpdateMap.get('WebOrderId');            	
            	integer countVal = key.countMatches(',')+1; 
            	
            	if(countVal > 0) {            		
            		salesOrders[0].Web_Order_Number__c = '';            		
            		for(String orderId : key.split(',',countVal)){            			
            			if(orderId != '0'){            				
            				salesOrders[0].Web_Order_Number__c +=   orderId+',';            				
            			}            			
            		}
            		
            		salesOrders[0].Web_Order_Number__c = salesOrders[0].Web_Order_Number__c.length() > 2 ? salesOrders[0].Web_Order_Number__c.substring(0,salesOrders[0].Web_Order_Number__c.length()-2) : '';            		
            	}                
            }
            if (isRetry)
            	salesOrders[0].Order_Failed_At_First_Try__c = true;            
            update orderSoapFieldMap.values();                                              
            update salesOrders;
            
        } else {
            // if order is submitted from line items then this part will run
            salesOrderProduct.ALM_Order_Request_XML__c = request;
        	salesOrderProduct.ALM_Response_XML__c 	   = response;
            
            if(orderUpdateMap.get('WebOrderId') == '0'){
                salesOrderProduct.Host_Order_Number__c = orderUpdateMap.get('WebOrderId');
                
                if(orderUpdateMap.get('HeaderMessageData') != null){
                    salesOrderProduct.ILG_Response__c = orderUpdateMap.get('HeaderMessageData');
                    if(orderUpdateMap.get('ProductDescription') != null){
                        salesOrderProduct.ILG_Response__c += orderUpdateMap.get('ProductDescription');
                    }
                    salesOrderProduct.Status__c = 'Order failed in ALM';
                } else {
                
                    salesOrderProduct.ILG_Response__c  = orderUpdateMap.get('ProductDescription');
                    salesOrderProduct.ILG_Response__c += orderUpdateMap.get('LineMessageData');
                    salesOrderProduct.Status__c = 'Order failed in ALM';
                }
            } else {
                salesOrderProduct.Host_Order_Number__c = orderUpdateMap.get('WebOrderId');
                salesOrderProduct.Status__c 		   = 'Order placed in ALM';
                salesOrderProduct.ILG_Response__c 	   = ''; 
            }             
            update salesOrderProduct;
        }            
     } 
     
     // update a checkbox on sales order or sales order product so that Autentication failed email could be sent out to ASM     
     public override void updatesalesordertoSendEmail(String almRequest, String almResponse){
    	System.debug('updatesalesordertoSendEmail almRequest : ' +almRequest+ '____ almResponse :' + almResponse);   	
     	
     	String faultString = null;
     	String faultCode = null;
		   	
		if(almResponse.contains('faultstring')){			
		    faultString = almResponse.substring(almResponse.indexOf('>',almResponse.indexOf('<faultstring')) + 1,almResponse.indexOf('</faultstring>'));			    
		    if(faultString.length() > 255){			    	
		    	faultString = faultString.substring(0,244);			    	
		    }			
		}
		
		if(almResponse.contains('faultcode')){			
		    faultCode = almResponse.substring(almResponse.indexOf('>',almResponse.indexOf('<faultcode')) + 1,almResponse.indexOf('</faultcode>'));			    
		}
		
        if(salesOrders.size()>0){
            salesOrders[0].Send_Authentication_failed_email__c  = true;
            salesOrders[0].Status__c 							= 'Order failed in ALM';
            salesOrders[0].ALM_Order_Request_XML__c 			= almRequest;
            salesOrders[0].ALM_Response_XML__c 					= almResponse;
            salesOrders[0].ALM_Error__c = faultString;
            salesOrders[0].ALM_Error_Code__c = faultCode;
            
            if (salesOrders[0].ALM_error__c != null && salesOrders[0].ALM_error__c.length() >= 254) {
				salesOrders[0].ALM_error__c = salesOrders[0].ALM_error__c.subString(0, 254);
			}
            
            if (isRetry)
            	salesOrders[0].Order_Failed_At_First_Try__c = true;                       
            update salesOrders;        
        } else {
            salesOrderProduct.Send_Authentication_failed_email__c 	= true;
            salesOrderProduct.Status__c 							= 'Order failed in ALM';
            salesOrderProduct.ALM_Order_Request_XML__c 				= almRequest;
            salesOrderProduct.ALM_Response_XML__c 					= almResponse; 
        	salesOrderProduct.ALM_Error__c = faultString;
        	salesOrderProduct.ALM_Error_Code__c = faultCode;
            update salesOrderProduct;        
        }             
     }
     
     /**
      * @author: Geeta Kushwaha
      * @created: 24 Jan, 2014
      * @Description: Status code was neither 200(OK) nor 500(InternalServerError)
      *               Send email to user that the sales order has not been placed in ALM. 
      *               Display to user - Salesforce attempted to place the sales order in ALM - by capturing the request xml
      */
     public override void updatesalesordertoSendEmailUnexpectedStatusCode(String almRequest, String almResponse, Integer  statusCode, String statusMessage){
     	System.debug('updatesalesordertoSendEmailUnexpectedStatusCode almRequest : ' +almRequest+ '____ almResponse :' + almResponse+ '____ statusCode :' + statusCode+ '____ statusMessage :' + statusMessage);  
        if(salesOrders.size()>0){
            salesOrders[0].Send_Authentication_failed_email__c  = true;
            salesOrders[0].Status__c 							= 'Order failed in ALM';
            salesOrders[0].ALM_Order_Request_XML__c 			= almRequest;
            salesOrders[0].ALM_Response_XML__c 					= almResponse;
            salesOrders[0].ALM_Error__c = statusMessage;
            salesOrders[0].ALM_Error_Code__c = 'HTTP Status Code: '+statusCode;
            
            if (isRetry)
            	salesOrders[0].Order_Failed_At_First_Try__c = true;                       
            update salesOrders;        
        } else {
            salesOrderProduct.Send_Authentication_failed_email__c 	= true;
            salesOrderProduct.Status__c 							= 'Order failed in ALM';
            salesOrderProduct.ALM_Order_Request_XML__c 				= almRequest;
            salesOrderProduct.ALM_Response_XML__c 					= almResponse; 
        	salesOrderProduct.ALM_Error__c = statusMessage;
        	salesOrderProduct.ALM_Error_Code__c = 'Http Status Code: '+statusCode;
            update salesOrderProduct;        
        }             
     }
   
   	public override void resendRequest() {   		
   		   		
   		ALM_User_Name_and_Region__c tempUserSetting = new ALM_User_Name_and_Region__c();
		List<ALM_User_Name_and_Region__c> userNameAndRegions = ALM_User_Name_and_Region__c.getall().values();

   		for (ALM_User_Name_and_Region__c userName : userNameAndRegions) {
   			if (!salesOrders.isEmpty()) {
	   			if (userName.ALM_State_Code__c ==  salesOrders[0].Customer_State_Code__c) {
	   				tempUserSetting = userName;
	   			}   			
   			} 
   		}   		
   		region = tempUserSetting.name;  
   		System.debug('region is :' +region);
   		
   		lineid = 0;
   		salesOrders = new List<Sales_Order__c>();
   		orderSoapFieldMap = new Map<String,Sales_Order_Product__c>();
   		salesOrderProduct = new Sales_Order_Product__c();
   		orderlineItemList = new List<Sales_Order_Product__c>();
   		fetchSalesOrder(sOrderId);
		isRetry = true;   		
   	}   	
     
}