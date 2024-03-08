/**
 * @author : Gunwant Patidar
 * @description : This is a helper class for trade loader page. creates list of products and prices associated with products
 * @created date: 29/5/2013
 */
public with sharing class TradeLoaderHelper {
	public string wholesalerGroupCode   {get;set;}
	public Product__c productsData		{get;set;}
	public Sales_Order_Product__c salesOrderProducts{get;set;}
	public Date promoStartDate			{get;set;}
	public Date promoEndDate			{get;set;}
	public Pricing__c productPrice		{get;set;}
	public Decimal productTotalAmount	{get;set;}
	public Decimal totalQuantity		{get;set;}
	public string needApproval			{get;set;}
	public boolean doApprovalRequired	{get;set;} 
	public String rowColor 				{get;set;}
	public Decimal drop1Amount			{get;set;}
	public Decimal drop2Amount			{get;set;}
	public Decimal drop3Amount			{get;set;}
	public Decimal promotionDiscount	{get;set;}
}