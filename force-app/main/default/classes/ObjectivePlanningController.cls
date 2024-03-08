/**
 * @author    : Created by Geeta Kushwaha on 2 May, 2013  geeta.kushwaha@arxxus.com
 * @Purpose   : Controller for Page ObjectivePlanning
 * @Criteria  : 
 * @Modified  : Geeta Kushwaha on 3 June, 2013 geeta.kushwaha@arxxus.com
 */
public  class ObjectivePlanningController {
	
	public enum SortDirection {
       
       ASCENDING, DESCENDING
    
    }
	
    private static boolean activeStatus = true;
	
	/*
	 * ObjectivePlanning Page components  
	 */

    private list <SelectOption> years {get; set;}
    
    private list <SelectOption> callCycles {get;set;}
    
    private list <SelectOption> bannerGroups {get;set;}
    
    private list <SelectOption> gradings {get;set;}
    
    private list <SelectOption> outlets {get;set;}
    
    private list <SelectOption> objectives {get;set;}
    
    private list <SelectOption> priorityKpi {get;set;}
    
    private list <SelectOption> taskStatus {get;set;}
    
    private list <SelectOption> numberOfOutlets {get;set;}
    
    public String selectedYear {get; set;}
    
    public String selectedCallCycle {get; set;}
    
    public String selectedBanerGroup {get; set;}
    
    public String selectedGrading {get; set;}
    
    public String selectedOutlet {get; set;}
    
    public String selectedObjective {get; set;}
    
    public String selectedPriorityKpi {get; set;}
    
    public String selectedTaskStatus {get; set;}
    
    public boolean displayAddButton {get; set;}
    
    private boolean displayResults {get; set;}
    
    /*
     * Show/Hide
     */
    
    public boolean bannerGrpFlag {get; set;}
    
    public boolean cityFlag {get; set;}
    
    public boolean gradingFlag {get; set;}
    
    public boolean volumeFlag {get; set;}
    
    public boolean postCodeFlag {get; set;}
    
    /*
     * For Sorting of Account Records
     */
        
    public String currentSortField {get; set;}
        
    public SortDirection previousSortOrder {get; set;}
    
    public String previousSortField {get; set;}
    
    private SortDirection SORT_DIR; /* Current Sort Direction */
    
    public boolean taskAddedDeleted {get;set;}
    
    public boolean clear {get;set;}
    
    private transient integer currentPageNumber;
     
    private map<String, String> valFieldName = new map<String,String>{'Outlet' => 'name',
						                                              'BannerGroup' => 'Banner_Group_Name__c',
						                                              'City' => 'BillingCity',
						                                              'Volume' => 'Volume__c', 
						                                              'Grading' => 'Account_Grading__c',
						                                              'postCode' => 'BillingPostalCode'};
						                                              
    /*
     * Export to Excel & send mail to Mgr
     */
    public list <Account> accountsListExcel {get; set;}
    
    public map<String,list<Task>> tasksMapExcel {get; set;} // Account.Id#Outlet.Id -> Task
    
    public map <Id,Objective_Statistics__c> statsMapExcel {get; set;}						                                              
    
    /*
     * Helper components
     */
    
    public Date todaysDate {get; set;}
    
    private PicklistHelper pickHelper ;
    
    private DayDateWeekCalculator calc ;
    
    private Call_Cycle__c selectedCallCycleRec {get; set;}
    
    private Call_Cycle__c currentCallCycle {get; set;}
    
    public boolean countryFound {get; set;}
    
    public User currentUser {get; set;}
    
    private Id recordTypeObjectiveId;
    
    private Set <Id> objectivesSet;
    
    private list <date> duration;
    
    /*
     * Add/Remove tasks
     */
     
    public Id accId {get; set;} 
    
    public Id objectiveId {get; set;}
       
    private map <String,Task> insertTaskMap {get; set;}
    
    private map <String,Task> deleteTaskMap {get; set;}
    
    /*
     * All Tasks to be displayed on Calendar
     */
    
    public map<String,list<Task>> tasksMap {get; set;} // Account.Id#Outlet.Id -> Task
    
    public map<String, Integer> noOfObjAllocReallocPending {get; set;}
    
    public map<String, Integer> noOfObjExecuted{get; set;}
    
    public map<String, Integer> noOfObjRemaining {get; set;}
    
    private map<Id,Objective__c> currentObjectivesMap {get; set;}
    
    private map<Id,Objective__c> currentObjectivesMapNew {get; set;}
    
    private List <String> recordTypeAccountList {get; set;}
    
    public map <Id,Objective_Statistics__c> statsMap {get; set;}
    
    private map<Id, String> accountNamesCurrentPageMap {get; set;}
    
    public list <Id> sortedObjectivesList {get; set;}
    
    /*
     * Pagination of Account Records
     */
    private String query {get; set;}
    
    public ApexPages.StandardSetController setCon {get; set;}  
    
    public Integer noOfRecords{get; set;}
    
    public Integer size{get;set;}
    
    public String recordsPerPage {get; set;}
    
    public list <Account> accounts { get; set;}
    
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
	 * Display Call Visit Task on click of + button
	 */
	private Id callVisit {get;set;}
	
	public list <Task> taskList {get; set;}
	
	public String selectedTask {get;set;}
    
    /*
     * Constructor
     */    
    public ObjectivePlanningController(){
    	
    	recordTypeObjectiveId = Utilities.getRecordTypeId('Task', 'Objective');
        
        pickHelper = new PicklistHelper();
        
        todaysDate = date.today();
        
        if(Test.isRunningTest())
        
            todaysDate = date.newInstance(2013,6,6);
        
        sortedObjectivesList = new list<Id>();
        
        duration = new list <date>(); 
    	
    	/*
         * If url for Call Planning has been received by email,
         * Then autopopulate the filters
         * Australia - Call Cycle & Yr      
         */
    	
    	Map<String, String> parameterMap = ApexPages.currentPage().getParameters();

        if(parameterMap.containsKey('scc')) {
            
            selectedCallCycle = parameterMap.get('scc');
            
        }
        
        if(parameterMap.containsKey('yr')){
            
            selectedYear = parameterMap.get('yr');
            
        }
        
        if(parameterMap.containsKey('uId')){
            
            selectedOutlet = parameterMap.get('uId');
            
        }
        
        /*
         * Export to Excel
         */ 
    	accountsListExcel = new list<Account>();
        
        tasksMapExcel = new map<String, list<Task>>();      
        
        statsMapExcel = new map <Id,Objective_Statistics__c>();
        
        /*
         * Data to be displayed, added or deleted
         */
    	objectivesSet = new set<Id>();
    	
    	insertTaskMap = new map<String,Task>();
    
        deleteTaskMap = new map<String, Task>();
    	
    	tasksMap = new map<String,list<Task>>();
    	
        noOfObjAllocReallocPending = new map<String, Integer>();
        
        noOfObjExecuted = new map<String, Integer>();
        
        noOfObjRemaining = new map<String, Integer>();
        
        currentObjectivesMap = new map<Id,Objective__c>();
        
        currentObjectivesMapNew = new map<Id,Objective__c>();
        
        accountNamesCurrentPageMap = new map<Id,String>();
        
        /*
         * Get the current user & check for user country. 
         * Get ManagerId for Send Mail to Manager
         * Get UserRoleId for populating the owner picklist 
         */          
        currentUser = [Select id, Region__c, LastName, FirstName, Country, UserRoleId, ManagerId, Manager.FirstName
                       from User
                       where Id =: UserInfo.getUserId()];    
        
        String userLocation = '';
        
        if(currentUser.Country == null) {
            
            countryNotFound();
            
        }  
        
        else {
        	
            /*
             * Ignorecase for country
             * If aus or Australia => australia
             */
            
            userLocation = currentUser.Country.toLowerCase();
            
            if(userLocation == 'aus' || userLocation == 'australia') {
            
                userLocation = 'australia';
                
                countryFound = true;
                
            }    
            
            else {
                
                countryNotFound();
                
            }
            
        }  
        
        calc = new DayDateWeekCalculator(userLocation);
    	
    	/*
    	 * Populate picklists and set default values of picklist
    	 */
    	
    	years = pickHelper.getYears();
    	
    	if(!parameterMap.containsKey('yr'))
    	
    	   selectedYear = '' + todaysDate.year();
    	
    	callCycles = pickHelper.getCallCycleAustralia('australia', selectedYear, todaysDate);
    	
    	if(!parameterMap.containsKey('yr'))
        
           selectedYear = pickHelper.selectedYear;
    	
    	bannerGroups = pickHelper.getBannerGroups();
    	
    	gradings = pickHelper.getGradings();
    	
    	outlets = pickHelper.getOutlets(UserInfo.getUserId(), currentUser.UserRoleId);
    	
    	priorityKpi = pickHelper.getPriorityKPI();
    	
    	taskStatus = pickHelper.getTaskStatusObjective();
    	
    	numberOfOutlets = pickHelper.getNumberOfOutlets();
    	
    	if(callCycles.size() > 1)
    	   
    	   selectedCallCycleRec = pickHelper.getcurrentCallCycle();
    	   
    	else
    	
    	   selectedCallCycleRec = null;   
    	
    	selectedBanerGroup = selectedGrading = selectedObjective = selectedPriorityKpi = selectedTaskStatus = 'All';
    	
    	if(!parameterMap.containsKey('uId'))
        
            selectedOutlet = UserInfo.getUserId();
    	
    	if(selectedCallCycleRec!= null && ! parameterMap.containsKey('scc')) {
    	   
    	   selectedCallCycle = selectedCallCycleRec.Call_Cycle__c;
    	   
    	}
    	
    	currentCallCycle = selectedCallCycleRec;
    	
    	bannerGrpFlag = cityFlag = volumeFlag = postCodeFlag = true;
    	
    	gradingFlag = false;
    	
    	taskAddedDeleted = clear = false;
    	
    	populateObjectives();
    	
    	if(currentObjectivesMapNew != null && currentObjectivesMapNew.size() > 0) {
        
            currentObjectivesMap.putAll(currentObjectivesMapNew);
        
        }
    	
    	/*
    	 * Account record types to be displayed
    	 */
    	
    	recordTypeAccountList = new list<String>();
    	
    	recordTypeAccountList.add(Utilities.getRecordTypeId('Account', 'Outlet')); 
    	
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
    	   
    	/*
		 * Display Call Visit Task on click of + button
		 */
		callVisit = Utilities.getRecordTypeId('Task', 'Call Visit');
		
		taskList = new list <Task>(); 
    	   
    }
    
    public void populateAccounts(){
        
        accountNamesCurrentPageMap.clear();
            
        resetTaskMap();
        	
        accounts = new list<Account>();      
        
        if(setCon != null && !ApexPages.hasMessages()) {
        	
        	displayResults = true;     	
            
            for(Account accObj : (list <Account>)setCon.getRecords()) {
            	
                accounts.add(accObj);
                
                accountNamesCurrentPageMap.put(accObj.Id, accObj.Name);
                
            }
            
            for(Id objectiveId : currentObjectivesMap.keyset()){
            	
            	for(Id accId : accountNamesCurrentPageMap.keyset()) {
            		
            		tasksMap.put(''+accId+'#'+objectiveId, new list<task>());
            		
            	}
            	
            }            
            
            String week = null, taskMapKey = null;
            
            if(selectedTaskStatus == 'All') {
            
	            for(Task taskRec : [select id, Owner.Firstname, Owner.LastName, Day__c, ActivityDate, Status, Description, WhatId, Subject, Objective_Id__c
	                                from Task
	                                where RecordTypeId =: recordTypeObjectiveId
	                                and ActivityDate <=: duration[1] 
	                                and ActivityDate >=: duration[0]
	                                and WhatId IN : accountNamesCurrentPageMap.keyset()
	                                and Objective_Id__c IN : objectivesSet]) {   
	                
	                taskMapKey = ''+taskRec.WhatId+'#'+taskRec.Objective_Id__c;
	                
	                tasksMap.get(taskMapKey).add(taskRec);
	                
	            }
	            
            }
            
            else {
            	
            	for(Task taskRec : [select id, Owner.Firstname, Owner.LastName, Day__c, ActivityDate, Status, Description, WhatId, Subject, Objective_Id__c
                                    from Task
                                    where RecordTypeId =: recordTypeObjectiveId
                                    and ActivityDate <=: duration[1] 
                                    and ActivityDate >=: duration[0]
                                    and WhatId IN : accountNamesCurrentPageMap.keyset()
                                    and Objective_Id__c IN : objectivesSet
                                    and Status =: selectedTaskStatus]) {   
                    
                    taskMapKey = ''+taskRec.WhatId+'#'+taskRec.Objective_Id__c;
                    
                    tasksMap.get(taskMapKey).add(taskRec);
                    
                }
            	
            }
            
            populateUpsertMap();
            
            populateDeleteMap();
	        
        }
    
        else {
        
            if(accounts!=null)
            
                accounts.clear();
                
           totalPages = 0;
           
        }       
        
    }
    
    private map <Id,Objective_Statistics__c> getStats(){
    	
    	map <Id,Objective_Statistics__c> statsMap = new map<Id,Objective_Statistics__c>();
    	
    	for(Objective_Statistics__c stats: [Select id, Total_Allocation__c, Objective__c
                                            from Objective_Statistics__c
                                            where ASM__c =: UserInfo.getUserId()
                                            and Objective__c IN : currentObjectivesMap.keySet()
                                            and Call_Cycle__c =: selectedCallCycle]){
        
           statsMap.put(stats.Objective__c, stats);                                         
                                                
        }
        
        set <Id> remainingObjectives = new set<Id>();
        
        remainingObjectives.addAll(currentObjectivesMap.keySet());
                                               
        remainingObjectives.removeAll(statsMap.keySet());
        
        for(Id objId : remainingObjectives){
            
            statsMap.put(objId, new Objective_Statistics__c(Total_Allocation__c = 0, Objective__c = objId, ASM__c = UserInfo.getUserId()));
            
        }
        
        System.debug('*********************** Returnning Map  '+statsMap.keySet());
        
        return statsMap;
    	
    }
    
    private void getQueryString(){
    	
    	query = 'Select id, Name, Account_Grading__c, Volume__c, BillingStreet, BillingState, BillingCountry, BillingCity,  BillingPostalCode, Banner_Group_Name__c from Account where RecordTypeId IN : recordTypeAccountList ';
	            
        query += ' and OwnerId =: selectedOutlet';    
        
        if(selectedBanerGroup != 'All')
            
            query += ' and Banner_Group__r.Parent_Hierarchy__c LIKE '+'\'%,'+ selectedBanerGroup +',%\'' ;
        
        if(selectedGrading  != 'All')
                
            query += ' and Account_Grading__c =: selectedGrading ';
            
        query += ' and Active__c =: activeStatus';
        
        if(currentSortField != null && valFieldName.containsKey(currentSortField)) {
        
        	query += ' Order By '+valFieldName.get(currentSortField);
        	
        	if(SORT_DIR == SortDirection.ASCENDING){
        		
        		query += ' ASC ';
        		
        	}
        	
        	else {
        		
        		query += ' DESC ';
        		
        	}
        	
        	query += ' NULLS FIRST';
        	
        }
        
        else 
        
            query += ' Order By Name ASC ';
        
        query+= ' LIMIT 10000';
    	
    }
    
    public PageReference searchAccounts()  {  
    	
    	if(insertTaskMap.size() >0 || deleteTaskMap.size() > 0 ){
    	   
    	   taskAddedDeleted = true;
    	   
    	}   
    	   
    	else {
    	
    	   taskAddedDeleted = false;
    	   
    	}   
        
        if(taskAddedDeleted && clear == null)
        
           return null;
        
        else if(taskAddedDeleted && clear != null){
            
                    
            if(clear == false) {
                saveTasks();
                clear = null;
                taskAddedDeleted = false;
            }
            
        } 
        	
    	clear = null;
    
        resetAddRemoveParameters();
        
        sortedObjectivesList.clear();
    
	    insertTaskMap.clear();
	        
	    deleteTaskMap.clear();
	    
	    if(ApexPages.hasMessages())
	    
	      displayResults = false;
	      
	      
	    else
	    
	      displayResults = true;    
        
        getQueryString();     
	            
        try {    
            
            setCon = new ApexPages.StandardSetController(Database.getQueryLocator(query)); 
            
            setCon.setPageSize(Integer.valueOf(recordsPerPage));  
            
            Decimal dtotalPages = (setCon.getResultSize() / setCon.getPageSize());
            
            dtotalPages = Math.floor(dtotalPages) + ((Math.mod(setCon.getResultSize(), Integer.valueOf(recordsPerPage))>0) ? 1 : 0);
            
            totalPages = Integer.valueOf(dtotalPages);
            
            if(currentPageNumber != null && currentPageNumber <= totalPages){
            
               setCon.setPageNumber(currentPageNumber);
               
            }
            
            if(setCon.getResultSize() == 0)
            
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Outlet records not found')); 
            
        }
	        
        catch(QueryException e) {
            
            if(!ApexPages.hasMessages())
                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Records could not be retrieved'));
            
        }
            
        getselectedCallCycleRec(); 
        
        populateObjectives();
        
        if(selectedObjective == 'All')
        
        	sortedObjectivesList = pickHelper.getCurrentObjectivesIdList();
        
        else
            
            sortedObjectivesList.add(selectedObjective);
        
        if(currentObjectivesMapNew != null && currentObjectivesMapNew.size() > 0) {
        
            currentObjectivesMap.clear();
            
            if(selectedObjective == 'All') {
                
                currentObjectivesMap.putAll(currentObjectivesMapNew);
            
            }
            
            else {
                
                 currentObjectivesMap.put(selectedObjective,currentObjectivesMapNew.get(selectedObjective));
                
            }
        
        }
        
        noOfObjAllocReallocPending.clear(); 
        
        noOfObjExecuted.clear();

        noOfObjRemaining.clear();    
        
        for(Id  key : currentObjectivesMap.keyset()){
             
            noOfObjAllocReallocPending.put(key, 0);
            
            noOfObjExecuted.put(key, 0);
            
        }
        
        objectivesSet.clear();
	            
        if(selectedObjective == 'All')
            
            objectivesSet.addAll(currentObjectivesMap.keyset());
            
        else
        
            objectivesSet.add(selectedObjective);
            
        if(selectedCallCycleRec != null && currentCallCycle != null)
                
            displayAddButton = selectedCallCycleRec.Start_Date__c >= currentCallCycle.Start_Date__c;
            
        else
        
            displayAddButton = false;    
            
        duration.clear();    
            
        duration = calc.getWeekDuration('All', selectedCallCycleRec);    
	        
        map <Id, Account> allAccount = new map<Id, Account>();
	        
        while(true){
           
           allAccount.putAll(new map<Id,Account>((list <Account>)setCon.getRecords())); 
            
            if(setCon.getHasNext()) {
               
               setCon.next();
               
           }    
               
           else
           
               break;  
                
        }
	                   
        if(currentPageNumber != null && currentPageNumber <= totalPages){
                
           setCon.setPageNumber(currentPageNumber);
               
        } 

        else
            
            setCon.first();  
	        
        if(duration.size() == 2) {
	        
	        list <AggregateResult> allocReallocPendingAR = [Select count(id) taskCount, Objective_Id__c
	                                                        from Task
	                                                        where Status IN : new list<String>{'Allocated','Re- Allocated','Pending'}
	                                                        and RecordTypeId =: recordTypeObjectiveId
							                                and ActivityDate <=: duration[1] 
							                                and ActivityDate >=: duration[0]
							                                and WhatId IN : allAccount.keyset()
							                                and Objective_Id__c IN : objectivesSet
	                                                        group by Objective_Id__c];
	                                                      
	        for(AggregateResult ar : allocReallocPendingAR) {
	        	
	        	noOfObjAllocReallocPending.put((Id)ar.get('Objective_Id__c'),(Integer)ar.get('taskCount'));
	        	
	        }  
	        
	        list <AggregateResult> noOfObjExecutedAR = [Select count(id) taskCount, Objective_Id__c
	                                                    from Task
	                                                    where Status =: 'Executed'
	                                                    and RecordTypeId =: recordTypeObjectiveId
	                                                    and ActivityDate <=: duration[1] 
	                                                    and ActivityDate >=: duration[0]
	                                                    and WhatId IN : allAccount.keyset()
	                                                    and Objective_Id__c IN : objectivesSet
	                                                    group by Objective_Id__c];
	                                                      
	        for(AggregateResult ar : noOfObjExecutedAR) {
	            
	            noOfObjExecuted.put((Id)ar.get('Objective_Id__c'),(Integer)ar.get('taskCount'));
	            
	        }  
	        
        }  
	        
        /*
         * Populate Number of Allocation
         */
        
        statsMap = getStats();
        
        for(Id  key : currentObjectivesMap.keyset()){

        	if(statsMap.containsKey(key)) {
        		
        		if(statsMap.get(key).Total_Allocation__c == null)
        		
        		  statsMap.get(key).Total_Allocation__c = 0;
        	
	        	if(noOfObjExecuted.containsKey(key)) {
	        
	                noOfObjRemaining.put(key, (Integer) statsMap.get(key).Total_Allocation__c - noOfObjExecuted.get(key));
	                
	        	}
	        	    
	            else {    
	            
	                noOfObjRemaining.put(key, (Integer) statsMap.get(key).Total_Allocation__c );
	                
	            }    
                
        	}   
           
        }                                                
        
        populateAccounts(); 
        
        return null ;  
        
    }  
  
 
    public void first() {
        
        setCon.first();
       
        populateAccounts();
        
    }
  
    public void last() {
        
        setCon.last();
        
        populateAccounts();
        
    }
  
    public void previous() {
        
        setCon.previous();
        
        populateAccounts();
        
    }
  
    public void next() {
        
        setCon.next();
        
        populateAccounts();
    
    }
    
    void getselectedCallCycleRec() {
        
        try {
        
            selectedCallCycleRec = calc.getCallCycleRec(selectedYear, selectedCallCycle, null);
            
            if(selectedCallCycleRec == null) {
            
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Call Cycle Record not found for '+selectedCallCycle+', '+selectedYear));
                              
            }
            
        }
        
        catch(Exception e) {
        	
            if(!ApexPages.hasMessages())
            
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Call Cycle Record not found for '+selectedCallCycle+', '+selectedYear));
                            
        }
        
    }
    
    public void resetTaskMap(){
    	
    	for(String key : tasksMap.keyset()){
    	   
    	   tasksMap.get(key).clear();
    		
    	}
    	
    	tasksMap.clear();
    	
    }
    
    void populateTaskMap(){
    	
    	set <Id> accountIdSet = new set<Id>();
    	
    	for(Account accObj : (list <Account>)setCon.getRecords()) {
            
           accountIdSet.add(accObj.Id);
           
           tasksMap.put(''+accObj.Id+'#'+objectiveId, new list<task>());
                
        }
        
        list <date> duration = calc.getWeekDuration('All', selectedCallCycleRec);
        
        if(duration.size() == 2) {
        
	        for(Task taskRec : [select id, Owner.Firstname, Owner.LastName, Day__c, ActivityDate, Status, Description, WhatId, Subject, Objective_Id__c
	                            from Task
	                            where RecordTypeId =: recordTypeObjectiveId
	                            and ActivityDate <=: duration[1] 
	                            and ActivityDate >=: duration[0]
	                            and WhatId IN : accountIdSet
	                            and Objective_Id__c =: objectiveId]) {
	 
	            String taskMapKey = ''+taskRec.WhatId+'#'+taskRec.Objective_Id__c;
	            
	            tasksMap.get(taskMapKey).add(taskRec);
	            
	        }
        
        }
    	
    }
    
    void populateUpsertMap(){
    	
    	for(String key : insertTaskMap.keySet()) {
    		
    		if(tasksMap.containsKey(key) && tasksMap.get(key).size() == 0) {
    			
    			tasksMap.put(key,new list<Task>{insertTaskMap.get(key)});
    			
    		}
    		
    	}
    	
    }
    
    void populateDeleteMap(){
        
        for(String key : deleteTaskMap.keySet()) {
            
            if(tasksMap.containsKey(key) && tasksMap.get(key).size() > 0) {
                
                tasksMap.put(key,new list<Task>());
                
            }
            
        }
        
    }
    
    public PageReference addAllTasks(){
    	
        Integer currentPageNumber = setCon.getPageNumber();
        
        if(currentPageNumber != 1) {
            
            setCon.setPageNumber(1);
            
            setCon.first();
            
            populateTaskMap();
            
            populateDeleteMap();
        
        }
        
        String key ;

        while(true){
           
           for(Account acc : (list <Account>)setCon.getRecords()) {
                
                key = ''+acc.Id+'#'+objectiveId;
               
                if(tasksMap.containsKey(key) && tasksMap.get(key).size() == 0) {
                   
                    Task newTask = new Task();
                    
                    newTask.Subject = 'OBJ: '+currentObjectivesMap.get(objectiveId).Name+' - CC'+selectedCallCycle.right(1);
                    
                    newTask.ActivityDate = selectedCallCycleRec.End_Date__c;
                    
                    newTask.WhatId = acc.Id;
                    
                    newTask.Objective_Id__c = objectiveId;
                    
                    newTask.Call_Cycle__c = selectedCallCycle;
                    
                    newTask.Objective_Name__c = currentObjectivesMap.get(objectiveId).Name;
                    
                    newTask.RecordTypeId = recordTypeObjectiveId;
                    
                    newTask.Status = 'Allocated';
                    
                    newTask.Priority_KPI__c = currentObjectivesMap.get(objectiveId).Priority_KPI__c;
                   
                    tasksMap.get(key).add(newTask);                   
                    
                    if(deleteTaskMap.containsKey(key)){
                                
                        deleteTaskMap.remove(key);
                        
                        insertTaskMap.remove(key);
                    
                    }       
                    
                    else {
                    	
                    	insertTaskMap.put(key,newTask);
                    	
                    }
               
                }
                
            }
            
            if(setCon.getHasNext()) {
               
               setCon.next();
         
               populateTaskMap();
               
               populateDeleteMap();
               
           }    
               
           else
           
               break;  
                
        }
                   
        setCon.setPageNumber(currentPageNumber);
        
        populateTaskMap();
        
        populateUpsertMap();
        
        populateDeleteMap();
        
        objectiveId = null; 
        
        return null;
        
    }        
    
    public PageReference removeAllTasks(){
    	
    	Integer currentPageNumber = setCon.getPageNumber();
        
        if(currentPageNumber != 1) {
            
            setCon.setPageNumber(1);
            
            setCon.first();
            
            populateTaskMap();
            
            populateUpsertMap();
        
        }
        
        String key ;

        while(true){
           
           for(Account acc : (list <Account>)setCon.getRecords()) {
                
                key = ''+acc.Id+'#'+objectiveId;
               
                if(tasksMap.containsKey(key) && tasksMap.get(key).size() != 0) {
                   
                    Task deleteTask = tasksMap.get(key)[0];
                                                                                 
                    if(deleteTask.Status != 'Executed'){
                        
                         if(insertTaskMap.containsKey(key)){
                                
                            Task t = insertTaskMap.get(key);
                            
                            if(t.Id == null || (''+t.Id) == ''){
                                
                                insertTaskMap.remove(key);
                                
                            }
                            
                            else {
                                
                                insertTaskMap.remove(key);
                                
                                deleteTaskMap.put(key,tasksMap.get(key)[0]);                                
                            
                            }
                            
                        }
                        
                        else {
                        
                            deleteTaskMap.put(key,tasksMap.get(key)[0]);
                        
                        }
                        
                        tasksMap.put(key, new list<Task>());
                    
                    }
               
                }
                
            }
            
            if(setCon.getHasNext()) {
               
               setCon.next();
         
               populateTaskMap();
               
               populateUpsertMap();
               
           }    
               
           else
           
               break;
                
        }        
        	
	    setCon.setPageNumber(currentPageNumber);
	        
	    populateTaskMap();
	    
	    populateUpsertMap();
        
        populateDeleteMap();
        
        objectiveId = null; 
        
        return null;
        
    }
    
    
    public PageReference addTasks(){
    	
    	String key = ''+accId+'#'+objectiveId;
    	
    	Task newTask = new Task();
    	
    	newTask.Subject = 'OBJ: '+currentObjectivesMap.get(objectiveId).Name+' - CC'+selectedCallCycle.right(1);
    	
    	newTask.ActivityDate = selectedCallCycleRec.End_Date__c;
    	/*if(selectedTask == 'New'){
    
	        newTask.ActivityDate = selectedCallCycleRec.End_Date__c;
	        
	    }
	    else {
	    
	        for(Task t : taskList) {
	        
	            if(t.Id == selectedTask) {
	                
	                newTask.ActivityDate = t.ActivityDate;
	                
	                newTask.Call_Visit_Id__c = t.Id;
	                
	                break;
	                
	            }   
	            
	        }
	    }*/
    	
    	newTask.WhatId = accId;
    	
    	newTask.Objective_Id__c = objectiveId;
    	
    	newTask.RecordTypeId = recordTypeObjectiveId;
    	
    	newTask.Objective_Name__c = currentObjectivesMap.get(objectiveId).Name;
    	
    	newTask.Call_Cycle__c = selectedCallCycle;
    	
    	newTask.Priority_KPI__c = currentObjectivesMap.get(objectiveId).Priority_KPI__c;
    	
    	newTask.Status = 'Allocated';    	
    	
    	if(tasksMap.containsKey(key)){
    	
    	   if(tasksMap.get(key).size() > 0)
    	   
    	       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Task already exists. Please update existing task'));
    	   
    	   else{
    	   
    	       tasksMap.get(key).add(newTask);
    	       
    	       insertTaskMap.put(key,newTask);
    	       
    	       deleteTaskMap.remove(key);
    	       
    	   }
    	
    	}
    	
    	else {
    	   
    	   tasksMap.put(key,new list<Task>{newTask});
    	   
    	   insertTaskMap.put(key,newTask);
    	   
    	   deleteTaskMap.remove(key);
    	   
    	}
    	
    	resetAddRemoveParameters();
        
        return null;
        
    }
    
    public PageReference removeTasks(){
    	
    	String key = ''+accId+'#'+objectiveId;
    	
    	if(insertTaskMap.containsKey(key)){
    		
    		Task t = insertTaskMap.get(key);
    		
    		if(t.Id == null || (''+t.Id) == ''){
    			
	    		insertTaskMap.remove(key);
	    		
	    		tasksMap.put(key, new list<Task>());
	    		
    		}
    		
    		else {
    			
    			insertTaskMap.remove(key);
    			
    			deleteTaskMap.put(key,tasksMap.get(key)[0]);
            
                tasksMap.put(key, new list<Task>());
    			
    		
    		}
    		
    	}
    	
    	else {
    		
    	   if(tasksMap.get(key).size() == 0) {
    	   
    	       	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'No tasks exists'));
    	       	
    	   }
    	   
    	   else if(tasksMap.get(key)[0].Status == 'Executed') {
    	   	
    	   	   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Cannot delete executed objective tasks'));
    	   	
    	   }
    	   
    	   else {

	    	   deleteTaskMap.put(key,tasksMap.get(key)[0]);
	    	   
	    	   tasksMap.put(key, new list<Task>());
	    	   
	    	   insertTaskMap.remove(key);
    	   
    	   }
    	
    	}
    	
    	resetAddRemoveParameters();
        
        return null;
        
    }
    
    public PageReference saveTasks(){
    	
    	for(Id key : statsMap.KeySet()){
    		
    		if(statsMap.get(key).Total_Allocation__c != null && statsMap.get(key).Total_Allocation__c < 0) {
    			
    			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Total Allocation cannot be negative'));
    			
    		}
    		
    	}
    	
    	if(ApexPages.hasMessages())
    	
    	   return null;
    	   
    	else 
    	
    	   upsert statsMap.values();   
    	
    	integer index = 0;
    	
    	if(insertTaskMap.size() > 0 || deleteTaskMap.size() > 0) {
    	
	    	if(deleteTaskMap.size() > 0){
	            
	            index = 0;
	            
	            list <Task> deleteTaskList = new list<Task>();
	            
	            deleteTaskList.addAll(deleteTaskMap.values());
	            
	            Database.DeleteResult[] results = database.delete(deleteTaskList, false); // allow partial success    
	            
	            for (Database.DeleteResult result : results) {
	            
	                if (result.isSuccess()) {
	                    
	                    deleteTaskMap.remove(''+deleteTaskList[index].WhatId+'#'+deleteTaskList[index].Objective_Id__c);
	                    
	                }
	                
	                else{
	                	
	                	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Task could not be deleted for : '+currentObjectivesMap.get(deleteTaskList[index].Objective_Id__c).Name));
	                	
	                }
	                
	                index ++;
	                
	            } 
	            
	        }
	    	
	    	if(insertTaskMap.size() > 0) {
	    		
	    		index = 0;
	    		
		    	list <Task> insertTaskList = new list<Task>();
		    	
		    	insertTaskList.addAll(insertTaskMap.values());
		    	
		    	Database.SaveResult[] results = database.insert(insertTaskList, false); // allow partial success    
	            
	            for (Database.SaveResult result : results) {
	            
	                if (result.isSuccess()) {
	                    
	                    insertTaskMap.remove(''+insertTaskList[index].WhatId+'#'+insertTaskList[index].Objective_Id__c);
	                    
	                }
	                
	                else {
	                	
	                	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Task could not be created for : '+currentObjectivesMap.get(insertTaskList[index].Objective_Id__c).Name));
	                	
	                }
	                
	                index ++;
	                
	            }  
		    	
	    	}
    	
    		//updateTargetAchieved(currentObjectivesMap.keySet(), recordTypeObjectiveId);
    		
    	}
    	
    	if(!ApexPages.hasMessages()){
		    	
	        Integer currentPageNumber = setCon.getPageNumber();
	        
	        searchAccounts();
	                
	        if(currentPageNumber < = totalPages)
	        
	           setCon.setPageNumber(currentPageNumber);	        
        
            populateAccounts();
        	
        }
    	
    	return null;
    	
    }
    
    
    /*public static void updateTargetAchieved(set <Id> objectivesForFutureCall, Id recordType){
    	
    	TargetAchievedOnObjective.updateTargetAchieved(objectivesForFutureCall, recordType);
    	
    }*/
    
    public PageReference cancel(){
    	
    	insertTaskMap.clear();
    	
    	deleteTaskMap.clear();
    	
    	statsMap.clear();
        
        searchAccounts();

        return null;
        
    }

    public PageReference showHide(){
        
        return null;
    
    }
    
    private void resetAddRemoveParameters(){
    	
    	accId = null;
        
        objectiveId = null;
    	
    }
    
    /*
     * This method calculates the Objectives on basis of selectedYr, selectedCallCycle & selectedPostcode
     */
    private void populateObjectives(){
    	
    	objectives = pickHelper.getObjectives(selectedYear, selectedCallCycle, currentUser.Region__c, selectedPriorityKpi);
        
        currentObjectivesMapNew = pickHelper.getCurrentObjectivesMap();
        
        if( currentObjectivesMapNew.size() == 0 && ! ApexPages.hasMessages()) {
                
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Objective Records Not Found'));
              
        }
    	
    }
    
    public PageReference populateNewObjectives(){
    	
    	populateObjectives();
    	   
    	displayResults = false;   
    	
    	return null;
    	
    }
    
    public list <SelectOption> getCallCycles(){
        
        return callCycles;
        
    }
    
    public list <SelectOption> getObjectives(){
        
        return objectives;
        
    }
    
    public list <SelectOption> getOutlets(){
        
        return outlets;
        
    }
    
    public list <SelectOption> getBannerGroups(){
        
        return bannerGroups;
        
    }

    public list <SelectOption> getGradings(){
        
        return gradings;
        
    }
    
    public list <SelectOption> getYears(){
        
        return years;
        
    }
    
    public list <SelectOption> getPriorityKpi(){
        
        return priorityKPI;
        
    }
    
    public list <SelectOption> getTaskStatus(){
    	
    	return taskStatus;
    	
    }
    
    public list <SelectOption> getnumberOfOutlets(){
        
        return numberOfOutlets;
    
    } 
    
    public map<Id, Objective__c> getCurrentObjectivesMap(){
        
        return currentObjectivesMap;
        
    }
    
    public boolean getDisplayResults(){
    	
    	System.debug('***************** getDisplayResults '+displayResults);
        
        return displayResults;
        
    }
    
    public void reverseSortDirection(){
        
        if(SORT_DIR == SortDirection.ASCENDING)
            
            SORT_DIR = SortDirection.DESCENDING;
        
        else
        
            SORT_DIR = SortDirection.ASCENDING;
    
    }
    
    /*
     * sort the Account records on basis of selected sort field 
     */
    public PageReference sortAccount(){
        
        String currentSortField_temp = valFieldName.get(currentSortField);
        
        if(currentSortField_temp == previousSortField) {
                
            SORT_DIR = previousSortOrder ;
                
            reverseSortDirection();
                
        }
            
        else {
                
            SORT_DIR = SortDirection.ASCENDING ;
                
        }
        
        previousSortField = currentSortField_temp;
        
        previousSortOrder = SORT_DIR;    
        
        currentPageNumber = setCon.getPageNumber();   
        
        System.debug('*********************** SORT currentPageNumber '+currentPageNumber);
        
        return searchAccounts();
        
    }    
    
    void countryNotFound(){
        
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'User Location not found. This page is available to users from Australia only.'));
            
        countryFound = false;
        
    }
    
   /*
    * this method sent email to manager when a task has created
    */
    
    public PageReference sentMailToManager(){
    	
    	if( currentUser.ManagerId == null)
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Manager has not been defined'));   
               
        else {       
        	
        	try {
               
                Call_Cycle__c selectedCallCycleRec = calc.getCallCycleRec(selectedYear, selectedCallCycle, null);
                
                //populateNewObjectives();
                
                objectives = pickHelper.getObjectives(selectedYear, selectedCallCycle, currentUser.Region__c, selectedPriorityKpi);
        
                currentObjectivesMapNew = pickHelper.getCurrentObjectivesMap();
                
                if( currentObjectivesMapNew.size() == 0) {
                        
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Objective Records Not Found'));
                      
                }
                
                searchAccounts();
                
                if(!ApexPages.hasMessages()) {
        
		            Map<Id,User> mgrMap = Utilities.getUsers(new set<Id>{currentUser.ManagerId});
		             
			    	EmailTemplates et = new EmailTemplates();
			    	
			    	list <String> data = et.submitPlanToManager(currentUser.Manager.FirstName , UserInfo.getFirstName()+' '+UserInfo.getLastName(),selectedCallCycle,selectedYear,UserInfo.getUserId(), ApexPages.currentPage().getUrl(),null,null,'objective ');
			        
			        (new SendEmail()).sendEmailToUsers(new list<string>{mgrMap.get(currentUser.ManagerId).email}, new list<string>(), 'Objective Management',data[0], data[1]);
                
                }
		        //(new SendEmail()).sendEmailToUsers(new list<string>{'najalin.shaikh@arxxus.com'}, new list<string>(), 'Objective Management',data[0], data[1]);
		        
		    }
            
            catch(Exception e) {
                
                   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Selected Call Cycle Record not found.'));
                
            }
        
        }
        
        return null;
        
    }
    
    private void getDataForExportToExcelOrPdf(){
    	
    	/*
    	 * Clear existing data
    	 */    	
    	accountsListExcel.clear();
        
        tasksMapExcel.clear(); 
        
        statsMapExcel.clear();
        
        statsMapExcel = getStats();
        
        System.debug('*********************** statsMapExcel '+statsMapExcel.keySet());
        
        Integer currentPageNumber = setCon.getPageNumber();

        setCon.setPageNumber(1);
        
        setCon.first();
        
        set <Id> accountIdSet = new set<Id>();

        while(true){
        	
            for(Account accObj : (list <Account>)setCon.getRecords()) {
            
	           accountIdSet.add(accObj.Id);
	           
	           accountsListExcel.add(accObj);
	           
	           for(Id objectiveId : currentObjectivesMap.keySet()){
                
	               tasksMapExcel.put(''+accObj.Id+'#'+objectiveId, new list<task>());
	                
	            }   
	                
	        }        

            if(setCon.getHasNext()) {
               
               setCon.next();
               
           }    
               
           else
           
               break;
                
        }
        
        list <date> duration = calc.getWeekDuration('All', selectedCallCycleRec);
        
        if(duration.size() == 2) {
        
            if(selectedTaskStatus == 'All') {
        
		        for(Task taskRec : [select id, Day__c, ActivityDate, Status, Description, WhatId, Subject, Objective_Id__c
		                            from Task
		                            where RecordTypeId =: recordTypeObjectiveId
		                            and ActivityDate <=: duration[1] 
		                            and ActivityDate >=: duration[0]
		                            and WhatId IN : accountIdSet
		                            and Objective_Id__c =: objectivesSet]) {
		            
		            tasksMapExcel.put(''+taskRec.WhatId+'#'+taskRec.Objective_Id__c, new list<Task>{taskRec});  
		            
		        }
	        
            }
            
            else {
            	
            	for(Task taskRec : [select id, Day__c, ActivityDate, Status, Description, WhatId, Subject, Objective_Id__c
                                    from Task
                                    where RecordTypeId =: recordTypeObjectiveId
                                    and ActivityDate <=: duration[1] 
                                    and ActivityDate >=: duration[0]
                                    and WhatId IN : accountIdSet
                                    and Objective_Id__c =: objectivesSet
                                    and Status=: selectedTaskStatus]) {
                    
                    tasksMapExcel.put(''+taskRec.WhatId+'#'+taskRec.Objective_Id__c, new list<Task>{taskRec});  
                    
                }
            	
            }
        
        }
        
        setCon.setPageNumber(currentPageNumber);
    	
    }
    
    /*
     *This method is using for Export data as excel file
     */
    public pagereference downloadExcel(){
        
        getDataForExportToExcelOrPdf();
        
        PageReference pg = Page.ObjectiveManagementExportToExcel;
        
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
	
	/*
	 * Display Call Visit Task on click of + button
	 */                                              
	public pagereference displayCallPlanningTasks(){
		
		boolean taskOnLastDayOfCallCycleExists = false;
	
	    taskList.clear();
	
	    taskList = [select id, ActivityDate, Subject, Status, Day__c
	                from Task
	                where WhatId =: accId
	                and ActivityDate <=: duration[1] 
	                and ActivityDate >=: duration[0]
	                and RecordTypeId =: callVisit 
	                order by ActivityDate];
	    
	    for(Task t : taskList) {
	    
	        if(t.ActivityDate == duration[1]) {
	        
	            taskOnLastDayOfCallCycleExists = true;
	            
	            break;
	            
	        }
	        
	    }  
	     
	    if(!taskOnLastDayOfCallCycleExists)
	    
	       taskList.add(new Task(ActivityDate = duration[1]));         
	                            
	    return null;
	
	}   
    
}