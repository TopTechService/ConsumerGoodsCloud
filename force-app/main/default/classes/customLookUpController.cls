public class customLookUpController {
    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName, String additionalField, String queryCondition) {
        system.debug('ObjectName-->' + ObjectName);
        String searchKey = string.escapeSingleQuotes(searchKeyWord.replace('’','\'')) + '%';
        
        List < sObject > returnList = new List < sObject > ();
        
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5   
        String sQuery =  'select id, Name ';
        // Add an Additionnal field in the search
        if(String.isNotBlank(additionalField))
            sQuery = sQuery + ', ' + additionalField;
        // Add the from and standard search
        sQuery = sQuery + ' from ' +ObjectName + ' where Name LIKE \'' + searchKey + '\'';
        // Add the query condition
        if(String.isNotBlank(queryCondition))
            sQuery = sQuery + ' and ' + queryCondition;
        // Add the ordering and limit
        sQuery = sQuery + ' order by createdDate DESC limit 5';
            
        system.debug('### sQuery : ' + sQuery);
        List < sObject > lstOfRecords = Database.query(sQuery);
        
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
}