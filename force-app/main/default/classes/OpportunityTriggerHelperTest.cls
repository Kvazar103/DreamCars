/**
 * @description       : 
 * @author            : Nazar Voinarovych
 * @group             : 
 * @last modified on  : 10-07-2024
 * @last modified by  : Nazar Voinarovych
**/

@isTest
public with sharing class OpportunityTriggerHelperTest {
    
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
    
    //private static Pricebook2 createPriceBook(){
        //Pricebook2 priceBook=new Pricebook2(Name='Test Pricebook',isActive=true);
        
        //return priceBook;
    //}
    
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
    private static void testPositiveOpportunityClose(){
        
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
        
        Test.startTest();
        
        opportunity.StageName='Closed Won';
        update opportunity;
        
        Test.stopTest();
        
        Opportunity newOpportunity=[SELECT Id,Name,StageName,Amount,CloseDate,(SELECT Id,Product2.Condition__c FROM OpportunityLineItems) FROM Opportunity LIMIT 1];
        Planned_Sales__c newPlannedSale=[SELECT Id,Name,Car_Type__c,Total_Amount_Earned__c,Year__c,Month__c,Count_of_Cars_Sold__c FROM Planned_Sales__c LIMIT 1];
        OpportunityLineItem oli=[SELECT Id,Product2.Condition__c FROM OpportunityLineItem];

        
        system.assert(newOpportunity!=null);
        system.assert(newPlannedSale!=null);
        system.assertEquals(newOpportunity.StageName,'Closed Won');
        system.assertEquals(newPlannedSale.Year__c,newOpportunity.CloseDate.year());
        system.assertEquals(newPlannedSale.Month__c,newOpportunity.CloseDate.month());
        system.assertEquals(newPlannedSale.Total_Amount_Earned__c,newOpportunity.Amount);
        system.assertEquals(newPlannedSale.Count_of_Cars_Sold__c,newOpportunity.OpportunityLineItems.size());
        system.assertEquals(newPlannedSale.Car_Type__c,oli.Product2.Condition__c);

    }
    
    //test negative
    @isTest
    private static void testNegativeOpportunityClose(){
        
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
        
        opportunity.StageName='Contract Sent';
        upsert opportunity;

        Test.StopTest();
        
        Opportunity newOpportunity=[SELECT Id,Name,StageName,Amount,CloseDate,(SELECT Id,Product2.Condition__c FROM OpportunityLineItems) FROM Opportunity LIMIT 1];
        OpportunityLineItem oli=[SELECT Id,Product2.Condition__c FROM OpportunityLineItem];
        Planned_Sales__c newPlannedSale=[SELECT Id,Name,Car_Type__c,Total_Amount_Earned__c,Year__c,Month__c,Count_of_Cars_Sold__c FROM Planned_Sales__c LIMIT 1];
         
        system.assert(newOpportunity!=null);
        system.assert(newPlannedSale!=null);
        system.assertEquals(newOpportunity.StageName,'Contract Sent');
        system.assert(newPlannedSale.Total_Amount_Earned__c!=newOpportunity.Amount);
        system.assert(newPlannedSale.Count_of_Cars_Sold__c!=newOpportunity.OpportunityLineItems.size());

    }
    
    //test bulkify
    @isTest
    private static void testBulkifyOpportunityClosed(){
        
        List<Account> accounts=new List<Account>();

        List<Product2> cars=new List<Product2>();
        
        Pricebook2 priceBook=getStandardPriceBook();
        List<PricebookEntry> priceBookEntries=new List<PricebookEntry>();
        
        List<Opportunity> opportunities=new List<Opportunity>();
        
        Planned_Sales__c pls=createPlannedSale();
        insert pls;
        
        List<OpportunityLineItem> opportunityLineItems=new List<OpportunityLineItem>();
        
        for(Integer i=0;i<200;i++){
            accounts.add(createAccount());
            //plannedSales.add(createPlannedSale());
            Product2 car=createCar();
            car.VIN_Number__c+=i;
            cars.add(car);
        }
        insert accounts;
        //insert plannedSales;
        
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
        //try{
            for(Opportunity opp:opportunities){
                opp.StageName='Closed Won';
            }
            update opportunities;
            
       //}catch (DmlException e){
           //System.debug('Помилка DML-операції: ' + e.getMessage()); // Виведення повідомлення про помилку
           //System.debug('Тип винятку: ' + e.getTypeName()); // Тип винятку
           //System.debug('Стек трейс: ' + e.getStackTraceString()); // Деталі про місце помилки в коді
           //System.debug('Кількість рядків з помилкою: ' + e.getNumDml()); // Скільки DML операцій викликало помилку
           //System.debug('Ідентифікатори записів з помилками: ' + e.getDmlId(0)); // Ідентифікатори записів, де сталась помилка
           //system.debug('Cause'+ e.getCause());
            //system.debug('getDmlFieldNames= '+e.getDmlFieldNames(0));
            //system.debug('getDmlMessage= '+e.getDmlMessage(0));
        //}
        
        Test.StopTest();
        
        List<Opportunity> opp=[SELECT Id,Name,StageName,Amount,CloseDate,(SELECT Id,Product2.Condition__c FROM OpportunityLineItems) FROM Opportunity];
        AggregateResult[] totalAmount=[SELECT SUM(Amount)totalAmount FROM Opportunity];
        Planned_Sales__c newPlannedSale=[SELECT Id,Name,Car_Type__c,Total_Amount_Earned__c,Year__c,Month__c,Count_of_Cars_Sold__c FROM Planned_Sales__c LIMIT 1];
        
        system.assert(opp.size()==200);
        system.assertEquals(newPlannedSale.Total_Amount_Earned__c,totalAmount[0].get('totalAmount'));
        system.assertEquals(newPlannedSale.Count_of_Cars_Sold__c,200);

    }
    
    //positive delete opportunity
    @isTest
    private static void testPositiveDeleteOpportunity(){
        
        Account account=createAccount();
        insert account;
        
        Planned_Sales__c plannedSale=createPlannedSale();
        insert plannedSale;
        
        Pricebook2 priceBook=getStandardPriceBook();
        
        Product2 car=createCar();
        insert car;
        
        PricebookEntry priceBookEntry=createPriceBookEntry(priceBook.Id,car.Id);
        insert priceBookEntry;
        
        Opportunity opportunity=createOpportunity(priceBook,account.Id);
        insert opportunity;
        
        OpportunityLineItem opportunityProduct=createOpportunityProduct(car.Id,opportunity.Id);
        insert opportunityProduct;
        
        Test.StartTest();
        
        opportunity.StageName='Closed Won';
        update opportunity; 
        
        delete opportunity;
        
        Test.StopTest();
        
        Planned_Sales__c ps=[SELECT Id,Name,Car_Type__c,Total_Amount_Earned__c,Year__c,Month__c,Count_of_Cars_Sold__c FROM Planned_Sales__c LIMIT 1];
        
        system.assertEquals(opportunity.CloseDate.month(),plannedSale.Month__c);
        system.assertEquals(opportunity.CloseDate.year(),plannedSale.Year__c);
        system.assert(ps.Total_Amount_Earned__c==0);
        system.assert(ps.Count_of_Cars_Sold__c==0);
        
    }
    
    //negative test delete
    @isTest
    private static void testNegativeDeleteOpportunity(){
        Account account=createAccount();
        insert account;
        
        Planned_Sales__c plannedSale=createPlannedSale();
        insert plannedSale;
        
        Pricebook2 priceBook=getStandardPriceBook();
        
        Product2 car=createCar();
        insert car;
        
        PricebookEntry priceBookEntry=createPriceBookEntry(priceBook.Id,car.Id);
        insert priceBookEntry;
        
        Opportunity opportunity=createOpportunity(priceBook,account.Id);
        insert opportunity;
        
        OpportunityLineItem opportunityProduct=createOpportunityProduct(car.Id,opportunity.Id);
        insert opportunityProduct;
        
        Test.StartTest();
        
        delete opportunity;
        
        Test.StopTest();
        
        system.assertEquals(opportunity.CloseDate.month(),plannedSale.Month__c);
        system.assertEquals(opportunity.CloseDate.year(),plannedSale.Year__c);
        system.assertEquals(plannedSale.Total_Amount_Earned__c,opportunity.Amount);
        system.assertEquals(plannedSale.Count_of_Cars_Sold__c,opportunity.OpportunityLineItems.size());
    }
    
    //bulkify test delete
    @isTest
    private static void testBulkifyDeleteOpportunity(){
        List<Account> accounts=new List<Account>();

        List<Product2> cars=new List<Product2>();
        
        Pricebook2 priceBook=getStandardPriceBook();
        
        List<PricebookEntry> priceBookEntries=new List<PricebookEntry>();
        
        List<Opportunity> opportunities=new List<Opportunity>();
        
        Planned_Sales__c pls=createPlannedSale();
        insert pls;
        
        List<OpportunityLineItem> opportunityLineItems=new List<OpportunityLineItem>();
        
        for(Integer i=0;i<200;i++){
            accounts.add(createAccount());
            //plannedSales.add(createPlannedSale());
            Product2 car=createCar();
            car.VIN_Number__c+=i;
            cars.add(car);
        }
        insert accounts;
        //insert plannedSales;
        
        insert cars;
        
        for(Integer i=0;i<200;i++){
            priceBookEntries.add(createPriceBookEntry(priceBook.Id,cars.get(i).Id));
        }
        insert priceBookEntries;
        
        for(Integer i=0;i<200;i++){
            Opportunity opportunity=createOpportunity(priceBook,accounts.get(i).Id);
            opportunity.StageName='Closed Won';
            opportunities.add(opportunity);
        }
        insert opportunities;
        
        for(Integer i=0;i<200;i++){
            opportunityLineItems.add(createOpportunityProduct(cars.get(i).Id,opportunities.get(i).Id));
        }
        insert opportunityLineItems;
        
        Test.StartTest();

        delete opportunities;
        
        Test.StopTest();
        
        Planned_Sales__c planed=[SELECT Id,Name,Car_Type__c,Total_Amount_Earned__c,Year__c,Month__c,Count_of_Cars_Sold__c FROM Planned_Sales__c LIMIT 1];
        system.debug(planed.Total_Amount_Earned__c);

        system.assertEquals(planed.Total_Amount_Earned__c,0);
        system.assertEquals(planed.Count_of_Cars_Sold__c,0);
        
    }
    

}