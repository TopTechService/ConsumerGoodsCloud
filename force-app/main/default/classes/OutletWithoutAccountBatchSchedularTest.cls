@isTest
public class OutletWithoutAccountBatchSchedularTest {
        public static testMethod void testschedule() {
            Test.StartTest();
            OutletWithoutAccountFinderBatchSchedular sh1 = new OutletWithoutAccountFinderBatchSchedular();
            String sch = '0 0 23 * * ?'; 
            //system.schedule('OutletWithoutAccountFinderBatchSchedular', sch, sh1); 
            Test.stopTest(); 
        }
}