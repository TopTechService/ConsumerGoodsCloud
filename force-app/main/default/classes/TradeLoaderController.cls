/*
 @ Created By-:Sourav Nema
 @ Description-:This controller is used in SalesOrder Page that opens on click of "New Trade Loader Sales Order" button on account record.
 @ Last modified by : Gunwant Patidar
 @ modified: by Geeta Kushwaha on 28 OCt, 2013. Display Maxdiscount & applied discount. 
 			 by Geeta Kushwaha on 14 Feb, 2014. Display promotions applicable to parent banner group as well
 */

public with sharing class TradeLoaderController{
    public String drop1DateValidOrNot {get; set;}
    public Integer coloredRow{set;get;}
    public Sales_Order__c salesRecord           {set;get;}
    public Sales_Order__c salesRecord2          {set;get;}
    public Sales_Order__c salesRecord3          {set;get;}
    
    public string rewardName {get;set;}
    public list<TradeLoaderHelper> orderLineItemsToBeDisplayed {get;set;}
    public list<TradeLoaderHelper> orderLineItemsSelected {get;set;}
    public list<string> headerList{get;set;}
    public decimal grandTotal{get;set;}
    public decimal totalAmount{get;set;}
	public integer totalQuantityDrop1{get;set;}
	public integer totalQuantityDrop2{get;set;}
	public integer totalQuantityDrop3{get;set;}
	public boolean promotionExists{get;set;}
	public string promtionId{get;set;}
	public Boolean approvalFlag{get;set;}
	boolean inCludeNone =true;
	private set<string> promotionIdSet = new set<string>();
	private set<Id> productIdSet  = new set<Id>();
	public Integer totalQuantitySalesOrder {get;set;}
	
	public Promotion__c promotion = new Promotion__c();
    public list<Product__c> prdct{set;get;}
    public list<string> prmProduct{set;get;}
    public list<Decimal> price{set;get;}
    public list<string> wholeSalerGroupProduct{set;get;}
    public string acId{set;get;}
    
    private set<string> prdctList           = new set<string>();
    private set<string> wholeSalerList      = new set<string>();
    private boolean sendApproval  			= false;
    
    private Map<String,String> customerNumberMap = new Map<String,String>();
    private String customerNumberWBO;
    private list<Sales_Order_Product__c> bonusProductList = new list<Sales_Order_Product__c>();
    
    map<id,Product__c> prdctMap     =  new map<id,Product__c>([select Brand__r.name,Product_ID__c,Brand_ID__c,MLs_Per_Bottle__c,name,Bottles_Per_Carton__c from Product__c]);
    private set<string> wBranchList = new set<string>();
   
  	public list<PromotionProduct__c> promotionProdshow{set;get;}
  	
  	public boolean wholesalerNotExist{get;set;}
  	
  	public boolean hideRestItems{get;set;}
  	
  	public list<Promotion__c> selectedPromotion{get;set;}
  	public List<SelectOption> Items{get;set;}
  	
  	private date todaysDate;
  	
  	//private string showApprovalError = 'No';
    
  	//Create Wholesaler Picklist
   	String  waccId;
   	
	
	/**
	 * @author : Gunwant Patidar
	 * @description : this methods fetches all the promotions where start date is less than sales order creation date and end date
	 					greater than sales order creation date
	 					
	 */
	public list<SelectOption> getOnPromotions(){
		list<SelectOption> options 		 = new list<SelectOption>();
		list<Promotion__c> promotionList = new list<Promotion__c>();
		
		promotionList = [SELECT id, Name
						 FROM Promotion__c
						 WHERE Promotion_Period_Start_Date__c <=: system.today()
						 AND Promotion_Period_End_Date__c >=: system.today()
						 AND RecordType.Name = 'Trade Loader Promotion'
						 order by Name];
		
		options.add(new SelectOption('None','None'));
		if(promotionList.size() > 0){
			promotionExists = false;
			for(Promotion__c promotion : promotionList){
				options.add(new SelectOption(promotion.id,promotion.Name));
			}
		} else {
			promotionExists = true;
		}					
			 	
	 	return options;
	}
	public String getwAccount() {
    	return waccId;
    }
            
    public void setwAccount(String wacc) {
    	customerNumberWBO = wacc;
    	list<String> wholesalerBranchId = wacc.split(':');
    	
    	this.waccId = wholesalerBranchId[0];
    }  
    
    public PageReference validateDrop1Date() {
    	
    	drop1DateValidOrNot = '';
    	
    	
    	if(salesRecord != null && salesRecord.Drop_1_Date__c != null && salesRecord.Drop_1_Date__c > todaysDate) {
    		
    		if(salesRecord.Drop_1_Date__c == todaysDate.addDays(1)) {
    			
    			if (datetime.now().hour() < 12) {
            
                    drop1DateValidOrNot = 'Yes';
              
    			}
    			
    			else {
    				
    				drop1DateValidOrNot = 'No';
    				
    			}
              
    		}  
              
    		else if(salesRecord.Drop_1_Date__c >= todaysDate.addDays(2)){
    			
    			drop1DateValidOrNot = 'Yes';
    			
    		}    		
    	
    	}
    	
    	else
    	
    	   drop1DateValidOrNot = 'No';
    	
    	return null;
    	
    }
    
    //Constructor
    public TradeLoaderController(){
    	todaysDate = date.today();
    	Items = new List<SelectOption>();
    	wholesalerNotExist 		= false;
    	hideRestItems 			= true;
    	promotionExists 		= false;
    	headerList 				= new list<string>{'header'};
    	totalAmount				= 0;
    	totalQuantityDrop1 		= 0;
    	totalQuantityDrop2 		= 0;
    	totalQuantityDrop3 		= 0; 
    	orderLineItemsToBeDisplayed = new list<TradeloaderHelper>();
    	orderLineItemsSelected 		= new list<TradeLoaderHelper>();
    	prmProduct                  = new list<string>();
        price                       = new list<Decimal>();
        prdct                       = new list<Product__c>();

        salesRecord                 = new Sales_Order__c (Outlet_Name__c= ApexPages.currentPage().getParameters().get('acid'));
        
        salesRecord2                = new Sales_Order__c (Outlet_Name__c= ApexPages.currentPage().getParameters().get('acid'));
        salesRecord3                = new Sales_Order__c (Outlet_Name__c= ApexPages.currentPage().getParameters().get('acid'));
        
        salesRecord.recordTypeId    = Utilities.getRecordTypeId('Sales_Order__c','Trade Loader Sales Order Drop 1');
       
        salesRecord2.recordTypeId   = Utilities.getRecordTypeId('Sales_Order__c','Trade Loader Sales Order Drop 2');
        salesRecord3.recordTypeId   = Utilities.getRecordTypeId('Sales_Order__c','Trade Loader Sales Order Drop 3');
        
        acId                        = ApexPages.currentPage().getParameters().get('acid');

        wholeSalerGroupProduct      = new list<string>();
        list<string> promotionId    = new list<string>();
        
     	list<PromotionProduct__c> promotionProd = new list<PromotionProduct__c>();
     	
     	// select Banner group Id for the curent outlet
     	Account acnt;
     	Try{
     		acnt =  [SELECT Outlet_ID__c, Region_Id__c, Banner_Group_ID__c, Banner_Group__r.Parent_Hierarchy__c  
     				 FROM Account 
     				 WHERE Id =: acId];
     	} catch (QueryException qe){
     		
     	}
     	
     	/* @author: Geeta Kushwaha
		 * @Description: Get the banner groups in the hierarchy                         
         */               
		set <String> bannerGrpIdSet = new set<String>();       

		bannerGrpIdSet.add(acnt.Banner_Group_ID__c);  
		
		if(acnt.Banner_Group__r.Parent_Hierarchy__c  != null){
			
	        string parent = acnt.Banner_Group__r.Parent_Hierarchy__c ;
	        
			set <String> mysalesIdSet = new set<String>();
			
			for(String s : parent.split(',',parent.countMatches(','))){
			    
			    try {
			    	
			    	mysalesIdSet.add(''+Integer.valueOf(s)); //We dont have to add ** or * values, only integer values need to be added
			    	
			    }
			    
			    catch(Exception e){}
			    
			}
			
			if(!mysalesIdSet.isEmpty()) {
			
				for(Account banner : [select Banner_Group_ID__c
		  							  from Account
		  							  where My_Sales_Id__c IN : mysalesIdSet
		  							  and RecordTypeId =: Utilities.getRecordTypeId('Account','Banner Group')]) {
		  							  	
		  				bannerGrpIdSet.add(banner.Banner_Group_ID__c);			  	
		  							  	
		  							  	
				}
			
			}
			
		}       
     	
     	//CREATE LIST OF PROMOTION ID FROM PROMOTION OUTLET
        
	    list<Promotion_Outlet__c> pOutlet = [SELECT Promotion_ID__c 
	    									FROM Promotion_Outlet__c  
                                            WHERE Outlet_ID__c =:acnt.Outlet_ID__c
                                            AND Promotion__r.Buy_Period_Start_Date__c <=:Date.today()
                                            AND Promotion__r.Buy_Period_End_Date__c>=:Date.today()];

		for(Promotion_Outlet__c po:pOutlet){
			promotionIdSet.add(po.Promotion_ID__c);
		}    

		//create  list of promotion id from wholesaler banner group

	  	list<Wholesaler_Banner_Group__c> wbGroup  = [SELECT Banner_Group_ID__c,name, Region_Id__c,
			                                        	(SELECT Promotion_ID__c, Promotion__r.Buy_Period_Start_Date__c,Promotion__r.Buy_Period_End_Date__c 
			                                             FROM Promotion_Banner_Groups__r) 
		                                             FROM Wholesaler_Banner_Group__c  
		                                             WHERE Banner_Group_ID__c IN : bannerGrpIdSet
		                                             AND Region_Id__c =: acnt.Region_Id__c];

		if(wbGroup.size()>0 ){
			for(Wholesaler_Banner_Group__c wholeSaleBannerGroup : wbGroup){
				
				for(Promotion_Banner_Group__c pbg : wholeSaleBannerGroup.Promotion_Banner_Groups__r){
					promotionIdSet.add(pbg.Promotion_ID__c);
				}
			}
		}
     	
     	//Fetch ongoing promotions
     	if(promotionIdSet.size()>0){
			promotionProd = [SELECT name,id,Product__c,Promotion__r.Discount_Amount_1__c,Product__r.Product_ID__c,
			                	Promo_Start_Date__c,Promo_End_Date__c 
			                 FROM PromotionProduct__c
                             WHERE Promotion__r.name in:promotionIdSet
                             AND Promotion__r.Buy_Period_Start_Date__c <=:Date.today()
                             AND Promotion__r.Buy_Period_End_Date__c>=:Date.today()
                             and Active__c = true
                             ORDER BY Product__r.name];
		}    
     	
     	// add those products which are going throug a promotion
     	// productIdSet : contains product ids for those products which are coming in ongoing promotions
     	for(PromotionProduct__c prpmd : promotionProd){ 
			productIdSet.add(prpmd.Product__c);
		}   
		
		// Fetch those promotion products which are not in promotions
		list<PromotionProduct__c> promotionProdOfPricing = [SELECT name,id,Product__c, Product__r.Name, 
    													   		Promotion__r.Discount_Amount_1__c,Product__r.Product_ID__c, 
    															Promo_Start_Date__c, Promo_End_Date__c 
                                                            FROM PromotionProduct__c
                                                            WHERE Pricing__r.Start_Date__c <=:Date.today()
                                                            AND Pricing__r.End_Date__c>=:Date.today()
                                                            AND Promotion__c = NULL
                                                            AND Product__c NOT IN : productIdSet
                                                            and Active__c = true
                                                            ORDER BY Product__r.Name];
        
        //add pricing product to exisitng ongoing promotion product
        for(PromotionProduct__c prd : promotionProdOfPricing){
              promotionProd.add(prd);
        }                                                      

        //Get value of current pricing 
        for(PromotionProduct__c prmPrdct :promotionProd){

            prdctList.add(prmPrdct.Product__r.Product_ID__c);
            
            promotionId.add(prmPrdct.id); 
           
            prmProduct.add(prmPrdct.name);  
            
        }

        DataLoaderHelper helper        =  new DataLoaderHelper();
        map<id,Pricing__c> pricingMap  = new  map<id,Pricing__c>();
        pricingMap.putAll(helper.getPromotionProductPricingMap(promotionId));
        
        for(PromotionProduct__c prmProd : promotionProd){

			Sales_Order_Product__c orderLineItem = new Sales_Order_Product__c(PromotionProduct__c = prmProd .id);
 
            if(prmProd.Product__c != null){
                prdct.add(prdctMap.get(prmProd.Product__c));
			
                if(pricingMap.get(prmProd.id)!=null){
                    if(pricingMap.get(prmProd.id).Wholesaler_Price__c != null && pricingMap.get(prmProd.id).Wholesaler_Price__c != 0.00){
                    	decimal pric = decimal.valueOf(string.valueOf(pricingMap.get(prmProd.id).Wholesaler_Price__c));
                    	
                    	// put data in tradeloaderhelper class
                    	TradeLoaderHelper tradeLoadhelper   = new TradeLoaderHelper();
                    	tradeLoadhelper.productsData 	    = prdctMap.get(prmProd.Product__c);
                    	tradeLoadhelper.salesOrderProducts  = orderLineItem; 
                    	tradeLoadhelper.wholesalerGroupCode = '';
                    	tradeLoadhelper.productPrice 		= pricingMap.get(prmProd.id);
                    	tradeLoadhelper.promoStartDate 		= prmProd.Promo_Start_Date__c;
                    	tradeLoadhelper.promoEndDate 		= prmProd.Promo_End_Date__c;
                    	
                    	if(prmProd.Promotion__r.Discount_Amount_1__c != null){
            
                			tradeLoadhelper.promotionDiscount  = decimal.valueOf(prmProd.Promotion__r.Discount_Amount_1__c).setScale(2);
            			} else{

			                tradeLoadhelper.promotionDiscount  = decimal.valueOf('0.00').setScale(2);
			            }
                    	
                    	if(tradeLoadhelper.promoStartDate != null){
                    		tradeLoadhelper.rowColor = 'Red';
                    	} else {
                    		tradeLoadhelper.rowColor = 'Black';
                    	}
                    	orderLineItemsToBeDisplayed.add(tradeLoadhelper);
                    	if(prmProd.Promo_Start_Date__c != null)
                    	
                     	  price.add(pric);
                      //price.add(integer.valueOf(pricingMap.get(prmProd.id).Wholesaler_Price__c));
                    }
                  
            	}
        	}
		}
		// set wholesaler branch name and customer number to Wholesaler Branch Name picklist 
		// 
        list<Wholesaler_Branch_Outlet__c> branchOutlet = [SELECT WholeSalerAccountId__c,Wholesaler_Branch__c,Primary__c,Wholesaler_Branch__r.Wholesaler_Branch_Name__c,
		                                                  		Wholesaler_Branch__r.Wholesaler_Account__r.name, Customer_Number__c  
		                                                  FROM Wholesaler_Branch_Outlet__c 
                                                          WHERE Outlet_Account__c =:acId
                                                          AND Customer_Number__c != null
                                                          AND (End_Date__c >=: System.today()
                                                          OR End_Date__c = null)];
       	for(Wholesaler_Branch_Outlet__c outlet : branchOutlet) {
        	if(outlet.Primary__c == true) {	
         		Items.add(new SelectOption(outlet.Wholesaler_Branch__c + ':' + outlet.Customer_Number__c,outlet.Wholesaler_Branch__r.Wholesaler_Branch_Name__c + '-' + outlet.Customer_Number__c));
         		customerNumberMap.put(outlet.Wholesaler_Branch__c + ':' + outlet.Customer_Number__c, outlet.Customer_Number__c);
         		inCludeNone = false;
         		break;
         	}
	  	} 
	  
	    //If there is no primary key include none
	  
	    if(inCludeNone){
	  		Items.add(new SelectOption('None','None'));    
	  	}                                              

		for(Wholesaler_Branch_Outlet__c outlet : branchOutlet) {
        	if(outlet.Primary__c != true) {
           		Items.add(new SelectOption(outlet.Wholesaler_Branch__c + ':' + outlet.Customer_Number__c,outlet.Wholesaler_Branch__r.Wholesaler_Branch_Name__c + '-' + outlet.Customer_Number__c));
           		customerNumberMap.put(outlet.Wholesaler_Branch__c + ':' + outlet.Customer_Number__c, outlet.Customer_Number__c);
	      	}
	  	}
		
		// get wholesaler branch list. if no wholesler branch is associated with this outlet then
		// set wholesalerNotExist t o true
		// else set false, so that error message can be displayed on page
		
		for(Wholesaler_Branch_Outlet__c outlet : branchOutlet) {
			
			
				//Create whole saler group product code for initial value
				if(outlet.Primary__c == true) {
				  waccId = outlet.Wholesaler_Branch__c;
				  showWholesalerGroup();
				}
	
				wBranchList.add(outlet.Wholesaler_Branch__c);
		}  

		if(wBranchList.size() == 0){
			wholesalerNotExist = true;
			hideRestItems = false;
		}  
		else{
			wholesalerNotExist = false;
			hideRestItems = true;
		}    
		wBranchList.clear();  
    	
    }
    
    /**
     * @author: Gunwant Patidar
     * @description : This method assigns RTD, Glass Sprints and Wine# to sales order record based on the promotion selected
     				 on SalesOrderTradeLoader page.
     */
     
    public pagereference populateSalesOrderFields(){
     	
 		selectedPromotion = new list<Promotion__c>();
 	
 		selectedPromotion = [SELECT id, Name, Deal_Size__c, Glass_Premium__c, 
 								Glass_Spirits__c, Wine__c, RTD__c, Reward__c
	 						 FROM Promotion__c
	 						 WHERE Id =: promtionId];
 		if(selectedPromotion.size()>0){				
     					
     		salesRecord.RTD_Drop_1__c = selectedPromotion[0].RTD__c;
     		salesRecord.Reward__c =  selectedPromotion[0].Reward__c;
     		rewardName = selectedPromotion[0].Reward__c;
     		salesRecord.Wine_Drop_1__c = selectedPromotion[0].Wine__c;
     		salesRecord.Glass_Spirits_Drop_1__c = selectedPromotion[0].Glass_Spirits__c;			
     		salesRecord.Glass_Premium_Drop_1__c = selectedPromotion[0].Glass_Premium__c;
     		
     		totalQuantitySalesOrder = Integer.valueOf(selectedPromotion[0].Deal_Size__c);
     		
     		promotionExists = true;
     		
 		}
 		return null;
    }
    
    //save salesOrder and all sales Order product record after validation
    public pagereference save(){  
    	sendApproval = false;
    	
        try{
            
            integer drop2QuantityTotal = 0;
            integer drop1QuantityTotal = 0;
            integer drop3QuantityTotal = 0;
            totalQuantitySalesOrder = 0;
            Decimal totalQuantityLineItems = 0.00;
            
            Wholesaler_Branch__c wholesaler = new Wholesaler_Branch__c();
       		if(waccId != null && waccId != ''){
          		wholesaler  =  [select Wholesaler_Account__c  from Wholesaler_Branch__c where id =:waccId];
          		
          		salesRecord.Wholesaler__c  =  wholesaler.Wholesaler_Account__c;
       		}
       		
       		//set sales order record value
	        // set status to sent for approval
	        // so that record does not go directly to wholesaler
	        // if trade loader order does not go for approval then updates status to 'New Sales Order Created'
			salesRecord.Status__c = 'Sent for Approval';
       		salesRecord.Wholesaler_Branch__c = waccId;	
       		salesRecord.Promotion__c = promtionId;
       		salesRecord.Wholesaler_Account_Number__c = 	customerNumberMap.get(customerNumberWBO);
       		
            // if drop 2 is totally blank then no needs to create 2 sales orders
            // else if drop 1 and drop 2 quantity is not balnk then create 2 sales order with drop 1 and drop 2 values
            if(salesRecord.Glass_Spirits_Drop_2__c != null){
            	drop2QuantityTotal += integer.valueOf(salesRecord.Glass_Spirits_Drop_2__c);
            } 
            if(salesRecord.RTD_Drop_2__c != null){
            	drop2QuantityTotal += integer.valueOf(salesRecord.RTD_Drop_2__c);
            }
            
            if(salesRecord.Wine_Drop_2__c != null){
            	drop2QuantityTotal += integer.valueOf(salesRecord.Wine_Drop_2__c);
            }
            
            if(salesRecord.Drop_2_Date__c != null && drop2QuantityTotal != 0){
                cloneSalesRecord(salesRecord,salesRecord2)  ;
            }
            
            if(salesRecord.Glass_Premium_Drop_3__c != null){
                drop1QuantityTotal += integer.valueOf(salesRecord.Glass_Premium_Drop_3__c);
            }
            
             // for drop 3 quantity sum up
            if(salesRecord.Glass_Spirits_Drop_3__c != null){
            	drop3QuantityTotal += integer.valueOf(salesRecord.Glass_Spirits_Drop_3__c);
            } 
            
            if(salesRecord.RTD_Drop_3__c != null){
            	drop3QuantityTotal += integer.valueOf(salesRecord.RTD_Drop_3__c);
            }
            
            if(salesRecord.Wine_Drop_3__c != null){
            	drop3QuantityTotal += integer.valueOf(salesRecord.Wine_Drop_3__c);
            }
            
            if(salesRecord.Glass_Premium_Drop_3__c != null){
                drop3QuantityTotal += integer.valueOf(salesRecord.Glass_Premium_Drop_3__c);
            }
            
            if(salesRecord.Drop_3_Date__c != null && drop3QuantityTotal != 0){
                	cloneSalesRecord3(salesRecord,salesRecord3)  ;
            }
            
            
            // for drop 1 quantity sum up
            if(salesRecord.Glass_Spirits_Drop_1__c != null){
            	drop1QuantityTotal += integer.valueOf(salesRecord.Glass_Spirits_Drop_1__c);
            } 
            if(salesRecord.RTD_Drop_1__c != null){
            	drop1QuantityTotal += integer.valueOf(salesRecord.RTD_Drop_1__c);
            }
            
            if(salesRecord.Wine_Drop_1__c != null){
            	drop1QuantityTotal += integer.valueOf(salesRecord.Wine_Drop_1__c);
            }
            
            if(salesRecord.Glass_Premium_Drop_1__c != null){
                drop1QuantityTotal += integer.valueOf(salesRecord.Glass_Premium_Drop_1__c);
            }
            
            // sum total quantity for sales order
            totalQuantitySalesOrder = integer.valueOf(selectedPromotion[0].Deal_Size__c);
            
            // sum total quantity for line items
            totalQuantityLineItems = totalQuantityDrop1 + totalQuantityDrop2 + totalQuantityDrop3;
            
            salesRecord.Drop_2_Date__c 		= null;
            salesRecord.Wine_Drop_3__c 		= null;
            salesRecord.Glass_Spirits_Drop_2__c =null;
            salesRecord.Glass_Spirits_Drop_3__c =null;
            salesRecord.RTD_Drop_2__c 		= null;
            salesRecord.RTD_Drop_3__c 		= null;
            salesRecord.Wine_Drop_2__c 		= null;
            salesRecord.Drop_3_Date__c 		= null;
            salesRecord.Glass_Premium_Drop_3__c = null;
			salesRecord.Glass_Premium_Drop_2__c = null;
									
            insert salesRecord;

            integer counter=0;
			
			list<Sales_Order_Product__c> salesOrderProductsTObeCreated = new list<Sales_Order_Product__c>(); 
			for(TradeLoaderHelper lineItems : orderLineItemsSelected){
				// create line items for Drop 1 sales order
				if(salesRecord.id != null && (lineItems.salesOrderProducts.Quantity__c != null && lineItems.salesOrderProducts.Quantity__c != 0)){
					Sales_Order_Product__c orderProduct1 = new Sales_Order_Product__c();
					orderProduct1.PromotionProduct__c 	 = lineItems.salesOrderProducts.PromotionProduct__c;
					orderProduct1.Quantity__c 			 = lineItems.salesOrderProducts.Quantity__c;
					orderProduct1.Sales_Order__c 		 = salesRecord.id;
					orderProduct1.Discount__c 			 = lineItems.salesOrderProducts.Discount__c;
					orderProduct1.Total_Price__c 		 = lineItems.drop1Amount;
					orderProduct1.Maximum_Discount__c    = lineItems.productPrice.Maximum_Discount__c;
					
					if(lineItems.salesOrderProducts.Discount__c == Null || lineItems.salesOrderProducts.Discount__c < lineItems.promotionDiscount){
						orderProduct1.Total_Applied_Discount2__c = lineItems.promotionDiscount.setScale(2);
						
					} else {
						orderProduct1.Total_Applied_Discount2__c = orderProduct1.Discount__c.setScale(2);
					}
					salesOrderProductsTObeCreated.add(orderProduct1);
				}
				// create line items for Drop 2 sales order
				if(salesRecord2.Id != null && (lineItems.salesOrderProducts.Quantity_2__c != null && lineItems.salesOrderProducts.Quantity_2__c != 0)){
				 	Sales_Order_Product__c orderProduct2 = new Sales_Order_Product__c();
				 	orderProduct2.PromotionProduct__c 	 = lineItems.salesOrderProducts.PromotionProduct__c;
				 	orderProduct2.Quantity__c  			 = lineItems.salesOrderProducts.Quantity_2__c;
				 	orderProduct2.Discount__c 			 = lineItems.salesOrderProducts.Discount__c;
					orderProduct2.Sales_Order__c 		 = salesRecord2.id;
					orderProduct2.Total_Price__c 		 = lineItems.drop2Amount;
					orderProduct2.Maximum_Discount__c    = lineItems.productPrice.Maximum_Discount__c;
					if(lineItems.salesOrderProducts.Discount__c == Null || lineItems.salesOrderProducts.Discount__c < lineItems.promotionDiscount){
						orderProduct2.Total_Applied_Discount2__c = lineItems.promotionDiscount.setScale(2);
						
					} else {
						orderProduct2.Total_Applied_Discount2__c = orderProduct2.Discount__c.setScale(2);
					}
					
					salesOrderProductsTObeCreated.add(orderProduct2);
				}
				// create line items for Drop 3 sales order
				if(salesRecord3.Id != null && (lineItems.salesOrderProducts.Quantity_3__c != null && lineItems.salesOrderProducts.Quantity_3__c != 0)){
				 	Sales_Order_Product__c orderProduct3 = new Sales_Order_Product__c();
				 	orderProduct3.PromotionProduct__c 	 = lineItems.salesOrderProducts.PromotionProduct__c;
				 	orderProduct3.Quantity__c 	 		 = lineItems.salesOrderProducts.Quantity_3__c;
				 	orderProduct3.Discount__c 			 = lineItems.salesOrderProducts.Discount__c;
					orderProduct3.Sales_Order__c 		 = salesRecord3.id;
					orderProduct3.Total_Price__c 		 = lineItems.drop3Amount;
					orderProduct3.Maximum_Discount__c    = lineItems.productPrice.Maximum_Discount__c;
					
					if(lineItems.salesOrderProducts.Discount__c == Null || lineItems.salesOrderProducts.Discount__c < lineItems.promotionDiscount){
						orderProduct3.Total_Applied_Discount2__c = lineItems.promotionDiscount.setScale(2);
						
					} else {
						orderProduct3.Total_Applied_Discount2__c = orderProduct3.Discount__c.setScale(2);
					}
					
					salesOrderProductsTObeCreated.add(orderProduct3);
				}
				
				if(totalQuantitySalesOrder > totalQuantityLineItems){
                    sendApproval = true;
                    salesRecord.Send_Approval_for_quantity__c = true;
                    if(salesRecord2.id != null){
                       salesRecord2.Send_Approval_for_quantity__c = true;
                    }
                    if(salesRecord3.id != null){
                       salesRecord3.Send_Approval_for_quantity__c = true;
                    }
                } 
				
				// check for approving sales order if discount is more than maximum discount
				else if(lineItems.salesOrderProducts.Discount__c > lineItems.productPrice.Maximum_Discount__c && lineItems.salesOrderProducts.Quantity__c != null){
                    sendApproval = true;
                    salesRecord.Send_Approval_for_discount__c = true;
                    if(salesRecord2.id != null){
                       salesRecord2.Send_Approval_for_discount__c = true;
                    }
                    if(salesRecord3.id != null){
                       salesRecord3.Send_Approval_for_discount__c = true;
                    }                    
                }
				
			}
			insert salesOrderProductsTObeCreated;
			
            //send approval process.  
            
            map<boolean, string> statusMap = new map<boolean,String>{true => 'Sent for Approval',
                                                                     false => 'New Sales Order Created'};
				
            list <Sales_Order__c> orderList = new list<Sales_Order__c>();
            
            salesRecord.Status__c = statusMap.get(sendApproval);
            
            orderList.add(salesRecord);
            
            if(salesRecord2.Id != null){
            	
            	salesRecord2.Status__c = statusMap.get(sendApproval);
            	
            	orderList.add(salesRecord2);
            	
            }
            
            if(salesRecord3.Id != null){
                
                salesRecord3.Status__c = statusMap.get(sendApproval);
                
                orderList.add(salesRecord3);
                
            }
            
            update orderList;
            
            if(sendApproval){
            	
               sendApproval(salesRecord);
               
               if(salesRecord2.Id != null){
               	
               	    sendApproval(salesRecord2);
               	    
               }
               
               if(salesRecord3.Id != null){
               	
                    sendApproval(salesRecord3);
                    
               }
               
            }
            
            Task tsk = new Task(ActivityDate = salesRecord.Drop_1_Date__c.addDays(15),Description = 'Make call',Priority = 'High',Status ='In Progress',
                                 Subject='Make call',Type ='Call' ,WhatId = acId ,OwnerId = UserInfo.getUserId());
                     
            insert tsk; 
                                 
            return new pagereference('/'+salesRecord.id);
          
        } catch (Exception e){
        	ApexPages.addMessages(e);
        }
        return null;
    }
    // Send sales order for approval if discount is greater than maximum discount
    private void sendApproval(Sales_Order__c s){
        // Create an approval request for the account
        Approval.ProcessSubmitRequest req1 = 
                new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(s.id);

        // Submit the approval request for the account
        Approval.ProcessResult result = Approval.process(req1);

        // Verify the result
        System.assert(result.isSuccess());

        System.assertEquals(
                'Pending', result.getInstanceStatus(), 
                'Instance Status'+result.getInstanceStatus());
    }

    /**
     * @Author : Gunwant Patidar
     * @description : when wholesaelr Branch name pick list valus is changed on vf page this method will  update 
     *    				corresponding WholesalerGroupProductId to each promotion product
     */ 
	public void showWholesalerGroup(){
		
    	wholeSalerGroupProduct.clear(); 
        try{
	        if(waccId!=null){
	        	 
		        wholeSalerGroupProduct.clear();     
		        
		        wholeSalerGroupProduct.clear();
		        map<string,string> groupProuctMap  =  new map<string, string>();
		         
		        Wholesaler_Branch__c branch = [select Wholesaler_Account__c from Wholesaler_Branch__c where id =:waccId];
		        account ac = [select id,Wholesaler_Group__r.Wholesaler_Group_ID__c from account where id =:branch.Wholesaler_Account__c];
		        
		        wholeSalerList.add(ac.Wholesaler_Group__r.Wholesaler_Group_ID__c );
		        
		        DataLoaderHelper helper = new DataLoaderHelper();
		        groupProuctMap.putAll(helper.getWholeSalerGroupProductMap(prdctList,wholeSalerList));
		        
		        // put wholesaler Group code in helper class
		        for(TradeLoaderHelper help : orderLineItemsToBeDisplayed){
		        	
			        if(groupProuctMap.get(help.productsData.Product_ID__c+':'+ac.Wholesaler_Group__r.Wholesaler_Group_ID__c) != null){	
			        	help.wholesalerGroupCode = groupProuctMap.get(help.productsData.Product_ID__c+':'+ac.Wholesaler_Group__r.Wholesaler_Group_ID__c);
			        }
			        else{  
			        	
			         	help.wholesalerGroupCode = '';  
			        }
		        }
		    }
		    if(waccId == 'None'){
		    	for(TradeLoaderHelper help : orderLineItemsToBeDisplayed){
			    	help.wholesalerGroupCode = '';  
		        }
		    } 
        } catch (Exception e){
        	
        } 

	}

	/**
	 * @Author : Sourav nema :
	 * @description : this method creates sales order which will a clone of sales order 1 but Drop 1 value will be blank
	 * 				Drop 2 value will be different from sales order 1
	 */
    void cloneSalesRecord(Sales_Order__c sls1,Sales_Order__c sls2){

        sls2.Authorising_Rep__c 	= sls1.Authorising_Rep__c;

        sls2.Banner_Group__c    	= sls1.Banner_Group__c;

		sls2.Wholesaler_Branch__c   = sls1.Wholesaler_Branch__c;


        sls2.EFTPOS_Card_Number__c  = sls1.EFTPOS_Card_Number__c;

        sls2.Extra_Reward__c 		= sls1.Extra_Reward__c;

        sls2.Glass_Spirits_Drop_2__c = sls1.Glass_Spirits_Drop_2__c;

        sls2.Order_Status__c 		= sls1.Order_Status__c;

        sls2.Wholesaler_Account_Number__c  =  sls1.Wholesaler_Account_Number__c;

        sls2.Outlet_Name__c 		= sls1.Outlet_Name__c;

        sls2.Promotion__c 			= sls1.Promotion__c;

        sls2.Reward__c 				= sls1.Reward__c;

		sls2.Drop_2_Date__c 		= sls1.Drop_2_Date__c;

        sls2.RTD_Drop_2__c			= sls1.RTD_Drop_2__c;
        
        sls2.Customer_PO_Number__c 	= sls1.Customer_PO_Number__c;
        
        sls2.Wholesaler_Account_Number__c = sls1.Wholesaler_Account_Number__c;
        
        sls2.Size__c  				= sls1.Size__c;
        
        sls2.Status__c 				= sls1.Status__c;
        
        sls2.Supplier_Reference__c 	= sls1.Supplier_Reference__c;
        
        sls2.Team__c   				= sls1.Team__c;
        
        sls2.VendorOrderId__c 		= sls1.VendorOrderId__c;
        
        sls2.Status__c 				= 'New Sales Order Created';
        
        sls2.Wholesaler__c 			= sls1.Wholesaler__c;
        
        sls2.Wine_Drop_2__c  		= sls1.Wine_Drop_2__c;
        sls2.Glass_Premium_Drop_2__c  = sls1.Glass_Premium_Drop_2__c;
        
        insert sls2;
        
    }
    // insert Trade loader sales order for drop 3
    void cloneSalesRecord3(Sales_Order__c sls1,Sales_Order__c sls2){

        sls2.Authorising_Rep__c 	= sls1.Authorising_Rep__c;

        sls2.Banner_Group__c    	= sls1.Banner_Group__c;

		sls2.Wholesaler_Branch__c   = sls1.Wholesaler_Branch__c;


        sls2.EFTPOS_Card_Number__c  = sls1.EFTPOS_Card_Number__c;

        sls2.Extra_Reward__c 		= sls1.Extra_Reward__c;

        sls2.Glass_Spirits_Drop_3__c = sls1.Glass_Spirits_Drop_3__c;

        sls2.Order_Status__c 		= sls1.Order_Status__c;

        sls2.Wholesaler_Account_Number__c  =  sls1.Wholesaler_Account_Number__c;

        sls2.Outlet_Name__c 		= sls1.Outlet_Name__c;

        sls2.Promotion__c 			= sls1.Promotion__c;

        sls2.Reward__c 				= sls1.Reward__c;

		sls2.Drop_3_Date__c 		= sls1.Drop_3_Date__c;

        sls2.RTD_Drop_3__c 			= sls1.RTD_Drop_3__c;
        
        sls2.Customer_PO_Number__c  = sls1.Customer_PO_Number__c;
        
        sls2.Wholesaler_Account_Number__c = sls1.Wholesaler_Account_Number__c;
        
        sls2.Size__c  				= sls1.Size__c;
        
        sls2.Status__c 				= sls1.Status__c;
        
        sls2.Supplier_Reference__c 	= sls1.Supplier_Reference__c;
        
        sls2.Team__c   				= sls1.Team__c;
        
        sls2.VendorOrderId__c 		= sls1.VendorOrderId__c;
        
        sls2.Status__c 				= 'New Sales Order Created';
        
        sls2.Wholesaler__c 			= sls1.Wholesaler__c;
        
        sls2.Wine_Drop_3__c  		= sls1.Wine_Drop_3__c;
        sls2.Glass_Premium_Drop_3__c  = sls1.Glass_Premium_Drop_3__c;
        
        insert sls2;
        
    }

    /**
     * @author : Gunwant Patidar
     * @description : this method pick those records which has some value in quantity and quantity 2 and price is not null and not 0
     * @return orderLineItemsSelected TradeLoaderHelper:
     */
    public pagereference addSelectedProducts(){

    	if(selectedPromotion == null || selectedPromotion.size() == 0) {
    	
    	   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Select Promotion'));
    	   
    	   return null;
    	   
    	}   
    	
    	grandTotal 			= 0;
		totalQuantityDrop2 	= 0;
    	totalQuantityDrop1  = 0;
    	totalQuantityDrop3  = 0;
    	approvalFlag 		= false;
    	orderLineItemsSelected.clear();
    	
    	//Modified By-:Sourav// 
    	
    	decimal salesOrderValue1 = 0;
    	decimal salesOrderValue2 = 0;
    	decimal salesOrderValue3 = 0;
    	
    	decimal discount;
    	
    	//////////////////////////
    	
    	for(TradeLoaderHelper helpOrder : orderLineItemsToBeDisplayed){
    		helpOrder.productTotalAmount = 0;
    		helpOrder.totalQuantity 	 = 0;
    		
    		helpOrder.needApproval 		 = 'No';
    		helpOrder.doApprovalRequired = false;
    		
    		// set approvalFlag to true 
            if(helpOrder.salesOrderProducts.Discount__c != null){
            	
            	if( helpOrder.promotionDiscount > helpOrder.salesOrderProducts.Discount__c)
            
                    discount = helpOrder.promotionDiscount;
                    
                else
                
                    discount = helpOrder.salesOrderProducts.Discount__c;  

                    
                if(helpOrder.salesOrderProducts.Discount__c != 0 && helpOrder.salesOrderProducts.Discount__c > helpOrder.productPrice.Maximum_Discount__c){
                    
                    approvalFlag = true;
                    
                    helpOrder.doApprovalRequired = true;
                    
                    helpOrder.needApproval = 'Yes';
                    
                }
            }
            
            else
                
                discount = helpOrder.promotionDiscount;
    		  
    		
    		
    		if(helpOrder.salesOrderProducts.Quantity__c != null || helpOrder.salesOrderProducts.Quantity_2__c != null || helpOrder.salesOrderProducts.Quantity_3__c != null){
	    		if(helpOrder.salesOrderProducts.Quantity__c != null && helpOrder.salesOrderProducts.Quantity__c != 0){
	    			
	    			
	    			
	    			helpOrder.totalQuantity += helpOrder.salesOrderProducts.Quantity__c;
	    			totalQuantityDrop1  	+=  integer.valueOf(helpOrder.salesOrderProducts.Quantity__c);
	    			
					if(helpOrder.productPrice.Wholesaler_Price__c != null && helpOrder.productPrice.Wholesaler_Price__c != 0 && helpOrder.productPrice.Wholesaler_Price__c != 0.00){
					
					   helpOrder.drop1Amount = helpOrder.salesOrderProducts.Quantity__c * (helpOrder.productPrice.Wholesaler_Price__c - discount);
					   
					   helpOrder.productTotalAmount = helpOrder.drop1Amount ;
					   
	    		    }
					
					//orderLineItemsSelected.add(helpOrder);
				}
				if(helpOrder.salesOrderProducts.Quantity_2__c != null && helpOrder.salesOrderProducts.Quantity_2__c != 0){
					
					helpOrder.totalQuantity += helpOrder.salesOrderProducts.Quantity_2__c;
					
					totalQuantityDrop2 +=  integer.valueOf(helpOrder.salesOrderProducts.Quantity_2__c);
					
					if(helpOrder.productPrice.Wholesaler_Price__c != null && helpOrder.productPrice.Wholesaler_Price__c != 0 && helpOrder.productPrice.Wholesaler_Price__c != 0.00) {
					
					   helpOrder.drop2Amount  = helpOrder.salesOrderProducts.Quantity_2__c * (helpOrder.productPrice.Wholesaler_Price__c - discount);
					
					   helpOrder.productTotalAmount += helpOrder.drop2Amount;
					   
					}
					
				}
				
				if(helpOrder.salesOrderProducts.Quantity_3__c != null && helpOrder.salesOrderProducts.Quantity_3__c != 0){
					helpOrder.totalQuantity += helpOrder.salesOrderProducts.Quantity_3__c;
					totalQuantityDrop3 +=  integer.valueOf(helpOrder.salesOrderProducts.Quantity_3__c);
					
					if(helpOrder.productPrice.Wholesaler_Price__c != null && helpOrder.productPrice.Wholesaler_Price__c != 0 && helpOrder.productPrice.Wholesaler_Price__c != 0.00) {
					
					   helpOrder.productTotalAmount += helpOrder.salesOrderProducts.Quantity_3__c * (helpOrder.productPrice.Wholesaler_Price__c - discount);
					   helpOrder.drop3Amount         = helpOrder.salesOrderProducts.Quantity_3__c * (helpOrder.productPrice.Wholesaler_Price__c - discount);
					
					}
					
				}
				
				grandTotal += helpOrder.productTotalAmount.setScale(2);
                grandTotal = grandTotal.setScale(2);

                helpOrder.productTotalAmount = helpOrder.productTotalAmount.setScale(2);
				
				orderLineItemsSelected.add(helpOrder);
    		}
    	}
    	
    	salesOrderValue1 = calculateSum(salesRecord.RTD_Drop_1__c,salesRecord.Glass_Spirits_Drop_1__c,salesRecord.Wine_Drop_1__c, salesRecord.Glass_Premium_Drop_1__c);
        
        salesOrderValue2 = calculateSum(salesRecord.RTD_Drop_2__c, salesRecord.Glass_Spirits_Drop_2__c, salesRecord.Wine_Drop_2__c, salesRecord.Glass_Premium_Drop_2__c);
        
        salesOrderValue3 = calculateSum(salesRecord.RTD_Drop_3__c, salesRecord.Glass_Spirits_Drop_3__c, salesRecord.Wine_Drop_3__c, salesRecord.Glass_Premium_Drop_3__c);
    	
    	if((salesOrderValue1 + salesOrderValue2 + salesOrderValue3) < Integer.valueOf(selectedPromotion[0].Deal_Size__c)){
    	    
	        for(TradeLoaderHelper helpOrder : orderLineItemsToBeDisplayed){  
	        	if(helpOrder.salesOrderProducts.Quantity__c != null || helpOrder.salesOrderProducts.Quantity_2__c != null || helpOrder.salesOrderProducts.Quantity_3__c != null)   
	               helpOrder.needApproval = 'Yes';
	        }
    		
    	}
    		
    	return null;
    }
    
    public decimal calculateSum(decimal rtd, decimal spirit, decimal wineDrop, decimal glassPremium){        
    	
    	return (rtd == null ? 0 : rtd) + (spirit == null ? 0 : spirit) + (wineDrop == null ? 0 : wineDrop) + (glassPremium == null ? 0 : glassPremium);
    	
    }
    
}