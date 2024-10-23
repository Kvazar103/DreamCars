@isTest
public with sharing class CarTriggerHelperTest {
    
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
    private static void testBulkifyUpdateCar(){
        
        List<Account> accounts=TestDataFactory.createAccounts(True);
        List<Product2> cars=TestDataFactory.createCars(False);
        
        for(Integer i=0;i<cars.size();i++){
            cars.get(i).VIN_Number__c+=i+1;
            cars.get(i).reservedInOpportunity__c=true;
            cars.get(i).Car_Status__c='Reserved';
        }
        
        insert cars;
        
        Pricebook2 priceBook=TestDataFactory.getStandardPriceBook();
        
        List<PricebookEntry> priceBookEntries=TestDataFactory.createPriceBookEntry(priceBook.Id, cars, True);
        
        List<Opportunity> opportunities=TestDataFactory.createOpportunities(priceBook.Id, accounts, True);
        List<OpportunityLineItem> opportunityLineItems=TestDataFactory.createOpportunityProduct(cars, opportunities,True);
        
        
        Test.StartTest();
        
        
        for(Opportunity opp: opportunities){
            opp.showWarningMessage__c=true;
        }
        update opportunities;
        
        for(Product2 car:cars){
            car.Car_Status__c='Available';
        }
        update cars;
        
        Test.StopTest();
        
        List<Opportunity> opps=[SELECT Id,showWarningMessage__c FROM Opportunity];
        
        for(Integer i=0;i<opps.size();i++){
            Assert.isTrue(opps.get(i).showWarningMessage__c==false);
        }
        
    }
    
    //test negative
    @isTest
    private static void testNegativeUpdateCar(){
        
        List<Account> accounts=TestDataFactory.createAccounts(True);
        List<Product2> cars=TestDataFactory.createCars(False);
        
        for(Integer i=0;i<cars.size();i++){
            cars.get(i).VIN_Number__c+=i+1;
            cars.get(i).reservedInOpportunity__c=true;
            cars.get(i).Car_Status__c='Reserved';
        }
        
        insert cars;
        
        Pricebook2 priceBook=TestDataFactory.getStandardPriceBook();
        
        List<PricebookEntry> priceBookEntries=TestDataFactory.createPriceBookEntry(priceBook.Id, cars, True);
        
        List<Opportunity> opportunities=TestDataFactory.createOpportunities(priceBook.Id, accounts, True);
        List<OpportunityLineItem> opportunityLineItems=TestDataFactory.createOpportunityProduct(cars, opportunities,True);
        
        Test.StartTest();
        
        for(Integer i=0;i<opportunities.size();i++){
            opportunities.get(i).showWarningMessage__c=true;
        }
        update opportunities;
        
        for(Integer i=0;i<cars.size();i++){
            cars.get(i).Car_Status__c='On Hold';
        }
        
        update cars;
        
        Test.StopTest();
        
        List<Opportunity> opps=[SELECT Id,showWarningMessage__c FROM Opportunity];
        
        for(Opportunity opportunity:opps){
            Assert.isTrue(opportunity.showWarningMessage__c==true);
        }
        
    }
    
}