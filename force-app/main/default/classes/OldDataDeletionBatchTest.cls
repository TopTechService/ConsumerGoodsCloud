/*
 * Class Name : OldDataDeletionBatchTest
 * Description : This is test class for OldDataDeletionBatch
 * @author : Rahul Devsatwar
 * @revised : 27-03-2017
 */ 
@isTest
private class OldDataDeletionBatchTest {
    
    @isTest static void myUnitTest(){

        List<Sale_MySales__c> mysaleList= new List<Sale_MySales__c>();
        
        for(Integer i=0 ;i <2000;i++)
        {
            Sale_MySales__c mysale = new Sale_MySales__c();
            mysale.Name = 'Test' + i;
            mysale.OutletID__c = 'Test' + i;
            mysale.ProductID__c = 'Test' + i;
            mysale.Nine_LE__c = i;
            //mysale.Sales_External_Id__c = 'Test' + i;
            mysale.Sale_ExtId__c = 'Test' + i;
            mysale.Sale_Date__c = System.today().addDays(-740);
            
            mysaleList.add(mysale);
        }
        if(!mysaleList.isEmpty()){
            System.debug('mysaleList.size()===>' + mysaleList.size());
            System.debug('mysaleList.size()===>' + mysaleList[0].Sale_Date__c);
            insert mysaleList;  
        }

        Test.startTest();
        OldDataDeletionBatch batch = new OldDataDeletionBatch();
        Database.executebatch(batch);
        Test.stopTest();
    }

    @isTest static void setWherePartTest(){
        OldDataDeletionBatch batch = new OldDataDeletionBatch();
        batch.setWherePart('Test');
    }
    
}