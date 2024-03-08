@isTest(SeeAllData=true)
private class updateAccountsOwnerBatchTest {
    
    @isTest
    private static void updateAccountOwnerBatchTest() {
        
        Test.startTest();
 		
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
               
        String uniqueAccountName = 'Account - ' + DateTime.now().getTime();
       
        Account acc = new Account(Name = uniqueAccountName);
        insert acc;
        
        Account AccountUpdated = [SELECT id, ownerId FROM account WHERE Name = :uniqueAccountName];
             	        
        updateAccountsOwnerBatch.GetOwnersInformation s = new updateAccountsOwnerBatch.GetOwnersInformation();
        s.Old_Owner_Id = AccountUpdated.OwnerId;
        s.New_Owner_Id = AccountUpdated.OwnerId;
        
                
        updateAccountsOwnerBatch.searchEntries(new List<updateAccountsOwnerBatch.GetOwnersInformation> {s});    
        
        Test.stopTest();
        
      
    }
}