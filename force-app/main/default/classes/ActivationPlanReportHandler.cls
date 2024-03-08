/**
 * @author : Gunwant Patidar
 * @description : This class fetches all the promotions based on year select from list and create a JSON string which is used 
 					In JQuery to create promotions data on VF page.
 * @created date: 01/06/2013
 					
 */
public class ActivationPlanReportHandler{
	//public variables 
	public transient list<string> weekStartDates{set;get;}
	public transient Integer quarter1Colspan{set;get;}
	public transient Integer quarter2Colspan{set;get;}
	public transient Integer quarter3Colspan{set;get;}
	public transient Integer quarter4Colspan{set;get;}
	public transient Integer JanuaryQuarterColspan{set;get;}
 	public transient Map<string,Integer> monthMap{set;get;}
 	public transient list<string> monthList{get;set;}
 	public transient Integer selectedYear{get;set;}
 	public transient boolean showTableGrid{get;set;}
  	Public transient list<ActivationPlanHelper> promotionHelperList{get;set;}
  	Public transient list<ActivationPlanHelper> accountBrandList{get;set;}
 	Public transient Date startMondayDateOfYear;
 	Public transient list<Promotion__c> promotionList;
 	Public transient list<String> selectedBannerGroupAccount{get;set;}
 	Public transient list<SelectOption> accountOptions = new list<SelectOption>();
 	Public transient String promotionsJSON{get;set;}
 	Public transient list<SelectOption> stateAvailableList {get;set;}
 	Public transient list<String> stateSelected {get;set;}
 	Public transient Boolean showBannerGroupLimitError{get;set;}
 	
  
 	// set previous year, current and current+2 years in list
 	// @return list<SelectOption>: 2012,2013,2014,2015
 	public List<SelectOption> getYears(){
 		List<SelectOption> options = new List<SelectOption>();
 		Date currentDate = system.today();
 		Integer prevYear = currentDate.year()-1;
 		Integer nextYear = currentDate.year() + 1;
 		Integer nextToNextYear = currentDate.year() + 2;
 		options.add(new SelectOption('','-None-'));
 		options.add(new SelectOption(string.valueOf(prevYear),string.valueOf(prevYear)));
 		options.add(new SelectOption(string.valueOf(currentDate.year()),string.valueOf(currentDate.year())));
 		options.add(new SelectOption(string.valueOf(nextYear),string.valueOf(nextYear)));
 		options.add(new SelectOption(string.valueOf(nextToNextYear),string.valueOf(nextToNextYear)));
 		return options;
 	} 
 	// get selected year and calculate weeks in a quarter
 	// set offset for q1 monday and then add 7 till end of q1
 	// Quarter starts from Feburuary. 
 	// count total mondays in particular quarter and set them as colspan for that quarter
 	// if Total mondays in QUarter is 13 then colspan = 13 
 	private Integer getWeeksInQuarter(Date startDate, Integer selectedYear,string quarter){
 		Integer NumberOfWeeksInQuarter = 0;
 		Date quarterEndMonth ;
 		
 		if(quarter == 'q4')
 			quarterEndMonth = startDate.addMonths(2);
 		else if(quarter == 'JanQuarter')
 			quarterEndMonth = startDate.addMonths(1);
 		else 
 			quarterEndMonth = startDate.addMonths(3);
 			
 		quarterEndMonth = quarterEndMonth.addDays(-1);
 		
 		
 		system.debug('QuarterNew Date: ' + startDate);
 		system.debug('quarterEndMonth: ' + quarterEndMonth);
 		
 		datetime startingDateTime   = DateTime.newInstance(startDate, Time.newInstance(0, 0, 0, 0));
 		
 		Integer MondayOffset = 0;
 		if(startingdatetime.format('EEEE')=='Tuesday'){
 			MondayOffset = 6;
 		} else if(startingdatetime.format('EEEE')=='Wednesday'){
 			MondayOffset  = 5;
 		} else if(startingdatetime.format('EEEE')=='Thursday'){
 			MondayOffset  = 4;
 		} else if(startingdatetime.format('EEEE')=='Friday'){
 			MondayOffset  = 3;
 		} else if(startingdatetime.format('EEEE')=='Saturday'){
 			MondayOffset  = 2;
 		} else if(startingdatetime.format('EEEE')=='Sunday'){
 			MondayOffset  = 1;
 		} 
 		NumberOfWeeksInQuarter  = ((startDate.daysBetween(quarterEndMonth) - MondayOffset)/7) + 1;
 		return NumberOfWeeksInQuarter;
 	}
 	
 	// @ set : weekstartDates list, monthList, monthMap
 	// get starting monday of year, get yearEndMonth 
 	// add 7 days to each date and calculate total weeks in a year
 	private void getWeekStartDateMonth(Date startDate){
 		Date yearEndMonth ;
 		Datetime startingDateTime   = DateTime.newInstance(startDate, Time.newInstance(0, 0, 0, 0));
 		
 		
 		Date mondayDate = startDate;//= startDate.toStartofWeek().addDays(1);
 		if(startingDateTime.format('EEEE')=='Tuesday'){
 			mondayDate = mondayDate.addDays(6);
 		} else if(startingDateTime.format('EEEE')=='Wednesday'){
 			mondayDate  = mondayDate.addDays(5);
 		} else if(startingDateTime.format('EEEE')=='Thursday'){
 			mondayDate  = mondayDate.addDays(4);
 		} else if(startingDateTime.format('EEEE')=='Friday'){
 			mondayDate  = mondayDate.addDays(3);
 		} else if(startingDateTime.format('EEEE')=='Saturday'){
 			mondayDate  = mondayDate.addDays(2);
 		} else if(startingDateTime.format('EEEE')=='Sunday'){
 			mondayDate  = mondayDate.addDays(1);
 		} 
 		
 		startMondayDateOfYear = mondayDate;
 		yearEndMonth = startDate.addMonths(11).addDays(30);
 		
 		// Calculate monthColspan , add MonthName in monthList
 		// iterate till end of the year from starting of first monday of the year 
 		// calculate total mondays: for year 2013 it will be 7/1,14/1,21/1......
 		Datetime dateTimeMonth;
 		Integer monthColspan = 1;
 		String monthName = '';
 		String monday;
 		String monthNumber;
 		for(mondayDate = mondayDate ; mondayDate <= yearEndMonth; mondayDate.addDays(7)){
 			monthNumber = String.valueOf(mondayDate.month());
 			monday = String.valueOf(mondayDate.Day());
 			if(String.valueOf(mondayDate.Day()).length() == 1){
 				monday = '0'+mondayDate.Day();
 			} 
			//if(String.valueOf(mondayDate.month()).length() == 1) {
 				//monthNumber = '0'+mondayDate.month(); 
 			//}
 			weekStartDates.add(monday);//+ '/' + monthNumber);
 			mondayDate = mondayDate.addDays(7);
 			
 			dateTimeMonth   = DateTime.newInstance(mondayDate, Time.newInstance(0, 0, 0, 0));
 			
 			//set January in monthMap so that it fits in below criterira
 			// if monthName != ateTimeMonth.format('MMMM')
 			// then increment monthcolspan to 1 ,2, 3..
 			// when month get changed put that monthcolspan in monthMap
 			if(dateTimeMonth.format('MMMM') == 'January'){
 				monthName = dateTimeMonth.format('MMMM');
 			}
 			
 			
 			if(monthName != dateTimeMonth.format('MMMM')){
 				
 				monthMap.put(monthName,monthColspan);
 				monthList.add(monthName);
 				monthName = dateTimeMonth.format('MMMM');
 				
 				// set month colspan for December month
 				// count days between start week of Decemeber and last date of month and MOD 7 
 				// add 1 to monthColspan for border values . ie: start on 2nd Dec and last monday on 30st Dec
 				if(dateTimeMonth.format('MMMM') == 'December'){
 					Date decemberEndDate = Date.newInstance(selectedYear, 12, 31);
 					monthColspan = mondayDate.daysBetween(decemberEndDate)/7;
 					monthList.add(dateTimeMonth.format('MMMM'));
 					monthMap.put(dateTimeMonth.format('MMMM'),monthColspan + 1);
 				}
 				monthColspan = 1;
 			} else {
 				monthColspan++;
 			}
 		}
 		
 	}
 	
 	/**
 	 * @Author : Gunwant patidar
 	 * @description : This select option returns all Banner group account name for selected year's promotions.
 	 */
 	public list<SelectOption> getBannerGroupAccounts(){
 		//channelAvailableList = new list<SelectOption>();
 		stateAvailableList = new list<SelectOption>();
 		// set  Banner group names to picklist
 		List<Account> bannerGroupList = [select Id, Name 
 											FROM Account
 											WHERE RecordType.Name = 'Banner Group'
 											ORDER BY Name ASC];
 											
 		accountOptions = new list<SelectOption>();
 		// Fethces all the existing promotions for selected year
 		System.debug('Getting Accounts : ' + selectedYear);
 		//accountOptions.add(new SelectOption('None','None'));
		
 		for(Account banner : bannerGroupList){
	 		accountOptions.add(new SelectOption(banner.Name,banner.Name));
 		}
 		
 		// get channel picklist
 		//channelAvailableList.add(new SelectOption('None','None'));
 		//Schema.DescribeFieldResult optionFieldDescription = Account.Channel__c.getDescribe();
		//for(Schema.PicklistEntry pleOptions : optionFieldDescription.getPicklistValues()){
			//channelAvailableList.add(new SelectOption(pleOptions.getvalue(),pleOptions.getLabel()));
		//}
		
		// set State values in picklist
		List<State__c> stateList = [SELECT Id, Name
										FROM State__c
										ORDER BY Name ASC];
		for(State__c state : stateList){
			stateAvailableList.add(new SelectOption(state.Name,state.Name));
		}								
 		
 		return accountOptions;
 	}
 	
 	
   
 	//Constructor
 	public ActivationPlanReportHandler(){
 		showTableGrid = false;
 		promotionList = new list<Promotion__c>();
	}
	  	
  	// when year selected on page and user clicks on Run Report button this method get called and get all the promotions for selected year
  	public void getOnGoingPromotions(){
  		list<String> newSelectedAccounts = new list<String>();
  		list<String> newSelectedStates = new list<String>();
  		System.debug('selectedBannerGroupAccount: ' + selectedBannerGroupAccount);
  		promotionList = new list<Promotion__c>();
  		showBannerGroupLimitError = false;
  		String startdayMonth;
  		for(String s : selectedBannerGroupAccount){
  			System.debug('s: ' + s);
  			s = String.escapeSingleQuotes(s);
  			s = '\'' + s + '\'';
  			System.debug('s after: ' + s);
  			newSelectedAccounts.add(s);
  		}
  		
  		for(String s : stateSelected){
  			s = '\'' + s + '\'';
  			newSelectedStates.add(s);
  		}
  		System.debug('newSelectedAccounts: ' + newSelectedAccounts);
  		String query = 'select id, Name, Promoted_Range_ID__c,Promotion_Period_Start_Date__c, Promotion_Period_End_Date__c,'
	     						+ ' StartDayMonth__c, colspan__c, Promotion_Overlaped__c, Banner_Group_Account__c, Brand_Name__c, State__c, Channel__c'   			
								+ ' FROM Promotion__c'
								+ ' WHERE CALENDAR_YEAR(Promotion_Period_Start_Date__c) =' + selectedYear
								+ ' AND CALENDAR_YEAR(Promotion_Period_End_Date__c) =' +selectedYear
								+ ' AND recordtype.name = \'Standard Promotion\'' 
								+ ' AND Banner_Group_Account__c != null'
								+ ' AND Brand_Name__c != null'
								+ ' AND Banner_Group_Account__c IN '+newSelectedAccounts;
								
		if(selectedBannerGroupAccount.size() > 10){ 
			// TODO: add error on page	
			showBannerGroupLimitError = true;
		} else {
			if(stateSelected.size()>0){
				query += ' AND State__c IN '+newSelectedStates;
			}
			//if(channelSelected != 'None'){
				//System.debug('add channel to query');
				//query += ' AND Channel__c = ' + '\'' + channelSelected + '\'';
			//}
									
			query += ' ORDER BY Brand_Name__c ASC';
	  		
	 	 	Integer mapCounterOverlappedPromotions = 0; // this varibale distincts Overlapped Promotions as new <tr>
	 		
	 		promotionHelperList = new list<ActivationPlanHelper>();
	 		accountBrandList = new list<ActivationPlanHelper>();
		 	if(selectedYear != null){
		 		system.debug('selectedYear: ' + selectedYear);
		 		if(selectedYear != 0){
		  			showTableGrid = true;
		  		} else {
		  			showTableGrid = false;
		  			promotionHelperList = null;
		  		}
		  		
		  		monthList = new list<string>();
		 		
		      	monthMap       = new Map<string,Integer>(); 
		      	weekStartDates = new list<string>();
		      	
		      	//set each quarter's startmonth, endmonth
		      	Date startDateOfQuarter  = date.newinstance(selectedYear, 1, 1);
		      	
		      	JanuaryQuarterColspan = getWeeksInQuarter(startDateOfQuarter,selectedYear, 'JanQuarter');
		      	
		      	startDateOfQuarter  = date.newinstance(selectedYear, 2, 1);
		      	
		      	quarter1Colspan = getWeeksInQuarter(startDateOfQuarter,selectedYear, 'q1');
		      	
		      	startDateOfQuarter  = date.newinstance(selectedYear, 5, 1);
		      	
		      	quarter2Colspan = getWeeksInQuarter(startDateOfQuarter,selectedYear, 'q2');
		      	
		      	startDateOfQuarter  = date.newinstance(selectedYear, 8, 1);
		      	
		      	quarter3Colspan = getWeeksInQuarter(startDateOfQuarter,selectedYear, 'q3');
		      	
		      	startDateOfQuarter  = date.newinstance(selectedYear, 11, 1);
		      	
		      	quarter4Colspan = getWeeksInQuarter(startDateOfQuarter,selectedYear, 'q4');
		     	
		     	// set weekStartDate list, monthMap, monthList
		     	startDateOfQuarter  = date.newinstance(selectedYear, 1, 1);
		     	getWeekStartDateMonth(startDateOfQuarter);
	 		}
 			System.debug('query: ' + query);
 			try{
 				promotionList = Database.query(query);
 			} catch (Exception e){
 				System.debug('QueryException: ' + e);
 			}
		}
    	
     	// iterate on accountBrandPromotionMap's keyset and get list of promotions agianst each key
     	// then set a colspan for that prmotion and put promtion name in helper class
     	// set dayMonth cells to be skipped from left on page
     	Integer promotionStartDate;
     	Integer promtoionStartMonth;
     	Date promotionStartDateMonth;
     	Integer totalWeeksFromYearStartToPromotionStartDate;
     	for(Promotion__c promotion : promotionList){
     		// creates <tr> for table 
     		ActivationPlanHelper planHelper = new ActivationPlanHelper();
     		ActivationPlanHelper accountBrandData = new ActivationPlanHelper();
     		
     		accountBrandData.aN = promotion.Banner_Group_Account__c;
     		accountBrandData.bN = promotion.Brand_Name__c;
     		accountBrandData.sN = promotion.State__c;
     		accountBrandData.cN = promotion.Channel__c;
     		accountBrandList.add(accountBrandData);
 			// set number of cells to be skiipped for a promotion to render on page
 			startdayMonth = promotion.StartDayMonth__c;
 			list<String> dayMonthOfMonday = startdayMonth.split('/');
 			promotionStartDate = Integer.valueOf(dayMonthOfMonday[0]);
 			promtoionStartMonth = Integer.valueOf(dayMonthOfMonday[1]);
 				     			
 			promotionStartDateMonth = Date.newInstance(selectedYear, promtoionStartMonth, promotionStartDate);
 			totalWeeksFromYearStartToPromotionStartDate = (startMondayDateOfYear.daysBetween(promotionStartDateMonth)/7) + 2;
 			
 			// assign values from promtoion to helper class
 		 	planHelper.cS = Integer.valueOf(promotion.colspan__c);
 		 	planHelper.bN = promotion.Brand_Name__c;
 		 	planHelper.pN = promotion.name;
 		 	planHelper.dM = totalWeeksFromYearStartToPromotionStartDate; // cells to be skipped from left
     		
     		// this list contains Account Name, brand Name and list of promotions associated with these account and brand
     		// e.g: test Campari, Sky blue,list<promotion,1,promotion 2,.,.,.,.>
     		 promotionHelperList.add(planHelper);
     	}
     	// create JSON String
     	
     	promotionsJSON = JSON.serialize(promotionHelperList);
     	System.debug('JSON: ' + promotionsJSON);
	}
}