// author   : Carnac group - Yoann Beurier
// purpose  : runs from the File trigger. Used to count the Number of Files on Tasks / Events
// criteria : on before Add / Delete
// date     : v1 - 11/10/2018 - created
// 

public class contentDocument_handler {
    
    public static void updateNumberFile(List<sObject> triggerNew, boolean add1toCount){
        
        // Get the Id structure of the Event
        Schema.DescribeSObjectResult evt = Event.sObjectType.getDescribe();
        String evtKeyPrefix = evt.getKeyPrefix();
        List<Event> evtToUpdate = new List<Event>();
        
        // Get the Id structure of the Task
        Schema.DescribeSObjectResult tsk = Task.sObjectType.getDescribe();
        String tskKeyPrefix = tsk.getKeyPrefix();
        List<Task> tskToUpdate = new List<Task>();
        
        String QueryCount; 
        
        Map<Id, integer> mapevtNumberFiles = new Map<Id, integer>();
        Map<Id, integer> maptskNumberFiles = new Map<Id, integer>();
        
        Set<Id> setLinkedEntityId = new Set<Id>();
        List<ContentDocumentLink> numberOfFiles = new List<ContentDocumentLink>();
        
        for(ContentDocumentLink a : (List<ContentDocumentLink>)triggerNew)
        {
            setLinkedEntityId.add(a.LinkedEntityId);
        }
        
        numberOfFiles = [SELECT Id, LinkedEntityId from ContentDocumentLink WHERE LinkedEntityId = :setLinkedEntityId];
        
        for(ContentDocumentLink a : (List<ContentDocumentLink>)triggerNew){
            
            integer count = 0;
            for(ContentDocumentLink nbr :numberOfFiles)
            {
                if(a.LinkedEntityId == nbr.LinkedEntityId)
                {
                        count = count+1;
                }
                
            }
            system.debug('the count is '+ count);
            
            
            // If files is linked to an event
            if(evtKeyPrefix == String.valueOf(a.LinkedEntityId).left(3)){
                
                if(!mapevtNumberFiles.containsKey(a.LinkedEntityId))
                    mapevtNumberFiles.put(a.LinkedEntityId,count);
                else
                    if(mapevtNumberFiles.get(a.LinkedEntityId) < count)
                    mapevtNumberFiles.put(a.LinkedEntityId,count);                
            }
            
            // If files is linked to a task
            if(tskKeyPrefix == String.valueOf(a.LinkedEntityId).left(3)){
                
                if(!maptskNumberFiles.containsKey(a.LinkedEntityId))
                    maptskNumberFiles.put(a.LinkedEntityId,count);
                else
                    if(maptskNumberFiles.get(a.LinkedEntityId) < count)
                    maptskNumberFiles.put(a.LinkedEntityId,count);                
            }
        }
        
        //get list of Events
        if(mapevtNumberFiles.size()>0)
            evtToUpdate = [Select Id, Number_of_Attachment_s__c from Event where Id =: mapevtNumberFiles.keySet()];
        System.debug('mapevtNumberFiles ' + mapevtNumberFiles);
        
        //get list of Tasks
        if(maptskNumberFiles.size()>0)
            tskToUpdate = [Select Id, Number_of_Attachment_s__c from Task where Id =: maptskNumberFiles.keySet()];
        System.debug('maptskNumberFiles ' + maptskNumberFiles);
        
        //Update event Number of Files
        for(Event evnt : evtToUpdate)
            evnt.Number_of_Attachment_s__c = mapevtNumberFiles.get(evnt.Id);
        
        //Update Task Number of Files
        for(Task t : tskToUpdate)
            t.Number_of_Attachment_s__c = maptskNumberFiles.get(t.Id);
        
        if(evtToUpdate.size()>0)
            upsert evtToUpdate;
        
        if(tskToUpdate.size()>0)
            upsert tskToUpdate;
        
    }
    
}