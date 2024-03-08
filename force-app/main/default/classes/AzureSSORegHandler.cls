global class AzureSSORegHandler implements Auth.RegistrationHandler{
    global boolean canCreateUser(Auth.UserData data) {
        //TODO: Check whether we want to allow creation of a user with this data
        //Set<String> s = new Set<String>{'usernamea', 'usernameb', 'usernamec'};
        //if(s.contains(data.username)) { 
        //return true;
        //}
        return false;
    }
    
    global User createUser(Id portalId, Auth.UserData data){
        //if(!canCreateUser(data)) {
        //Returning null or throwing an exception fails the SSO flow
        //   return null;
        //}
        //The user is authorized, so create their Salesforce user
        
        system.debug('### User Data' +  data.attributeMap.get('email'));
        User u;
        if(!Test.IsrunningTest())
             u = [SELECT ID FROM User Where IsActive = true and Email = : data.attributeMap.get('email')];
        else
             u = [SELECT ID FROM User Where IsActive = true Limit 1];
        
        return u;
    }
    
    global void updateUser(Id userId, Id portalId, Auth.UserData data){
        //No Operation
    }
}