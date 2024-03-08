@isTest
public class TestSetParentsOnSaleMySales {
	
	public id accrecordTypeId;
	
	public Account acc ;
	public Account childAcc;
	public Product__c product;
	public Wholesaler_Branch__c wholesaler;
	public Sale_MySales__c salesMySales ;
	public Brand__c brand ;
	public id wholesalerRecordType;
	public void parentOnMySales (){
		
		brand = TestFactory.getBrand('Brand 5', '125698');
		brand.Name = 'Brand 5';
		insert brand;
		
		accrecordTypeId = Utilities.getRecordTypeId('Account','Banner Group');
		
		acc = TestFactory.getAccount('TestParent', accrecordTypeId);
		acc.My_Sales_Id__c = '12365';
		acc.Outlet_ID__c = '2365836';
		insert acc;
		
		
		wholesalerRecordType = Utilities.getRecordTypeId('Account','Wholesaler');
		childAcc = TestFactory.getAccount('Testchild', wholesalerRecordType);
		childAcc.My_Sales_Id__c = '2365890';
		childAcc.ParentId = acc.id;
		childAcc.Outlet_ID__c = '23658904';
		childAcc.Banner_Group__c = acc.id;
		childAcc.Wholesaler_ID__c = 'wholesaer980';
		
		insert childAcc;
		
		
		product = TestFactory.createProduct('Brand 5');
		product.Product_ID__c = 'Pid123';
		insert product;
		
		system.debug('---------childAcc--------'+childAcc.id);
		
		wholesaler = new Wholesaler_Branch__c();
		wholesaler.Wholesaler_ID__c = 'wholesaer980';
		wholesaler.Wholesaler_Branch_Id__c = 'whole125698745';
		wholesaler.Wholesaler_Account__c = childAcc.id;
		wholesaler.Wholesaler_Branch_Name__c = 'whole125698745';
		insert wholesaler;
		
		salesMySales = new Sale_MySales__c();
		salesMySales.ProductID__c 	= 'Pid123';
		salesMySales.Name			= 'TestSales'; 
		salesMySales.OutletID__c    = '23658904';
		salesMySales.Sale_Date__c	= system.today();
		salesMySales.Region_Id__c = '1256';
		salesMySales.Nine_LE__c = 2;
        salesMySales.Sale_ExtId__c = '123';
		
		salesMySales.Wholesaler_Branch_ID__c = 'whole125698745';
		
		insert salesMySales;
		
		delete salesMySales;
		
		
	}
	
	
    static testMethod void myUnitTest() {
    	test.startTest();
	  	TestSetParentsOnSaleMySales parentOnSales = new TestSetParentsOnSaleMySales();
	  	parentOnSales.parentOnMySales();
	  	test.stopTest();
        
    }
}