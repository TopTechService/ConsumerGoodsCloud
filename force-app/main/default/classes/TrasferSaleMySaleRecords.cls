global class TrasferSaleMySaleRecords implements Database.Batchable<sObject>{
   global integer year;
   global String queryString = 'select id, Name, Banner_Group__c, Carton_Count__c, Discount_Value__c, Invoice_Value__c, Nine_LE__c, Outlet__c, OutletID__c, '+
                               'Product__c, ProductID__c, Region_Id__c, Sale_Date__c, Wholesaler_Branch__c, Wholesaler_Branch_ID__c, OwnerId '+
                               'From Sale_MySales__c where Year__c =:year ';

   global TrasferSaleMySaleRecords(integer year){
      this.year = year;
      
   }

   global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(queryString);
     
   }

   global void execute(Database.BatchableContext BC, List<sObject> mySalesRecords){
     list <Sale_MySales_Historical__c> historicalList = new list<Sale_MySales_Historical__c>();
     for(sobject rec : mySalesRecords){
        Sale_MySales__c s = new Sale_MySales__c();
        s = (Sale_MySales__c)rec; 
     	historicalList.add(new Sale_MySales_Historical__c(Name = s.Name,
            										     X9LE__c = s.Nine_LE__c,
                                                         Banner_Group__c = s.Banner_Group__c,
                                                         Carton_Count__c = s.Carton_Count__c,
                                                         Discount_Value__c = s.Discount_Value__c,
                                                         Net_Sales__c = s.Invoice_Value__c,
                                                         Outlet__c = s.Outlet__c,
                                                         OutletID__c = s.OutletID__c,
                                                         Product__c = s.Product__c,
                                                         ProductID__c = s.ProductID__c,
                                                         Region_Id_Text__c = s.Region_Id__c,
                                                         Sale_Date__c = s.Sale_Date__c,
                                                         Wholesaler_Branch__c = s.Wholesaler_Branch__c,
                                                         Wholesaler_Branch_ID__c = s.Wholesaler_Branch_ID__c));
     }
       
     insert historicalList;
       
     delete mySalesRecords;
       
    }

   global void finish(Database.BatchableContext BC){
   }
}