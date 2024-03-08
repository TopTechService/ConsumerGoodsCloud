/*Created by-:Sourav Nema
  Created Date-:5/6/2013
  Purpose-:Populate value in 	Outlet_Sub_Type__c look up field of Outlet_Category__c  
  */
    

trigger outletCategoryTrigger on Outlet_Category__c (before insert, before update) {
 
   list<string> subTypeId             = new list<string>();
   
   DataLoaderHelper helper            = new DataLoaderHelper();
   
   map<string, Outlet_Sub_Type__c> subTypeIdMap       =  new map<string,Outlet_Sub_Type__c>();
   
 
   
   for(Outlet_Category__c oCategory:trigger.new){
    
      
      subTypeId.add(oCategory.Outlet_SubType_ID__c);
       
    
   }  
   
   //Get id of corresponding Outlet SubType
   
    subTypeIdMap.putAll(helper.getOutletSubTypeMap(subTypeId));
   
 
      
  //Assign Outlet Subtype
  
   for(Outlet_Category__c oCategory:trigger.new){
   
    if(subTypeIdMap.get(oCategory.Outlet_SubType_ID__c) != null){
     oCategory.Outlet_Sub_Type__c        = subTypeIdMap.get(oCategory.Outlet_SubType_ID__c).id;
    }
    else{
      oCategory.Outlet_Sub_Type__c.addError('Invalid SubType Id');
    } 
    
    
   
   
}

}