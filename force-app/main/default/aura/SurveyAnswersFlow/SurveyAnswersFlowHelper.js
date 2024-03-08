/**
 * Created by eugene on 23.09.19.
 */
({
    update: function (component, questionId, answer) {
        let action = component.get('c.updateSurveyAnswer');

        action.setParams({
            SurveyID: questionId,
            Answer: answer
        });

        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                console.log('OK')
            }
        });

        $A.enqueueAction(action);
    }
})