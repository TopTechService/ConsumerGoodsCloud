({
    doInit: function(component, event, helper) {
        helper.getEventsCount(component, event, helper);
        helper.loadEvents(component, 'today', helper);
    },

    todayButtonClickHandler: function(component, event, helper) {
        helper.loadEvents(component, 'today', helper);
        component.set('v.periodLabel', 'Today');
    },

    tomorrowButtonClickHandler: function(component, event, helper) {
        helper.loadEvents(component, 'tomorrow', helper);
        component.set('v.periodLabel', 'Tomorrow');
    },

    weekButtonClickHandler: function(component, event, helper) {
        helper.loadEvents(component, 'week', helper);
        component.set('v.periodLabel', 'Next 7 Days');
    },

    monthButtonClickHandler: function(component, event, helper) {
        helper.loadEvents(component, 'month', helper);
        component.set('v.periodLabel', 'This Month');
    },

    navigateTo: function(component, event, helper) {
        let target = event.target;
        while (!target.getAttribute('data-id')) {
            target = target.parentNode
        }

        let navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            recordId: target.getAttribute('data-id')
        });
        navEvt.fire();
    }
})