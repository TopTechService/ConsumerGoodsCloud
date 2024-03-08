global class OutletWithoutAccountFinderBatchSchedular implements Schedulable {
   global void execute(SchedulableContext SC) {
      OutletWithoutAccountFinderBatch batch = new OutletWithoutAccountFinderBatch();
      Database.executeBatch(batch);
   }
}