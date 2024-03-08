public class SetPostCode {

    private boolean m_isExecuting = false;
    private integer BatchSize = 20;
    
    
    public SetPostCode(boolean isExecuting, integer size){
        
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
   
 
    public void setAccountPostCode(List<Account> Accounts) {
       
        system.debug('Assign PostCode....');
        
        set<string> PostCodeList = new set<string>();
    	List<Account> AccNotDefinePCs = new List<Account>();
                
        For(Account Acc : Accounts){
             if(Acc.BillingPostalCode <> NULL){
                   system.debug('This is the new post code: ' + Acc.BillingPostalCode);
                   PostCodeList.add(Acc.Post_Code_Merged__c);
                    }
                }
    	            
        			List<Post_Code_Region__c> Post_Codes = [Select Id, Name, Post_Code_Merged__c, Territory_Owner__c from Post_Code_Region__c where Post_Code_Merged__c IN :PostCodeList];
                    Map<string,id> PC_Id = new Map<string,id>();
                    Map<string,id> TerritoryOw_Id = new Map<string,id>();
                       
                    For(Post_Code_Region__c PC : Post_Codes){
                           PC_Id.put(PC.Post_Code_Merged__c, PC.id); 
                           TerritoryOw_Id.put(PC.Post_Code_Merged__c,PC.Territory_Owner__c);
                        }
                       
                    List<Account> AccountsToUpdate = new List<Account>();
                        
                    For(Account Acc : Accounts){
                         Account AccountToUpdate = new account();
                         AccountToUpdate.id = acc.id;
                            
                        If(PC_Id.get(acc.Post_Code_Merged__c) <> null){
                                AccountToUpdate.Post_Code_Region__c = PC_Id.get(acc.Post_Code_Merged__c);
                                AccountToUpdate.OwnerId = TerritoryOw_Id.get(acc.Post_Code_Merged__c);
                                AccountToUpdate.Pending_Post_Code__c = FALSE;
                         }else{
                                 AccountToUpdate.Pending_Post_Code__c = TRUE;
                            }
                         AccountsToUpdate.add(AccountToUpdate);
                    }
               
                    Update AccountsToUpdate;
                
                    
                
               
    }
        
    
    
    
}