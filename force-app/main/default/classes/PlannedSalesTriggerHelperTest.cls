/**
 * @description       : 
 * @author            : Nazar Voinarovych
 * @group             : 
 * @last modified on  : 10-07-2024
 * @last modified by  : Nazar Voinarovych
**/
@isTest
public with sharing class PlannedSalesTriggerHelperTest {
    
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
                                  Condition__c='Used',Model__c='Test Model',Mileage__c=9000,VIN_Number__c=111111111,Car_Status__c='Available');
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
    private static void testPositiveCreatePlannedSales(){
        
        Trigger_Control__c triggerControl=createTriggerControl();
        insert triggerControl;
        
        Account account=createAccount();
        insert account;
                
        Product2 car=createCar();
        insert car;
        
        Pricebook2 priceBook=getStandardPriceBook();
        
        PricebookEntry pricebookEntry=createPriceBookEntry(priceBook.Id,car.Id);
        insert pricebookEntry;
        
        Opportunity opportunity=createOpportunity(priceBook,account.Id);
        opportunity.StageName='Closed Won';
        insert opportunity;
        
        OpportunityLineItem oli=createOpportunityProduct(car.Id,opportunity.Id);
        insert oli;
        
        Test.startTest();
        
        Planned_Sales__c plannedSale=createPlannedSale();
        insert plannedSale;
        
        
        Test.stopTest();
        
        Opportunity opp=[SELECT Id,Name,StageName,Amount,CloseDate,(SELECT Id,Product2.Condition__c FROM OpportunityLineItems) FROM Opportunity LIMIT 1];
        Planned_Sales__c pls=[SELECT Id,Name,Car_Type__c,Total_Amount_Earned__c,Year__c,Month__c,Count_of_Cars_Sold__c FROM Planned_Sales__c LIMIT 1];
        
        system.debug(opp);
        system.debug(pls);
        
        Assert.isTrue(opp!=null);
        Assert.isTrue(pls!=null);
        Assert.areEqual(pls.Total_Amount_Earned__c,opp.Amount);
        Assert.areEqual(pls.Count_of_Cars_Sold__c,opp.OpportunityLineItems.size());
    }
    
    //test negative
    @isTest
    private static void testNegativeCreatePlannedSale(){
        
        Trigger_Control__c triggerControl=createTriggerControl();
        insert triggerControl;
        
        Account account=createAccount();
        insert account;
                
        Product2 car=createCar();
        insert car;
        
        Pricebook2 priceBook=getStandardPriceBook();
        
        PricebookEntry pricebookEntry=createPriceBookEntry(priceBook.Id,car.Id);
        insert pricebookEntry;
        
        Opportunity opportunity=createOpportunity(priceBook,account.Id);
        //opportunity.StageName='Closed Won';
        insert opportunity;
        
        OpportunityLineItem oli=createOpportunityProduct(car.Id,opportunity.Id);
        insert oli;
        
        Test.startTest();
        
        Planned_Sales__c plannedSale=createPlannedSale();
        insert plannedSale;
        
        Test.stopTest();
        
        Opportunity opp=[SELECT Id,Name,StageName,Amount,CloseDate,(SELECT Id,Product2.Condition__c FROM OpportunityLineItems) FROM Opportunity LIMIT 1];
        Planned_Sales__c pls=[SELECT Id,Name,Car_Type__c,Total_Amount_Earned__c,Year__c,Month__c,Count_of_Cars_Sold__c FROM Planned_Sales__c LIMIT 1];
    

        Assert.isTrue(opp!=null);
        Assert.isTrue(pls!=null);
        Assert.isTrue(opp.StageName!='Closed Won');
        Assert.isTrue(pls.Total_Amount_Earned__c!=opp.Amount);
        Assert.isTrue(pls.Count_of_Cars_Sold__c!=opp.OpportunityLineItems.size());
        Assert.areEqual(pls.Total_Amount_Earned__c,0);
        Assert.areEqual(pls.Count_of_Cars_Sold__c,0);
    }
    
    //test bulkify
    @isTest
    private static void testBulkifyCreatePlannedSales(){
        
        Trigger_Control__c triggerControl=createTriggerControl();
        insert triggerControl;
        
        List<Account> accounts=new List<Account>();

        List<Product2> cars=new List<Product2>();
        
        Pricebook2 priceBook=getStandardPriceBook();
        
        List<PricebookEntry> priceBookEntries=new List<PricebookEntry>();
        List<Planned_Sales__c> plannedSalesToInsert=new List<Planned_Sales__c>();

        
        List<Opportunity> opportunities=new List<Opportunity>();
        
        List<OpportunityLineItem> opportunityLineItems=new List<OpportunityLineItem>();
        
        for(Integer i=0;i<200;i++){
            accounts.add(createAccount());
            Product2 car=createCar();
            car.VIN_Number__c+=i;
            cars.add(car);
        }
        insert accounts;
        insert cars;
        
        for(Integer i=0;i<200;i++){
            priceBookEntries.add(createPriceBookEntry(priceBook.Id,cars.get(i).Id));
        }
        insert priceBookEntries;
        
        for(Integer i=0;i<200;i++){
            Opportunity opportunity=createOpportunity(priceBook,accounts.get(i).Id);
            opportunity.StageName='Closed Won';
            opportunity.CloseDate = opportunity.CloseDate.addYears(i);
            opportunities.add(opportunity);
        }
        insert opportunities;

        
        
        for(Integer i=0;i<200;i++){
            opportunityLineItems.add(createOpportunityProduct(cars.get(i).Id,opportunities.get(i).Id));
        }
        insert opportunityLineItems;
        
        Test.StartTest();
        
        
        for(Integer i=0;i<200;i++){
            Planned_Sales__c pl = createPlannedSale();
            pl.Year__c=pl.Year__c+i;
            plannedSalesToInsert.add(pl);
        }
        
        insert plannedSalesToInsert;

        Test.StopTest();
        
        List<Planned_Sales__c> newPlannedSales=[SELECT Id,Name,Car_Type__c,Total_Amount_Earned__c,Year__c,Month__c,Count_of_Cars_Sold__c FROM Planned_Sales__c];
        List<Opportunity> newOpportunities=[SELECT Id,Name,StageName,Amount,CloseDate,(SELECT Id,Product2.Condition__c FROM OpportunityLineItems) FROM Opportunity WHERE StageName='Closed Won'];

        for(Integer i=0;i<newPlannedSales.size();i++){
            system.debug(newPlannedSales.get(i));
            system.debug(newOpportunities.get(i));
            system.debug(newPlannedSales.get(i).Total_Amount_Earned__c);
            Assert.areEqual(newPlannedSales.get(i).Total_Amount_Earned__c,newOpportunities.get(i).Amount);
        } 
       

        Assert.isTrue(newPlannedSales.size()==200);
        Assert.isTrue(newOpportunities.size()==200);
       
    }
    
    //test positive
    @isTest
    private static void testPositiveUpdatePlannedSales(){
        
        Trigger_Control__c triggerControl=createTriggerControl();
        insert triggerControl;
        
        Planned_Sales__c plannedSale=createPlannedSale();
        insert plannedSale;
        
        Account account=createAccount();
        insert account;
                
        Product2 car=createCar();
        insert car;
        
        Pricebook2 priceBook=getStandardPriceBook();
        
        PricebookEntry pricebookEntry=createPriceBookEntry(priceBook.Id,car.Id);
        insert pricebookEntry;
        
        Opportunity opportunity=createOpportunity(priceBook,account.Id);
        opportunity.StageName='Closed Won';
        insert opportunity;
        
        Opportunity opportunity2=createOpportunity(priceBook,account.Id);
        opportunity2.StageName='Closed Won';
        opportunity2.CloseDate=opportunity2.CloseDate.addYears(2);
        insert opportunity2;
        system.debug(opportunity2);
        
        OpportunityLineItem oli=createOpportunityProduct(car.Id,opportunity.Id);
        insert oli;
        
        OpportunityLineItem oli2=createOpportunityProduct(car.Id,opportunity2.Id);
        insert oli2;
        
        Test.StartTest();
        
        plannedSale.Year__c+=2;
        update plannedSale;
        
        Test.StopTest();
        
        Assert.areEqual(plannedSale.Year__c,opportunity2.CloseDate.year());
        Assert.areEqual(plannedSale.Month__c,opportunity2.CloseDate.month());

    }
    //negative test
    @isTest
    private static void testNagativeUpdatePlannedSales(){
        
        Trigger_Control__c triggerControl=createTriggerControl();
        insert triggerControl;
        
        Planned_Sales__c plannedSale=createPlannedSale();
        insert plannedSale;
        
        Account account=createAccount();
        insert account;
                
        Product2 car=createCar();
        insert car;
        
        Pricebook2 priceBook=getStandardPriceBook();
        
        PricebookEntry pricebookEntry=createPriceBookEntry(priceBook.Id,car.Id);
        insert pricebookEntry;
        
        Opportunity opportunity=createOpportunity(priceBook,account.Id);
        insert opportunity;
        
        OpportunityLineItem oli=createOpportunityProduct(car.Id,opportunity.Id);
        insert oli;
        
        Test.StartTest();
        
        plannedSale.Year__c+=2;
        update plannedSale;
        
        Test.StopTest();
        
        Assert.areNotEqual(plannedSale.Year__c,opportunity.CloseDate.year());
        Assert.areNotEqual(plannedSale.Total_Amount_Earned__c,opportunity.Amount);
        
    }
    
    //bulkify test
    @isTest
    private static void testBulkifyUpdatePlannedSales(){
        
        Trigger_Control__c triggerControl=createTriggerControl();
        insert triggerControl;
        
        List<Account> accounts=new List<Account>();
        
        Account account=createAccount();
        insert account;

        List<Product2> cars=new List<Product2>();
        
        Pricebook2 priceBook=getStandardPriceBook();
        
        List<PricebookEntry> priceBookEntries=new List<PricebookEntry>();
        List<Planned_Sales__c> plannedSales=new List<Planned_Sales__c>();

        
        List<Opportunity> opportunities=new List<Opportunity>();
        
        List<OpportunityLineItem> opportunityLineItems=new List<OpportunityLineItem>();
        
        for(Integer i=0;i<201;i++){
            //accounts.add(createAccount());
            
            Product2 car=createCar();
            car.VIN_Number__c+=i;
            cars.add(car);

        }
        //insert accounts;
        insert cars;
        
        for(Integer i=0;i<200;i++){
            Planned_Sales__c plannedSale=createPlannedSale();
            plannedSale.Year__c+=i;
            plannedSales.add(plannedSale);
        }
        insert plannedSales;
        
        for(Integer i=0;i<201;i++){
            priceBookEntries.add(createPriceBookEntry(priceBook.Id,cars.get(i).Id));
        }
        insert priceBookEntries;
        
        for(Integer i=0;i<201;i++){
            Opportunity opportunity=createOpportunity(priceBook,account.Id);
            opportunity.StageName='Closed Won';
            opportunity.CloseDate = opportunity.CloseDate.addYears(i);
            opportunities.add(opportunity);
        }
        insert opportunities;

        
        
        for(Integer i=0;i<201;i++){
            opportunityLineItems.add(createOpportunityProduct(cars.get(i).Id,opportunities.get(i).Id));
        }
        insert opportunityLineItems;
        
        Test.StartTest();
        List<Planned_Sales__c> plannedSalesToUpdate=new List<Planned_Sales__c>();
        
        for(Planned_Sales__c plannedSale:plannedSales){
            plannedSale.Year__c+=1;
            plannedSalesToUpdate.add(plannedSale);
        }
        update plannedSalesToUpdate;
        
        
        Test.StopTest();
        
        //List<Planned_Sales__c> updatedPlannedSales=[SELECT Id,Name,Car_Type__c,Total_Amount_Earned__c,Year__c,Month__c,Count_of_Cars_Sold__c FROM Planned_Sales__c ];

    }
    
}