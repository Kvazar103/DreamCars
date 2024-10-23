trigger OpportunityTrigger on Opportunity (after update,before delete) {
    
    Trigger_Control__c triggerSetting=Trigger_Control__c.getInstance('OpportunityTriggerSettings');  
    
    if((triggerSetting!=null)&&(triggerSetting.isDisabled__c==false)){
        if(Schema.sObjectType.Opportunity.isAccessible()){ //if user have access to object and fields
            if(Trigger.isUpdate && Trigger.isAfter){
                //OpportunityTriggerHelper.updatePlannedSalesWhenOpportunityClosedWon();
                OpportunityTriggerHelper.updatePlannedSalesWhenOpportunityClosedWonOrDeleted(Trigger.new,False);
                OpportunityTriggerHelper.updateCarStatusWhenOpportunityStageChanged();
            }else if(Trigger.isDelete && Trigger.isBefore){
                //OpportunityTriggerHelper.deleteOpportunity();
                OpportunityTriggerHelper.updatePlannedSalesWhenOpportunityClosedWonOrDeleted(Trigger.old,True);
            }
        }else{
            system.debug('The user doesnt have access to this object');
            Trigger.new[0].addError('The user doesnt have access to this object');

        }
    }else {
        system.debug('Trigger is off');
        Trigger.new[0].addError('Trigger is off');
    }
    
}