/**
 * @author    : Created by Geeta Kushwaha on 8 Apr, 2013  geeta.kushwaha@arxxus.com
 * @Purpose   : Helper class for CallVisitController
 * @Criteria  : 
 * @Modified  : Geeta Kushwaha on 29 Apr, 2013  geeta.kushwaha@arxxus.com
 */
public class DayDateWeekCalculator {
	
	String userLocation {get; set;}
	
	public Date refDate {get; set;}
	
	public DayDateWeekCalculator(){
		
	}
	
	public DayDateWeekCalculator(String userLocation) {
		
		refdate = date.newinstance(1900, 1, 7);
		
		this.userLocation = userLocation;
		
	}
	
	/*
     * Calculate Activity Date for a given call cycle week
     */
    public date getActivityDate(Integer dayName, String weekName, Date startDate){
        
        date returnValue;
    
        if(userLocation == 'australia') {
            
            integer weekNumber = Integer.valueOf(weekName.substring(5));
            
            if(weekNumber == 1)
            
                returnValue = startDate.addDays(dayName);
            
            else
            
               returnValue = startDate.addDays(7* (weekNumber - 1) + dayName);
        
        }
        
        return returnValue;
        
    }
	
	/*
     * Return day of task
     */
    
    public String getActivityDay(Integer dayName){
        
        if(dayName == 1){
            
            return 'Mon';
            
        }
        
        else if(dayName == 2){
            
            return 'Tue'; 
            
        }
        
        else if(dayName == 3){
        
            return 'Wed';
        }
        
        else if(dayName == 4){
        
            return 'Thu';
        }
        
        else if(dayName == 5){
        
            return 'Fri';
        
        }
        
        else if(dayName == 6){
        
            return 'Sat';
        
        }
        
        else if(dayName == 0){
        
            return 'Sun';
        
        }
        
        return '';
        
    }
	
	/*
	 * Returns the time duration of selectedWeek
	 */
	public list <Date> getWeekDuration(String selectedWeek, Call_Cycle__c selectedCallCycleRec){
        
        list <Date> duration = new list<Date>();
        
        try {
        
	        if(selectedWeek == 'All') {
	            
	            duration.add(selectedCallCycleRec.Start_Date__c);
	            
	            duration.add(selectedCallCycleRec.End_Date__c);
	            
	        }
	        
	        else {
	        
	            integer weekNumber = Integer.valueOf(selectedWeek.substring(5));
	                
	                weekNumber --;
	        
	            if(userLocation == 'Australia') {
		            
		            if(weekNumber == 0){
		                
		                duration.add(selectedCallCycleRec.Start_Date__c);
		                
		            }
		            
		            else{
		                
		                duration.add(selectedCallCycleRec.Start_Date__c.addDays(weekNumber * 7));
		                
		            }
		            
		            
		            duration.add(duration[0].addDays(6));
	            
	            }
	            
	           
	            
	        }
        
        }
        
        catch(NullPointerException e) {
        	
        	
        	
        }
        
        return duration;
        
    }
	
	/*
	 * Returns the Call Cycle record for the selected year, selected call cycle & selected month
	 * When a call Cycle record is not found it returns QueryException
	 */
	public Call_Cycle__c getCallCycleRec(String selectedYear, String selectedCallCycle, String selectedMonth) {
		
		Call_Cycle__c selectedCallCycleRec ;

		if(userLocation == 'australia') {
                
            selectedCallCycleRec = [Select id, End_Date__c, Start_Date__c, Number_Of_Weeks__c
                                    from Call_Cycle__c
                                    where Year__c =: selectedYear and Call_Cycle__c =: selectedCallCycle and Location__c =: userLocation];
        
        }    
            
        return selectedCallCycleRec;     
		
	}             
	
	/*
	 * Returns the name of the Week from the Task ActivityDate using the call cycle & selected Week
	 */
	public String getWeekName(Date dueDate, Call_Cycle__c selectedCallCycleRec, String selectedWeek) {
        
        if(selectedWeek == 'All') {
           
            if(userLocation == 'australia')
                return 'Week '+ (Integer)((Decimal) (selectedCallCycleRec.Start_Date__c.daysBetween(dueDate) + 1)).divide(7, 0, System.RoundingMode.CEILING);
                
            

        }
        
        return selectedWeek;
        
    }

    /*
     * Return the number of the day of the week
     */
    public Integer getNumberOfDay(String dayOfTheWeek){
        Integer dayNumber = 0;
        switch on dayOfTheWeek {
            when 'Monday' {
                dayNumber = 1;
            }
            when 'Tuesday'{
                dayNumber = 2;
            }
            when 'Wednesday'{
                dayNumber = 3;
            }
            when 'Thursday'{
                dayNumber = 4;
            }
            when 'Friday'{
                dayNumber = 5;
            }
            when 'Saturday'{
                dayNumber = 6;
            }
            when 'Sunday'{
                dayNumber = 7;
            }
         }

         return dayNumber;
    }

    public String getDayOfWeek(Date refDate){
        Date d = refDate;
        Datetime dt = (DateTime)d;
        String dayOfWeek = dt.format('EEEE');  

        return dayOfWeek;
    }
	
}