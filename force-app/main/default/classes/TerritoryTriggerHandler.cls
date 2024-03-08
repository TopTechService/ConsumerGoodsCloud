/* This class was replaced by Flow: Territory: After Update (V2)  - NOT USING IT ANYMORE CARNAC aug.2022
 */
public class TerritoryTriggerHandler {

    private boolean m_isExecuting = false;
    private integer BatchSize = 100;
    
    
    public TerritoryTriggerHandler(boolean isExecuting, integer size){
        
        m_isExecuting = isExecuting;
        BatchSize = size;
    } 
   
    public void OnAfterUpdate(List<Territory__c> territories) {
        
        /* set<id> uniqueCodes = new set<id>();
        set<id> accountIds = new set<id>();
        
        List<Post_Code_Region__c> postCodes = [SELECT id, Territory_Owner__c FROM Post_Code_Region__c WHERE Territory__c IN :territories];
        
        system.debug('TerritoryTriggerHandler OnAfterUpdate postCodes ' + postCodes.size());
        
        List<Post_Code_Region__c> listPostCodeUpd = new List<Post_Code_Region__c>();
        
        for(Post_Code_Region__c pcr : postCodes){
            Post_Code_Region__c postCodeUpd = new Post_Code_Region__c();
            uniqueCodes.add(pcr.id);
            postCodeUpd.id	= pcr.id;
            postCodeUpd.OwnerId = pcr.Territory_Owner__c;
            listPostCodeUpd.add(postCodeUpd);
            
        }
        
        update listPostCodeUpd;
        
        
        if(uniqueCodes.size() >0){
        
        List<Account> accounts = [SELECT id, name, ownerId, BillingPostalCode, Post_Code_Merged__c, Pending_Post_Code__c FROM Account 
                                  WHERE Post_Code_Region__c IN :uniqueCodes 
                                  AND Post_Code_Region__c <> null];
        
        
        for(Account acc : accounts){
            accountIds.add(acc.id);
        }
        
        if(accountIds.size() > 0 ){           
           system.debug ('TerritoryTriggerHandler OnAfterUpdate accounts:' + accountIds.size());
            ProcessAccounts(accountIds);
           }
        } */
    }
    
    @future
    public static void ProcessAccounts(set<id> accountsIds) {
        
    /*     Map<Id, User> usersMap2 = new Map<Id, User>([SELECT Id, ManagerId, manager.email,EmployeeNumber, LastName, FirstName  
                                                            FROM User ]);
        
        List<Account> accountList = [SELECT id, name, ownerId, BillingPostalCode, Post_Code_Merged__c, Pending_Post_Code__c,
                                     Post_Code_Region__c, Account.Post_Code_Region__r.ownerID FROM Account WHERE id IN :accountsIds];
        
        
        system.debug('TerritoryTriggerHandler ProcessAccounts accountsIds.size: ' + accountList.size());
        
    	List<Account> accountsToUpdate = new List<Account>();
        
        for(Account Acc : accountList){
            Account accountToUpdate = new account();
            accountToUpdate.id = acc.id;
            //accountToUpdate.OwnerId = acc.Post_Code_Region__r.OwnerId;
           // accountToUpdate.ASM_User_ID__c = usersMap2.get(acc.Post_Code_Region__r.OwnerId).EmployeeNumber; 
            accountsToUpdate.add(accountToUpdate);
        }
            
        system.debug('TerritoryTriggerHandler ProcessAccounts accountsToUpdate.size: ' + accountsToUpdate.size());
       	update accountsToUpdate; */
    	
    }
}