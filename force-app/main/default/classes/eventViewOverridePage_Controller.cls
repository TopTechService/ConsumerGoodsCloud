public class eventViewOverridePage_Controller {

    private List<Task> taskz;
    private Event evnt; 
    private Account accnt;
    public eventViewOverridePage_Controller(ApexPages.StandardController controller) {
        this.evnt= (event)controller.getRecord();
    }
    
    public List<Task> getTaskz()
    {
        taskz = new List<Task>();
        Event evn = [Select id, AccountId FROM Event where id = :evnt.id];
        if (evn.AccountId == null)
         return null;
        taskz = [Select id, AccountId, Objective_Name__c, ActivityDate, Status, Product_Group__c , Objective_Id__c , Subject  from Task where Accountid = :evn.AccountId and IsClosed = false Order by ActivityDate ];
        return taskz;
    }
}