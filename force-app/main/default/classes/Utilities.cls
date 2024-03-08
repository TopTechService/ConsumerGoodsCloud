/**
 * @author    : Created by Geeta Kushwaha on 8 Apr, 2013  geeta.kushwaha@arxxus.com
 * @Purpose   : Utilities class
 * @Criteria  : This class uses Sigleton Design Pattern
 * @Modified  : Modified by Geeta Kushwaha on 20 May, 2013  geeta.kushwaha@arxxus.com
 */
public with sharing class Utilities{

    private static Map<String, Schema.SObjectType> sobjectSchemaMap;

    /*
     * returns the record type Id for given sobject & record type name
     */
    public static Id getRecordTypeId(string objectName,string recordTypeName){
        
        if(sobjectSchemaMap == null){
            
            sobjectSchemaMap = Schema.getGlobalDescribe();
        
        }
        
        Schema.SObjectType s = sobjectSchemaMap.get(objectName) ;
        
        Schema.DescribeSObjectResult cfrSchema = s.getDescribe();
        
        Map<String,Schema.RecordTypeInfo> RecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
        
        if(RecordTypeInfo.get(recordTypeName) == null){
        	
            return [select Id from RecordType where Name =: recordTypeName  and SobjectType =: objectName].Id;
            
        }    
      
        return RecordTypeInfo.get(recordTypeName).getRecordTypeId();
    
    }
    
    /*
     * Returns salesforce Id prefix of given sobject
     */
    public static String getSalesforceIdPrefix(String sObjectName){
		
		if(sobjectSchemaMap == null){
            
            sobjectSchemaMap = Schema.getGlobalDescribe();
        
        }
		
		for(String sObj : sobjectSchemaMap.keySet()){
			
			Schema.DescribeSObjectResult r = sobjectSchemaMap.get(sObj).getDescribe();
			
			if(r.getName().equalsIgnoreCase(sObjectName)) {
			    
			    return r.getKeyPrefix();
			
			}
		
		}  
		
		return null;
		
	}
	
	/*
	 * This method returns all Subordinate Users for a given role & with the given role
	 */
	public static list<User> getRoleSubordinateUsers(Id roleId) {
        
        Set<Id> allSubRoleIds = getAllSubRoleIds(new Set<ID>{roleId});
        
        allSubRoleIds.add(roleId);
        
        list<User> users = [Select Id, Name,isActive 
                            From User where 
                            UserRoleId IN : allSubRoleIds
                            order by Name asc];

        return users;
        
    }
 
    /*
     * This method retunrns the sub roles of given roles
     */
    private static Set<ID> getAllSubRoleIds(Set<ID> roleIds) {
 
        Set<ID> currentRoleIds = new Set<ID>();
     
        for(UserRole userRole :[select Id 
                                from UserRole 
                                where ParentRoleId IN :roleIds 
                                AND ParentRoleID != null]) {
                                
           currentRoleIds.add(userRole.Id);
     
        }

        if(currentRoleIds.size() > 0)
        
          currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds));
     
        return currentRoleIds;
 
    }    
   
    /*
     * This method accepts the userId and returns map containing userId and corresponding user record 
     */
    public static Map<Id, User> getUsers(set<Id> managersIdSet){
    	
    	managersIdSet.remove(null);
   	
   	    if(managersIdSet.size() > 0) {
   	    	
	   	    return new map<Id, User>([select id, email, FirstName, Alias 
	   	                              from User
	   	                              where Id IN: managersIdSet]);
	   	                                 	
   	    }
   	    
   	    return new map<Id, User>();
   	    
    }

}