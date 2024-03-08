@isTest(SeeAllData=true)
public class RHX_TEST_Employee_Leaves {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM Employee_Leaves__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Employee_Leaves__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}