/*Created By -:Sourav Nema
Purpose-:Populate values on brand look-up on product object
Update : 27/09/2018 - Yoann Beurier - Add/Remove the Product to Product Range on outlets.
*/

trigger productTrigger on Product__c(before insert,before update, after insert, after update) {
    
    if(trigger.isBefore) {
        
        list<string> brandId      = new list<string>();
        DataLoaderHelper helper   = new DataLoaderHelper();
        map<string, id> brandMap  = new  map<string, id>();
        
        for(Product__c prdct : trigger.new){
            brandId.add(prdct.Brand_ID__c); 
        }  
        
        //Get id of corresponding brand
        brandMap.putAll(helper.getBrandMap(brandId));
        
        //Assign account
        for(Product__c prdct:trigger.new){
            
            if( brandMap.get(prdct.Brand_ID__c)!=null){ 
                prdct.Brand__c   =  brandMap.get(prdct.Brand_ID__c);
            }
            else{
                prdct.Brand_ID__c.addError('Invalid Brand Id');
            }
        }  
    }
    
    if(trigger.isAfter) {
        TriggerDispatcher.Run(new productTriggerHandler());
    }
    
    
}