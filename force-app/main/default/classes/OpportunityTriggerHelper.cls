/**
* @description       : 
* @author            : Nazar Voinarovych
* @group             : 
* @last modified on  : 10-07-2024
* @last modified by  : Nazar Voinarovych
**/
public with sharing class OpportunityTriggerHelper {
    
    public static void updatePlannedSalesWhenOpportunityClosedWonOrDeleted(List<Opportunity> triggeredOpportunities,Boolean isDeleted){

        List<Opportunity> updatedOpportunities=[SELECT Id,CloseDate,StageName,Amount,(SELECT Id,Product2.Condition__c,UnitPrice FROM OpportunityLineItems) FROM Opportunity 
                                                WHERE Id IN :triggeredOpportunities];

        Map<Id,Opportunity> oldOpportunities=(Map<Id,Opportunity>)Trigger.oldMap;
        
        
        Set<Integer> month=new Set<Integer>();
        Set<Integer> year=new Set<Integer>();
        
        Map<String,Planned_Sales__c> plannedSales=new Map<String,Planned_Sales__c>();
        
        Map<Id,Planned_Sales__c> plannedSalesToUpdate=new Map<Id,Planned_Sales__c>();
        
        if(!updatedOpportunities.isEmpty()){
            for(Opportunity opportunity:updatedOpportunities){
                
                month.add(opportunity.CloseDate.month());
                year.add(opportunity.CloseDate.year());
                
            }
            
            if((!month.isEmpty()) && (!year.isEmpty())){
                for(Planned_Sales__c plannedSale:[SELECT Id,Year__c,Month__c,Car_Type__c,Total_Amount_Earned__c,Count_of_Cars_Sold__c 
                                                  FROM Planned_Sales__c 
                                                  WHERE Year__c IN:year
                                                  AND Month__c IN:month]){
                                                      
                                                      String key=plannedSale.Month__c+'_'+plannedSale.Year__c+'_'+plannedSale.Car_Type__c;
                                                      plannedSales.put(key,plannedSale); 
                                                  }
                
                if(!plannedSales.isEmpty()){
                    for(Opportunity opportunity:updatedOpportunities){
                        String key1=opportunity.CloseDate.month()+'_'+opportunity.CloseDate.year();
                        
                        for(OpportunityLineItem opp:opportunity.OpportunityLineItems){
                            String key2=key1+'_'+opp.Product2.Condition__c;
                            
                            if((opportunity.StageName=='Closed Won') && (plannedSales.containsKey(key2)) && (!isDeleted)){
                                Planned_Sales__c plannedSale=plannedSales.get(key2);
                                
                                plannedSale.Total_Amount_Earned__c+=opp.UnitPrice;
                                plannedSale.Count_of_Cars_Sold__c+=1;
                                plannedSalesToUpdate.put(plannedSale.Id,plannedSale);
                                
                            }else if((opportunity.StageName=='Closed Won') &&(plannedSales.containsKey(key2)) && isDeleted){
                                Planned_Sales__c plannedSale=plannedSales.get(key2);
                                
                                plannedSale.Count_of_Cars_Sold__c-=1;
                                plannedSale.Total_Amount_Earned__c-=opp.UnitPrice;
                                plannedSalesToUpdate.put(plannedSale.Id,plannedSale);
                                
                            }else if(opportunity.StageName!=oldOpportunities.get(opportunity.Id).StageName && 
                                     oldOpportunities.get(opportunity.Id).StageName=='Closed Won'){
                                         String keyOne=opportunity.CloseDate.month()+'_'+opportunity.CloseDate.year();
                                         
                                         for(OpportunityLineItem oli:opportunity.OpportunityLineItems){
                                             
                                             String keyTwo=keyOne+'_'+oli.Product2.Condition__c;
                                             if(plannedSales.containsKey(keyTwo)){
                                                 Planned_Sales__c plannedSale=plannedSales.get(keyTwo);
                                                 if(plannedSale!=null){
                                                     plannedSale.Total_Amount_Earned__c-=oli.UnitPrice;
                                                     plannedSale.Count_of_Cars_Sold__c-=1;
                                                     plannedSalesToUpdate.put(plannedSale.Id,plannedSale);
                                                 }
                                             }
                                             
                                         }
                                     }
                        }
                        
                    }
                    
                }
                if(!plannedSalesToUpdate.isEmpty()){
                    update plannedSalesToUpdate.values();
                }
            }
            
            
        }
    }
    
    public static void updateCarStatusWhenOpportunityStageChanged(){
        
        List<Opportunity> newOpportunities=[SELECT Id,CloseDate,StageName,Amount,(SELECT Id,Product2.Condition__c FROM OpportunityLineItems) 
                                            FROM Opportunity WHERE Id IN :Trigger.New];
        Map<Id,Product2> carsToUpdate=new Map<Id,Product2>();
        
        Id carSoldRecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Product2' AND Name = 'Sold' LIMIT 1].Id;
        
        
        Map<Id,Opportunity> oldOpportunities=(Map<Id, Opportunity>)Trigger.oldMap; //Trigger.oldMap have default Map<Id,SObject>
        
        Map<Id,Planned_Sales__c> plannedSalesToUpdateIfOpportunityClosed=new Map<Id,Planned_Sales__c>();
        Map<String,Planned_Sales__c> relatedPlannedSales=new Map<String,Planned_Sales__c>();
        
        Set<Integer> month=new Set<Integer>();
        Set<Integer> year=new Set<Integer>();
        
        if(!newOpportunities.isEmpty()){
            for(Opportunity newOpportunity:newOpportunities){
                month.add(newOpportunity.CloseDate.month());
                year.add(newOpportunity.CloseDate.year());
            }
            for(Planned_Sales__c plannedSale:[SELECT Id,Year__c,Month__c,Car_Type__c,Total_Amount_Earned__c,Count_of_Cars_Sold__c 
                                              FROM Planned_Sales__c 
                                              WHERE Year__c IN:year
                                              AND Month__c IN:month]){
                                                  
                                                  String key=plannedSale.Month__c+'_'+plannedSale.Year__c+'_'+plannedSale.Car_Type__c;                             
                                                  relatedPlannedSales.put(key,plannedSale);
                                                  
                                              }
            for(Opportunity newOpportunity:newOpportunities){
                
                Opportunity oldOpportunity=oldOpportunities.get(newOpportunity.Id);
                
                if(newOpportunity.StageName!=oldOpportunity.StageName && newOpportunity.StageName=='Contract Sent'){
                    
                    if(!newOpportunity.OpportunityLineItems.isEmpty()){
                        for(OpportunityLineItem oli:newOpportunity.OpportunityLineItems){ 
                            oli.Product2.Car_Status__c='Reserved';
                            carsToUpdate.put(oli.Product2.Id,oli.Product2);
                        }
                    }
                    
                }else if(newOpportunity.StageName!=oldOpportunity.StageName && newOpportunity.StageName=='Closed Won'){
                    
                    for(OpportunityLineItem oli:newOpportunity.OpportunityLineItems){
                        oli.Product2.Car_Status__c='Sold';
                        oli.Product2.RecordTypeId=carSoldRecordTypeId;
                        carsToUpdate.put(oli.Product2.Id,oli.Product2);
                        
                    }
                }else if(newOpportunity.StageName!=oldOpportunity.StageName && newOpportunity.StageName=='Closed Lost'){
                    for(OpportunityLineItem oli:newOpportunity.OpportunityLineItems){
                        oli.Product2.Car_Status__c='Available';
                        carsToUpdate.put(oli.Product2.Id,oli.Product2);
                    }
                }else if(newOpportunity.StageName!=oldOpportunity.StageName && oldOpportunity.StageName=='Contract Sent' && newOpportunity.StageName!='Closed Won' && 
                         newOpportunity.StageName!='Closed Lost' ){
                             for(OpportunityLineItem oli:newOpportunity.OpportunityLineItems){
                                 oli.Product2.Car_Status__c='Available';
                                 carsToUpdate.put(oli.Product2.Id,oli.Product2);
                             }
                         }
            }
            
        }
        
        if(!carsToUpdate.isEmpty()){
            update carsToUpdate.values();
        }
        if(!plannedSalesToUpdateIfOpportunityClosed.isEmpty()){
            update plannedSalesToUpdateIfOpportunityClosed.values();
        }
    }
}