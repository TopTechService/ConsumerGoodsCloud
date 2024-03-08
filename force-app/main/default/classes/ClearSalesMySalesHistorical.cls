/**
 * Author :Geeta Kushwaha, geeta.kushwaha@arxxus.com
 * @created date : 23/12/2013
 * Description : This class deletes all Sale_MySales_Historical__c records 
 */
global class ClearSalesMySalesHistorical implements Database.Batchable<sObject>{

   global String queryString = 'SELECT Id FROM Sale_MySales_Historical__c';

   global Database.QueryLocator start(Database.BatchableContext BC){
   	
      return Database.getQueryLocator(queryString);
     
   }

   global void execute(Database.BatchableContext BC, List<sObject> mySalesHistoricalRecords){
       
     delete mySalesHistoricalRecords;
       
    }

   global void finish(Database.BatchableContext BC){
   	
   }
   
}