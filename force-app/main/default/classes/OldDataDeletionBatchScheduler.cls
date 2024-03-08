/*
 * Class Name : OldDataDeletionBatchScheduler
 * Description : Scheduler class for batch class 'OldDataDeletionBatch'
 * @author : Rahul Devsatwar
 */ 

global class OldDataDeletionBatchScheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
		OldDataDeletionBatch batch = new OldDataDeletionBatch();
      	database.executebatch(batch);
	}
}