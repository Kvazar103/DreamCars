/**
 * @description       : 
 * @author            : Nazar Voinarovych
 * @group             : 
 * @last modified on  : 10-07-2024
 * @last modified by  : Nazar Voinarovych
**/

@isTest
public with sharing class OpportunityTriggerHelperTest {
    
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
    
    
    //test bulkify
    @isTest
    private static void testBulkifyOpportunityClosed(){
        
        
        List<Account> accounts=TestDataFactory.createAccounts(True);

        List<Product2> cars=TestDataFactory.createCars(True);
        
        Pricebook2 priceBook=TestDataFactory.getStandardPriceBook();
        
        List<PricebookEntry> priceBookEntries=TestDataFactory.createPriceBookEntry(priceBook.Id, cars, True);
        
        List<Planned_Sales__c> pls=TestDataFactory.createPlannedSales(False);
        insert pls.get(0);
        
        List<Opportunity> opportunities=TestDataFactory.createOpportunities(priceBook.Id, accounts, True);
        
        List<OpportunityLineItem> opportunityLineItems=TestDataFactory.createOpportunityProduct(cars, opportunities, True);

        
        Test.StartTest();
        
        for(Integer i=0;i<opportunities.size();i++){
            opportunities.get(i).StageName='Closed Won';
            opportunities.get(i).CloseDate=Date.today();
        }
        update opportunities;
        


        Test.StopTest();
        
        List<Opportunity> opp=[SELECT Id,Name,StageName,Amount,CloseDate,(SELECT Id,Product2.Condition__c FROM OpportunityLineItems) FROM Opportunity];
        AggregateResult[] totalAmount=[SELECT SUM(Amount)totalAmount FROM Opportunity];
        Planned_Sales__c newPlannedSale=[SELECT Id,Name,Car_Type__c,Total_Amount_Earned__c,Year__c,Month__c,Count_of_Cars_Sold__c FROM Planned_Sales__c LIMIT 1];
        
        system.debug(newPlannedSale);
        
        Assert.isTrue(opp.size()==75);
        Assert.areEqual(newPlannedSale.Total_Amount_Earned__c,totalAmount[0].get('totalAmount'));
        Assert.areEqual(newPlannedSale.Count_of_Cars_Sold__c,75);

    }
    
    //test negative
    @isTest
    private static void testNegativeOpportunityClose(){
        
        List<Account> accounts=TestDataFactory.createAccounts(True);
        
        List<Product2> cars=TestDataFactory.createCars(True);
        
        Pricebook2 priceBook=TestDataFactory.getStandardPriceBook();
        
        List<PricebookEntry> priceBookEntries=TestDataFactory.createPriceBookEntry(priceBook.Id, cars, True);
        
        List<Opportunity> opportunities=TestDataFactory.createOpportunities(priceBook.Id, accounts, True);
        
        List<OpportunityLineItem> opportunityLineItems=TestDataFactory.createOpportunityProduct(cars, opportunities, True);
        
        List<Planned_Sales__c> pls=TestDataFactory.createPlannedSales(False);
        insert pls.get(0);
        
        Test.StartTest();
        
        for(Integer i=0;i<opportunities.size();i++){
            opportunities.get(i).StageName='Contract Sent';
        }
        
        update opportunities;
        Test.StopTest();
        
        List<Opportunity> newOpportunities=[SELECT Id,Name,StageName,Amount,CloseDate,(SELECT Id,Product2.Condition__c FROM OpportunityLineItems) FROM Opportunity];
        List<OpportunityLineItem> oli=[SELECT Id,Product2.Condition__c FROM OpportunityLineItem];
        Planned_Sales__c newPlannedSale=[SELECT Id,Name,Car_Type__c,Total_Amount_Earned__c,Year__c,Month__c,Count_of_Cars_Sold__c FROM Planned_Sales__c];
        
        for(Integer i=0;i<newOpportunities.size();i++){
            Assert.isTrue(newPlannedSale.Total_Amount_Earned__c!=newOpportunities.get(i).Amount);
            Assert.isTrue(newPlannedSale.Count_of_Cars_Sold__c!=newOpportunities.get(i).OpportunityLineItems.size());
        }
        
        
    }
    
     //test bulkify
    @isTest
    private static void testBulkifyUpdateOpportunitiesFromClosedWon(){
        
        
        List<Account> accounts=TestDataFactory.createAccounts(True);

        List<Product2> cars=TestDataFactory.createCars(True);
        
        Pricebook2 priceBook=TestDataFactory.getStandardPriceBook();
        
        List<PricebookEntry> priceBookEntries=TestDataFactory.createPriceBookEntry(priceBook.Id, cars, True);
        
        List<Planned_Sales__c> pls=TestDataFactory.createPlannedSales(False);
 
        insert pls.get(0);
        
        List<Opportunity> opportunities=TestDataFactory.createOpportunities(priceBook.Id, accounts,False);
        
        for(Integer i=0;i<opportunities.size();i++){
            opportunities.get(i).StageName='Closed Won';
        }
        insert opportunities;
        
        List<OpportunityLineItem> opportunityLineItems=TestDataFactory.createOpportunityProduct(cars, opportunities, True);

        

        Test.StartTest();
        
       for(Integer i=0;i<opportunities.size();i++){
            opportunities.get(i).StageName='Contract Sent';
        }
        update opportunities;
        
        
        
        Test.StopTest();
    
        Planned_Sales__c newPlannedSale=[SELECT Id,Name,Car_Type__c,Total_Amount_Earned__c,Year__c,Month__c,Count_of_Cars_Sold__c FROM Planned_Sales__c LIMIT 1];
        
        Assert.areEqual(newPlannedSale.Total_Amount_Earned__c,0);
        Assert.areEqual(newPlannedSale.Count_of_Cars_Sold__c,0);

    }
    
    //bulkify test delete
    @isTest
    private static void testBulkifyDeleteOpportunity(){

        List<Account> accounts=TestDataFactory.createAccounts(True);

        List<Product2> cars=TestDataFactory.createCars(True);
        
        Pricebook2 priceBook=TestDataFactory.getStandardPriceBook();

        
        
        List<PricebookEntry> priceBookEntries=TestDataFactory.createPriceBookEntry(priceBook.Id, cars,True);

        List<Opportunity> opportunities=TestDataFactory.createOpportunities(priceBook.Id, accounts, True);
        
        for(Integer i=0;i<opportunities.size();i++){
            opportunities.get(i).CloseDate=Date.today();
            opportunities.get(i).StageName='Closed Won';
        }
        update opportunities;
        
        List<Planned_Sales__c> plannedSales=TestDataFactory.createPlannedSales(False);
        insert plannedSales.get(0);
        
        List<OpportunityLineItem> opportunityLineItems=TestDataFactory.createOpportunityProduct(cars, opportunities, True);

        Test.StartTest();

        delete opportunities;
        
        Test.StopTest();
        
        Planned_Sales__c planed=[SELECT Id,Name,Car_Type__c,Total_Amount_Earned__c,Year__c,Month__c,Count_of_Cars_Sold__c FROM Planned_Sales__c LIMIT 1];

        Assert.AreEqual(planed.Total_Amount_Earned__c,0);
        Assert.AreEqual(planed.Count_of_Cars_Sold__c,0);
        
    }
    
    //negative test delete
    @isTest
    private static void testNegativeDeleteOpportunity(){
        

        List<Account> accounts=TestDataFactory.createAccounts(True);

        List<Product2> cars=TestDataFactory.createCars(True);
        
        Pricebook2 priceBook=TestDataFactory.getStandardPriceBook();

        List<Planned_Sales__c> plannedSales=TestDataFactory.createPlannedSales(False);
        insert plannedSales.get(0);
        

        
        List<PricebookEntry> priceBookEntries=TestDataFactory.createPriceBookEntry(priceBook.Id, cars,True);

        List<Opportunity> opportunities=TestDataFactory.createOpportunities(priceBook.Id, accounts, True);
        
        List<OpportunityLineItem> opportunityLineItems=TestDataFactory.createOpportunityProduct(cars, opportunities, True);

        
        Test.StartTest();
        
        delete opportunities;
        
        Test.StopTest();
        
        Planned_Sales__c planned=[SELECT Id,Name,Car_Type__c,Total_Amount_Earned__c,Year__c,Month__c,Count_of_Cars_Sold__c FROM Planned_Sales__c LIMIT 1];

  
        Assert.areEqual(planned.Total_Amount_Earned__c,0);
        Assert.areEqual(planned.Count_of_Cars_Sold__c,0);
    }
    
    
    

    
}