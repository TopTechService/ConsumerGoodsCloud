/*
 * Class Name : OldDataDeletionBatch
 * Description : This batch class is used to delete old data which is older than two years (Created Date < 2 Years)
 * @author : Rahul Devsatwar
 */ 

global class OldDataDeletionBatch implements Database.Batchable<String>,Database.Stateful {
    
    global boolean bReRun = false; //will be used to determine if batch has to re-run in case there are more that 10K of records
    global Iterable<String> start(Database.BatchableContext ctx) {
    return new List<String> {'Sale_MySales__c', 'PromotionProduct__c', 'Promotion_Banner_Group__c',
                             'Sales_Order__c','Sales_Order_Product__c'}; //List of strings with my object names
    }
    
    global String setWherePart(String objectName){
        DateTime todaysDate = System.now();
        DateTime twoYearsBackDt = todaysDate.addMonths(-24);

        if(objectName == 'Sale_MySales__c'){
            return 'WHERE Sale_Date__c!= null and Sale_Date__c < '+ String.valueOf(twoYearsBackDt).left(10);
        }
        else if(objectName == 'PromotionProduct__c'){
            return 'WHERE Promo_End_Date__c!= null and Promo_End_Date__c < '+  String.valueOf(twoYearsBackDt).left(10);
        }
        else if(objectName == 'Promotion_Banner_Group__c'){
            return 'WHERE end_date__c!= null and end_date__c < '+ String.valueOf(twoYearsBackDt).left(10);
        }
        else if(objectName == 'Sales_Order__c'){
            return 'WHERE CreatedDate < '+ twoYearsBackDt.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        }
        else if(objectName == 'Sales_Order_Product__c'){
            return 'WHERE CreatedDate < '+ twoYearsBackDt.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        }
        else{
            return null;
        }
    }

    global void execute(Database.BatchableContext ctx, list<string> lstsObjectName) {
    List<sObject> lstDeleteRecords = new List<sObject>();
    String wherePart;
    
    for(String strObjectName : lstsObjectName) {
        wherePart = setWherePart(strObjectName);

        for(sObject objsObject : database.query('SELECT ID FROM ' + strObjectName +' '+ wherePart)) {
            //if(lstDeleteRecords.size() < 9998)
            if(lstDeleteRecords.size() < 200*(11 - lstsObjectName.size()) + lstsObjectName.size()){
                lstDeleteRecords.add(objsObject);
            }
            else {
                bReRun = true;
                break;
            }
        }
    }
    lstDeleteRecords.sort();
    if(!lstDeleteRecords.isEmpty()){
        delete lstDeleteRecords;
    }
    }
    
    global void finish(Database.BatchableContext ctx) {
        if(bReRun) {
            Database.executebatch(new OldDataDeletionBatch());
        }
    }
}