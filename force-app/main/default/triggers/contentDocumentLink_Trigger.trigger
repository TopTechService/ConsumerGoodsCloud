trigger contentDocumentLink_Trigger on ContentDocumentLink (after insert, after delete) {
    
    if(trigger.isInsert){
     contentDocument_handler.updateNumberFile((list<SObject>) trigger.new, true);
    }
    
    if(trigger.isdelete){
     contentDocument_handler.updateNumberFile((list<SObject>) trigger.old, false);
    }
    
}