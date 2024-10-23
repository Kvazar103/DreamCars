trigger OpportunityLineItemTrigger on OpportunityLineItem (before delete,after insert,after update) {
    
    Trigger_Control__c triggerSetting=Trigger_Control__c.getInstance('OpportunityLineItemTriggerSettings');  
    
    if((triggerSetting!=null)&&(triggerSetting.isDisabled__c==false)){
        
        if(Schema.sObjectType.OpportunityLineItem.isAccessible()){//if user have access to object and fields
            if(Trigger.isAfter && Trigger.isInsert){
                OpportunityLineItemTriggerHelper.checkCarStatusBeforeInsert();
            }else if(Trigger.isDelete && Trigger.isBefore){
                OpportunityLineItemTriggerHelper.deleteOpportunityLineItem();
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