/*
 * Class Name : PopulateAccountAddress
 *
 * @author Debasish (debasish@arxxus.com)
 * @revised : 16-05-2013 [created by Debasish]
 * @revised : 
 */ 


public  class PopulateAccountAddress {
	
	public Account accountRec;
	
	 /*
	 * Method : autoPopulateAddress
	 * Description - This Method is displays the Address dialog in call planning and objective planning page.
	 * Input Param : string, list <Account>
	 * Output Param: account
	 * @author Debasish (debasish@arxxus.com)
	 * @revised : 16-05-2013 [created by Debasish]
	 * @revised : 
	 */ 
	
	public Account autoPopulateAddress(string accId, list<Account> accounts){
		
		accountRec = new Account();
		
		for(Account acc : accounts){
			
			if(acc.id == accId){
				
				accountRec = acc;
				
				break;
				
			}
			
		}
		
		return accountRec;
		
	}
	
}