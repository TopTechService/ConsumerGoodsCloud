/**
 * @author    : Created by Geeta Kushwaha on 3 June, 2013  geeta.kushwaha@arxxus.com
 * @Purpose   : Test Class
 * @Criteria  : This is test class for EmailTempates
 * @Modified  : Modified by Geeta Kushwaha on 3 June, 2013  geeta.kushwaha@arxxus.com
 */
@isTest 
public with sharing class EmailTemplatesTest {
    
    static testMethod void submitPlanToManagerTest() {
        
        EmailTemplates et = new EmailTemplates();

        list<String> body = et.submitPlanToManager('managerName','testUser', 'Call Cycle 2', '2013', 'Outlet 1', URL.getSalesforceBaseUrl().toExternalForm(),'请访问', 'January',null);
        
        System.assertEquals(body.size(), 2);
        
        list<String> body0 = et.submitPlanToManager('managerName','testUser', 'Call Cycle 2', '2013', 'Outlet 1', URL.getSalesforceBaseUrl().toExternalForm(),'请访问', null,null);
        
        System.assertEquals(body0.size(), 2);
        
        
        list<String> body1 = et.submitPlanToManager('managerName','testUser', 'Call Cycle 2', '2013', 'Outlet 1', URL.getSalesforceBaseUrl().toExternalForm()+'?scc=2013','请访问', 'January','objective ');
        
        System.assertEquals(body1.size(), 2);
        
        
        list<String> body2 = et.submitPlanToManagerForObjctiveMngmt('managerName','testUser',  '2013', 'Outlet 1', URL.getSalesforceBaseUrl().toExternalForm(),'请访问', 'January',null,'All');
        
        System.assertEquals(body2.size(), 2);
        
        list<String> body3 = et.submitPlanToManagerForObjctiveMngmt('managerName','testUser',  '2013', 'Outlet 1', URL.getSalesforceBaseUrl().toExternalForm()+'?scc=2013','请访问', 'January','objective ','All');
        
        System.assertEquals(body3.size(), 2);


        list<String> body4 = et.submitPlanToManagerForObjctiveMngmt('managerName','testUser',  '2013', 'Outlet 1', URL.getSalesforceBaseUrl().toExternalForm()+'?scc=2013','请访问', null,'objective ','All');
        
        System.assertEquals(body4.size(), 2);        
    }

}