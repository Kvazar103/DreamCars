trigger CarTrigger on Product2 (before insert,after update) {
    
    Trigger_Control__c triggerSetting=Trigger_Control__c.getInstance('MakeActive');  
    
    if((triggerSetting!=null) && (triggerSetting.isActive__c)){
        try{
            if(Schema.sObjectType.Product2.isAccessible()){//if user have access to object and fields
                if(Trigger.isAfter && Trigger.isUpdate){
                    CarTriggerHelper.updateCar(Trigger.oldMap);
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
        system.debug('Trigger is off');
    }
    
}