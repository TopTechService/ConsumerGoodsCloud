@isTest
public class OutletWithoutAccountFinderBatchTest {
    static testMethod void testBatch(){
        
        region__c region =  TestFactory.getRegion('VIC', '3');
		insert region;  
        
        State__c state = TestFactory.getState('3');
        state.State_ID__c = '3';
        insert state;
        
        Outlet_Type__c outletType = new Outlet_Type__c();
        outletType.Name = '45723';
        outletType.Type_ExtId__c = '45723';
        insert outletType;
        
        Outlet_Sub_Type__c outletSubtype = TestFactory.createOutletSubType('45723');
        insert outletSubtype; 
        
        Outlet_Category__c outletCategory = TestFactory.createOutletCategory('45723');
        outletCategory.Outlet_Category_Id__c = '45723';
        insert outletCategory; 
        
        outlet__c outlet = TestFactory.createOutlet('3' ,'45723');
        insert outlet;
        
        test.startTest();
            OutletWithoutAccountFinderBatch batch = new OutletWithoutAccountFinderBatch();
            database.executeBatch(batch,200);
        test.stopTest();
    }
    
   
    
 }