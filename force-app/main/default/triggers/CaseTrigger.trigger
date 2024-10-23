trigger CaseTrigger on Case (after insert,before insert) {
    
    Trigger_Control__c triggerSetting=Trigger_Control__c.getInstance('CaseTriggerSettings');  
    
    if((triggerSetting!=null)&&(triggerSetting.isDisabled__c==false)){
        if(Schema.sObjectType.Case.isAccessible()){
            if(Trigger.isInsert && Trigger.isAfter){
                CaseTriggerHelper.createCarServiceIfCarVinNumberMatching();
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