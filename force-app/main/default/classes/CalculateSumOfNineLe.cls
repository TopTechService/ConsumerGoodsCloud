/**
 * @author : Geeta Kushwaha, geeta.kushwaha@arxxus.com
 * @date : 16-01-2014
 * @Description : This class calculates sum of NineLe for all outlets for the current year
                  It should be called every year on 1 Jan
 */
global class CalculateSumOfNineLe implements Database.Batchable<sObject>, Database.Stateful{
	
    global String query = 'select Outlet__c, Nine_LE__c from Sale_MySales__c where CALENDAR_YEAR(Sale_Date__c) =: currentYear';
    
    global String query1 = 'select id, Volume__c from Account where RecordTypeId =: outletId ';
    
    map<Id,decimal> volMap;
     
    integer currentYear;
    
    String region;
    
    String outletId;
    
    global CalculateSumOfNineLe(){
    	
    	this.currentYear = date.today().year();
    	
    	volMap = new map<Id, decimal> ();
    	
    	region = null;
    	
    	this.outletId = Utilities.getRecordTypeId('Account','Outlet');
    	
    	getVolMap();
    	
    }
    
    global CalculateSumOfNineLe(String region){
    	
    	this.currentYear = date.today().year();
    	
    	volMap = new map<Id, decimal> ();
    	
    	this.region = region;
    	
    	this.outletId = Utilities.getRecordTypeId('Account','Outlet');
    	
    	getVolMap();
    	
    }
    
    void getVolMap(){
    	
    	for(Sale_MySales__c mySales : database.query(region == null ? query : query + ' and Outlet__r.State__r.Region__r.Region_Abbr__c =: region')) {
    		
    		if(mySales.Outlet__c != null && mySales.Nine_LE__c != null){
    			
    			if(volMap.containsKey(mySales.Outlet__c)){
    				
    				volMap.put(mySales.Outlet__c, volMap.get(mySales.Outlet__c) + mySales.Nine_LE__c);
    				
    			}
    			
    			else {
    				
    				volMap.put(mySales.Outlet__c, mySales.Nine_LE__c);
    				
    			}
    			
    		}    		
    		
    	}
    	
    }
	
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        return Database.getQueryLocator(region == null ? query1 : query1 + ' and State__r.Region__r.Region_Abbr__c =: region');
        
    }

    global void execute(Database.BatchableContext BC, List<Account> accountRecords){
    	
    	for(Account acc: accountRecords){
	
    		if(volMap.containsKey(acc.Id)){
    			
    			/*
                 * Copy all the current statistics in appropriate fields for Current Year as well as Last Year
                 */
                
                acc.Volume__c = volMap.get(acc.Id).setScale(2);
            	
            }
            
            else {
            	
            	/*
	        	 * Initialize Volume
	        	 */
	            
	            acc.Volume__c = 0;
            	
            }
	    		
    	}
    	
    	try {
	    	
	    	/*
	         * Commit all the updated account records to the database
	         */
	         
	         RecursiveTriggerController.calledFromBatch = true;
	         
	         database.update(accountRecords, false);
	        
	    }                         
                              
        
        catch(Exception e){
            
            
        }     
    	
    	
    }

    global void finish(Database.BatchableContext BC){    	
    			
    	
    }
	
}