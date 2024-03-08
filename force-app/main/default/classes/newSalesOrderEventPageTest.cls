/**
 * Created by eugene on 03.10.19.
 */
@isTest
public with sharing class newSalesOrderEventPageTest {
    @isTest
    static void getSalesOrderRecordTypesTest(){
        List<RecordType> lst = newSalesOrderEventPage.getSalesOrderRecordTypes();
        System.assertNotEquals(lst.size(), null);
    }
}