/**
 * @author : Geeta Kushwaha, geeta.kushwaha@arxxus.com
 * @date : 16-01-2014
 * @Description : This is test class for ResetVolumeOnAccountScheduler 
 */
@isTest
private class ResetVolumeOnAccountSchedulerTest {

    static testMethod void myUnitTest() {
        Test.StartTest();
        ResetVolumeOnAccountScheduler sh1 = new ResetVolumeOnAccountScheduler();
        String sch =  '0 0 0 1 1 ?';
        system.schedule('Update Account Data', sch, sh1);
        Test.stopTest();
    }
}