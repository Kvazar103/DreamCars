trigger PlannedSalesTrigger on Planned_Sales__c (after insert,after update,before update) {
    
    
    Trigger_Control__c triggerSetting=Trigger_Control__c.getInstance('MakeActive');  
    
    if((triggerSetting!=null) && (triggerSetting.isActive__c)){
        try{
            if(Schema.sObjectType.Planned_Sales__c.isAccessible()){//if user have access to object and fields
                if(Trigger.isInsert && Trigger.isAfter){
                    PlannedSalesTriggerHelper.createPlannedSales();
                }
                if(Trigger.isUpdate && Trigger.isBefore){ // if isAfter than will be System.FinalException: Record is read-only 
                    PlannedSalesTriggerHelper.updatePlannedSales(Trigger.new,Trigger.oldMap);
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