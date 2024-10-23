/**
* @description       : 
* @author            : Nazar Voinarovych
* @group             : 
* @last modified on  : 10-18-2024
* @last modified by  : Svyatoslav Andrushchak
**/
@isTest
public with sharing class PlannedSalesTriggerHelperTest {
    
    @TestSetup
    static void createTestData(){
        Trigger_Control__c contentDocumentLinkTriggerControl=TestDataFactory.createContentDocumentLinkTriggerControl();
        insert contentDocumentLinkTriggerControl;
        
        Trigger_Control__c plannedSalesTriggerControl=TestDataFactory.createPlannedSalesTriggerControl();
        insert plannedSalesTriggerControl;
        
        Trigger_Control__c carTriggerControl=TestDataFactory.createCarTriggerControl();
        insert carTriggerControl;
        
        Trigger_Control__c caseTriggerControl=TestDataFactory.createCaseTriggerControl();
        insert caseTriggerControl;
        
        Trigger_Control__c opportunityLineItemTriggerControl=TestDataFactory.createOpportunityLineItemTriggerControl();
        insert opportunityLineItemTriggerControl;
        
        Trigger_Control__c opportunityTriggerControl=TestDataFactory.createOpportunityTriggerControl();
        insert opportunityTriggerControl;
        
        
        
        
    } 
    //test negative
    @isTest
    private static void testNegativeCreatePlannedSale(){
        
        Pricebook2 standardPriceBook=TestDataFactory.getStandardPriceBook();
        
        List<Account> accounts=TestDataFactory.createAccounts(True);
        
        List<Product2> cars=TestDataFactory.createCars(True);
        
        List<PricebookEntry> priceBookEntries=TestDataFactory.createPriceBookEntry(standardPriceBook.Id, cars, True);
        
        List<Opportunity> opportunities=TestDataFactory.createOpportunities(standardPriceBook.Id, accounts, False);
        
        for(Integer i=0;i<opportunities.size();i++){
            opportunities.get(i).CloseDate=opportunities.get(i).CloseDate.addYears(i+1);
        }
        insert opportunities;
        
        List<OpportunityLineItem> opportunityLineItems=TestDataFactory.createOpportunityProduct(cars, opportunities, True);
        
        
        Test.startTest();
        
        List<Planned_Sales__c> plannedSales=TestDataFactory.createPlannedSales(False);
        
        for(Integer i=0;i<plannedSales.size();i++){
            plannedSales.get(i).Year__c=plannedSales.get(i).Year__c+i+100;
        }
        insert plannedSales;
        
        Test.stopTest();

        List<Opportunity> newOpportunities=[SELECT Id,Name,StageName,Amount,CloseDate,(SELECT Id,Product2.Condition__c FROM OpportunityLineItems) FROM Opportunity];
        List<Planned_Sales__c> newPlannedSales=[SELECT Id,Name,Car_Type__c,Total_Amount_Earned__c,Year__c,Month__c,Count_of_Cars_Sold__c FROM Planned_Sales__c];
        
        for(Integer i=0;i<75;i++){
            Assert.isTrue(newOpportunities.get(i).Amount!=newPlannedSales.get(i).Total_Amount_Earned__c);
        }
        
    }
    
    //test bulkify
    @isTest
    private static void testBulkifyCreatePlannedSales(){
        
        Pricebook2 standardPriceBook=TestDataFactory.getStandardPriceBook();
        
        List<Account> accounts=TestDataFactory.createAccounts(True);
        
        List<Product2> cars=TestDataFactory.createCars(True);
        
        List<PricebookEntry> priceBookEntries=TestDataFactory.createPriceBookEntry(standardPriceBook.Id, cars, True);
        
        List<Opportunity> opportunities=TestDataFactory.createOpportunities(standardPriceBook.Id, accounts, False);
        
        for(Integer i=0;i<opportunities.size();i++){
            opportunities.get(i).StageName='Closed Won';
            opportunities.get(i).CloseDate=opportunities.get(i).CloseDate.addYears(i+1);
        }
        insert opportunities;
        
        
        List<OpportunityLineItem> opportunityLineItems=TestDataFactory.createOpportunityProduct(cars, opportunities, True);
        
        Test.StartTest();
        
        List<Planned_Sales__c> plannedSales=TestDataFactory.createPlannedSales(False);
        
        for(Integer i=0;i<plannedSales.size();i++){
            plannedSales.get(i).Year__c=plannedSales.get(i).Year__c+i+1;
        }
        
        insert plannedSales;
        Test.StopTest();
        
        List<Opportunity> newOpportunities=[SELECT Id,Name,StageName,Amount,CloseDate,(SELECT Id,Product2.Condition__c FROM OpportunityLineItems) FROM Opportunity WHERE StageName='Closed Won'];
        
        List<Planned_Sales__c> newPlannedSales=[SELECT Id,Name,Car_Type__c,Total_Amount_Earned__c,Year__c,Month__c,Count_of_Cars_Sold__c FROM Planned_Sales__c];
        
        for(Integer i=0;i<newPlannedSales.size();i++){
            Assert.areEqual(newPlannedSales.get(i).Total_Amount_Earned__c,newOpportunities.get(i).Amount);
        } 
        
        
        Assert.isTrue(newPlannedSales.size()==75);
        Assert.isTrue(newOpportunities.size()==75);
        
    }
    
    //negative test
    @isTest
    private static void testNegateUpdatePlannedSales(){
        
        List<Account> accounts=TestDataFactory.createAccounts(True);
        
        List<Product2> cars=TestDataFactory.createCars(True);
        
        Pricebook2 priceBook=TestDataFactory.getStandardPriceBook();
        
        List<PricebookEntry> priceBookEntries=TestDataFactory.createPriceBookEntry(priceBook.Id, cars, True);
        
        List<Opportunity> opportunities=TestDataFactory.createOpportunities(priceBook.Id, accounts, False);
        
        for(Integer i=0;i<opportunities.size();i++){
            opportunities.get(i).CloseDate=opportunities.get(i).CloseDate.AddYears(i+1);
        }
        insert opportunities;
        
        List<OpportunityLineItem> opportunityLineItems=TestDataFactory.createOpportunityProduct(cars, opportunities, True);
        
        List<Planned_Sales__c> plannedSalesToUpdate=TestDataFactory.createPlannedSales(True);
        
        Test.StartTest();
        for(Integer i=0;i>plannedSalesToUpdate.size();i++){
            plannedSalesToUpdate.get(i).Year__c+=i+1;
        }
        update plannedSalesToUpdate;
        
        Test.StopTest();
        
        List<Planned_Sales__c> updatedPlannedSales=[SELECT Id,Name,Car_Type__c,Total_Amount_Earned__c,Year__c,Month__c,Count_of_Cars_Sold__c FROM Planned_Sales__c ];
        List<Opportunity> opps=[SELECT Id,Name,Amount,CloseDate FROM Opportunity];
        
        for(Integer i=0;i<75;i++){
            Assert.isTrue(updatedPlannedSales.get(i).Total_Amount_Earned__c==0);
            Assert.isTrue(updatedPlannedSales.get(i).Count_of_Cars_Sold__c==0);
        }
        
    }
    
    //bulkify test
    @isTest
    private static void testBulkifyUpdatePlannedSales(){
        
        List<Account> accounts=TestDataFactory.createAccounts(True);
        
        List<Product2> cars=TestDataFactory.createCars(True);
        
        Pricebook2 priceBook=TestDataFactory.getStandardPriceBook();
        
        List<PricebookEntry> priceBookEntries=TestDataFactory.createPriceBookEntry(priceBook.Id, cars, True);
        
        List<Opportunity> opportunities=TestDataFactory.createOpportunities(priceBook.Id, accounts, False);
        
        for(Integer i=0;i<opportunities.size();i++){
            opportunities.get(i).StageName='Closed Won';
            opportunities.get(i).CloseDate = opportunities.get(i).CloseDate.addYears(i+1);
        }
        insert opportunities;
        
        List<OpportunityLineItem> opportunityLineItems=TestDataFactory.createOpportunityProduct(cars, opportunities, True);
        
        Test.StartTest();
        
        List<Planned_Sales__c> plannedSalesToUpdate=TestDataFactory.createPlannedSales(True);
        
        for(Integer i=0;i<plannedSalesToUpdate.size();i++){
            plannedSalesToUpdate.get(i).Year__c+=i+1;
        }
        
        update plannedSalesToUpdate;
        
        
        Test.StopTest();
        
        List<Planned_Sales__c> updatedPlannedSales=[SELECT Id,Name,Car_Type__c,Total_Amount_Earned__c,Year__c,Month__c,Count_of_Cars_Sold__c FROM Planned_Sales__c ];
        List<Opportunity> opps=[SELECT Id,Name,Amount,CloseDate FROM Opportunity];
        
        for(Integer i=0;i<75;i++){
            Assert.areEqual(updatedPlannedSales.get(i).Total_Amount_Earned__c,opps.get(i).Amount);
        }
        
    }
    
}