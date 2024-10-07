trigger OpportunityTrigger on Opportunity (after update,before delete) {
    
    if(Trigger.isUpdate && Trigger.isAfter){
        OpportunityTriggerHelper.updatePlannedSales();
        OpportunityTriggerHelper.updateCarStatusWhenOpportunityStageChanged(Trigger.new,Trigger.oldMap);
    }else if(Trigger.isDelete && Trigger.isBefore){
        OpportunityTriggerHelper.deleteOpportunity();
    }

}