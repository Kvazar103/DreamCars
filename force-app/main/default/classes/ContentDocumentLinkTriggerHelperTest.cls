@isTest
public with sharing class ContentDocumentLinkTriggerHelperTest {
    
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

    //test positive
    @isTest
    private static void testBulkifyProcessInsertedContentDocumentLinks(){
        
        List<Product2> cars=TestDataFactory.createCars(True);
        
        List<Case> cases=TestDataFactory.createCaseFromEmailToCase(cars,True);
        
        List<EmailMessage> emailMessages=TestDataFactory.createEmailMessage(cases,cars,True);
        
        List<ContentVersion> contentVersions=TestDataFactory.createContentVersions(True);

        List<ContentDocument> contentDocuments=[SELECT Id FROM ContentDocument];


        Test.StartTest();

        List<ContentDocumentLink> contentDocumentLinks=TestDataFactory.createContentDocumentLink(contentVersions, emailMessages, True);

        Test.StopTest();
        
        List<ContentDocumentLink> newContentDocumentLinks=[SELECT Id, ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN (SELECT Id FROM EmailMessage)];
        system.debug(newContentDocumentLinks.size());
        
        List<Car_Service__c> carServices=[SELECT Id,Name,Car__c FROM Car_Service__c];
        
        Assert.isTrue(carServices.size()==15);
        
        for(Car_Service__c cs:carServices){
            for(Integer i=0;i<cars.size();i++){
                Assert.areEqual(cs.Name,cars.get(i).Name+' service');
            }
        } 
    }
    
    //test negative
    @isTest
    private static void testNegativeProcessInsertedContentDocumentLinks(){
        
        List<Product2> cars=TestDataFactory.createCars(True);
        
        List<Case> cases=TestDataFactory.createCaseFromEmailToCase(cars,True);
        
        List<EmailMessage> emailMessages=TestDataFactory.createEmailMessage(cases,cars,True);
        
        List<Car_Service__c> carServices=[SELECT Id,Name,Car__c FROM Car_Service__c];
        
        system.debug(carServices.size());
        
        Assert.isTrue(carServices.size()==0);
        
    }
    
    //test positive
    @isTest
    private static void testBulkifySendEmailWithPdfAfterOrderCreated(){
        
        List<Account> accounts=TestDataFactory.createAccounts(True);
        List<Contract> contracts=TestDataFactory.createContracts(accounts,True);
        List<Product2> cars=TestDataFactory.createCars(True);

        
        Pricebook2 priceBook=TestDataFactory.getStandardPriceBook();
               
        List<PricebookEntry> priceBookEntries=TestDataFactory.createPriceBookEntry(priceBook.Id, cars, True);
 
        List<Opportunity> opportunities=TestDataFactory.createOpportunities(priceBook.Id, accounts, False);

        for(Integer i=0;i<opportunities.size();i++){
            opportunities.get(i).StageName='Contract Sent';
            opportunities.get(i).CloseDate=opportunities.get(i).CloseDate.AddYears(i+1);
        }
        insert opportunities;
        List<OpportunityLineItem> opportunityLineItems=TestDataFactory.createOpportunityProduct(cars, opportunities, True);

        
        List<Contact> contacts=TestDataFactory.createContacts(accounts,True);
        
        List<OpportunityContactRole> opportunityContactRoles=TestDataFactory.addPrimaryContactRoleToOpportunity(opportunities,contacts,True);
        
        List<Opportunity> opp=[SELECT Id,AccountId,ContractId,StageName,(SELECT Id,IsPrimary,ContactId FROM OpportunityContactRoles) FROM Opportunity];


        List<Order> orders=TestDataFactory.createOrders(contracts,accounts,opp,True);
                               List<ContentVersion> contentVersions=TestDataFactory.createContentVersions(True);

        Test.StartTest();
        
        List<ContentDocumentLink> contentDocumentLinks=TestDataFactory.createContentDocumentLinkFromOrder(contentVersions,orders,True);
        
        Test.StopTest();
        
        Assert.isTrue(contentDocumentLinks.size()==15);
        
        

    }
    
 
    
  
    
    
}