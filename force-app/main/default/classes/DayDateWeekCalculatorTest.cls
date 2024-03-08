/**
 * @author    : Created by Geeta Kushwaha on 4 June, 2013  geeta.kushwaha@arxxus.com
 * @Purpose   : Test Class
 * @Criteria  : This is test class for DayDateWeekCalculator
 * @Modified  : Modified by Geeta Kushwaha on 4 June, 2013  geeta.kushwaha@arxxus.com
 */
@isTest
public class DayDateWeekCalculatorTest {

    static testMethod void getActivityDateAusTest() {
    	
        DayDateWeekCalculator calc = new DayDateWeekCalculator('australia');
        
        System.assertEquals(calc.getActivityDate(0,'Week 1',date.newInstance(2013, 1, 28)),date.newInstance(2013, 1, 28));
        
        System.assertEquals(calc.getActivityDate(0,'Week 2',date.newInstance(2013, 1, 28)),date.newInstance(2013, 2, 4));
        
    }
    
    static testMethod void getActivityDayTest(){
    	
    	DayDateWeekCalculator calc = new DayDateWeekCalculator('australia');
    	
    	System.assertEquals(3,calc.getActivityDay(0).length());
    	
    	System.assertEquals(3,calc.getActivityDay(1).length());
    	
    	System.assertEquals(3,calc.getActivityDay(2).length());
    	
    	System.assertEquals(3,calc.getActivityDay(3).length());
    	
    	System.assertEquals(3,calc.getActivityDay(4).length());
    	
    	System.assertEquals(3,calc.getActivityDay(5).length());
    	
    	System.assertEquals(3,calc.getActivityDay(6).length());
    	
    	System.assertEquals('',calc.getActivityDay(7));
    	
    }
    
    static testMethod void getWeekDurationAllTest(){
    	
    	Call_Cycle__c cc1 = TestFactory.createCallCycle('Call Cycle 1',date.newInstance(2013,1,28), date.newInstance(2013, 3, 15), 'Australia', null, '2013');
        
        insert cc1;
       
    	DayDateWeekCalculator calc = new DayDateWeekCalculator('australia');
    	
    	test.startTest();
    	
    	list <Date> res1 = calc.getWeekDuration('All', cc1);
    	
    	System.assertEquals(res1[0], cc1.Start_Date__c);
    	
    	System.assertEquals(res1[1], cc1.End_Date__c);
    	
  
    	test.stopTest();
    	
    }
    
    static testMethod void getWeekDurationAusTest(){
        
        Call_Cycle__c cc1 = TestFactory.createCallCycle('Call Cycle 1',date.newInstance(2013,1,28), date.newInstance(2013, 3, 15), 'Australia', null, '2013');
        
        insert cc1;
        
        DayDateWeekCalculator calc = new DayDateWeekCalculator('australia');
        
        test.startTest();
        
        list <Date> res1 = calc.getWeekDuration('Week 1', cc1);
        
        System.assertEquals(res1[0], cc1.Start_Date__c);
        
        System.assertEquals(res1[1], cc1.Start_Date__c.addDays(6));
        
        list <Date> res2 = calc.getWeekDuration('Week 2', cc1);
        
        System.assertEquals(res2[0], cc1.Start_Date__c.addDays(7));
        
        System.assertEquals(res2[1], cc1.Start_Date__c.addDays(13));
        
        test.stopTest();
        
    }
      
    static testMethod void getCallCycleRecAusTest(){
        
        Call_Cycle__c cc1 = TestFactory.createCallCycle('Call Cycle 1',date.newInstance(2013,1,28), date.newInstance(2013, 3, 15), 'Australia', null, '2013');
        
        insert cc1;
        
        DayDateWeekCalculator calc = new DayDateWeekCalculator('australia');
        
        test.startTest();
        
        System.assertEquals(calc.getCallCycleRec(cc1.Year__c, cc1.Call_Cycle__c, cc1.Month__c).Id,cc1.Id);
        
        test.stopTest();
        
    }
    
  
    static testMethod void getWeekNameSelectedTest(){
        
        
        Call_Cycle__c cc2 = TestFactory.createCallCycle('Call Cycle 1',date.newInstance(2013,1,28), date.newInstance(2013, 3, 15), 'Australia', null, '2013');
        
        insert cc2;
        
        
        DayDateWeekCalculator calc2 = new DayDateWeekCalculator('australia');
        
        test.startTest();
        
        System.assertEquals(calc2.getWeekName(date.newInstance(2013,1,28),cc2,'Week 1'), 'Week 1');
        
        test.stopTest();
        
    }
    
    static testMethod void getWeekNameAllAusTest(){
    	
    	Call_Cycle__c cc1 = TestFactory.createCallCycle('Call Cycle 1',date.newInstance(2013,1,28), date.newInstance(2013, 3, 15), 'Australia', null, '2013');
        
        insert cc1;
    
        DayDateWeekCalculator calc = new DayDateWeekCalculator('australia');
        
        test.startTest();
        
        System.assertEquals(calc.getWeekName(date.newInstance(2013,1,28),cc1,'Week 1'),'Week 1');
        
        System.assertEquals(calc.getWeekName(date.newInstance(2013,1,28),cc1,'All'),'Week 1');
        
        System.assertEquals(calc.getWeekName(date.newInstance(2013,2,4),cc1,'All'),'Week 2');
        
        test.stopTest();
    
    }
    

}