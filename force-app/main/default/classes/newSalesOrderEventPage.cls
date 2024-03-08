/**
 * Created by eugene on 03.10.19.
 */

public with sharing class newSalesOrderEventPage {
    @AuraEnabled
    public static List<RecordType> getSalesOrderRecordTypes(){
        return [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Sales_Order__c'];
    }
}