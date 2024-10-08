public with sharing class CarTriggerHelper {
    
    public static void updateCar(Map<Id,Product2> oldCars){
        
        List<Product2> updatedCars=[SELECT Id,Car_Status__c,Condition__c,Name,reservedInOpportunity__c FROM Product2 WHERE Id IN:Trigger.new];
        
        Set<Id> findCarsId=new Set<Id>();
        List<Opportunity> opportunityToUpdate=new List<Opportunity>();
        
        for(Product2 car:updatedCars){
            Product2 oldCar=oldCars.get(car.Id);
            
            if(oldCar!=null){
                if(car.Car_Status__c!=oldCar.Car_Status__c && car.Car_Status__c=='Available'){
                    findCarsId.add(car.Id);
                }
            }
        }
        if(!findCarsId.isEmpty()){
            List<OpportunityLineItem> oppLineItems=[SELECT Id,Product2Id,Product2.Condition__c,Product2.Car_Status__c,Product2.reservedInOpportunity__c,
                                                           Opportunity.StageName,Opportunity.showWarningMessage__c 
                                       FROM OpportunityLineItem WHERE Opportunity.showWarningMessage__c=true AND  Product2Id IN:findCarsId];
            if(!oppLineItems.isEmpty()){
            for(OpportunityLineItem oppLineItem:oppLineItems){
                oppLineItem.Opportunity.showWarningMessage__c=false;
                opportunityToUpdate.add(oppLineItem.Opportunity);
            }
            }
        }

        if(!opportunityToUpdate.isEmpty()){
            update opportunityToUpdate;
        }
        
    }

}