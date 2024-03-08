public class OutletSalesReportController {
	/*
	 * Filters for VF page
	 */
	private list<SelectOption> regionList;
    private list <SelectOption> bannerGroup;
    /*
     * Values that user has selected
     */
	public string selected_Region{get;set;}
    public string selected_BannerGroup{get;set;}
    public Sale_MySales__c salesDate {get;set;}
    public string outletId{get;set;}
    public string outletRegionId{get;set;}
    public string outletName {get; set;}
    public string outletRegionName {get; set;}
    /*
     * Helper components
     */
    private Id bannerGroupId;
    public boolean showResults {get; set;}
    public String[] classificationsList {get; set;}
    /*
     * Data to be plotted on VF page
     */
    public map <String,map<String,set<Product__c>>> brandSubClassificationProductMap {get;set;}
    public map <String,map<String,Integer>> brandSubClassificationProductMapKeys {get;set;}  
    public map <String, String> brandInfoMap {get; set;}
    public map <Id,Product__c> productInfoMap {get;set;}
    
    public OutletSalesReportController(){
    	
    	salesDate = new Sale_MySales__c();
        outletId = Apexpages.currentPage().getParameters().get('outletId');
        outletRegionId = Apexpages.currentPage().getParameters().get('outletRegionId');
        
        if (null != outletId) {
        	try {
		        Account tempAccount = [select id, My_Sales_Id__c, Name, Region1__c
				                  from Account 
				                  where Id =: outletId];
				if (null != tempAccount) {
		       		outletName = tempAccount.name;
		       		outletRegionName = tempAccount.Region1__c;
	       		}
			} catch(Exception e) {
				System.debug('exception occured while populating name fields :' + e.getMessage());
			}
        }


        
        /*
         * Initially do not display the report data
         */
    	showResults = false;
    	brandSubClassificationProductMap = new map <String,map<String,set<Product__c>>>();
    	brandSubClassificationProductMapKeys = new map <String,map<String,integer>>();
    	classificationsList = new String[]{'RTD','Glass','Wine'};
        bannerGroupId = Utilities.getRecordTypeId('Account', 'Outlet');
        productInfoMap = new map<Id, Product__c>([select Id, Name, Classification__c, Sub_Classification__c, Brand__c
                                                  from Product__c where Hide_From_Outlet_report__c = false]); 
        set <String> brandSet = new set<String>();
        Product__c prod; 
        for(Id prodId: productInfoMap.keySet()) {
        	prod = productInfoMap.get(prodId);
            brandSet.add(prod.Brand__c); 
            if(brandSubClassificationProductMap.containsKey(prod.Brand__c)){
                if(brandSubClassificationProductMap.get(prod.Brand__c).containsKey(prod.Sub_Classification__c))
                    brandSubClassificationProductMap.get(prod.Brand__c).get(prod.Sub_Classification__c).add(prod);
                else   
                    brandSubClassificationProductMap.get(prod.Brand__c).put(prod.Sub_Classification__c,new set<Product__c>{prod});
            }   
            else {
                brandSubClassificationProductMap.put(prod.Brand__c, new map<String,set<Product__c>>{prod.Sub_Classification__c => new set<Product__c>{prod}});
            }            
        }
        
        /*
         * Replace all Null Values as VF page cannot handle it
         */
        if(brandSubClassificationProductMap.containsKey(null)) {
            map<String,set<Product__c>> subClassificationProducts = brandSubClassificationProductMap.get(null);
            brandSubClassificationProductMap.remove(null);
            brandSubClassificationProductMap.put('NullRange',subClassificationProducts);
        }
        
        for(String keyRangeId : brandSubClassificationProductMap.keySet()){
            for(String subClassfication : brandSubClassificationProductMap.get(keyRangeId).keySet()) {
                if(subClassfication == null)
                {
                    set<Product__c> products = brandSubClassificationProductMap.get(keyRangeId).get(null);
                    brandSubClassificationProductMap.get(keyRangeId).remove(null);
                    brandSubClassificationProductMap.get(keyRangeId).put('NullClassification',products);
                }
            }
        }
        
        integer count;
        
        for(String keyRangeId : brandSubClassificationProductMap.keySet()){
        	count = 0;
        	for(String subClassfication : brandSubClassificationProductMap.get(keyRangeId).keySet()) {
        	   if(brandSubClassificationProductMapKeys.containsKey(keyRangeId))
        	       brandSubClassificationProductMapKeys.get(keyRangeId).put(subClassfication, count);   
        	   else
        	       brandSubClassificationProductMapKeys.put(keyRangeId, new map <String,integer> {subClassfication => count});
        	   count++;
        	}
        }
        
        brandInfoMap = new map<String, String>();
        for(Brand__c b: [select Name, Id
                         from Brand__c
                         where ID IN : brandSet]) {
            brandInfoMap.put(b.Id, b.Name); 
        } 
        if(brandInfoMap.containsKey(null)) {
        	String promotedRangeName = brandInfoMap.get(null);
        	brandInfoMap.remove(null);
        }
        else
            brandInfoMap.put('NullRange','--------');
        
        //region picklist
        regionList = new List<SelectOption>(); 
        for(Region__c region: [select Id, Name 
                               from Region__c
                               where name != 'National'       
                               order BY Name ASC limit 9999]) {
            regionList.add(new SelectOption(region.Id,region.Name));
        }
        
        //BannerGroupPicklist
        bannerGroup = new List<SelectOption>(); 
        bannerGroup.add(new SelectOption('None','None'));
        for(Account sms : [Select id, Name 
                           from Account
                           where RecordTypeId =: bannerGroupId
                           and My_Sales_Id__c != : null
                           order by Name ASC]) {
            bannerGroup.add(new SelectOption(sms.id,sms.Name));
        }
        selected_Region = outletRegionId;
        selected_BannerGroup = outletId;
        salesDate.Sale_Date__c = System.today();
        
    }
    
    public pagereference createReport(){
    	if(selected_BannerGroup == 'None') {
    		showResults = false;
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Select Banner Group'));
    	}
    	else {
	    	showResults = true;
	    	if(salesDate.Sale_Date__c == null)
	            salesDate.Sale_Date__c = date.today();     
    	}
    	return null;
    }
    
    private static map <String, decimal> count9LE(list <Id> bannerIdList, String regionId, boolean isClassification, Date fromDate, Date toDate){
    	map <String, decimal> productMap = new map <String,decimal>();
    	string queryforBanner;
    	if(isClassification) {
    		list <String> classificationsList = new list<String>{'RTD','Glass','Wine'};
    		queryForBanner =  'Select Product__r.Classification__c, Nine_LE__c From Sale_MySales__c  where Product__r.Classification__c IN : classificationsList';          
            queryForBanner += ' and Outlet__c IN : bannerIdList';
            queryforBanner += ' and Sale_Date__c >=: fromDate and Sale_Date__c <=: toDate';
            queryforBanner += ' and Outlet__r.State__r.Region__c =: regionId';
            queryforBanner += ' and Product__r.Hide_From_Outlet_report__c = false';
                  
            for(Sale_MySales__c sales : database.query(queryforBanner)){
            	if(sales.Product__r.Classification__c != null && sales.Product__r.Classification__c.length() > 0) {
	                if(productMap.containsKey(sales.Product__r.Classification__c))
	                    productMap.put(sales.Product__r.Classification__c, productMap.get(sales.Product__r.Classification__c)+sales.Nine_LE__c);
	                else
	                    productMap.put(sales.Product__r.Classification__c, sales.Nine_LE__c);  
            	} 
            }
    	}
    	else {
    		//product
    		queryForBanner =  'Select Product__c, Nine_LE__c From Sale_MySales__c  where Product__c != null';          
	        queryForBanner += ' and Outlet__c IN : bannerIdList';
	        queryforBanner += ' and Sale_Date__c >=: fromDate and Sale_Date__c <=: toDate';
	        queryforBanner += ' and Outlet__r.State__r.Region__c =: regionId';
	        queryforBanner += ' and Product__r.Hide_From_Outlet_report__c = false';
	        
	              
	        for(Sale_MySales__c sales : database.query(queryforBanner)){
	            if(productMap.containsKey(sales.Product__c))
	                productMap.put(sales.Product__c, productMap.get(sales.Product__c)+sales.Nine_LE__c);
	            else
	                productMap.put(sales.Product__c, sales.Nine_LE__c);    
	        }
    	}
        return productMap; 
    }
    
    @RemoteAction
    public static set<Id> getSubBannerGroups(String selected_BannerGroup){        
        Account acc = null;
        try {
           acc = [select id, My_Sales_Id__c
                  from Account 
                  where Id =: selected_BannerGroup];
        }
        catch(QueryException e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Selected Banner Group doesnt have mysales Id'));
            return new set <Id>();
        }  
        set<id> accIds =  new set<Id>();
        accIds.add(acc.id);
        return accIds;
    	//return (new map<Id,Account>((list <Account>)database.query('Select id from Account where Parent_Hierarchy__c LIKE '+'\'%,'+ acc.My_Sales_Id__c +',%\''))).keySet();
    }
    
    //Month: Actual TY
    @RemoteAction
    public static Map<String, decimal> calculateColumn1(Date selectedDate, String selected_Region, list <Id> bannerIdList, boolean isClassification){
    	return count9LE(bannerIdList, selected_Region, isClassification, date.newInstance(selectedDate.year(), selectedDate.month(),1), selectedDate);
    }
    
    //Month: Actual LY
    @RemoteAction
    public static Map<String, decimal> calculateColumn2(Date selectedDate, String selected_Region, list <Id> bannerIdList, boolean isClassification){
        return count9LE(bannerIdList, selected_Region, isClassification, date.newInstance(selectedDate.year()-1, selectedDate.month(),1), date.newInstance(selectedDate.year()-1, selectedDate.month(),selectedDate.day()));        
    }
    
    //Calendar Year to Date: Actual TY
    @RemoteAction
    public static Map<String, decimal> calculateColumn6(Date selectedDate,String selected_Region, list <Id> bannerIdList, boolean isClassification){
        return count9LE(bannerIdList, selected_Region, isClassification, date.newInstance(selectedDate.year(),1,1), selectedDate);
    }
    
    //Calendar Year to Date: Actual LY
    @RemoteAction
    public static Map<String, decimal> calculateColumn7(Date selectedDate, String selected_Region, list <Id> bannerIdList, boolean isClassification){
        return count9LE(bannerIdList, selected_Region, isClassification, date.newInstance(selectedDate.year()-1, 1,1),  date.newInstance(selectedDate.year()-1, selectedDate.month(),selectedDate.day()));        
    }
    
    //Volume by Quarter and Half TY vs. LY: Q1 TY
    @RemoteAction
    public static Map<String, decimal> calculateColumn11(Date selectedDate, String selected_Region, list <Id> bannerIdList, boolean isClassification){
        return count9LE(bannerIdList, selected_Region, isClassification, date.newInstance(selectedDate.year(),1,1), date.newInstance(selectedDate.year(),3,31));
    }
    
    //Volume by Quarter and Half TY vs. LY: Q1 LY
    @RemoteAction
    public static Map<String, decimal> calculateColumn12(Date selectedDate, String selected_Region, list <Id> bannerIdList, boolean isClassification){
        return count9LE(bannerIdList, selected_Region, isClassification, date.newInstance(selectedDate.year()-1, 1,1),  date.newInstance(selectedDate.year()-1,3,31));        
    }
    
    //Volume by Quarter and Half TY vs. LY: Q2 TY
    @RemoteAction
    public static Map<String, decimal> calculateColumn15(Date selectedDate, String selected_Region, list <Id> bannerIdList, boolean isClassification){
        return count9LE(bannerIdList, selected_Region, isClassification, date.newInstance(selectedDate.year(),4,1), date.newInstance(selectedDate.year(),6,30));
    }
    
    //Volume by Quarter and Half TY vs. LY: Q2 LY
    @RemoteAction
    public static Map<String, decimal> calculateColumn16(Date selectedDate, String selected_Region, list <Id> bannerIdList, boolean isClassification){
        return count9LE(bannerIdList, selected_Region, isClassification, date.newInstance(selectedDate.year()-1, 4,1),  date.newInstance(selectedDate.year()-1,6,30));        
    }
    
    //Volume by Quarter and Half TY vs. LY: Q3 TY
    @RemoteAction
    public static Map<String, decimal> calculateColumn23(Date selectedDate, String selected_Region, list <Id> bannerIdList, boolean isClassification){
        return count9LE(bannerIdList, selected_Region, isClassification, date.newInstance(selectedDate.year(),7,1), date.newInstance(selectedDate.year(),9,30));
    }
    
    //Volume by Quarter and Half TY vs. LY: Q3 LY
    @RemoteAction
    public static Map<String, decimal> calculateColumn24(Date selectedDate, String selected_Region, list <Id> bannerIdList, boolean isClassification){
        return count9LE(bannerIdList, selected_Region, isClassification, date.newInstance(selectedDate.year()-1, 7,1),  date.newInstance(selectedDate.year()-1,9,30));        
    }
    
    //Volume by Quarter and Half TY vs. LY: Q4 TY
    @RemoteAction
    public static Map<String, decimal> calculateColumn27(Date selectedDate, String selected_Region, list <Id> bannerIdList, boolean isClassification){
        return count9LE(bannerIdList, selected_Region, isClassification, date.newInstance(selectedDate.year(),10,1), date.newInstance(selectedDate.year(),12,31));
    }
    
    //Volume by Quarter and Half TY vs. LY: Q4 LY
    @RemoteAction
    public static Map<String, decimal> calculateColumn28(Date selectedDate, String selected_Region, list <Id> bannerIdList, boolean isClassification){
        return count9LE(bannerIdList, selected_Region, isClassification, date.newInstance(selectedDate.year()-1, 10,1),  date.newInstance(selectedDate.year()-1,12,31));        
    }
    
    //Volume by Month (MAT):JAN
    @RemoteAction
    public static Map<String, decimal> calculateColumn40(Date selectedDate, String selected_Region, list <Id> bannerIdList, boolean isClassification){
        return count9LE(bannerIdList, selected_Region, isClassification, date.newInstance(selectedDate.year(), 1,1),  date.newInstance(selectedDate.year(),1,31));        
    }
    
    //Volume by Month (MAT):FEB
    @RemoteAction
    public static Map<String, decimal> calculateColumn41(Date selectedDate, String selected_Region, list <Id> bannerIdList, boolean isClassification){
    	if(selectedDate.month() >= 2)
            return count9LE(bannerIdList, selected_Region, isClassification, date.newInstance(selectedDate.year(), 2,1), date.newInstance(selectedDate.year(),2,date.daysInMonth(selectedDate.year(), 2)));
        else
            return new Map<String, decimal>();           
    }
    
    //Volume by Month (MAT):MAR
    @RemoteAction
    public static Map<String, decimal> calculateColumn42(Date selectedDate, String selected_Region, list <Id> bannerIdList, boolean isClassification){
        if(selectedDate.month() >= 3)
            return count9LE(bannerIdList, selected_Region, isClassification, date.newInstance(selectedDate.year(), 3,1),  date.newInstance(selectedDate.year(),3,31));  
        else
            return new Map<String, decimal>();        
    }
    
    //Volume by Month (MAT):APR
    @RemoteAction
    public static Map<String, decimal> calculateColumn43(Date selectedDate, String selected_Region, list <Id> bannerIdList, boolean isClassification){
        if(selectedDate.month() >= 4)
            return count9LE(bannerIdList, selected_Region, isClassification, date.newInstance(selectedDate.year(), 4,1),  date.newInstance(selectedDate.year(),4,30));
        else
            return new Map<String, decimal>();          
    }
    
    //Volume by Month (MAT):MAY
    @RemoteAction
    public static Map<String, decimal> calculateColumn44(Date selectedDate, String selected_Region, list <Id> bannerIdList, boolean isClassification){
        if(selectedDate.month() >= 5)
            return count9LE(bannerIdList, selected_Region, isClassification, date.newInstance(selectedDate.year(), 5,1),  date.newInstance(selectedDate.year(),5,31)); 
        else
            return new Map<String, decimal>();         
    }
    
    //Volume by Month (MAT):JUN
    @RemoteAction
    public static Map<String, decimal> calculateColumn45(Date selectedDate, String selected_Region, list <Id> bannerIdList, boolean isClassification){
        if(selectedDate.month() >= 6)
            return count9LE(bannerIdList, selected_Region, isClassification, date.newInstance(selectedDate.year(), 6,1),  date.newInstance(selectedDate.year(),6,30)); 
        else
            return new Map<String, decimal>();         
    }
    
    //Volume by Month (MAT):JUL
    @RemoteAction
    public static Map<String, decimal> calculateColumn46(Date selectedDate, String selected_Region, list <Id> bannerIdList, boolean isClassification){
        if(selectedDate.month() >= 7)
            return count9LE(bannerIdList, selected_Region, isClassification, date.newInstance(selectedDate.year(), 7,1),  date.newInstance(selectedDate.year(),7,31));   
        else
            return new Map<String, decimal>();       
    }
    
    //Volume by Month (MAT):AUG
    @RemoteAction
    public static Map<String, decimal> calculateColumn47(Date selectedDate, String selected_Region, list <Id> bannerIdList, boolean isClassification){
        if(selectedDate.month() >= 8)
            return count9LE(bannerIdList, selected_Region, isClassification, date.newInstance(selectedDate.year(), 8,1),  date.newInstance(selectedDate.year(),8,31));   
        else
            return new Map<String, decimal>();       
    }
    
    //Volume by Month (MAT):SEP
    @RemoteAction
    public static Map<String, decimal> calculateColumn48(Date selectedDate, String selected_Region, list <Id> bannerIdList, boolean isClassification){
        if(selectedDate.month() >= 9)
            return count9LE(bannerIdList, selected_Region, isClassification, date.newInstance(selectedDate.year(), 9,1),  date.newInstance(selectedDate.year(),9,30));    
        else
            return new Map<String, decimal>();      
    }
    
    //Volume by Month (MAT):OCT
    @RemoteAction
    public static Map<String, decimal> calculateColumn49(Date selectedDate, String selected_Region, list <Id> bannerIdList, boolean isClassification){
        if(selectedDate.month() >= 10)
            return count9LE(bannerIdList, selected_Region, isClassification, date.newInstance(selectedDate.year(), 10,1),  date.newInstance(selectedDate.year(),10,31));  
        else
            return new Map<String, decimal>();        
    }
    
    //Volume by Month (MAT):NOV
    @RemoteAction
    public static Map<String, decimal> calculateColumn50(Date selectedDate, String selected_Region, list <Id> bannerIdList, boolean isClassification){
        if(selectedDate.month() >= 11)
            return count9LE(bannerIdList, selected_Region, isClassification, date.newInstance(selectedDate.year(), 11,1),  date.newInstance(selectedDate.year(),11,30));
        else
            return new Map<String, decimal>();          
    }
    
    //Volume by Month (MAT):DEC
    @RemoteAction
    public static Map<String, decimal> calculateColumn51(Date selectedDate, String selected_Region, list <Id> bannerIdList, boolean isClassification){
        if(selectedDate.month() == 12)
            return count9LE(bannerIdList, selected_Region, isClassification, date.newInstance(selectedDate.year(), 12,1),  date.newInstance(selectedDate.year(),12,31));  
        else
            return new Map<String, decimal>();        
    }
    
    public List<SelectOption> getRegionList() {
        return regionList;
    }
    public List<SelectOption>  getBannerGroup() {
        return bannerGroup;
    }
}