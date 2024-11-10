/**
 * @description       : 
 * @author            : Nazar Voinarovych
 * @group             : 
 * @last modified on  : 11-05-2024
 * @last modified by  : Nazar Voinarovych
**/
@isTest
public with sharing class CaseTriggerHelperTest {
    
    
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
    private static void testNegativeCreateCarServiceIfCarVinNumberMatching(){
        
        List<Product2> cars=TestDataFactory.createCars(True);
     
        Test.StartTest();
        
        List<Case> cases=TestDataFactory.createCaseFromWebToCase(cars, False);
        
        for(Case caseRecord:cases){
            caseRecord.Origin='Phone';
        }
        insert cases;
        
        Test.StopTest();
        
        List<Car_Service__c> carServices=[SELECT Id,Car__c,Name FROM Car_Service__c];
        
        Assert.isTrue(carServices.size()==0);

    }
        

    //test bulkify
    @isTest
    private static void testBulkifyCreateCarServiceIfCarVinNumberMatching(){

        List<Product2> cars=TestDataFactory.createCars(True);
        
        Test.StartTest();
        
        List<Case> casesToInsert=TestDataFactory.createCaseFromWebToCase(cars,True);

        Test.StopTest();
        
        List<Car_Service__c> carServices=[SELECT Id,Car__c,Name FROM Car_Service__c];
        
        Assert.isTrue(carServices.size()==75); 
    }
   
}