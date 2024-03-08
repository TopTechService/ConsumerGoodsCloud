global class updateAccountsOwnerBatch  implements Database.Batchable<sObject> {
     
     private static Integer BATCH_SIZE = 100;

     global String Old_Owner_Id; 
  	 global String New_Owner_Id; 
    
    
      @InvocableMethod(label='Assign New Owner' description='Assign new owner to accounts')
  	  public static void searchEntries(List<GetOwnersInformation> requests) {
        
        if (requests == NULL || requests.size() == 0) {
            System.debug('There are not parameters');
        }
        
       	GetOwnersInformation request = requests[0];
		System.debug('Old Owner: ' + request.Old_Owner_Id);
        System.debug('New Owner: ' + request.New_Owner_Id);

		DataBase.executeBatch(new updateAccountsOwnerBatch(request.Old_Owner_Id, request.New_Owner_Id), BATCH_SIZE);
    } 

    global updateAccountsOwnerBatch(String oldOwnerId, String newOrderId) {
        Old_Owner_Id = oldOwnerId;
        New_Owner_Id = newOrderId;
    }
    
    global DataBase.QueryLocator start(Database.BatchableContext bc) {
        
        String query = 'SELECT Id, Name, OwnerId from Account where ownerId = \'' + Old_Owner_Id + '\'';
        
        System.debug('updateAccountsOwnerBatch Start  - This is the query> ' + query);
       
        return Database.getQueryLocator(query);
       //  System.debug('How many results?> ' + query.size() );
    }
    
    global void execute(Database.BatchableContext bc, List<Account> accounts) {
        List<Account> UpdatedAccounts = new List<Account>();
        
        for (Account acc : accounts) {
            Account updatedAccount = new Account();
			updatedAccount.id = acc.id;
            updatedAccount.OwnerId = New_Owner_Id;
        	UpdatedAccounts.add(updatedAccount);
        }
        //System.debug('updateAccountsOwnerBatch execute - New_Owner_Id: ' + New_Owner_Id);
        //System.debug('updateAccountsOwnerBatch execute - UpdatedAccounts: ' + UpdatedAccounts);

        try {
            Database.SaveResult[] srList = Database.update(UpdatedAccounts, false);
            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully updated account. Account ID: ' + sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.'+ err.getStatusCode() + ': ' + err.getMessage());                    
                        System.debug('Account fields that affected this error: ' + err.getFields());
                    }
                }           
            }
        } catch(Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }

    }
    
    global void finish(Database.BatchableContext bc) {
         // no need to do anything here
    }
        
    
   
    
    public class GetOwnersInformation {
 
        @InvocableVariable
        public String Old_Owner_Id;
        @InvocableVariable
  		public String New_Owner_Id;

    }
    
    
    
    
}