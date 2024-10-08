/**
* @description       : 
* @author            : Nazar Voinarovych
* @group             : 
* @last modified on  : 10-07-2024
* @last modified by  : Nazar Voinarovych
**/
public with sharing class OpportunityTriggerHelper {
    
    public static void updatePlannedSalesWhenOpportunityClosedWon(){
        try{
            
            List<Opportunity> updatedOpportunities=[SELECT Id,CloseDate,StageName,Amount,(SELECT Id,Product2.Condition__c FROM OpportunityLineItems) FROM Opportunity 
                                                    WHERE StageName='Closed Won' AND Id IN :Trigger.New];
            
            Map<Integer,Integer> monthAndYear=new Map<Integer,Integer>();
            
            Map<String,Planned_Sales__c> plannedSales=new Map<String,Planned_Sales__c>();
            
            Map<Id,Planned_Sales__c> plannedSalesToUpdate=new Map<Id,Planned_Sales__c>();
            
            if(!updatedOpportunities.isEmpty()){
                for(Opportunity opportunity:updatedOpportunities){
                    
                    monthAndYear.put(opportunity.CloseDate.month(),opportunity.CloseDate.year());
                    
                }
                
                if(!monthAndYear.isEmpty()){
                    for(Planned_Sales__c plannedSale:[SELECT Id,Year__c,Month__c,Car_Type__c,Total_Amount_Earned__c,Count_of_Cars_Sold__c 
                                                      FROM Planned_Sales__c 
                                                      WHERE Year__c IN:monthAndYear.values()
                                                      AND Month__c IN:monthAndYear.keySet()]){
                                                          
                                                          String key=plannedSale.Year__c+'_'+plannedSale.Month__c+'_'+plannedSale.Car_Type__c;
                                                          plannedSales.put(key,plannedSale); 
                                                      }
                    
                    if(!plannedSales.isEmpty()){
                        for(Opportunity opportunity:updatedOpportunities){
                            String key1=opportunity.CloseDate.year()+'_'+opportunity.CloseDate.month();
                            
                            for(OpportunityLineItem opp:opportunity.OpportunityLineItems){
                                String key2=key1+'_'+opp.Product2.Condition__c;
                                
                                if(plannedSales.containsKey(key2)){
                                    Planned_Sales__c plannedSale=plannedSales.get(key2);
                                    
                                    if(plannedSale!=null){
                                        plannedSale.Total_Amount_Earned__c+=opportunity.Amount;
                                        plannedSale.Count_of_Cars_Sold__c+=opportunity.OpportunityLineItems.size();
                                        plannedSalesToUpdate.put(plannedSale.Id,plannedSale);
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
            
            
        }catch (System.NullPointerException e){
            system.debug(e);
            System.debug('Error message: ' + e.getMessage()); 
            System.debug('Stack trace: ' + e.getStackTraceString());
        }
    }
    
    public static void deleteOpportunity(){
        
        List<Opportunity> deletedOpportunities=[SELECT Id,CloseDate,StageName,Amount,(SELECT Id,Product2.Condition__c FROM OpportunityLineItems) FROM Opportunity 
                                                WHERE StageName='Closed Won' AND Id IN :Trigger.old];
        
        Map<Id,Planned_Sales__c> plannedSalesToUpdate=new Map<Id,Planned_Sales__c>();
        Map<String,Planned_Sales__c> relatedPlannedSales=new Map<String,Planned_Sales__c>();
        Map<Integer,Integer> monthAndYear=new Map<Integer,Integer>();
        
        if(!deletedOpportunities.isEmpty()){
            for(Opportunity deletedOpportunity:deletedOpportunities){
                monthAndYear.put(deletedOpportunity.CloseDate.month(),deletedOpportunity.CloseDate.year());
                
            }
            
            if(!monthAndYear.isEmpty()){
                for(Planned_Sales__c plannedSale:[SELECT Id,Year__c,Month__c,Car_Type__c,Total_Amount_Earned__c,Count_of_Cars_Sold__c 
                                                  FROM Planned_Sales__c 
                                                  WHERE Year__c IN:monthAndYear.values()
                                                  AND Month__c IN:monthAndYear.keySet()]){
                                                      
                                                      String key=plannedSale.Month__c+'_'+plannedSale.Year__c+'_'+plannedSale.Car_Type__c;                             
                                                      relatedPlannedSales.put(key,plannedSale);
                                                      
                                                  }
                
                if(!relatedPlannedSales.isEmpty()){
                    for(Opportunity deletedOpportunity:deletedOpportunities){
                        String key=deletedOpportunity.CloseDate.month()+'_'+deletedOpportunity.CloseDate.year();
                        for(OpportunityLineItem oli:deletedOpportunity.OpportunityLineItems){
                            String key2=key+'_'+oli.Product2.Condition__c;
                            if(relatedPlannedSales.containsKey(key2)){
                                Planned_Sales__c plannedSale=relatedPlannedSales.get(key2);
                                if(plannedSale!=null){
                                    plannedSale.Count_of_Cars_Sold__c-=deletedOpportunity.OpportunityLineItems.size();
                                    plannedSale.Total_Amount_Earned__c-=deletedOpportunity.Amount;
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
    
    public static void updateCarStatusWhenOpportunityStageChanged(Map<Id,Opportunity> oldOpportunities){
        
        List<Opportunity> newOpportunities=[SELECT Id,CloseDate,StageName,Amount,(SELECT Id,Product2.Condition__c FROM OpportunityLineItems) 
                                            FROM Opportunity WHERE Id IN :Trigger.New];
        List<Product2> carsToUpdate=new List<Product2>();
        
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
                            carsToUpdate.add(oli.Product2);
                        }
                    }
                    
                }else if(newOpportunity.StageName!=oldOpportunity.StageName && newOpportunity.StageName=='Closed Won'){
                    
                    String key=newOpportunity.CloseDate.month()+'_'+newOpportunity.CloseDate.year();
                    
                    for(OpportunityLineItem oli:newOpportunity.OpportunityLineItems){
                        oli.Product2.Car_Status__c='Sold';
                        oli.Product2.RecordTypeId='012WU000002S418YAC';
                        carsToUpdate.add(oli.Product2);
                        
                    }
                }else if(newOpportunity.StageName!=oldOpportunity.StageName && newOpportunity.StageName=='Closed Lost'){
                    for(OpportunityLineItem oli:newOpportunity.OpportunityLineItems){
                        oli.Product2.Car_Status__c='Available';
                        carsToUpdate.add(oli.Product2);
                    }
                }else if(oldOpportunity.StageName=='Contract Sent' && newOpportunity.StageName!='Closed Won' && 
                         newOpportunity.StageName!='Closed Lost' && newOpportunity.StageName!=oldOpportunity.StageName){
                             for(OpportunityLineItem oli:newOpportunity.OpportunityLineItems){
                                 oli.Product2.Car_Status__c='Available';
                                 carsToUpdate.add(oli.Product2);
                             }
                         }
                if(oldOpportunity.StageName=='Closed Won' && newOpportunity.StageName!=oldOpportunity.StageName){
                    String key=newOpportunity.CloseDate.month()+'_'+newOpportunity.CloseDate.year();
                    
                    for(OpportunityLineItem oli:newOpportunity.OpportunityLineItems){
                        
                        String key2=key+'_'+oli.Product2.Condition__c;
                        if(relatedPlannedSales.containsKey(key2)){
                            Planned_Sales__c plannedSale=relatedPlannedSales.get(key2);
                            if(plannedSale!=null){
                                plannedSale.Total_Amount_Earned__c-=newOpportunity.Amount;
                                plannedSale.Count_of_Cars_Sold__c-=newOpportunity.OpportunityLineItems.size();
                                plannedSalesToUpdateIfOpportunityClosed.put(plannedSale.Id,plannedSale);
                            }
                        }
                        
                    }
                }
            }
            
        }
        
        if(!carsToUpdate.isEmpty()){
            update carsToUpdate;
        }
        if(!plannedSalesToUpdateIfOpportunityClosed.isEmpty()){
            update plannedSalesToUpdateIfOpportunityClosed.values();
        }
    }
}