/*Created By-:Sourav Nema
  Purpose-:Insert or update account based on inserted or updated Wholesaler data

 */



trigger WholesalerTrigger on Wholesaler__c (after insert,after update) {


	list<id> wholesalerGroupId            = new list<string>();
	DataLoaderHelper helper               = new DataLoaderHelper();
	map<string, id> wSalerAccountIdMap;
	list<account> accountList             = new list<account>();
	list<string> wholesalerId            = new list<string>();


	for(Wholesaler__c saler:trigger.new){



		wholesalerGroupId.add(saler.Wholesaler_Group_ID__c);


		if(trigger.isInsert){
			wholesalerId.add(saler.Wholesaler_ID__c);
		}
		else{

			wholesalerId.add(trigger.oldMap.get(saler.id).Wholesaler_ID__c);
			system.debug('wholesalerid.....'+wholesalerId+'old map '+trigger.oldMap.get(saler.id));
		}
	}  

	//Get id of corresponding wholesaler group

	wSalerAccountIdMap = helper.getWholeSalerGroupIdMap (wholesalerGroupId);

	if(trigger.isInsert){ 
		for(Wholesaler__c saler:trigger.new){
			
			//insert new account from wholesaler
			if(wSalerAccountIdMap .get(saler.Wholesaler_Group_ID__c)!= null){
				account  acc  = new account(Customer_Number__c = saler.Customer_Number__c , Active__c = saler.Is_Active__c, Key_Customer_Number__c = saler.Key_Customer_Number__c,
						Old_Customer_Number__c = saler.Old_Customer_Number__c ,   Wholesaler_Group__c = wSalerAccountIdMap .get(saler.Wholesaler_Group_ID__c),
						Wholesaler_ID__c = saler.Wholesaler_ID__c,recordtypeid =Utilities.getRecordTypeId('Account','Wholesaler'),name = saler.name,
						My_Sales_Id__c = saler.Wholesaler_ID__c);


				accountList.add(acc); 
			}
			else{

				saler.Wholesaler_Group_ID__c.addError('Invalid Wholesaler Group Id');
			}
		}
		insert accountList;  
	}





	//Update related account of  Wholesaler if wholesaler is getting updated.

	if(trigger.isUpdate){
        
		list<account>accountList2   = [select id,Customer_Number__c,Active__c,Key_Customer_Number__c, Old_Customer_Number__c, Wholesaler_Group__c, Wholesaler_ID__c
		                               from account where Wholesaler_ID__c in:wholesalerId];

		map<string,account> idMap        = new Map<string,account>();

		for(account ac:accountList2){


			idMap.put(ac.Wholesaler_ID__c,ac);    

		}

		for(Wholesaler__c saler:trigger.new){
			if(idMap.get(trigger.oldMap.get(saler.id).Wholesaler_ID__c)!=null){
				account ac = idMap.get(trigger.oldMap.get(saler.id).Wholesaler_ID__c);  
				ac.Customer_Number__c              = saler.Customer_Number__c;
				ac.Active__c = saler.Is_Active__c;
				ac.Key_Customer_Number__c          = saler.Key_Customer_Number__c;
				ac.Old_Customer_Number__c         = saler.Old_Customer_Number__c; 
				ac.Wholesaler_Group__c             = wSalerAccountIdMap .get(saler.Wholesaler_Group_ID__c);
				ac.Wholesaler_ID__c                = saler.Wholesaler_ID__c;
				ac.My_Sales_Id__c                 = saler.Wholesaler_ID__c; 
				accountList.add(ac);
			}
			else{
				saler.Wholesaler_ID__c.addError('Invalid Wholesaler Id');
			}

		}                

		update accountList;

	}
	
	
	
}