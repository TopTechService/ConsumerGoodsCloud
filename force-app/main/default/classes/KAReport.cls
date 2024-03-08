/*
 * Class Name : KAReport
 * Description - This class is used for calculating the data on proposedKaReport.
 * @author Geeta Kushwaha (geeta.kushwaha@arxxus.com)
 * @revised : 23-07-2013 [created by Geeta Kushwaha]
 * @revised : 27-08-2013 [modified by Geeta Kushwaha] optimize query for performance 
 * @revised : 24-12-2013 [modified by Geeta Kushwaha] group by brand instead of promoted range
 */ 
public class KAReport {
	
	/*
	 * Filters for VF page
	 */
	private list<SelectOption> stateList;
    
    private list <SelectOption> bannerGroup;
    
    /*
     * Values that user has selected
     */
	
	public string selected_State{get;set;}
	
    public string selected_BannerGroup{get;set;}
    
    public Sale_MySales__c salesDate {get;set;}
    
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
    
    public KAReport(){
    	
    	//selected_State = 'a0UO00000023g6HMAQ';
    	 
    	//selected_BannerGroup = '001O000000E0ag7IAB';
        
        salesDate = new Sale_MySales__c();
        
        //salesDate.Sale_Date__c = date.newInstance(2013,07,31);
        
        /*
         * Initially do not display the report data
         */
    	
    	showResults = false;
    	
    	brandSubClassificationProductMap = new map <String,map<String,set<Product__c>>>();
    	
    	brandSubClassificationProductMapKeys = new map <String,map<String,integer>>();
    	
    	classificationsList = new String[]{'RTD','Glass','Wine'};
    	
        bannerGroupId = Utilities.getRecordTypeId('Account', 'Banner Group');
        
        productInfoMap = new map<Id, Product__c>([select Id, Name, Classification__c, Sub_Classification__c, Brand__c
                                                  from Product__c where Hide_From_KAReport__c = false]); 
        
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
        
        stateList = new List<SelectOption>(); 

        //stateList.add(new SelectOption('ALL','ALL'));
            
        for(State__c state: [select Id, Name ,Region__r.Name
                               from State__c
                               where Region__r.Name != 'National'       
                               order BY Name ASC limit 9999]) {
                
            stateList.add(new SelectOption(state.Id,state.Name));
              
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
    
    private static map <String, decimal> count9LE(list <Id> bannerIdList, String stateId, boolean isClassification, Date fromDate, Date toDate){
    	
    	map <String, decimal> productMap = new map <String,decimal>();
    	
    	string queryforBanner;
    	
    	if(isClassification) {
    		
    		list <String> classificationsList = new list<String>{'RTD','Glass','Wine'};
    		
    		queryForBanner =  'Select Product__r.Classification__c, Nine_LE__c From Sale_MySales__c  where Product__r.Classification__c IN : classificationsList';          
        
            queryForBanner += ' and Banner_Group__c IN : bannerIdList';
            
            queryforBanner += ' and Sale_Date__c >=: fromDate and Sale_Date__c <=: toDate';
            
            queryforBanner += ' and Outlet__r.State__c =: stateId';
            
            queryforBanner += ' and Product__r.Hide_From_KAReport__c = false';
            
            
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
        
	        queryForBanner += ' and Banner_Group__c IN : bannerIdList';
	        
	        queryforBanner += ' and Sale_Date__c >=: fromDate and Sale_Date__c <=: toDate';
	        
	        queryforBanner += ' and Outlet__r.State__c =: stateId';
	        
            queryforBanner += ' and Product__r.Hide_From_KAReport__c = false';
	              
	        for(Sale_MySales__c sales : database.query(queryforBanner)){
	            
	            if(productMap.containsKey(sales.Product__c))
	            
	                productMap.put(sales.Product__c, productMap.get(sales.Product__c)+sales.Nine_LE__c);
	                
	            else
	            
	                productMap.put(sales.Product__c, sales.Nine_LE__c);    
	            
	        }
    		
    	}
    	
    	
        
        return productMap;
    	
    }
    
    /**
     * @Arxxus Advantage:
     * added start date
   	 */
    
    //Month: Actual TY
    @RemoteAction
    public static Map<String, decimal> calculateColumn1(Date startDate, Date selectedDate, String selected_State, list <Id> bannerIdList, boolean isClassification){
    	
    	return count9LE(bannerIdList, selected_State, isClassification, date.newInstance(selectedDate.year(), selectedDate.month(),1), selectedDate);
    	
    }
    
    //Month: Actual LY
    @RemoteAction
    public static Map<String, decimal> calculateColumn2(Date startDate, Date selectedDate, String selected_State, list <Id> bannerIdList, boolean isClassification){
        
        return count9LE(bannerIdList, selected_State, isClassification, date.newInstance(selectedDate.year()-1, selectedDate.month(),1), date.newInstance(selectedDate.year()-1, selectedDate.month(),selectedDate.day()));        
        
    }
    
    //Calendar Year to Date: Actual TY
    @RemoteAction
    public static Map<String, decimal> calculateColumn6(Date startDate, Date selectedDate,String selected_State, list <Id> bannerIdList, boolean isClassification){
        
        return count9LE(bannerIdList, selected_State, isClassification, startDate, selectedDate);
        
    }
    
    //Calendar Year to Date: Actual LY
    @RemoteAction
    public static Map<String, decimal> calculateColumn7(Date startDate, Date selectedDate, String selected_State, list <Id> bannerIdList, boolean isClassification){
        
        return count9LE(bannerIdList, selected_State, isClassification, date.newInstance(startDate.year()-1, startDate.month(), startDate.day()),  date.newInstance(selectedDate.year()-1, selectedDate.month(),selectedDate.day()));        
        
    }
    
    //Volume by Quarter and Half TY vs. LY: Q1 TY
    @RemoteAction
    public static Map<String, decimal> calculateColumn11(Date selectedDate, String selected_State, list <Id> bannerIdList, boolean isClassification){
        
        return count9LE(bannerIdList, selected_State, isClassification, date.newInstance(selectedDate.year(),1,1), date.newInstance(selectedDate.year(),3,31));
        
    }
    
    //Volume by Quarter and Half TY vs. LY: Q1 LY
    @RemoteAction
    public static Map<String, decimal> calculateColumn12(Date selectedDate, String selected_State, list <Id> bannerIdList, boolean isClassification){
        
        return count9LE(bannerIdList, selected_State, isClassification, date.newInstance(selectedDate.year()-1, 1,1),  date.newInstance(selectedDate.year()-1,3,31));        
        
    }
    
    //Volume by Quarter and Half TY vs. LY: Q2 TY
    @RemoteAction
    public static Map<String, decimal> calculateColumn15(Date selectedDate, String selected_State, list <Id> bannerIdList, boolean isClassification){
        
        return count9LE(bannerIdList, selected_State, isClassification, date.newInstance(selectedDate.year(),4,1), date.newInstance(selectedDate.year(),6,30));
        
    }
    
    //Volume by Quarter and Half TY vs. LY: Q2 LY
    @RemoteAction
    public static Map<String, decimal> calculateColumn16(Date selectedDate, String selected_State, list <Id> bannerIdList, boolean isClassification){
        
        return count9LE(bannerIdList, selected_State, isClassification, date.newInstance(selectedDate.year()-1, 4,1),  date.newInstance(selectedDate.year()-1,6,30));        
        
    }
    
    //Volume by Quarter and Half TY vs. LY: Q3 TY
    @RemoteAction
    public static Map<String, decimal> calculateColumn23(Date selectedDate, String selected_State, list <Id> bannerIdList, boolean isClassification){
        
        return count9LE(bannerIdList, selected_State, isClassification, date.newInstance(selectedDate.year(),7,1), date.newInstance(selectedDate.year(),9,30));
        
    }
    
    //Volume by Quarter and Half TY vs. LY: Q3 LY
    @RemoteAction
    public static Map<String, decimal> calculateColumn24(Date selectedDate, String selected_State, list <Id> bannerIdList, boolean isClassification){
        
        return count9LE(bannerIdList, selected_State, isClassification, date.newInstance(selectedDate.year()-1, 7,1),  date.newInstance(selectedDate.year()-1,9,30));        
        
    }
    
    //Volume by Quarter and Half TY vs. LY: Q4 TY
    @RemoteAction
    public static Map<String, decimal> calculateColumn27(Date selectedDate, String selected_State, list <Id> bannerIdList, boolean isClassification){
        
        return count9LE(bannerIdList, selected_State, isClassification, date.newInstance(selectedDate.year(),10,1), date.newInstance(selectedDate.year(),12,31));
        
    }
    
    //Volume by Quarter and Half TY vs. LY: Q4 LY
    @RemoteAction
    public static Map<String, decimal> calculateColumn28(Date selectedDate, String selected_State, list <Id> bannerIdList, boolean isClassification){
        
        return count9LE(bannerIdList, selected_State, isClassification, date.newInstance(selectedDate.year()-1, 10,1),  date.newInstance(selectedDate.year()-1,12,31));        
        
    }
    
    //Volume by Month (MAT):JAN
    @RemoteAction
    public static Map<String, decimal> calculateColumn40(Date startDate, Date selectedDate, String selected_State, list <Id> bannerIdList, boolean isClassification){
        if (startDate.month() == 1)  
        	return count9LE(bannerIdList, selected_State, isClassification, date.newInstance(selectedDate.year(), 1,1),  date.newInstance(selectedDate.year(),1,31));        
        else
        	return new Map<String, Decimal>();
    }
    
    
    // selectedDate.month() is EndDate/salesDate month
    //Volume by Month (MAT):FEB
    @RemoteAction
    public static Map<String, decimal> calculateColumn41(Date startDate, Date selectedDate, String selected_State, list <Id> bannerIdList, boolean isClassification){
    	
    	if(selectedDate.month() >= 2 && startDate.month() <= 2)
        
            return count9LE(bannerIdList, selected_State, isClassification, date.newInstance(selectedDate.year(), 2,1), date.newInstance(selectedDate.year(),2,date.daysInMonth(selectedDate.year(), 2)));
            
        else
        
            return new Map<String, decimal>();           
        
    }
    
    //Volume by Month (MAT):MAR
    @RemoteAction
    public static Map<String, decimal> calculateColumn42(Date startDate, Date selectedDate, String selected_State, list <Id> bannerIdList, boolean isClassification){
        
        if(selectedDate.month() >= 3 && startDate.month() <= 3)
        
            return count9LE(bannerIdList, selected_State, isClassification, date.newInstance(selectedDate.year(), 3,1),  date.newInstance(selectedDate.year(),3,31));  
        
        else
        
            return new Map<String, decimal>();        
        
    }
    
    //Volume by Month (MAT):APR
    @RemoteAction
    public static Map<String, decimal> calculateColumn43(Date startDate, Date selectedDate, String selected_State, list <Id> bannerIdList, boolean isClassification){
        
        if(selectedDate.month() >= 4 && startDate.month() <= 4)
        
            return count9LE(bannerIdList, selected_State, isClassification, date.newInstance(selectedDate.year(), 4,1),  date.newInstance(selectedDate.year(),4,30));
        
        else
        
            return new Map<String, decimal>();          
        
    }
    
    //Volume by Month (MAT):MAY
    @RemoteAction
    public static Map<String, decimal> calculateColumn44(Date startDate, Date selectedDate, String selected_State, list <Id> bannerIdList, boolean isClassification){
        
        if(selectedDate.month() >= 5 && startDate.month() <= 5)
        
            return count9LE(bannerIdList, selected_State, isClassification, date.newInstance(selectedDate.year(), 5,1),  date.newInstance(selectedDate.year(),5,31)); 
        
        else
        
            return new Map<String, decimal>();         
        
    }
    
    //Volume by Month (MAT):JUN
    @RemoteAction
    public static Map<String, decimal> calculateColumn45(Date startDate, Date selectedDate, String selected_State, list <Id> bannerIdList, boolean isClassification){
        
        if(selectedDate.month() >= 6 && startDate.month() <= 6)
        
            return count9LE(bannerIdList, selected_State, isClassification, date.newInstance(selectedDate.year(), 6,1),  date.newInstance(selectedDate.year(),6,30)); 
        
        else
        
            return new Map<String, decimal>();         
        
    }
    
    //Volume by Month (MAT):JUL
    @RemoteAction
    public static Map<String, decimal> calculateColumn46(Date startDate, Date selectedDate, String selected_State, list <Id> bannerIdList, boolean isClassification){
        
        if(selectedDate.month() >= 7 && startDate.month() <= 7)
        
            return count9LE(bannerIdList, selected_State, isClassification, date.newInstance(selectedDate.year(), 7,1),  date.newInstance(selectedDate.year(),7,31));   
        
        else
        
            return new Map<String, decimal>();       
        
    }
    
    //Volume by Month (MAT):AUG
    @RemoteAction
    public static Map<String, decimal> calculateColumn47(Date startDate, Date selectedDate, String selected_State, list <Id> bannerIdList, boolean isClassification){
        
        if(selectedDate.month() >= 8 && startDate.month() <= 8)
        
            return count9LE(bannerIdList, selected_State, isClassification, date.newInstance(selectedDate.year(), 8,1),  date.newInstance(selectedDate.year(),8,31));   
        
        else
        
            return new Map<String, decimal>();       
        
    }
    
    //Volume by Month (MAT):SEP
    @RemoteAction
    public static Map<String, decimal> calculateColumn48(Date startDate, Date selectedDate, String selected_State, list <Id> bannerIdList, boolean isClassification){
        
        if(selectedDate.month() >= 9 && startDate.month() <= 9)
        
            return count9LE(bannerIdList, selected_State, isClassification, date.newInstance(selectedDate.year(), 9,1),  date.newInstance(selectedDate.year(),9,30));    
        
        else
        
            return new Map<String, decimal>();      
        
    }
    
    //Volume by Month (MAT):OCT
    @RemoteAction
    public static Map<String, decimal> calculateColumn49(Date startDate, Date selectedDate, String selected_State, list <Id> bannerIdList, boolean isClassification){
        
        if(selectedDate.month() >= 10 && startDate.month() <= 10)
        
            return count9LE(bannerIdList, selected_State, isClassification, date.newInstance(selectedDate.year(), 10,1),  date.newInstance(selectedDate.year(),10,31));  
        
        else
        
            return new Map<String, decimal>();        
        
    }
    
    //Volume by Month (MAT):NOV
    @RemoteAction
    public static Map<String, decimal> calculateColumn50(Date startDate, Date selectedDate, String selected_State, list <Id> bannerIdList, boolean isClassification){
        
        if(selectedDate.month() >= 11 && startDate.month() <= 11)
        
            return count9LE(bannerIdList, selected_State, isClassification, date.newInstance(selectedDate.year(), 11,1),  date.newInstance(selectedDate.year(),11,30));
        
        else
        
            return new Map<String, decimal>();          
        
    }
    
    //Volume by Month (MAT):DEC
    @RemoteAction
    public static Map<String, decimal> calculateColumn51(Date startDate, Date selectedDate, String selected_State, list <Id> bannerIdList, boolean isClassification){
        
        System.debug('startDate:'+startDate+'selectedDate'+selectedDate+'selected_State'+selected_State+'bannerIdList'+bannerIdList+'isClassification'+isClassification);
        if(selectedDate.month() == 12 && startDate.month() <= 12)
        
            return count9LE(bannerIdList, selected_State, isClassification, date.newInstance(selectedDate.year(), 12,1),  date.newInstance(selectedDate.year(),12,31));  
        
        else
        
            return new Map<String, decimal>();        
        
    }
    
    @RemoteAction
    public static set<Id> getSubBannerGroups(String selected_BannerGroup){        
    	
        Account acc = null;
        
        try {
        
           acc = [select id, My_Sales_Id__c 
                  from Account 
                  where Id =: selected_BannerGroup and My_Sales_Id__c != : null];
                       
        }
        
        catch(QueryException e){
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Selected Banner Group doesnt have mysales Id'));
                
            return new set <Id>();
            
        }  
    
    	return (new map<Id,Account>((list <Account>)database.query('Select id from Account where Parent_Hierarchy__c LIKE '+'\'%,'+ acc.My_Sales_Id__c +',%\''))).keySet();
    	
    }
    
    public List<SelectOption> getStateList() {
        
        return stateList;
        
    }
    
    public List<SelectOption>  getBannerGroup() {
    	
        return bannerGroup;
        
    }

}