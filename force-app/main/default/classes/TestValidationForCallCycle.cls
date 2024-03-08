/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
public class TestValidationForCallCycle {
	public list<Call_Cycle__c> callCycleList;
	public date startDate;
	public date endDate;
	public TestValidationForCallCycle(){
		startDate 	= date.newInstance(2013, 1, 7);
		endDate		= date.newInstance(2013, 5, 24);
		
		callCycleList = new list<Call_Cycle__c>();
		
		// call cycle  for australia
		Call_Cycle__c call1 = getCallCycel('Australia');
		call1.Start_Date__c = startDate;
		call1.End_Date__c 	= endDate;
		callCycleList.add(call1);
		
		// call cycle  for australia
		Call_Cycle__c call2 = getCallCycel('Australia');
		call2.Start_Date__c = startDate;
		call2.End_Date__c 	= startDate;
		callCycleList.add(call2);
		
		
		// call cycle  for australia
		Call_Cycle__c call3 = getCallCycel('Australia');
		call3.Start_Date__c = startDate;
		call3.End_Date__c 	= enddate.addDays(10);
		callCycleList.add(call3);
		
		// call cycle  for australia
		Call_Cycle__c call6 = getCallCycel('');
		//call5.Start_Date__c = startDate;
		//call5.End_Date__c 	= startDate.addDays(55);
		call6.Month__c 		= 'January';
		call6.year__c		= '2013';
		callCycleList.add(call6);
		
		// call cycle  for australia
		Call_Cycle__c call7 = getCallCycel('Australia');
		//call7.Start_Date__c = startDate;
		call7.End_Date__c 	= enddate.addDays(10);
		callCycleList.add(call7);
		
		Call_Cycle__c call8 = getCallCycel('Australia');
		call8.Start_Date__c = startDate.addDays(3);
		call8.End_Date__c 	= startDate.addDays(30);
		callCycleList.add(call8);
		
		Call_Cycle__c call9 = getCallCycel('Australia');
		call9.Start_Date__c = startDate;
		call9.End_Date__c 	= startDate.addDays(11);
		callCycleList.add(call9);
		
		Call_Cycle__c call10 = getCallCycel('Australia');
        call10.Start_Date__c = date.newInstance(2014, 1, 6);
        call10.End_Date__c   = date.newInstance(2014, 2, 14);
        call10.Call_Cycle__c = 'Summer Call Cycle';
        
        callCycleList.add(call10);
		
		database.insert(callCycleList,false);
		
	}
	
	
	
	
    static testMethod void myUnitTest() {
       TestValidationForCallCycle callCycle = new TestValidationForCallCycle();
    }
    
    public Call_Cycle__c getCallCycel(string location ){
    	
    	Call_Cycle__c callCycle = new Call_Cycle__c();
    	callCycle.Call_Cycle__c = 'Call Cycle 1';
    	callCycle.Location__c = location;
    	//callCycle.Unique_Field__c	= 'cal1236589';
    	
    	return callCycle;
    }
}