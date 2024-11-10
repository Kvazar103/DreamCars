public with sharing class CarTriggerHelper {
    
    public static void updateCar(){
        
        Map<Id,Product2> oldCars=(Map<Id,Product2>) Trigger.oldMap;
                
        List<Product2> updatedCars=(List<Product2>) Trigger.new;
        
        Set<Id> findCarsId=new Set<Id>();
        Map<Id,Opportunity> opportunityToUpdate=new Map<Id,Opportunity>();
        
        for(Product2 car:updatedCars){
            Product2 oldCar=oldCars.get(car.Id);
            
            if(car.Car_Status__c!=oldCar.Car_Status__c && car.Car_Status__c=='Available'){
                findCarsId.add(car.Id);
            }
        }
        if(!findCarsId.isEmpty()){
            List<OpportunityLineItem> oppLineItems=[SELECT Id,Product2Id,Product2.Condition__c,Product2.Car_Status__c,Product2.reservedInOpportunity__c,
                                                    Opportunity.StageName,Opportunity.showWarningMessage__c 
                                                    FROM OpportunityLineItem WHERE Opportunity.showWarningMessage__c=true AND  Product2Id IN:findCarsId];
            if(!oppLineItems.isEmpty()){
                for(OpportunityLineItem oppLineItem:oppLineItems){
                    oppLineItem.Opportunity.showWarningMessage__c=false;
                    opportunityToUpdate.put(oppLineItem.Opportunity.Id,oppLineItem.Opportunity);
                }
            }
        }
        
        if(!opportunityToUpdate.isEmpty()){
            update opportunityToUpdate.values();
        }
        
    }
    
}