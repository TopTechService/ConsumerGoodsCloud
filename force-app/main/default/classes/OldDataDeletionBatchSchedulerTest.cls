@isTest
private class OldDataDeletionBatchSchedulerTest {
	
	@isTest
	static void testScheduler(){ 
	Test.StartTest();
	OldDataDeletionBatchScheduler schedule = new OldDataDeletionBatchScheduler();
		String sch = '0 0 23 * * ?';
		system.schedule('Test',sch,schedule);
	Test.stopTest();
	}
}