@isTest
public class EmailSenderTest {
		public static testMethod void testschedule() {
            Test.StartTest();
            
            // Create a Config Email configuration
        insert TestFactory.createEmailonfiguration();
        
            // Get custom settings emails for errors sending
            String configEmails = Email_Configuration__c.getInstance('NotificationEmails').Email_Ids__c;
            EmailSender.sendMail(new list<String>{configEmails}, 'Test', 'Test');
            Test.stopTest(); 
        }
}