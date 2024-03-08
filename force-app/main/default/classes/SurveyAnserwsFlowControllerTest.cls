/* Author : Eugene @ Carnac Group

* Created : 23/09/2019

* Description:

* setup  :  Сreates test data

* copySurveySetupTroggerTest : Сreates events and tests the trigger

* getSurveyAnswersTest : Tests controller method returning Survey Answers

* updateSurveyAnswer : Tests controller method updating survey answer record

*/


@isTest
public with sharing class SurveyAnserwsFlowControllerTest {
    /*
    @testSetup
    static void setup() {
        Call_Cycle__c cycle = new Call_Cycle__c(Name = 'Call Cycle 6 - 2019', Call_Cycle__c = 'Call Cycle 1', Year__c = '2019', Location__c = 'Australia', Start_Date__c = date.parse('19/08/2019') , End_Date__c = date.parse('27/09/2019'));
        Call_Cycle__c cycle1 = new Call_Cycle__c(Name = 'Call Cycle 7 - 2019', Call_Cycle__c = 'Call Cycle 2', Year__c = '2019', Location__c = 'Australia', Start_Date__c = date.parse('30/09/2019') , End_Date__c = date.parse('04/10/2019'));
        insert cycle;
        insert cycle1;
        List<Survey_Setup__c> forInsert = new List<Survey_Setup__c>();
        for(Integer i=0; i<2; i++){
            Survey_Setup__c survey = new Survey_Setup__c(Call_Cycle__c = cycle.id, Question__c = 'question 1-5 O '+i, Question_Type__c = 'Picklist - 1 to 5', Status__c = 'Open');
            Survey_Setup__c survey1 = new Survey_Setup__c(Call_Cycle__c = cycle.id, Question__c = 'question R O '+i, Question_Type__c = 'Radio - Yes or No', Status__c = 'Open');
            Survey_Setup__c survey2 = new Survey_Setup__c(Call_Cycle__c = cycle.id, Question__c = 'question R C '+i, Question_Type__c = 'Radio - Yes or No', Status__c = 'Closed');
            Survey_Setup__c survey3 = new Survey_Setup__c(Call_Cycle__c = cycle.id, Question__c = 'question 1-5 C '+i, Question_Type__c = 'Picklist - 1 to 5', Status__c = 'Closed');
            Survey_Setup__c survey4 = new Survey_Setup__c(Call_Cycle__c = cycle1.id, Question__c = 'questionForCC2 1-5 O '+i, Question_Type__c = 'Picklist - 1 to 5', Status__c = 'Open',Applicable_Channels__c = 'Off-Premise');
            Survey_Setup__c survey5 = new Survey_Setup__c(Call_Cycle__c = cycle1.id, Question__c = 'questionForCC2 R O '+i, Question_Type__c = 'Radio - Yes or No', Status__c = 'Open', Applicable_Channels__c = 'On-Premise');
            Survey_Setup__c survey6 = new Survey_Setup__c(Call_Cycle__c = cycle1.id, Question__c = 'questionForCC2 1-5 C '+i, Question_Type__c = 'Picklist - 1 to 5', Status__c = 'Closed');
            Survey_Setup__c survey7 = new Survey_Setup__c(Call_Cycle__c = cycle1.id, Question__c = 'questionForCC2 R C '+i, Question_Type__c = 'Radio - Yes or No', Status__c = 'Closed');
            Survey_Setup__c survey8 = new Survey_Setup__c(Call_Cycle__c = cycle1.id, Question__c = 'questionForCC2 1-5 C '+i, Question_Type__c = 'Picklist - 1 to 5', Status__c = 'Closed',Applicable_Channels__c = 'On-Premise');
            Survey_Setup__c survey9 = new Survey_Setup__c(Call_Cycle__c = cycle1.id, Question__c = 'questionForCC2 R C '+i, Question_Type__c = 'Radio - Yes or No', Status__c = 'Closed',Applicable_Channels__c = 'Off-Premise');
			Survey_Setup__c survey10 = new Survey_Setup__c(Call_Cycle__c = cycle1.id, Question__c = 'questionForCC2 R C '+i, Question_Type__c = 'Radio - Yes or No', Status__c = 'Open',Applicable_Channels__c = 'On-Premise & Hybrid');
            Survey_Setup__c survey11 = new Survey_Setup__c(Call_Cycle__c = cycle1.id, Question__c = 'questionForCC2 R C '+i, Question_Type__c = 'Radio - Yes or No', Status__c = 'Open',Applicable_Channels__c = 'Off-Premise & Hybrid');

            forInsert.add(survey);
            forInsert.add(survey1);
            forInsert.add(survey2);
            forInsert.add(survey3);
            forInsert.add(survey4);
            forInsert.add(survey5);
            forInsert.add(survey6);
            forInsert.add(survey7);
            
            forInsert.add(survey8);
            forInsert.add(survey9);
            forInsert.add(survey10);
            forInsert.add(survey11);
       
        }
        insert forInsert;
        List<Survey_Setup__c> setups = [SELECT id, Name, Call_Cycle__c, Question__c, Question_Type__c, Status__c FROM Survey_Setup__c];

    }

    @isTest
    static void copySurveySetupTroggerTest(){
        List<Call_Cycle__c> cycles = [SELECT id, name FROM Call_Cycle__c];
        List<Event> events = new List<Event>();
     test.startTest();
        // All channel Account
        Account a = new Account ();
        a.name='Test Account all';
        a.Outlet_ID__c = '123';
        a.account_Type__c = 'National';
        a.Channel__c = 'Off-Premise';
        a.On_Premise_Segmentation__c = 'Specialty';
        a.recordTypeId = Utilities.getRecordTypeId('Account','Outlet');
        insert a;
 
        for(Integer i =0; i< cycles.size(); i++){
            for(Integer j =0; j<2; j++) {
                Event e = new Event();
                e.WhatId = a.id;
                e.Subject = 'test' + i + '' + j;
                e.Call_Cycle_Id__c = cycles[i].id;
                e.StartDateTime = system.today()+i;
                e.EndDateTime = system.today() + 5+i;
                e.Type_of_Call__c = 'Outlet Visit';
                e.IsUnplanned__c =false;
                events.add(e);
            }
        }
        
         

        insert events;
        List<Event> lst = [SELECT id FROM Event WHERE Call_Cycle_Id__c =: cycles[1].id];
        List<Survey_Answer__c> answers = [SELECT id, Name FROM Survey_Answer__c WHERE EventID__c =: lst[0].id];
        System.assertEquals(4, answers.size());
        System.assertNotEquals(0, answers.size());
        
        lst[1].StartDateTime = date.parse('19/08/2019');
        update lst[1];
        
        
        try{
        lst[1].StartDateTime = date.parse('30/08/2019');
        update lst[1];
            
            }
        catch(Exception e){
            System.Assert(e.getMessage().contains('New Due Date does not belong to call cycle for which this task had been defined.: [ActivityDate]'));
        }
         test.stopTest();
    }

    
    
    @isTest
    static void getSurveyAnswersTest(){
        List<Call_Cycle__c> cycles = [SELECT id, name FROM Call_Cycle__c];
        List<Event> events = new List<Event>();

        Account a = new Account ();
        a.name='Test Account';
        a.Channel__c = 'On-Premise';
        a.account_Type__c = 'National';
        a.On_Premise_Segmentation__c = 'Local Pub';
        a.recordTypeId = Utilities.getRecordTypeId('Account','Outlet');
        insert a;
        for(Integer i =0; i< cycles.size(); i++){
            for(Integer j =0; j<2; j++) {
                Event e = new Event();
                e.WhatId = a.id;
                e.Subject = 'test' + i + '' + j;
                e.Call_Cycle_Id__c = cycles[i].id;
                e.StartDateTime = system.today();
                e.EndDateTime = system.today() + 5;
                e.Type_of_Call__c = 'Outlet Visit';
                events.add(e);
            }
        }

        insert events;
        List<Event> lst = [SELECT id FROM Event WHERE Call_Cycle_Id__c =: cycles[1].id];
        Test.StartTest();
        List<Survey_Answer__c> answers = SurveyAnserwsFlowController.getSurveyAnswers(lst[0].id);
        Test.StopTest();
        System.assertNotEquals(null, answers);
    }

    @isTest
    static void updateSurveyAnswer(){
        List<Call_Cycle__c> cycles = [SELECT id, name FROM Call_Cycle__c];
        List<Event> events = new List<Event>();

        Account a = new Account ();
        a.name='Test Account';
        a.Channel__c = 'On-Premise';
        a.account_Type__c = 'National';
        a.On_Premise_Segmentation__c = 'Local Pub';
        a.recordTypeId = Utilities.getRecordTypeId('Account','Outlet');
        insert a;
        for(Integer i =0; i< cycles.size(); i++){
            for(Integer j =0; j<2; j++) {
                Event e = new Event();
                e.WhatId = a.id;
                e.Subject = 'test' + i + '' + j;
                e.Call_Cycle_Id__c = cycles[i].id;
                e.StartDateTime = system.today();
                e.EndDateTime = system.today() + 5;
                e.Type_of_Call__c = 'Outlet Visit';
                events.add(e);
            }
        }

        insert events;
        List<Survey_Answer__c> answers = [SELECT id, Name, Question_Type__c, Question__c, Answer__c from Survey_Answer__c];
        Survey_Answer__c before = answers[0];
        Test.StartTest();
        SurveyAnserwsFlowController.updateSurveyAnswer(answers[0].id, '1');
        Test.StopTest();
        Survey_Answer__c after = [SELECT id, Name, Question_Type__c, Question__c, Answer__c from Survey_Answer__c WHERE id =: answers[0].id];
        System.assertEquals(before.Answer__c, null);
        System.assertEquals(after.Answer__c, '1');
        System.assertNotEquals(after.Answer__c, before.Answer__c);
    }*/
}