trigger OpportunityLineItemTrigger on OpportunityLineItem (before delete,after insert,after update) {
    
   Trigger_Control__c triggerSetting=Trigger_Control__c.getInstance('MakeActive');  
    
    if((triggerSetting!=null) && (triggerSetting.isActive__c)){
        try{
            if(Schema.sObjectType.OpportunityLineItem.isAccessible()){//if user have access to object and fields
                if(Trigger.isAfter && Trigger.isInsert){
                    OpportunityLineItemTriggerHelper.checkCarStatusBeforeInsert();
                }else if(Trigger.isDelete && Trigger.isBefore){
                    OpportunityLineItemTriggerHelper.deleteOpportunityLineItem();
                }
            }else{
                system.debug('The user doesnt have access to this object');
            }
        }catch(Exception e){
            //transcation control
            system.debug('Error '+e.getMessage());
            throw e; //cancel all changes in transaction  
        }
    }else{
        system.debug('trigger is off');
    }
}