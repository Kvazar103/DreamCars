/**
 * @description       : 
 * @author            : Nazar Voinarovych
 * @group             : 
 * @last modified on  : 11-06-2024
 * @last modified by  : Nazar Voinarovych
**/
@isTest
public with sharing class MonthlySalesCheckNotificationQueueabTest {
    @TestSetup
    static void makeData(){
        Trigger_Control__c plannedSalesTriggerControl=TestDataFactory.createPlannedSalesTriggerControl();
        insert plannedSalesTriggerControl;

        List<Planned_Sales__c> plannedSales=TestDataFactory.createPlannedSales(False);

        for(Planned_Sales__c plannedSale:plannedSales){
            plannedSale.Total_Amount_Earned__c=100;
            plannedSale.Planned_Total_Amount__c=200;
            plannedSale.Underperfoming__c=true;
        }
        insert plannedSales;
    }
    @isTest
    private static void testMonthlySalesCheckNotificationQueueable(){
        List<Planned_Sales__c> plannedSales=[SELECT Id,Total_Amount_Earned__c,Planned_Total_Amount__c,Underperfoming__c FROM Planned_Sales__c];

        Test.startTest();
        system.enqueueJob(new MonthlySalesCheckNotificationQueueable(plannedSales));
        Test.stopTest();

    }
}