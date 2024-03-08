/**
 * @author : Geeta Kushwaha, geeta.kushwaha@arxxus.com
 * @date : 16-01-2014
 * @Description : This class executes batch ResetVolumeOnAccountBatch. Which in turn updates Volume on Account 
 */
global class ResetVolumeOnAccountScheduler implements Schedulable {
	
	global void execute(SchedulableContext ctx) {
           
      database.executebatch(new CalculateSumOfNineLe());
      
   }   

}