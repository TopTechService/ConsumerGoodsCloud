/**
 * @author           : Sourav Nema
   @Created Date     : 4/26/2013
   @lastmodified     : Gunwant Patidar
   @lastmodified date: 22/5/2013
   @modified : Geeta Kushwaha on 22/10/2013. Revise Promotion Product creation logic as per below
   Create a field PromotedRangeID on Product. Every Promotion has PromotedRangeID mentioned. PromotionProduct should only be created for the corresponding Promotion, PromotionRangeID and Product (and not for all the Products under the Brand). 
 */

trigger promotionTrigger on Promotion__c (before insert, before update ,after insert, after update) {

    static list<string> uniqueIdList = new list<string>();
    list<string> rangeId  = new list<string>();
    set<Id> promotionIds = new set<Id>();
    
    map<string, list<Product__c>> idPrdctListMap = new map<string, list<Product__c>>();

    DataLoaderHelper helper = new DataLoaderHelper();

    map<String, Promoted_Range__c> promotedRangeMap = new map<String, Promoted_Range__c>();

    list<string> promotionId   = new list<string>();
    list<string> promotionType = new list<string>();
    map<string,string> promotionTypeMap = new map<string,string>();
    
    list<string> spendType = new list<string>();
    map<string,string> spendTypeMap = new map<string,string>();

    list <RecordType> promotionRecordTypeIds = new list <RecordType> ();

    for(Promotion__c prmtn :trigger.new){
    	rangeId.add(string.valueOf(prmtn.Promoted_Range_ID__c));
        promotionType.add(prmtn.Promotion_Type_ID__c);
        spendType.add(prmtn.Spend_Type_Id__c);
        if(trigger.isUpdate && prmtn.Promoted_Range_ID__c != trigger.oldMap.get(prmtn.id).Promoted_Range_ID__c){
            promotionId.add(prmtn.id);
        }
    }  

    promotionRecordTypeIds = [select id from RecordType where SObjectType = 'Promotion__c' and developerName = 'Trade_Loader_Promotion'];

    //delete all promotion products of promotions if Promoted Range ID has been changed.

    if(promotionId.size()>0){ 

        list<PromotionProduct__c> prmnList = new list<PromotionProduct__c>();
        
        prmnList.addAll(helper.getPromotionProduct(promotionId));
        delete prmnList;
    } 
    //Get id of corresponding Promoted Range and promotion type and spend type

    promotedRangeMap.putAll(helper.getPromotedRangeMap(rangeId));
    promotionTypeMap.putAll(helper.getPromotedTypeIdMap(promotionType));
    spendTypeMap.putAll(helper.getSpendTypeIdMap(spendType));
    //Assign Promoted Range
    if(trigger.isBefore){
        for(Promotion__c prmtn :trigger.new){
            if(prmtn.Promotion_Period_Start_Date__c != null && prmtn.Promotion_Period_End_Date__c != null){
            	prmtn.colspan__c = PromotionColspanClass.getColspan(prmtn.Promotion_Period_Start_Date__c, prmtn.Promotion_Period_End_Date__c);
            	prmtn.StartDayMonth__c = PromotionColspanClass.getStartDayMonth(prmtn.Promotion_Period_Start_Date__c);
            	prmtn.End_Day_Month__c = PromotionColspanClass.getStartDayMonth(prmtn.Promotion_Period_End_Date__c);
            }
            if( (promotedRangeMap.get(prmtn.Promoted_Range_ID__c) !=null || prmtn.Promoted_Range_ID__c!=null)
                    && promotionTypeMap.get(prmtn.Promotion_Type_ID__c)!= null && spendTypeMap.get(prmtn.Spend_Type_Id__c) !=null){
                if(promotedRangeMap.containsKey(prmtn.Promoted_Range_ID__c)){
                    prmtn.Promoted_Range__c   = promotedRangeMap.get(prmtn.Promoted_Range_ID__c).id;
                }
                if(promotionTypeMap.containsKey(prmtn.Promotion_Type_ID__c)){
                    prmtn.Promotion_Type__c   = promotionTypeMap.get(prmtn.Promotion_Type_ID__c);
                }
                if(spendTypeMap.containsKey(prmtn.Spend_Type_Id__c)){
                    prmtn.Spend_Type__c       = spendTypeMap.get(prmtn.Spend_Type_Id__c);
                }
                uniqueId__c uniqueIdListRecord   = new uniqueId__c(); 
                if(promotedRangeMap.containsKey(prmtn.Promoted_Range_ID__c)){
                    uniqueIdListRecord.name = promotedRangeMap.get(prmtn.Promoted_Range_ID__c).PromotedBrandId__c;
                    
                }
                
            }
 
            else{
                if(promotedRangeMap.get(prmtn.Promoted_Range_ID__c) ==null && prmtn.RecordTypeId != promotionRecordTypeIds[0].Id ){
                    System.debug(' promotedRangeMap.get(prmtn.Promoted_Range_ID__c)' + promotedRangeMap.get(prmtn.Promoted_Range_ID__c) + prmtn.RecordType.Name);
                    prmtn.Promoted_Range_ID__c.addError('Invalid Promoted Range id');
                }
                else if(promotionTypeMap.get(prmtn.Promotion_Type_ID__c)== null && prmtn.RecordTypeId != promotionRecordTypeIds[0].Id){

                    prmtn.Promotion_Type_ID__c.addError('Invalid Promotion type id');
                }
                else if(prmtn.RecordTypeId != promotionRecordTypeIds[0].Id){
                    
                      prmtn.Spend_Type_Id__c.addError('Invalid spend type');
                }
            }


        } 

    }  


    //After trigger
    if(trigger.isAfter){

        list<PromotionProduct__c> prmProduct = new list<PromotionProduct__c>();

        //get prmoted range and product list map
        idPrdctListMap.putAll(helper.getIdProductListMap(rangeId));

        /*map<Id, Promoted_Range__c> promotedRangeMap = new map<Id,Promoted_Range__c>([select Promotion_Range_ID__c,PromotedBrandId__c, id 
                                                      from Promoted_Range__c
                                                      where Promotion_Range_ID__c in: promotionId]); */


        //created promotion products 
        for(Promotion__c prmtn :trigger.new){
        	if(prmtn.Promotion_Period_Start_Date__c != null && prmtn.Promotion_Period_End_Date__c != null){
            		promotionIds.add(prmtn.id);
            }
                        
            if(idPrdctListMap.containsKey(prmtn.Promoted_Range_ID__c) && idPrdctListMap.get(prmtn.Promoted_Range_ID__c).size()>0){

                if(trigger.isInsert ||(trigger.isUpdate && prmtn.Promoted_Range_ID__c != trigger.oldMap.get(prmtn.id).Promoted_Range_ID__c)){
                    for(Product__c prd : idPrdctListMap.get(prmtn.Promoted_Range_ID__c)){
                        PromotionProduct__c pprd= new PromotionProduct__c(Promotion__c = prmtn.id , Promoted_Range__c = promotedRangeMap.get(prmtn.Promoted_Range_ID__c).id,
                                Product__c = prd.Id,name = prmtn.name+''+prd.name);
                        prmProduct.add(pprd);

                    }
                }
            }
             
        }
        // check overalpping dates
        if(StaticVariableHandler.promotionTriggerRun == 1){
        	PromotionColspanClass.checkOverlapDates(promotionIds,'isAfter');
        }  
        system.debug('prmProduct: ' + prmProduct);

        insert prmProduct;
    }
}