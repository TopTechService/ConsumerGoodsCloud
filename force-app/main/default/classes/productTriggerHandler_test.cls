@isTest(seealldata=false)
public class productTriggerHandler_test {
    
    static testMethod void newProductToRangeTest(){
        
        Id bannerGrpId = Utilities.getRecordTypeId('Account', 'Banner Group');
        Id accOutlet = Utilities.getRecordTypeId('Account', 'Outlet');
        Profile p = [select id from profile where name='System Administrator'];
        
        Account bannergrp1 = TestFactory.getAccount('Banner Grp 1', bannerGrpId);
        bannergrp1.My_Sales_Id__c = '1';
        insert bannergrp1;
        
        Region__c region1 = TestFactory.getRegion('1', '001');
        insert region1;
        
        State__c state1 = TestFactory.getState(region1.Region_ID__c);
        insert state1;
        
        Account acc;
        
        acc = TestFactory.getAccount('Acc 1', bannergrp1.Id, '12345', state1.Id, 'NSW', 10.0, 'A');
        acc.RecordTypeId = accOutlet;
        acc.Called_On__c = true;
        insert acc;
        
        Brand__c brand = new Brand__c();
        brand.Brand_ID__c = '46';
        brand.Name = 'Brand Test';
        insert brand;
        
        test.startTest();
        
        Product__c prod = New Product__c();
        prod.Name = 'Product Name';
        prod.Product_ID__c = '123';
        prod.Brand_ID__c = '46';
        prod.Standard_Range__c = true;
        insert prod;
        
        prod.Standard_Range__c = false;
        update prod;
        
        prod.Standard_Range__c = true;
        update prod;
        
        acc.Called_On__c =false;
        update acc;
        
        acc.Called_On__c =true;
        update acc;
        
        Account acc2;
        
        acc2 = TestFactory.getAccount('Acc 2', bannergrp1.Id, '12345', state1.Id, 'NSW', 10.0, 'A');
        acc2.RecordTypeId = accOutlet;
        acc2.Called_On__c = true;
        insert acc2;
        
        //delete prod;
        
        test.stopTest();
        
        
    }

    @isTest 
    static void consumerGoodsCloudTests() {

        //Setup test data

        Brand__c brand = new Brand__c();
        brand.Brand_ID__c = '55';
        brand.Name = 'Brand Test';
        brand.SAP_Brand_Code__c = 'CG0A5555';
        insert brand;

        //Product2 should be created via flow
        Product2 testBrand = [SELECT Id, Name, cgcloud__Consumer_Goods_Product_Code__c,
                              cgcloud__Consumer_Goods_External_Product_Id__c
                              FROM Product2 
                              WHERE cgcloud__Consumer_Goods_External_Product_Id__c = :brand.SAP_Brand_Code__c
                              LIMIT 1
                              ];
        if (testBrand.Id == null) {
            testBrand.Name = brand.Name;
            testBrand.cgcloud__Consumer_Goods_Product_Code__c = brand.Brand_ID__c;
            testBrand.cgcloud__Consumer_Goods_External_Product_Id__c = brand.SAP_Brand_Code__c;
            insert testBrand;
        }

        brand.Product2_Id__c = testBrand.Id;
        update brand;

        String productName = 'Test Drink 750ml 4 pack';
        String productId = '273';
        String skuName = 'Tst Drnk 750';
        String cpiName = 'Test Drink 62 year old';
        String classification = 'Glass';
        String skuFormat = 'Bottle';
        String productBrandId = brand.Id;
        String reportingBrand = 'Other';
        String productCategory = 'Spirits';
        String mlsPerBottle = '750';
        String productPackSize = '4';
        Decimal bottlesPerCarton = 3;
        String sapCode = 'GA273';
        String promotedRangeId = '44';

        //Start testing
        //Create a new MySales Product
        Test.startTest();
        Product__c newMSProduct = new Product__c(Name = productName,
                                                 Product_ID__c = productId,
                                                 SKU_Name__c = skuName,
                                                 CPI_Name__c = cpiName,
                                                 Classification__c = classification,
                                                 SKU_Format__c = skuFormat,
                                                 Brand_ID__c = brand.Brand_ID__c,
                                                 Reporting_Brand__c = reportingBrand,
                                                 Product_Category__c = productCategory,
                                                 Bottles_Per_Carton__c = bottlesPerCarton,
                                                 SAP_Code__c = sapCode,
                                                 PromotedRangeID__c = promotedRangeId,
                                                 MLs_Per_Bottle__c = mlsPerBottle,
                                                 Product_Packsize__c = productPackSize,
                                                 Standard_Range__c = true,
                                                 SKU_Active__c = true,
                                                 PSS_Product__c = true,
                                                 PVS_Product__c = true
                                                 );
        insert newMSProduct;

        Product__c newMSProduct00 = new Product__c(Name = productName + '00',
                                                 Product_ID__c = productId + '00',
                                                 Brand_ID__c = brand.Brand_ID__c
                                                 );
        insert newMSProduct00;

        Product__c newMSProduct01 = new Product__c(Name = productName + '01',
                                                 Product_ID__c = productId + '01',
                                                 Brand_ID__c = brand.Brand_ID__c,
                                                 Product_Packsize__c = '1'
                                                 );
        insert newMSProduct01;


        List<Product2> insertedProducts = [SELECT Id, Name, cgcloud__Criterion_3_Product__r.Name 
                                            FROM Product2 
                                            WHERE cgcloud__Consumer_Goods_Product_Code__c = :productId
                                            ];

        //Let's update the MySales Product
        newMSProduct.Name = productName + '0';
        newMSProduct.Product_ID__c = productId + '0';
        newMSProduct.SKU_Name__c = skuName + '0';
        newMSProduct.CPI_Name__c = cpiName + '0';
        newMSProduct.Classification__c = classification + '0';
        newMSProduct.SKU_Format__c = 'Can';
        newMSProduct.Reporting_Brand__c = 'Skyy';
        newMSProduct.Product_Category__c = 'RTD';
        newMSProduct.Bottles_Per_Carton__c = bottlesPerCarton + 1;
        newMSProduct.SAP_Code__c = sapCode + '0';
        newMSProduct.PromotedRangeID__c = promotedRangeId + '0';
        newMSProduct.MLs_Per_Bottle__c = '1000';
        newMSProduct.Product_Packsize__c = null;
        newMSProduct.Standard_Range__c = false;
        newMSProduct.SKU_Active__c = false;
        newMSProduct.PSS_Product__c = false;
        newMSProduct.PVS_Product__c = false;
        newMSProduct.Deactivate__c = true;
        newMSProduct.Shor_Name_Flows__c = 'Changed'; 

        update newMSProduct;
        newMSProduct.Product_Packsize__c = '1';
        update newMSProduct;
        newMSProduct.Product_Packsize__c = '4';
        update newMSProduct;
        Test.stopTest();

        //Assert that a corresponding Product2 has been created.
        System.assertEquals(1, insertedProducts.size());
        System.assertEquals('Test Drink 750ml 4 pack', insertedProducts[0].Name);
        System.assertEquals(brand.Name, insertedProducts[0].cgcloud__Criterion_3_Product__r.Name);

        //Initialise the Product2 record and assert that it has also been updated.
        List<Product2> triggeredProducts = [SELECT Id, Name, cgcloud__Criterion_3_Product__r.Name 
                                            FROM Product2 
                                            WHERE cgcloud__Consumer_Goods_Product_Code__c = :newMSProduct.Product_ID__c
                                            ];

        List<Product__c> msProdcuts = [SELECT Name FROM Product__c];
        System.debug('Size= ' + msProdcuts.size());
        System.debug('Name= ' + msProdcuts[0].Name);

        System.assertEquals(1, triggeredProducts.size());
        System.assertEquals(newMSProduct.Name, triggeredProducts[0].Name);                                    
    }
    
}