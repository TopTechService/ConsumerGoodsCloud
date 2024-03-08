/* Author : Eugene @ Carnac Group

* Created : 20/09/2019

* Description:

* getSurveyAnswers  :  Gets survey answers for the current event

* updateSurveyAnswer : Updates the answer field in the survey answer object when it was changed

*/

public with sharing class SurveyAnserwsFlowController {
	/*@AuraEnabled
    public static List<Survey_Answer__c> getSurveyAnswers(ID EventId){
        return [SELECT id, Name, Question_Type__c, Question__c, Answer__c, Question_order__c from Survey_Answer__c WHERE EventID__c =: EventId];
    }

    @AuraEnabled
    public static void updateSurveyAnswer(ID SurveyID, String Answer){
        Survey_Answer__c ans = [SELECT id, Name, Answer__c FROM Survey_Answer__c WHERE id =: SurveyID];
        ans.Answer__c = Answer;
        update ans;
    }*/
}