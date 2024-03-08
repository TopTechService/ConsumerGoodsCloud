/**
 * Created by eugene on 03.10.19.
 */
({
    doInit : function (component, event, helper) {
        let action = component.get("c.getSalesOrderRecordTypes");
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.recordTypes', response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    changeRecordType : function (component, event, helper) {
        let selectedValue = component.find("selectType").get("v.value");
        let selectedLabel = component.find("selectType").get("v.label");
        component.set("v.selectedRecordTypeId", selectedValue);
        if(selectedValue === '-1'){
            component.set("v.disabledBtn",true);
        }else{
            component.set("v.disabledBtn",false);
        }
    },
    createSalesOrder : function (component, event, helper) {
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "Sales_Order__c",
            "recordTypeId" : component.get("v.selectedRecordTypeId")
        });
        createRecordEvent.fire();
    }
});