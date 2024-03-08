global class DeleteOutletsScheduler implements Schedulable{

	global void execute(SchedulableContext SC) {
		DeleteMarkedOutlet del = new DeleteMarkedOutlet();
		del.delWholesalerBranchOutlet();
		del.delPromotionOutlet();		
		del.delBannerGroupOutlet();
		del.delOutlet();
		del.mergeOutlet();
    }
    
}