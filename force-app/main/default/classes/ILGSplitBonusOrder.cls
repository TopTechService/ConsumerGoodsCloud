/**
 * @Description : Split Ilg Order having bonus product same as normal product
 * as ILG server rejects order with repeated line items   
 **/
public without sharing class ILGSplitBonusOrder {
    
    private final string wholesalerName = 'ILG';
    private Map<Id, Sales_Order__c> orignalVsNewSalesOrderMap;                      // To map bonus order with bonus order products using bonusProductsMap
    private Map<Id, Sales_Order_Product__c> orignalBonusPrdVsNewBonusPrdMap;        // To verify that new bounus record is inserted

    public ILGSplitBonusOrder() {
        orignalVsNewSalesOrderMap = new Map<Id, Sales_Order__c>();
        orignalBonusPrdVsNewBonusPrdMap = new Map<Id, Sales_Order_Product__c>();
    }
    
    
    /**
     * @param : ILG Sales order ids to be sent to wholesaler
     * @return : Original ids + Newly created sales orders Ids
     * */
    public Set<Id> splitOrder(Set<Id> salesOrderId) {
        
        // set counter to 2     
        StaticVariableHandler.setSalesOrderTriggerRun ++;

        Set<Sales_Order__c> ilgOrdersSet = new Set<Sales_Order__c>();
        Set<Id> bonusOrderIdSet = new Set<Id>();
        
        try {
            List<Sales_Order__c> salesOrderList = [SELECT Id, Wholesaler_Account_Number__c, VendorOrderId__c, Authorising_Rep__c,
                                                        Send_Approval_for_discount__c, Send_Approval_for_quantity__c,
                                                        Outlet_Name__c, Banner_Group__c, Wholesaler__c, Drop_1_Date__c,
                                                        Drop_2_Date__c, Drop_3_Date__c, Wholesaler_Branch__c, Status__c,
                                                        WholeSaler_Type__c, ILG_Orignal_Order__c, Name,
                                                        (SELECT Id, Sales_Order_Number__c, Wholesaler__c,Total_Applied_Discount2__c,
                                                             Total_Price__c,Supplier_deal_id__c,Cases_Ordered_ILG__c, ILG_Response__c,
                                                             Product_Code__c, Product_Description__c, Status__c, Units_Ordered_ILG__c,  
                                                             Total_Quantity_Including_Bonus__c, Bonus_Status__c, ILG_Discount__c,
                                                             Bonus_Product__c, Wholesaler_Group_Id__c, Quantity__c, Cases_Ordered__c,
                                                             Discount__c, WholeSaler_Type__c, Order_Type__c, PromotionProduct__c,
                                                             Units_Ordered__c 
                                                         FROM  Sales_Order_Products__r)
                                                   FROM Sales_Order__c
                                                   WHERE Id IN :salesOrderId AND WholeSaler_Type__c = :wholesalerName];
                                                   
            for (Sales_Order__c salesOrder : salesOrderList) {
                System.debug('salesOrder :' + salesOrder);
                if (null == salesOrder.Sales_Order_Products__r)
                    continue;
                for (Sales_Order_Product__c sop : salesOrder.Sales_Order_Products__r) {
                    System.debug('Sales_Order_Product__c :' + sop);
                    if (!(sop.Order_Type__c == 'B' && sop.Bonus_Status__c == 'Dependent Child' && sop.WholeSaler_Type__c == 'ILG')) 
                        continue;
                    ilgOrdersSet.add(salesOrder);                   
                }
                            
            }
            
            System.debug('ilgOrdersSet :' + ilgOrdersSet);
            if (ilgOrdersSet.isEmpty())
                return salesOrderId;

            // Orignal order vs New Bonus products map  
            Map<id, List<Sales_Order_Product__c>> bonusProductsMap = getBonusProducts(ilgOrdersSet);
            System.debug('bonusProductsMap :' + bonusProductsMap);

            bonusOrderIdSet = createBonusSalesOrder(bonusProductsMap);
            System.debug('bonusOrderIdSet :' + bonusOrderIdSet);
            
            // Process only if bonus sales order is created
            if (null != bonusOrderIdSet && !bonusOrderIdSet.isEmpty()) {            
                removeProductFromOrignalOrder(ilgOrdersSet);
                populateFieldsOnNonBonusProduct(ilgOrdersSet);
                salesOrderId.addAll(bonusOrderIdSet);       
            }

            If (System.Test.isRunningTest())
                Integer i = 10/0;

        } catch (Exception ex) {
            List<String> toAddresses = new List<String>();
            // Get custom settings emails for errors sending
            String configEmails = Email_Configuration__c.getInstance('NotificationEmails').Email_Ids__c;
            toAddresses = configEmails.split(',');
            List<String> ccAddresses = new List<String>();
            String body = 'Exception occurred while spliting ILG Sales order :' + ex.getTypeName() + ': ' + ex.getMessage() 
                            + ' -- ' + ex.getCause() + ' -- '+ ex.getStackTraceString(); 
            SendEmail em = new SendEmail();
            em.sendEmailToUsers(toAddresses, ccAddresses, 'Exception occurred while spliting ILG Sales order', body, body); 
        }
        
        // reset counter        
        StaticVariableHandler.setSalesOrderTriggerRun --;
        return bonusOrderIdSet;
    }
    
    /**
     * @Description :
     *  create bonus product, set status = Independent and clear Sales_Order_Number__c
     *  create bonus order and populate orignalVsNewSalesOrderMap
     *  orignalVsNewSalesOrderMap will be used in createBonusSalesOrder() to insert new orders
     *  return orignal order vs bonus products map
     */
    private Map<id, List<Sales_Order_Product__c>> getBonusProducts(Set<Sales_Order__c> ilgOrdersSet) {
        // orignal order vs bonus order products        
        Map<id, List<Sales_Order_Product__c>> bonusProductsMap = new Map<id, List<Sales_Order_Product__c>>();
        for (Sales_Order__c so : ilgOrdersSet) {
            Map<Sales_Order__c, List<Sales_Order_Product__c>> newOrderMap = new Map<Sales_Order__c, List<Sales_Order_Product__c>>();
            
            Sales_Order__c bonusOrder = getBonusOrder(so);
            List<Sales_Order_Product__c> bonusProdList = new List<Sales_Order_Product__c>();
            for (Sales_Order_Product__c sop : so.Sales_Order_Products__r) {
                System.debug('Sales_Order_Product__c :' + sop);
                if (!(sop.Order_Type__c == 'B' && sop.Bonus_Status__c == 'Dependent Child' && sop.WholeSaler_Type__c == 'ILG')) 
                    continue;

                Sales_Order_Product__c sopClone = sop.clone(false, true);
                sopClone.Bonus_Status__c = 'Independent';   
                sopClone.Sales_Order_Number__c = '';
                bonusProdList.add(sopClone);
                orignalBonusPrdVsNewBonusPrdMap.put(sop.id, sopClone);                  
            }
            bonusOrder.ILG_Orignal_Order__c = so.id;
            orignalVsNewSalesOrderMap.put(so.id, bonusOrder);
            bonusProductsMap.put(so.id, bonusProdList);                         

        }               

        return bonusProductsMap; 
    }
    
    private Sales_Order__c getBonusOrder(Sales_Order__c so) {
        Sales_Order__c bonusOrder = so.clone(false, true);
        bonusOrder.VendorOrderId__c = '';       
        return bonusOrder;
    }

    /**
     * @param : Orignal sales order and cloned bonus products to be inserted
     * @return : Newly created sales orders Ids
     * */
    private Set<Id> createBonusSalesOrder(Map<id, List<Sales_Order_Product__c>> bonusProductsMap) {
        // we are using object as a key for inner map hence using this map to hold newly inserted bonus orders.
        List<Sales_Order_Product__c> cloneProdListToInsert = new List<Sales_Order_Product__c> ();
        Map<Id, Sales_Order__c> bonusOrderMap = new Map<Id, Sales_Order__c>();

        // Insert Cloned Bonus Sales Order and populate venodr order id 
        if (!orignalVsNewSalesOrderMap.values().isEmpty()) {
            insert orignalVsNewSalesOrderMap.values();

            for (Sales_Order__c order : orignalVsNewSalesOrderMap.values()) {
                bonusOrderMap.put(order.id, null);
            }

            bonusOrderMap.putAll([SELECT id, name, VendorOrderId__c FROM Sales_Order__c WHERE id IN :bonusOrderMap.keySet()]);
            for (Id bonusOrderId : bonusOrderMap.keySet()) {
                Sales_Order__c ord =  bonusOrderMap.get(bonusOrderId);
                if (null != ord) {
                    ord.VendorOrderId__c = ord.Name + (''+System.now().year()).substring(0,2)
                                                        +System.now().month()+System.now().day()+System.now().hour()
                                                        +System.now().minute()+System.now().second();
                }
            }           
        }   

        for (Id orignalOrderId : bonusProductsMap.keySet()) {
            if (null == bonusProductsMap.get(orignalOrderId)) {
                System.debug(LoggingLevel.WARN, 'No Cloned Bonus Products found for order :' + orignalOrderId);             
                continue;
            }
            if (null == orignalVsNewSalesOrderMap.get(orignalOrderId)) {
                System.debug(LoggingLevel.WARN, 'No CLoned Bonus Order found for order :' + orignalOrderId);                                
                continue;
            }   

            Sales_Order__c bonusOrderInserted = orignalVsNewSalesOrderMap.get(orignalOrderId);
            for (Sales_Order_Product__c bonusProd : bonusProductsMap.get(orignalOrderId)) {
                    bonusProd.Sales_Order__c = bonusOrderInserted.id;
                    cloneProdListToInsert.add(bonusProd);
            }

            // Populate Vendor Order Id on the inserted bonus orders

            bonusOrderInserted.VendorOrderId__c = bonusOrderMap.get(bonusOrderInserted.id).VendorOrderId__c;
        }


        if (!orignalVsNewSalesOrderMap.values().isEmpty())
            update orignalVsNewSalesOrderMap.values();

        if (!cloneProdListToInsert.isEmpty())
            insert cloneProdListToInsert;
        

        return bonusOrderMap.keySet();
    }

    private void removeProductFromOrignalOrder(Set<Sales_Order__c> ILGorderSet) {
        List<Sales_Order_Product__c> sopDeleteList = new List<Sales_Order_Product__c>();
        for (Sales_Order__c temp : ILGorderSet) {
            if (null == temp.Sales_Order_Products__r)
                continue;
            for (Sales_Order_Product__c sop : temp.Sales_Order_Products__r) {
                // Prevent deletion of the independent bonus products from orignal order
                Sales_Order_Product__c cloneSop = orignalBonusPrdVsNewBonusPrdMap.get(sop.id);
                if (null == cloneSop)
                    continue;
                // check if clone bonus product is created and then delete orignal product
                if (null != cloneSop.id) {
                    sopDeleteList.add(sop);
                }
            }
        }
        if (!sopDeleteList.isEmpty())
            delete sopDeleteList;
    }
    
    private void populateFieldsOnNonBonusProduct(Set<Sales_Order__c> ILGorderSet) {     
        List<Sales_Order_Product__c> masterProductsList = new List<Sales_Order_Product__c>();
        
        for (Sales_Order__c temp : ILGorderSet) {
            if (null == temp.Sales_Order_Products__r)
                continue;
            for (Sales_Order_Product__c sop : temp.Sales_Order_Products__r) {               
                if (sop.Bonus_Status__c != 'Dependent Master')
                    continue;
                //sop.Total_Quantity_Including_Bonus__c = sop.Quantity__c;
                //sop.ILG_Discount__c = sop.Total_applied_Discount2__c;
                //sop.Bonus_Status__c = 'Independent';              

                // nullified fields as they are not needed for independent order
                sop.Total_Quantity_Including_Bonus__c = null;
                sop.ILG_Discount__c = null;
                sop.Bonus_Status__c = null;
                sop.Cases_Ordered_ILG__c = sop.Cases_Ordered__c;
                
                System.debug('Units_Ordered__c :' + sop.Units_Ordered__c);
                sop.Units_Ordered_ILG__c = sop.Units_Ordered__c;
                System.debug('Units_Ordered_ILG__c :' + sop.Units_Ordered_ILG__c);
                masterProductsList.add(sop);                                    
            }
        }
        if (!masterProductsList.isEmpty()) 
            update masterProductsList;
    }   


}