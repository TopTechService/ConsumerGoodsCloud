/**
 * @Author: Gunwant Patidar
 * @createddate : 07/05/2013
 * @description : This trigger updates sales order data when sales order is created or updated
                  Send approoved, inserted order to wholesaler.
                  Self approval for any order after 5 hours when it is created. [Geeta]
 * @modified: Geeta Kushwaha on 23 Oct, 2013
 * modified by daniel.peaper@viseo.com as part of the Consumer goods Cloud project.
 */
trigger salesOrderTrigger on Sales_Order__c (after insert, after update) {
    
    if(StaticVariableHandler.setSalesOrderTriggerRun == 1){
        Set<Id> almSalesOrderIds = new Set<Id>();
        Set<Id> ilgSalesOrderIds = new Set<Id>();
        Date todaysDate = Date.today();     
        Set<Id> salesOrderIds  = New Set<Id>();
        String APPROVED_STATUS = 'Order Approved';
        Set<Id> salesOrderApprovedTobeSentToWholesalerIds         = New Set<Id>();
        Map<Id,String> salesOrderRecordTypeMap = new Map<Id,String>();
        WholesalerAccountNumberHandlerSalesOrder wholesalerNumber = new WholesalerAccountNumberHandlerSalesOrder();
        
        // When sales order got created , populate some fields , sales_Order_Number__c, Authorising_Rep__c,
        // Send inserted orders to wholesaler
        if(trigger.isAfter && trigger.isInsert){
            for(Sales_Order__c salesorder : Trigger.new){
                salesOrderIds.add(salesorder.id);
            }
        }
        
        if(trigger.isAfter && trigger.isUpdate){            
            Set <Id> salesOrderForAutoApprovalSet = new Set<Id>();             
                                                                  
            for(RecordType rt : [SELECT Id, Name
                                 FROM RecordType
                                 WHERE SobjectType  = 'Sales_Order__c']){
                salesOrderRecordTypeMap.put(rt.id,rt.Name);
            }                                             
            system.debug('===salesOrderRecordTypeMap===' + salesOrderRecordTypeMap);
            
            List<Sales_Order__c> salesOrderIdToEscalateApproval = new List<Sales_Order__c>();
                        
            //list<Sales_Order_Escalation__c> salesOrderEscalation = new list<Sales_Order_Escalation__c>();
            
            for(Sales_Order__c salesOrder : trigger.new){
                System.debug('Sales order record type: ' + salesOrder.RecordType.Name);
                system.debug('===salesOrder====' + salesOrder);
                if(salesOrder.Wholesaler__c != trigger.oldMap.get(salesOrder.id).Wholesaler__c 
                            || salesOrder.Retail_Store__c != trigger.oldMap.get(salesOrder.id).Retail_Store__c){
                    salesOrderIds.add(salesorder.id);
                }
                
                if((salesOrderRecordTypeMap.get(salesorder.RecordTypeId) == 'Standard Sales Order' 
                            || salesOrderRecordTypeMap.get(salesorder.RecordTypeId) == 'Trade Loader Sales Order Drop 1')
                            && salesOrder.Status__c != trigger.oldMap.get(salesOrder.id).Status__c 
                            && (salesOrder.Status__c == APPROVED_STATUS 
                                    || (salesorder.Status__c == 'New Sales Order Created' 
                                            && trigger.oldMap.get(salesOrder.id).Status__c == 'Sent for Approval'))) {
                    System.debug('Processing SalesOrder: ' + salesOrder);
                    if(salesorder.Drop_1_Date__c == null 
                                || Math.abs(salesorder.Drop_1_Date__c.daysBetween(todaysDate)) <= 2){
                        /*
                         * for backward compatibility
                         */
                        if (salesorder.WholeSaler_Type__c == 'ALM') {
                            almSalesOrderIds.add(salesOrder.Id);
                        } else {
                            ilgSalesOrderIds.add(salesOrder.Id);
                        }
                    }                                           
                }                
                
               if( salesOrder.X5_Hours_Since_Order_Creation__c && salesOrder.Status__c == 'Sent for Approval' && !system.isBatch() && !system.isFuture()) {                                       
                    salesOrderForAutoApprovalSet.add(salesOrder.Id);
                    System.debug('Approval Set: ' + salesOrderForAutoApprovalSet);  
                    if (salesorder.WholeSaler_Type__c == 'ALM') {
                        almSalesOrderIds.add(salesOrder.Id);
                    } else {
                        ilgSalesOrderIds.add(salesOrder.Id);
                    }
                }
                
                if(salesOrder.X1_Hours_Since_Order_Creation__c == true  
                    && Trigger.oldMap.get(salesOrder.Id).X1_Hours_Since_Order_Creation__c != salesOrder.X1_Hours_Since_Order_Creation__c){
                    salesOrderIdToEscalateApproval.add(salesOrder);
                }               
            }
            
            system.debug('---salesOrderIdToEscalateApproval--' + salesOrderIdToEscalateApproval);
            if(!salesOrderIdToEscalateApproval.isEmpty()){
                salesOrderTriggerHandler handler = new salesOrderTriggerHandler();
                // Escalate order to the state Manager
                handler.escalateApprovalToStateManager(salesOrderIdToEscalateApproval);
            }
            
            

            if(!salesOrderForAutoApprovalSet.isEmpty()) {
                System.debug('AutoApprove: ' + salesOrderForAutoApprovalSet);
                AutoApproveRecords.approveRecords(salesOrderForAutoApprovalSet);
            }  

                      
        }
        
        // call method to populate Authorising rep, supplier reference field on sales order
        // send approved order to wholesaler 
        if((trigger.isInsert || trigger.isUpdate) && trigger.isAfter){
            wholesalerNumber.updateWholesalerNumber(salesOrderIds);
            System.debug('WholesalerNumber updated: ' + salesOrderIds);
            system.debug('running status: ' + StaticVariableHandler.setSalesOrderTriggerRun);
            
            if (ilgSalesOrderIds.size() > 0) {
                ILGSplitBonusOrder splitOrderHandler = new ILGSplitBonusOrder();
                ilgSalesOrderIds.addALL(splitOrderHandler.splitOrder(ilgSalesOrderIds));                
                SalesOrderStatusUpdateHandler.sendApprovedOrderToWholesaler(ilgSalesOrderIds); 
            }
            if (almSalesOrderIds.size() > 0) {              
                System.debug('Sent to wholesaler: ' + almSalesOrderIds);
                for (Id salesOrderId : almSalesOrderIds) {
                    SalesOrderStatusUpdateHandler.sendApprovedOrderToWholesaler(new Set<Id>{ salesOrderId});                    
                }
            }
        }
    }    
}