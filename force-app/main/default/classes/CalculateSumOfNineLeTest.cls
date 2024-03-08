/**
 * @author : Geeta Kushwaha, geeta.kushwaha@arxxus.com
 * @date : 27-01-2014
 * @Description : This class is test class for CalculateSumOfNineLe
 */
@isTest
private class CalculateSumOfNineLeTest {

    static testMethod void myUnitTest() {

		Id bannerId = Utilities.getRecordTypeId('Account', 'Banner Group');
        
        Account parentBanner = TestFactory.getAccount('IBA', bannerId);
        
        parentBanner.My_Sales_Id__c = '12';
        
        insert parentBanner;
        
        list <Account> childBanner = new list<Account>();
        
        childBanner.add(TestFactory.getAccount('Child Banner1', bannerId));
        
        childBanner.add(TestFactory.getAccount('Child Banner2', bannerId));
        
        childBanner.add(TestFactory.getAccount('Child Banner3', bannerId));
        
        childBanner.add(TestFactory.getAccount('Child Banner4', bannerId));
        
        integer i = 1000;
        
        for(Account acc : childBanner) {
            
            acc.ParentId = parentBanner.Id;
            
            acc.My_Sales_Id__c = ''+i;
            
            i++;
            
        }
        
        insert childBanner;
        
        Region__c region = TestFactory.getRegion('1256','NSW');
        
        region.Name = 'NSW';
        
        insert region;
        
        State__c state = TestFactory.getState(region.Region_ID__c);
        
        insert state;
        
        Account outletAccount = TestFactory.getAccount('Outlet', Utilities.getRecordTypeId('Account', 'Outlet'));
        outletAccount.Outlet_ID__c = 'OutletId1';
        outletAccount.My_Sales_Id__c = 'sales1';
        outletAccount.Volume__c = 1000;
        
        insert outletAccount;
        
        Brand__c brand = TestFactory.getBrand('Brand 5', 'Brand 5sap');
        insert brand;
        
        Product__c product1 = TestFactory.getProduct('Product1','Brand 5','Pid123','Glass','Glen Grant Glass');
        product1.PromotedRangeID__c = '1';
        insert product1;
        
        Product__c product2 = TestFactory.getProduct('Product2','Brand 5','Pid1234','RTD','Wild Turkey 101 RTD');
        product1.PromotedRangeID__c = '2';
        insert product2;
        
        Product__c product3 = TestFactory.getProduct('Product2','Brand 5','Pid1235','Wine','Cinzano Wine');
        product1.PromotedRangeID__c = '3';
        insert product3;
        
        Product__c product4 = TestFactory.getProduct('Product2','Brand 5','Pid1236','Wine',null);
        product1.PromotedRangeID__c = '4';
        insert product4;
        
        integer currentYear =  date.today().year();
        
        list <Sale_MySales__c> mySalesList = new list <Sale_MySales__c>();
        
        mySalesList.add(TestFactory.getSalesMySaleswithID(10.4, parentBanner.Id, outletAccount.Outlet_ID__c, product1.Product_ID__c, date.newInstance(currentYear,1,1),'1'));
        mySalesList.add(TestFactory.getSalesMySaleswithID(10.4, parentBanner.Id, outletAccount.Outlet_ID__c, product1.Product_ID__c, date.newInstance(currentYear,1,5),'2'));
        mySalesList.add(TestFactory.getSalesMySaleswithID(-10.4, parentBanner.Id, outletAccount.Outlet_ID__c, product2.Product_ID__c, date.newInstance(currentYear,2,1),'11'));
        mySalesList.add(TestFactory.getSalesMySaleswithID(-10.4, parentBanner.Id, outletAccount.Outlet_ID__c, product4.Product_ID__c, date.newInstance(currentYear,2,2),'12'));
        mySalesList.add(TestFactory.getSalesMySaleswithID(1.4, parentBanner.Id, outletAccount.Outlet_ID__c, product3.Product_ID__c, date.newInstance(currentYear,3,1),'13'));
        mySalesList.add(TestFactory.getSalesMySaleswithID(2.1, parentBanner.Id, outletAccount.Outlet_ID__c, product1.Product_ID__c, date.newInstance(currentYear,4,1),'14'));
        mySalesList.add(TestFactory.getSalesMySaleswithID(1.9, parentBanner.Id, outletAccount.Outlet_ID__c, product2.Product_ID__c, date.newInstance(currentYear,5,1),'15'));
        mySalesList.add(TestFactory.getSalesMySaleswithID(0.4, parentBanner.Id, outletAccount.Outlet_ID__c, product3.Product_ID__c, date.newInstance(currentYear,6,1),'16'));
        mySalesList.add(TestFactory.getSalesMySaleswithID(9.7, parentBanner.Id, outletAccount.Outlet_ID__c, product1.Product_ID__c, date.newInstance(currentYear,7,1),'17'));
        mySalesList.add(TestFactory.getSalesMySaleswithID(-6.5, parentBanner.Id, outletAccount.Outlet_ID__c, product2.Product_ID__c, date.newInstance(currentYear,8,1),'18'));
        mySalesList.add(TestFactory.getSalesMySaleswithID(67.9, parentBanner.Id, outletAccount.Outlet_ID__c, product3.Product_ID__c, date.newInstance(currentYear,9,1),'19'));
        mySalesList.add(TestFactory.getSalesMySaleswithID(2.08, parentBanner.Id, outletAccount.Outlet_ID__c, product1.Product_ID__c, date.newInstance(currentYear,10,1),'10'));
        mySalesList.add(TestFactory.getSalesMySaleswithID(9.43, parentBanner.Id, outletAccount.Outlet_ID__c, product2.Product_ID__c, date.newInstance(currentYear,11,1),'111'));
        mySalesList.add(TestFactory.getSalesMySaleswithID(2.56, parentBanner.Id, outletAccount.Outlet_ID__c, product3.Product_ID__c, date.newInstance(currentYear,12,1),'112'));
        mySalesList.add(TestFactory.getSalesMySaleswithID(2.56, parentBanner.Id, outletAccount.Outlet_ID__c, product3.Product_ID__c, date.newInstance(currentYear,12,30),'113'));
        
        mySalesList.add(TestFactory.getSalesMySaleswithID(10.4, parentBanner.Id, outletAccount.Outlet_ID__c, product1.Product_ID__c, date.newInstance(currentYear,1,1),'114'));
        mySalesList.add(TestFactory.getSalesMySaleswithID(10.4, parentBanner.Id, outletAccount.Outlet_ID__c, product2.Product_ID__c, date.newInstance(currentYear,2,1),'115'));
        mySalesList.add(TestFactory.getSalesMySaleswithID(51.4, parentBanner.Id, outletAccount.Outlet_ID__c, product3.Product_ID__c, date.newInstance(currentYear,3,1),'116'));
        mySalesList.add(TestFactory.getSalesMySaleswithID(2.1, parentBanner.Id, outletAccount.Outlet_ID__c, product1.Product_ID__c, date.newInstance(currentYear,4,1),'117'));
        mySalesList.add(TestFactory.getSalesMySaleswithID(-1.9, parentBanner.Id, outletAccount.Outlet_ID__c, product2.Product_ID__c, date.newInstance(currentYear,5,1),'118'));
        mySalesList.add(TestFactory.getSalesMySaleswithID(0.4, parentBanner.Id, outletAccount.Outlet_ID__c, product3.Product_ID__c, date.newInstance(currentYear,6,1),'121'));
        mySalesList.add(TestFactory.getSalesMySaleswithID(9.7, parentBanner.Id, outletAccount.Outlet_ID__c, product1.Product_ID__c, date.newInstance(currentYear,7,1),'122'));
        mySalesList.add(TestFactory.getSalesMySaleswithID(-1.5, parentBanner.Id, outletAccount.Outlet_ID__c, product2.Product_ID__c, date.newInstance(currentYear,8,1),'123'));
        mySalesList.add(TestFactory.getSalesMySaleswithID(63.9, parentBanner.Id, outletAccount.Outlet_ID__c, product3.Product_ID__c, date.newInstance(currentYear,9,1),'124'));
        mySalesList.add(TestFactory.getSalesMySaleswithID(26.08, parentBanner.Id, outletAccount.Outlet_ID__c, product1.Product_ID__c, date.newInstance(currentYear,10,1),'125'));
        mySalesList.add(TestFactory.getSalesMySaleswithID(19.43, parentBanner.Id, outletAccount.Outlet_ID__c, product2.Product_ID__c, date.newInstance(currentYear,11,1),'126'));
        mySalesList.add(TestFactory.getSalesMySaleswithID(2.56, parentBanner.Id, outletAccount.Outlet_ID__c, product3.Product_ID__c, date.newInstance(currentYear,12,1),'127'));
        mySalesList.add(TestFactory.getSalesMySaleswithID(32.56, parentBanner.Id, outletAccount.Outlet_ID__c, product3.Product_ID__c, date.newInstance(currentYear,12,25),'128'));
        
        insert mySalesList;    

		Test.startTest();  

        database.executebatch(new CalculateSumOfNineLe());
        
        Test.stopTest();
        
        Account acc = [select Volume__c
                       from Account
                       where Id =: outletAccount.Id];
                       
        System.assertNotEquals(acc.Volume__c,outletAccount.Volume__c);               
        
        
    }
}