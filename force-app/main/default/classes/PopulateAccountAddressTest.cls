/**
 * @author    : Created by Geeta Kushwaha on 3 June, 2013  geeta.kushwaha@arxxus.com
 * @Purpose   : Test Class
 * @Criteria  : This is test class for PopulateAccountAddress
 * @Modified  : Modified by Geeta Kushwaha on 3 June, 2013  geeta.kushwaha@arxxus.com
 */
@isTest
public class PopulateAccountAddressTest {

        static testMethod void autoPopulateAddressTest() {
        
        Id recordType = Utilities.getRecordTypeId('Account', 'Outlet');
        
        Account acc1 = TestFactory.getAccount('Acc 1', recordType);
        
        insert acc1;
        
        Account acc2 = TestFactory.getAccount('Acc 2', recordType);
        
        insert acc2;
        
        Account acc3 = TestFactory.getAccount('Acc 3', recordType);
        
        insert acc3;    
        
        test.startTest();
        
        PopulateAccountAddress paaObj =  new PopulateAccountAddress();
        
        Account retVal = paaObj.autoPopulateAddress(acc1.Id, new list<Account>{acc1,acc2,acc3});
        
        System.assertEquals(retVal.Id, acc1.Id);
        
        test.stopTest();
        
    }

}