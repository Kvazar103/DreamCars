@isTest
public with sharing class OpportunityLineItemTriggerHelperTest {
    
    private static Trigger_Control__c createTriggerControl(){ //custom setting trigger control 
        Trigger_Control__c customSetting = new Trigger_Control__c(
            Name = 'MakeActive', 
            isActive__c = true   
        );
        return customSetting;
    }
    
    private static Planned_Sales__c createPlannedSale(){
        Planned_Sales__c ps=new Planned_Sales__c(Car_Type__c='Used',Year__c=Date.today().year(),Month__c=Date.today().month());
        return ps;
    }
    
    private static Account createAccount(){
        Account acc=new Account(Name='Test Account',BillingCity='Test City',BillingStreet='Test Street',
                                BillingState='Test State',BillingCountry='Test Country',BillingPostalCode='Test Postal Code');
        return acc;
    }
    
    private static Product2 createCar(){
        Product2 car=new Product2(RecordTypeId='012WU000002S418YAC',Name='Test Car',Brand__c='Test Brand',
                                  Condition__c='Used',Model__c='Test Model',Mileage__c=9000,VIN_Number__c=111111111);
        return car;
    }
    
    private static Pricebook2 getStandardPriceBook(){
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(Id = pricebookId,IsActive = true);
        return standardPricebook;
    }
    
    private static PricebookEntry createPriceBookEntry(Id priceBookId,Id productId){
        PricebookEntry priceBookEntry=new PricebookEntry(Pricebook2Id=priceBookId,Product2Id=productId,
                                                         UnitPrice=1000,isActive=true);
        return priceBookEntry;
        
    }
    
    private static Opportunity createOpportunity(Pricebook2 priceBook,Id accountId){
        Opportunity opp=new Opportunity(Name='Test Opportunity',CloseDate=Date.today(),
                                        StageName='Prospecting',AccountId=accountId,Amount=25000,Pricebook2Id=priceBook.Id 
                                       );
        return opp;
    }
    
    private static OpportunityLineItem createOpportunityProduct(Id product2Id,Id opportunityId){
        OpportunityLineItem opportunityProduct=new OpportunityLineItem(OpportunityId=opportunityId,Product2Id=product2Id,
                                                                       Quantity=1,UnitPrice=12500);
        return opportunityProduct;
    }
    
    //test positive
    @isTest
    private static void testPositiveCheckCarStatusBeforeInsert(){
        
        Trigger_Control__c triggerControl=createTriggerControl();
        insert triggerControl;
        
        Account account=createAccount();
        insert account;
        
        Planned_Sales__c plannedSale=createPlannedSale();
        insert plannedSale;
        
        Product2 car=createCar();
        insert car;
        
        Pricebook2 priceBook=getStandardPriceBook();
        
        PricebookEntry priceBookEntry=createPriceBookEntry(priceBook.Id,car.Id);
        insert priceBookEntry;
        
        Opportunity opportunity=createOpportunity(priceBook,account.Id);
        insert opportunity;
        
        Test.StartTest();
        
        car.Car_Status__c='Reserved';
        car.reservedInOpportunity__c=true;
        update car;
        
        OpportunityLineItem opportunityProduct=createOpportunityProduct(car.Id,opportunity.Id);
        insert opportunityProduct;
            
        Test.StopTest();
        
        Opportunity opp=[SELECT Id,Name,StageName,Amount,CloseDate,ShowWarningMessage__c,(SELECT Id,Product2.Condition__c FROM OpportunityLineItems) FROM Opportunity LIMIT 1];
        
        Assert.areEqual(opp.showWarningMessage__c,true);
    }
    
    //test negative
    @isTest
    private static void testNegativeCheckCarStatusBeforeInsert(){
        
        Trigger_Control__c triggerControl=createTriggerControl();
        insert triggerControl;
        
        Account account=createAccount();
        insert account;
        
        Planned_Sales__c plannedSale=createPlannedSale();
        insert plannedSale;
        
        Product2 car=createCar();
        insert car;
        
        Pricebook2 priceBook=getStandardPriceBook();
        
        PricebookEntry priceBookEntry=createPriceBookEntry(priceBook.Id,car.Id);
        insert priceBookEntry;
        
        Opportunity opportunity=createOpportunity(priceBook,account.Id);
        insert opportunity;
        
        Test.StartTest();
        
        car.Car_Status__c='Available';
        car.reservedInOpportunity__c=true;
        update car;
        
        OpportunityLineItem opportunityProduct=createOpportunityProduct(car.Id,opportunity.Id);
        insert opportunityProduct;
        
        Test.StopTest();
        
        Assert.areEqual(opportunityProduct.Opportunity.showWarningMessage__c,false);

    }
    
    //test bulkify
    @isTest
    private static void testBulkifyCheckCarStatusBeforeInsert(){
        
        Planned_Sales__c plannedSale=createPlannedSale();
        insert plannedSale;
        
        Trigger_Control__c triggerControl=createTriggerControl();
        insert triggerControl;
        
        Pricebook2 priceBook=getStandardPriceBook();

        List<Account> accounts=new List<Account>();
        List<Product2> cars=new List<Product2>();
        List<PricebookEntry> priceBookEntries=new List<PricebookEntry>();
        List<Opportunity> opportunities=new List<Opportunity>();
        List<OpportunityLineItem> opportunityLineItems=new List<OpportunityLineItem>();
        
        for(Integer i=0;i<200;i++){
            Account account=createAccount();
            accounts.add(account);
            
            Product2 car=createCar();
            car.VIN_Number__c+=i;
            car.reservedInOpportunity__c=true;
            car.Car_Status__c='Reserved';
            cars.add(car);
        }
        
        insert accounts;
        insert cars;
        
        for(Integer i=0;i<200;i++){
            priceBookEntries.add(createPriceBookEntry(priceBook.Id,cars.get(i).Id));
        }
        insert priceBookEntries;
        
        for(Integer i=0;i<200;i++){
            opportunities.add(createOpportunity(priceBook,accounts.get(i).Id));
        }
        insert opportunities;
        
        for(Integer i=0;i<200;i++){
            opportunityLineItems.add(createOpportunityProduct(cars.get(i).Id,opportunities.get(i).Id));
        }
        insert opportunityLineItems;

    }
    
    //test positive
    @isTest
    private static void testPositiveDeleteOpportunityLineItem(){
        
        Trigger_Control__c triggerControl=createTriggerControl();
        insert triggerControl;
        
        Account account=createAccount();
        insert account;
        
        Planned_Sales__c plannedSale=createPlannedSale();
        insert plannedSale;
        
        Product2 car=createCar();
        insert car;
        
        Pricebook2 priceBook=getStandardPriceBook();
        
        PricebookEntry priceBookEntry=createPriceBookEntry(priceBook.Id,car.Id);
        insert priceBookEntry;
        
        Opportunity opportunity=createOpportunity(priceBook,account.Id);
        insert opportunity;
        
        OpportunityLineItem opportunityProduct=createOpportunityProduct(car.Id,opportunity.Id);
        insert opportunityProduct;
        
        Test.StartTest();
        
        car.Car_Status__c='Reserved';
        car.reservedInOpportunity__c=true;
        opportunity.showWarningMessage__c=true;
        
        update car;
        update opportunity;
        
        delete opportunityProduct;
        
        Test.StopTest();
        
        Assert.areEqual(opportunityProduct.Opportunity.showWarningMessage__c,false);
        
        
    }
    
    //test negative
    @isTest
    private static void testNegativeDeleteOpportunityLineItem(){
        
        Trigger_Control__c triggerControl=createTriggerControl();
        insert triggerControl;
        
        Account account=createAccount();
        insert account;
        
        Planned_Sales__c plannedSale=createPlannedSale();
        insert plannedSale;
        
        Product2 car=createCar();
        insert car;
        
        Pricebook2 priceBook=getStandardPriceBook();
        
        PricebookEntry priceBookEntry=createPriceBookEntry(priceBook.Id,car.Id);
        insert priceBookEntry;
        
        Opportunity opportunity=createOpportunity(priceBook,account.Id);
        insert opportunity;
        
        OpportunityLineItem opportunityProduct=createOpportunityProduct(car.Id,opportunity.Id);
        insert opportunityProduct;
        
        Test.StartTest();
        
        car.Car_Status__c='Available';
        car.reservedInOpportunity__c=false;
        opportunity.showWarningMessage__c=false;
        
        update car;
        update opportunity;
        
        delete opportunityProduct;
        
        Assert.areEqual(opportunityProduct.Opportunity.showWarningMessage__c,false);
        
    }
    
    //test bulkify
    @isTest
    private static void testBulkifyDeleteOpportunityLineItems(){
        
        Planned_Sales__c plannedSale=createPlannedSale();
        insert plannedSale;
        
        Trigger_Control__c triggerControl=createTriggerControl();
        insert triggerControl;
        
        Pricebook2 priceBook=getStandardPriceBook();

        List<Account> accounts=new List<Account>();
        List<Product2> cars=new List<Product2>();
        List<PricebookEntry> priceBookEntries=new List<PricebookEntry>();
        List<Opportunity> opportunities=new List<Opportunity>();
        List<OpportunityLineItem> opportunityLineItems=new List<OpportunityLineItem>();
        
        for(Integer i=0;i<200;i++){
            Account account=createAccount();
            accounts.add(account);
            
            Product2 car=createCar();
            car.VIN_Number__c+=i;
            car.reservedInOpportunity__c=true;
            car.Car_Status__c='Reserved';
            cars.add(car);
        }
        
        insert accounts;
        insert cars;
        
        for(Integer i=0;i<200;i++){
            priceBookEntries.add(createPriceBookEntry(priceBook.Id,cars.get(i).Id));
        }
        insert priceBookEntries;
        
        for(Integer i=0;i<200;i++){
            opportunities.add(createOpportunity(priceBook,accounts.get(i).Id));
        }
        insert opportunities;
        
        for(Integer i=0;i<200;i++){
            opportunityLineItems.add(createOpportunityProduct(cars.get(i).Id,opportunities.get(i).Id));
        }
        insert opportunityLineItems;
        
        Test.StartTest();
          
        delete opportunityLineItems;
        
        Test.StopTest();
    }
    

}