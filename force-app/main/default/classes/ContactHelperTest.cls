@isTest
private class ContactHelperTest {

    static testMethod void myUnitTest() {
    	
    	Account acc1 = TestFactory.getAccount('Acc 1', null, '12345', null, 'NSW', 10.0, 'A');
            
        acc1.RecordTypeId = Utilities.getRecordTypeId('Account', 'Outlet');
            
        insert acc1;
        
        Account acc2 = TestFactory.getAccount('Acc 1', null, '12345', null, 'NSW', 10.0, 'A');
            
        insert acc2;
        
        Contact con1 = TestFactory.getContact('Last Name1', acc1.Id);
        
        con1.FirstName = 'First Name1';
        
        insert con1;
        
        Contact con2 = TestFactory.getContact('Last Name2', acc1.Id);
        
        con2.FirstName = 'First Name2';
        
        insert con2;
    
        Test.startTest();
        
        ContactHelper ch = new ContactHelper();
        
        ch.accId = acc1.Id;
        
        list <Contact> contactsList = ch.getContactName();
        
        System.assertEquals(contactsList.size(),2);
        
        set <Id> contactIdSet = new set<Id>();
        
        for(Contact c : contactsList)
        
            contactIdSet.add(c.Id);
            
        System.assert(contactIdSet.contains(con1.Id));
        
        System.assert(contactIdSet.contains(con2.Id)); 

        ch.accId = acc2.Id;
        
        System.assertEquals(ch.getContactName().size(),0);
        
        Test.stopTest();
    
    }
    
}