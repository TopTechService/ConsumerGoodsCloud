/*
 * Class Name : AutoApproveRecords
 * Description - This class automatically approves Records
 * @author Geeta Kushwaha (geeta.kushwaha@arxxus.com)
 * @created : 23-10-2013 [created by Geeta]
 */
public class AutoApproveRecords {

    /**
	 * @author : Geeta Kushwaha, geeta.kushwaha@arxxus.com
	 * @date : 23-10-2013
	 * @Description : Auto Approve Records
	 * @parameter : Records which needs to be approved automatically
	 * @return : void
	 */
    @future
    public static void approveRecords(set <Id> targetObjectSet){
    	
    	StaticVariableHandler.setSalesOrderTriggerRun = 2;
    	
        map<Id,Id> workItemMap = new map<Id,Id>();
            
        for(ProcessInstance approvalProcessRec : [Select Id, TargetObjectId
                                                  From ProcessInstance
                                                  where TargetObjectId IN : targetObjectSet
                                                  and Status = 'Pending'
                                                  and isDeleted = false]) {
                                                    
            workItemMap.put(approvalProcessRec.TargetObjectId, null);                                       
                                                    
        }
            
        if(!workItemMap.isEmpty()) {
                                                  
            for(ProcessInstanceWorkitem workItem  : [Select Id, ProcessInstance.TargetObjectId 
                                                     from ProcessInstanceWorkitem
                                                     where ProcessInstance.TargetObjectId In: workItemMap.keySet()]) {
                                                        
                workItemMap.put(workItem.ProcessInstance.TargetObjectId, workItem.id);
            
            }
            
            for(Id salesOrder : targetObjectSet) {
                
                if(workItemMap.containsKey(salesOrder) && workItemMap.get(salesOrder) != null) {
                    
                    Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
                    
                    req2.setComments('This Record has been auto approved');
                    
                    req2.setAction('Approve'); //This is the action that is approve in your case, you can set it to Reject also
                    
                    req2.setWorkitemId(workItemMap.get(salesOrder));
        
                    // Submit the request for approval  
                                
                    Approval.ProcessResult result2 =  Approval.process(req2);   
                        
                }                             

            }                                     
            
        }

    }
    
    
    /**
     * @author : Geeta Kushwaha, geeta.kushwaha@arxxus.com
     * @date : 23-10-2013
     * @Description : Update X5_Hours_Since_Order_Creation__c of Sales Order to False so that when the trigger executes again, 
                      it does not invoke auto approve again
     * @parameter : Records where X5_Hours_Since_Order_Creation__c needs to be set to False
     * @return : void
     */
    @future
    public static void setX5_Hours_Since_Order_CreationToFalse(set <Id> salesOrderIdSet){
    	
    	StaticVariableHandler.setSalesOrderTriggerRun = 2;
    	
    	if(!salesOrderIdSet.isEmpty()) {
    		
    		list <Sales_Order__c> salesOrderList = [Select Id, X5_Hours_Since_Order_Creation__c
    		                                        from Sales_Order__c
    		                                        where Id IN: salesOrderIdSet];
    		                                        
            for(Sales_Order__c so : salesOrderList)  {
            	
            	so.X5_Hours_Since_Order_Creation__c = false;
            	
            }  
            
            update salesOrderList;                                        
    		
    	}
    
    }

}