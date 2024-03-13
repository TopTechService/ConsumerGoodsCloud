public with sharing class DataLoaderHelper {   
   
   	Map<String, Account> accountIdMap = new Map<String, Account>();   
   	Map<String, Id> wholeSalerBrnchMap = new Map<String, Id>();
   	Map<String, Id> wholeSalerPrdctMap = new Map<String, String>();
   	Map<String, Id> wholeSalerGroupMap = new Map<String, Id>();
   	Map<String, String> outletCategoryMap = new Map<String, String>();
   	Map<String, Id> stateMap = new Map<String, Id>(); 
   	Map<String, Id> brandMap = new Map<String, Id>();   
   	Map<String, Id> productMap = new Map<String, Id>(); 
   	Map<String, Promoted_Range__c> promotedRangeMap = new Map<String, Promoted_Range__c>(); 
   	public Map<String,Id> RecordTypeIdMap;   
   
   	//get Map for WholesalerBannerGroup  trigger   
	public Map<String,Account> getWholeSalerIdMap (List<String> wsGroup){    
	    accountIdMap.clear();
        Id recordtype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Wholesaler').getRecordTypeId();
	    List<account> accList  =  [SELECT Id,Wholesaler_ID__c 
	    						   FROM account 
	                               WHERE recordtypeid =:recordtype
	                               AND Wholesaler_ID__c IN : wsGroup];
	      
	    for(account ac:accList){        
	    	accountIdMap.put(ac.Wholesaler_ID__c,ac);     
	    }	   
	    return accountIdMap;
    }   
  
    public Map<String,Account>  getBannerIdMap(set<String> wsGroup) {      
	    accountIdMap.clear();    
	    Id recordtype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Banner Group').getRecordTypeId();
	    List<account> accList  =  [select Id, Banner_Group_ID__c 
	                                from account 
	                                where recordtypeid =:recordtype
	                                and Banner_Group_ID__c IN : wsGroup];
	       
	    for(account ac:accList){        
	    	accountIdMap.put(ac.Banner_Group_ID__c,ac);     
	    }     
	    return accountIdMap;
    }
/*    
   	//Get Map for trigger WholesalerBranchOutlet trigger  
   	public  Map<String,account>  getWholesalerOutletMapId (List<String> outletId){
	   	Map<String,account> accntMap = new Map<String, account>();
   	    Id recordtype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Outlet').getRecordTypeId();
       	List<account> accList  =  [SELECT Id,Outlet_ID__c     
                                   FROM account 
                                   WHERE recordtypeid =:recordtype
                                   AND Outlet_ID__c IN : outletId];
		for(account ac:accList){
	        accntMap.put(ac.Outlet_ID__c,ac);
	    }
		return accntMap;
    }
*/
   	//Get Map for trigger WholesalerBranchOutlet trigger
	// modified for Consumer Goods Cloud by daniel.peaper@viseo.com to use retail store records instead of accounts.
   	public  Map<String,RetailStore>  getWholesalerOutletMapId (List<String> outletId){
		Map<String,RetailStore> accntMap = new Map<String, RetailStore>();
		Id recordtype = Schema.SObjectType.RetailStore.getRecordTypeInfosByDeveloperName().get('Retail_Store').getRecordTypeId();
		List<RetailStore> accList  =  [SELECT Id, My_Sales_Id__c     
										FROM RetailStore 
										WHERE recordtypeid =:recordtype
										AND My_Sales_Id__c IN : outletId];
	 for(RetailStore ac:accList){
		 accntMap.put(ac.My_Sales_ID__c,ac);
	 }
	 return accntMap;
 }

  
  
  	//Get Map for trigger WholesalerBranchOutlet trigger
	public  Map<String,Id>  getWholesalerBranchIdMap (List<String> branchId){
	      
		List<Wholesaler_Branch__c> brnchList  =  [SELECT Id,Wholesaler_Branch_Id__c   
		                                          FROM Wholesaler_Branch__c 
		                                          WHERE Wholesaler_Branch_Id__c IN : branchId];
		          
		for(Wholesaler_Branch__c brnch:brnchList){     
			wholeSalerBrnchMap.put(brnch.Wholesaler_Branch_Id__c,brnch.Id);
		}
		     
		return wholeSalerBrnchMap;
	}   
   
  	//Get Map for trigger Wholesaler Group Product     
   	public  Map<String,Id>  getWholeSalerGroupProductMapId (List<String> prdctId){
       	List<Product__c> prdctList  = [select Id,Product_ID__c    
                                    from Product__c 
                                    where Product_ID__c in : prdctId];
        for(Product__c prdct:prdctList){
	        wholeSalerPrdctMap.put(prdct.Product_ID__c,prdct.Id);
    	}
     
	    return wholeSalerPrdctMap;
    }
   
    //Get Map for Wholesaler Group      
    public  Map<String,Id>  getWholeSalerGroupIdMap (List<String> grpId){ 
       
        List<Wholesaler_Group__c> grpList  = [select Id,Wholesaler_Group_ID__c    
                                              from Wholesaler_Group__c 
                                              where Wholesaler_Group_ID__c in : grpId];        
        for(Wholesaler_Group__c grp:grpList){
       		wholeSalerGroupMap.put(grp.Wholesaler_Group_ID__c,grp.Id);
        }
     
        return wholeSalerGroupMap;
    }
  
  
	//Get oultlet category 
    public  Map<String,Id> getOutletCategoryMap (List<String> oname){
    	List<Outlet_Category__c> oCategory  = [select name , Outlet_Category_Id__c,Id from  Outlet_Category__c
                                              where Outlet_Category_Id__c in: oname]; 
        
        for(Outlet_Category__c otlt: oCategory){
        	outletCategoryMap.put(otlt.Outlet_Category_Id__c,otlt.Id);
        }
        return outletCategoryMap;
    }
   
    //Get State
    public  Map<String,Id> getStateMap (List<String> stateId){
    	List<State__c> stt = [select State_ID__c,name from State__c
                             where State_ID__c in: stateId]; 
                
     	for(State__c st: stt ){
     		stateMap.put(st.State_ID__c,st.Id);
        }
        return stateMap;
    }
   
    //Get state abbrv based on region Id   
    public  Map<String,String> getRegionStateMap (List<String> regionId){      
    	Map<String, String> sttMap = new Map<String, String>();
       
        List<State__c> stt = [select State_ID__c,name,State_Abbr__c,Region_ID__c from State__c
                             where Region_ID__c in: regionId];
        for(State__c st: stt ){
        	sttMap.put(st.Region_ID__c,st.State_Abbr__c);
       	}
       	return sttMap;
    }
    
    //Get Brand Name
    public  Map<String,Id> getBrandMap (List<String> brndId){
		List<Brand__c> brnd= [select Brand_ID__c,Id from Brand__c
                             where Brand_ID__c in: brndId]; 
                
     	for(Brand__c brd: brnd){
        	brandMap.put(brd.Brand_ID__c,brd.Id);
       	}
     
      	return brandMap;
    }
    
    //Get Product Map
    public  Map<String,Id> getProductMap (List<String> prdId){
    	List<Product__c> prd = [select Product_ID__c,Id from Product__c
                                where Product_ID__c in: prdId]; 
                
     	for(Product__c prdct: prd){
     		productMap.put(prdct.Product_ID__c,prdct.Id);
        }
     
      	return productMap;
   	}   
   
   	//get PromotionProductPricingMap
   	public Map<Id,Pricing__c> getPromotionProductPricingMap(List<Id> prdctId){
   	
   		List<PromotionProduct__c> prdct             =   [select Product__c from PromotionProduct__c where Id in:prdctId];
   	  	List<Pricing__c> pricing                    =   [select Id,Wholesaler_Price__c,Estimated_Discount__c,Maximum_Discount__c,Product__c 
   	                                                   from Pricing__c 
   	                                                   where Start_Date__c <=:Date.today() and End_Date__c >=:Date.today()];
   	                                  
   		Map<Id, Pricing__c> prodctPricingMap        =    new Map<Id, Pricing__c>();
      	Map<Id,Pricing__c>  promotionPricingMap     =    new Map<Id, Pricing__c>();
      
      	for(Pricing__c pric :pricing){
      		prodctPricingMap.put(pric.Product__c, pric);
      	}
   	
   		//Create PromotionProduct Pricing Map
   	 	for(PromotionProduct__c prmprdct : prdct){   	 		
	   	 	if(prodctPricingMap.containsKey(prmprdct.Product__c)){
	   	 		promotionPricingMap.put(prmprdct.Id, prodctPricingMap.get(prmprdct.Product__c));   	 		
   	 		}
	  	}
   		return promotionPricingMap;   	
   	}
   	
    //Get Promoted Range Map
    public  Map<String,Promoted_Range__c> getPromotedRangeMap (List<String> promotionId){
    	List<Promoted_Range__c> prd   = [select Promotion_Range_ID__c,PromotedBrandId__c,Id from Promoted_Range__c
                                        where Promotion_Range_ID__c in: promotionId]; 
                
     	for(Promoted_Range__c range: prd){
        	promotedRangeMap.put(range.Promotion_Range_ID__c,range);
        }
        return promotedRangeMap;
   	}
  
  
  //GET PROMOTED RANGE PRODUCT Map   
	public  Map<String, List<Product__c>> getIdProductListMap(List<String> unqId){   	
		Map<String, List<Product__c>> idPrdctListMap = new Map<String, List<Product__c>>();
	   	List<Product__c> prdctList  =  [select Id,ProductBrandId__c ,Product_ID__c ,name, PromotedRangeID__c 
	   	                                from Product__c 
	  	 	                            where PromotedRangeID__c in:unqId];
	  	 	                                
	    for(Promoted_Range__c rang: promotedRangeMap.values()){	  	 	
	  		List<Product__c> plist  = new List<Product__c>();		  	 	
	  	 	for(Product__c prd : prdctList){	  	 		
	  	 		if(rang.Promotion_Range_ID__c == prd.PromotedRangeID__c){	  	 			
	  	 			plist.add(prd);
	  	 		}	  	 		
	  	 	}	  	 	
	  	  	idPrdctListMap.put(rang.Promotion_Range_ID__c, plist);		   	
	   	}	   
	   	return idPrdctListMap;
 	}
 
 	public List<PromotionProduct__c> getPromotionProduct(List<String> promotionId){
 	
	   List<Promotion__c> prprd = [select Id,(select Id from PromotionProducts__r),name from Promotion__c where name in :promotionId];	 	 
	   List<PromotionProduct__c> promotionList  =  new List<PromotionProduct__c>(); 
	 		 
	    for(Promotion__c prm: prprd){	      
	 		if(prm.PromotionProducts__r.size()>0){
	 			promotionList.addAll(prm.PromotionProducts__r);
	 		}
	 	}
	 	return promotionList;
 	} 
 
    //Get Outlet SubType Id Map
   public  Map<String,Outlet_Sub_Type__c> getOutletSubTypeMap (List<String> subId){      
        Map<String,Outlet_Sub_Type__c> outLetMap = new Map<String,Outlet_Sub_Type__c>();
       
       	List<Outlet_Sub_Type__c> stype   = [select Outlet_Type_Id__c,Outlet_Type__c,Id ,name from Outlet_Sub_Type__c
                                           where name in: subId];             
     	for(Outlet_Sub_Type__c subType: stype){
        	outLetMap.put(subType.name,subType);
       	}
       	return outLetMap;
   }
   
   
    //Get OutletType Id Map
   	public  Map<String,Outlet_Type__c> getOutletIdMap (List<String> outLetId){      
    	Map<String,Outlet_Type__c> outLetMap = new Map<String,Outlet_Type__c>();       
       	List<Outlet_Type__c> stype   = [select name,Id from Outlet_Type__c
                                           where name in: outLetId]; 
            
     	for(Outlet_Type__c outLetType: stype){        
          	outLetMap.put(outLetType.name,outLetType);      
     	}
     
      	return outLetMap;
   	}
   	
   //Get PromotedType
	public  Map<String,String>  getPromotedTypeIdMap (List<String> typeId){      
       	Map<String,String> prmtionTypeMap = new Map<String,String>();
       
       	List<Promotion_Type__c> prmList  = [select name,Promotion_Type_Desc__c    
                                             from  Promotion_Type__c
                                             where name in : typeId]; 
     	for(Promotion_Type__c prmType:prmList){
        	prmtionTypeMap.put(prmType.name,prmType.Promotion_Type_Desc__c);     
     	}
     
      	return prmtionTypeMap;
   	}
   	
   	//Get WholeSalerBannerGroup Map 
   	public  Map<String,Id>  getWholeSalerBannerGroupMap (List<String> wbgId){
      
    	Map<String,String> wbGroupMap    = new Map<String,String>();
       
       	List<Wholesaler_Banner_Group__c> groupList  = [select name,Id    
                                                    from  Wholesaler_Banner_Group__c
                                                    where name in : wbgId];
        for(Wholesaler_Banner_Group__c wbGroup:groupList){
        	wbGroupMap.put(wbGroup.name,wbGroup.Id);
       	}
       	return wbGroupMap;
   	}
   	
    //Get Spend Type
    public  Map<String,String>  getSpendTypeIdMap (List<String> typeId){
      
    	Map<String,String> spendTypeMap = new Map<String,String>();
       
       	List<Spend_Type__c> typeList  =    [select name,Spend_Type_Desc__c    
                                             from  Spend_Type__c
                                             where name in : typeId];
        for(Spend_Type__c spnType:typeList){
        	spendTypeMap.put(spnType.name,spnType.Spend_Type_Desc__c);
        }
     
      	return spendTypeMap;
   	}
   	
   	//Get Region
   	public  Map<String,Region__c>  getRegionIdMap (List<String> regionId){
      
       	Map<String,Region__c> regionIdMap = new Map<String,Region__c>();
       
       	List<Region__c> regionList   =    [select Id,Region_ID__c,Region_Abbr__c    
                                             from  Region__c
                                             where Region_ID__c in : regionId];
    	for(Region__c rgn:regionList){
    		regionIdMap.put(rgn.Region_ID__c,rgn);
        }  
     
      	return regionIdMap;
   	}
   	
	//Get Promotion Product
	public  Map<String,String>  getPromotionProductMap (List<String> ppId){      
       	Map<String,String> promotionProductMap = new Map<String,String>();       
       	List<Promotion__c> prmPrdct    =    [select Id,name    
                                            from  Promotion__c
                                            where name in : ppId];       
     	for(Promotion__c pp:prmPrdct){
         	promotionProductMap.put(pp.name,pp.Id);
     	}  
     
      	return promotionProductMap;  
   	} 
      
   	//Get Whole
   	public Map<String,String> getWholeSalerGroupProductMap(Set<String> prdctList, Set<String> wholeSalerList){
   	
	   	Map<String,String> groupProuctMap  =  new Map<String, String>();
	   	
	   	/*
	   	 * Fetch WholesalerGroup_Product in ascending order of createdDate 
	   	 * so that latest record is added to Map after iteration through all records
	     */
	   	List<Wholesaler_Group_Product__c> prdcList = [SELECT Wholesaler_Product_Code__c ,Product_ID__c,Wholesaler_Group_ID__c
	   	                                              FROM Wholesaler_Group_Product__c
	   	                                              WHERE Product_ID__c IN :prdctList
	   	                                              AND Wholesaler_Group_ID__c IN:wholeSalerList 
	   												  ORDER BY LastModifiedDate ASC];
	   	
	   	for(Wholesaler_Group_Product__c prdct : prdcList){
	   		groupProuctMap.put(prdct.Product_ID__c+':'+prdct.Wholesaler_Group_ID__c,prdct.Wholesaler_Product_Code__c);
	   	}
	   
	   	System.debug('Map '+groupProuctMap);
	   	return groupProuctMap;
   	}
   	
  	//Get Outlet
  	public Map<String,Outlet__c> getIdOutletMap(set<String> outletId){
   	
   		Map<String,Outlet__c> OutletMap              =  new Map<String, Outlet__c>();
   	  
   	  	List<Outlet__c> outletList                   = [select name,Address_Line_1__c,Address_Line_2__c,ASM_User_ID__c,Licence_Class__c,
   	                                                 Licence_Number__c,Licence_Type_ID__c,LMAA_Code__c,New_Liquor_Licence_Number__c,
   	                                                 Outlet_Category_Id__c,Outlet_Name__c,Post_Code__c,State_ID__c,Suburb__c,Tele_Sales_User_ID__c
   	                                                 from Outlet__c
   	                                                 where name in:outletId];
   	    for(Outlet__c otlt : outletList){
   	    	OutletMap.put(otlt.name,otlt);
   	   	}
   	   	return OutletMap;
   	}
   
   	//Get Updatable banner group outlet   
   	public List<Banner_Group_Outlet__c> getBannerGroupOutlet (List<Id> accList){
   	
   		List<Banner_Group_Outlet__c> bntList  =  new List<Banner_Group_Outlet__c>();
   	 
   	 	List<account>  acntList  = [select Banner_Group_ID__c ,(select Banner_Group_ID__c from Banner_Group_Outlets1__r) from account];
   	
   		for(account ac: acntList){
   			List<Banner_Group_Outlet__c>  groupOutlet = ac.Banner_Group_Outlets1__r;
   			for(Banner_Group_Outlet__c outlet : groupOutlet){
   				outlet.Banner_Group_ID__c = ac.Banner_Group_ID__c;
   				bntList.add(outlet);
   			}
   		}
   	  	return bntList;   	
   	}
   
   	//get account banner group outlet Map   
    public Map<String,  List<Banner_Group_Outlet__c>> getbgoAccountMap (set<String> accList){
    
    	Map<String, List<Banner_Group_Outlet__c>> bgoMap = new  Map<String, List<Banner_Group_Outlet__c>>();
    	List<account>  acntList  = [select Banner_Group_ID__c ,(select Banner_Group_ID__c from Banner_Group_Outlets__r) 
   	                             from account where Id in:accList];
   	
   	 	for(account ac: acntList){
   		   		
   			List<Banner_Group_Outlet__c>  groupOutlet = ac.Banner_Group_Outlets__r;
   		  	System.debug('bgomap....'+groupOutlet+'finl acc....'+ac.Id);
   			bgoMap.put(ac.Id, groupOutlet);
   		}
   		return bgoMap;
   	}
}