/**
 * @author    : Created by Geeta Kushwaha on 8 Apr, 2013  geeta.kushwaha@arxxus.com
 * @Purpose   : Controller for Call Visit Plan Page
 * @Criteria  : 
 * @Modified  :  Geeta Kushwaha on 3 June, 2013  geeta.kushwaha@arxxus.com
                 Geeta Kushwaha on 2 July, 2013  geeta.kushwaha@arxxus.com
                 Geeta Kushwaha on 9 Jan, 2013  geeta.kushwaha@arxxus.com Summer Call Cycle fix                 
 */
public with sharing class CallVisitPlanController {

    public String hasNotification {get;  set;}
    
    public String msgNotification {get; set;}
    
    public enum SortDirection {
       
       ASCENDING, DESCENDING
    
    }
    
    public List<String> weekDays {get; set;} 
    
    public List <Default_Call_Cycle__c> defaultCC;
    
    public boolean countryFound {get; set;} 
    
    public date selectedCallCycleRecStart {get; set;}
    
    private DayDateWeekCalculator calc; 
    
    private PicklistHelper pickHelper ;

    public map <String, String> dayLabels {get; set;}
    
     public boolean isCalledOnCheck {get;set;}
    
    /*
     * Following fields are set by actionfunction
     * used for displaying day detail e.g. Mon and for creating event on specific day
     */
   
    public Id accId {get; set;}
     
    public string weekName {get; set;}
    
    public string dayName {get; set;}
    
    public list<boolean> daysCheckBoxList {get; set;}
    
    public String eventDescription {get; set;}
    
    /*
     * All events to be displayed on Calendar
     */
    
    public map<Id, map<String, map<String, list<event>>>> eventsMap {get; set;} // AccId -> Week -> Day -> event
    
    public map<String, boolean> displayAddButton {get; set;}
    
    public map<String, Integer> numberOfCallsMap {get; set;}
    
    public map<String, map<String, Integer>> dayWiseStatsAus {get; set;}
    
    private static final String accPrefix = Utilities.getSalesforceIdPrefix('Account');
    
    /*
     * Create New event
     */    
    private set <event> upserteventSet {get; set;}
    
    /*
     * Delete events
     */
    public list <event> deleteevent;
    
    /*
     * Data to be displayed on VF page
     */
    
    private Call_Cycle__c selectedCallCycleRec;
    
    private Call_Cycle__c currentCallCycle;
    
    private Call_Cycle__c defaultSourceCallCycle;
    
    private Call_Cycle__c defaultDestinationCallCycle;
    
    private String query {get; set;} 
    
    public User currentUser {get; set;}
    
    private List <String> recordTypeAccountList {get; set;}
    
    private list <SelectOption> years {get; set;}
    
    private list <SelectOption> callCycles {get;set;}
    
    private list <SelectOption> weeks {get;set;}
    
    private list <SelectOption> months {get;set;}
    
    private list <SelectOption> outlets {get;set;}
    
    private list <SelectOption> bannerGroups {get;set;}
    
    private list <SelectOption> gradings {get;set;}
    
    private list <SelectOption> postCode {get;set;}
    
    private list <SelectOption> eventStatus {get;set;}
    
    private list <SelectOption> accType {get;set;}
    
    private list <SelectOption> numberOfOutlets {get;set;}
    
    public list <SelectOption> sortby {get;set;} // DK-20181026

    public list <SelectOption> filterby {get;set;} // YB-20190117
    
    public list <SelectOption> sortorder {get;set;} // DK-20181117
    
    public String selectedSortBy {get; set;} // DK-20181026

    public String selectedFilterBy {get; set;} // YB-20190117
    
    public String selectedSortOrder {get; set;} // DK-20181117
    
    public String selectedYear {get; 
        
        set {
            
            selectedYear = value;
            
            showDialog = null;
            
        }
    }
    
    public String selectedCallCycle {get; 
    
        set {
            
            selectedCallCycle = value;
            
            showDialog = null;
            
        }
        
    }
    
    public String selectedWeek {get; set;}
    
    public String selectedMonth {get; set;}
    
    public String selectedOutlet {get; set;}
    
    public String selectedBanerGroup {get; set;}
    
    public String selectedGrading {get; set;}
    
    public String selectedPostcode {get; set;}
    
    public String selectedeventStatus {get; set;}
    
    public String selectedAccType {get; set;}
    
    private list <date> duration;

    private list <String> weeksHeader {get; set;}
    
    private list <String> weeksHeaderOriginal {get; set;}
    
    public Date todaysDate {get; set;}
    
    private map<String, Integer> daysSequenceMap{get; set;}
    
    /*
     * Page view Australia
     */
    public String userLocation {get; set;}
    
    private Id recordTypeClientCallId;
    
    /*
     * For Sorting of Account Records
     */
    public String currentSortField {get; set;}
        
    public SortDirection previousSortOrder {get; set;}
    
    private SortDirection SORT_DIR; /* Current Sort Direction */
    
    public String previousSortField {get; set;}
     
    /*
     * Pagination of Account Records
     */
    public ApexPages.StandardSetController setCon {get; set;}  
    
    Public Integer noOfRecords{get; set;}
    
    Public Integer size{get;set;}
    
    public list <Account> accounts { get; set;}
    
    public Integer totalPages {get; set;}
    
    public String recordsPerPage {get; set;}
    
    /*
     * Clone
     */ 
    public String selectedSourceCallCycleYear {get; set;}
    
    public String selectedSourceCallCycle {get; set;}
    
    public String selectedNewCallCycleYear {get; set;}
    
    public String selectedNewCallCycle {get; set;}
    
    private list <SelectOption> sourceCallCycles {get;set;}
    
    private list <SelectOption> destinationCallCycles {get;set;}
     
    public boolean overrideDefault {get; set;} 
    
    public boolean showDialog {get; set;}
    
    public boolean eventAddedDeleted {get;set;}
    
    public boolean clear {get;set;}  

    /*
     * Load From Template
     */ 

    public String selectedCurrentOrFutureCallCycle {get; set;}
    public String selectedCurrentOrFutureCallCycleLoad {get; set;}

    public list <SelectOption> currentAndFutureCallCycles {get;set;}

    public String selectedOwner {get; set;}
    public String selectedOwnerLoad {get; set;}

    public list <SelectOption> owners {get;set;}
    

     /*
     * Save Template
     */ 

     public String selectedOwnerTemplate {get; set;}

     public String selectedCurrentOrPastCallCycle {get; set;}

     public list <SelectOption> currentAndPastCallCycles {get;set;}

     /*
     * Swap 2 Days 
     */ 

     public String selectedWeekFromDays {get; set;}

     public String selectedWeekToDays {get; set;}

     public String selectedDayFrom {get; set;}

     public String selectedDayTo {get; set;}

     public list <SelectOption> daysOptions {get;set;}


      /*
     * Swap 2 Weeks 
     */ 

     public String selectedWeekTo {get; set;}

     public list <SelectOption> weekOptions {get;set;}

     public String selectedWeekFrom {get; set;}
        
     
    /*
     * Show/Hide
     */
    
    public boolean cityFlag {get; set;}
    public boolean bannerGrpFlag {get; set;}    
    public boolean postCodeFlag {get; set;}
    public boolean volumeFlag {get; set;}
    public boolean volumeLYFlag {get; set;}
    public boolean gradingFlag {get; set;}
    public boolean eventChecked {get; set;}
    public boolean eventUnChecked {get; set;}

    /*
     *Day view
     */
    private list<String>daysHeader;
    
    private list<String>daysHeaderCopy;
    
    public string weekDayname {get;set;}
    
    /*
     *Popup Address Information
     */
    public Account AccAddress {get;set;}
   
    public string accAddressId {get;set;}
    
    /*
     * Export to Excel
     */
    public list <Account> accountsListExcel {get; set;}
    
    public map<Id, map<String, map<String, list<event>>>> eventsMapExcel {get; set;} // AccId -> Week -> Day -> event  
    
    public map<String, Integer> numberOfCallsMapExcel {get; set;}
    
    public map<String, map<String, Integer>> dayWiseStatsAusExcel {get; set;}
    
    private map<String, String> valFieldName = new map<String,String>{'Outlet' => 'name',
                                                                      'BannerGroup' => 'Banner_Group_Name__c',
                                                                      'City' => 'BillingCity',
                                                                      'Volume' => 'Volume__c', 
                                                                      'VolumeLY' => 'Volume_9LE_LY__c', 
                                                                      'Grading' => 'Account_Grading__c', 
                                                                      'postCode' => 'BillingPostalCode'};
    
    private static boolean activeStatus = true;
    
    @TestVisible 
    private transient integer currentPageNumber;
    
    private set <Date> deleteActivityDateSet;
    
    // DK: 20181025
    // search
    public string searchOutlet {get; set;}
    // section display variables
    public boolean displaySectionClone {get; set;}
    public boolean displaySectionFilter {get; set;}
    
    //public class eventWrapper {
    //    public event ev {get; set;}
    //    public Boolean isInMap(String accId, String week){return eventsMap.get(accId).get(week).containskey(ev.Id);}
    //}

    // DK: 20181025
    public void toggleSectionClone() {
        if (displaySectionClone)
            displaySectionClone = false;
        else
            displaySectionClone = true;
    }
    
    public void toggleSectionFilter() {
        if (displaySectionFilter)
            displaySectionFilter = false;
        else
            displaySectionFilter = true;
    }
    
    public CallVisitPlanController() {

        // DK-20181025
        displaySectionClone = false;
        displaySectionFilter = true;
        eventChecked = true;
        eventUnChecked = false;
        
        deleteActivityDateSet = new set<Date>();
        pickHelper = new PicklistHelper();
      	todaysDate = date.today();
        /***********/
        if(test.isRunningTest())
            todaysDate = date.newInstance(2013,6,6);
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
        
        if(parameterMap.containsKey('uId'))
            selectedOutlet = parameterMap.get('uId');
        else 
            selectedOutlet = UserInfo.getUserId();    
        
        if(parameterMap.containsKey('month')){
            selectedMonth = parameterMap.get('month');
        }   
        
        /*
         * Show all columns by default
         */
        cityFlag =  bannerGrpFlag  =  postCodeFlag  =  volumeFlag = volumeLYFlag = true;
        gradingFlag  =  true; // DK-20181026
        
        if(!Test.isRunningTest()){
			isCalledOnCheck = true;
		}
        eventAddedDeleted = clear = null;
        
        /*
         * Initialize the data to be inserted, deleted, events container map, number of calls & display (add button or not) 
         */        
        upserteventSet = new set<event>();  
        deleteevent = new list<event>();
        eventsMap = new map<Id, map<String, map<String, list<event>>>> ();
        numberOfCallsMap = new map<String, Integer>();
        displayAddButton = new map<String, boolean>();
        
        /*
         * Display the days in the order  Mon, .... Sat, Sun
         */        
        daysSequenceMap = new Map<String, Integer>{'Mon' => 1, 'Tue' => 2, 'Wed' => 3, 'Thu' => 4, 'Fri' => 5,'Sat' => 6, 'Sun' => 7 };
        dayLabels = new map<String,String>{'1Mon' => Label.Mon,'2Tue' => Label.Tue, '3Wed' => Label.Wed, '4Thu' => Label.Thu, 
                                           '5Fri' => Label.Fri, '6Sat' => Label.Sat, '7Sun'=> Label.Sun};
        weekDays = new List<String>{'1Mon', '2Tue', '3Wed', '4Thu', '5Fri'}; //, '6Sat', '7Sun'
        daysHeader = new list<String>();
        daysHeaderCopy = new list<String>();
        
        for(String key : daysSequenceMap.keySet()){
            daysHeader.add(''+daysSequenceMap.get(key)+key);
        }
        
        daysHeader.sort();
        
        /*
         * Data structure for checking event has been added to which day or event has to be deleted for which day
         * 0 = Mon, 1 = Tue, 2 = Wed, 4 = Thu, 5 = Fri, 6 = Sat, 7 = Sun
         */        
        daysCheckBoxList = new list<boolean>{false, false, false, false, false, false, false};    
        weeksHeaderOriginal = new list<String>();
        
        /*
         * Get the current user & check for user country. 
         * Get ManagerId for Send Mail to Manager
         * Get UserRoleId for populating the owner picklist 
         */       
        currentUser = [Select id, UserRoleId, LastName, FirstName, Email, Country, ManagerId, Manager.FirstName, Manager.Alias, State_Sales_Manager__c
                       from User
                       where Id =: UserInfo.getUserId()];    
        
        if(currentUser.Country == null || currentUser.Country == '') {
            countryNotFound();
        }  
        else {
            /*
             * Ignorecase for country
             * If aus or Australia = australia
             */
            userLocation = currentUser.Country.toLowerCase();
            if(userLocation == 'aus')
                userLocation = 'australia';
            if(userLocation == 'australia') {
                countryFound = true;
            }    
            else {
                countryNotFound();
            }
            calc = new DayDateWeekCalculator(userLocation);
        }  
        
        /*
         * Years Picklist
         */
         
        years = pickHelper.getYears();
        
        if(!parameterMap.containsKey('yr')) {
            selectedYear = '' + todaysDate.year();
            selectedSourceCallCycleYear = selectedNewCallCycleYear = selectedYear;
        }
        
        /*
         * Call Cycles picklist
         */
        
        callCycles = new list <SelectOption> ();
        
        sourceCallCycles = new list <SelectOption>();
        
        destinationCallCycles = new list <SelectOption>();

        currentAndFutureCallCycles = new list <SelectOption>();

        currentAndPastCallCycles = new list <SelectOption>();

        weekOptions = new list <SelectOption>();
        weekOptions.add(new SelectOption('Week 1','Week 1'));
        weekOptions.add(new SelectOption('Week 2','Week 2'));
        weekOptions.add(new SelectOption('Week 3','Week 3'));
        weekOptions.add(new SelectOption('Week 4','Week 4'));
        weekOptions.add(new SelectOption('Week 5','Week 5'));
        weekOptions.add(new SelectOption('Week 6','Week 6'));
        weekOptions.add(new SelectOption('Week 7','Week 7'));
        weekOptions.add(new SelectOption('Week 8','Week 8'));

        selectedWeekFrom = '';

        daysOptions = new list <SelectOption>();
        daysOptions.add(new SelectOption('Monday','Monday'));
        daysOptions.add(new SelectOption('Tuesday','Tuesday'));
        daysOptions.add(new SelectOption('Wednesday','Wednesday'));
        daysOptions.add(new SelectOption('Thursday','Thursday'));
        daysOptions.add(new SelectOption('Friday','Friday'));
        
        list <Call_Cycle__c> ccList = getCallCyclesForYear('' + todaysDate.year());
        list <Call_Cycle__c> ccListNextYear = getCallCyclesForYear('' + todaysDate.addYears(1).year()); // DK-20181028
        system.debug('=======ccList 1 ====' + ccList); 
        system.debug('=======ccListNextYear  ====' + ccListNextYear);    

        /*
         * Weeks picklist
         */
        weeks = new list <SelectOption> ();
        
        weeks.add(new SelectOption('All',Label.All));
        
        weeksHeader = new list<String>();

        // YB-20190117: START
        filterby = new list <SelectOption> ();
        
        filterby.add(new SelectOption('All','All Outlets'));
        filterby.add(new SelectOption('Planned','Planned'));
        filterby.add(new SelectOption('UnPlanned','UnPlanned'));
        
        
        // DK-20181026: START
        sortby = new list <SelectOption> ();
        
        sortby.add(new SelectOption('Outlet','Outlet'));
        sortby.add(new SelectOption('Grading','Grading'));
        sortby.add(new SelectOption('Volume','Volume'));
        sortby.add(new SelectOption('VolumeLY','Volume LY'));
        sortby.add(new SelectOption('City','City'));
        sortby.add(new SelectOption('postCode','Post Code'));
        sortby.add(new SelectOption('days','Days'));
        
        //sortby.add(new SelectOption('Grading','Grading'));    

        sortorder = new list <SelectOption> ();
        sortorder.add(new SelectOption('ASC','ASC'));
        sortorder.add(new SelectOption('DES','DES'));

        // DK-20181025: Custom setting "Call_Cycle_Filters__c" is used to store previous user's filters and sort selection
        Call_Cycle_Filters__c CCF = Call_Cycle_Filters__c.getInstance(UserInfo.getUserId());
        String prevCallCycle = CCF.Call_Cycle__c;
        Boolean prevCalledOn = CCf.Called_On__c;
        String prevGrading = CCF.Grading__c;
        String prevOwner = CCF.Owner__c;
        String prevStatus = CCF.Status__c;
		String prevYear = CCF.Year__c;
		String prevSortBy = CCF.SortBy__c;
        String prevSortOrder = CCF.SortOrder__c; // DK-20181117
        String prevRecordsPerPage = CCF.Record_Per_Page__c;
        // DK-20181026: END
        
        // DK-20181025: set the sort by to the value that the user previoulsy used 
        if(prevSortBy != null){
            selectedSortBy = currentSortField = prevSortBy;
        } else {
            selectedSortBy = currentSortField = prevSortBy = 'postCode';
        }
        
        selectedSortOrder = prevSortOrder = 'ASC'; // DK-20181117
        if (prevSortOrder == 'DES') 
            SORT_DIR = SortDirection.DESCENDING;
        else 
        	SORT_DIR = SortDirection.ASCENDING;
        /*
         * Grading Picklist
         */               
        
        gradings = pickHelper.getGradings();
        
        /*
         * Outlets picklist
         */
         
        outlets = pickHelper.getOutlets(UserInfo.getUserId(), currentUser.UserRoleId);
        owners = pickHelper.getAllUsers();

        system.debug('##user info ' + UserInfo.getUserId());
        system.debug('##current user role ' + currentUser.UserRoleId);
        system.debug('##outlets ' + outlets);

        selectedOwner = UserInfo.getUserId();
        selectedOwnerLoad = UserInfo.getUserId();
        selectedOwnerTemplate = UserInfo.getUserId();
    
        /*
         * Postcode Picklist
         */ 
        
        postCode = new list <SelectOption> ();
        
        postCode.add(new SelectOption('All', Label.All));
        
        numberOfOutlets = pickHelper.getNumberOfOutlets();
        
        recordTypeAccountList = new list<String>();
        
        if(userLocation == 'australia') {
            
            /*
             * Remove keys Sat & Sun as its not required for Australia
             */ 
             
            daysSequenceMap.remove('Sat');
            
            daysSequenceMap.remove('Sun');            
            
            daysHeader.remove(6); //7Sun
            
            daysHeader.remove(5); //6Sat
            
            recordTypeAccountList.add(Utilities.getRecordTypeId('Account', 'Outlet'));
            
            for(Region__c region : [Select Region_Abbr__c
                                    from Region__c
                                    where Region_Abbr__c != null]){
            
                 postCode.add(new SelectOption(region.Region_Abbr__c,region.Region_Abbr__c));
                                        
            }
            
            selectedBanerGroup = selectedGrading = selectedPostcode = 'All';
            
             /*
              * Banner Group Picklist
              */
            bannerGroups = pickhelper.getBannerGroups();
            
            integer i = 1; // DK-20181028
            integer defaultSourceCallCycleNum;// DK-20181028
            integer ccSize = ccList.size(); // DK-20181028
            
            for(Call_Cycle__c ccRec : ccList) {
                
                if(ccRec.Call_Cycle__c != null){
                
                    callCycles.add(new SelectOption(ccRec.Call_Cycle__c , ccRec.Call_Cycle__c+' ('+ ccRec.Start_Date__c.day()+'/'+ccRec.Start_Date__c.month()+'/'+(ccRec.Start_Date__c.year()-2000)+' - '+ccRec.End_Date__c.day()+'/'+ccRec.End_Date__c.month()+'/'+(ccRec.End_Date__c.year()-2000)+')'));
                    
                    sourceCallCycles.add(new SelectOption(ccRec.Call_Cycle__c , ccRec.Call_Cycle__c+' ('+ ccRec.Start_Date__c.day()+'/'+ccRec.Start_Date__c.month()+'/'+(ccRec.Start_Date__c.year()-2000)+' - '+ccRec.End_Date__c.day()+'/'+ccRec.End_Date__c.month()+'/'+(ccRec.End_Date__c.year()-2000)+')'));
                    
                    destinationCallCycles.add(new SelectOption(ccRec.Call_Cycle__c , ccRec.Call_Cycle__c+' ('+ ccRec.Start_Date__c.day()+'/'+ccRec.Start_Date__c.month()+'/'+(ccRec.Start_Date__c.year()-2000)+' - '+ccRec.End_Date__c.day()+'/'+ccRec.End_Date__c.month()+'/'+(ccRec.End_Date__c.year()-2000)+')'));

                    currentAndPastCallCycles.add(new SelectOption(ccRec.Id , ccRec.Call_Cycle__c+' ('+ ccRec.Start_Date__c.day()+'/'+ccRec.Start_Date__c.month()+'/'+(ccRec.Start_Date__c.year()-2000)+' - '+ccRec.End_Date__c.day()+'/'+ccRec.End_Date__c.month()+'/'+(ccRec.End_Date__c.year()-2000)+')'));

                    if(todaysDate <= ccRec.End_Date__c && todaysDate >= ccRec.Start_Date__c ){
                        
                        currentCallCycle = ccRec;
                        defaultSourceCallCycle = ccRec; // DK-20181026
                        defaultSourceCallCycleNum = i;
                        selectedCurrentOrPastCallCycle = currentCallCycle.Call_Cycle__c;
                    }
                    // DK-20181026: START
                    // set the default destination Call Cycle to the next call cycle
                    if(todaysDate + 40 <= ccRec.End_Date__c && todaysDate + 40 >= ccRec.Start_Date__c ){
                        defaultDestinationCallCycle = ccRec;
                        system.debug('ccRec: ' + ccRec);
                    }                    
                    // DK-20181026: END
                    
                }
                system.debug('=======currentCallCycle loop======' + currentCallCycle);
                i++; // DK-20181028
            }  
            
            // DK-20181028: check if the current call cycle is the last call cycle in a year
            boolean isLastCallCycle = false;
            if (ccSize == defaultSourceCallCycleNum)
                isLastCallCycle = true;
            // DK-20181028: END
            
            if(currentCallCycle == null){
               selectedYear = '' + (todaysDate.addYears(-1).year());
               /* initialize clone section slected yr */
               selectedSourceCallCycleYear = selectedNewCallCycleYear = selectedYear;
               callCycles.clear();
               sourceCallCycles.clear();
               destinationCallCycles.clear();
               for(Call_Cycle__c ccRec : getCallCyclesForYear('' + (todaysDate.addYears(-1).year()))) {
                   callCycles.add(new SelectOption(ccRec.Call_Cycle__c , ccRec.Call_Cycle__c+' ('+ ccRec.Start_Date__c.day()+'/'+ccRec.Start_Date__c.month()+'/'+(ccRec.Start_Date__c.year()-2000)+' - '+ccRec.End_Date__c.day()+'/'+ccRec.End_Date__c.month()+'/'+(ccRec.End_Date__c.year()-2000)+')'));
                   sourceCallCycles.add(new SelectOption(ccRec.Call_Cycle__c , ccRec.Call_Cycle__c+' ('+ ccRec.Start_Date__c.day()+'/'+ccRec.Start_Date__c.month()+'/'+(ccRec.Start_Date__c.year()-2000)+' - '+ccRec.End_Date__c.day()+'/'+ccRec.End_Date__c.month()+'/'+(ccRec.End_Date__c.year()-2000)+')'));
                   destinationCallCycles.add(new SelectOption(ccRec.Call_Cycle__c , ccRec.Call_Cycle__c+' ('+ ccRec.Start_Date__c.day()+'/'+ccRec.Start_Date__c.month()+'/'+(ccRec.Start_Date__c.year()-2000)+' - '+ccRec.End_Date__c.day()+'/'+ccRec.End_Date__c.month()+'/'+(ccRec.End_Date__c.year()-2000)+')'));
                   if(todaysDate <= ccRec.End_Date__c && todaysDate >= ccRec.Start_Date__c ){
                        currentCallCycle = ccRec;
                    }
                    system.debug('=====currentCallCycle loop 4 =======' + currentCallCycle);
               }                     
                                        
                
                if(currentCallCycle == null) {    
                    
                    
                    // YB - 20190103 - Use the reporting start date instead.
                    for(Call_Cycle__c ccRec : ccList) {
                        
                        if(todaysDate < ccRec.Start_Date__c && todaysDate >= ccRec.Reporting_Start_Date__c ){
                            currentCallCycle = ccRec;
                            break;
                            
                        }                            
                    
                    }
                    system.debug('=====currentCallCycle loop 3 =======' + currentCallCycle);
                    
                    selectedYear = '' + todaysDate.year();
                    
                    selectedSourceCallCycleYear = selectedNewCallCycleYear = selectedYear;
               
                    callCycles.clear();
                   
                    sourceCallCycles.clear();
                   
                    destinationCallCycles.clear();
                    
                    for(Call_Cycle__c ccRec : getCallCyclesForYear('' + (todaysDate.year()))) {
                   
                       callCycles.add(new SelectOption(ccRec.Call_Cycle__c , ccRec.Call_Cycle__c+' ('+ ccRec.Start_Date__c.day()+'/'+ccRec.Start_Date__c.month()+'/'+(ccRec.Start_Date__c.year()-2000)+' - '+ccRec.End_Date__c.day()+'/'+ccRec.End_Date__c.month()+'/'+(ccRec.End_Date__c.year()-2000)+')'));
                    
                       sourceCallCycles.add(new SelectOption(ccRec.Call_Cycle__c , ccRec.Call_Cycle__c+' ('+ ccRec.Start_Date__c.day()+'/'+ccRec.Start_Date__c.month()+'/'+(ccRec.Start_Date__c.year()-2000)+' - '+ccRec.End_Date__c.day()+'/'+ccRec.End_Date__c.month()+'/'+(ccRec.End_Date__c.year()-2000)+')'));
                    
                       destinationCallCycles.add(new SelectOption(ccRec.Call_Cycle__c , ccRec.Call_Cycle__c+' ('+ ccRec.Start_Date__c.day()+'/'+ccRec.Start_Date__c.month()+'/'+(ccRec.Start_Date__c.year()-2000)+' - '+ccRec.End_Date__c.day()+'/'+ccRec.End_Date__c.month()+'/'+(ccRec.End_Date__c.year()-2000)+')'));
                    
                   } 
                    
                }
                
            }
            
            if(currentCallCycle != null) {
                
                if(!parameterMap.containsKey('scc'))
                   
                   selectedCallCycle = currentCallCycle.Call_Cycle__c;
                        
                selectedCallCycleRecStart = date.newInstance(currentCallCycle.Start_Date__c.year(), currentCallCycle.Start_Date__c.month(),currentCallCycle.Start_Date__c.day());
                system.debug('### currentCallCycle - line661' + currentCallCycle);

                //Add current call cycle
                currentAndFutureCallCycles.add(new SelectOption(currentCallCycle.Id , currentCallCycle.Call_Cycle__c+' ('+ currentCallCycle.Start_Date__c.day()+'/'+currentCallCycle.Start_Date__c.month()+'/'+(currentCallCycle.Start_Date__c.year()-2000)+' - '+currentCallCycle.End_Date__c.day()+'/'+currentCallCycle.End_Date__c.month()+'/'+(currentCallCycle.End_Date__c.year()-2000)+')'));
            }
            else {
                
                if(!parameterMap.containsKey('scc'))
                   
                   selectedCallCycle = 'Call Cycle 1';
                
                selectedCallCycleRecStart = todaysDate;
                
            }


            //Add future call cycles
            for(Call_Cycle__c futureCallCycle : ccListNextYear){
                if(futureCallCycle.Call_Cycle__c != null){
                    currentAndFutureCallCycles.add(new SelectOption(futureCallCycle.Id , futureCallCycle.Call_Cycle__c+' ('+ futureCallCycle.Start_Date__c.day()+'/'+futureCallCycle.Start_Date__c.month()+'/'+(futureCallCycle.Start_Date__c.year()-2000)+' - '+futureCallCycle.End_Date__c.day()+'/'+futureCallCycle.End_Date__c.month()+'/'+(futureCallCycle.End_Date__c.year()-2000)+')'));
                }
            }

            system.debug('##currentAndFutureCallCycles' + currentAndFutureCallCycles);
            
            // DK-20181026: START
            if(defaultSourceCallCycle != null) {
                selectedSourceCallCycle = defaultSourceCallCycle.Call_Cycle__c;
                selectedSourceCallCycleYear = String.valueOf(defaultSourceCallCycle.Start_Date__c.year());
            }
            
            if(defaultDestinationCallCycle != null) {
                if (!isLastCallCycle) {
                    selectedNewCallCycle = defaultDestinationCallCycle.Call_Cycle__c;
                    selectedNewCallCycleYear = String.valueOf(defaultDestinationCallCycle.Start_Date__c.year());
                }
                else { // set destination call cycle to next year's first call cycle  
                    if (ccListNextYear != null) {
                        selectedNewCallCycle = ccListNextYear[0].Call_Cycle__c;
                        selectedNewCallCycleYear = String.valueOf(ccListNextYear[0].Start_Date__c.year());
                    }
                }
            }
            // DK-20181026: END
            
            
            eventStatus = pickHelper.geteventStatusCallVisit();
            
            recordTypeClientCallId = Utilities.getRecordTypeId('event', 'Visit');
            
            String weekNumber;
            
            if(currentCallCycle != null){
            
                for( integer numWeeks = 1; numWeeks <= (integer) currentCallCycle.Number_Of_Weeks__c; numWeeks++ ) {
                    
                   weekNumber = 'Week ' + numWeeks;
                    
                   weeksHeader.add(weekNumber);
                    
                   weeks.add(new SelectOption(weekNumber,Label.Week+' '+numWeeks)); 
                    
                } 
            
            }            
            
            weeksHeaderOriginal.addAll(weeksHeader);
            
            dayWiseStatsAus = new map<String, map<String, Integer>> ();
            
            dayWiseStatsAusExcel = new map<String, map<String, Integer>> ();
            
            map <String, Integer> weeksHeaderMap, weeksHeaderMapExcel; 
        
            for(String dayName : daysHeader ) {
                
                weeksHeaderMap = new map<String,Integer>();
                
                weeksHeaderMapExcel = new map<String,Integer>();
                
                for(String weekName : weeksHeaderOriginal){
                
                    weeksHeaderMap.put(weekName, 0);
                    
                    weeksHeaderMapExcel.put(weekName, 0);
                    
                }    
            
                dayWiseStatsAus.put(dayName, weeksHeaderMap);
                
                dayWiseStatsAusExcel.put(dayName, weeksHeaderMap);
                   
            }           
            
        }
        
        
        
        daysHeaderCopy.addAll(daysHeader);
        
        selectedWeek = selectedeventStatus = selectedAccType = 'All';
        
        /*
         * Sort
         */        
        previousSortOrder = SortDirection.ASCENDING;
        
        previousSortField = 'Name';
        
        /*
         * Search the accounts to be displayed & the number of records to be displayed
         */
                
        
        recordsPerPage = prevRecordsPerPage; // DK-20181028
        if (prevRecordsPerPage == null)
        	recordsPerPage = '25';	
        
        
        // DK-20181025: restore filter selections from custom settings
        isCalledOnCheck = prevCalledOn;
        selectedOutlet = prevOwner;
        selectedGrading = prevGrading;
        selectedEventStatus = prevStatus;
        //selectedYear = prevYear;
        //selectedCallCycle = prevCallCycle;
        
        searchAccounts();
        
        recalculateWeek();
        
    } 
    
    void getselectedCallCycleRec() {
        try {
            selectedCallCycleRec = calc.getCallCycleRec(selectedYear, selectedCallCycle, selectedMonth);
        }
        
        catch(Exception e) {
            
            if(!ApexPages.hasMessages())
            
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.callcyclerecordnotfound));
            
        }
        
    }
    
    // DK 20181108: Save All Events in table
    public PageReference saveAllEvents() {
        
        //List <event> upserteventList = new List<event>();
        System.debug('======================= Apexpages.currentPage().getParameters().get(\'accountsArray\': ' + Apexpages.currentPage().getParameters().get('accountsArray' ));
        
        list<String> accountIdsList = ( List<String> )JSON.deserialize( Apexpages.currentPage().getParameters().get('accountsArray'), List<string>.class );   
        list<String> weeksList = ( List<String> )JSON.deserialize( Apexpages.currentPage().getParameters().get('weeksArray'), List<string>.class );
        list<String> daysList = ( List<String> )JSON.deserialize( Apexpages.currentPage().getParameters().get('daysArray'), List<string>.class );
        list<String> addOrRemoveList = ( List<String> )JSON.deserialize( Apexpages.currentPage().getParameters().get('addOrRemoveArray'), List<string>.class );
        System.debug('======================= accountIdsList: ' + accountIdsList );
        String accountIdItem;
        String weekItem;
        String dayItem;
        String addOrRemoveItem;
        for (integer i=0; i<accountIdsList.size(); i++) {
            accountIdItem = accountIdsList[i];
            weekItem = weeksList[i];
            dayItem = daysList[i];
            accId = accountIdItem;
            weekName = weekItem;
            addOrRemoveItem = addOrRemoveList[i];
            System.debug('======================= accountIdItem: ' + accountIdItem );
            System.debug('======================= weekItem: ' + weekItem);
            System.debug('======================= weekName: ' + weekName);
            System.debug('======================= dayItem: ' + dayItem );
            System.debug('======================= addOrRemoveItem: ' + addOrRemoveItem );
            integer dayNum = integer.valueof(dayItem.substring(0,1));
            System.debug('======================= dayNum: ' + dayNum  );
            String day = calc.getActivityDay(dayNum);
            System.debug('======================= day: ' + day  );
            
            if (addOrRemoveItem == 'true') {
                
                event newevent = new event();
                newevent.OwnerId = currentUser.Id;
                newevent.Type_of_Call__c = 'Outlet Visit';
                newevent.RecordTypeId = recordTypeClientCallId;
                newevent.Subject = 'CC'+ selectedCallCycle.right(1)+', '+weekName;
                //newevent.Description = eventDescription;
                newevent.WhatId = accountIdItem; //accId;
                newevent.ActivityDate = calc.getActivityDate(dayNum-1,weekName, selectedCallCycleRec.Start_Date__c); //weekName
                newevent.StartDateTime = DateTime.newinstance(calc.getActivityDate(dayNum-1,weekName, selectedCallCycleRec.Start_Date__c), Time.newInstance(17,0,0,0) ); //weekName
                newevent.DurationInMinutes = 90;
                newevent.Day__c = day;
                newevent.Status__c = 'Not Started';
                newevent.IsUnplanned__c = false;
                
                if(newevent.ActivityDate < currentCallCycle.Start_Date__c) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,label.newTaskcannotbecreatedinpast));
                }    
                else {
                    addeventToeventMap(accId,weekItem,newevent.Day__c, newevent);
                    //upsert newevent;
                    upserteventSet.add(newevent);
                    System.debug('======================= newevent: ' + newevent  );
                    System.debug('======================= eventsMap: ' + eventsMap  );
                }
            }
            else {
                if (!eventsMap.isEmpty()){
                    if(eventsMap.containsKey(accId)) {
                        if(eventsMap.get(accId).containsKey(weekName)) {
                            if(eventsMap.get(accId).get(weekName).containsKey( daysSequenceMap.get(day) + day)) {
                                for(event event : eventsMap.get(accId).get(weekName).get( daysSequenceMap.get(day) + day)){
                                    if(event.status__c != 'Completed'){
                                        eventsMap.get(accId).get(weekName).put(daysSequenceMap.get(day) + day, new list<event>{});
                                        upserteventSet.remove(event);
                                    }
                                    else {
                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Completed event cannot be deleted'));
                                    }
                                    if(event.status__c != 'Completed' && event.id != null && ''+event.Id != ''){
                                        deleteevent.add(event);
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            
        }
        system.debug('======================= upserteventList.size(): ' + upserteventSet.size());
        
		accId = null;
        weekName = null;
        saveevents();
        return null;
    }
    
    public PageReference saveevents(){
        
        /*if(setCon.getResultSize() > 0) {
                
            validateNumberOfevents();
                
        }*/
        
        if(!ApexPages.hasMessages()) {
        
            List <event> upserteventList = new List<event>();
            
            upserteventList.addAll(upserteventSet);
        
            if(upserteventSet.size() > 0 || deleteevent.size() > 0) {
                
                if(deleteevent.size() > 0) {
                
                    database.delete(deleteevent,false);
                
                }
                
                Database.UpsertResult[] results = database.upsert(upserteventList, false); // allow partial success    
                
                integer index = 0;
                
                for (Database.UpsertResult result : results) {
                
                    if (!result.isSuccess()) {
                                            
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'event could not be created for : '+upserteventList[index].ActivityDate+'Because this exception : ' +result.getErrors()));

                    }
                          
                    index ++;
                    
                }  
                
            }    
            
            else {
                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,label.noTaskshavebeenadded_deleted));
                
            }
            
            if(!ApexPages.hasMessages()){
                deleteActivityDateSet.clear();
                deleteevent.clear();
                upserteventSet.clear();
                Integer currentPageNumber = setCon.getPageNumber();
                if(currentPageNumber < = totalPages)
                   setCon.setPageNumber(currentPageNumber);
                populateAccounts(); 
                getStats();
                system.debug('********************************** populateAccounts !!!');
            }
            
        }
        
        return null;
        
    }
    
    public PageReference cancel(){
        
        upserteventSet.clear();
        
        deleteevent.clear();
        
        Integer currentPageNumber = setCon.getPageNumber();
        
        if(currentPageNumber < = totalPages)
                
            setCon.setPageNumber(currentPageNumber);
            
        populateAccounts();     

        return null;
        
    }
    
    /**
    * @author : Geeta Kushwaha, geeta.kushwaha@arxxus.com
    * @date : 3-10-2013
    * @Description : Remove All events 
    * @parameter : 
    * @return :
    */
    public PageReference removeAllevents(){
        //system.debug('=====clear===' + clear + '===========' + selectedeventStatus);
        if(clear && selectedeventStatus != 'Completed'){
            
            Integer currentPageNumber = setCon.getPageNumber();
        
            if(currentPageNumber != 1) {
                
                setCon.setPageNumber(1);
                
                setCon.first();
            
            }
            
            list <Id> accIdList = new list<Id>();
            
            while(true){
               
               for(Account acc : (list <Account>)setCon.getRecords()) {
                 
                    accIdList.add(acc.Id);
                    
               }
                
                if(setCon.getHasNext()) {
                   
                   setCon.next();
                   
               }    
                   
               else
               
                   break;
                    
            }  
            
            list <date> dur;
            
            list <String> daysList = new list <String>();
            
            if(selectedWeek == 'All'){
                
                dur = calc.getWeekDuration(weekName, selectedCallCycleRec);
                
                daysList.addAll(daysSequenceMap.keySet());
                
            }
            
            else {
                
                dur = duration;
                
                daysList.add(weekName.substring(1,4));
                
            }
            //system.debug('=======daysList=======' + daysList + '=dur=' + dur);
            
            if(selectedeventStatus == 'All'){
            
                for(event t:[select Id, WhatId, Day__c, ActivityDate
                            from event
                            where RecordTypeId =: recordTypeClientCallId
                            and ActivityDate <=: dur[1] 
                            and ActivityDate >=: dur[0]
                            and WhatId IN : accIdList
                            and Day__c IN : daysList
                            //and IsUnplanned__c = false
                            and status__c != 'Completed']){
                
                    upserteventSet.remove(t);
                    
                    deleteevent.add(t);
                }
            
            }
            else {
            
                if(selectedeventStatus != 'Completed') {
                for(event t:[select Id, WhatId, Day__c, ActivityDate, Event_Status__c
                            from event
                            where RecordTypeId =: recordTypeClientCallId
                            and ActivityDate <=: dur[1] 
                            and ActivityDate >=: dur[0]
                            and WhatId IN : accIdList
                            and Day__c IN : daysList
                            //and IsUnplanned__c = false
                            and status__c =: selectedeventStatus]){
                            
                    upserteventSet.remove(t);
                    
                    deleteevent.add(t);       
                
                }
                }
                
            }
            
            /*
             * Delete events that have not been inserted yet
             */
            
            set<event> removeeventSet = new set<event>();
            
            for(event t : upserteventSet){
            
                if(t.ActivityDate <= dur[1] && t.ActivityDate >= dur[0])
                
                    removeeventSet.add(t);
                
            }
            
            if(!removeeventSet.isEmpty()){
                
                upserteventSet.removeAll(removeeventSet);
                
            }
            
            setCon.setPageNumber(currentPageNumber);
            
            populateAccounts();
        
            return null;
            
        }
        
        return null;
        
    }
    
    public PageReference addTempEvent(){ 
        
        integer numberOfDays = daysCheckBoxList.size();
        
        String day;
        
        if(userLocation == 'Australia')
        
            numberOfDays -= 2;

        for(integer i=0; i< numberOfDays;i++){
            
            if(i == 6)
            
                day = calc.getActivityDay(0);
            
            else 
            
                day = calc.getActivityDay(i+1);
                
            if(daysCheckBoxList.get(i)){
                System.debug('###addTempEvent *******AAAA*********');
                String key =  daysSequenceMap.get(day) + day;
                system.debug('###addTempEvent =====eventsMap====' + eventsMap + 'weekName' + weekName + 'key' + key);
                Boolean createNewEvent = false;
                
                if(eventsMap.isEmpty())
                    createNewEvent = true;
                else
                    if(!eventsMap.get(accId).get(weekName).containsKey(key) || (selectedWeek != 'All' && eventsMap.get(accId).get(weekName).containsKey(key) && eventsMap.get(accId).get(weekName).get(key).size()==0))
                		createNewEvent = true;
                
                //if(!eventsMap.get(accId).get(weekName).containsKey(key) || (selectedWeek != 'All' && eventsMap.get(accId).get(weekName).containsKey(key) && eventsMap.get(accId).get(weekName).get(key).size()==0)) {
                if(createNewEvent){

                    event newevent = new event();
                    
                    newevent.OwnerId = currentUser.Id;
                    
                    newevent.Type_of_Call__c = 'Outlet Visit';
            
                    newevent.RecordTypeId = recordTypeClientCallId;
                    
                    newevent.Subject = 'CC'+ selectedCallCycle.right(1)+', '+weekName;

                    newevent.Description = eventDescription;
                    
                    newevent.WhatId = accId;

                    newevent.ActivityDate = calc.getActivityDate(i,weekName, selectedCallCycleRec.Start_Date__c);
                    newevent.StartDateTime = DateTime.newinstance(calc.getActivityDate(i,weekName, selectedCallCycleRec.Start_Date__c), Time.newInstance(17,0,0,0) );
                    newevent.DurationInMinutes = 90;
                                        
                    newevent.Day__c = day;
                    
                    newevent.Status__c = 'Not Started';
                    
                    newevent.IsUnplanned__c = false;

                    
                
                    if(newevent.ActivityDate < currentCallCycle.Start_Date__c) {
                    
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,label.newTaskcannotbecreatedinpast));
                        
                    }    
                    
                    
                        
                        else {
                            
                            addeventToeventMap(accId,weekName,newevent.Day__c, newevent);
                            
                            upserteventSet.add(newevent);
                        
                        }
                        
                    
                    
                }
                
                else if(eventsMap.get(accId).get(weekName).containsKey(key) && eventsMap.get(accId).get(weekName).get(key).size()>0 && eventsMap.get(accId).get(weekName).get(key)[0].Id == null){
                    
                    eventsMap.get(accId).get(weekName).get(key)[0].Description = eventDescription;
                    system.debug('====eventsMap==== : ' + eventsMap + 'accId : ' + accId + 'weekName : ' + weekName);
                }
                
                daysCheckBoxList[i] = false;
                system.debug('====eventsMap==== : ' + eventsMap + 'accId : ' + accId + 'weekName : ' + weekName);
            }
            
            // deleted the event when the event is not completed and the unchecked the check box 
            else if(selectedWeek == 'All'){
                system.debug('====eventsMap==== : ' + eventsMap );
                if (!eventsMap.isEmpty()){
                    if(eventsMap.get(accId).get(weekName).containsKey( daysSequenceMap.get(day) + day)) {
                        
                        for(event event : eventsMap.get(accId).get(weekName).get( daysSequenceMap.get(day) + day)){
                            
                            if(event.status__c != 'Completed'){
                                eventsMap.get(accId).get(weekName).put(daysSequenceMap.get(day) + day, new list<event>{});
                                upserteventSet.remove(event);
                            }
                            else {
                                
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Completed event cannot be deleted'));
                                
                            }
                            
                            if(event.status__c != 'Completed' && event.id != null && ''+event.Id != ''){
                                
                                deleteevent.add(event);
                                
                            }
                    
                        }
                        
                    }
                }
                
            }
            
        }
            
        accId = null;
        
        weekName = null;
        
        eventDescription = null;
        
        return null;
        
    }
    
    @TestVisible
    void addeventToeventMap(Id accId,String weekName,String day, event newevent){
        
        if(eventsMap.containsKey(accId)) {
            
            if(eventsMap.get(accId).containsKey(weekName)){
                
                if(eventsMap.get(accId).get(weekName).containsKey(daysSequenceMap.get(day) + day) && eventsMap.get(accId).get(weekName).get(daysSequenceMap.get(day) + day).size() > 0 ){
                     ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'event Has already been added'));
                }
                else {
                    eventsMap.get(accId).get(weekName).put(daysSequenceMap.get(day) + day, new list<event>{newevent});
                }
            }
            else {
                eventsMap.get(accId).put(weekName, new map<String, list<event>>{daysSequenceMap.get(day) + day => new list<event>{newevent}});
            }
        }
        else {
            eventsMap.put(accId, new Map<String, map<String, list<event>>>{weekName => new map<String, list<event>>{daysSequenceMap.get(day) + day => new list<event>{newevent}}});
        }
    }
    
    @TestVisible 
    private void reseteventMap(){
    
        for(String accId : eventsMap.keySet()){
            
            map<String, map<String, list<event>>> weekMap = eventsMap.get(accId);
            
            for(String weekName : weekMap.keySet()) {
                
                map<String, list<event>> dayMap = weekMap.get(weekName);
                
                for(String day : dayMap.keySet()) {
                    
                    dayMap.get(day).clear();
                    
                }
                
                dayMap.clear();
                
            }
            
            weekMap.clear();
            
        }
        
        eventsMap.clear();
        
    }
    
    public void populateAccounts(){
            
        accounts = new list<Account>();
        
        reseteventMap();
        
                
        if(!ApexPages.hasMessages()){
                        
            if(setCon != null) {
                
                for(Account accObj : (list <Account>)setCon.getRecords()) {
                    
                    accounts.add(accObj);
                    
                    eventsMap.put(accObj.Id, new map<String, map<String, list<event>>>());
                    
                    if(selectedWeek == 'All'){
                    
                        for(String weekName : weeksHeaderOriginal){
                            
                            eventsMap.get(accObj.Id).put(weekName, new map<String,list<event>>());     
                            
                        }
                    
                    }
                    
                    else{
                            
                       eventsMap.get(accObj.Id).put(selectedWeek, new map<String,list<event>>());  
                       
                       for(String key : daysHeader){
                        
                           eventsMap.get(accObj.Id).get(selectedWeek).put(key, new list<event>());
                           
                       }  
                            
                    }
                    
                }
                
                String week = null;
                
                if(selectedeventStatus == 'All') {
                
                    for(event eventRec : [select id, Owner.Firstname, Owner.LastName, Day__c, ActivityDate,
                                          status__c, WhatId, Event_Status__c
                                        from event
                                        where RecordTypeId =: recordTypeClientCallId
                                        and ActivityDate <=: duration[1] 
                                        and ActivityDate >=: duration[0]
                                        and WhatId IN : eventsMap.keySet()
                                        //and OwnerId =: selectedOutlet
                                        //and IsUnplanned__c = false
                                        and Day__c IN : daysSequenceMap.keySet()]) {
                        
                        map<String, map<String, list<event>>> weekMap = eventsMap.get(eventRec.WhatId);
                        
                        week = calc.getWeekName(eventRec.ActivityDate, selectedCallCycleRec, selectedWeek);  
     
                        String dayKey ; //addeventToeventMap(Id accId,String weekName,String day, event newevent)
                        
                        if(daysSequenceMap.containsKey(eventRec.Day__c)) {   
                            
                            dayKey = daysSequenceMap.get(eventRec.Day__c) + eventRec.Day__c;
                            
                            if(weekMap.containsKey(week)){
                                
                                if(weekMap.get(week).containsKey(dayKey )) {
                                    
                                    weekMap.get(week).get(dayKey).add(eventRec);
                                        
                                }
                                
                                else {
                                    
                                    weekMap.get(week).put(dayKey, new list<event>{eventRec});
                                    
                                }
                                
                            }
                                                
                            else {
                                
                                weekMap.put(week, new Map<String, List<event>> {dayKey => new list<event>{eventRec}} );
                                
                            }
                        
                        }
                        
                    }
                    
                }
                
                else {
                    
                    for(event eventRec : [select id, Owner.Firstname, Owner.LastName, Day__c, ActivityDate, status__c, 
                                          WhatId,Event_Status__c
                                        from event
                                        where RecordTypeId =: recordTypeClientCallId
                                        and ActivityDate <=: duration[1] 
                                        and ActivityDate >=: duration[0]
                                        and WhatId IN : eventsMap.keySet() 
                                        and Day__c IN : daysSequenceMap.keySet()
                                        //and IsUnplanned__c = false
                                        and status__c =: selectedeventStatus]) {
                        
                        map<String, map<String, list<event>>> weekMap = eventsMap.get(eventRec.WhatId);
                        
                        week = calc.getWeekName(eventRec.ActivityDate, selectedCallCycleRec, selectedWeek);  
     
                        String dayKey;
                        
                        if(daysSequenceMap.containsKey(eventRec.Day__c)) {   
                            
                            dayKey = daysSequenceMap.get(eventRec.Day__c) + eventRec.Day__c;                 
                            
                            if(weekMap.containsKey(week)){
                                
                                if(weekMap.get(week).containsKey(dayKey )) {
                                    
                                    weekMap.get(week).get(dayKey).add(eventRec);
                                        
                                }
                                
                                else {
                                    
                                    weekMap.get(week).put(dayKey, new list<event>{eventRec});
                                    
                                }
                                
                            }
                                                
                            else {
                                
                                weekMap.put(week, new Map<String, List<event>> {dayKey => new list<event>{eventRec}} );
                                
                            }
                        
                        }
                    
                    }
                    
                }
                                    
            }
        
        }
        
        else {
        
            if(accounts!=null)
            
                accounts.clear();
                
                totalPages = 0;
        }
        
        populateInsertedevents();
        
        populateDeletedevents();        
        
    }
    
    /*
     * When the user had deleted some event(s),
     * Then navigates to another page & comes back again to the page where he had deleted events
     * those event(s) should NOT be displayed
     */
    void populateDeletedevents(){
        
        String week, dayKey;
        
        for(event t : deleteevent){
            
            if(eventsMap.containsKey(t.WhatId)) {
                
                week = calc.getWeekName(t.ActivityDate, selectedCallCycleRec, selectedWeek);
                
                dayKey = daysSequenceMap.get(t.Day__c)+t.Day__c; 

                if(eventsMap.get(t.WhatId).containsKey(week) && eventsMap.get(t.WhatId).get(week).containsKey(dayKey)) {

                    eventsMap.get(t.WhatId).get(week).put(dayKey, new list<event>());
                
                }
                
            }
            
        }
        
    }
    
    /*
     * When the user had created some event(s),
     * Then navigates to another page & comes back again to the page where he had created events
     * those event(s) should be displayed
     */
    @TestVisible
    void populateInsertedevents(){
        
        String week, dayKey;
        //system.debug('upserteventSet===' + upserteventSet + 'eventsMap===');
        for(event t : upserteventSet){
            
            if(eventsMap.containsKey(t.WhatId)) {
                
                week = calc.getWeekName(t.ActivityDate, selectedCallCycleRec, selectedWeek);
                
                dayKey = daysSequenceMap.get(t.Day__c)+t.Day__c; 

                if(eventsMap.get(t.WhatId).containsKey(week)) {

                    eventsMap.get(t.WhatId).get(week).put(dayKey, new list<event>{t});
                
                }
                
            }
            
        }
        
    }
    
    /*
     * Go back to the salesforce home page
     */
    public Pagereference home(){
    
       return new PageReference('/home/home.jsp');
    
    }
    
    private void getQueryString(){
        
        query = 'Select id, Name, Account_Grading__c, BillingStreet, BillingState, BillingCountry, BillingCity,  BillingPostalCode, ShippingCity, ShippingCountry, ShippingStreet, BillingLatitude, BillingLongitude, ShippingLatitude, ShippingLongitude, Last_Stayed_in_Touch_Date__c ';
        
        if(userLocation == 'australia') {
            
            query += ',Region1__c, Volume__c, Volume_9LE_LY__c, Banner_Group_Name__c from Account where RecordTypeId IN : recordTypeAccountList ';
            
            query += ' and OwnerId =: selectedOutlet';   
            
            // DK: 20181025 - Outlet Search: do a search on the Outlet Name, Banner Group Name, Street, Postcode
            if (searchOutlet != null && searchOutlet.length() > 0) {
                query += ' and (Name LIKE \'%' + string.escapeSingleQuotes(searchOutlet) + '%\'';
                query += ' or Banner_Group_Name__c LIKE \'%' + string.escapeSingleQuotes(searchOutlet) + '%\'';
                query += ' or BillingStreet LIKE \'%' + string.escapeSingleQuotes(searchOutlet) + '%\'';
                query += ' or BillingPostalCode LIKE \'%' + string.escapeSingleQuotes(searchOutlet) + '%\')';
            }
            // DK: 20181025 - END
            
            if(selectedBanerGroup != 'All')
                
                 query += ' and Banner_Group__r.Parent_Hierarchy__c LIKE '+'\'%,'+ selectedBanerGroup +',%\'' ;
            
            if(selectedPostcode != 'All')
                
                query += ' and Region1__c =: selectedPostcode ';
            
                query += ' and Called_On__c =: isCalledOnCheck';
        }
        
        if(selectedGrading  != 'All')
            query += ' and Account_Grading__c =: selectedGrading ';
        query += ' and Active__c =: activeStatus';
system.debug('*****query****** currentSortField: ' + currentSortField);
system.debug('*****query****** SORT_DIR: ' + SORT_DIR);
        if(currentSortField != null && valFieldName.containsKey(currentSortField)) {
            query += ' Order By '+valFieldName.get(currentSortField);
            if(SORT_DIR == SortDirection.ASCENDING || SORT_DIR == null){
                query += ' ASC ';
            }
            else {
                query += ' DESC ';
            }
            query += ' NULLS FIRST ';
        }
        else 
            query += ' Order By BillingPostalCode ASC ';
        query += ' LIMIT 10000'; 
system.debug('*****query****** query: ' + query);        
    }

    // DK-20181028: saves filter selections and then performs search
    public PageReference refreshAccounts()  {  
    	saveFilterSettings();
        // YB-20190117 - ensure that clicking on refresh sets the call cycle dates.
        recalculateWeek();
        
        return searchAccounts();
    }
    
    /*
     * This method is called everytime the Refresh button has been clicked
     * Populate all the account records according to the user location
     */
    public PageReference searchAccounts()  {  
        
        if(upserteventSet.size() >0 || deleteevent.size() > 0 ){
           
           eventAddedDeleted = true;
           
        }   
           
        else {
        
           eventAddedDeleted = false;
           
        }   
        
        weeksHeader.clear();
        
        daysHeader.clear();  
        
        if(eventAddedDeleted && clear == null)
        
           return null;
        
        else if(eventAddedDeleted && clear != null){
            
                    
            if(clear == false) {
                saveevents();
                clear = null;
                eventAddedDeleted = false;
            }
            
        }  
        
        //if(!eventAddedDeleted || (clear != null && eventAddedDeleted && !clear) ){
            
        upserteventSet.clear();
    
        deleteevent.clear();
        
        displayAddButton.clear();
        
        numberOfCallsMap.clear();
        
        weeksHeader.clear(); /* Added purposefully do not remove this*/
        
        daysHeader.clear();  /* Added purposefully do not remove this*/
        
        clear = null;
        
        accId = null;
            
        weekName = null;
            
        dayName = null;
        
        getQueryString();   
            
        try {   
                
            setCon = new ApexPages.StandardSetController(Database.getQueryLocator(query));  
       
            setCon.setPageSize(Integer.valueOf(recordsPerPage));  
                
            Decimal dtotalPages = (setCon.getResultSize() / setCon.getPageSize());
                
            dtotalPages = Math.floor(dtotalPages) + ((Math.mod(setCon.getResultSize(), Integer.valueOf(recordsPerPage))>0) ? 1 : 0);
                
            totalPages = Integer.valueOf(dtotalPages);
                
            if(currentPageNumber != null && currentPageNumber != 0 && currentPageNumber <= totalPages) {
                
                setCon.setPageNumber(currentPageNumber);
                   
            } 
            
            getselectedCallCycleRec();
            
            if(ApexPages.hasMessages())
            
                return null;

            
            daysHeader.addAll(daysHeaderCopy);
                
            if(selectedWeek == 'All') {  
                
                        weeksHeader.addAll(weeksHeaderOriginal);
                
            }
                
            else {
                
                weeksHeader.add(selectedWeek);
                
            }
                
            /*
             * Display Add Button or not & Number of calls
             */
                
            if(selectedWeek == 'All'){
                
                date weekStart = selectedCallCycleRec.Start_Date__c;  
                system.debug('## weekStart : ' + weekStart); 
                system.debug('## currentCallCycle.Start_Date__c : ' + currentCallCycle.Start_Date__c); 
                    
                for(String weekName : weeksHeader){
                    displayAddButton.put(weekName, weekStart >= currentCallCycle.Start_Date__c); 
                    weekStart = weekStart.addDays(7);
                }
                
                system.debug('## displayAddButton : ' + displayAddButton); 
                    
                for(String weekName : weeksHeader){
                    numberOfCallsMap.put(weekName, 0);
                }
                    
            }
            
            else {

                integer weekNumber = Integer.valueOf(selectedWeek.substring(5));
                
                weekNumber --;
                    
                if(weekNumber == 0){
                        
                    displayAddButton.put(selectedWeek, selectedCallCycleRec.Start_Date__c >= currentCallCycle.Start_Date__c); 
                }
                    
                else{
                        
                    displayAddButton.put(selectedWeek, selectedCallCycleRec.Start_Date__c.addDays(weekNumber * 7 ) >= currentCallCycle.Start_Date__c);

                }
                    
                for(String dayName : daysHeader){

                    numberOfCallsMap.put(dayName, 0);
                        
                }
                    
            }   

            duration = calc.getWeekDuration(selectedWeek, selectedCallCycleRec);                
                
            /*
             * Populate Number of Calls
             */
            //System.debug('&****************************** 1748');    
            getStats();
            
        }
        
        catch(QueryException e) {
            
            if(!ApexPages.hasMessages())
                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.recordscouldnotberetrieved));
            
        }
            
        /*catch(Exception e){
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.pleaserefreshthepageandtryagain));
            
        }*/
        if(accounts != null)
    
            accounts.clear();
        populateAccounts();

        return null ;  
        
    }
    
    private void getStats(){
                
        String week , dayKey;
        
        if(!ApexPages.hasMessages()) {
        
            date duration0 = duration[0], duration1 = duration[1];
            
            set <String> daysSet = daysSequenceMap.keySet();
            
            list <Id> accIdList = new list<Id>();
            
            Integer currentPageNumber = setCon.getPageNumber();
            
            if(currentPageNumber != 1) {
                
                setCon.setPageNumber(1);
                
                setCon.first();
               
            }
    
            while(true){
               
               for(Account acc : (list <Account>)setCon.getRecords()) {
                    
                    accIdList.add(acc.Id);
                    
                }
                
                if(setCon.getHasNext()) {
                   
                   setCon.next();
             
               }    
                   
               else
               
                   break;  
                    
            }
            
            numberOfCallsMap.clear();
    
            if(selectedWeek == 'All'){
                
                if(weeksHeader.size() == 0 ){
                    
                    if(selectedCallCycle == 'Summer Call Cycle'){
                        
                        for(integer i=1; i<=selectedCallCycleRec.Number_Of_Weeks__c; i++)
                        
                            weeksHeader.add('Week '+i);     
                        
                    }    
                    
                    else {
                    
                        weeksHeader.addAll(weeksHeaderOriginal);
                    
                    }
                    
                }               
                    
                for(String weekName : weeksHeader){
            
                    numberOfCallsMap.put(weekName, 0);
                    
                }
            
            }
            
            else {
                
                if(daysHeader.size() == 0){
                    
                    daysHeader.addAll(daysHeaderCopy);
                    
                }
            
                
                for(String dayName : daysHeader){
            
                    numberOfCallsMap.put(dayName, 0);
                    
                }
                
            }
                       
            setCon.setPageNumber(currentPageNumber);
            
            String queryString =  'select Day__c, ActivityDate';
            queryString += ' from event';
            queryString += ' where RecordTypeId =: recordTypeClientCallId and ActivityDate <=: duration1';
            queryString += ' and ActivityDate >=: duration0';
            queryString += ' and WhatId IN : accIdList';
            queryString += ' and Day__c IN : daysSet';
            //queryString += ' and IsUnplanned__c = false';
           
                
                initializeDayWiseStatsAus();
                        
                if(selectedeventStatus != 'All') 
                
                    queryString += ' and status__c =: selectedeventStatus';                
                        
                for(event eventRec : database.query(queryString)) {
                    
                    //System.debug('***************** eventRec '+eventRec.Id);
                    
                    week = dayKey = null;
                        
                    week = calc.getWeekName(eventRec.ActivityDate, selectedCallCycleRec, selectedWeek);  
                    
                    if(daysSequenceMap.containsKey(eventRec.Day__c))  
                            
                       dayKey = daysSequenceMap.get(eventRec.Day__c) + eventRec.Day__c;  
        
                    if(week != null && dayKey != null) {
                        
                        //System.debug('******************** '+dayWiseStatsAus.keySet()+'***************** ');
                        
                        //System.debug('********************** dayKey '+dayKey);
                        
                        //System.debug('*********************** dayWiseStatsAus.get(dayKey) '+dayWiseStatsAus.get(dayKey));
                        
                        //System.debug('*********************** dayWiseStatsAus.get(dayKey).get('+week+') '+dayWiseStatsAus.get(dayKey).get(week));
                        
                        dayWiseStatsAus.get(dayKey).put(week, dayWiseStatsAus.get(dayKey).get(week) + 1);
                        
                        if(selectedWeek == 'All') 
                            numberOfCallsMap.put(week, numberOfCallsMap.get(week) + 1);
                        else    
                           numberOfCallsMap.put(dayKey, numberOfCallsMap.get(dayKey) + 1);
                    }     
                            
                }
            
        
        }
        
    }  
  
    public void first() {
        
        setCon.first();
        
        accId = null;
        
        populateAccounts();
        
    }
  
    public void last() {
        
        setCon.last();
        
        accId = null;
        
        populateAccounts();
        
    }
  
    public void previous() {
        
        setCon.previous();
        
        accId = null;
        
        populateAccounts();
        
    }
  
    public void next() {
        
        setCon.next();
        
        accId = null;
        
        populateAccounts();
    
    }
    

    /*
     * Increment the event count in when a event has been found in the eventsCountMap
     */
     private void incrementeventCount(Map <Id, Integer> eventsCountMap, Id whatId){
        
        if(eventsCountMap.containsKey(WhatId)){  
                
            eventsCountMap.put(whatId, eventsCountMap.get(whatId) + 1);
            
        }
        
        else {
            
            eventsCountMap.put(whatId, 1);
            
        }
        
    }
      	
    
    public PageReference showHide(){
        
        return null;
    
    }
     

    /*
     * Creates the event for a particular day.
     * @Criteria: This mehtod is called only when the Week filter is NOT All
     */
    public PageReference createeventForDay(){
        
        string dayName = weekDayname.substring(1,4);
        //system.debug('======dayName=======' + dayName);
        for(integer i=0;i<daysCheckBoxList.size();i++)
        
            daysCheckBoxList[i] = false;
            
        if(dayName == 'Sun')
        
            daysCheckBoxList[6] = true;
        
        else
           
           daysCheckBoxList[daysSequenceMap.get(dayName) - 1] = true;
        
        addTempEvent();
        
        return null;
        
    }
    
    /*
     * Deletes the event for a particular day.
     * @Criteria: This mehtod is called only when the Week filter is NOT All
     */
    public pageReference deleteeventForDay(){

        string dayName = weekDayname.substring(1,4);
       
        integer i = daysSequenceMap.get(dayName) - 1;
        
        String day = calc.getActivityDay(i+1);
        system.debug('======eventsMap====' + eventsMap + 'weekName' + weekName + 'day' + day);
        if(eventsMap.get(accId).get(weekName).containsKey( daysSequenceMap.get(day) + day)) {
                    
            for(event event : eventsMap.get(accId).get(weekName).get( daysSequenceMap.get(day) + day)){
                
                if(event.status__c != 'Completed'){
                    
                   // eventsMap.get(accId).get(weekName).remove( daysSequenceMap.get(day) + day);
                    eventsMap.get(accId).get(weekName).put(daysSequenceMap.get(day) + day, new list<event>{});
                    
                    upserteventSet.remove(event);
                    
                }
                
                if(event.status__c == 'Completed')
                
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,label.completedTaskcannotbedeleted));
                
                else if(event.id != null){ // event.id != null & event.status__c != 'Completed'
                    
                    deleteevent.add(event);
                    
                }
        
            }
            
        }
        return null;
    }
   
 
    /*
     * Find the address information to be displayed. Called when user clicks on home icon.
     */
    public pagereference addressInfo(){        
        AccAddress = new Account();        
        PopulateAccountAddress populateAddress = new PopulateAccountAddress();        
        AccAddress = populateAddress.autoPopulateAddress(accAddressId, (list <Account>)setCon.getRecords());
        return null;        
    }
    
     public void reverseSortDirection(){        
        if(SORT_DIR == SortDirection.ASCENDING)            
            SORT_DIR = SortDirection.DESCENDING;        
        else        
            SORT_DIR = SortDirection.ASCENDING;    
    }
    
    /*
     * This method will sort the account records on basis of Account Name, Banner Grp, City, Region, Postcode, Grade & Volume
     * On first time click sort Direction is Ascending
     * On click of same field again sort Direction would be descending
     */    
    public PageReference sortAccount(){        

        previousSortOrder = SORT_DIR;        
        currentPageNumber = setCon.getPageNumber();        
        return searchAccounts();        
    }  
    
    // DK-20181028
    public PageReference executeSortBy(){
        system.debug('=====selectedSortBy===' + selectedSortBy);
        currentSortField = selectedSortBy;
        saveFilterSettings();
		return sortAccount();
    }
    
    public void saveSortBy(){
        system.debug('=====selectedSortBy===' + selectedSortBy);
        currentSortField = selectedSortBy;
        saveFilterSettings();
		//return sortAccount();
    }
    
    // DK-20181117
    public PageReference executeSortOrder(){
        system.debug('=====selectedSortOrder===' + selectedSortOrder);
        if (selectedSortOrder == 'DES') 
            SORT_DIR = SortDirection.DESCENDING;
        else 
        	SORT_DIR = SortDirection.ASCENDING;
        saveFilterSettings();
		return sortAccount();
    }
    
    // DK-20181028: Save the current filter selections in custom setting Call_Cycle_Filters__c
    public void saveFilterSettings(){
    	Call_Cycle_Filters__c CCF = Call_Cycle_Filters__c.getInstance(UserInfo.getUserId());
        CCF.SortBy__c = selectedSortBy;
        CCF.SortOrder__c = selectedSortOrder;
        CCF.Call_Cycle__c = selectedCallCycle;
        CCF.Called_On__c = isCalledOnCheck;
        CCF.Grading__c = selectedGrading;
        CCF.Owner__c = selectedOutlet;
        CCF.Status__c = selectedEventStatus;
        CCF.Year__c = selectedYear;
        CCF.Record_Per_Page__c = recordsPerPage;
        system.debug('@@@@@@@@@@@@@@@ CCF: ' + CCF);
        upsert(CCF);
    }
    
    void countryNotFound(){        
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.userlocationnotfoundpleasespecifyaustral));            
        countryFound = false;        
    }
    
    public list <SelectOption> getCallCycles(){        
        return callCycles;        
    }
    
    public list <SelectOption> getSourceCallCycles(){        
        return sourceCallCycles;        
    }
    
    public list <SelectOption> getDestinationCallCycles(){        
        return destinationCallCycles;        
    }
    
    public list <SelectOption> getWeeks(){        
        return weeks;        
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
    
    public list <SelectOption> getMonths(){        
        return months;        
    }
    
    public list <SelectOption> getPostCode(){        
        return postCode;        
    }
    
    public List <String> getWeeksHeader(){        
        return weeksHeader;        
    }
    
    public List <String> getdaysHeader(){        
        return daysHeader;        
    }
    
    public list <SelectOption> geteventStatus(){        
        return eventStatus;        
    }
    
    public list <SelectOption> getAccType(){        
        return accType;        
    }
    
    public list <SelectOption> getnumberOfOutlets(){        
        return numberOfOutlets;    
    }    
    
    private void initializeDayWiseStatsAus(){        
        //System.debug('***************** initializeDayWiseStatsAus ');        
        //System.debug('****************************** dayWiseStatsAus.keySet() '+dayWiseStatsAus.keySet());        
        for(String dayName : dayWiseStatsAus.keySet() ) {            
            //System.debug('********* dayName '+dayName+ ' values '+weeksHeaderOriginal);            
            dayWiseStatsAus.get(dayName).clear();                
            for(String weekName : weeksHeaderOriginal)            
                dayWiseStatsAus.get(dayName).put(weekName, 0);               
        }        
    }
    
    private list <Call_Cycle__c> getCallCyclesForYear(String year){        
        
        system.debug('======year======' + year + '====userLocation====' + userLocation);
        return [Select Start_Date__c, End_Date__c, Call_Cycle__c, Number_Of_Weeks__c, Reporting_Start_Date__c
                                       from Call_Cycle__c
                                       where Location__c =: userLocation 
                                       and year__c =: year
                                       order by Call_Cycle__c];        
    }
    
    /*
     * When the year has changed, call cycle picklist needs to be recalculated
     */
    public PageReference recalculateCallCycles(){        
        callCycles.clear();        
        for(Call_Cycle__c ccRec : getCallCyclesForYear(selectedYear)) {            
            if(ccRec.Call_Cycle__c != null)                
                callCycles.add(new SelectOption(ccRec.Call_Cycle__c , ccRec.Call_Cycle__c+' ('+ ccRec.Start_Date__c.day()+'/'+ccRec.Start_Date__c.month()+'/'+(ccRec.Start_Date__c.year()-2000)+' - '+ccRec.End_Date__c.day()+'/'+ccRec.End_Date__c.month()+'/'+(ccRec.End_Date__c.year()-2000)+')'));            
        }
        
        if(callCycles.size() == 0)        
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Call Cycles not defined for selected year'));           
        return null;        
    } 
    
    /*
     * When the year has changed, call cycle picklist needs to be recalculated
     */
    public PageReference recalculateSourceCallCycles(){        
        sourceCallCycles.clear();        
        sourceCallCycles.add(new SelectOption('Default','Default'));        
        for(Call_Cycle__c ccRec : getCallCyclesForYear(selectedSourceCallCycleYear)) {            
            if(ccRec.Call_Cycle__c != null)                
                sourceCallCycles.add(new SelectOption(ccRec.Call_Cycle__c , ccRec.Call_Cycle__c+' ('+ ccRec.Start_Date__c.day()+'/'+ccRec.Start_Date__c.month()+'/'+(ccRec.Start_Date__c.year()-2000)+' - '+ccRec.End_Date__c.day()+'/'+ccRec.End_Date__c.month()+'/'+(ccRec.End_Date__c.year()-2000)+')'));
        }
        
        if(callCycles.size() == 0)        
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Call Cycles not defined for selected year'));          
        return null;        
    } 
    
    /*
     * When the year has changed, call cycle picklist needs to be recalculated
     */
    public PageReference recalculateDestinationCallCycles(){        
        destinationCallCycles.clear();        
        for(Call_Cycle__c ccRec : getCallCyclesForYear(selectedNewCallCycleYear)) {            
            if(ccRec.Call_Cycle__c != null)                
                destinationCallCycles.add(new SelectOption(ccRec.Call_Cycle__c , ccRec.Call_Cycle__c+' ('+ ccRec.Start_Date__c.day()+'/'+ccRec.Start_Date__c.month()+'/'+(ccRec.Start_Date__c.year()-2000)+' - '+ccRec.End_Date__c.day()+'/'+ccRec.End_Date__c.month()+'/'+(ccRec.End_Date__c.year()-2000)+')'));            
        }
        
        if(callCycles.size() == 0)        
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Call Cycles not defined for selected year'));         
        return null;        
    } 
    
    public PageReference recalculateWeek(){        
        if(userLocation == 'australia'){        
            weeks.clear();            
            weeks.add(new SelectOption('All',Label.All));            
            getselectedCallCycleRec();             
            weeksHeaderOriginal.clear();            
            String weekNumber;                
            if(selectedCallCycleRec != null) {            
                for( integer numWeeks = 1; numWeeks <= (integer) selectedCallCycleRec.Number_Of_Weeks__c; numWeeks++ ) {                    
                   weekNumber = 'Week ' + numWeeks;                    
                   weeksHeaderOriginal.add(weekNumber);                    
                }                    
                date startDate;                
                for(String weekName : weeksHeaderOriginal) {                    
                    startDate = calc.getWeekDuration(weekName, selectedCallCycleRec)[0];                    
                    weeks.add(new SelectOption(weekName,weekName+' '+startDate.day()+'/'+startDate.month()+'/'+startDate.year()));                    
                }            
            }        
        }        
        return null;          
    }    

    public void saveLoadFromTemplate(){
        system.debug('#### selectedCurrentOrFutureCallCycle' + selectedCurrentOrFutureCallCycleLoad);
        system.debug('#### selectedOwner' + selectedOwnerLoad);
         
        List<Call_Cycle__c> callCycles = [SELECT Id, Start_Date__c FROM Call_Cycle__c WHERE Id =: selectedCurrentOrFutureCallCycleLoad];
        system.debug('#### callCycles' + json.serialize(callCycles));

        if(callCycles.size() == 0){
            return;
        }

        List<Call_Cycle_Template__c> callCycleTemplates = [SELECT Id, Name, Subject__c, Start_Date_Time__c, Day_of_the_Week__c, Type_of_Call__c, Related_To__c, CC_Week__c, Assigned_To__c, Assigned_To__r.Name
                                                    FROM Call_Cycle_Template__c 
                                                    WHERE Assigned_To__c =: selectedOwnerLoad AND CC_Week__c != NULL];
        
        system.debug('#### callCycleTemplates' + json.serialize(callCycleTemplates));

        if(callCycleTemplates.isEmpty()){
            hasNotification = 'warning';
            msgNotification = 'There is no call cycle template with the selected user!';
            system.debug('#### hasNotification' + hasNotification);
            return;
        }     
        

        LoadFromTemplateBatch batch = new LoadFromTemplateBatch(callCycleTemplates, callCycles[0], calc);
        Id batchId = Database.executeBatch(batch); 

        List<AsyncApexJob> batchJob = [SELECT Id, Status FROM AsyncApexJob WHERE Id =: batchId AND Status = 'Failed'];  
        system.debug('#### batchJob' + batchJob);  
        
        hasNotification = batchJob.size() == 0 ? 'error' : 'success';
    }


    public void saveCallCycleTemplate(){
        system.debug('#### selectedCurrentOrPastCallCycle' + this.selectedCurrentOrPastCallCycle);      
        system.debug('#### selectedOwnerTemplate' + this.selectedOwnerTemplate);
        
        hasNotification = '';
        deleteCallCycleTemplateCreated(this.selectedOwnerTemplate, this.selectedCurrentOrPastCallCycle);

        List<Event> events = [SELECT Id, Subject, CC_Week__c, ActivityDate, StartDateTime, WhatId, Call_Cycle_Id__r.Name, OwnerId 
                              FROM Event 
                              WHERE Call_Cycle_Id__c =: this.selectedCurrentOrPastCallCycle AND OwnerId =: this.selectedOwnerTemplate 
                              ORDER BY ActivityDate];

        system.debug('#### events' + json.serialize(events));  

        if(events.size() == 0)
            return;

        SaveToTemplateBatch batch = new SaveToTemplateBatch(events);
        Id batchId = Database.executeBatch(batch); 

        List<AsyncApexJob> batchJob = [SELECT Id, Status FROM AsyncApexJob WHERE Id =: batchId AND Status = 'Failed'];  
        system.debug('#### batchJob' + batchJob);  
        
        hasNotification = batchJob.size() == 0 ? 'error' : 'success';
    }

    private void deleteCallCycleTemplateCreated(Id ownerId, Id callCycleId){
        hasNotification = '';

        List<Call_Cycle__c> callCycles = [SELECT Id, Name, Start_Date__c, End_Date__c FROM Call_Cycle__c WHERE Id =: callCycleId];

        if(callCycles.size() == 0){
            return;
        }

        Call_Cycle__c callCycle = callCycles[0];

        List<Call_Cycle_Template__c> callCycleTemplates = [SELECT Id, Name 
                                                            FROM Call_Cycle_Template__c 
                                                            WHERE Assigned_To__c =: ownerId ];


        system.debug('#### callCycleTemplates DELETE'  + json.serialize(callCycleTemplates));   
        if(callCycleTemplates.isEmpty())
            return;

        try{
            delete callCycleTemplates;
            hasNotification = 'success';
        }
        catch(Exception e) {
            System.debug('##Error deleteCallCycleCreated' + e.getMessage());
            hasNotification = 'error';
        }
    }

    public void saveSwapDays(){
        system.debug('#### selectedWeekFrom' + selectedWeekFromDays);
        system.debug('#### selectedWeekTO' + selectedWeekToDays);
        system.debug('#### selectedDayFrom' + selectedDayFrom);
        system.debug('#### selectedDayTo' + selectedDayTo);
        system.debug('#### selectedCurrentOrPastCallCycle' + selectedCurrentOrFutureCallCycle);      
        system.debug('#### selectedOwnerTemplate' + this.selectedOwner);

        List<String> weeks = new List<String>();
        weeks.add(selectedWeekFromDays);
        weeks.add(selectedWeekToDays);

        hasNotification = '';
        List<Event> events = [SELECT Id, Subject, CC_Week__c, ActivityDate, StartDateTime FROM Event 
                              	WHERE OwnerId =: selectedOwner 
                              		AND Call_Cycle_Id__c =: selectedCurrentOrFutureCallCycle
                              		AND CC_Week__c IN: weeks ORDER BY ActivityDate];
        system.debug('#### events' + json.serialize(events));

        if(events.isEmpty())
            return;

        
        Swap2DaysBatch batch = new Swap2DaysBatch(events, selectedDayFrom, selectedWeekFromDays, selectedDayTo, selectedWeekToDays, selectedCurrentOrFutureCallCycle, calc);
        Id batchId = Database.executeBatch(batch); 

        List<AsyncApexJob> batchJob = [SELECT Id, Status FROM AsyncApexJob WHERE Id =: batchId AND Status = 'Failed'];  
        system.debug('#### batchJob' + batchJob);  
        
        hasNotification = batchJob.size() == 0 ? 'error' : 'success';
    }


    public void saveSwapWeeks(){
        system.debug('#### selectedWeekFrom' + selectedWeekFrom);
        system.debug('#### selectedWeekTO' + selectedWeekTO);
        system.debug('#### selectedCurrentOrPastCallCycle' + selectedCurrentOrFutureCallCycle);      
        system.debug('#### selectedOwnerTemplate' + this.selectedOwner);
        hasNotification = '';

        List<String> weeks = new List<String>();
        weeks.add(selectedWeekFrom);
        weeks.add(selectedWeekTO);
         
        List<Event> events = [SELECT Id, Subject, CC_Week__c, ActivityDate, StartDateTime 
                              	FROM Event 
                              	WHERE OwnerId =: selectedOwner 
                              		AND Call_Cycle_Id__c =: selectedCurrentOrFutureCallCycle
                              		AND CC_Week__c IN: weeks 
                              	ORDER BY ActivityDate];
        system.debug('#### events' + json.serialize(events));

        if(events.isEmpty())
            return;

        Swap2WeeksBatch batch = new Swap2WeeksBatch(events, selectedWeekFrom, selectedWeekTO, selectedCurrentOrFutureCallCycle, calc);
        Id batchId = Database.executeBatch(batch); 

        List<AsyncApexJob> batchJob = [SELECT Id, Status FROM AsyncApexJob WHERE Id =: batchId AND Status = 'Failed'];  
        system.debug('#### batchJob' + batchJob);  
        
        hasNotification = batchJob.size() == 0 ? 'error' : 'success';
    }

    public void test(){
        system.debug('#### hasNotification' + hasNotification);
        hasNotification = '';


        hasNotification = 'warning';
    }

   
}