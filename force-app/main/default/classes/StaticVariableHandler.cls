/**
 * @Author: Gunwant patidar
 * @description : This class stores all static variables to prevents trigger running recursively.
 * @created date : 22/5/2013
 */
public class StaticVariableHandler {
	public static integer setParentHierarchyRun = 1;
	public static integer setSalesOrderTriggerRun = 1;
	public static integer wholesalerAccountNumber = 1;// used in WholesalerAccountNumberHandlerSalesOrder class
	public static Integer promotionTriggerRun = 1;
	public static integer sendEmailSalesOrderChinaApprovedTriggerRun = 1;
	public static boolean updateBannerGroupOutlet = true;
}