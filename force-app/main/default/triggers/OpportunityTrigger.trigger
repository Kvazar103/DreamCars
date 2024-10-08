trigger OpportunityTrigger on Opportunity (after update,before delete) {
    
    Trigger_Control__c triggerSetting=Trigger_Control__c.getInstance('MakeActive');  
    
    if((triggerSetting!=null) && (triggerSetting.isActive__c)){
        
        try{
            if(Schema.sObjectType.Opportunity.isAccessible()){ //if user have access to object and fields
                if(Trigger.isUpdate && Trigger.isAfter){
                    OpportunityTriggerHelper.updatePlannedSalesWhenOpportunityClosedWon();
                    OpportunityTriggerHelper.updateCarStatusWhenOpportunityStageChanged(Trigger.oldMap);
                }else if(Trigger.isDelete && Trigger.isBefore){
                    OpportunityTriggerHelper.deleteOpportunity();
                }
            }else{
                system.debug('The user doesnt have access to this object');
            }
            
        }catch(Exception e){
            //transcation control
            system.debug('Error '+e.getMessage());
            throw e; //cancel all changes in transaction  
        } 
    }else {
        system.debug('Trigger is off');
    }
    
}