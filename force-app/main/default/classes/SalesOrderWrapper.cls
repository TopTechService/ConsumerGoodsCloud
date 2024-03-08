public with sharing class SalesOrderWrapper {
  
   
   public Sales_Order_Product__c product{set;get;}
   public Sales_Order_Product__c product2{set;get;}
   public Product__c prdct{set;get;}
   public Date startDate{set;get;}
   public Date endDate{set;get;}
   public string remainingDiscount{set;get;}
   public decimal price{set;get;}
   public decimal maxDiscount{set;get;}
   public string wholeSalerGroupProduct{set;get;}
   public String promoStartDate {get;set;}
   public String promoEndDate {get;set;}
   
   public decimal promotionDiscount{set;get;} 
  
  public SalesOrderWrapper(){
  	
  	
  }
}