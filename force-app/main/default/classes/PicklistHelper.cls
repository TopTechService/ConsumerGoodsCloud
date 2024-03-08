/**
 * @author    : Created by Geeta Kushwaha on 2 May, 2013  geeta.kushwaha@arxxus.com
 * @Purpose   : Helper for displaying picklists on Call Planning & Objective planning page
 * @Criteria  : 
 * @Modified  : Geeta Kushwaha on 4 May, 2013 geeta.kushwaha@arxxus.com
 */
public class PicklistHelper {
    
    private Call_Cycle__c currentCallCycle  ;   
    private map<Id,Objective__c> currentObjectivesMap ; 
    private list<Id> currentObjectivesIdList;   
    public string selectedYear {get;set;}
    
    public list <SelectOption> getNumberOfOutlets(){        
        return new list <SelectOption>{new SelectOption('100','100'),new SelectOption('150','150'), new SelectOption('200','200'), new SelectOption('250','250')};
    }
    
    
    /*
     * Generates yrs picklist from 2021 to current yr + 1
     */ 
    public list<SelectOption> getYears(){
        
        String selectedYear;        
        List<SelectOption> years = new List<SelectOption> ();
        
        integer yr = date.today().year();        
        selectedYear = '' + yr;        
        yr += 1;
        
        String year = null;
        
        while(yr >= 2021) {            
            year = '' + yr;            
            years.add(new SelectOption(year, year));            
            yr --;            
        }
        
        return years;       
    }
    
    public list <SelectOption> getBannerGroups(){
        
        List <SelectOption> bannerGroups = new List <SelectOption> ();            
        bannerGroups.add(new SelectOption('All', 'All'));
        
        List <Account> accList = [Select id, Name, My_Sales_Id__c
                                  from Account
                                  where RecordTypeId =: Utilities.getRecordTypeId('Account', 'Banner Group') 
                                  order by Name];
                              
        for(Account accRec : accList) {            
            if(accRec.My_Sales_Id__c != null & accRec.My_Sales_Id__c != '')                
                bannerGroups.add(new SelectOption(accRec.My_Sales_Id__c,accRec.Name));            
        }  
        
        return bannerGroups;        
    }
    
    public list<SelectOption> getGradings(){
        
        List <SelectOption> gradings = new List <SelectOption> ();
        
        gradings.add(new SelectOption('All', Label.All));
        
        for(Schema.PicklistEntry f : Account.Account_Grading__c.getDescribe().getPicklistValues()) {         
            gradings.add(new SelectOption(f.getValue(), f.getLabel()));            
        }
        
        return gradings;          
    }
    
    public List <SelectOption> getPriorityKPI(){
        
        List <SelectOption> kpi = new List<SelectOption>();     
        kpi.add(new SelectOption('All', 'All'));
        
        for( Schema.PicklistEntry f : Objective__c.Priority_KPI__c.getDescribe().getPicklistValues()) {         
            kpi.add(new SelectOption(f.getValue(), f.getLabel()));        
        }
        
        return kpi;     
    }
    
    public List <SelectOption> getTaskStatusObjective(){
        
        List <SelectOption> ts = new List<SelectOption>();        
        ts.add(new SelectOption('All', 'All'));        
        Map <String, ObjectiveStatus__c> statusMap = ObjectiveStatus__c.getAll();        
        List <String> sequenceOfTaskList = new list<String>();        
        sequenceOfTaskList.addAll(statusMap.keySet());        
        sequenceOfTaskList.sort();
        system.debug('sequenceOfTaskList '+sequenceOfTaskList);
        
        for(String key : sequenceOfTaskList) {          
            ts.add(new SelectOption(key, key));         
        }
        system.debug('statusKey '+ ts);
        return ts;      
    }
    
    public List <SelectOption> getTaskStatusCallVisit(){
        
        List <SelectOption> ts = new List<SelectOption>();        
        ts.add(new SelectOption('All', 'All'));
        
        Map <String, CallVisitStatus__c> statusMap = CallVisitStatus__c.getAll();
        
        List <String> sequenceOfTaskList = new List<String>();        
        sequenceOfTaskList.addAll(statusMap.keySet());        
        sequenceOfTaskList.sort();
        
        for(String key : sequenceOfTaskList) {            
            ts.add(new SelectOption(key, key));            
        }
        
        return ts;        
    }

    public List <SelectOption> geteventStatusCallVisit(){
        
        List <SelectOption> ts = new List<SelectOption>();        
        ts.add(new SelectOption('All', 'All'));
        
        Map <String, CallVisitStatus__c> statusMap = CallVisitStatus__c.getAll();
        
        List <String> sequenceOfeventList = new List<String>();        
        sequenceOfeventList.addAll(statusMap.keySet());        
        sequenceOfeventList.sort();
        
        for(String key : sequenceOfeventList) {            
            ts.add(new SelectOption(key, key));            
        }
        
        return ts;        
    }
    
    public List <SelectOption> getCallCycleAustralia(String userLocation, String selectedYear, Date todaysDate){
        
        currentCallCycle = null;        
        List <SelectOption> callCycles = new List <SelectOption> ();
        
        List <Call_Cycle__c> ccList = [Select Start_Date__c, End_Date__c, Call_Cycle__c, Number_Of_Weeks__c
                                       from Call_Cycle__c
                                       where Location__c =: userLocation and year__c =: selectedYear
                                       and Call_Cycle__c != null
                                       order by Call_Cycle__c];
        
        for(Call_Cycle__c ccRec : ccList) {                
            callCycles.add(new SelectOption(ccRec.Call_Cycle__c, ccRec.Call_Cycle__c));              
            if(todaysDate <= ccRec.End_Date__c && todaysDate >= ccRec.Start_Date__c ){                
                currentCallCycle = ccRec;                
            }        
        }
        
        if(currentCallCycle == null){
                                        
           selectedYear = '' + (todaysDate.year() - 1);           
           callCycles.clear();
           
           for(Call_Cycle__c ccRec : [Select Start_Date__c, End_Date__c, Call_Cycle__c, Number_Of_Weeks__c
                                      from Call_Cycle__c
                                      where Location__c =: userLocation and year__c =: selectedYear
                                      and Call_Cycle__c != null
                                      order by Call_Cycle__c]) {
               
               callCycles.add(new SelectOption(ccRec.Call_Cycle__c , ccRec.Call_Cycle__c));               
               if(todaysDate <= ccRec.End_Date__c && todaysDate >= ccRec.Start_Date__c ){                    
                     
                    currentCallCycle = ccRec;                    
               }            
           }                      
            
           if(currentCallCycle == null) {                 
                if(ccList.size() > 0)        
                    currentCallCycle = ccList[0];
                    
                /*
                 * NOTE Please do not combine below 2 loops(for)
                 */                    
                for(Call_Cycle__c ccRec : ccList) {                 
                    callCycles.add(new SelectOption(ccRec.Call_Cycle__c , ccRec.Call_Cycle__c));                    
                }
                
                for(Call_Cycle__c ccRec : ccList) {                    
                    if(todaysDate < ccRec.Start_Date__c && currentCallCycle.Start_Date__c < ccRec.Start_Date__c ){                        
                        currentCallCycle = ccRec;                        
                        break;                        
                    }                 
                }                
                selectedYear = '' + todaysDate.year();                
            }            
        }       
        
        this.selectedYear = selectedYear;       
        return callCycles;      
    }
    
    public List <SelectOption> getOutlets(Id currentUserId , String roleId){
        
        List <SelectOption> outlets = new List<SelectOption>();        
        set<Id> userIds = new Set<Id>();        
        
        // Added this part in arxxus advantage   
        
		map<string,Integer> OwnerIdVsAccountCount = new map<string,Integer>();
		for(AggregateResult aggr : database.query('SELECT count(Id) accountCount,OwnerId FROM Account group by OwnerId')){
		    system.debug('==aggr==' +aggr );
		    OwnerIdVsAccountCount.put( string.valueOf(aggr.get('OwnerId')),integer.valueOf(aggr.get('accountCount')));
		}
		system.debug('==OwnerIdVsAccountCount==' + OwnerIdVsAccountCount);
		system.debug('==OwnerIdVsAccountCountSize==' + OwnerIdVsAccountCount.size());
		
		if(roleId != null && roleId != '') {        
                List<User> users = Utilities.getRoleSubordinateUsers(roleId);  
                system.debug('##USERs' + json.serialize(users));         
                for(User u : users){                
                    if(u.isActive == true && OwnerIdVsAccountCount.containsKey(u.Id))   {
                       outlets.add(new SelectOption(u.Id,u.Name));          
                    } else if(!OwnerIdVsAccountCount.containsKey(u.Id)) {
                        system.debug('=====This owner have no account ======' + u.Id );
                        userIds.add(u.Id);
                    }                         
                } 
                system.debug('=====userIds size======' + userIds.size());
          }    
         system.debug('=====outlets size======' + outlets.size());  
       
        return outlets;     
    }
    
    public list<SelectOption> getObjectiveSettingChannel(){
    
    List <SelectOption> channels = new List <SelectOption> ();
        
        channels.add(new SelectOption('All', Label.All));
        
        for(Schema.PicklistEntry f : Objective__c.Channel__c.getDescribe().getPicklistValues()) {         
            channels.add(new SelectOption(f.getValue(), f.getLabel()));            
        }
        
        return channels;          
    }
    
    public list<SelectOption> getAccountChannel(){
    
    List <SelectOption> channels = new List <SelectOption> ();
        
        channels.add(new SelectOption('All', Label.All));
        
        for(Schema.PicklistEntry f : Account.Channel__c.getDescribe().getPicklistValues()) {         
            channels.add(new SelectOption(f.getValue(), f.getLabel()));            
        }
        
        return channels;          
    }
    
    public List <SelectOption> getObjectives(String year, String selectedCallCycle, String region, String selectedPriorityKpi){
        
        List <SelectOption> objectives = new List<SelectOption>();      
        currentObjectivesMap = new map<Id, Objective__c>();     
        currentObjectivesIdList = new list<Id>();       
        objectives.add(new SelectOption('All','All'));
        
        system.debug('## year : ' + year);
        
        List<Objective__c> objectiveList;
        if(selectedPriorityKpi == 'All') {      
            if(region == null || region == '') {            
                objectiveList = [ Select id, Name, Type_of_Objective__c, Channel__c, Priority_KPI__c, Execution_Standard__c, Support_Deal__c, Enable_Add_All_Remove_All__c, 
                                  Call_Cycle_Formula__c, Call_Cycle__c, Category_of_Objective__c, Product__c, Product_Group__c, Region__c, ROI__c, Sub_level__c, Target__c,
                                  Unique_Field__c, Year__c
                                  from Objective__c
                                  where Call_Cycle_Formula__c =: selectedCallCycle
                                  and Type_of_Objective__c =: 'National Objective'
                                  and Year__c =: year 
                                  order by Priority_KPI__c ASC, Name ASC];                            
            } else {                
                objectiveList = [ Select id, Name, Type_of_Objective__c, Channel__c, Priority_KPI__c, Execution_Standard__c, Support_Deal__c, Enable_Add_All_Remove_All__c, 
                                  Call_Cycle_Formula__c, Call_Cycle__c, Category_of_Objective__c, Product__c, Product_Group__c, Region__c, ROI__c, Sub_level__c, Target__c,
                                  Unique_Field__c, Year__c
                                  from Objective__c 
                                  where Call_Cycle_Formula__c =: selectedCallCycle 
                                  and (Type_of_Objective__c =:'National Objective' or (Type_of_Objective__c =: 'State Objective' and Region__c =: region)) 
                                  and Year__c =: year 
                                  order by Type_of_Objective__c ASC, Priority_KPI__c ASC, Name ASC];                
            }       
        } else {            
            if(region == null || region == '') {            
                objectiveList = [ Select id, Name, Type_of_Objective__c, Channel__c, Priority_KPI__c, Execution_Standard__c, Support_Deal__c, Enable_Add_All_Remove_All__c, 
                                  Call_Cycle_Formula__c, Call_Cycle__c, Category_of_Objective__c, Product__c, Product_Group__c, Region__c, ROI__c, Sub_level__c, Target__c,
                                  Unique_Field__c, Year__c
                                  from Objective__c
                                  where Call_Cycle_Formula__c =: selectedCallCycle
                                  and Type_of_Objective__c =: 'National Objective'
                                  and Year__c =: year
                                  and Priority_KPI__c =: selectedPriorityKpi
                                  order by Priority_KPI__c ASC, Name ASC];                              
            } else {                
                objectiveList = [ Select id, Name, Type_of_Objective__c, Channel__c, Priority_KPI__c, Execution_Standard__c, Support_Deal__c, Enable_Add_All_Remove_All__c, 
                                  Call_Cycle_Formula__c, Call_Cycle__c, Category_of_Objective__c, Product__c, Product_Group__c, Region__c, ROI__c, Sub_level__c, Target__c,
                                  Unique_Field__c, Year__c
                                  from Objective__c
                                  where Call_Cycle_Formula__c =: selectedCallCycle 
                                  and (Type_of_Objective__c =:'National Objective' or (Type_of_Objective__c =: 'State Objective' and Region__c =: region)) 
                                  and Year__c =: year
                                  and Priority_KPI__c =: selectedPriorityKpi
                                  order by Type_of_Objective__c ASC, Priority_KPI__c ASC, Name ASC];                
            }           
        }               
        
        for(Objective__c objRec : objectiveList)  {         
            objectives.add(new SelectOption(objRec.Id, objRec.Name));           
            currentObjectivesMap.put(objRec.Id, objRec);            
            currentObjectivesIdList.add(objRec.Id);         
        }            
        
        return objectives;      
    }
    
    public List <SelectOption> getObjectivesForObjectMangmt(String year, String region, String selectedPriorityKpi, String selectedObjectiveChannel){
        
        List <SelectOption> objectives = new List<SelectOption>();      
        currentObjectivesMap = new map<Id, Objective__c>();     
        currentObjectivesIdList = new list<Id>();       
        objectives.add(new SelectOption('All','All'));
        
        List<Objective__c> objectiveList;

        Date dateToday = system.today(); 

        
        if(selectedPriorityKpi == 'All') {        
            if(region == null || region == '') {             
                objectiveList = [ Select id, Name, Type_of_Objective__c, Channel__c, Priority_KPI__c, Execution_Standard__c, Support_Deal__c, Enable_Add_All_Remove_All__c, 
                                  Call_Cycle_Formula__c, Call_Cycle__c, Category_of_Objective__c, Product__c, Product_Group__c, Region__c, ROI__c, Sub_level__c, Target__c,
                                  Unique_Field__c, Year__c, Start_Date__c, End_Date__c
                                  from Objective__c
                                  where Type_of_Objective__c =: 'National Objective'
                                  and (  End_Date__c >=  : dateToday and End_Date__c <= :dateToday) 
                                  order by Channel__c ASC, Priority_KPI__c ASC, Name ASC];                 
             System.debug('=====in condition region == null || region == ');
                } else {                
                objectiveList = [ Select id, Name, Type_of_Objective__c, Channel__c, Priority_KPI__c, Execution_Standard__c, Support_Deal__c, Enable_Add_All_Remove_All__c, 
                                  Call_Cycle_Formula__c, Call_Cycle__c, Category_of_Objective__c, Product__c, Product_Group__c, Region__c, ROI__c, Sub_level__c, Target__c,
                                  Unique_Field__c, Year__c, Start_Date__c, End_Date__c
                                  from Objective__c 
                                  where  (Type_of_Objective__c =:'National Objective' or (Type_of_Objective__c =: 'State Objective' and Region__c =: region)) 
                                  and  (Start_Date__c <= :dateToday and End_Date__c >= : dateToday)
                                  order by Type_of_Objective__c ASC, Channel__c ASC, Priority_KPI__c ASC, Name ASC];               
                
                System.debug('===== Not in condition region == null || region == ');
                }       
        } else {            
            if(region == null || region == '') {            
                objectiveList = [ Select id, Name, Type_of_Objective__c, Channel__c, Priority_KPI__c, Execution_Standard__c, Support_Deal__c, Enable_Add_All_Remove_All__c, 
                                  Call_Cycle_Formula__c, Call_Cycle__c, Category_of_Objective__c, Product__c, Product_Group__c, Region__c, ROI__c, Sub_level__c, Target__c,
                                  Unique_Field__c, Year__c, Start_Date__c, End_Date__c
                                  from Objective__c
                                  where  Type_of_Objective__c =: 'National Objective'
                                  and Priority_KPI__c =: selectedPriorityKpi
                                  and (End_Date__c >= :dateToday and End_Date__c <= :dateToday)   
                                  order by Channel__c ASC, Priority_KPI__c ASC, Name ASC];                              
            } else {                
                objectiveList = [ Select id, Name, Type_of_Objective__c, Channel__c, Priority_KPI__c, Execution_Standard__c, Support_Deal__c, Enable_Add_All_Remove_All__c, 
                                  Call_Cycle_Formula__c, Call_Cycle__c, Category_of_Objective__c, Product__c, Product_Group__c, Region__c, ROI__c, Sub_level__c, Target__c,
                                  Unique_Field__c, Year__c, Start_Date__c, End_Date__c
                                  from Objective__c
                                  where (Type_of_Objective__c =:'National Objective' or (Type_of_Objective__c =: 'State Objective' and Region__c =: region)) 
                                  and Priority_KPI__c =: selectedPriorityKpi
                                  and (End_Date__c >= :dateToday and End_Date__c <= :dateToday)  
                                  order by Type_of_Objective__c ASC, Channel__c ASC, Priority_KPI__c ASC, Name ASC];                
            }           
        }
        
           system.debug('=======objectiveList==========' + objectiveList);
        List<Objective__c> newObjectiveList = getSortedObjectivesAccordingToChannel(objectiveList);
           system.debug('=======newObjectiveList==========' + newObjectiveList);
         
        if(selectedObjectiveChannel == 'All'){
          for(Objective__c objRec : newObjectiveList)  {            
            objectives.add(new SelectOption(objRec.Id, objRec.Name));           
            currentObjectivesMap.put(objRec.Id, objRec);            
            currentObjectivesIdList.add(objRec.Id);         
          }            
        }
        else{
          for(Objective__c objRec : newObjectiveList)  {         
            if(selectedObjectiveChannel == objRec.Channel__c){
              objectives.add(new SelectOption(objRec.Id, objRec.Name));         
              currentObjectivesMap.put(objRec.Id, objRec);          
              currentObjectivesIdList.add(objRec.Id);         
            }
          } 
        }
         system.debug('=======objectives==========' + objectives);
         system.debug('=======currentObjectivesMap==========' + currentObjectivesMap);
         system.debug('=======currentObjectivesIdList==========' + currentObjectivesIdList);
        return objectives;       
    }
    
    private List<Objective__c> getSortedObjectivesAccordingToChannel(List<Objective__c> objectiveList) {
        if (null == objectiveList)
            return null;
        List<Objective__c> tempList1 = new List<Objective__c>();
        List<Objective__c> tempList2 = new List<Objective__c>();
        List<Objective__c> tempList3 = new List<Objective__c>();
        List<Objective__c> sortedList = new List<Objective__c>();
        
        for (Objective__c obj : objectiveList) {
            if (obj.Channel__c == 'Off-Premise')
                tempList1.add(obj);
            else if (obj.Channel__c == 'On-Premise')
                tempList2.add(obj);
            else
                tempList3.add(obj);
        }
        
        sortedList.addAll(tempList1);
        sortedList.addAll(tempList2);
        sortedList.addAll(tempList3);
        
        return sortedList;
    }
    
    private List<Call_Cycle__c> fetchCallCycle( String selectedCallCycle, String year){

        return [select Id, Start_Date__c, End_Date__c,Call_Cycle__c,Year__c 
                    from Call_Cycle__c 
                    where Call_Cycle__c =: selectedCallCycle
                    and 
                    Year__c =: year];
   }
    
    /*
     * Returns the Call Cycle record populated from most recent call on CallCycleAustralia method.
     * Call this method after call of CallCycleAustralia method only to get recent data
     */
    public Call_Cycle__c getcurrentCallCycle(){        
        return currentCallCycle;        
    }
    
    /*
     * Returns the Objective Map populated from most recent call on getObjectives method.
     * Call this method after call of getObjectives method only to get recent data
     */
    public Map<Id, Objective__c> getCurrentObjectivesMap(){        
        return currentObjectivesMap;        
    }   
    
    /*
     * Returns the Objective Map populated from most recent call on getObjectives method.
     * Call this method after call of getObjectives method only to get recent data
     */
    public List <Id> getCurrentObjectivesIdList(){      
        return currentObjectivesIdList;     
    }
    
    /*Returns the All task Status values from status */
    /*Changes related to case no. #00021333
		Author: Pratik C. (Arxxus)*/
    public List<String> getTaskStatusValues(){
       List<String> taskStatusValues= new List<String>();
		Schema.DescribeFieldResult fieldResult = Task.Status.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
			taskStatusValues.add(pickListVal.getLabel());
		}     
		return taskStatusValues;
    }


    public List<SelectOption> getAllUsers(){
        List<User> listUser = [SELECT Id, Name FROM User WHERE isActive = TRUE ORDER BY Name];

        List <SelectOption> users = new List<SelectOption>();        

        for(User u : listUser){                
            users.add(new SelectOption(u.Id,u.Name));    
        }
       
        return users;     
    }
    
}