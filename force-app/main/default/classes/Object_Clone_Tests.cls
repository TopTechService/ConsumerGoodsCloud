@IsTest
private class Object_Clone_Tests {


    static testMethod void basicTestSingleNoChildren() {
        Account a = New Account(Name = 'Test Account',BillingCity = 'Test City', recordtypeid = '01290000000gaVo');
        insert a;

        Contact c = New Contact(LastName = 'Last', FirstName = 'First', recordtypeid= '01290000000gaVt', AccountId = a.id);
        insert c;

        Object_Clone.cloneObjectSingle(a.id,false);

        Account[] clonedAccount = [Select Name, BillingCity, recordtypeid From Account Where ID != :a.id];

        system.assertEquals(1,clonedAccount.size(), 'More than one account was created');

        //Clear out the values that would never match
        a.id = null;
        clonedAccount[0].id = null;

        system.assertEquals(a,clonedAccount[0]);

        Contact[] newContact = [Select LastName,FirstName, recordtypeid From Contact Where ID != :c.id];

        system.assertEquals(true,newContact.isEmpty(),'A contact record was created when nochildren was set to false');

    }

    /*static testMethod void basicTestSingleWhithChildren() {
        Account a = New Account(Name = 'Test Account',BillingCity = 'Test City', recordtypeid = '01290000000gaVn');
        insert a;

        Contact c = New Contact(LastName = 'Last', FirstName = 'First', AccountId = a.id, recordtypeid= '01290000000gaVt');
        insert c;

        Object_Clone.cloneObjectSingle(a.id,true);

        //Assert Records were created and linked
        Account[] clonedAccount = [Select Name, BillingCity , recordtypeid From Account Where ID != :a.id];

        system.assertEquals(1,clonedAccount.size(), 'More than one account was created');

        Contact[] newContact = [Select LastName,FirstName, AccountID, recordtypeid From Contact Where ID != :c.id];

        system.assertEquals(1,newContact.size(),'A contact record was created when nochildren was set to false');

        system.assertEquals(clonedAccount[0].id,newContact[0].AccountId,'The cloned Contact AccountID was not set to the cloned Account ID');

        //Assert they are equals sans the Ids
        a.id = null;
        clonedAccount[0].id = null;
        system.assertEquals(a,clonedAccount[0]);


        //Clear out the values that would never match
        c.id = null;
        c.AccountId = null;
        newContact[0].id = null;
        newContact[0].AccountId = null;
    }*/

    /*static testMethod void basicTestWithChildrenExcludeContact() {
        Account a = New Account(Name = 'Test Account',BillingCity = 'Test City');
        insert a;

        Contact c = New Contact(LastName = 'Last', FirstName = 'First', AccountId = a.id);
        insert c;

        Object_Clone.cloneObjectWithExclude(New Set<ID>{a.id},true,New Set<String>{'Contact'});

        Account[] clonedAccount = [Select Name, BillingCity From Account Where ID != :a.id];

        system.assertEquals(1,clonedAccount.size(), 'More than one account was created');

        //Clear out the values that would never match
        a.id = null;
        clonedAccount[0].id = null;

        system.assertEquals(a,clonedAccount[0]);

        Contact[] newContact = [Select LastName,FirstName From Contact Where ID != :c.id];

        system.assertEquals(true,newContact.isEmpty(),'A contact record was created when Contact was excluded');

    }*/


    static testMethod void noRecordsError(){
        Object_Clone.cloneObjectSingle(null,false);
        system.assertEquals(Object_Clone.NORECORDS,Object_Clone.getErrorMessage());

        Object_Clone.cloneObjectSet(New Set<ID>(), false);
        system.assertEquals(Object_Clone.NORECORDS,Object_Clone.getErrorMessage());

    }

    static testMethod void toManyTypesError(){

        Account a = New Account(Name = 'Test Account',BillingCity = 'Test City', recordtypeid = '01290000000gaVo');
        insert a;

        Contact c = New Contact(LastName = 'Last', FirstName = 'First', recordtypeid= '01290000000gaVt', AccountId = a.id);
        insert c;

        try {
            Object_Clone.queryForRecords(New Set<ID>{a.id, c.id}, null);
            system.assertEquals(false,true,'An error (TOO MANY TYPES) was supposed to be thrown and caught, thus we should have never made it here');
        }catch(Object_Clone.Object_Clone_Exception e) {
            system.assertEquals(Object_Clone.TOMANYTYPES, e.getMessage());
        }


    }

    static testMethod void NoExclusionsSet(){

        system.assertNotEquals(null,Object_Clone.excludedObjects, 'The Exclusion returned null when it should have been an empty list');
        system.assertEquals(true,Object_Clone.excludedObjects.isEmpty(),'The Exclusions were not empty despite the setter not being executed');

    }

    //TODO - Bulk Tests
    static testmethod void bulkClone(){

    }

}