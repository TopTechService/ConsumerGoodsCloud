/*
 * @Created By-: Sourav Nema

 * @Created Date-: 4/26/2013 
 * @Purpose -:Populate Wholesaler_Price__c using price records
 * @modified : Gunwant Patidar(gunwant.patidar@arxxus.com) 8/7/2013
 *             by Geeta Kushwaha, geeta.kushwaha@arxxus.com on 21 Feb, 2014 [When a sales order products 'Bonus Status' is 'Dependent Master' then its staus should be copied to corresponding 'Dependent Child' record]
 */
trigger salesOrderProductTrigger on Sales_Order_Product__c (after update,before insert,before update,after insert) {
    
    List<Id> productList   = new List<Id>();
    Set<Id> salesOrderIds = new Set<Id>();
    List<Sales_Order_Product__c> salesOrderProducts = new List<Sales_Order_Product__c>();
    List<Sales_Order_Product__c> salesOrderProductforProductId = new List<Sales_Order_Product__c>();
    Map<Id, Pricing__c> promotionPricingMap = new Map<Id, Pricing__c>();
  
    Set<string> prdctList           = new Set<string>();
    Set<string> wholeSalerList      = new Set<string>();
    Map<string,string>groupProuctMap = new Map<string,string>();
  
    for(Sales_Order_Product__c salesPrdct : trigger.new){
    
        productList.add(salesPrdct.PromotionProduct__c);
    
        prdctList.add(salesPrdct.Product_Code__c);
        wholeSalerList.add(salesPrdct.WholeSaler_Group__c);
    
        if(trigger.isUpdate && trigger.isAfter){
            // by Gunwant Add line sales Order ids and sendt to a class so that status of sales Order can be udpated as Success, fail or Partailly success
            if(salesPrdct.Status__c == 'Order Placed in ILG' && salesPrdct.Status__c != trigger.oldMap.get(salesPrdct.id).Status__c){
                salesOrderIds.add(salesPrdct.Sales_Order__c);
            } 
            
            else if(salesPrdct.Status__c == 'Order failed in ILG' && salesPrdct.Status__c != trigger.oldMap.get(salesPrdct.id).Status__c){
                salesOrderIds.add(salesPrdct.Sales_Order__c);
            }
            else if(salesPrdct.Status__c == 'Waiting for ACK' && salesPrdct.Status__c != trigger.oldMap.get(salesPrdct.id).Status__c){
                salesOrderIds.add(salesPrdct.Sales_Order__c);
            }
        
            else if(salesPrdct.Status__c == 'Order placed in ALM' && salesPrdct.Status__c != trigger.oldMap.get(salesPrdct.id).Status__c){
                salesOrderIds.add(salesPrdct.Sales_Order__c);
            }
        
            else if(salesPrdct.Status__c == 'Order failed in ALM' && salesPrdct.Status__c != trigger.oldMap.get(salesPrdct.id).Status__c){
                salesOrderIds.add(salesPrdct.Sales_Order__c);
            }
        }
        // only if line items get inserted and trigger is before insert
        if(trigger.isBefore && trigger.isInsert){
            salesOrderProducts.add(salesPrdct);
        }
    
        if(trigger.isBefore && trigger.isInsert || (trigger.isBefore && trigger.isUpdate)){
            salesOrderProductforProductId.add(salesPrdct);
        }
    }
    // update Status on Sales Order
    if(trigger.isUpdate && trigger.isAfter){
        SalesOrderStatusUpdateHandler.updateSalesOrderStatus(salesOrderIds);
    }
    // update cases and  units ordered
    SalesOrderStatusUpdateHandler.updateCasesUnitsOrdered(salesOrderProducts);
    
    /*
     * @author Geeta Kushwaha
     * @purpose When a sales order products 'Bonus Status' is 'Dependent Master' then its staus should be copied to corresponding 'Dependent Child' record
     */
    if(trigger.isBefore && trigger.isUpdate) {
    	
    	Map<Id, Map<String, String>> dependentMasterMap = new Map<Id, Map<String,String>>(); // <sales Order Id, <Product Code, status of line item>> 
    	
    	Set <string> productCodeSet = new Set<String> ();
    	
    	for(Sales_Order_Product__c sop : trigger.new) {
    		
    		if(sop.Bonus_Status__c != null && sop.Bonus_Status__c.equals('Dependent Master') 
    				&& sop.Status__c != null && !(sop.Status__c.equals('Waiting for ACK') ||sop.Status__c.equals('New Sales Order Created') || sop.Status__c.equals('New Sales Order-ILG'))) {
    			
    			if(dependentMasterMap.containsKey(sop.Sales_Order__c)) {    				
    				dependentMasterMap.get(sop.Sales_Order__c).put(sop.Product_Code__c, sop.Status__c);    				
    			} else {    				
    				dependentMasterMap.put(sop.Sales_Order__c , new Map<String,String> {sop.Product_Code__c => sop.Status__c});    				
    			}    			
    			productCodeSet.add(sop.Product_Code__c);    			
    		}    		
    	}
    	System.debug('Master Records: ' + dependentMasterMap);
    	if (dependentMasterMap.size() > 0) {
    		/*
    		 * Fetch dependent child to update status same as its corresponding master record
    		 */	
	    	List<Sales_Order_Product__c> sopList = new List<Sales_Order_Product__c>(); 	

	    	for(Sales_Order_Product__c sop : [SELECT Id, Sales_Order__c, Product_Code__c  FROM Sales_Order_Product__c
	    										WHERE Bonus_Status__c = 'Dependent Child'
	    										AND Sales_Order__c IN : dependentMasterMap.keySet()
	    										AND Sales_Order__r.Wholesaler__r.Name LIKE '%ILG%']) { 
				System.debug('Dependent Child: ' + sop);   		
	    		if(dependentMasterMap.containsKey(sop.Sales_Order__c) && dependentMasterMap.get(sop.Sales_Order__c).containsKey(sop.Product_Code__c)) {    			
	    			sop.Status__c = dependentMasterMap.get(sop.Sales_Order__c).get(sop.Product_Code__c); 
	    			sopList.add(sop);   			
	    		}		
	    	}
	    	if(sopList.size() > 0)
	    		update sopList;	    	
    	}    	
    }
    
    // update Product code from WholesalerGroupProduct object
    if((trigger.isBefore && trigger.isInsert) || (trigger.isBefore && trigger.isUpdate)){
        SalesOrderStatusUpdateHandler.populateProductCode(salesOrderProductforProductId);
    }
  
    DataLoaderHelper helper  =  new DataLoaderHelper();
  
    promotionPricingMap.putAll(helper.getPromotionProductPricingMap(productList));
  
    groupProuctMap.putAll(helper.getWholeSalerGroupProductMap(prdctList, wholeSalerList));
  
    if(trigger.isBefore){
        for(Sales_Order_Product__c salesPrdct : trigger.new){
            if(promotionPricingMap.containsKey(salesPrdct.PromotionProduct__c)){
                salesPrdct.Wholesaler_Price__c  = promotionPricingMap.get(salesPrdct.PromotionProduct__c).Wholesaler_Price__c;
            }
            salesPrdct.Whole_Saler_Group_Product__c = groupProuctMap.get(salesPrdct.Product_Code__c+':'+salesPrdct.WholeSaler_Group__c);
        }        
    } else if(trigger.isUpdate){            
        Set <Id> salesOrderIdSet = new Set<Id>();
        
        for(Sales_Order_Product__c prod : trigger.new) {            
            if(prod.Bonus_Product__c != trigger.oldMap.get(prod.Id).Bonus_Product__c ||
               		prod.Quantity__c != trigger.oldMap.get(prod.Id).Quantity__c ||
               		prod.Quantity_2__c != trigger.oldMap.get(prod.Id).Quantity_2__c ||
               		prod.Quantity_3__c != trigger.oldMap.get(prod.Id).Quantity_3__c) {                
               salesOrderIdSet.add(prod.Sales_Order__c);                    
            }            
        }
        
        for(ProcessInstance approvalProcessRec : [Select Id, TargetObjectId
                                                  From ProcessInstance
                                                  where TargetObjectId IN : salesOrderIdSet
                                                  and Status = 'Pending'
                                                  and isDeleted = false]) {                                                
            salesOrderIdSet.remove(approvalProcessRec.TargetObjectId);                 
        }
        
        if(!salesOrderIdSet.isEmpty()) {            
            List <Sales_Order__c> soList = [select Id
                                            from Sales_Order__c
                                            where Id IN : salesOrderIdSet];
                                            
            for(Sales_Order__c so : soList) {                
                so.Send_Approval_for_quantity__c = true;                
            }  
            
            update soList; 
            
            for(Id soId : salesOrderIdSet) {
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setComments('Auto Submit due to change in quantity after approval.');
                req1.setObjectId(soId);
                Approval.ProcessResult result = Approval.process(req1);            
            }            
        }
    } 
}