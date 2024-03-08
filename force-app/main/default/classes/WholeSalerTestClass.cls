@isTest
public class WholeSalerTestClass {

    static testMethod void myUnitTest() {
      list<Wholesaler__c> wholeSaler= TestFactory.createWholeSaler();
	   
	   insert wholeSaler;
	   wholeSaler[0].Wholesaler_ID__c ='1234';
	   update wholeSaler;
    }
}