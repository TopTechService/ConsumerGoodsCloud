/**
 * @Author: Gunwant Patidar
 * @description : runs every day and calls SalesorderProcessor class to process orders to wholesaler
 * @created date : 23/5/2013
 */
global class SchedulerSalesorderProcessor implements Schedulable{
    global void execute(SchedulableContext SC){
       
        SalesorderProcessor.sendOrderToWholesaler(); 
    }
}