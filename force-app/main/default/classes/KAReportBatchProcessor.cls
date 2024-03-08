/*
 * Class Name : KAReportBatchProcessor
 * Description - This class is used for populating the data to be sent by email
 * @author Geeta Kushwaha (geeta.kushwaha@arxxus.com)
 * @revised : 24-12-2013 [created by Geeta Kushwaha]
 */ 
global with sharing class KAReportBatchProcessor implements Database.Batchable<sObject>, Database.Stateful{
	
	global Id bannerId;
	
	global String bannerGroupName;
	
	global String mySalesId;
	
	global String query = 'Select Product__c, Product__r.Classification__c, Product__r.Sub_Classification__c, Product__r.Brand__c, Nine_LE__c, Sale_Date__c From Sale_MySales__c  where'          
        
            + ' Banner_Group__c IN : allBannersIdSet'
            
            + ' and Sale_Date__c >=: minDate and Sale_Date__c <=: maxDate'; 
            
    /*global String query = 'Select Product__c, Product__r.Classification__c, Product__r.Sub_Classification__c, Product__r.Brand__c, Nine_LE__c, Sale_Date__c From Sale_MySales__c '
    
                            + 'where Banner_Group__c in (Select id from Account where Parent_Hierarchy__c LIKE '+'\'%,'+ mySalesId +',%\')';*/ 
	
	global String email;
	
	public map <String,map<String,map<String,KARowWrapper>>> rowMap; //Brand -> Sub Classification -> productId -> Wrapper
	
	public map<Id, String> brandMap;
	
	public set<Id> allBannersIdSet;
	
	set <String> classificationsset;
	
	global date selectedDate, maxDate, minDate;
	
	global set <date> allDateRangesSet;
	
    global date col1FromDate;
    
    global date col2FromDate; 
    
    global date col2ToDate;
    
    global date col6FromDate;
    
    global date col7FromDate; 
    
    global date col7ToDate;
    
    global date col11FromDate;
    
    global date col11ToDate;
    
    global date col12FromDate;
     
    global date col12ToDate;
    
    global date col15FromDate;
     
    global date col15ToDate;
    
    global date col16FromDate; 
    
    global date col16ToDate;
    
    global date col23FromDate; 
    
    global date col23ToDate;
    
    global date col24FromDate;
     
    global date col24ToDate;
    
    global date col27FromDate;
     
    global date col27ToDate;
    
    global date col28FromDate;
     
    global date col28ToDate;
    
    global date col40FromDate; 
    
    global date col40ToDate;
    
    global date col41FromDate;
     
    global date col41ToDate;
    
    global date col42FromDate; 
    
    global date col42ToDate;
    
    global date col43FromDate;
     
    global date col43ToDate;
    
    global date col44FromDate; 
    
    global date col44ToDate;
    
    global date col45FromDate; 
    
    global date col45ToDate;
    
    global date col46FromDate; 
    
    global date col46ToDate;
    
    global date col47FromDate; 
    
    global date col47ToDate;
    
    global date col48FromDate; 
    
    global date col48ToDate;
    
    global date col49FromDate; 
    
    global date col49ToDate;
    
    global date col50FromDate; 
    
    global date col50ToDate;
    
    global date col51FromDate; 
    
    global final date col51ToDate;
    
    private string text {get; set;}
    
    private string html {get; set;}

    global KAReportBatchProcessor(Id bannerId, String bannerGroupName, String email, String mySalesId){

        this.bannerId = bannerId;
        
        this.bannerGroupName = bannerGroupName;
      
        this.email = email;
        
        this.mySalesId = mySalesId;
        
        html = text = '';
        
        brandMap = new map<Id,String>();
      
        rowMap = new map <String,map<String,map<String,KARowWrapper>>>();
		
		for(Product__c prod : [select Id, Name, Classification__c, Sub_Classification__c, Brand__c, Brand__r.Name
		                 from Product__c]){

            brandMap.put(prod.Brand__c,prod.Brand__r.Name);             
		        
		    if(rowMap.containsKey(prod.Brand__c)){
		    	
		    	if(rowMap.get(prod.Brand__c).containsKey(prod.Sub_Classification__c))
		    	
		    	    rowMap.get(prod.Brand__c).get(prod.Sub_Classification__c).put(prod.Id,new KARowWrapper(prod.Name));
		    	
		    	else
		        
		            rowMap.get(prod.Brand__c).put(prod.Sub_Classification__c,new map<String,KARowWrapper>{prod.Id => new KARowWrapper( prod.Name)});
		        
		    }   
		    
		    else {
		        
		        rowMap.put(prod.Brand__c, new map<String,map<String,KARowWrapper>>{prod.Sub_Classification__c => new map<String,KARowWrapper>{prod.Id => new KARowWrapper(prod.Name)}});
		        
		    }                                   
		                    
		}
		
		allBannersIdSet = new map<Id,Account>((list <Account>)database.query('Select id from Account where Parent_Hierarchy__c LIKE '+'\'%,'+ mySalesId +',%\'')).keySet();
		
		selectedDate = minDate = maxDate = date.today(); 
		
		integer selectedYear = selectedDate.year();
		
		col1FromDate = date.newInstance(selectedYear, selectedDate.month(), 1);
		
		col2FromDate = date.newInstance(selectedYear-1, selectedDate.month(), 1);
		
		col2ToDate = date.newInstance(selectedYear-1, selectedDate.month(), selectedDate.day()); 
		
		col6FromDate = date.newInstance(selectedYear, 1, 1);    
		
		col7FromDate = date.newInstance(selectedYear-1, 1, 1);
		
		col7ToDate = date.newInstance(selectedYear-1, selectedDate.month(),selectedDate.day());   
		
		col11FromDate = date.newInstance(selectedYear, 1, 1);
		
		col11ToDate = date.newInstance(selectedYear, 3, 31);
		
		col12FromDate = date.newInstance(selectedYear-1, 1, 1);
		
		col12ToDate = date.newInstance(selectedYear-1, 3, 31);
		
		col15FromDate = date.newInstance(selectedYear, 4, 1);
		
		col15ToDate =  date.newInstance(selectedYear, 6, 30);   
		
		col16FromDate = date.newInstance(selectedYear-1, 4, 1);
		
		col16ToDate = date.newInstance(selectedYear-1,6,30);  
		
		col23FromDate = date.newInstance(selectedYear, 7, 1);
		
		col23ToDate = date.newInstance(selectedYear, 9, 30);  
		
		col24FromDate = date.newInstance(selectedYear-1, 7, 1);
		
		col24ToDate = date.newInstance(selectedYear-1, 9, 30);
		
		col27FromDate = date.newInstance(selectedYear, 10, 1);
		
		col27ToDate = date.newInstance(selectedYear, 12, 31);
		
		col28FromDate = date.newInstance(selectedYear-1, 10,1);
		
		col28ToDate = date.newInstance(selectedYear-1, 12, 31);
		
		col40FromDate = date.newInstance(selectedYear, 1, 1);
		
		col40ToDate = date.newInstance(selectedYear, 1, 31);
                                      
        if(selectedDate.month() >= 2){
        
            col41FromDate = date.newInstance(selectedYear, 2, 1);
           
            col41ToDate = date.newInstance(selectedYear, 2, date.daysInMonth(selectedYear, 2));
            
        }
        
        if(selectedDate.month() >= 3){
        	
            col42FromDate = date.newInstance(selectedYear, 3, 1);
           
            col42ToDate = date.newInstance(selectedYear, 3, 31);
        	
        }
        
        if(selectedDate.month() >= 4){
            
            col43FromDate = date.newInstance(selectedYear, 4, 1);
           
            col43ToDate = date.newInstance(selectedYear, 4, 30);
            
        } 
        
        if(selectedDate.month() >= 5){
            
            col44FromDate = date.newInstance(selectedYear, 5, 1);
           
            col44ToDate = date.newInstance(selectedYear, 5, 31);
            
        } 
        
        if(selectedDate.month() >= 6){
            
            col45FromDate = date.newInstance(selectedYear, 6, 1);
           
            col45ToDate = date.newInstance(selectedYear, 6, 30);
            
        } 
        
        if(selectedDate.month() >= 7){
            
            col46FromDate = date.newInstance(selectedYear, 7, 1);
           
            col46ToDate = date.newInstance(selectedYear, 7, 31);
            
        } 
        
        if(selectedDate.month() >= 8){
            
            col47FromDate = date.newInstance(selectedYear, 8, 1);
           
            col47ToDate = date.newInstance(selectedYear, 8, 31);
            
        } 
        
        if(selectedDate.month() >= 9){
            
            col48FromDate = date.newInstance(selectedYear, 9, 1);
           
            col48ToDate = date.newInstance(selectedYear, 9, 30);
            
        } 
        
        if(selectedDate.month() >= 10){
            
            col49FromDate = date.newInstance(selectedYear, 10, 1);
           
            col49ToDate = date.newInstance(selectedYear, 10, 31);
            
        } 
        
        if(selectedDate.month() >= 11){
            
            col50FromDate = date.newInstance(selectedYear, 11, 1);
           
            col50ToDate = date.newInstance(selectedYear, 11, 30);
            
        } 
        
        if(selectedDate.month() == 12){
            
            col51FromDate = date.newInstance(selectedYear, 12, 1);
           
            col51ToDate = date.newInstance(selectedYear, 12, 31);
            
        } 
         
        allDateRangesSet = new set<date>{ selectedDate, 
	                                      col1FromDate,
	                                      col2FromDate, col2ToDate,
	                                      col6FromDate,
	                                      col7FromDate, col7ToDate,
	                                      col11FromDate, col11ToDate,
	                                      col12FromDate, col12ToDate,
	                                      col15FromDate, col15ToDate,
	                                      col16FromDate, col16ToDate,
	                                      col23FromDate, col23ToDate,
	                                      col24FromDate, col24ToDate,
	                                      col27FromDate, col27ToDate,
	                                      col28FromDate, col28ToDate,
	                                      col40FromDate, col40ToDate,
	                                      col41FromDate, col41ToDate,
	                                      col42FromDate, col42ToDate,
	                                      col43FromDate, col43ToDate,
	                                      col44FromDate, col44ToDate,
	                                      col45FromDate, col45ToDate,
	                                      col46FromDate, col46ToDate,
	                                      col47FromDate, col47ToDate,
	                                      col48FromDate, col48ToDate,
	                                      col49FromDate, col49ToDate,
	                                      col50FromDate, col50ToDate,
	                                      col51FromDate, col51ToDate};
	                                      
        allDateRangesSet.remove(null);	                                      
                                      
        for(date d : allDateRangesSet) {
        	
        	if (d > maxDate) {
        		
        		maxDate = d;
        		
        	}
        	
        	if(d < minDate){
        		
        		minDate = d;
        		
        	}
        	
        }  
        
        classificationsset = new set<String>{'RTD','Glass','Wine'}; 
        
        for(String classification : classificationsset)  {
        	
        	rowMap.put(classification, new Map<String,map<String,KARowWrapper>>{classification => new map<String,KARowWrapper>{classification => new KARowWrapper(classification)}});
        	
        } 
        
        rowMap.put('TOTAL BANNER', new Map<String,map<String,KARowWrapper>>{'TOTAL BANNER' => new map<String, KARowWrapper> { 'TOTAL BANNER' => new KARowWrapper('TOTAL BANNER')}});
                           
      
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        
        System.debug('************* query '+query);
        
        System.debug('******************** allBannersIdSet '+allBannersIdSet);
        
        System.debug('******************** minDate '+minDate);
        
        System.debug('******************** maxDate '+maxDate);
    	
        return Database.getQueryLocator(query);
      
    }

    global void execute(Database.BatchableContext BC, List<Sale_MySales__c> mySalesRecords){
    	system.debug('My Sales Data list size = '+mySalesRecords);
    	for(Sale_MySales__c sales : mySalesRecords){
    		
    		/*
             * RTD, GLASS, WINE are the Product Classifications
             */
                
            if(sales.Product__r.Classification__c != null && sales.Product__r.Classification__c.length() > 0) {
                
                if(rowMap.containsKey(sales.Product__r.Classification__c) && rowMap.get(sales.Product__r.Classification__c).containsKey(sales.Product__r.Classification__c)){
                    
                    if(sales.Sale_Date__c  >= col1FromDate && sales.Sale_Date__c <= selectedDate){
                    	
                    	System.debug('***************** RTD: '+sales.Nine_LE__c);
                    	
                    	rowMap.get(sales.Product__r.Classification__c).get(sales.Product__r.Classification__c).get(sales.Product__r.Classification__c).col1 += sales.Nine_LE__c;
                    	
                    }
                    
                    if(sales.Sale_Date__c  >= col2FromDate && sales.Sale_Date__c <= col2ToDate){
                        
                        rowMap.get(sales.Product__r.Classification__c).get(sales.Product__r.Classification__c).get(sales.Product__r.Classification__c).col2 += sales.Nine_LE__c;
                        
                    }
                    
                    if(sales.Sale_Date__c  >= col6FromDate && sales.Sale_Date__c <= selectedDate){
                        
                        rowMap.get(sales.Product__r.Classification__c).get(sales.Product__r.Classification__c).get(sales.Product__r.Classification__c).col6 += sales.Nine_LE__c;
                        
                    }
                    
                    if(sales.Sale_Date__c  >= col7FromDate && sales.Sale_Date__c <= col7ToDate){
                        
                        rowMap.get(sales.Product__r.Classification__c).get(sales.Product__r.Classification__c).get(sales.Product__r.Classification__c).col7 += sales.Nine_LE__c;
                        
                    }
                    
                    if(sales.Sale_Date__c  >= col11FromDate && sales.Sale_Date__c <= col11ToDate){
                        
                        rowMap.get(sales.Product__r.Classification__c).get(sales.Product__r.Classification__c).get(sales.Product__r.Classification__c).col11 += sales.Nine_LE__c;
                        
                    }
                    
                    if(sales.Sale_Date__c  >= col12FromDate && sales.Sale_Date__c <= col12ToDate){
                        
                        rowMap.get(sales.Product__r.Classification__c).get(sales.Product__r.Classification__c).get(sales.Product__r.Classification__c).col12 += sales.Nine_LE__c;
                        
                    }
                    
                    if(sales.Sale_Date__c  >= col15FromDate && sales.Sale_Date__c <= col15ToDate){
                        
                        rowMap.get(sales.Product__r.Classification__c).get(sales.Product__r.Classification__c).get(sales.Product__r.Classification__c).col15 += sales.Nine_LE__c;
                        
                    }
                    
                    if(sales.Sale_Date__c  >= col16FromDate && sales.Sale_Date__c <= col16ToDate){
                        
                        rowMap.get(sales.Product__r.Classification__c).get(sales.Product__r.Classification__c).get(sales.Product__r.Classification__c).col16 += sales.Nine_LE__c;
                        
                    }
                    
                    if(sales.Sale_Date__c  >= col23FromDate && sales.Sale_Date__c <= col23ToDate){
                        
                        rowMap.get(sales.Product__r.Classification__c).get(sales.Product__r.Classification__c).get(sales.Product__r.Classification__c).col23 += sales.Nine_LE__c;
                        
                    }
                    
                    if(sales.Sale_Date__c  >= col24FromDate && sales.Sale_Date__c <= col24ToDate){
                        
                        rowMap.get(sales.Product__r.Classification__c).get(sales.Product__r.Classification__c).get(sales.Product__r.Classification__c).col24 += sales.Nine_LE__c;
                        
                    }
                    
                    if(sales.Sale_Date__c  >= col27FromDate && sales.Sale_Date__c <= col27ToDate){
                        
                        rowMap.get(sales.Product__r.Classification__c).get(sales.Product__r.Classification__c).get(sales.Product__r.Classification__c).col27 += sales.Nine_LE__c;
                        
                    }
                    
                    if(sales.Sale_Date__c  >= col28FromDate && sales.Sale_Date__c <= col28ToDate){
                        
                        rowMap.get(sales.Product__r.Classification__c).get(sales.Product__r.Classification__c).get(sales.Product__r.Classification__c).col28 += sales.Nine_LE__c;
                        
                    }
                    
                    if(sales.Sale_Date__c  >= col40FromDate && sales.Sale_Date__c <= col40ToDate){
                        
                        rowMap.get(sales.Product__r.Classification__c).get(sales.Product__r.Classification__c).get(sales.Product__r.Classification__c).col40 += sales.Nine_LE__c;
                        
                    }
                    
                    if(sales.Sale_Date__c  >= col41FromDate && sales.Sale_Date__c <= col41ToDate){
                        
                        rowMap.get(sales.Product__r.Classification__c).get(sales.Product__r.Classification__c).get(sales.Product__r.Classification__c).col41 += sales.Nine_LE__c;
                        
                    }
                    
                    if(sales.Sale_Date__c  >= col42FromDate && sales.Sale_Date__c <= col42ToDate){
                        
                        rowMap.get(sales.Product__r.Classification__c).get(sales.Product__r.Classification__c).get(sales.Product__r.Classification__c).col42 += sales.Nine_LE__c;
                        
                    }
                    
                    if(sales.Sale_Date__c  >= col43FromDate && sales.Sale_Date__c <= col43ToDate){
                        
                        rowMap.get(sales.Product__r.Classification__c).get(sales.Product__r.Classification__c).get(sales.Product__r.Classification__c).col43 += sales.Nine_LE__c;
                        
                    }
                    
                    if(sales.Sale_Date__c  >= col44FromDate && sales.Sale_Date__c <= col44ToDate){
                        
                        rowMap.get(sales.Product__r.Classification__c).get(sales.Product__r.Classification__c).get(sales.Product__r.Classification__c).col44 += sales.Nine_LE__c;
                        
                    }
                    
                    if(sales.Sale_Date__c  >= col45FromDate && sales.Sale_Date__c <= col45ToDate){
                        
                        rowMap.get(sales.Product__r.Classification__c).get(sales.Product__r.Classification__c).get(sales.Product__r.Classification__c).col45 += sales.Nine_LE__c;
                        
                    }
                    
                    if(sales.Sale_Date__c  >= col46FromDate && sales.Sale_Date__c <= col46ToDate){
                        
                        rowMap.get(sales.Product__r.Classification__c).get(sales.Product__r.Classification__c).get(sales.Product__r.Classification__c).col46 += sales.Nine_LE__c;
                        
                    }
                    
                    if(sales.Sale_Date__c  >= col47FromDate && sales.Sale_Date__c <= col47ToDate){
                        
                        rowMap.get(sales.Product__r.Classification__c).get(sales.Product__r.Classification__c).get(sales.Product__r.Classification__c).col47 += sales.Nine_LE__c;
                        
                    }
                    
                    if(sales.Sale_Date__c  >= col48FromDate && sales.Sale_Date__c <= col48ToDate){
                        
                        rowMap.get(sales.Product__r.Classification__c).get(sales.Product__r.Classification__c).get(sales.Product__r.Classification__c).col48 += sales.Nine_LE__c;
                        
                    }
                    
                    if(sales.Sale_Date__c  >= col49FromDate && sales.Sale_Date__c <= col49ToDate){
                        
                        rowMap.get(sales.Product__r.Classification__c).get(sales.Product__r.Classification__c).get(sales.Product__r.Classification__c).col49 += sales.Nine_LE__c;
                        
                    }
                                          
                    if(sales.Sale_Date__c  >= col50FromDate && sales.Sale_Date__c <= col50ToDate){
                        
                        rowMap.get(sales.Product__r.Classification__c).get(sales.Product__r.Classification__c).get(sales.Product__r.Classification__c).col50 += sales.Nine_LE__c;
                        
                    }
                    
                    if(sales.Sale_Date__c  >= col51FromDate && sales.Sale_Date__c <= col51ToDate){
                        
                        rowMap.get(sales.Product__r.Classification__c).get(sales.Product__r.Classification__c).get(sales.Product__r.Classification__c).col51 += sales.Nine_LE__c;
                        
                    }                      
                    
                }    

            }
            
            
            if(sales.Product__c != null) {
                
                if(rowMap.containsKey(sales.Product__r.Brand__c) && rowMap.get(sales.Product__r.Brand__c).containsKey(sales.Product__r.Sub_Classification__c) && 
                   rowMap.get(sales.Product__r.Brand__c).get(sales.Product__r.Sub_Classification__c).containsKey(sales.Product__c)){
                	
                	if(sales.Sale_Date__c  >= col1FromDate && sales.Sale_Date__c <= selectedDate){
                        
                        rowMap.get(sales.Product__r.Brand__c).get(sales.Product__r.Sub_Classification__c).get(sales.Product__c).col1 += sales.Nine_LE__c;
                        
                    }
                    
                    if(sales.Sale_Date__c  >= col2FromDate && sales.Sale_Date__c <= col2ToDate){
                        
                        rowMap.get(sales.Product__r.Brand__c).get(sales.Product__r.Sub_Classification__c).get(sales.Product__c).col2 += sales.Nine_LE__c;
                        
                    }
                    
                    if(sales.Sale_Date__c  >= col6FromDate && sales.Sale_Date__c <= selectedDate){
                        
                        rowMap.get(sales.Product__r.Brand__c).get(sales.Product__r.Sub_Classification__c).get(sales.Product__c).col6 += sales.Nine_LE__c;
                        
                    }
                    
                    if(sales.Sale_Date__c  >= col7FromDate && sales.Sale_Date__c <= col7ToDate){
                        
                        rowMap.get(sales.Product__r.Brand__c).get(sales.Product__r.Sub_Classification__c).get(sales.Product__c).col7 += sales.Nine_LE__c;
                        
                    }
                    
                    if(sales.Sale_Date__c  >= col11FromDate && sales.Sale_Date__c <= col11ToDate){
                        
                        rowMap.get(sales.Product__r.Brand__c).get(sales.Product__r.Sub_Classification__c).get(sales.Product__c).col11 += sales.Nine_LE__c;
                        
                    }
                    
                    if(sales.Sale_Date__c  >= col12FromDate && sales.Sale_Date__c <= col12ToDate){
                        
                        rowMap.get(sales.Product__r.Brand__c).get(sales.Product__r.Sub_Classification__c).get(sales.Product__c).col12 += sales.Nine_LE__c;
                        
                    }
                    
                    if(sales.Sale_Date__c  >= col15FromDate && sales.Sale_Date__c <= col15ToDate){
                        
                        rowMap.get(sales.Product__r.Brand__c).get(sales.Product__r.Sub_Classification__c).get(sales.Product__c).col15 += sales.Nine_LE__c;
                        
                    }
                    
                    if(sales.Sale_Date__c  >= col16FromDate && sales.Sale_Date__c <= col16ToDate){
                        
                        rowMap.get(sales.Product__r.Brand__c).get(sales.Product__r.Sub_Classification__c).get(sales.Product__c).col16 += sales.Nine_LE__c;
                        
                    }
                    
                    if(sales.Sale_Date__c  >= col23FromDate && sales.Sale_Date__c <= col23ToDate){
                        
                        rowMap.get(sales.Product__r.Brand__c).get(sales.Product__r.Sub_Classification__c).get(sales.Product__c).col23 += sales.Nine_LE__c;
                        
                    }
                    
                    if(sales.Sale_Date__c  >= col24FromDate && sales.Sale_Date__c <= col24ToDate){
                        
                        rowMap.get(sales.Product__r.Brand__c).get(sales.Product__r.Sub_Classification__c).get(sales.Product__c).col24 += sales.Nine_LE__c;
                        
                    }
                    
                    if(sales.Sale_Date__c  >= col27FromDate && sales.Sale_Date__c <= col27ToDate){
                        
                        rowMap.get(sales.Product__r.Brand__c).get(sales.Product__r.Sub_Classification__c).get(sales.Product__c).col27 += sales.Nine_LE__c;
                        
                    }
                    
                    if(sales.Sale_Date__c  >= col28FromDate && sales.Sale_Date__c <= col28ToDate){
                        
                        rowMap.get(sales.Product__r.Brand__c).get(sales.Product__r.Sub_Classification__c).get(sales.Product__c).col28 += sales.Nine_LE__c;
                        
                    }
                    
                    if(sales.Sale_Date__c  >= col40FromDate && sales.Sale_Date__c <= col40ToDate){
                        
                        rowMap.get(sales.Product__r.Brand__c).get(sales.Product__r.Sub_Classification__c).get(sales.Product__c).col40 += sales.Nine_LE__c;
                        
                    }
                    
                    if(sales.Sale_Date__c  >= col41FromDate && sales.Sale_Date__c <= col41ToDate){
                        
                        rowMap.get(sales.Product__r.Brand__c).get(sales.Product__r.Sub_Classification__c).get(sales.Product__c).col41 += sales.Nine_LE__c;
                        
                    }
                    
                    if(sales.Sale_Date__c  >= col42FromDate && sales.Sale_Date__c <= col42ToDate){
                        
                        rowMap.get(sales.Product__r.Brand__c).get(sales.Product__r.Sub_Classification__c).get(sales.Product__c).col42 += sales.Nine_LE__c;
                        
                    }
                    
                    if(sales.Sale_Date__c  >= col43FromDate && sales.Sale_Date__c <= col43ToDate){
                        
                        rowMap.get(sales.Product__r.Brand__c).get(sales.Product__r.Sub_Classification__c).get(sales.Product__c).col43 += sales.Nine_LE__c;
                        
                    }
                    
                    if(sales.Sale_Date__c  >= col44FromDate && sales.Sale_Date__c <= col44ToDate){
                        
                        rowMap.get(sales.Product__r.Brand__c).get(sales.Product__r.Sub_Classification__c).get(sales.Product__c).col44 += sales.Nine_LE__c;
                        
                    }
                    
                    if(sales.Sale_Date__c  >= col45FromDate && sales.Sale_Date__c <= col45ToDate){
                        
                        rowMap.get(sales.Product__r.Brand__c).get(sales.Product__r.Sub_Classification__c).get(sales.Product__c).col45 += sales.Nine_LE__c;
                        
                    }
                    
                    if(sales.Sale_Date__c  >= col46FromDate && sales.Sale_Date__c <= col46ToDate){
                        
                        rowMap.get(sales.Product__r.Brand__c).get(sales.Product__r.Sub_Classification__c).get(sales.Product__c).col46 += sales.Nine_LE__c;
                        
                    }
                    
                    if(sales.Sale_Date__c  >= col47FromDate && sales.Sale_Date__c <= col47ToDate){
                        
                        rowMap.get(sales.Product__r.Brand__c).get(sales.Product__r.Sub_Classification__c).get(sales.Product__c).col47 += sales.Nine_LE__c;
                        
                    }
                    
                    if(sales.Sale_Date__c  >= col48FromDate && sales.Sale_Date__c <= col48ToDate){
                        
                        rowMap.get(sales.Product__r.Brand__c).get(sales.Product__r.Sub_Classification__c).get(sales.Product__c).col48 += sales.Nine_LE__c;
                        
                    }
                    
                    if(sales.Sale_Date__c  >= col49FromDate && sales.Sale_Date__c <= col49ToDate){
                        
                        rowMap.get(sales.Product__r.Brand__c).get(sales.Product__r.Sub_Classification__c).get(sales.Product__c).col49 += sales.Nine_LE__c;
                        
                    }
                                          
                    if(sales.Sale_Date__c  >= col50FromDate && sales.Sale_Date__c <= col50ToDate){
                        
                        rowMap.get(sales.Product__r.Brand__c).get(sales.Product__r.Sub_Classification__c).get(sales.Product__c).col50 += sales.Nine_LE__c;
                        
                    }
                    
                    if(sales.Sale_Date__c  >= col51FromDate && sales.Sale_Date__c <= col51ToDate){
                        
                        rowMap.get(sales.Product__r.Brand__c).get(sales.Product__r.Sub_Classification__c).get(sales.Product__c).col51 += sales.Nine_LE__c;
                        
                    }
                
                }    

            }
    		
    	}
        system.debug('Exceuted....!');
    }

    /*
     * Send Key Account Performance report to user by email 
     */
    global void finish(Database.BatchableContext BC){
    	
    	/*
    	 * Generate the body of the email (HTML & plain text)
    	 */
    	
    	/*
    	 * 1. Generate Heading of Report
    	 */
    	html = '<table><tr colspan="24"><h2 style="text-align:left">Key Account Performance Report</h2></tr></table>';
    	
    	html += '<br/>';
    	
    	text = 'Key Account Performance Report\n\n';
    	
    	/*
    	 * 2. Generate the filters of the report 
    	 */
        
        html += '        <table style="background-color: rgb(173,182,212);font-weight:bold;">';
        
        html += '            <tr>';
        
        html += '                <td style="background-color:white;"></td>';
        
        html += '                <td>Region:</td>';
        
        html += '                <td>National</td>';
        
        html += '            </tr>';
        
        html += '            <tr>';
        
        html += '                <td style="background-color:white;"></td>';
        
        html += '                <td>Banner Group:</td>';
        
        html += '                <td>' + bannerGroupName + '</td>';
        
        html += '            </tr>';
                    
        html += '            <tr>';
        
        html += '                <td style="background-color:white;"></td>';
        
        html += '                <td>Date:</td>';
        
        html += '                <td style="text-align:left;">'+selectedDate.day()+'/'+selectedDate.month()+'/'+selectedDate.year()+'</td>';
        
        html += '            </tr>';
        
        html += '        </table>';
        
        html += '<br/><br/>';
        
        text += 'Region: National\n';
        
        text += 'Banner Group: '+bannerGroupName+'\n';
        
        text += 'Date: '+selectedDate.day()+'/'+selectedDate.month()+'/'+selectedDate.year()+'\n\n\n';
        
        /*
         * 3. Display the headings for all the columns for the report
         */
        
        html += '    <table width="3320px" style="border-collapse: collapse;">';                     
        html += '       <thead>';
        html += '           <tr class="headingRow">';
        html += '               <th style="width:20px;"></th>';            
        html += '               <th style="background-color: none;width:350px;" align="center"></th>';
		html += '               <th colspan="4" style="text-align:center;background-color: Yellow;width:235px;border-left:.5pt solid black;border-top:.5pt solid black;border-right:.5pt solid black;"  align="center">Month</th>';
		html += '               <th style="border: none;background-color:white;width:15px;"></th>';
		html += '               <th colspan="4" style="text-align:center;background-color: Yellow;width:235px;border-left:.5pt solid black;border-top:.5pt solid black;border-right:.5pt solid black;"  align="center">Calendar Year to Date</th>';
		html += '               <th style="border: none;background-color:white;width:15px;"></th>';
		html += '               <th colspan="28" style="text-align:center;background-color: #FFCC99;width:165.5pt;border-left:.5pt solid black;border-top:.5pt solid black;border-right:.5pt solid black;"  align="center">Volume by Quarter and Half TY vs. LY</th>';
		html += '               <th style="border: none;background-color:white;width:15px;"></th>';
		html += '               <th colspan="12" style="text-align:center;background-color: #FFCC99;width:708px;border-left:.5pt solid black;border-top:.5pt solid black;border-right:.5pt solid black;"  align="center">Volume by Month (MAT)</th>';
		html += '           </tr>';
		html += '           <tr>';
		html += '               <td style="width:20px;"></td>';
        html += '               <td align="center" style="vertical-align:middle;background-color:#D9D9D9;width:35.5pt;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;" >Product Description</td>';
        html += '               <td align="center" style="vertical-align:middle;background-color:#D9D9D9;width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;" >&nbsp;&nbsp;Actual&nbsp;&nbsp;<br/>TY</td>';
        html += '               <td align="center" style="vertical-align:middle;background-color:#D9D9D9;width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;" >&nbsp;&nbsp;Actual&nbsp;&nbsp;<br/>LY</td>';
		html += '               <td align="center" style="vertical-align:middle;background-color:#D9D9D9;width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;" > +/- vs. LY<br/>Cases</td>';
		html += '               <td align="center" style="vertical-align:middle;background-color:#D9D9D9;width:58px;border-left:.5pt solid black;border-right:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;" > +/- vs. LY<br/>Cases%</td>';
		html += '               <td style="width:15px;border: none;background-color:white; "></td>';
		html += '               <td align="center" style="vertical-align:middle;background-color:#D9D9D9;width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;" >&nbsp;&nbsp;Actual&nbsp;&nbsp;<br/>TY</td>';
		html += '               <td align="center" style="vertical-align:middle;background-color:#D9D9D9;width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;" >&nbsp;&nbsp;Actual&nbsp;&nbsp;<br/>LY</td>';
		html += '               <td align="center" style="vertical-align:middle;background-color:#D9D9D9;width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;" > +/- vs. LY<br/>Cases</td>';
		html += '               <td align="center" style="vertical-align:middle;background-color:#D9D9D9;width:58px;border-left:.5pt solid black;border-right:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;" > +/- vs. LY<br/>Cases%</td>';
		html += '               <td style="width:15px;border: none;background-color:white; "></td>';
		html += '               <td align="center" style="vertical-align:middle;background-color:#D9D9D9;width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;" >&nbsp;&nbsp;Q1 TY&nbsp;&nbsp;</td>';
		html += '               <td align="center" style="vertical-align:middle;background-color:#D9D9D9;width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">&nbsp;&nbsp;Q1 LY&nbsp;&nbsp;</td>';
		html += '               <td align="center" style="vertical-align:middle;background-color:#D9D9D9;width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">+/- vs. LY<br/>Cases</td>';
		html += '               <td align="center" style="vertical-align:middle;background-color:#D9D9D9;width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">+/- vs. LY<br/>Cases %</td>';
		html += '               <td align="center" style="vertical-align:middle;background-color:#D9D9D9;width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">&nbsp;&nbsp;Q2 TY&nbsp;&nbsp;</td>';
		html += '               <td align="center" style="vertical-align:middle;background-color:#D9D9D9;width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">&nbsp;&nbsp;Q2 LY&nbsp;&nbsp;</td>';
		html += '               <td align="center" style="vertical-align:middle;background-color:#D9D9D9;width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">+/- vs. LY<br/>Cases</td>';
		html += '               <td align="center" style="vertical-align:middle;background-color:#D9D9D9;width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;" >+/- vs. LY<br/>Cases %</td>';
		html += '               <td align="center" style="vertical-align:middle;background-color:#D9D9D9;width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">&nbsp;&nbsp;H1 TY&nbsp;&nbsp;</td>';
		html += '               <td align="center" style="vertical-align:middle;background-color:#D9D9D9;width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">&nbsp;&nbsp;H1 LY&nbsp;&nbsp;</td>';
		html += '               <td align="center" style="vertical-align:middle;background-color:#D9D9D9;width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">+/- vs. LY<br/>Cases</td>';
		html += '               <td align="center" style="vertical-align:middle;background-color:#D9D9D9;width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">+/- vs. LY<br/>Cases %</td>';
		html += '               <td align="center" style="vertical-align:middle;background-color:#D9D9D9;width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">&nbsp;&nbsp;Q3 TY&nbsp;&nbsp;</td>';
		html += '               <td align="center" style="vertical-align:middle;background-color:#D9D9D9;width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">&nbsp;&nbsp;Q3 LY&nbsp;&nbsp;</td>';
		html += '               <td align="center" style="vertical-align:middle;background-color:#D9D9D9;width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">+/- vs. LY<br/>Cases</td>';
		html += '               <td align="center" style="vertical-align:middle;background-color:#D9D9D9;width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">+/- vs. LY<br/>Cases %</td>';
		html += '               <td align="center" style="vertical-align:middle;background-color:#D9D9D9;width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">&nbsp;&nbsp;Q4 TY&nbsp;&nbsp;</td>';
		html += '               <td align="center" style="vertical-align:middle;background-color:#D9D9D9;width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">&nbsp;&nbsp;Q4 LY&nbsp;&nbsp;</td>';
		html += '               <td align="center" style="vertical-align:middle;background-color:#D9D9D9;width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">+/- vs. LY<br/>Cases</td>';
		html += '               <td align="center" style="vertical-align:middle;background-color:#D9D9D9;width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">+/- vs. LY<br/>Cases %</td>';
		html += '               <td align="center" style="vertical-align:middle;background-color:#D9D9D9;width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">&nbsp;&nbsp;H2 TY&nbsp;&nbsp;</td>';
		html += '               <td align="center" style="vertical-align:middle;background-color:#D9D9D9;width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">&nbsp;&nbsp;H2 LY&nbsp;&nbsp;</td>';
		html += '               <td align="center" style="vertical-align:middle;background-color:#D9D9D9;width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">+/- vs. LY<br/>Cases</td>';
		html += '               <td align="center" style="vertical-align:middle;background-color:#D9D9D9;width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">+/- vs. LY<br/>Cases %</td>';
		html += '               <td align="center" style="vertical-align:middle;background-color:#D9D9D9;width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">Full Year<br/>TY</td>';
		html += '               <td align="center" style="vertical-align:middle;background-color:#D9D9D9;width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">Full Year<br/>LY</td>';
		html += '               <td align="center" style="vertical-align:middle;background-color:#D9D9D9;width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">+/- vs. LY<br/>Cases</td>';
		html += '               <td align="center" style="vertical-align:middle;background-color:#D9D9D9;width:58px;border-left:.5pt solid black;border-right:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">+/- vs. LY<br/>Cases %</td>';
		html += '               <td style="width:15px;border: none;background-color:white; "></td>';
		html += '               <td align="center" style="vertical-align:middle;background-color:#D9D9D9;width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;JAN&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>';
		html += '               <td align="center" style="vertical-align:middle;background-color:#D9D9D9;width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;FEB&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>';
		html += '               <td align="center" style="vertical-align:middle;background-color:#D9D9D9;width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;MAR&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>';
		html += '               <td align="center" style="vertical-align:middle;background-color:#D9D9D9;width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;APR&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>';
		html += '               <td align="center" style="vertical-align:middle;background-color:#D9D9D9;width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;MAY&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>';
		html += '               <td align="center" style="vertical-align:middle;background-color:#D9D9D9;width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;JUN&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>';
		html += '               <td align="center" style="vertical-align:middle;background-color:#D9D9D9;width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;JUL&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>';
		html += '               <td align="center" style="vertical-align:middle;background-color:#D9D9D9;width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;AUG&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>';
		html += '               <td align="center" style="vertical-align:middle;background-color:#D9D9D9;width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;SEP&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>';
		html += '               <td align="center" style="vertical-align:middle;background-color:#D9D9D9;width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;OCT&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>';
		html += '               <td align="center" style="vertical-align:middle;background-color:#D9D9D9;width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;NOV&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>';
		html += '               <td align="center" style="vertical-align:middle;background-color:#D9D9D9;width:58px;border-left:.5pt solid black;border-right:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;DEC&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>';
		html += '           </tr>';
		html += '       </thead>';
		
		text += '                   Month                                                     Calendar Year to Date                                                                                                                                                                                                                        Volume by Quarter & Half TY vs. LY                                                                                                                                                                                 Volume by Month (MAT)                  \n';
		text += 'Actual TY  Actual LY  +/- vs. LYCases   +/- vs. LYCases %    Actual TY  Actual LY  +/- vs. LYCases  +/- vs. LYCases %    Q1 TY  Q1 LY   +/- vs. LYCases  +/- vs. LYCases %  Q2 TY  Q2 LY  +/- vs. LYCases  +/- vs. LYCases %  H1 TY  H1 LY  +/- vs. LYCases   +/- vs. LYCases %  Q3 TY  Q3 LY  +/- vs. LYCases  +/- vs. LYCases %  Q4 TY  Q4 LY  +/- vs. LYCases   +/- vs. LYCases %  H2 TY  H2 LY  +/- vs. LYCases  +/- vs. LYCases %  Full Year TY  Full Year LY  +/- vs. LYCases  +/- vs. LY Cases %  JAN  FEB  MAR  APR  MAY  JUN  JUL  AUG  SEP  OCT  NOV  DEC';
		
		html += '       <tbody>';
		
		addNewLine();
		
		/*
         * 4. Calculate the Banner Group Row with the total - RTD, Glass, Wine and their total row
         */
		
		for(String classification : new list<String>{'RTD', 'Glass', 'Wine'}){
			
			rowMap.get(classification).get(classification).get(classification).calculateAllColumnsAndSetScale();
			
			addRowInEmail(rowMap.get(classification).get(classification).get(classification),'#C5D9F1');
			
			rowMap.get('TOTAL BANNER').get('TOTAL BANNER').get('TOTAL BANNER').addValues(rowMap.get(classification).get(classification).get(classification));
			
			rowMap.get(classification).get(classification).remove(classification);
            
            rowMap.get(classification).remove(classification);
            
            rowMap.remove(classification);
			
		}
		
		rowMap.get('TOTAL BANNER').get('TOTAL BANNER').get('TOTAL BANNER').calculateAllColumnsAndSetScale();
		
		addRowInEmail(rowMap.get('TOTAL BANNER').get('TOTAL BANNER').get('TOTAL BANNER'),'#8DB4E2');
		
		rowMap.get('TOTAL BANNER').get('TOTAL BANNER').remove('TOTAL BANNER');
            
        rowMap.get('TOTAL BANNER').remove('TOTAL BANNER');
        
        rowMap.remove('TOTAL BANNER');
        
        addNewLine();
        
        /*
         * 5. Add the Product Row, Sub classification rows and Brand rows
         */
        
        KARowWrapper bannerSum, subClassSum;
        
        system.debug('row map data'+rowMap);
        
        for(String bannerId : rowMap.keySet()){        	
        		                		
    		bannerSum = new KARowWrapper('TOTAL '+brandMap.get(bannerId));

		        	for(String subClassification : rowMap.get(bannerId).keySet()){		        		
		        		
		        		subClassSum = new KARowWrapper(subClassification);
		        		
		        		for(String productId : rowMap.get(bannerId).get(subClassification).keySet()){
		        						        			
		        			rowMap.get(bannerId).get(subClassification).get(productId).calculateAllColumnsAndSetScale();
		        			
		        			addRowInEmail(rowMap.get(bannerId).get(subClassification).get(productId),'transparent');
		        			
		        			subClassSum.addValues(rowMap.get(bannerId).get(subClassification).get(productId));
		        			
		        			bannerSum.addValues(rowMap.get(bannerId).get(subClassification).get(productId));
		        			
		        		}
		        		
		        		if(rowMap.get(bannerId).keySet().size() > 1 && subClassification != null){
		        		
			        		subClassSum.calculateAllColumnsAndSetScale();
			        		
			        		addRowInEmail(subClassSum,'#D9D9D9');
		        		
		        		}	        		
		        	}
        	        	
        	bannerSum.calculateAllColumnsAndSetScale();
                
            addRowInEmail(bannerSum,'#808080');
            
            addNewLine();
        	
        }
				
        html += '       </tbody>';
        html += '    </table>';
        
        /*
         * 6. Send email to user
         */
    	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

		mail.setToAddresses(new String[] {email});
		mail.setSenderDisplayName('System Administrator');
		mail.setSubject('Proposed KA Report');
		//mail.setPlainTextBody(text);
		
		//mail.setHtmlBody(html);
		
		mail.setPlainTextBody('Please Find Attached Report for Key Account Performance for '+bannerGroupName);
		
		mail.setHtmlBody('Please Find Attached Report for Key Account Performance for '+bannerGroupName);
		
		Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
		
		efa.setContentType('application/vnd.ms-excel');
		
        efa.setFileName('Key Account Performance - '+bannerGroupName+'.xls');
        
        efa.setInline(false);
        
        efa.setBody(Blob.valueOf(html));
        
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa}); 
		
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    
    }
    
    public void addNewLine(){
    	
    	html += '<tr>';
        html += '    <td>&nbsp;</td>';
        html += '</tr>';
        
        text += '\n';
    	
    }
    
    public void addRowInEmail(KARowWrapper wrap, String backgroundColor){
    	
        String col1 = formatDouble(wrap.col1);
        String col2 = formatDouble(wrap.col2);
        String col3 = formatDouble(wrap.col3);
        String col4 = formatDouble(wrap.col4);
        String col6 = formatDouble(wrap.col6);
        String col7 = formatDouble(wrap.col7);
        String col8 = formatDouble(wrap.col8);
        String col9 = formatDouble(wrap.col9);
        
        String col11 = formatDouble(wrap.col11);
        String col12 = formatDouble(wrap.col12);
        String col13 = formatDouble(wrap.col13);
        String col14 = formatDouble(wrap.col14);
        String col15 = formatDouble(wrap.col15);
        String col16 = formatDouble(wrap.col16);
        String col17 = formatDouble(wrap.col17);
        String col18 = formatDouble(wrap.col18);
        String col19 = formatDouble(wrap.col19);
        String col20 = formatDouble(wrap.col20);
        
        String col21 = formatDouble(wrap.col21);
        String col22 = formatDouble(wrap.col22);
        String col23 = formatDouble(wrap.col23);
        String col24 = formatDouble(wrap.col24);
        String col25 = formatDouble(wrap.col25);
        String col26 = formatDouble(wrap.col26);
        String col27 = formatDouble(wrap.col27);
        String col28 = formatDouble(wrap.col28);
        String col29 = formatDouble(wrap.col29);
        String col30 = formatDouble(wrap.col30);
        
        String col31 = formatDouble(wrap.col31);
        String col32 = formatDouble(wrap.col32);
        String col33 = formatDouble(wrap.col33);
        String col34 = formatDouble(wrap.col34);
        String col35 = formatDouble(wrap.col35);
        String col36 = formatDouble(wrap.col36);
        String col37 = formatDouble(wrap.col37);
        String col38 = formatDouble(wrap.col38);
        String col40 = formatDouble(wrap.col40);
        
        String col41 = formatDouble(wrap.col41);
        String col42 = formatDouble(wrap.col42);
        String col43 = formatDouble(wrap.col43);
        String col44 = formatDouble(wrap.col44);
        String col45 = formatDouble(wrap.col45);
        String col46 = formatDouble(wrap.col46);
        String col47 = formatDouble(wrap.col47);
        String col48 = formatDouble(wrap.col48);
        String col49 = formatDouble(wrap.col49);
        String col50 = formatDouble(wrap.col50);
        
        String col51 = formatDouble(wrap.col51);
    	
    	html += '<tr style="background-color:'+backgroundColor+'">';
    	html += '    <td style="background-color:white;width:20px;"></td>';
	    html += '    <td style="width:35.5pt;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">'+wrap.rowName+'</td>';
	    html += '    <td align="center" style="width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">'+col1+'</td>';
	    html += '    <td align="center" style="width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">'+col2+'</td>';
	    html += '    <td align="center" style="width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;color:'+wrap.col3Color+';">'+col3+'</td>';
	    html += '    <td align="center" style="width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;border-right:.5pt solid black;color:'+wrap.col4Color+';"><span>'+col4+'%</span></td>';
	    html += '    <td style="width:15px;border:none;background-color:white;"></td>';                                   
	    html += '    <td align="center" style="width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">'+col6+'</td>';
	    html += '    <td align="center" style="width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">'+col7+'</td>';
	    html += '    <td align="center" style="width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;color:'+wrap.col8Color+';">'+col8+'</td> ';
	    html += '    <td align="center" style="width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;border-right:.5pt solid black;color:'+wrap.col9Color+';">'+col9+'%</td>';
	    html += '    <td style="width:15px;border: none;background-color:white; "></td>';
	    html += '    <td align="center" style="width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">'+col11+'</td>';
	    html += '    <td align="center" style="width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">'+col12+'</td>';
	    html += '    <td align="center" style="width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;color:'+wrap.col13Color+';">'+col13+'</td>';
	    html += '    <td align="center" style="width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;color:'+wrap.col14Color+';">'+col14+'%</td>';
	    html += '    <td align="center" style="width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">'+col15+'</td>';
	    html += '    <td align="center" style="width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">'+col16+'</td>';
	    html += '    <td align="center" style="width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;color:'+wrap.col17Color+';">'+col17+'</td>';
	    html += '    <td align="center" style="width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;color:'+wrap.col8Color+';">'+col18+'%</td>';
	    html += '    <td align="center" style="width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">'+col19+'</td>';
	    html += '    <td align="center" style="width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">'+col20+'</td>';
	    html += '    <td align="center" style="width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;color:'+wrap.col21Color+';">'+col21+'</td>';
	    html += '    <td align="center" style="width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;color:'+wrap.col22Color+';">'+col22+'%</td>';
	    html += '    <td align="center" style="width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">'+col23+'</td>';
	    html += '    <td align="center" style="width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">'+col24+'</td>';
	    html += '    <td align="center" style="width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;color:'+wrap.col25Color+';">'+col25+'</td>';
	    html += '    <td align="center" style="width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;color:'+wrap.col26Color+';">'+col26+'%</td>';
	    html += '    <td align="center" style="width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">'+col27+'</td>';
	    html += '    <td align="center" style="width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">'+col28+'</td>';
	    html += '    <td align="center" style="width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;color:'+wrap.col29Color+';">'+col29+'</td>';
	    html += '    <td align="center" style="width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;color:'+wrap.col30Color+';">'+col30+'%</td>';
	    html += '    <td align="center" style="width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">'+col31+'</td>';
	    html += '    <td align="center" style="width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">'+col32+'</td>';
	    html += '    <td align="center" style="width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;color:'+wrap.col33Color+';">'+col33+'</td>';
	    html += '    <td align="center" style="width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;color:'+wrap.col34Color+';">'+col34+'%</td>';
	    html += '    <td align="center" style="width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">'+col35+'</td>';
	    html += '    <td align="center" style="width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">'+col36+'</td>';
	    html += '    <td align="center" style="width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;color:'+wrap.col37Color+';">'+col37+'</td>';
	    html += '    <td align="center" style="width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;border-right:.5pt solid black;color:'+wrap.col38Color+';">'+col38+'%</td>';   
	    html += '    <td style="width:15px;border: none;background-color:white;"></td>';
	    html += '    <td align="center" style="width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">'+col40+'</td>';  
	    html += '    <td align="center" style="width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">'+col41+'</td>';
	    html += '    <td align="center" style="width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">'+col42+'</td>';
	    html += '    <td align="center" style="width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">'+col43+'</td>';
	    html += '    <td align="center" style="width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">'+col44+'</td>';
	    html += '    <td align="center" style="width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">'+col45+'</td>';
	    html += '    <td align="center" style="width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">'+col46+'</td>';
	    html += '    <td align="center" style="width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">'+col47+'</td>';
	    html += '    <td align="center" style="width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">'+col48+'</td>';
	    html += '    <td align="center" style="width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">'+col49+'</td>';
	    html += '    <td align="center" style="width:58px;border-left:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">'+col50+'</td>';
	    html += '    <td align="center" style="width:58px;border-left:.5pt solid black;border-right:.5pt solid black;border-top:.5pt solid black;border-bottom:.5pt solid black;">'+col51+'</td>';                 
	    html += '</tr>';
	    
	    text += wrap.rowName+'  '+col1+'  '+col2+'  '+col3+'  '+col4+'    '+col6+'  '+col7+'  '+col8+'  '+col9+'    '+col21+'  '+col22+'  '+col23+'  '+col24+'  '+col25+'  '+col26+'  '+col27+'  '+col28+'  '+col29+'  '+col30
	                        +'  '+col31+'  '+col32+'  '+col33+'  '+col34+'  '+col35+'  '+col36+'  '+col37+'  '+col38+'    '+col40
	                        +'  '+col41+'  '+col42+'  '+col43+'  '+col44+'  '+col45+'  '+col46+'  '+col47+'  '+col48+'  '+col49+'  '+col50
    	                    +'  '+col51+'\n';
    }
    
    public String formatDouble(Decimal numberToBeFormatted){
		
		String numberAsString = numberToBeFormatted.format();
		
		return numberAsString;
	}

	
}