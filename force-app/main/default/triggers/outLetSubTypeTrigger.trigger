/*Created by-:Sourav Nema
  Created Date-:5/6/2013
  Purpose-:Populate value in 	Outlet_Type__c look up field of Outlet_Sub_Type__c  
  */
    

trigger outLetSubTypeTrigger on Outlet_Sub_Type__c (before insert, before update) {
    list<string> outLetId                           = new list<string>();
   
   DataLoaderHelper helper                          = new DataLoaderHelper();
   
   map<string, Outlet_Type__c> outTypeIdMap         =  new map<string,Outlet_Type__c>();
   
 
   
   for(Outlet_Sub_Type__c subType:trigger.new){
    
      
      outLetId.add(subType.Outlet_Type_Id__c);
       
    
   }  
   
   //Get id of corresponding Outlet Type
   
    outTypeIdMap.putAll(helper.getOutletIdMap(outLetId));
   
 
      
  //Assign Outlet type
  
   for(Outlet_Sub_Type__c subType:trigger.new){
   
    if(outTypeIdMap.get(subType.Outlet_Type_Id__c) != null){
     subType.Outlet_Type__c        = outTypeIdMap.get(subType.Outlet_Type_Id__c).id;
    }
    else{
      subType.Outlet_Type__c.addError('Invalid OutLet Type Id');
    } 
    
    
   
   
}
   
}