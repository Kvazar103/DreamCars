trigger CarTrigger on Product2 (before insert,after update) {
    
    Trigger_Control__c triggerSetting=Trigger_Control__c.getInstance('CarTriggerSettings');  
    
    if((triggerSetting!=null)&&(triggerSetting.isDisabled__c==false)){
        if(Schema.sObjectType.Product2.isAccessible()){//if user have access to object and fields
            if(Trigger.isAfter && Trigger.isUpdate){
                CarTriggerHelper.updateCar();
            }  
        }else{
            system.debug('The user doesnt have access to this object');
            Trigger.new[0].addError('The user doesnt have access to this object');
        }
        
    }else{
        system.debug('Trigger is off');
        Trigger.new[0].addError('Trigger is off');
    }
    
}