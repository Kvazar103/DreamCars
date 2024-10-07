/**
 * @description       : 
 * @author            : Svyatoslav Andrushchak
 * @group             : 
 * @last modified on  : 10-07-2024
 * @last modified by  : Svyatoslav Andrushchak
**/
@isTest
public with sharing class PlannedSalesTriggerHelperTest {
    
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
    private static void testPositiveCreatePlannedSales(){
        
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
        
        system.assert(opp!=null);
        system.assert(pls!=null);
        system.assertEquals(pls.Total_Amount_Earned__c,opp.Amount);
        system.assertEquals(pls.Count_of_Cars_Sold__c,opp.OpportunityLineItems.size());
    }
    
    //test negative
    @isTest
    private static void testNegativeCreatePlannedSale(){
        
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
    

        system.assert(opp!=null);
        system.assert(pls!=null);
        system.assert(opp.StageName!='Closed Won');
        system.assert(pls.Total_Amount_Earned__c!=opp.Amount);
        system.assert(pls.Count_of_Cars_Sold__c!=opp.OpportunityLineItems.size());
        system.assertEquals(pls.Total_Amount_Earned__c,0);
        system.assertEquals(pls.Count_of_Cars_Sold__c,0);
    }
    
    //test bulkify
    @isTest
    private static void testBulkifyCreatePlannedSales(){
        
        List<Account> accounts=new List<Account>();

        List<Product2> cars=new List<Product2>();
        
        Pricebook2 priceBook=getStandardPriceBook();
        
        List<PricebookEntry> priceBookEntries=new List<PricebookEntry>();
        List<Planned_Sales__c> plannedSalesToInsert=new List<Planned_Sales__c>();

        
        List<Opportunity> opportunities=new List<Opportunity>();
        
        //Planned_Sales__c pls=createPlannedSale();
        //insert pls;
        
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
            //system.assertEquals(newPlannedSales.get(i).Total_Amount_Earned__c,newOpportunities.get(i).Amount);
        }
       

        system.assert(newPlannedSales.size()==200);
        system.assert(newOpportunities.size()==200);
        //system.assert
        
        
    }
}