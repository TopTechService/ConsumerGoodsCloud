@isTest
public class contentDocument_handlerTest {
    
    static testMethod void myUnitTest_OnTask() {
        test.startTest();
        Task tsk = New Task();
        tsk.Subject = 'test';
        tsk.Type_of_Call__c = 'Outlet Visit';
        insert tsk;
        
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;   
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = tsk.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
               
        test.stopTest();
        
    }
    
    static testMethod void myUnitTest_OnEvent() {
        test.startTest();
        Event evt = New Event();
        evt.Subject = 'test';
        evt.DurationInMinutes = 10;
        evt.StartDateTime = system.now();
        evt.Type_of_Call__c = 'Outlet Visit';
        insert evt;
        
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;   
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = evt.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        
        test.stopTest();
        
    }
}