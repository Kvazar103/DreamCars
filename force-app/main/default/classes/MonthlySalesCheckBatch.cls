/**
 * @description       : 
 * @author            : Nazar Voinarovych
 * @group             : 
 * @last modified on  : 11-07-2024
 * @last modified by  : Nazar Voinarovych
**/
public with sharing class MonthlySalesCheckBatch implements Database.Batchable<sObject>{
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        return Database.getQueryLocator('SELECT Id,Total_Amount_Earned__c,Planned_Total_Amount__c,isPlannedTotalAmountGreaterThanTotalAmou__c FROM Planned_Sales__c WHERE isPlannedTotalAmountGreaterThanTotalAmou__c=true');
    }
    public void execute(Database.BatchableContext bc, List<SObject> records){
        // process each batch of records
        List<Planned_Sales__c> plannedSales=(List<Planned_Sales__c>) records;

        List<Planned_Sales__c> filteredPlannedSales=new List<Planned_Sales__c>();

        for(Planned_Sales__c plannedSale:plannedSales){
            if(plannedSale.Total_Amount_Earned__c<plannedSale.Planned_Total_Amount__c){
                plannedSale.Underperfoming__c=true;
                filteredPlannedSales.add(plannedSale);
            }
        }
        if(!filteredPlannedSales.isEmpty()){
            update filteredPlannedSales;
            System.enqueueJob(new MonthlySalesCheckNotificationQueueable(filteredPlannedSales));
        }
    }
    public void finish(Database.BatchableContext bc){
        // execute any post-processing operations
        system.debug('MonthlySalesChekBatch finish:'+bc);
    }
}