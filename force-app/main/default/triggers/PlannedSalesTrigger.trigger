trigger PlannedSalesTrigger on Planned_Sales__c (after insert,after update,before update) {
    
    if(Trigger.isInsert && Trigger.isAfter){
        PlannedSalesTriggerHelper.createPlannedSales();
    }else if(Trigger.isUpdate && Trigger.isBefore){ // if isAfter than will be System.FinalException: Record is read-only 
        PlannedSalesTriggerHelper.updatePlannedSales(Trigger.new,Trigger.oldMap);
    }
    
}