/**
 * @author    : Created by Geeta Kushwaha on 3 June, 2013  geeta.kushwaha@arxxus.com
 * @Purpose   : Test Class
 * @Criteria  : This is test class for SendEmail class
 * @Modified  : Modified by Geeta Kushwaha on 3 June, 2013  geeta.kushwaha@arxxus.com
 */
@isTest
public class SendEmailTest {

    public static testMethod void testSendEmailToUsers() {
        
        SendEmail se = new SendEmail();
        
        se.sendEmailToUsers(new list<string>{'geeta.kushwaha@arxxus.com'}, new list<string>(), 'Objective Management','Plain text', 'html body');
    
        se.sendEmailToManyUsers(new list<string>{'geeta.kushwaha@arxxus.com'},  'Objective Management',new list<string>{'Plain text'}, new list<string>{'html body'});
    
    }
    
 
    
}