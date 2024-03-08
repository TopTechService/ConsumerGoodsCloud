/**
 * @author    : Created by Geeta Kushwaha on 22 May, 2013  geeta.kushwaha@arxxus.com
 * @Purpose   : Test Class for ImageAttachment Trigger
 * @Criteria  : 
 * @Modified  : 
 */
@isTest
public class ImageAttachmentTest {

    static testMethod void attachmentInsertDeleteTest() {
    	
    	Brand__c brand = TestFactory.getBrand('1','001');
    	
    	insert brand;
    	
    	Product__c p = TestFactory.createProduct(brand.Brand_ID__c);
    	
    	insert p;
    	
    	//Product__c p1 = TestFactory.createProduct(brand.Brand_ID__c);
        
        //insert p1;
    	
    	test.startTest();
    	
    	/*
    	 * Test for Insert Attachement, valid image format
    	 */
    	
    	Attachment a1 = TestFactory.getAttachment('Product Image', p.Id, Blob.valueOf( 'this is an attachment test' ), 'image/jpeg');
    	
    	insert a1;
    	
        Product__c prodI= [Select Id, Product_Image_URL__c
                           from Product__c
                           where Id =: p.Id];
    	                           
    	System.assertEquals(prodI.Product_Image_URL__c, URL.getSalesforceBaseUrl().toExternalForm() + '/servlet/servlet.FileDownload?file='+a1.Id);
    	
    	/*
         * Test for Delete Attachement
         */
    	
    	delete a1;
    	
    	Product__c prodD = [Select Id, Product_Image_URL__c
	                       from Product__c
	                       where Id =: p.Id];
                                   
        System.assertEquals(prodD.Product_Image_URL__c, null);
        
        /* 
         * Test for insert Attachment which is not an image
         */
        
        //Attachment a2 = TestFactory.getAttachment('Product Image Text', p1.Id, Blob.valueOf( 'this is an attachment test' ), '.txt');
        Attachment a2 = TestFactory.getAttachment('Product Image Text', p.Id, Blob.valueOf( 'this is an attachment test' ), '.txt');
        
        insert a2;
        
        Product__c prodI1= [Select Id, Product_Image_URL__c
                           from Product__c
                           where Id =: p.Id];
                                   
        System.assertEquals(prodI1.Product_Image_URL__c, null);
    	
        test.stopTest();
        
    }
    
}