/**
* @Description : This batch class is for Find out duplicate sales record and update idDuplicate field on salesRecord to true  
*/
global class findUplicateSalesBatch implements Database.Batchable<sObject> {
	
	public string query; 
    
    global findUplicateSalesBatch(){    
         query = 'SELECT CreatedDate,IsDulpicate__c,Name,Sale_Date__c FROM Sale_MySales__c WHERE isChecked__c = false and IsDulpicate__c = false';       
                
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
        set<String> IdSet = new set<String>();
        system.debug('=======scope=====' + scope);
        for(Sale_MySales__c  sales : scope){
    		IdSet.add(sales.Name);
		}
        
        list<Sale_MySales__c> duplicateList = [SELECT IsDulpicate__c,Name,CreatedDate FROM Sale_MySales__c WHERE Name In :IdSet ORDER BY CreatedDate DESC];
		map<string ,list<Sale_MySales__c>> salesmAP = NEW map<string ,list<Sale_MySales__c>>();
		for(Sale_MySales__c s : duplicateList){
		    if(salesmAP.containsKey(s.Name)){
		        salesmAP.get(s.Name).add(s);
		    }else{
		        salesmAP.put(s.Name , new list<Sale_MySales__c> {s});
		    }
		}
		
		list<Sale_MySales__c> duplicateListToUpdate = new list<Sale_MySales__c>();
		 
		    for(String str : salesmAP.keySet()){
		        if(salesmAP.get(str).size()>1){
		            Integer counter = 0;
		            for(Sale_MySales__c sale : salesmAP.get(str)){
		                if(counter != 0 ){
		                    sale.IsDulpicate__c = true;   
		                    sale.isChecked__c = true;
		                    duplicateListToUpdate.add(sale);
		                }else{
		                    sale.isChecked__c = true;
		                    duplicateListToUpdate.add(sale);
		                }
		                counter++;
		            }
		           
		        }else{
		            for(Sale_MySales__c sale : salesmAP.get(str)){
		            	sale.isChecked__c = true;
		                duplicateListToUpdate.add(sale);
		        	}
		        }
		    }
			
		
		if(!duplicateListToUpdate.isEmpty()){
		    update duplicateListToUpdate;
		    system.debug('======duplicateListToUpdate=======' + duplicateListToUpdate);
		}
   }
     
       
   /**
   * Finish - Update IdDuplicate field on duplicate sales record to true 
   */  
   global void finish(Database.BatchableContext BC){
   
   }   	
 }