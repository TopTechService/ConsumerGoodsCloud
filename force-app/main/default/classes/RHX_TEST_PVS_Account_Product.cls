@isTest(SeeAllData=true)
public class RHX_TEST_PVS_Account_Product {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM PVS_Account_Product__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new PVS_Account_Product__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}