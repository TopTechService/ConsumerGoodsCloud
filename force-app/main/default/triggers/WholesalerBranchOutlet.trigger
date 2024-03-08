trigger WholesalerBranchOutlet on Wholesaler_Branch_Outlet__c (before insert, before update) {
  
  //Set value of  Account
   list<string> outletId        = new list<string>();
   list<string> branchId        = new list<string>();
  
   
   DataLoaderHelper helper = new DataLoaderHelper();
   map<string, account> outletAccountIdMap = new map<string, account>();
   map<string, id> 		BranchIdMap        = new map<string, id>();
  
   
   for(Wholesaler_Branch_Outlet__c saler :trigger.new){
    
      
      outletId.add(saler.Outlet_ID__c);
      branchId.add(saler.Wholesaler_Branch_ID__c);
     
    
   }  
   
   //Get id of corresponding account
  
   
    outletAccountIdMap.putAll(helper.getWholesalerOutletMapId(outletId));
          BranchIdMap.putAll(helper.getWholesalerBranchIdMap(branchId));
      
  //Assign account
  
   for(Wholesaler_Branch_Outlet__c  saler:trigger.new){
      
     if(outletAccountIdMap.get(saler.Outlet_ID__c)!=null){
         
         saler.Outlet_Account__c     = outletAccountIdMap.get(saler.Outlet_ID__c).id;
         saler.Name = saler.Wholesaler_Branch_My_Sales_Id__c;
         
     }
     else{
     
       saler.Outlet_ID__c.addError('Invalid Outlet Id');
     }  
     
     if(BranchIdMap.get(saler.Wholesaler_Branch_ID__c)!= null){
     saler.Wholesaler_Branch__c  = BranchIdMap.get(saler.Wholesaler_Branch_ID__c);
    }
    else{
      saler.Wholesaler_Branch_ID__c.addError('Invalid Branch Id');
    }
     
     
    
   }  
   
}