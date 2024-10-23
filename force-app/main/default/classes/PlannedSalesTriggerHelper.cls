/**
* @description       : 
* @author            : Nazar Voinarovych
* @group             : 
* @last modified on  : 10-07-2024
* @last modified by  : Nazar Voinarovych
**/

public with sharing class PlannedSalesTriggerHelper {
    
    public static void createOrUpdatePlannedSales(){
        
        List<Planned_Sales__c> newPlannedSales=(List<Planned_Sales__c>)Trigger.new;
        
        Map<Id,Planned_Sales__c> oldPlannedSalesMap=(Map<Id,Planned_Sales__c>)Trigger.oldMap;
        
        Set<Integer> month=new Set<Integer>();
       
        Set<Integer> year=new Set<Integer>();

        
        Map<String,Planned_Sales__c> relatedPlannedSales=new Map<String,Planned_Sales__c>();
        
        Map<String,Planned_Sales__c> relatedPlannedSalesToUpdate=new Map<String,Planned_Sales__c>();
        
        Map<Id,Planned_Sales__c> plannedSalesToUpdate=new Map<Id,Planned_Sales__c>();
        
        List<Planned_Sales__c> pls=new List<Planned_Sales__c>();
        
        
        for(Planned_Sales__c plannedSale:newPlannedSales){
            
            if(oldPlannedSalesMap!=null){

                Planned_Sales__c oldPlannedSale=oldPlannedSalesMap.get(plannedSale.Id);
                if((oldPlannedSale!=null) &&(plannedSale.Year__c!=oldPlannedSale.Year__c || plannedSale.Month__c!=oldPlannedSale.Month__c 
                                             || plannedSale.Car_Type__c!=oldPlannedSale.Car_Type__c)){
                                                 
                                                 String key=plannedSale.Month__c+'_'+plannedSale.Year__c+'_'+plannedSale.Car_Type__c;
                                                 //plannedSale.Count_of_Cars_Sold__c=0.00;
                                                 //plannedSale.Total_Amount_Earned__c=0.00;
                                                 month.add((Integer) plannedSale.Month__c);
                                                 year.add((Integer) plannedSale.Year__c);
                                                 relatedPlannedSales.put(key,plannedSale);
                                                 
                                             }
            } if(oldPlannedSalesMap==null){

                String key=plannedSale.Month__c+'_'+plannedSale.Year__c+'_'+plannedSale.Car_Type__c;
                relatedPlannedSales.put(key,plannedSale);

                month.add((Integer) plannedSale.Month__c);
                year.add((Integer) plannedSale.Year__c);
            }
            
        }
        
        if(month!=null && year!=null){
            for(Opportunity opportunity:[SELECT Id,CloseDate,StageName,Amount,(SELECT Id,Product2.Condition__c,Quantity,Product2.Sale_Price__c FROM OpportunityLineItems) FROM Opportunity 
                                         WHERE CALENDAR_MONTH(CloseDate) IN :month 
                                         AND CALENDAR_YEAR(CloseDate) IN:year
                                         AND StageName='Closed Won'
                                        ]){ 
                                            
                                            String key=opportunity.CloseDate.month()+'_'+opportunity.CloseDate.year(); 
                                            
                                            for(OpportunityLineItem oli:opportunity.OpportunityLineItems){
                                                
                                                String key2=key+'_'+oli.Product2.Condition__c;
                                                
                                                if(relatedPlannedSales.containsKey(key2)){
                                                    
                                                    Planned_Sales__c plannedSale=relatedPlannedSales.get(key2);
                                                    
                                                    if((plannedSale!=null) && (oldPlannedSalesMap!=null)){
                                                        
                                                        plannedSale.Total_Amount_Earned__c=opportunity.Amount;
                                                        plannedSale.Count_of_Cars_Sold__c=opportunity.OpportunityLineItems.size();
                                                        
                                                        
                                                    }else if((plannedSale!=null) && (oldPlannedSalesMap==null)){
                                                        
                                                        Planned_Sales__c pl=plannedSale.clone();
                                                        pl.Id=plannedSale.Id;
                                                        pl.Total_Amount_Earned__c=opportunity.Amount;
                                                        pl.Count_of_Cars_Sold__c=opportunity.OpportunityLineItems.size();
                                                        
                                                        plannedSalesToUpdate.put(pl.Id,pl);  
                                                        
                                                    } 
                                                }                             
                                            }
                                        } 
        }
        if(!plannedSalesToUpdate.isEmpty() && (oldPlannedSalesMap==null)){
            update plannedSalesToUpdate.values();
            
        }
        
    }
    
}