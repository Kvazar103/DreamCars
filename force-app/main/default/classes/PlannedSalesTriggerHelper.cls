/**
 * @description       : 
 * @author            : Svyatoslav Andrushchak
 * @group             : 
 * @last modified on  : 10-07-2024
 * @last modified by  : Svyatoslav Andrushchak
**/
public with sharing class PlannedSalesTriggerHelper {
    
    public static void createPlannedSales(){
        
        List<Planned_Sales__c> createdPlannedSales=[SELECT Id,Year__c,Month__c,Car_Type__c,Total_Amount_Earned__c,Count_of_Cars_Sold__c 
                                               FROM Planned_Sales__c WHERE Id IN:Trigger.New];
        
        Map<Integer,Integer> monthAndYearOfPlannedSale=new Map<Integer,Integer>();

        Set<Integer> month;
        Set<Integer> year;
        
        Map<String,Planned_Sales__c> relatedPlannedSales=new Map<String,Planned_Sales__c>();
        
        Map<Id,Planned_Sales__c> plannedSalesToUpdate=new Map<Id,Planned_Sales__c>();
                
                
        if(!createdPlannedSales.isEmpty()){
            for(Planned_Sales__c plannedSale:createdPlannedSales){
                String key=plannedSale.Month__c+'_'+plannedSale.Year__c+'_'+plannedSale.Car_Type__c;
                relatedPlannedSales.put(key,plannedSale);
                //! Problem HERE
                monthAndYearOfPlannedSale.put((Integer) plannedSale.Month__c,(Integer) plannedSale.Year__c);
            }

            if(!monthAndYearOfPlannedSale.isEmpty()){
                for(Opportunity opportunity:[SELECT Id,CloseDate,StageName,Amount,(SELECT Id,Product2.Condition__c FROM OpportunityLineItems) FROM Opportunity 
                                              WHERE CALENDAR_MONTH(CloseDate) IN :month 
                                             AND CALENDAR_YEAR(CloseDate) IN:monthAndYearOfPlannedSale.values()
                                             AND StageName='Closed Won'
                                            ]){ 
                     
                    String key=opportunity.CloseDate.month()+'_'+opportunity.CloseDate.year(); 
                                                 
                    for(OpportunityLineItem oli:opportunity.OpportunityLineItems){
                        
                        String key2=key+'_'+oli.Product2.Condition__c;
                        
                        if(relatedPlannedSales.containsKey(key2)){
                            
                            Planned_Sales__c plannedSale=relatedPlannedSales.get(key2);
                            
                            if(plannedSale!=null){
                                plannedSale.Total_Amount_Earned__c+=opportunity.Amount;
                                plannedSale.Count_of_Cars_Sold__c+=opportunity.OpportunityLineItems.size();
                                
                                plannedSalesToUpdate.put(plannedSale.Id,plannedSale);
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
    public static void updatePlannedSales(List<Planned_Sales__c> newPlannedSales,Map<Id,Planned_Sales__c> oldPlannedSalesMap){
        
        Map<Integer,Integer> monthAndYear=new Map<Integer,Integer>();
        Map<String,Planned_Sales__c> plannedSales=new Map<String,Planned_Sales__c>();
        
        
        Map<Id,Planned_Sales__c> plannedSalesToUpdate=new Map<Id,Planned_Sales__c>();
        
        if(!newPlannedSales.isEmpty()){
            for(Planned_Sales__c newPlannedSale:newPlannedSales){
                Planned_Sales__c oldPlannedSale=oldPlannedSalesMap.get(newPlannedSale.Id);
                
                if(newPlannedSale.Year__c!=oldPlannedSale.Year__c || newPlannedSale.Month__c!=oldPlannedSale.Month__c 
               
                   || newPlannedSale.Car_Type__c!=oldPlannedSale.Car_Type__c){
                       
                       String key=newPlannedSale.Month__c+'_'+newPlannedSale.Year__c+'_'+newPlannedSale.Car_Type__c;
                       monthAndYear.put((Integer) newPlannedSale.Month__c,(Integer) newPlannedSale.Year__c);
                       newPlannedSale.Count_of_Cars_Sold__c=0.00;
                       newPlannedSale.Total_Amount_Earned__c=0.00;
                       plannedSales.put(key,newPlannedSale);
                   }
            }
            if(!monthAndYear.isEmpty()){
                
            
            for(Opportunity opportunity:[SELECT Id,CloseDate,StageName,Amount,
                                         (SELECT Id,Product2.Condition__c FROM OpportunityLineItems) 
                                         FROM Opportunity 
                                         WHERE CALENDAR_MONTH(CloseDate) IN:monthAndYear.keySet()
                                         AND StageName='Closed Won'
                                         AND CALENDAR_YEAR(CloseDate) IN:monthAndYear.values()]){
                 
                 String key=opportunity.CloseDate.month()+'_'+opportunity.CloseDate.year();                           
                 for(OpportunityLineItem oli:opportunity.OpportunityLineItems){
                     String key2=key+'_'+oli.Product2.Condition__c;
                     
                     
                     if(plannedSales.containsKey(key2)){
                         
                         Planned_Sales__c plannedSale=plannedSales.get(key2);
                         if(plannedSale!=null){
                             plannedSale.Total_Amount_Earned__c+=opportunity.Amount;
                             plannedSale.Count_of_Cars_Sold__c+=opportunity.OpportunityLineItems.size();
                             
                             //plannedSalesToUpdate.put(plannedSale.Id,plannedSale);
                         }
                         
                     }
                                                 
                 }                    
            }
        }
           
        }
        //if(!plannedSalesToUpdate.isEmpty()){
            //upsert plannedSalesToUpdate.values();
        //}
        //
        //У тригері типу before ви можете безпосередньо змінювати записи в Trigger.new. Не потрібно виконувати окремі DML-операції 
        //(update) на цих записах, бо система вже автоматично їх зберігає після виконання тригера.
        
    }

}