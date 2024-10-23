trigger OrderTrigger on Order (after insert) {
    
    if(Trigger.isAfter && Trigger.isInsert){
        //OrderTriggerHelper.sendEmailWhenOrderCreated();
    }

}