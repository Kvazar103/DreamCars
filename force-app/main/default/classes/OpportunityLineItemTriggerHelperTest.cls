@isTest
public with sharing class OpportunityLineItemTriggerHelperTest {
    
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
    private static void testBulkifyCheckCarStatusBeforeInsert(){

        Pricebook2 priceBook=TestDataFactory.getStandardPriceBook();

        List<Account> accounts=TestDataFactory.createAccounts(True);
        List<Product2> cars=TestDataFactory.createCars(False);
        
        
        for(Integer i=0;i<cars.size();i++){
            cars.get(i).reservedInOpportunity__c=true;
            cars.get(i).Car_Status__c='Reserved';
        }
        insert cars;
        
        
        List<PricebookEntry> priceBookEntries=TestDataFactory.createPriceBookEntry(priceBook.Id, cars, True);
        List<Opportunity> opportunities=TestDataFactory.createOpportunities(priceBook.Id, accounts, True);
        
        Test.StartTest();
        
        List<OpportunityLineItem> opportunityLineItems=TestDataFactory.createOpportunityProduct(cars, opportunities, True);
        
        Test.StopTest();
        
        List<Opportunity> opp=[SELECT Id,showWarningMessage__c FROM Opportunity];
        
        for(Integer i=0;i<opp.size();i++){
            Assert.isTrue(opp.get(i).showWarningMessage__c==true);
        }
        
    }
    
    
    //test negative
    @isTest
    private static void testNegativeCheckCarStatusBeforeInsert(){

        
        Pricebook2 priceBook=TestDataFactory.getStandardPriceBook();

        List<Account> accounts=TestDataFactory.createAccounts(True);
        List<Product2> cars=TestDataFactory.createCars(True);
        
        List<PricebookEntry> priceBookEntries=TestDataFactory.createPriceBookEntry(priceBook.Id, cars, True);
        List<Opportunity> opportunities=TestDataFactory.createOpportunities(priceBook.Id, accounts, True);
        
        Test.StartTest();
        
        List<OpportunityLineItem> opportunityLineItems=TestDataFactory.createOpportunityProduct(cars, opportunities, True);
        
        Test.StopTest();
        
        List<Opportunity> opp=[SELECT Id,showWarningMessage__c FROM Opportunity];
        
        for(Integer i=0;i<opp.size();i++){
            Assert.isTrue(opp.get(i).showWarningMessage__c==false);
        }
        

    }
    
    //test bulkify
    @isTest
    private static void testBulkifyDeleteOpportunityLineItems(){

        Pricebook2 priceBook=TestDataFactory.getStandardPriceBook();

        List<Account> accounts=TestDataFactory.createAccounts(True);
        List<Product2> cars=TestDataFactory.createCars(False);
        
        for(Integer i=0;i<cars.size();i++){

            cars.get(i).reservedInOpportunity__c=true;
            cars.get(i).Car_Status__c='Reserved';
        }

        insert cars;
        
        List<PricebookEntry> priceBookEntries=TestDataFactory.createPriceBookEntry(priceBook.Id, cars, True);
        List<Opportunity> opportunities=TestDataFactory.createOpportunities(priceBook.Id, accounts, True);
        List<OpportunityLineItem> opportunityLineItems=TestDataFactory.createOpportunityProduct(cars, opportunities, True);

        Test.StartTest();
          
        delete opportunityLineItems;
        
        Test.StopTest();
        
        List<Opportunity> opp=[SELECT Id,showWarningMessage__c FROM Opportunity];
        
        for(Integer i=0;i<opp.size();i++){
            Assert.isTrue(opp.get(i).showWarningMessage__c==false);
        }
    }

    //test negative
    @isTest
    private static void testNegativeDeleteOpportunityLineItem(){

        Pricebook2 priceBook=TestDataFactory.getStandardPriceBook();

        List<Account> accounts=TestDataFactory.createAccounts(True);
        List<Product2> cars=TestDataFactory.createCars(True);

        List<PricebookEntry> priceBookEntries=TestDataFactory.createPriceBookEntry(priceBook.Id, cars, True);
        List<Opportunity> opportunities=TestDataFactory.createOpportunities(priceBook.Id, accounts, True);
        
        List<OpportunityLineItem> opportunityLineItems=TestDataFactory.createOpportunityProduct(cars, opportunities, True);
        
        Test.StartTest();
        
        delete opportunityLineItems;
        
        Test.StopTest();
        
        List<Opportunity> opp=[SELECT Id,showWarningMessage__c FROM Opportunity];
        
        for(Integer i=0;i<opp.size();i++){
            Assert.isTrue(opp.get(i).showWarningMessage__c==false);
        }
        
    }
    
       

}