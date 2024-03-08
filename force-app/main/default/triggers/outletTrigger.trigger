/*Created By -:Sourav Nema
  Purpose-:Populate value of outlet category and state on  outlet object
  
  */

trigger outletTrigger on Outlet__c ( after update, before insert, after insert) {
    RecursiveTriggerController.outletCount++;// Counter is supposed to count only if the outlet was updated by one account.
    list<string> outLetCategory         =  new list<string>();
    list<string> state                  =  new list<string>();
     
    DataLoaderHelper helper             = new DataLoaderHelper();
   
    map<string, id> outLetCategoryMap   =  new map<string, id>();
   
    map<string, id> stateIdMap          =  new map<string, id>();          
    list<account> accountList           =  new list<account>();   
    String recrdTypeId = Utilities.getRecordTypeId('Account','Outlet');
    //map<string,account> accountMap = new map<string,account>();
   // list<account> updatableAccount = new list<account>(); // not using
    //list<string> outletId = new list<string>();
    
           
    for(Outlet__c outLet:trigger.new){
        if(outLet.Outlet_Category_Id__c != null && outLet.State_ID__c != null){
        outLetCategory.add(outLet.Outlet_Category_Id__c);
        state.add(outLet.State_ID__c);     
        //outletId.add(outLet.name); //Not using
        }
    } 
    
   

    //Get id of corresponding state and outlet category
    if(outLetCategory.size()>0 && state.size()>0){
    outLetCategoryMap.putAll(helper.getOutletCategoryMap (outLetCategory)); //CodeReview - Map with category code, Outlet_Category__c ID
    stateIdMap.putAll(helper.getStateMap(state));   //CodeReview - Map with state code, State__c ID 
    }
    
    /**
     * @Arxxus Support 
     * Changes to update related Outlet Account based on outlet
   	 */
    
    if (trigger.IsAfter && trigger.IsUpdate) {
        
    	// don't update account if trigger is invoked by account trigger
    	if (RecursiveTriggerController.count > 1){
            system.debug('OutletTrigger RecursiveTriggerController.count>>> '+RecursiveTriggerController.count);
    		return;
        }        	
	    if (OutletTriggerHelper.outletTriggerFired){
            system.debug('OutletTrigger outletTriggerFired>>> '+OutletTriggerHelper.outletTriggerFired);
	    	return;
        }	    
	    OutletTriggerHelper.outletTriggerFired = true;    	
    	try {
            system.debug('outletTrigger IsAfter IsUpdate');
    		OutletTriggerHelper outletHelper = new OutletTriggerHelper();
    		outletHelper.updateRelatedAccount(Trigger.newMap,  Trigger.oldMap, outLetCategoryMap
    															, stateIdMap);
    	} catch(Exception ex) {
			List<String> toAddresses = new List<String>();
            String configEmails = Email_Configuration__c.getInstance('NotificationEmails').Email_Ids__c;
            toAddresses = configEmails.split(',');
            System.debug('toAddresses>>>' + toAddresses);
			//toAddresses.add('campari@arxxus.com');
            //toAddresses.add('Olyn.Jumalon@campari.com');
            //toAddresses.add('ybeurier@carnacgroup.com');
			List<String> ccAddresses = new List<String>();
			String body = 'Exception occurred while updating Outlet Accounts from outletTrigger :' + ex.getTypeName() + ': ' + ex.getMessage() 
							+ ' -- ' + ex.getCause() + ' -- '+ ex.getStackTraceString(); 
			SendEmail em = new SendEmail();
			em.sendEmailToUsers(toAddresses, ccAddresses, 'Exception occurred while updating Accounts (Outlet) from outlet Trigger', body, body);	
    	}
    }    
    
    if(trigger.IsBefore && trigger.isInsert){ 
        for(Outlet__c  otlt:trigger.new){
            system.debug('state   '+stateIdMap.get(otlt.State_ID__c));
            if(stateIdMap.get(otlt.State_ID__c)!=null && outLetCategoryMap.get(otlt.Outlet_Category_Id__c)!=null){  
    
                if(otlt.Outlet_Name__c != null && otlt.Outlet_Name__c != ''){
                  otlt.Outlet_Name__c = otlt.Outlet_Name__c.toUpperCase();
                }  
                
                // all accounts are mapped to the business admin user.
                // DEfault business admin user will update the account in Salesforce manually.
                String defaultOwnerId ;
                system.debug('----Default_Account_Owner__c.getAll()----' + Default_Account_Owner__c.getAll()); //CodeReview - Default Account Owner is a custom setting
                

                if(Default_Account_Owner__c.getAll() != null && !Default_Account_Owner__c.getAll().values().isEmpty()){
                    defaultOwnerId = Default_Account_Owner__c.getAll().values()[0].ownerId__c;
                }else{
                    defaultOwnerId = userinfo.getuserid();
                }

                otlt.OwnerId = defaultOwnerId;
                   
                system.debug('---otlt.OwnerId----' + otlt.OwnerId);
                 
                
            } else {  
                if(stateIdMap.get(otlt.State_ID__c)==null){
                    otlt.State_ID__c.addError('Invalid State Id');
                } else {
                    otlt.Outlet_Category_Id__c.addError('Invalid Outlet Category Id');
                }
            }
        }
        
    } 
    
    if(trigger.IsAfter && trigger.isInsert){ 
        for(Outlet__c  otlt:trigger.new){
            system.debug('state   '+stateIdMap.get(otlt.State_ID__c));
            if(stateIdMap.get(otlt.State_ID__c)!=null && outLetCategoryMap.get(otlt.Outlet_Category_Id__c)!=null){  
    
                //create address field 
                String add1  =  otlt.Address_Line_1__c!=null?otlt.Address_Line_1__c:'';
                String add2  =  otlt.Address_Line_2__c!=null?otlt.Address_Line_2__c:'';  
                String post  =  otlt.Post_Code__c!=null?otlt.Post_Code__c:''; 
                String city  =  otlt.Suburb__c!=null?otlt.Suburb__c:'';
                System.debug('outlet...'+otlt.Outlet_Name__c);
 
                account  acc  = new account(name = otlt.Outlet_Name__c,
                                            BillingStreet = (add1+''+add2),
                                            ASM_User_ID__c = otlt.ASM_User_ID__c,
                                  			Licence_Class__c = otlt.Licence_Class__c , 
                                            Licence_Number__c = otlt.Licence_Number__c ,
                                            Licence_Type_ID__c =otlt.Licence_Type_ID__c,
                                  			LMAA_Code__c =otlt.LMAA_Code__c , 
                                            New_Liquor_Licence_Number__c = otlt.New_Liquor_Licence_Number__c,
                                            Outlet_Category_ID__c = otlt.Outlet_Category_Id__c,
                                  			BillingPostalCode= post ,
                                            BillingCity=city,
                                            recordtypeid = recrdTypeId,
                                  			Outlet_Category__c = outLetCategoryMap.get(otlt.Outlet_Category_Id__c),
                                            State__c = stateIdMap.get(otlt.State_ID__c),
                                  			Outlet_ID__c = String.valueOf(Integer.valueOf(otlt.Outlet_My_Sales_Id__c)),
                                            OwnerId = otlt.OwnerId,
                                            Outlet__c = otlt.Id
                                           );
                  
                if(otlt.ASM_User_ID__c == null || otlt.ASM_User_ID__c == '' || otlt.ASM_User_ID__c == 'null'){
                    acc.Unallocated__c = true;
                }  

                accountList.add(acc);  
                
            } 
        }
        
          DataBase.SaveResult[] accountSaveResult = DataBase.insert(accountList,true);
          
          system.debug('error is '+accountSaveResult);
        
    } 
}