trigger ContentDocumetLinkTrigger on ContentDocumentLink (after insert) {
    
    Trigger_Control__c triggerSetting=Trigger_Control__c.getInstance('ContentDocumentLinkTriggerSettings'); 
    
    if((triggerSetting!=null)&&(triggerSetting.isDisabled__c==false)){
        if(Schema.sObjectType.ContentDocumentLink.isAccessible()){
            if(Trigger.isAfter && Trigger.isInsert){
                ContentDocumentLinkTriggerHelper.processInsertedContentDocumentLinks();
                ContentDocumentLinkTriggerHelper.sendEmailWithPdfAfterOrderCreated();
            } 
        }else{
            system.debug('The user doesnt have access to this object');
            Trigger.new[0].addError('The user doesnt have access to this object');
        }       
    }else{
        system.debug('trigger is off');
        Trigger.new[0].addError('Trigger is off');
    }
}