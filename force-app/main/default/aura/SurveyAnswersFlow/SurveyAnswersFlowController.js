/**
 * Created by eugene on 20.09.19.
 */
({
    click1: function (component, event, helper) {
        let clickedButton = component.get("v.question").Id + '1';
        let value = document.getElementById(clickedButton).value;
        helper.update(component, component.get("v.question").Id, value);

    },

    click2: function (component, event, helper) {
        let clickedButton = component.get("v.question").Id + '2';
        let value = document.getElementById(clickedButton).value;
        helper.update(component, component.get("v.question").Id, value);
    },

    click3: function (component, event, helper) {
        let clickedButton = component.get("v.question").Id + '3';
        let value = document.getElementById(clickedButton).value;
        helper.update(component, component.get("v.question").Id, value);
    },

    click4: function (component, event, helper) {
        let clickedButton = component.get("v.question").Id + '4';
        let value = document.getElementById(clickedButton).value;
        helper.update(component, component.get("v.question").Id, value);
    },

    click5: function (component, event, helper) {
        let clickedButton = component.get("v.question").Id + '5';
        let value = document.getElementById(clickedButton).value;
        helper.update(component, component.get("v.question").Id, value);
    },

    change: function (component, event, helper) {
        let action =  event.getSource().get("v.label");
        let answer;
        if(action === 'Yes'){
            answer = true;
        }else {
            answer = false
        }
        helper.update(component, component.get("v.question").Id, answer);
    }

});