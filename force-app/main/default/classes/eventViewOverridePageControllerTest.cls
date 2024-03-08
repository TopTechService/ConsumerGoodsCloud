@isTest
public class eventViewOverridePageControllerTest{
  public static testMethod void testgetTaskz(){     
      
        Account a= new Account ();
        a.name='Test Account';
        insert a;
        
        Event e = new Event();
        e.WhatId=a.id;
        e.Subject='test';
        e.StartDateTime=system.today();
        e.EndDateTime=system.today()+5;
      	e.Type_of_Call__c = 'Outlet Visit';
        insert e;
      
      Test.startTest();
      Test.setCurrentPage(Page.eventViewOverridePage);      
      ApexPages.StandardController stdController = new ApexPages.StandardController(e);    
      eventViewOverridePage_Controller obj = new eventViewOverridePage_Controller(stdController);   
      obj.getTaskz();
      Test.stopTest();
  }
}