/**
 * @description       : 
 * @author            : Nazar Voinarovych
 * @group             : 
 * @last modified on  : 11-06-2024
 * @last modified by  : Nazar Voinarovych
**/
@isTest
public with sharing class MonthlySalesCheckScheduleTest {
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
    private static void testMonthlySalesCheckSchedule(){
        String cronExpression='0 0 0 1 * ? ';
        Test.startTest();
        String jobId=System.schedule('Monthly Planned Sales Check Test', cronExpression, new MonthlySalesCheckSchedule());
        Test.stopTest();

        CronTrigger cron=[SELECT Id,CronExpression,State FROM CronTrigger WHERE Id=:jobId];
        Assert.areEqual('WAITING', cron.State);

    }
}