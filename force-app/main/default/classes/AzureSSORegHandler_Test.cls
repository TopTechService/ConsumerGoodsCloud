@isTest
public class AzureSSORegHandler_Test {
     
    static testMethod void testCreateAndUpdateUser() {
        AzureSSORegHandler handler = new AzureSSORegHandler();
        Auth.UserData sampleData = new Auth.UserData('testId', 'testFirst', 'testLast',
                                                     'testFirst testLast', 'testuser@example.org', null, 'testuserlong@fs.org', 'en_US', 'facebook',
                                                     null, new Map<String, String>{'language' => 'en_US'});
        User u = handler.createUser(null, sampleData);

        //Test Can create method - blank currently
        Boolean canCreate = handler.canCreateUser(sampleData);
        system.assertEquals(False, canCreate);
        
        //Test Update user - blank currently
         handler.updateUser(u.id,null,sampleData);

        
    }
    
    
}