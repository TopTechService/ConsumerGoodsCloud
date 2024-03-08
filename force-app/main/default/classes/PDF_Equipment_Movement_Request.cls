/*
*   Author : Andrey Piasetski @ Carnac Group
*   Created : 02/09/2019
*
*   Description : A document to obtain the required data for the Asset_Register__C object
*   and its associated objects. Used as a controller to generate a pdf file from a visualforce page.
*   You have sent a message and attached a pdf file to the message.
*
*   Method 1 : generatePDF()
*   Method 2 : generateAttachment()
*   Method 3 : sendMessage(Attachment)
*   Method 4 : generate()
*
*/ 

public with sharing class PDF_Equipment_Movement_Request {
    
    public String id { get; set; }
    public Asset_Register__c assetRegister { get; set; }
    public String userFullName { get; set; }
    public Date generationDate { get; set; }
    public User userInformation { get; set; }
    public Boolean useShiping {get ;set;}

    /*
    *   Using the id parameter from the parameters of the current page, execute a request
    *   to get the data of the Asset_Register__c object record, and also get the user data of the owner
    *   of the associated account record.
    */
    public PDF_Equipment_Movement_Request() {
        String id = ApexPages.currentPage().getParameters().get('id');

        List<Asset_Register__c> listAssetRegister = [
            SELECT Id, Serial_Number__c, Removal_Requested__c, Removal_Requested_Date__c, Requested_Date__c, Product_family_class__c, Removal_Date__c,
            Product_Name__c, A_Brand__c, Outlet_Contact__r.Name,Outlet_Contact__r.FirstName, Outlet_Contact__r.LastName, Outlet_Contact__r.Phone, Outlet_Contact__r.MobilePhone,
            Account__r.Name, Account__r.ShippingStreet, Account__r.ShippingCity, Account__r.ShippingState, Account__r.ShippingPostalCode,
            Account__r.BillingStreet, Account__r.BillingCity, Account__r.BillingState, Account__r.BillingPostalCode,
            Account__r.OwnerId
            FROM Asset_Register__c
            WHERE Id=:id
            ORDER BY CreatedDate DESC LIMIT 1
        ];

        if(listAssetRegister.isEmpty()) {
            return;
        }
        
        Integer ShippingCount = 0;
        Integer BillingCount = 0;

        if(listAssetRegister[0].Account__r.ShippingStreet != null){
            ShippingCount ++;
        }
        if(listAssetRegister[0].Account__r.ShippingCity != null){
            ShippingCount ++;
        }
        if(listAssetRegister[0].Account__r.ShippingState != null){
            ShippingCount ++;
        }
        if(listAssetRegister[0].Account__r.ShippingPostalCode != null){
            ShippingCount ++;
        }

        if(listAssetRegister[0].Account__r.BillingStreet != null){
            BillingCount ++;
        }
        if(listAssetRegister[0].Account__r.BillingCity != null){
            BillingCount ++;
        }
        if(listAssetRegister[0].Account__r.BillingState != null){
            BillingCount ++;
        }
        if(listAssetRegister[0].Account__r.BillingPostalCode != null){
            BillingCount ++;
        }

        if(ShippingCount > BillingCount){
            useShiping = true;
        }else {
            useShiping = false;
        }


        if (listAssetRegister.size() == 1) {
            this.id = listAssetRegister[0].Id;
            this.assetRegister = listAssetRegister[0];
        } else {
            this.id = ApexPages.currentPage().getParameters().get('id');
            this.assetRegister = null;
        }

        this.userFullName = UserInfo.getName();
        this.generationDate = Date.today();

        if (this.assetRegister != null && this.assetRegister.Account__r.OwnerId != null) {
            List<User> listUser = [
                SELECT Id, Name, Email, Phone, MobilePhone
                FROM User
                WHERE Id=:this.assetRegister.Account__r.OwnerId
                LIMIT 1
            ];

            if (listUser.size() == 1) {
                this.userInformation = listUser[0];

                if (listUser[0].Phone == null && listUser[0].MobilePhone != null) {
                    this.userInformation.Phone = listUser[0].MobilePhone;
                }
            }
        }
    }

    /*
    *   Using the visualforce page, pass the id parameter to it and the result is the
    *   body of the generated document in Blob format.
    */
    public Blob generatePDF(){
        if (this.id != null) {
            PageReference page_EquipmentMovementRequest = new PageReference('/apex/PDF_Equipment_Movement_Request');
            page_EquipmentMovementRequest.getParameters().put('id', this.id);
            page_EquipmentMovementRequest.setRedirect(false);

            Blob generatedPDF;
            try {
                generatedPDF = page_EquipmentMovementRequest.getContentAsPDF();
            }
            catch (Exception e) {
                generatedPDF = Blob.valueOf(e.getMessage());
            }

            return generatedPDF;
        }
        return null;
    }

    /*
    *   If successful, create a new Attachment and attach it to the current record
    *   of the Asset_Register__с object
    */
    public Attachment generateAttachment() {
        Blob body = this.generatePDF();
        if (body != null) {
            Datetime dateNow = Datetime.now();
            String strConvertedDate = dateNow.format('yyyy-MM-dd HH-mm-ss');
            Attachment attachment = new Attachment();
            attachment.Body = body;
            attachment.Name = 'Equipment Movement Request ' + strConvertedDate + '.pdf';
            attachment.ParentId = this.id;
            insert attachment;
            return attachment;
        }
        return null;
    }

    /*
    *   The method of sending the email. To start, get the data from the record
    *   Custom Settings and Email Template. Then generate a new message and attach the generated new
    *   Attachment to it. Send a message and display a message to the console about the result of sending.
    */
    public void sendMessage(Attachment attachment) {
        // GET SETTINGS
        Asset_Register_Configuration__c setting = Asset_Register_Configuration__c.getInstance();

        // GET TEMPLATE
        EmailTemplate template = [
            SELECT Id, Subject
            FROM EmailTemplate
            WHERE DeveloperName =:setting.Email_Template__c
        ];
        
        // NEW MESSAGE
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = new String[] {setting.Asset_Supplier_Email__c};

        // SUBJECT
        if (!this.assetRegister.Removal_Requested__c) {
            message.subject = 'Request New';

        } else if (this.assetRegister.Removal_Requested__c) {
            message.subject = 'Remove Asset';
        }

        // BODY
        Messaging.SingleEmailMessage messageBody = Messaging.renderStoredEmailTemplate(template.Id, UserInfo.getUserId(), this.id);
        String body = messageBody.getPlainTextBody();
        message.plainTextBody = body;

        // ATTACHMENT
        Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment();
        emailAttachment.setContentType('application/pdf');
        emailAttachment.setFileName(attachment.Name);
        emailAttachment.setBody(attachment.Body);
        message.setFileAttachments(new Messaging.EmailFileAttachment[]{ emailAttachment });

        // SEND MESSAGES
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>{message};
        List<Messaging.SendEmailResult> results = Messaging.sendEmail(messages);

        if (results[0].success) {
            System.debug('The email was sent successfully.');
        } else {
            System.debug('The email failed to send: ' + results[0].errors[0].message);
        }
    }

    /*
    *   This method is used when you click a button on the Asset_Register__C record page, using the link
    *   to the VisualForce page with the id parameter
    */
    public PageReference generate() {
        Attachment attachment = this.generateAttachment();

        if (attachment != null) {
            this.sendMessage(attachment);
        }

        PageReference url = new PageReference('/' + this.id);
        return url;
    }
}