({
    getEventsCount: function(component, event, helper) {
        let action = component.get('c.getEventsCount');

        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
               component.set('v.eventsCountData', response.getReturnValue());

               component.set('v.showSpinner', false);
            }
        });

        $A.enqueueAction(action);
    },

    loadEvents: function(component, mode, helper) {
        component.set('v.showSpinner', true);

        let action = component.get('c.getEvents');

        action.setParams({
            mode: mode
        });

        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                component.set('v.events', response.getReturnValue());

                let recalculateFunction = helper.recalculateMaxHeight;
                setTimeout($A.getCallback(function() {
                    recalculateFunction();
                }), 100);
            }

            component.set('v.showSpinner', false);
        });

        $A.enqueueAction(action);
    },

    recalculateMaxHeight: function(component, event, helper) {
        let container = document.querySelector('.items-container');
        let maxHeight = 0;

        let count = 0;
        Array.from(container.children).map(function(item) {
            if (count >= 6)
                return;

            maxHeight += item.offsetHeight;
            count++;
        });

        if (maxHeight > 0) {
            maxHeight += 30;
            container.style.maxHeight = maxHeight + 'px';
        }
    }
})