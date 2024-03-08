@isTest
private class PDF_Equipment_Movement_Request_TEST {

    public static testMethod void generatePDF_WithoutAssetRegister() {
        // Page
        PageReference pageRef = Page.PDF_Equipment_Movement_Request;
        Test.setCurrentPage(pageRef);

        // Controller
        PDF_Equipment_Movement_Request pdfcls = new PDF_Equipment_Movement_Request();
        pdfcls.generate();
    }

    public static testMethod void generatePDF_WithAssetRegister() {
        
        // Get profile
        Profile profile = [SELECT Id FROM Profile WHERE Name='Standard User']; 

        // Create user
        User user = new User(
            Alias = 'standt',
            Email = 'sgsfdfghgfgmgbkdfsngldfks@test.org',
            Phone = '+7777777777',
            MobilePhone = '+9999999999',
            EmailEncodingKey = 'UTF-8',
            FirstName = 'Firstname',
            LastName = 'Lastname',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = profile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'sgsfdfghgfgmgbkdfsngldfks@test.org'
        );
        insert user;

        System.runAs(user){

            // Create account
            Account account = new Account(
                Name = 'Test Account Name',
                ShippingStreet = 'ShippingStreet',
                ShippingCity = 'ShippingCity',
                ShippingState = 'ShippingState',
                ShippingPostalCode = '777777',
                OwnerId = user.Id
            );
            insert account;

            // Create contact
            Contact contact = new Contact(
                LastName = 'Lastname',
                FirstName = 'Firstname',
                Phone = '+7777777777',
                MobilePhone = '+9999999999'
            );
            insert contact;

            // Create Asset Register
            Asset_Register__c assetRegister = new Asset_Register__c(
                Outlet_Contact__c = contact.Id,
                Account__c = account.Id,
                Serial_Number__c = 'SerialNumber',
                Removal_Requested__c = true,
                Removal_Requested_Date__c = Date.today(),
                Requested_Date__c = Date.today(),
                Removal_Date__c = Date.today(),
                Product_family_class__c = 'Fridge',
                Product_Name__c = 'Negroni Barrel',
                A_Brand__c = 'Campari'
            );
            insert assetRegister;

            // Create Email Template
            EmailTemplate emailTemplate = new EmailTemplate (
                isActive = true,
                Name = 'name',
                DeveloperName = 'Email_Template',
                TemplateType = 'text',
                FolderId = UserInfo.getUserId(),
                Subject = 'Your Subject Here'
            );
            insert emailTemplate;

            // Custom settings
            Asset_Register_Configuration__c setting = new Asset_Register_Configuration__c(
                Email_Template__c = emailTemplate.developerName,
                Asset_Supplier_Email__c = 'mvdjsdfdfdssdfgdfgdsf@dgfdhgdfsh.test'
            );
            insert setting;


            // Page
            PageReference pageRef = Page.PDF_Equipment_Movement_Request;
            pageRef.getParameters().put('id', assetRegister.Id);
            Test.setCurrentPage(pageRef);

            // Controller
            PDF_Equipment_Movement_Request pdfcls = new PDF_Equipment_Movement_Request();
            pdfcls.generate();
        }
    }

    public static testMethod void generatePDF_WithAssetRegister_PhoneNull() {
        
        // Get profile
        Profile profile = [SELECT Id FROM Profile WHERE Name='Standard User']; 

        // Create user
        User user = new User(
            Alias = 'standt',
            Email = 'sgsfdfghgfgmgbkdfsngldfks@test.org',
            Phone = null,
            MobilePhone = '+9999999999',
            EmailEncodingKey = 'UTF-8',
            FirstName = 'Firstname',
            LastName = 'Lastname',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = profile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'sgsfdfghgfgmgbkdfsngldfks@test.org'
        );
        insert user;

        System.runAs(user){

            // Create account
            Account account = new Account(
                Name = 'Test Account Name',
                ShippingStreet = 'ShippingStreet',
                ShippingCity = 'ShippingCity',
                ShippingState = 'ShippingState',
                ShippingPostalCode = '777777',
                OwnerId = user.Id
            );
            insert account;

            // Create contact
            Contact contact = new Contact(
                LastName = 'Lastname',
                FirstName = 'Firstname',
                Phone = '+7777777777',
                MobilePhone = '+9999999999'
            );
            insert contact;

            // Create Asset Register
            Asset_Register__c assetRegister = new Asset_Register__c(
                Outlet_Contact__c = contact.Id,
                Account__c = account.Id,
                Serial_Number__c = 'SerialNumber',
                Removal_Requested__c = true,
                Removal_Requested_Date__c = Date.today(),
                Requested_Date__c = Date.today(),
                Removal_Date__c = Date.today(),
                Product_family_class__c = 'Fridge',
                Product_Name__c = 'Negroni Barrel',
                A_Brand__c = 'Campari'
            );
            insert assetRegister;

            // Create Email Template
            EmailTemplate emailTemplate = new EmailTemplate (
                isActive = true,
                Name = 'name',
                DeveloperName = 'Email_Template',
                TemplateType = 'text',
                FolderId = UserInfo.getUserId(),
                Subject = 'Your Subject Here'
            );
            insert emailTemplate;

            // Custom settings
            Asset_Register_Configuration__c setting = new Asset_Register_Configuration__c(
                Email_Template__c = emailTemplate.developerName,
                Asset_Supplier_Email__c = 'mvdjsdfdfdssdfgdfgdsf@dgfdhgdfsh.test'
            );
            insert setting;


            // Page
            PageReference pageRef = Page.PDF_Equipment_Movement_Request;
            pageRef.getParameters().put('id', assetRegister.Id);
            Test.setCurrentPage(pageRef);

            // Controller
            PDF_Equipment_Movement_Request pdfcls = new PDF_Equipment_Movement_Request();
            pdfcls.generate();
        }
    }

    public static testMethod void generatePDF_WithAssetRegister_RemovalRequested_False() {
        
        // Get profile
        Profile profile = [SELECT Id FROM Profile WHERE Name='Standard User']; 

        // Create user
        User user = new User(
            Alias = 'standt',
            Email = 'sgsfdfghgfgmgbkdfsngldfks@test.org',
            Phone = null,
            MobilePhone = '+9999999999',
            EmailEncodingKey = 'UTF-8',
            FirstName = 'Firstname',
            LastName = 'Lastname',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = profile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'sgsfdfghgfgmgbkdfsngldfks@test.org'
        );
        insert user;

        System.runAs(user){

            // Create account
            Account account = new Account(
                Name = 'Test Account Name',
                ShippingStreet = 'ShippingStreet',
                ShippingCity = 'ShippingCity',
                ShippingState = 'ShippingState',
                ShippingPostalCode = '777777',
                OwnerId = user.Id
            );
            insert account;

            // Create contact
            Contact contact = new Contact(
                LastName = 'Lastname',
                FirstName = 'Firstname',
                Phone = '+7777777777',
                MobilePhone = '+9999999999'
            );
            insert contact;

            // Create Asset Register
            Asset_Register__c assetRegister = new Asset_Register__c(
                Outlet_Contact__c = contact.Id,
                Account__c = account.Id,
                Serial_Number__c = 'SerialNumber',
                Removal_Requested__c = false,
                Removal_Requested_Date__c = Date.today(),
                Requested_Date__c = Date.today(),
                Removal_Date__c = Date.today(),
                Product_family_class__c = 'Fridge',
                Product_Name__c = 'Negroni Barrel',
                A_Brand__c = 'Campari'
            );
            insert assetRegister;

            // Create Email Template
            EmailTemplate emailTemplate = new EmailTemplate (
                isActive = true,
                Name = 'name',
                DeveloperName = 'Email_Template',
                TemplateType = 'text',
                FolderId = UserInfo.getUserId(),
                Subject = 'Your Subject Here'
            );
            insert emailTemplate;

            // Custom settings
            Asset_Register_Configuration__c setting = new Asset_Register_Configuration__c(
                Email_Template__c = emailTemplate.developerName,
                Asset_Supplier_Email__c = 'mvdjsdfdfdssdfgdfgdsf@dgfdhgdfsh.test'
            );
            insert setting;


            // Page
            PageReference pageRef = Page.PDF_Equipment_Movement_Request;
            pageRef.getParameters().put('id', assetRegister.Id);
            Test.setCurrentPage(pageRef);

            // Controller
            PDF_Equipment_Movement_Request pdfcls = new PDF_Equipment_Movement_Request();
            pdfcls.generate();
        }
    }

    public static testMethod void generatePDF_WithAssetRegister_RemovalRequested_Null() {
        
        // Get profile
        Profile profile = [SELECT Id FROM Profile WHERE Name='Standard User']; 

        // Create user
        User user = new User(
            Alias = 'standt',
            Email = 'sgsfdfghgfgmgbkdfsngldfks@test.org',
            Phone = null,
            MobilePhone = '+9999999999',
            EmailEncodingKey = 'UTF-8',
            FirstName = 'Firstname',
            LastName = 'Lastname',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = profile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'sgsfdfghgfgmgbkdfsngldfks@test.org'
        );
        insert user;

        System.runAs(user){

            // Create account
            Account account = new Account(
                Name = 'Test Account Name',
                ShippingStreet = 'ShippingStreet',
                ShippingCity = 'ShippingCity',
                ShippingState = 'ShippingState',
                ShippingPostalCode = '777777',
                OwnerId = user.Id
            );
            insert account;

            // Create contact
            Contact contact = new Contact(
                LastName = 'Lastname',
                FirstName = 'Firstname',
                Phone = '+7777777777',
                MobilePhone = '+9999999999'
            );
            insert contact;

            // Create Asset Register
            Asset_Register__c assetRegister = new Asset_Register__c(
                Outlet_Contact__c = contact.Id,
                Account__c = account.Id,
                Serial_Number__c = 'SerialNumber',
                // Removal_Requested__c = null,
                Removal_Requested_Date__c = Date.today(),
                Requested_Date__c = Date.today(),
                Removal_Date__c = Date.today(),
                Product_family_class__c = 'Fridge',
                Product_Name__c = 'Negroni Barrel',
                A_Brand__c = 'Campari'
            );
            insert assetRegister;

            // Create Email Template
            EmailTemplate emailTemplate = new EmailTemplate (
                isActive = true,
                Name = 'name',
                DeveloperName = 'Email_Template',
                TemplateType = 'text',
                FolderId = UserInfo.getUserId(),
                Subject = 'Your Subject Here'
            );
            insert emailTemplate;

            // Custom settings
            Asset_Register_Configuration__c setting = new Asset_Register_Configuration__c(
                Email_Template__c = emailTemplate.developerName,
                Asset_Supplier_Email__c = 'mvdjsdfdfdssdfgdfgdsf@dgfdhgdfsh.test'
            );
            insert setting;


            // Page
            PageReference pageRef = Page.PDF_Equipment_Movement_Request;
            pageRef.getParameters().put('id', assetRegister.Id);
            Test.setCurrentPage(pageRef);

            // Controller
            PDF_Equipment_Movement_Request pdfcls = new PDF_Equipment_Movement_Request();
            pdfcls.generate();
        }
    }
}