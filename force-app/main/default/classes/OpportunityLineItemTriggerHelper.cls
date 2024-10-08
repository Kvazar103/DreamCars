public with sharing class OpportunityLineItemTriggerHelper {
    
    public static void checkCarStatusBeforeInsert(){
        
        List<OpportunityLineItem> newOpportunityLineItems=[SELECT Id,Product2Id,Product2.Condition__c,Product2.Car_Status__c,Product2.reservedInOpportunity__c,
                                                           Opportunity.StageName,Opportunity.showWarningMessage__c 
                                       FROM OpportunityLineItem WHERE Id IN:Trigger.new];
        
        List<Opportunity> opportunityToUpdate=new List<Opportunity>();
        Set<Id> productsId=new Set<Id>();
        
        for(OpportunityLineItem oli:newOpportunityLineItems){
            productsId.add(oli.Product2Id);
        }
        
        if(!newOpportunityLineItems.isEmpty()){
                for(OpportunityLineItem oli:newOpportunityLineItems){
                    if((oli.Product2.Car_Status__c=='Reserved' || oli.Product2.Car_Status__c=='Sold')&& oli.Product2.reservedInOpportunity__c==true ){
                        oli.Opportunity.showWarningMessage__c=true;
                        opportunityToUpdate.add(oli.Opportunity);
                    }
                }
        }
        
        if(!opportunityToUpdate.isEmpty()){
            update opportunityToUpdate;
        }
    }
    
    public static void deleteOpportunityLineItem(){
        List<OpportunityLineItem> deletedOpportunityLineItems=[SELECT Id,Product2Id,Product2.Condition__c,Product2.Car_Status__c,Product2.reservedInOpportunity__c,
                                                           Opportunity.StageName,Opportunity.showWarningMessage__c 
                                       FROM OpportunityLineItem WHERE Id IN:Trigger.old];
        
        Set<Id> productIdOfDeleteOppLineItems=new Set<Id>();
        List<Opportunity> opportunityToUpdate=new List<Opportunity>();
        
        if(!deletedOpportunityLineItems.isEmpty()){
            for(OpportunityLineItem oli:deletedOpportunityLineItems){
                productIdOfDeleteOppLineItems.add(oli.Product2Id);
            }   
                if(!deletedOpportunityLineItems.isEmpty()){
                    for(OpportunityLineItem oli:deletedOpportunityLineItems){
                        system.debug(oli);
                        if((oli.Product2.Car_Status__c=='Sold' || oli.Product2.Car_Status__c=='Reserved') 
                           && (oli.Opportunity.showWarningMessage__c==true) && oli.Product2.reservedInOpportunity__c==true){
                            oli.Opportunity.showWarningMessage__c =false;
                            opportunityToUpdate.add(oli.Opportunity);
                        }
                    }
                }
  
        }
        if(!opportunityToUpdate.isEmpty()){
            update opportunityToUpdate;
        }
        
    }

}