/**
* @Description : This batch class is for Find out duplicate sales record and update idDuplicate field on salesRecord to true  
*/
global class FindOutDuplicateSalesRecordBatch implements Database.Batchable<sObject> {
	
	public string query;
    
    global FindOutDuplicateSalesRecordBatch(){    
         query = 'SELECT IsDulpicate__c,CreatedDate,Id,Name'+
                  ' FROM Sale_MySales__c ORDER BY CreatedDate DESC';      
                
    }    
       
    /**
    *   Start Method
    */
    global Database.QueryLocator start(Database.BatchableContext BC){   
         return Database.getQueryLocator(query);
    }
      
      
      
   /**
   *   Execute Logic
   */      
   global void execute(Database.BatchableContext BC, List<Sale_MySales__c>scope){
        list<Sale_MySales__c> duplicateSalesToUpdate = new list<Sale_MySales__c>();
 		list<Sale_MySales__c> duplicateSalesList = new list<Sale_MySales__c>();
 		map<id,Sale_MySales__c> SalesIdVsSalesMap = new map<id,Sale_MySales__c>();
 		
 		for (Sale_MySales__c sal : scope){
 			duplicateSalesList = [SELECT ID,Name,IsDulpicate__c FROM Sale_MySales__c WHERE Name =: sal.name AND IsDulpicate__c = false ORDER BY CreatedDate DESC];
 			Integer counter = 0;
 			if(duplicateSalesList.size() > 1){
 				for(Sale_MySales__c ss: duplicateSalesList){
 					if(counter == 0){
 						ss.IsDulpicate__c = false;
 					}else{
 						ss.IsDulpicate__c = true;
 					}
 					duplicateSalesToUpdate.add(ss);
 					counter ++;
 				}
 				
 				if(!duplicateSalesToUpdate.isEmpty()){
					database.update( duplicateSalesToUpdate,false);
					system.debug('====duplicateSalesList=====' + duplicateSalesToUpdate);       
				} 
 			}
 			duplicateSalesList.clear(); 
 		}
 	}
     
       
   /**
   * Finish - Update IdDuplicate field on duplicate sales record to true 
   */  
   global void finish(Database.BatchableContext BC){
   
   }   	
 }