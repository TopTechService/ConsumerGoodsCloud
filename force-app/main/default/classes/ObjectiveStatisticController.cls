public without sharing class ObjectiveStatisticController {

    @AuraEnabled(cacheable=true)
    public static List<Objective_Statistics__c> getObjectiveStatistics() {
        return [SELECT Id, Name, ASM__c, ASM__r.Name, ASM_Manager__c, ASM_Manager_Boolean__c , ASM_Region__c, Objective__c, Objective__r.Reporting_Name__c, Objective__r.Channel__c , Total_Allocation__c 
                                                             FROM Objective_Statistics__c 
                                                             WHERE ASM__c != null 
                                                             AND Objective__c != null
                                                             AND Current_Call_Cycle__c =: TRUE
                                                             ORDER BY ASM_Manager_Boolean__c  desc, ASM_Region__c, ASM__r.Name, Objective__r.Reporting_Name__c ];
    }

 /*
	public static List<objective_Statics_c> getNextCallCycleStatistics(){
		Call_Cycle__c currentCycle = [SELECT Id, Name, Start_Date__c
                                                             FROM Call_Cycle__c 
                                                             WHERE Current_Call_Cycle__c =: TRUE 
															 ORDER BY Start_Date__c ASC NULLS FIRST Limit 1];{
		if (currentCycle == null)
		return null;
}

 Call_Cycle__c nextCycle = [SELECT Id, Name, Start_Date__c 
                                                             FROM Call_Cycle__c 
                                                             WHERE Start_Date__c > Today 
															 ORDER BY Start_Date__c  LIMIT 1];{
		if (nextCycle == null)
		return null;
}

    // Get record to the next cycle
        return [SELECT Id, Name, ASM__c, ASM__r.Name, Objective__c, Objective__r.Name, Total_Allocation__c 
                                                             FROM Objective_Statistics__c 
                                                             WHERE ASM__c != null 
                                                             AND Objective__c != null 
                                                             AND Current_Call_Cycle__c =: nextCycle.Id
                                                             ORDER BY ASM__r.Name, Objective__r.Name];
    }
 */
      
    @AuraEnabled(cacheable=true)
    public static List<ObjectiveStatisticWrapper> getObjectiveStatisticsWrapper() {
        List<Objective_Statistics__c> objectiveStatistics = getObjectiveStatistics();

        if(objectiveStatistics.isEmpty())
            return null;
        
        // Build unicity on Axis
        Set<String> setUser = new Set<String>();
        Map<String, String> mapUserRegion = new Map<String, String>();
        Map<String, String> mapAmIManager = new Map<String, String>();
        Map<String, String> mapRowClass = new Map<String, String>();
        Set<String> setObjective = new Set<String>();
        
        for(Objective_Statistics__c objectStatistic : objectiveStatistics){
            if(objectStatistic.ASM__c != null && objectStatistic.Objective__c != null){
                setUser.add(objectStatistic.ASM__r.Name);
                setObjective.add( objectStatistic.Objective__r.Reporting_Name__c);
                mapUserRegion.put(objectStatistic.ASM__r.Name, objectStatistic.ASM_Region__c);
                mapAmIManager.put(objectStatistic.ASM__r.Name, String.valueof(objectStatistic.ASM_Manager__c));
                IF(objectStatistic.ASM_Manager_Boolean__c)
                    mapRowClass.put(objectStatistic.ASM__r.Name,'inputRows slds-theme_shade');
                    else 
                        mapRowClass.put(objectStatistic.ASM__r.Name,'inputRows');
            }
        }
        
        // Build list of users with Objective as list
        List<ObjectiveStatisticWrapper> wrapperList = new List<ObjectiveStatisticWrapper>();
        List<Objective_Statistics__c> userObjectives = new List<Objective_Statistics__c>();
        
        // Loop over user in the Set
        for(String user : setUser){
            system.debug( '### user - ' + user);
            // Within that loop, prepare a list of Statistics for the user. 
            userObjectives.clear();

            ObjectiveStatisticWrapper wrapper = new ObjectiveStatisticWrapper();
            wrapper.statistics = new List<Objective_Statistics__c>();
            wrapper.objectives = new List<String>();
            // Prepare Header Row
            wrapper.objectives.addAll(setObjective);
           
            for(Objective_Statistics__c objStatistic : objectiveStatistics){
                // Build the list is user matches
                if(objStatistic.ASM__r.Name == user){
                    userObjectives.add(objStatistic);
                }
            }
            
            wrapper.username = user;
            wrapper.userregion = mapUserRegion.get(user);
            wrapper.usermanager = mapAmIManager.get(user);
            wrapper.rowclass = mapRowClass.get(user);
            wrapper.statistics.addAll(userObjectives);
            wrapperList.add(wrapper);
        }
        
        system.debug( '### wrapperList Size - ' + wrapperList.size());
        system.debug( '### wrapperList 0 Name ' + wrapperList[0].username);
        system.debug( '### wrapperList 1 Name' + wrapperList[1].username);
        system.debug( '### wrapperList 0 Stats' + wrapperList[0].statistics);
        system.debug( '### wrapperList 1 Stats' + wrapperList[1].statistics);
        return wrapperList;
    }

    @AuraEnabled
    public static void updateObjectiveStatistics(List<Objective_Statistics__c> listObjectiveStatistic){
        try {
            system.debug('## listObjectiveStatistic' + listObjectiveStatistic);
            update listObjectiveStatistic;
        }
        catch(Exception e) {
            System.debug('## error' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public class ObjectiveStatisticWrapper{
        @AuraEnabled
        public String username{get;set;}
        @AuraEnabled
        public String userregion{get;set;}
        @AuraEnabled
        public String usermanager{get;set;}
        @AuraEnabled
        public String rowclass{get;set;}
        @AuraEnabled
        public List<Objective_Statistics__c> statistics {get;set;}
        @AuraEnabled
        public List<String> objectives {get;set;}
    }
}