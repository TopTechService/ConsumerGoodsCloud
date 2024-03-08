/**
 * @author      : Created by Arxxus Technology Partners
 * @date        : 24th Feb, 2014
 * @modified    : @ 23 Feb, 2015
                  1. fixed invalid stats issue - changed aggregate task query to omit call cycle date check
                     and group task based on only objectives.
                  2. fixed map key not found issue by setting page number, created new variable currentPageNumberSaveStats
                  3. to fix objective stats for objective spanning in 2 call or more call cycles 
                     removed call cycle check from Objective_Statistics__c query from getStats function.
			      @ 12 sept,2017
					1: Enhancing class for making task status 'Executed' generic */
public  class ObjectiveManagementController {
    
    public enum SortDirection {       
       ASCENDING, DESCENDING    
    }
    public static Integer i=0;
    private static Boolean activeStatus = true;
    public String messageSeverity  {get; set;}
    public String messageSummary  {get; set;}
    
    public String message {get; set;}
    public String errorLevel {get; set;}    

    /*
     * Below string variables hold selected value for each picklist in filter section
     */    
    public String selectedYear {get; set;}    
    public String selectedCallCycle {get; set;}
    public String selectedBanerGroup {get; set;}    
    public String selectedGrading {get; set;}    
    public String selectedOutlet {get; set;}    
    public String selectedObjective {get; set;}    
    public String selectedPriorityKpi {get; set;}    
    public String selectedTaskStatus {get; set;}
    public String selectedObjectiveChannel {get; set;}
    public String selectedAccountChannel {get; set;}
    public String searchAccountName {get; set;}
    public boolean isCalledOnCheck {get;set;}
    public boolean isAllocated {get;set;}

    
    /*
     * Flag indicating if add new task button needs to be displayed in cell or not
     */
    public Boolean displayAddButton {get; set;}
    
    private Boolean displayResults {get; set;}
    
    /*
     * Flags for each checkbox in show/hide section
     */    
    public Boolean bannerGrpFlag {get; set;}    
    public Boolean cityFlag {get; set;}    
    public Boolean gradingFlag {get; set;}    
    public Boolean volumeFlag {get; set;}    
    public Boolean postCodeFlag {get; set;}
    
    /*
     * currentSortField holds the current field (of outlet) on which sorting is done
     */        
    public String currentSortField {get; set;}
    public String currentSortDirection {get; set;}

	public String currentSortFieldFixed {get; set;}
	public String currentSortDirectionFixed {get; set;}

    public String previousSortField {get; set;}
    public SortDirection previousSortOrder {get; set;}    
    private SortDirection SORT_DIR; /* Current Sort Direction */       
    
    private transient Integer currentPageNumber;
    private transient Integer currentPageNumberSaveStats;
     
    /*
     * This map stores mapping of outlet field label on objective management page and field api name
     */
    private static Map<String, String> valFieldName = new map<String,String>{'Outlet' => 'name',
                                                                      'BannerGroup' => 'Banner_Group_Name__c',
                                                                      'City' => 'BillingCity',
                                                                      'Volume' => 'Volume__c', 
                                                                      'Grading' => 'Account_Grading__c',
                                                                      'postCode' => 'BillingPostalCode'};
                                                                      
    /*
     * Export to Excel & send mail to Mgr
     */
    public List<Account> accountsListExcel {get; set;}
    
    public Map<String,List<Task>> tasksMapExcel {get; set;} // Account.Id#Outlet.Id -> Task    
    
    /*

     * Helper components
     */    
    public Date todaysDate {get; set;}    
    private PicklistHelper pickHelper;    
    private DayDateWeekCalculator calc;
    
    private Call_Cycle__c selectedCallCycleRec {get; set;}    
    private Call_Cycle__c currentCallCycle {get; set;}
        
    public User currentUser {get; set;}
    
    //private final Id recordTypeObjectiveId;
    private final Id recordTypeAccountList;
    
    private Set<Id> objectivesSet;
    
    private List<Date> duration;    
    
    public Map<String,List<Task>> tasksMap {get; set;} // Account.Id#Outlet.Id -> Task
    
    public Map <Id,Objective_Statistics__c> statsMap {get; set;}    
    public Map<String, Integer> noOfObjAllocReallocPending {get; set;}    
    public Map<String, Integer> noOfObjExecuted{get; set;}    
    public Map<String, Integer> noOfObjRemaining {get; set;}

	public Map<String, Integer> allocatedStats { get; set; }
	public Map<String, Integer> pendingStats { get; set; }
	public Map<String, Integer> executedStats { get; set; }
	public Map<String, Integer> declinedStats { get; set; }

    private Map<Id,Objective__c> currentObjectivesMap {get; set;}    
    private Map<Id,Objective__c> currentObjectivesMapNew {get; set;}    
    
    public List <Id> sortedObjectivesList {get; set;}
    
    public ApexPages.StandardSetController setCon {get; set;}    
    public String recordsPerPage {get; set;}    
    public Integer totalPages {get; set;}
    
    /*
     *Popup Address Information
     */
    public Account AccAddress {get;set;}   
    public string accAddressId {get;set;}
    
    /*
     * Populate Objective Information
     */
    public String objectiveIdClicked {get;set;}    
    public Objective__c objectiveInformation {get;set;}
     
    /*
     * Constructor
     */    
    public ObjectiveManagementController(){

	    currentSortDirection = 'ASC';
        
        //recordTypeObjectiveId = Utilities.getRecordTypeId('Task', 'Objective');        
        pickHelper = new PicklistHelper();        
        todaysDate = date.today(); 
        
        if(Test.isRunningTest())        
            todaysDate = date.newInstance(2013,6,6);
        
        sortedObjectivesList = new List<Id>();        
        duration = new List<Date>(); 
        
        /*
         * If url for Call Planning has been received by email,
         * then autopopulate the filters
         * Australia - Call Cycle & Yr      
         */     
        Map<String, String> parameterMap = ApexPages.currentPage().getParameters();
        
        /*
         * Export to Excel
         */ 
        accountsListExcel = new List<Account>();        
        tasksMapExcel = new Map<String, List<Task>>();        
        
        /*
         * Data to be displayed, added or deleted
         */
        objectivesSet = new Set<Id>();              
        tasksMap = new Map<String,List<Task>>();
        noOfObjAllocReallocPending = new map<String, Integer>();        
        noOfObjExecuted = new map<String, Integer>();        
        noOfObjRemaining = new map<String, Integer>();        
        currentObjectivesMap = new map<Id,Objective__c>();        
        currentObjectivesMapNew = new map<Id,Objective__c>();        
        totalPages = 0;
        
        /*
         * Get the current user & check for user country. 
         * Get ManagerId for Send Mail to Manager
         * Get UserRoleId for populating the owner picklist 
         */          
        currentUser = [Select id, Region__c, LastName, FirstName, Country, UserRoleId, ManagerId, Manager.FirstName, State_Sales_Manager__c
                       from User
                       where Id =: UserInfo.getUserId()];    
        
        String userLocation = '';   
        
        if(currentUser.Country == null) {            
            countryNotFound();            
        } else {            
            userLocation = currentUser.Country.toLowerCase();
            if(userLocation == 'aus' || userLocation == 'australia') {
                userLocation = 'australia';                
            } 
        }  
        
        calc = new DayDateWeekCalculator(userLocation);
        
        if(parameterMap.containsKey('yr')){            
            selectedYear = parameterMap.get('yr');            
        } else {
            selectedYear = '' + todaysDate.year();
        }       
        
        //if(parameterMap.containsKey('scc')) {            
        //    selectedCallCycle = parameterMap.get('scc');            
        //}        
        
        if(parameterMap.containsKey('uId')){            
            selectedOutlet = parameterMap.get('uId');            
        }
        
        pickHelper.getCallCycleAustralia('australia', selectedYear, todaysDate);
        selectedCallCycleRec = pickHelper.getcurrentCallCycle(); 
        
        /*
         * Set select option default to ALL for below picklists
         */
        selectedBanerGroup = selectedGrading = selectedObjective = selectedPriorityKpi = selectedTaskStatus = 'All';
        
        if(!parameterMap.containsKey('uId'))        
            selectedOutlet = UserInfo.getUserId();
        
        //if(selectedCallCycleRec!= null && !parameterMap.containsKey('scc')) {          
        //   selectedCallCycle = selectedCallCycleRec.Call_Cycle__c;         
        //}
        
        currentCallCycle = selectedCallCycleRec;    
        bannerGrpFlag = cityFlag = volumeFlag = postCodeFlag = true;        
        gradingFlag = false;
        isCalledOnCheck = true;
        
        selectedObjectiveChannel = 'All';

        selectedAccountChannel = 'All';
        
        populateObjectives();
        
        if(currentObjectivesMapNew != null && currentObjectivesMapNew.size() > 0) {        
            currentObjectivesMap.putAll(currentObjectivesMapNew);        
        }
        
        /*
         * Account record types to be displayed
         */     
        recordTypeAccountList = Utilities.getRecordTypeId('Account', 'Outlet'); 
        
        /*
         * Sort
         */     
        previousSortOrder = SortDirection.ASCENDING;        
        previousSortField = 'Name';
        
        /*
         * Search the accounts to be displayed & the number of records to be displayed
         */
        recordsPerPage = '25';
        
        if(!ApexPages.hasMessages())   
            searchAccounts();         
        
    }
    
    public List<Account> getAccounts() {
        List<Account> accounts = new List<Account>();
        if(setCon != null && !ApexPages.hasMessages()) {            
            displayResults = true;          

	        if (selectedTaskStatus.contains('Executed')) {
		        for (Account account : [
			        SELECT Id, (
				        SELECT Id
				        FROM Tasks
				        WHERE Status LIKE '%Executed%'
			        )
			        FROM Account
			        WHERE Id IN :new Map<Id, Account>((List<Account>)setCon.getRecords()).keySet()
		        ]) {
			        if (account.Tasks.size() > 0)
				        accounts.add(account);
		        }
	        } else {
		        for(Account accObj : (List<Account>)setCon.getRecords()) {
			        accounts.add(accObj);
		        }
	        }
        }

        return accounts;
    }
    
    private static list<Id> getRecordTypeId(string objectName,string recordTypeName){
        list<Id> recordTypeIdList  = new list<id>();
        for(RecordType rt : [select Id from RecordType where Name like :'%' + recordTypeName +'%'  and SobjectType =: objectName]){
            recordTypeIdList.add(rt.id);
        }

        return recordTypeIdList;
    }
     
    
    public void populateAccounts(){   
        Boolean executeBol;
        tasksMap.clear();           
        Set<Id> accountIds = new Set<Id>();
        
        if (System.Test.isRunningTest())
        { executeBol = true;}
        else if(setCon != null && !ApexPages.hasMessages())
        {executeBol = true;}
        else {executeBol = false;}
        

        //if(setCon != null && !ApexPages.hasMessages()) {     
        if(executeBol == true) {       
            displayResults = true;          
            for(Account accObj : (List<Account>)setCon.getRecords()) {              
                accountIds.add(accObj.Id);
            }     
                        
            String week = null, taskMapKey = null;                        
            if(selectedTaskStatus == 'All') {            
                  list<Task> taskLit = [SELECT id, Owner.Firstname, Owner.LastName, Day__c, ActivityDate, Status, Description, WhatId, Subject, Objective_Id__c
                                    FROM Task
                                    WHERE RecordTypeId in: getRecordTypeId('Task', 'Objective')
                                       AND WhatId IN : accountIds /* Arxxus */
                                       AND Objective_Id__c IN : objectivesSet
                                    ORDER BY ActivityDate];

                for(Task taskRec : taskLit) {   
                    taskMapKey = ''+taskRec.WhatId+'#'+taskRec.Objective_Id__c;
                                    
                    if (tasksMap.get(taskMapKey) == null) {
                        List<Task> taskList = new List<Task>();
                        tasksMap.put(taskMapKey, taskList);
                    }                   
                    tasksMap.get(taskMapKey).add(taskRec);
                }               
            } //**Changes related to case no. #00021333
            else if(selectedTaskStatus.contains('Executed')){
               for(Task taskRec : [SELECT id, Owner.Firstname, Owner.LastName, Day__c, ActivityDate, Status, Description, WhatId, Subject, Objective_Id__c
                                    FROM Task
                                    WHERE 
                                   		//RecordTypeId =: recordTypeObjectiveId and
                                        WhatId IN : accountIds 
                                        AND Objective_Id__c IN : objectivesSet 
                                        AND Status like '%Executed%'
                                    ORDER BY ActivityDate]) {   
                    taskMapKey = ''+taskRec.WhatId+'#'+taskRec.Objective_Id__c;  
                    
                    if (tasksMap.get(taskMapKey) == null) {
                        List<Task> taskList = new List<Task>();
                        tasksMap.put(taskMapKey, taskList);
                    }                   
                    tasksMap.get(taskMapKey).add(taskRec);                    
                }                
                
            }
            else  {                
                for(Task taskRec : [SELECT id, Owner.Firstname, Owner.LastName, Day__c, ActivityDate, Status, Description, WhatId, Subject, Objective_Id__c
                                    FROM Task
                                    WHERE 
                                        //RecordTypeId =: recordTypeObjectiveId and
                                        WhatId IN : accountIds /* Arxxus */ /*AND call_cycle__c =: selectedCallCycle*/ // Changes Related to Case # 00019771
                                        AND Objective_Id__c IN : objectivesSet 
                                        AND Status =: selectedTaskStatus
                                    ORDER BY ActivityDate]) {   
                    taskMapKey = ''+taskRec.WhatId+'#'+taskRec.Objective_Id__c;  
                    
                    if (tasksMap.get(taskMapKey) == null) {
                        List<Task> taskList = new List<Task>();
                        tasksMap.put(taskMapKey, taskList);
                    }                   
                    tasksMap.get(taskMapKey).add(taskRec);                    
                }                
            }
            for(Id objId : currentObjectivesMap.keyset()){              
                for(Id accountId : accountIds) {                    
                    if (tasksMap.get('' + accountId +'#'+objId) == null) {
                        tasksMap.put(''+ accountId + '#'+objId, new List<Task>());                      
                    }
                }               
            }                       
        } else {
           totalPages = 0;           
        }            
    }
    
    private Map <Id,Objective_Statistics__c> getStats(){
        System.debug('x4 - getStats');
        Map<Id,Objective_Statistics__c> statsMap = new Map<Id,Objective_Statistics__c>();
        
        for(Objective_Statistics__c stats: [Select id, Total_Allocation__c, Objective__c
                                            from Objective_Statistics__c
                                            where ASM__c =: UserInfo.getUserId()
                                            and Objective__c IN : currentObjectivesMap.keySet()
                                         /*Arxxus*/   //and Call_Cycle__c =: selectedCallCycle
                                            ]){        
           statsMap.put(stats.Objective__c, stats);
        }
        
        Set<Id> remainingObjectives = new Set<Id>();
        remainingObjectives.addAll(currentObjectivesMap.keySet());
        remainingObjectives.removeAll(statsMap.keySet());
        
        /*
         * Set total allocation to 0 for all objectives for which objective statistics is not available
         */
        for(Id objId : remainingObjectives){            
            statsMap.put(objId, new Objective_Statistics__c(Total_Allocation__c = 0, Objective__c = objId, ASM__c = UserInfo.getUserId()));
        }
        
        System.debug('*********************** Returning Map  ' + statsMap.keySet());        
        return statsMap;        
    }
    
    private String getQueryString(boolean isExportRequested){
        
        String query = 'Select id, Name, Account_Grading__c, Volume__c, BillingStreet, BillingState, BillingCountry, BillingCity,  BillingPostalCode, Banner_Group_Name__c, Volume_9LE_LY__c from Account ';
        query += ' where RecordTypeId = \'' + recordTypeAccountList + '\'';             
        query += ' and OwnerId = \''+ selectedOutlet + '\'';   
        
        if(selectedBanerGroup != 'All')            
            query += ' and Banner_Group__r.Parent_Hierarchy__c LIKE '+'\'%,'+ selectedBanerGroup +',%\'' ;
        
        if(selectedGrading  != 'All')                
            query += ' and Account_Grading__c = \''+ selectedGrading + '\'' ;
        
        if(selectedAccountChannel  != 'All' && selectedAccountChannel  != null)                
            query += ' and Channel__c = \''+ selectedAccountChannel + '\''; 
        
            query += ' and Called_On__c = '+ isCalledOnCheck;

        if (!isExportRequested && null != searchAccountName && searchAccountName.length() > 0) 
            query += ' and Name LIKE \'%' + string.escapeSingleQuotes(searchAccountName) + '%\'';
         
            query += ' and Active__c = ' + activeStatus;
        
        if(currentSortField != null && valFieldName.containsKey(currentSortField)) {        
            query += ' Order By '+valFieldName.get(currentSortField);
            
            if(SORT_DIR == SortDirection.ASCENDING){                
                query += ' ASC ';               
            } else if (SORT_DIR == SortDirection.DESCENDING) {
                query += ' DESC ';                
            } else {
	            query += ' ASC ';
            }
            
            query += ' NULLS LAST';
        } else {
            query += ' Order By Name ASC ';         
        }        
        query+= ' LIMIT 10000';   

        return query;
    }
    
    public PageReference searchAccounts()  {
        System.debug('x3 - searchAccounts'); 
        sortedObjectivesList.clear();  
        messageSeverity = '';
        messageSummary = '';
                    
        if(ApexPages.hasMessages())     
            displayResults = false;       
        else        
            displayResults = true;           
                
        try {            
            if(isAllocated == true){
                setCon = new ApexPages.StandardSetController(getAllocatedAccounts(false));

            }else{
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(getQueryString(false))); 
            }
                       
            setCon.setPageSize(Integer.valueOf(recordsPerPage)); 
            Decimal dtotalPages = (setCon.getResultSize() / setCon.getPageSize());    
            dtotalPages = Math.floor(dtotalPages) + ((Math.mod(setCon.getResultSize(), Integer.valueOf(recordsPerPage))>0) ? 1 : 0);            
            totalPages = Integer.valueOf(dtotalPages);
            if(currentPageNumber != null && currentPageNumber <= totalPages){            
               setCon.setPageNumber(currentPageNumber);               
            }            
            if(setCon.getResultSize() == 0) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Outlet records not found')); 
                messageSeverity = ApexPages.Severity.ERROR.name();
                messageSummary = 'Outlet records not found';                
            }            
           
        } catch(QueryException e) {            
            if(!ApexPages.hasMessages()) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Records could not be retrieved'));
                messageSeverity = ApexPages.Severity.ERROR.name();
                messageSummary = 'Records could not be retrieved';              
            }
        }
            
        //getselectedCallCycleRec();         
        populateObjectives();
        
        noOfObjAllocReallocPending.clear();         
        noOfObjExecuted.clear();
        noOfObjRemaining.clear();
        
        objectivesSet.clear();  
        currentObjectivesMap.clear();
        if(selectedObjective == 'All') {            
            if (currentObjectivesMapNew != null && currentObjectivesMapNew.size() > 0) {
                currentObjectivesMap.putAll(currentObjectivesMapNew); 
            }

            objectivesSet.addAll(currentObjectivesMap.keyset());
            sortedObjectivesList = pickHelper.getCurrentObjectivesIdList();
        } else {                         
            objectivesSet.add(selectedObjective);
            sortedObjectivesList.add(selectedObjective);
            if (currentObjectivesMapNew != null && currentObjectivesMapNew.size() > 0) {
                currentObjectivesMap.put(selectedObjective,currentObjectivesMapNew.get(selectedObjective)); 
            }
        } 
        
        for(Id  key : currentObjectivesMap.keyset()){             
            noOfObjAllocReallocPending.put(key, 0);            
            noOfObjExecuted.put(key, 0);            
        }
              
        /*
         * Display + button to add task only if selected call cycle is either current call cycle or future call cycle
         */
        
        if(selectedCallCycleRec != null && currentCallCycle != null)                
            displayAddButton = selectedCallCycleRec.Start_Date__c >= currentCallCycle.Start_Date__c;            
        else        
            displayAddButton = false;    
            
        duration.clear();            
        duration = calc.getWeekDuration('All', selectedCallCycleRec);
                       
        if(currentPageNumber != null && currentPageNumber <= totalPages){                
           setCon.setPageNumber(currentPageNumber);               
        } else {
            // added if condition to assign correct pagenumber instead of first
            if (currentPageNumberSaveStats != null && currentPageNumberSaveStats <= totalPages) {
                setCon.setPageNumber(currentPageNumberSaveStats);
                currentPageNumberSaveStats = null;
            } else 
                setCon.first();
        }            
              
        
        refreshObjectiveStats();
        populateAccounts();         
        return null ;         
    } 

    /**
    * @Description : This method is responsible to return the list of allocated accounts  
    */
 
    private list<Account> getAllocatedAccounts(boolean isExport){
        map<Id,Account> accountsmap = new map<Id,account>((list<Account>)Database.query(getQueryString(false)) );
        set<Id> accountIdForAllocatedTask = new set<Id>();
        //system.debug('======selectedCallCycle====== Size' + selectedCallCycle);
        
        map<Id,Task> allocatedtasks = new map<Id,Task>([SELECT id , WhatId , call_cycle__c
                                       FROM Task 
                                       WHERE 
                                           //RecordTypeId =: recordTypeObjectiveId and
                                           WhatId in : accountsmap.keyset()
                                           //and call_cycle__c =: selectedCallCycle
                                           and Objective_Id__c in : objectivesSet
                                            ]);
        
        list<account> allocatedAccountList = new list<account>();
        allocatedAccountList.clear();
        for(Task tsk : allocatedtasks.values()){
            accountIdForAllocatedTask.add(tsk.whatid);
        }

        for(Id accId : accountIdForAllocatedTask){
            allocatedAccountList.add(accountsmap.get(accId));
        }
        return allocatedAccountList;
    } 

    public void first() {        
        setCon.first();       
        populateAccounts(); 
        refreshObjectiveStats();
    }
  
    public void last() {        
        setCon.last();        
        populateAccounts();     
        refreshObjectiveStats();
    }
  
    public void previous() {        
        setCon.previous();        
        populateAccounts();     
        refreshObjectiveStats();
    }
  
    public void next() {        
        setCon.next();        
        populateAccounts();    
        refreshObjectiveStats();
    }
    
    /*void getselectedCallCycleRec() {    
        messageSeverity = '';
        messageSummary = '';
        try {        
            selectedCallCycleRec = calc.getCallCycleRec(selectedYear, selectedCallCycle, null);            
            if(selectedCallCycleRec == null) {            
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Call Cycle Record not found for '+selectedCallCycle+', '+selectedYear));
                messageSeverity = ApexPages.Severity.ERROR.name();
                messageSummary = 'Call Cycle Record not found for '+selectedCallCycle+', '+selectedYear;
            }            
        } catch(Exception e) {          
            if(!ApexPages.hasMessages()) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Call Cycle Record not found for '+selectedCallCycle+', '+selectedYear));
                messageSeverity = ApexPages.Severity.ERROR.name();
                messageSummary = 'Call Cycle Record not found for '+selectedCallCycle+', '+selectedYear;        
            }         
        }        
    }*/
    
    private void refreshObjectiveStats() {
        System.debug('x2 - refreshObjectiveStats');
        Integer currentPage = setCon.getPageNumber();
        setCon.setPageNumber(1);
        Set<Id> accountIdSet = new Set<Id>(); 
        while (true) {          
            for(Account accObj : (List<Account>)setCon.getRecords()) {
                accountIdSet.add(accObj.Id); 
            }           
            if(setCon.getHasNext()) {               
                setCon.next();  
            } else {
                break;
            }
        }       
        setCon.setPageNumber(currentPage);

	    allocatedStats = new Map<String, Integer>();
	    pendingStats = new Map<String, Integer>();
	    executedStats = new Map<String, Integer>();
	    declinedStats = new Map<String, Integer>();

        for(Id objective : currentObjectivesMap.keySet()) {
	        allocatedStats.put(objective, 0);
	        pendingStats.put(objective, 0);
	        executedStats.put(objective, 0);
	        declinedStats.put(objective, 0);
        }

	    for (AggregateResult ar : [
		    SELECT COUNT(Id) taskCount, Objective_Id__c, Status
		    FROM Task
		    WHERE Status IN :pickHelper.getTaskStatusValues()
		    AND RecordTypeId =: getRecordTypeId('Task', 'Objective')
		    AND WhatId IN : accountIdSet
		    AND Objective_Id__c IN : currentObjectivesMap.keySet()
		    GROUP BY Objective_Id__c, Status
	    ]) {
		    String status = (String)ar.get('Status');
		    Integer taskCount = (Integer)ar.get('taskCount');

		    if (status == 'Allocated' || status == 'Re- Allocated')
			    allocatedStats.put((Id)ar.get('Objective_Id__c'), allocatedStats.get((Id)ar.get('Objective_Id__c')) + taskCount);

		    if (status == 'Presented - Waiting on Response' || status == 'Sold In')
			    pendingStats.put((Id)ar.get('Objective_Id__c'), pendingStats.get((Id)ar.get('Objective_Id__c')) + taskCount);

		    if (status.contains('Executed'))
			    executedStats.put((Id)ar.get('Objective_Id__c'), executedStats.get((Id)ar.get('Objective_Id__c')) + taskCount);

		    if (status == 'Presented - Customer Declined')
			    declinedStats.put((Id)ar.get('Objective_Id__c'), declinedStats.get((Id)ar.get('Objective_Id__c')) + taskCount);
	    }

        statsMap = getStats();
        for(Id  key : currentObjectivesMap.keyset()){
            if(statsMap.containsKey(key)) {
                if(statsMap.get(key).Total_Allocation__c == null)
                    statsMap.get(key).Total_Allocation__c = 0;
            }
        }
        //**************************************************** */
        //
        //**************************************************** */
         noOfObjExecuted.clear();
         noOfObjAllocReallocPending.clear();

         for(Id  key : currentObjectivesMap.keyset()){
             noOfObjAllocReallocPending.put(key, 0);
             noOfObjExecuted.put(key, 0);
         }
         if(duration.size() == 2) {
             String TestStatus;
             List <String>taskStatusList= pickHelper.getTaskStatusValues();
             for(AggregateResult ar : [SELECT count(id) taskCount, Objective_Id__c, status
                                         FROM Task
                                         WHERE Status IN : taskStatusList
                                         AND RecordTypeId =: getRecordTypeId('Task', 'Objective')
                                         AND WhatId IN : accountIdSet
                                         AND Objective_Id__c IN : currentObjectivesMap.keyset()
                                         GROUP BY Objective_Id__c, status]) {
                                             TestStatus=(String)ar.get('status');
                                             system.debug('TestStatus '+TestStatus);

                 //Checking if Status is'Executed __' type
                     if (TestStatus.contains('Executed') ){

                         if(noOfObjExecuted.get((Id)ar.get('Objective_Id__c'))==null){
                             noOfObjExecuted.put((Id)ar.get('Objective_Id__c'),(Integer)ar.get('taskCount'));
                         }
                         else{
                             Integer execTaskCount= noOfObjExecuted.get((Id)ar.get('Objective_Id__c'));
                             noOfObjExecuted.put((Id)ar.get('Objective_Id__c'), execTaskCount + (Integer)ar.get('taskCount'));
                         }
                         //****************************************
                     }else {
                     if (noOfObjAllocReallocPending.get((Id)ar.get('Objective_Id__c')) == null) {
                         noOfObjAllocReallocPending.put((Id)ar.get('Objective_Id__c'),(Integer)ar.get('taskCount'));
                     } else {
                         Integer currentTaskCount = noOfObjAllocReallocPending.get((Id)ar.get('Objective_Id__c'));
                         noOfObjAllocReallocPending.put((Id)ar.get('Objective_Id__c'),currentTaskCount + (Integer)ar.get('taskCount'));
                     }
                 }
             }
             system.debug('Number of object executed======  '+ noOfObjExecuted);
         }
         statsMap = getStats();
         for(Id  key : currentObjectivesMap.keyset()){
             if(statsMap.containsKey(key)) {
                 if(statsMap.get(key).Total_Allocation__c == null)
                     statsMap.get(key).Total_Allocation__c = 0;

                 if(noOfObjExecuted.containsKey(key) && statsMap.get(key).Total_Allocation__c > 0) {
                     noOfObjRemaining.put(key, (Integer) statsMap.get(key).Total_Allocation__c - noOfObjExecuted.get(key));
                 } else {
                     noOfObjRemaining.put(key, (Integer) statsMap.get(key).Total_Allocation__c );
                 }
             }
         }
    }    
       
    @RemoteAction
    public static List<Task> addRemoteTasks(String accId, String objectiveId, String objectiveName, 
                                            String priorityKpi, String existingTask) {
        
        String categoryOfObjective = '';                                 
                                                
        Task newTask = null;
        DayDateWeekCalculator calc = new DayDateWeekCalculator('australia'); 
        Call_Cycle__c selectedCallCycleRec = null;

        List<Objective__c> objectiveRec = [select id, Name, Objective_Task_Name__c,Start_Date__c, End_Date__c, Category_of_Objective__c from Objective__c where ID =:objectiveId];

        if(String.isBlank(objectiveName) == true && objectiveRec.size() > 0){
            objectiveName = objectiveRec[0].Name;
        }
        
        if(objectiveRec.size() > 0){
            categoryOfObjective = objectiveRec[0].Category_of_Objective__c ;
        }
        
        String bannerGroupId =  String.valueOf([SELECT Id,Name,Banner_Group__c FROM Account WHERE Id = :accId].Banner_Group__c);
        string taskRecordTypeId ;
        Id recordTypeExist;

         
        Map<String, Schema.RecordTypeInfo> recordTypes = Schema.SObjectType.Task.getRecordTypeInfosByName();

        if(!String.isblank(categoryOfObjective)){
            RecordTypeInfo info = SObjectType.Task.getRecordTypeInfosByName().get('Objective - ' + categoryOfObjective);
            
           	if(info != null)
                taskRecordTypeId = info.getRecordTypeId();
            	else
                	taskRecordTypeId = Utilities.getRecordTypeId('Task', 'Objective'); 
        } else
            taskRecordTypeId = Utilities.getRecordTypeId('Task', 'Objective');   
        
        List<Date> duration = calc.getWeekDuration('All', selectedCallCycleRec); 
        
        newTask = new Task();
		if(!String.isEmpty(objectiveRec[0].Objective_Task_Name__c)){
			newTask.subject = objectiveRec[0].Objective_Task_Name__c;
		}else{
			newTask.subject = 'OBJ: ' + objectiveName ;
		}
       
        newTask.activitydate = objectiveRec[0].End_Date__c;
        newTask.whatid = accId;
        newTask.objective_id__c = objectiveId;
        newTask.recordtypeid = taskRecordTypeId;
        newTask.objective_name__c = objectiveName;
        newTask.priority_kpi__c = priorityKpi;
        newTask.status = 'Allocated';
            
        insert newTask;              
  
        List<Task> taskList = [Select id, whatid, objective_id__c, objective_name__c, status, ActivityDate 
                                FROM Task
                                WHERE RecordTypeId =:taskRecordTypeId 
                                    AND WhatId =: accId
                                    AND Objective_Id__c =: objectiveId
                                ORDER BY ActivityDate];
        
        return taskList;
    }
    
    // added by arxxus advantage
    // This methode will give the task record type depending on the bannerGroup as well as objective 
    @TestVisible
    private static string getTaskRecordTypeId (String objId,String bannerId){
        map<String,ObjectiveSetting__c> mapObjectiveIdVsSetting = new  map<String,ObjectiveSetting__c>();
        map<String,BannerGroupSetting__c> mapBannerGroupIdVsSetting = new  map<String,BannerGroupSetting__c>();
        string taskRecordTypeId ;
        
        for(ObjectiveSetting__c  obj : ObjectiveSetting__c.getAll().Values()){
            mapObjectiveIdVsSetting.put(String.valueOf(obj.get('Objective_Id__c')),obj);            
        } 
        
        for(BannerGroupSetting__c  obj : BannerGroupSetting__c.getAll().Values()){
            mapBannerGroupIdVsSetting.put(String.valueOf(obj.get('name')),obj);            
        }
         
        if(mapObjectiveIdVsSetting.containsKey(objId)){
            /*If the Objective Id is as per the Custom Setting, then assign ObjectiveSpritz record type to the Task*/
            /*@modified On: 01/12/2016
            * @Case No: 00019575
            * @author: Abhishek M. (Arxxus)
            */
            If(mapObjectiveIdVsSetting.get(objId).Objective_Id__c == objId){
                Id devRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Objective - Spritz Summer Preview').getRecordTypeId();
                taskRecordTypeId = devRecordTypeId;
            }
        }else if(mapObjectiveIdVsSetting.containsKey(objId) && mapBannerGroupIdVsSetting.containsKey(bannerId)){
            if( String.valueOf(mapObjectiveIdVsSetting.get(objId).Objective_Banner_Group_Id_No__c) == string.valueOf(mapBannerGroupIdVsSetting.get(bannerId).Banner_Group_Id_No__c) ){
                taskRecordTypeId = mapBannerGroupIdVsSetting.get(bannerId).Task_Record_Type_Id__c;    
            }else{
                taskRecordTypeId = Utilities.getRecordTypeId('Task', 'Objective');
            }
        }else{
            taskRecordTypeId = Utilities.getRecordTypeId('Task', 'Objective');  
        }
        
        return taskRecordTypeId;   
    }
    
    @RemoteAction
    public static List<Task> addAllRemoteTasks(String selectedGrading, String selectedBanerGroup, String objectiveId, String objectiveName, 
                                               String priorityKpi, String searchAccountName, boolean isCalledOnCheck) {     
        String recordIdOutlet =  Utilities.getRecordTypeId('Account', 'Outlet');
        String userId = UserInfo.getUserId();
        
        String  query = 'Select id, Volume_9LE_LY__c from Account where RecordTypeId =: recordIdOutlet  and OwnerId =: userId';
        if(selectedBanerGroup != 'All') {           
            query += ' and Banner_Group__r.Parent_Hierarchy__c LIKE '+'\'%,'+ selectedBanerGroup +',%\'' ;
        }
        if(selectedGrading  != 'All') {
            query += ' and Account_Grading__c =: selectedGrading ';         
        }        
        
        if (null != searchAccountName && searchAccountName.length() > 0) 
            query += ' and Name LIKE \'%' + searchAccountName + '%\'';
                                                   
		if (isCalledOnCheck == true ) 
            query += ' and Called_On__c =: isCalledOnCheck ';                                                   
        
        query += ' and Active__c =: activeStatus  Order by LastModifiedDate DESC LIMIT 2000';  
        
        List<Objective__c> objectiveRec = [select id, Start_Date__c, Objective_Task_Name__c,End_Date__c from Objective__c where ID =:objectiveId];

        ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(Database.getQueryLocator(query));
        setCon.setPageSize(100); 

        DayDateWeekCalculator calc = new DayDateWeekCalculator('australia');
                                                   
                                                   
        Call_Cycle__c selectedCallCycleRec = null;
                                                   
        
        Map<String, Task> tasksMap = new Map<String, Task>();
            
        String objectiveRecordType = Utilities.getRecordTypeId('Task', 'Objective');
        Set<Id> accountIdSet = new Set<Id>(); 
        Task newTask = null;
        while (true) {      
            for(Account accObj : (List<Account>)setCon.getRecords()) {
                accountIdSet.add(accObj.Id);
                newTask = new Task();               
                
                if(!String.isEmpty(objectiveRec[0].Objective_Task_Name__c)){
			        newTask.subject = objectiveRec[0].Objective_Task_Name__c;
				}else{
					newTask.subject = 'OBJ: ' + objectiveName ;
				}
				
				newTask.activitydate = objectiveRec[0].End_Date__c;
                newTask.whatid = accObj.Id;
                newTask.objective_id__c = objectiveId;
                newTask.objective_setting__c = objectiveId;
                newTask.recordtypeid = objectiveRecordType;
                newTask.objective_name__c = objectiveName;
                newTask.priority_kpi__c = priorityKpi;
                newTask.status = 'Allocated';
                //newTask.CreatedById = 'userid';
                
                tasksMap.put(''+accObj.Id+'-'+objectiveId, newTask);    
            }
            
            if(setCon.getHasNext()) {               
                setCon.next();  
            } else {
                break;
            }
        }
        List<String> existingTasks = new List<String>();
        List<Date> duration = calc.getWeekDuration('All', selectedCallCycleRec);  
        
        if(duration.size() == 2) { 
            for(Task taskRec : [SELECT Id, WhatId, Objective_Id__c  
                                FROM Task
                                WHERE RecordTypeId =: objectiveRecordType
                                    AND priority_kpi__c =: priorityKpi
                                    AND WhatId IN : accountIdSet 
                                    AND Objective_Id__c =: objectiveId]) {   
                existingTasks.add('' + taskRec.WhatId + '-' + taskRec.Objective_Id__c);             
            }        
        }

        for (String accObjId : existingTasks) {
            tasksMap.remove(accObjId);
        }       
        
        list<database.SaveResult> results = database.insert(tasksMap.values());
        
        /***********************Added by Arxxus Advantage for log ***************/
        String body = '<html>'+
                        'Logged In User : '+ UserInfo.getName() + ' Id : ' + UserInfo.getUserId()+'<br/><br/>'+
                        'Account Id Set : '+ accountIdSet +'<br/><br/>'+ 
                        'Objective Id : '+ objectiveId + '<br/><br/>' + 
                        'Objective Name : '+objectiveName + '<br/><br/>';
                        
        String insertedTasks = 'Inserted Tasks ids : ';
        for(database.SaveResult result : results){
        	insertedTasks = insertedTasks +  result.getId() + ' ';                                              
        }
       	
        Email_Configuration__c emailConfig = Email_Configuration__c.getInstance('Objective Management Debug Log');
		list<String> emailIds =   emailConfig.Email_Ids__c.split(',');                                          
        body = body + insertedTasks + '</html>';                                        
        EmailSender.sendMail(emailIds,'Objective Allocated for all the Outlets Debug ' + UserInfo.getName(),body);
        /**************End **************************/  
        return tasksMap.values();
    }
    
   
    
    @RemoteAction
    public static List<String> removeAllRemoteTasks(String selectedGrading, String selectedBanerGroup, 
                                                    String objectiveId, String priorityKpi, String searchAccountName) { 
                
        String recordIdOutlet =  Utilities.getRecordTypeId('Account', 'Outlet');
        String userId = UserInfo.getUserId();
        
        String  query = 'Select id, Volume_9LE_LY__c from Account where RecordTypeId =: recordIdOutlet  and OwnerId =: userId';
        if(selectedBanerGroup != 'All') {           
            query += ' and Banner_Group__r.Parent_Hierarchy__c LIKE '+'\'%,'+ selectedBanerGroup +',%\'' ;
        }
        if(selectedGrading  != 'All') {
            query += ' and Account_Grading__c =: selectedGrading ';         
        }        
        
        if (null != searchAccountName && searchAccountName.length() > 0) 
            query += ' and Name LIKE \'%' + searchAccountName + '%\'';
        
        query += ' and Active__c =: activeStatus  LIMIT 10000';  
        
        ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(Database.getQueryLocator(query));
        setCon.setPageSize(50); 

        DayDateWeekCalculator calc = new DayDateWeekCalculator('australia');
        Call_Cycle__c selectedCallCycleRec = null;
        
           
        String objectiveRecordType = Utilities.getRecordTypeId('Task', 'Objective');
        Set<Id> accountIdSet = new Set<Id>(); 
        while (true) {          
            for(Account accObj : (List<Account>)setCon.getRecords()) {
                accountIdSet.add(accObj.Id);
            }
            
            if(setCon.getHasNext()) {               
                setCon.next();  
            } else {
                break;
            }
        }
        /*
         * DeleteTask list stores element id (html id) of deleted task
         */
        List<String> deletedTask = new List<String>();
        List<Task> tasksToDelete = new List<Task>();
        List<Date> duration = calc.getWeekDuration('All', selectedCallCycleRec);
        Map<String, List<Task>> mapOfTasksToDelete = new Map<String, List<Task>>();
        
        if(duration.size() == 2) { 
            for(Task taskRec : [SELECT Id, WhatId, Objective_Id__c, Status  
                                FROM Task
                                WHERE RecordTypeId =: objectiveRecordType
                                    AND priority_kpi__c =: priorityKpi
                                    AND WhatId IN : accountIdSet 
                                    AND Objective_Id__c =: objectiveId
                                    AND Status != 'Executed'
                                    ORDER BY ActivityDate]) {   
                
                if (mapOfTasksToDelete.get('TaskList-' + taskRec.WhatId + '-' + taskRec.Objective_Id__c) == null) {
                    List<Task> taskList = new List<Task>();
                    mapOfTasksToDelete.put('TaskList-' + taskRec.WhatId + '-' + taskRec.Objective_Id__c, taskList);
                }
                mapOfTasksToDelete.get('TaskList-' + taskRec.WhatId + '-' + taskRec.Objective_Id__c).add(taskRec);              
            }  

            
        }
        
        if (mapOfTasksToDelete.size() > 0) {
            Set<String> mapKey = mapOfTasksToDelete.keySet();           
            Iterator<String> itr = mapKey.iterator();
            String key = null;
            while (itr.hasNext()) {
                key = itr.next();
                List<Task> taskList = mapOfTasksToDelete.get(key);
                /*
                 * Delete oldest non-executed task for given outlet and objective.
                 */
                if (taskList.size() > 0) {
                    tasksToDelete.add(taskList.get(0));
                    deletedTask.add('Task-' + taskList.get(0).WhatId + '-' + taskList.get(0).Objective_Id__c + '-' + taskList.get(0).Id);
                }               
            }           
            if (tasksToDelete.size() > 0) {
                delete tasksToDelete;
            }
        }           
        return deletedTask;
    }
    
    @RemoteAction
    public static List<Task> removeRemoteTasks(String accId, String objectiveId) {                 
        DayDateWeekCalculator calc = new DayDateWeekCalculator('australia');            
        Call_Cycle__c selectedCallCycleRec = null;
       
       
        List<Date> taskduration = calc.getWeekDuration('All', selectedCallCycleRec);
        List<Task> tasksToDelete = [select id, Owner.Firstname, Owner.LastName, Day__c, ActivityDate, Status, Description, WhatId, Subject, Objective_Id__c
                                    from Task 
                                    where RecordTypeId =: getRecordTypeId('Task', 'Objective')  
                                        and WhatId =: accId 
                                        and Objective_Id__c =: objectiveId                                  
                                    Order By ActivityDate];
        
        Integer initialTaskCount = 0;
        if (tasksToDelete != null && tasksToDelete.size() > 0) {
            initialTaskCount = tasksToDelete.size();
            for (Integer i = 0; i < tasksToDelete.size(); i++) {
                if (tasksToDelete[i].status != 'Executed') {
                    delete tasksToDelete[i];
                    tasksToDelete.remove(i);
                    break;
                }
            }           
            if (initialTaskCount == tasksToDelete.size()) {
                tasksToDelete = null;
            }
        } else {
            tasksToDelete = null;
        }           
        return tasksToDelete;
    }    
    
    public PageReference saveStats(){
        System.debug('x1 - saveStats');
        System.debug(statsMap);
        messageSeverity = '';
        messageSummary = '';

        for(Id key : statsMap.keySet()){            
            if(statsMap.get(key).Total_Allocation__c != null && statsMap.get(key).Total_Allocation__c < 0) {           
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Total Allocation cannot be negative'));
                messageSeverity = ApexPages.Severity.ERROR.name();
                messageSummary = 'Total Allocation cannot be negative';
            } else {
                if(noOfObjExecuted.containsKey(key) && statsMap.get(key).Total_Allocation__c > 0) {         
                    noOfObjRemaining.put(key, (Integer) statsMap.get(key).Total_Allocation__c - noOfObjExecuted.get(key));                  
                } else {                
                    noOfObjRemaining.put(key, (Integer) statsMap.get(key).Total_Allocation__c );                    
                } 
            }           
        }
        
        if(ApexPages.hasMessages()) {
            
            return null;            
        } else {
            /*
             * Upsert Objective statistics
             */
            upsert statsMap.values();
        }  
        
        if(!ApexPages.hasMessages()){                
            Integer currentPageNumber = setCon.getPageNumber();
            
            /**
             * Arxxus Advantage : Mapkey not found issue - Assigning global variable instead of local variable
             */
            currentPageNumberSaveStats = currentPageNumber;
            searchAccounts();
                    
            if(currentPageNumber < = totalPages)            
                setCon.setPageNumber(currentPageNumber);          
           
        }       
        return null;
    }

    public PageReference showHide(){        
        return null;    
    }
    
    /*
     * This method calculates the Objectives on basis of selectedYr, selectedCallCycle & selectedPostcode
     */
    private void populateObjectives(){ 
        messageSeverity = '';
        messageSummary = '';
        pickHelper.getObjectivesForObjectMangmt(selectedYear,  currentUser.Region__c, selectedPriorityKpi, selectedObjectiveChannel);
        currentObjectivesMapNew = pickHelper.getCurrentObjectivesMap();

        if( currentObjectivesMapNew.size() == 0 && ! ApexPages.hasMessages()) {                
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Objective Records Not Found'));
            messageSeverity = ApexPages.Severity.ERROR.name();
            messageSummary = 'Objective Records Not Found';
        }   
    }
    
    public PageReference populateNewObjectives(){       
        populateObjectives();          
        displayResults = false;     
        return null;        
    }
    
    public List<SelectOption> getPriorityKpi() {
        return pickHelper.getPriorityKPI();
    }
    
    public List <SelectOption> getCallCycles(){        
        return pickHelper.getCallCycleAustralia('australia', selectedYear, todaysDate);        
    }
    
    public List <SelectOption> getObjectives(){        
        return pickHelper.getObjectivesForObjectMangmt(selectedYear, currentUser.Region__c, selectedPriorityKpi, selectedObjectiveChannel);        
    }
    
    public List <SelectOption> getOutlets(){        
        return pickHelper.getOutlets(UserInfo.getUserId(), currentUser.UserRoleId);        
    }
    
    public List <SelectOption> getBannerGroups(){        
        return pickHelper.getBannerGroups();        
    }

    public List <SelectOption> getGradings(){        
        return pickHelper.getGradings();        
    }
    
    public List <SelectOption> getYears(){        
        return pickHelper.getYears();        
    }
    
    public List <SelectOption> getTaskStatus(){     
        return pickHelper.getTaskStatusObjective();     
    }

    public List <SelectOption> getAccountChannels(){     
        return pickHelper.getAccountChannel();     
    }
    
    public List <SelectOption> getnumberOfOutlets(){        
        return pickHelper.getNumberOfOutlets();    
    } 
    
    public Map<Id, Objective__c> getCurrentObjectivesMap(){        
        return currentObjectivesMap;        
    }
    
    public Boolean getDisplayResults(){     
        return displayResults;        
    }
    
    public void reverseSortDirection(){  
        /*
         * If previous sort direction is ascending then set sort direction to descending
         */
//        if(SORT_DIR == SortDirection.ASCENDING) {
//            SORT_DIR = SortDirection.DESCENDING;
//        } else {
//            SORT_DIR = SortDirection.ASCENDING;
//        }
    }
    
    /*
     * sort the Account records on basis of selected sort field 
     */
    public PageReference sortAccount(){

        String currentSortField_temp = valFieldName.get(currentSortField);

	    if (currentSortDirection == 'ASC') {
		    SORT_DIR = SortDirection.ASCENDING ;
	    } else if (currentSortDirection == 'DESC') {
		    SORT_DIR = SortDirection.DESCENDING;
//		    reverseSortDirection();
	    }

//        if(currentSortField_temp == previousSortField) {
//            SORT_DIR = previousSortOrder ;
//            reverseSortDirection();
//        } else {
//            SORT_DIR = SortDirection.ASCENDING ;
//        }
        
        previousSortField = currentSortField_temp;        
        previousSortOrder = SORT_DIR;            
        currentPageNumber = setCon.getPageNumber();     
        return searchAccounts();        
    }    

	public PageReference sortAccountFixed() {
		currentSortDirection = currentSortDirectionFixed;
		currentSortField = currentSortFieldFixed;

		return sortAccount();
	}

    public void countryNotFound(){        
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'User Location not found. This page is available only to Australia users.'));
        messageSeverity = ApexPages.Severity.ERROR.name();
        messageSummary = 'User Location not found. This page is available only to Australia users.';
    }
    
   /*
    * this method sent email to manager when a task has created
    */    
    public PageReference sentMailToManager(){  
        Map<Id,User> mgrMap = null;
        messageSeverity = '';
        messageSummary = '';
        if(currentUser.State_Sales_Manager__c == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Manager has not been defined for ' + currentUser.FirstName + ' ' + currentUser.LastName));
            messageSeverity = ApexPages.Severity.ERROR.name();
            messageSummary = 'Manager has not been defined for ' + currentUser.FirstName + ' ' + currentUser.LastName;          
        } else {            
            try {        
                pickHelper.getObjectivesForObjectMangmt(selectedYear, currentUser.Region__c, selectedPriorityKpi, selectedObjectiveChannel);
                currentObjectivesMapNew = pickHelper.getCurrentObjectivesMap();                
                
                if( currentObjectivesMapNew.size() == 0) {                        
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Objective Records Not Found'));
                    messageSeverity = ApexPages.Severity.ERROR.name();
                    messageSummary = 'Objective Records Not Found';
                }
                
                searchAccounts();
                
                if(!ApexPages.hasMessages()) {     
                    mgrMap = Utilities.getUsers(new Set<Id>{currentUser.State_Sales_Manager__c});                    
                    EmailTemplates et = new EmailTemplates();   
                    String managerName = mgrMap.get(currentUser.State_Sales_Manager__c).FirstName;
                    managerName = managerName.substring(0,1).toUpperCase() + managerName.substring(1);
                    
                    List<String> data = et.submitPlanToManagerForObjctiveMngmt(managerName , UserInfo.getFirstName()+' '+UserInfo.getLastName(),selectedYear,UserInfo.getUserId(), ApexPages.currentPage().getUrl(),null,null,'objective ', selectedObjectiveChannel);
                    (new SendEmail()).sendEmailToUsers(new List<String>{mgrMap.get(currentUser.State_Sales_Manager__c).email}, new List<String>(), 'Objective Management',data[0], data[1]);   
                }
            } catch(Exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Selected Call Cycle Record not found.'));
                messageSeverity = ApexPages.Severity.ERROR.name();
                messageSummary = 'Selected Call Cycle Record not found.';
            }        
        }  
        
        if (!ApexPages.hasMessages()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Mail has been successfully sent to ' + mgrMap.get(currentUser.State_Sales_Manager__c).email));
            messageSeverity = ApexPages.Severity.CONFIRM.name();
            messageSummary = 'Mail has been successfully sent to ' + mgrMap.get(currentUser.State_Sales_Manager__c).email;
        }
        return null;        
    }
    
    private void getDataForExportToExcelOrPdf(){        
        /*
         * Clear existing data
         */     
        accountsListExcel.clear();        
        tasksMapExcel.clear();             
        set <Id> accountIdSet = new set<Id>();
        
        /*
         * In case if export functionality is requested then all accounts (without account name filter criteria) needs to be exported
         * hence pass boolean flag as true for getQueryString parameter
         */
        ApexPages.StandardSetController setCon;
         if(isAllocated == true){
            setCon = new ApexPages.StandardSetController(getAllocatedAccounts(true));
         }else{
            setCon = new ApexPages.StandardSetController(Database.getQueryLocator(getQueryString(true)));
         }
        
        
        while(true){            
            for(Account accObj : (List <Account>)setCon.getRecords()) {            
                accountIdSet.add(accObj.Id);               
                accountsListExcel.add(accObj);
               
                for(Id objId : currentObjectivesMap.keySet()){
                    if (tasksMapExcel.get(''+accObj.Id+'#'+objId) == null) {
                        List<Task> taskList = new List<Task>();
                        tasksMapExcel.put(''+accObj.Id+'#'+objId, taskList);
                    }
                }
            }
            if(setCon.getHasNext()) {               
               setCon.next();               
            } else           
                break;                
        }
        
        List<Date> duration = calc.getWeekDuration('All', selectedCallCycleRec);
        
        if(duration.size() == 2) {        
            if(selectedTaskStatus == 'All') {        
                for(Task taskRec : [select id, Day__c, ActivityDate, Status, Description, WhatId, Subject, Objective_Id__c
                                    from Task
                                    where 
                                    // RecordTypeId =: recordTypeObjectiveId and 
                                    WhatId IN : accountIdSet /*and call_cycle__c = : selectedCallCycle*/  //Changes Related to Case # 00019771
                                    and Objective_Id__c =: objectivesSet]) {
                    
                    tasksMapExcel.get(''+taskRec.WhatId+'#'+taskRec.Objective_Id__c).add(taskRec);
                }           
            } else {                
                for(Task taskRec : [select id, Day__c, ActivityDate, Status, Description, WhatId, Subject, Objective_Id__c
                                    from Task
                                    where 
                                    // RecordTypeId =: recordTypeObjectiveId and
                                    WhatId IN : accountIdSet
                                    and Objective_Id__c =: objectivesSet
                                    and Status=: selectedTaskStatus]) {  
                    tasksMapExcel.get(''+taskRec.WhatId+'#'+taskRec.Objective_Id__c).add(taskRec);
                }               
            }        
        }        
    }
    
    /*
     *This method is using for Export data as excel file
     */
    public pagereference downloadExcel(){        
        getDataForExportToExcelOrPdf();
        refreshObjectiveStats();
        PageReference pg = Page.ObjectiveMgmtExportToExcel;        
        pg.setRedirect(false);
        return pg;        
    }    


    /*
     *This method is using for Export data as excel file
     */
    public pagereference downloadExcelForOutlet(){        
        isAllocated = true;
        getDataForExportToExcelOrPdf();
        refreshObjectiveStats();
        PageReference pg = Page.ObjectiveMgmtExportToExcel;        
        pg.setRedirect(false);
        return pg;        
    }    
    
    /*
     * Find the address information to be displayed. Called when user clicks on home icon on account div
     */
    public pagereference addressInfo(){     
        AccAddress = new Account();     
        PopulateAccountAddress populateAddress = new PopulateAccountAddress();      
        AccAddress = populateAddress.autoPopulateAddress(accAddressId, (list <Account>)setCon.getRecords());
        return null;        
    }
    
    /*
     * Find the Objective Information to be displayed. Called when user clicks on the Objective Link.
     */
    public pagereference objectiveInfo(){        
        if(currentObjectivesMap.containsKey(objectiveIdClicked))            
            objectiveInformation = currentObjectivesMap.get(objectiveIdClicked);        
        else            
            objectiveInformation = new Objective__c();        
        return null;            
    }
    
    public Pagereference home(){        
       return new PageReference('/home/home.jsp');     
    }
}