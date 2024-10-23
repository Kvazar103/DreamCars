/**
 * @description       : 
 * @author            : Svyatoslav Andrushchak
 * @group             : 
 * @last modified on  : 10-18-2024
 * @last modified by  : Svyatoslav Andrushchak
**/
trigger PlannedSalesTrigger on Planned_Sales__c (after insert,after update,before update) {
    
    
    Trigger_Control__c triggerSetting=Trigger_Control__c.getInstance('PlannedSalesTriggerSettings');  
    
    if((triggerSetting!=null)&&(triggerSetting.isDisabled__c==false)){
            if(Schema.sObjectType.Planned_Sales__c.isAccessible()){//if user have access to object and fields
                if(Trigger.isInsert && Trigger.isAfter){
                    //PlannedSalesTriggerHelper.createPlannedSales();
                    PlannedSalesTriggerHelper.createOrUpdatePlannedSales();
                }
                if(Trigger.isUpdate && Trigger.isBefore){ // if isAfter than will be System.FinalException: Record is read-only 
                    //PlannedSalesTriggerHelper.updatePlannedSales(Trigger.new,Trigger.oldMap);
                    system.debug('update');
                    PlannedSalesTriggerHelper.createOrUpdatePlannedSales();
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