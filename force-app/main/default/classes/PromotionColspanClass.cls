/**
 * @Author : Gunwant Patidar
 * @Description : THis class set StartDate of any promotion to Monday date 
 * 				  Count colspans for each promotions
 				  Check Promotion dates overlapping	
 */
public class PromotionColspanClass {
	public static Integer getColspan(Date sDate, Date eDate){
		DateTime dttime = DateTime.newInstance(sDate, Time.newInstance(0, 0, 0, 0));
  		
  		system.debug('dttime: '  +dttime );
  		
  		system.debug('dttime format: ' + dttime.format('EEEE'));
  		String day = dttime.format('EEEE');
  		Date currentYearDate = sDate;
  		
  		// check if day is tuesday to thursday then substract day from date so that it should come on Monday
  		// if day is Ahead to Thursday then add some days so that it come on Monday
  		
  		if(day == 'Tuesday'){
  			
  			sDate = sDate.addDays(-1);
  			if(currentYearDate.Year() != sDate.year()){
  				sDate = sDate.addDays(7);
  			}
  			
  		} else if(day == 'Wednesday'){
  			system.debug('date: ' + day);
  			sDate = sDate.addDays(-2);
  			if(currentYearDate.Year() != sDate.year()){
  				sDate = sDate.addDays(7);
  			}
  		
  		} else if(day == 'Thursday'){ 
  			
  			sDate = sDate.addDays(-3);
  			if(currentYearDate.Year() != sDate.year()){
  				sDate = sDate.addDays(7);
  			}
  			
  		} else if(day == 'Friday'){
  			
  			sDate = sDate.addDays(3);
  		
  		} else if(day == 'Saturday'){
  			
  			sDate = sDate.addDays(2);
  		
  		} else if(day == 'Sunday'){
  			
  			sDate = sDate.addDays(1);
  			
  		}
  		
  		// end date
  		DateTime dttimeEndDate = DateTime.newInstance(eDate, Time.newInstance(0, 0, 0, 0));
  		currentYearDate = eDate;
  		String dayEndDate = dttimeEndDate.format('EEEE');
  		
  		// check if day is tuesday to thursday then substract day from date so that it should come on Monday
  		// if day is Ahead to Thursday then add some days so that it come on Monday
  		
  		if(dayEndDate == 'Tuesday'){
  			
  			eDate = eDate.addDays(-1);
  			
  		} else if(dayEndDate == 'Wednesday'){
  			
  			eDate = eDate.addDays(-2);
  		
  		} else if(dayEndDate == 'Thursday'){
  			
  			eDate = eDate.addDays(-3);
  			
  		} else if(dayEndDate == 'Friday'){
  			
  			eDate = eDate.addDays(3);
  			if(currentYearDate.Year() != eDate.year()){
  				sDate = sDate.addDays(-7);
  			}
  		
  		} else if(dayEndDate == 'Saturday'){
  			
  			eDate = eDate.addDays(2);
  			if(currentYearDate.Year() != eDate.year()){
  				sDate = sDate.addDays(-7);
  			}
  		
  		} else if(dayEndDate == 'Sunday'){
  			
  			eDate = eDate.addDays(1);
  			if(currentYearDate.Year() != eDate.year()){
  				sDate = sDate.addDays(-7);
  			}
  			
  		}
  		
  		
  		
  		integer days = sDate.daysBetween(eDate);
  		
  		integer colspanCount = days/7;
  		//String dayMonth = string.valueOf(sDate.day()) + string.valueOf(sDate.month());
  		
  		system.debug('colspanCount: ' + colspanCount+1);
  		//return colspanCount;
  		return colspanCount+1;
	
	}
	
	public static string getStartDayMonth(Date sDate){
		DateTime dttime = DateTime.newInstance(sDate, Time.newInstance(0, 0, 0, 0));
  		Date currentYearDate = sDate;
  		system.debug('dttime: '  +dttime );
  		
  		system.debug('dttime format: ' + dttime.format('EEEE'));
  		String day = dttime.format('EEEE');
  		
  		// check if day is tuesday to thursday then substract day from date so that it should come on Monday
  		// if day is Ahead to Thursday then add some days so that it come on Monday
  		
  		if(day == 'Tuesday'){
  			
  			sDate = sDate.addDays(-1);
  			if(currentYearDate.Year() != sDate.year()){
  				sDate = sDate.addDays(7);
  			}
  			
  		} else if(day == 'Wednesday'){
  			system.debug('date: ' + day);
  			sDate = sDate.addDays(-2);
  			if(currentYearDate.Year() != sDate.year()){
  				sDate = sDate.addDays(7);
  			}
  		
  		} else if(day == 'Thursday'){ 
  			
  			sDate = sDate.addDays(-3);
  			if(currentYearDate.Year() != sDate.year()){
  				sDate = sDate.addDays(7);
  			}
  			
  		} else if(day == 'Friday'){
  			
  			sDate = sDate.addDays(3);
  		
  		} else if(day == 'Saturday'){
  			
  			sDate = sDate.addDays(2);
  		
  		} else if(day == 'Sunday'){
  			
  			sDate = sDate.addDays(1);
  			
  		}
  		
  		String dayMonth = string.valueOf(sDate.day()) + '/' + string.valueOf(sDate.month());
  		
  		system.debug('dayMonth: ' + dayMonth);
  		//return dayMonth;
  		return dayMonth;
	}
	
	// Check overlap date for same account's and same brand's promotions
	@future
	public static void checkOverlapDates(set<Id> promotionIds, String triggerMode){
		list<Promoted_Range__c> promotedList = new list<Promoted_Range__c>();
		list<Promotion__c> existingPromotionList = new list<Promotion__c>();
		list<Promotion__c> promotionList = new list<Promotion__c>();
		set<string> promotionRangeIds = new set<string>();
		set<string> promotionBannerGrpIds = new set<string>();
		set<string> wholesalerBannerGrpIds = new set<string>();
		set<integer> promotionYears = new set<integer>();
		
		promotionList = [select id, Name, Promotion_Period_Start_Date__c, Promotion_Period_End_Date__c,
				            Promoted_Range_ID__c, Promotion_Overlaped__c, StartDayMonth__c, End_Day_Month__c
				            FROM Promotion__c
				            WHERE Id IN : promotionIds]; 
		
		list<Promotion_Banner_Group__c> promotionBannerGroupList;
 		list<Wholesaler_Banner_Group__c> wholesalerBannerGroupList;
 		
 		map<string,string> promotionBannerGroupMap = new map<string,string>();
 		map<string,string> wholesalerBannerGroupMap = new map<string,string>();
 		map<string,string> brandMap = new map<string,string>();
 		map<string,list<Promotion__c>> accountBrandTempMap = new map<string,list<Promotion__c>>();
		
		for(Promotion__c promotion : promotionList){
			//promotionRangeIds.add(promotion.Promoted_Range_ID__c);
			//promotionBannerGrpIds.add(promotion.name);
			if(promotion.Promotion_Period_Start_Date__c != null && promotion.Promotion_Period_End_Date__c != null){
				promotionYears.add(promotion.Promotion_Period_Start_Date__c.year());
				system.debug('promotionYears: ' + promotionYears);
			}
    	}
    	
    	// fetch existing promtion for a particular year exists in promotionYears set
    	existingPromotionList = [select id, Name, Promotion_Period_Start_Date__c, Promotion_Period_End_Date__c,
    								Promoted_Range_ID__c, Promotion_Overlaped__c, StartDayMonth__c, End_Day_Month__c
    								FROM Promotion__c
    								WHERE CALENDAR_YEAR(Promotion_Period_Start_Date__c) IN : promotionYears];
    								
    	// iterate through existing promotion and get promoted range ids and promotion banner group ids
    	for(Promotion__c promotion : existingPromotionList){
			promotionRangeIds.add(promotion.Promoted_Range_ID__c);
			promotionBannerGrpIds.add(promotion.name);
    	}
    								
    	
    	promotedList = [select id,Brand__r.Name, Promotion_Range_ID__c FROM Promoted_Range__c 
    					WHERE Promotion_Range_ID__c IN : promotionRangeIds];
    	
    	// get promotionBannerGroup reocords based on promotionBannerGrpIds				
    	promotionBannerGroupList = [select id,Promotion_ID__c ,Wholesaler_Banner_Group_ID__c 
    								FROM Promotion_Banner_Group__c
    								WHERE Promotion_Id__c IN :promotionBannerGrpIds];
    								
    								 
    					
    	// getting wholsalerBannerGroupIds in set
    	// put wholesalerBannerGroupIds corresponding to Promotion ids
    	for(Promotion_Banner_Group__c promotionbanGroup : promotionBannerGroupList){
    		wholesalerBannerGrpIds.add(promotionbanGroup.Wholesaler_Banner_Group_ID__c);
    		promotionBannerGroupMap.put(promotionbanGroup.Promotion_Id__c,promotionbanGroup.Wholesaler_Banner_Group_ID__c);
    	}
    	
    	// get wholesaler Banner Group records based on wholesalerBannerGroupIds
    	wholesalerBannerGroupList = [select id,Name, Banner_Group_Account__c, Banner_Group_Account__r.Name
    									FROM Wholesaler_Banner_Group__c
    									WHERE Name IN : wholesalerBannerGrpIds];
    									
    	// get account details in map for corresponding wholesalerBannerGroup Id
    	for(Wholesaler_Banner_Group__c wholesalerBannerGrp : wholesalerBannerGroupList){
    		wholesalerBannerGroupMap.put(wholesalerBannerGrp.Name,wholesalerBannerGrp.Banner_Group_Account__r.Name);
    		//wholesalerBannerGroupAccountIdMap.put(wholesalerBannerGrp.Name,wholesalerBannerGrp.Banner_Group_Account__c);
    	}
    	
    	// put  				
    	for(Promoted_Range__c promrange : promotedList){
    		brandMap.put(promrange.Promotion_Range_ID__c,promrange.Brand__r.Name);
    		//brandIdMap.put(promrange.Promotion_Range_ID__c,promrange.Brand__c);
    	}
    	// put promtions in a map
    	for(Promotion__c promotion : existingPromotionList){
    		//accountBrandTempMap contains all the account and Brand as key and list of promotions against each account brand
    		
    		String accName = wholesalerBannerGroupMap.get(promotionBannerGroupMap.get(promotion.Name));
    		String brandName = brandMap.get(promotion.Promoted_Range_ID__c);
    		
    		if(accountBrandTempMap.containsKey(accName + ':' + brandName)){
    			accountBrandTempMap.get(accName + ':' + brandName).add(promotion);
    		} else {
    			accountBrandTempMap.put(accName + ':' + brandName, new list<Promotion__c>{promotion});
    		}
    		
    	}
    	system.debug('accountBrandTempMap: ' + accountBrandTempMap);
    	// iterate through promotion list and check if any prmotion for same account and brand overlaps in the same date range
    	for(Promotion__c promotion: promotionList){
    		String accName = wholesalerBannerGroupMap.get(promotionBannerGroupMap.get(promotion.Name));
    		String brandName = brandMap.get(promotion.Promoted_Range_ID__c);
    		String accBrand = accName + ':' + brandName;
    		promotion.Promotion_Overlaped__c = false;
    		promotion.Banner_Group_Account__c = accName;
    		promotion.Brand_Name__c = brandName;
    		if(promotion.Promotion_Period_Start_Date__c != null && promotion.Promotion_Period_End_Date__c != null){
	    		if(accountBrandTempMap.containsKey(accBrand)){
	    			system.debug('accountBrandTempMap containsKey: ');
	    			
		    		for(Promotion__c promo : accountBrandTempMap.get(accBrand)){
		    			system.debug('promotion.id != promo.id: ' + promotion.id + '  ' + promo.id);
		    			if(promotion.id != promo.id && promo.Promotion_Period_Start_Date__c != null && promo.Promotion_Period_End_Date__c != null){	
			    			if(promotion.Promotion_Period_Start_Date__c.Year() == promo.Promotion_Period_Start_Date__c.Year() && promotion.Promotion_Period_End_Date__c.Year() == promo.Promotion_Period_End_Date__c.Year()){
			    				if(promotion.Promotion_Period_Start_Date__c <= promo.Promotion_Period_Start_Date__c
			    					&& promotion.Promotion_Period_End_Date__c > promo.Promotion_Period_Start_Date__c
			    					&& promo.Promotion_Overlaped__c != true){
			    						promotion.Promotion_Overlaped__c = true;
		    					} else if(promotion.Promotion_Period_Start_Date__c < promo.Promotion_Period_End_Date__c
			    					&& promotion.Promotion_Period_End_Date__c > promo.Promotion_Period_Start_Date__c
			    					&& promo.Promotion_Overlaped__c != true){
		    							promotion.Promotion_Overlaped__c = true;
		    					} else if((promotion.StartDayMonth__c == promo.StartDayMonth__c
			    					|| promotion.StartDayMonth__c == promo.End_Day_Month__c)
			    					&& promo.Promotion_Overlaped__c != true){
		    							promotion.Promotion_Overlaped__c = true;
		    					} else if((promotion.End_Day_Month__c == promo.StartDayMonth__c
			    					|| promotion.End_Day_Month__c == promo.End_Day_Month__c)
			    					&& promo.Promotion_Overlaped__c != true){
		    							promotion.Promotion_Overlaped__c = true;
		    					} 
			    			}
		    			}	
		    		}
	    		}
    		}
    	}
    	System.debug('triggerMode: ' + triggerMode);
    	if(triggerMode == 'isAfter'){
    		StaticVariableHandler.promotionTriggerRun = 2; // prevent calling @future method from future mthods twice
    		update promotionList;
    		
    	}				 		
	}
}