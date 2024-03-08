@isTest(SeeAllData=true)
public class KAReportCartonCountTest {
    
    
    static testMethod void testReport(){    	
        KAReportCartonCount CartonCount = new KAReportCartonCount();    	
        PageReference pageRef = Page.KAreportCartonCount;   
        
        CartonCount.createReport();
        
        List<Id> bgid = new List<Id>();
        String nsw = 'NSW';
        List<Sale_MySales__c> acct = [Select Banner_Group__c from Sale_MySales__c where Banner_Group__c <> null and Outlet__r.State__r.Region__c =:nsw order by LastModifiedDate desc limit 1];
        for(Sale_MySales__c a :acct)
            bgid.add(a.Banner_Group__c);
        
        KAReportCartonCount.calculateColumn1(System.Today()-365, System.Today()-365, 'NSW', bgid, false);
        KAReportCartonCount.calculateColumn1(System.Today()-365, System.Today()-365, 'NSW', bgid, true);
        
        KAReportCartonCount.calculateColumn2(System.Today()-365, System.Today()-365, 'NSW', bgid, true);
        KAReportCartonCount.calculateColumn6(System.Today()-365, System.Today()-365, 'NSW', bgid, true);
        KAReportCartonCount.calculateColumn7(System.Today()-365, System.Today()-365, 'NSW', bgid, true);
        KAReportCartonCount.calculateColumn11( System.Today()-365, 'NSW', bgid, true);
        KAReportCartonCount.calculateColumn12( System.Today()-365, 'NSW', bgid, true);
        KAReportCartonCount.calculateColumn15( System.Today()-365, 'NSW', bgid, true);
        KAReportCartonCount.calculateColumn16( System.Today()-365, 'NSW', bgid, true);
        KAReportCartonCount.calculateColumn23( System.Today()-365, 'NSW', bgid, true);
        KAReportCartonCount.calculateColumn24( System.Today()-365, 'NSW', bgid, true);
        KAReportCartonCount.calculateColumn27( System.Today()-365, 'NSW', bgid, true);
        KAReportCartonCount.calculateColumn28( System.Today()-365, 'NSW', bgid, true);
        
        KAReportCartonCount.calculateColumn40( System.Today()-365, System.Today()-365, 'NSW', bgid, true);
        KAReportCartonCount.calculateColumn41( System.Today()-365, System.Today()-365, 'NSW', bgid, true);
        KAReportCartonCount.calculateColumn42( System.Today()-365, System.Today()-365, 'NSW', bgid, true);
        KAReportCartonCount.calculateColumn43( System.Today()-365, System.Today()-365, 'NSW', bgid, true);
        KAReportCartonCount.calculateColumn44( System.Today()-365, System.Today()-365, 'NSW', bgid, true);
        KAReportCartonCount.calculateColumn45( System.Today()-365, System.Today()-365, 'NSW', bgid, true);
        KAReportCartonCount.calculateColumn46( System.Today()-365, System.Today()-365, 'NSW', bgid, true);
        KAReportCartonCount.calculateColumn47( System.Today()-365, System.Today()-365, 'NSW', bgid, true);
        KAReportCartonCount.calculateColumn48( System.Today()-365, System.Today()-365, 'NSW', bgid, true);
        
        KAReportCartonCount.calculateColumn49( System.Today()-365, System.Today()-365, 'NSW', bgid, true);
        KAReportCartonCount.calculateColumn50( System.Today()-365, System.Today()-365, 'NSW', bgid, true);
        KAReportCartonCount.calculateColumn51( System.Today()-365, System.Today()-365, 'NSW', bgid, true);
        
        CartonCount.getRegionList();
        CartonCount.getBannerGroup();
            

    }
    
    
    
}