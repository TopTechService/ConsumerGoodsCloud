public with sharing class salesOrderTriggerHandler {
	public salesOrderTriggerHandler() {
		
	}

	/**
	* @Description : This method is used to escalate the approval to the state Manager 
	*/
	public void escalateApprovalToStateManager(list<Sales_Order__c> salesOrderList){
		
		system.debug('---salesOrderList--' + salesOrderList);
		map<Id,Id> salesOrderIdVsapprovalId = new map<Id,Id>();
		set<Id> asmUserIdSet = new set<Id>();
		list<ProcessInstanceWorkitem> items = [ SELECT ActorId,CreatedDate,Id,IsDeleted,OriginalActorId,ProcessInstanceId, 
		                                               ProcessInstance.TargetObjectId,CreatedBy.State_Sales_Manager__c 
		          								FROM ProcessInstanceWorkitem 
		          								WHERE ProcessInstance.TargetObjectId In : salesOrderList];
		
		list<ProcessInstanceWorkitem> approvalToEscalate = new list<ProcessInstanceWorkitem>();
		for(ProcessInstanceWorkitem item : items){
			if(String.isNotBlank(item.CreatedBy.State_Sales_Manager__c)){
				item.ActorId = item.CreatedBy.State_Sales_Manager__c;
				approvalToEscalate.add(item);
			}
		}
		system.debug('---approvalToEscalate--' + approvalToEscalate);
		try{
			if(!approvalToEscalate.isEmpty()){
				Database.update(approvalToEscalate);
			}
		} catch(Exception e ){
			system.debug('Exception Occured While updating Approval process ');
		}
		

	}
}