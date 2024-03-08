/* This class was replaced by Flow: Post Code: After Update and Post Code: Before update - NOT USING IT ANYMORE CARNAC aug.2022
 */
public class PostCodeTriggerHandler {

     private boolean m_isExecuting = false;
    private integer BatchSize = 20;
    Map<string,id> PC_Id = new Map<string,id>();
    Map<string,id> TerritoryOw_Id = new Map<string,id>();
    
    public PostCodeTriggerHandler(boolean isExecuting, integer size){
        
        m_isExecuting = isExecuting;
        BatchSize = size;
    }   
    
    
    public void OnBeforeUpdate(List<Post_Code_Region__c> postCodes) {
    	
       /*  for(Post_Code_Region__c pcr : postCodes){
        pcr.OwnerId = pcr.Territory_Owner__c;
        }  */    
        //system.debug ('PostCodeTriggerHandler onBeforeUpdate Assigning Terri Owner');
    }
    
    
    public void OnAfterUpdate(List<Post_Code_Region__c> postCodes) {
        
     /*    set<id> uniqueCodes = new set<id>();
		
        for(Post_Code_Region__c pcr : postCodes){
            uniqueCodes.add(pcr.id);
        }
        
        if(uniqueCodes.size() > 0 ){           
            system.debug ('PostCodeTriggerHandler afterUpdate uniqueCodes.size:' + uniqueCodes.size());
            ProcessPostCodes(uniqueCodes);
        } */
    }
       
        
    @future
    public static void ProcessPostCodes(set<id> uniqueCodes) {
    
      //  List<Post_Code_Region__c> PostCodes = [Select Name, Territory__r.OwnerId From Post_Code_Region__c where id IN :uniqueCodes];
      //  List<Post_Code_Region__c> ListPostCodeUpd = new List<Post_Code_Region__c>();
      
      // for(Post_Code_Region__c pcr : PostCodes){
          //  Post_Code_Region__c PostCodeUpd = new Post_Code_Region__c();
          //   PostCodeUpd.id	= pcr.id;
          //  PostCodeUpd.OwnerId = pcr.Territory__r.OwnerId;
          // ListPostCodeUpd.add(PostCodeUpd);
          //    }
          
          //  update ListPostCodeUpd;
        
   /*      List<Account> accountList = [SELECT id, name, ownerId, BillingPostalCode, Post_Code_Merged__c, Pending_Post_Code__c,
                                     Post_Code_Region__c, Account.Post_Code_Region__r.ownerID FROM Account 
                                  	WHERE Post_Code_Region__c IN :uniqueCodes 
                                  	AND Post_Code_Region__c <> null];
        
        if (accountList.size()>0){
            Map<Id, User> usersMap2 = new Map<Id, User>([SELECT Id, ManagerId, manager.email,EmployeeNumber, LastName, FirstName  
                                                                FROM User ]);
            
            system.debug('PostCodeTriggerHandler ProcessPostCodes accountList.size: ' + accountList.size());
            
            List<Account> accountsToUpdate = new List<Account>();
            
            for(Account acc : accountList){
                Account accountToUpdate = new account();
                accountToUpdate.id = acc.id;
                accountToUpdate.OwnerId = acc.Post_Code_Region__r.OwnerId;
                accountToUpdate.ASM_User_ID__c = usersMap2.get(acc.Post_Code_Region__r.OwnerId).EmployeeNumber; 
                accountsToUpdate.add(accountToUpdate);
            }
                
           system.debug('PostCodeTriggerHandler ProcessPostCodes accountList.size: ' + accountList.size());
           system.debug('PostCodeTriggerHandler ProcessPostCodes accountsToUpdate.size: ' + accountsToUpdate.size());
           system.debug('PostCodeTriggerHandler ProcessPostCodes accountsToUpdate ' + accountsToUpdate.get(0));
            
           update accountsToUpdate;
    	} */
    }
        
}