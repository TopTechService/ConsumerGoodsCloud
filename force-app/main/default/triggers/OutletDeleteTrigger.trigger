trigger OutletDeleteTrigger on Outlet__c (before delete) {
	try {
		Map<String, String> outletVsAccounts = new Map<String, String>();
		List<Account> outletAccountList = new List<Account>();
		for (Outlet__c outlet : Trigger.old) {
			outletVsAccounts.put(outlet.name, null); 
		}
		
		Id accOutletRecordType = Utilities.getRecordTypeId('Account', 'Outlet');
		outletAccountList = [SELECT id, name, Outlet_ID__c FROM Account WHERE Outlet_ID__c IN : outletVsAccounts.keySet() 
																	AND RecordTypeId = : accOutletRecordType];
																
		if (!outletAccountList.isEmpty()) {
			Integer sizeList = outletAccountList.size();
			delete outletAccountList;
			
			/*
			List<String> toAddresses = new List<String>();
			toAddresses.add('campari@arxxus.com');
			List<String> ccAddresses = new List<String>();
			String body = 'Number of records :' + sizeList;
			SendEmail em = new SendEmail();
			em.sendEmailToUsers(toAddresses, ccAddresses, 'Records have been deleted successfully : Accounts (Outlet)', body, body);
			 
			if(System.Test.isRunningTest()) {
				Account acc = new Account();
				insert acc;
			}	*/			
		} 				
	} catch (Exception e) {
			/*
			List<String> toAddresses = new List<String>();
			toAddresses.add('campari@arxxus.com');
			List<String> ccAddresses = new List<String>();
			String body = 'Exception :' + e.getMessage();
			SendEmail em = new SendEmail();
			em.sendEmailToUsers(toAddresses, ccAddresses, 'Exception occurred while deleting records : Accounts (Outlet)', body, body);
	   		*/
	}

}