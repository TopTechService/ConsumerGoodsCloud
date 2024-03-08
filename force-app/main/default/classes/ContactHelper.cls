/**
 * @author    : Created by Geeta Kushwaha on 26 June, 2013  geeta.kushwaha@arxxus.com
 * @Purpose   : Controller for component ContactHelper
 * @Criteria  : 
 * @Modified  : Geeta Kushwaha on 26 June, 2013 geeta.kushwaha@arxxus.com
 */
public class ContactHelper {
    
    public Id accId {get; set;}
    
    private list <Contact> contactNames;
    
    public list <Contact> getContactName(){
        
        contactNames = [select FirstName, LastName 
                        from Contact
                        where AccountId =: accId];
        
        return contactNames;
        
    }
    
    public ContactHelper() {
    	
    	contactNames = new list <Contact>();
    	
    }
        
    
}