/**
 * Created by eugene on 20.09.19.
 */
({
    doInit: function (component, event, helper) {
        let action = component.get('c.getSurveyAnswers');

        action.setParams({
            EventId: component.get('v.recordId')
        });

        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                let resut = response.getReturnValue();
                resut.sort((a,b) => b.Question_order__c > a.Question_order__c ? -1 : b.Question_order__c === a.Question_order__c ? 0 : 1);
                console.log(resut);
                component.set('v.surveyAnswers', resut);
                if(response.getReturnValue().length > 0){
                    component.set("v.footer", '');
                }else {
                    component.set("v.footer", 'There are no questions on this event');
                }
            }
        });

        $A.enqueueAction(action);
    }
});