public with sharing class OpportunityLineItemTriggerHelper {
    
    public static void checkCarStatusBeforeInsert(){
        
        List<OpportunityLineItem> newOpportunityLineItems=[SELECT Id,Product2Id,Product2.Condition__c,Product2.Car_Status__c,Product2.reservedInOpportunity__c,
                                                           Opportunity.StageName,Opportunity.showWarningMessage__c 
                                                           FROM OpportunityLineItem WHERE Id IN:Trigger.new];
        
        //List<OpportunityLineItem> newOpportunityLineItems=(List<OpportunityLineItem>) Trigger.new;
        
        Map<Id,Opportunity> opportunityToUpdate=new Map<Id,Opportunity>();
        Set<Id> productsId=new Set<Id>();
        
        for(OpportunityLineItem oli:newOpportunityLineItems){
            productsId.add(oli.Product2Id);
        }
        
        for(OpportunityLineItem oli:newOpportunityLineItems){
            if((oli.Product2.Car_Status__c=='Reserved' || oli.Product2.Car_Status__c=='Sold')&& oli.Product2.reservedInOpportunity__c==true ){
                oli.Opportunity.showWarningMessage__c=true;
                opportunityToUpdate.put(oli.Opportunity.Id,oli.Opportunity);
            }
        }
        if(!opportunityToUpdate.isEmpty()){
            update opportunityToUpdate.values();
        }
    }
    
    public static void deleteOpportunityLineItem(){
        List<OpportunityLineItem> deletedOpportunityLineItems=[SELECT Id,Product2Id,Product2.Condition__c,Product2.Car_Status__c,Product2.reservedInOpportunity__c,
                                                               Opportunity.StageName,Opportunity.showWarningMessage__c 
                                                               FROM OpportunityLineItem WHERE Id IN:Trigger.old];
        
        //List<OpportunityLineItem> deletedOpportunityLineItems=(List<OpportunityLineItem>) Trigger.old;
        
        Set<Id> productIdOfDeleteOppLineItems=new Set<Id>();
        Map<Id,Opportunity> opportunityToUpdate=new Map<Id,Opportunity>();
        
        for(OpportunityLineItem oli:deletedOpportunityLineItems){
            productIdOfDeleteOppLineItems.add(oli.Product2Id);
        }   
        if(!deletedOpportunityLineItems.isEmpty()){
            for(OpportunityLineItem oli:deletedOpportunityLineItems){
                system.debug(oli);
                if((oli.Product2.Car_Status__c=='Sold' || oli.Product2.Car_Status__c=='Reserved') 
                   && (oli.Opportunity.showWarningMessage__c==true) && oli.Product2.reservedInOpportunity__c==true){
                       oli.Opportunity.showWarningMessage__c =false;
                       opportunityToUpdate.put(oli.Opportunity.Id,oli.Opportunity);
                   }
            }
        }
        
        if(!opportunityToUpdate.isEmpty()){
            update opportunityToUpdate.values();
        }
        
    }
    
}