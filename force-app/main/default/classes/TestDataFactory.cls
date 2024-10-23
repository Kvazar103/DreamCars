@isTest
public class TestDataFactory {
    
    public static Trigger_Control__c createContentDocumentLinkTriggerControl(){ //custom setting trigger control 
        Trigger_Control__c customSetting = new Trigger_Control__c(
            Name = 'ContentDocumentLinkTriggerSettings', 
            isDisabled__c = false  
        );
        return customSetting;
    }
    
    public static Trigger_Control__c createPlannedSalesTriggerControl(){ //custom setting trigger control 
        Trigger_Control__c customSetting = new Trigger_Control__c(
            Name = 'PlannedSalesTriggerSettings', 
            isDisabled__c = false   
        );
        return customSetting;
    }
    public static Trigger_Control__c createCarTriggerControl(){ //custom setting trigger control 
        Trigger_Control__c customSetting = new Trigger_Control__c(
            Name = 'CarTriggerSettings', 
            isDisabled__c = false   
        );
        return customSetting;
    }
    public static Trigger_Control__c createCaseTriggerControl(){ //custom setting trigger control 
        Trigger_Control__c customSetting = new Trigger_Control__c(
            Name = 'CaseTriggerSettings', 
            isDisabled__c = false   
        );
        return customSetting;
    }
    public static Trigger_Control__c createOpportunityLineItemTriggerControl(){ //custom setting trigger control 
        Trigger_Control__c customSetting = new Trigger_Control__c(
            Name = 'OpportunityLineItemTriggerSettings', 
            isDisabled__c = false   
        );
        return customSetting;
    }
    
    public static Trigger_Control__c createOpportunityTriggerControl(){ //custom setting trigger control 
        Trigger_Control__c customSetting = new Trigger_Control__c(
            Name = 'OpportunityTriggerSettings', 
            isDisabled__c = false   
        );
        return customSetting;
    }
    
    public static List<Product2> createCars(Boolean doInsert){
        
        List<Product2> carsToInsert=new List<Product2>();
        Id carSoldRecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Product2' AND Name = 'Sold' LIMIT 1].Id;
        
        for(Integer i=0;i<75;i++){
            Product2 car=new Product2(RecordTypeId=carSoldRecordTypeId,Name='Test Car',Brand__c='Test Brand',Car_Status__c='Available',
                                      Condition__c='Used',Model__c='Test Model',Mileage__c=9000,VIN_Number__c=111111111);
            car.VIN_Number__c+=i;
            carsToInsert.add(car);
        }
        if(doInsert){
            insert carsToInsert;  
        }
        
        return carsToInsert;
        
    }
    
    public static List<Case> createCaseFromEmailToCase(List<Product2> cars,Boolean doInsert){
        
        List<Case> casesToInsert=new List<Case>();
        
        for(Integer i=0;i<75;i++){
            Case recordCase=new Case(SuppliedEmail='test@gmail.com',Description='Some Description',
                                     Subject='VIN-{'+cars.get(i).VIN_Number__c+'}',SuppliedName='Nickname',Origin='Email'); 
            casesToInsert.add(recordCase);
        }
        if(doInsert){
            insert casesToInsert;
        }
        return casesToInsert;
    }
    
    public static List<EmailMessage> createEmailMessage(List<Case> caseRecords,List<Product2> cars,Boolean doInsert){
        List<EmailMessage> emailMessagesToInsert=new List<EmailMessage>();
        
        for(Integer i=0;i<15;i++){
            
            EmailMessage emailMessage=new EmailMessage(    
                ParentId = caseRecords.get(i).Id,   // Прив'язуємо до кейса
                Subject = 'VIN-{'+cars.get(i).VIN_Number__c+'}',
                FromAddress = caseRecords.get(i).SuppliedEmail,
                ToAddress = 'nazar.voinarovych150250@1bbuyhwfhjlx3pa2xnevq1nxqwh5azbio0ur0m6ecrgenqsism.wu-9g4op2aq.swe106.case.salesforce.com',
                TextBody = 'This is a test email body.',
                Status = '3'// Draft стату             
            );
            emailMessagesToInsert.add(emailMessage);
            
        }
        if(doInsert){
            insert emailMessagesToInsert;
        }
        return emailMessagesToInsert; 
        
        
    }
    
    public static List<ContentVersion> createContentVersions(Boolean doInsert){
        
        List<ContentVersion> contentVersionsToInsert=new List<ContentVersion>();
        
        for(Integer i=0;i<15;i++){
            ContentVersion contentVersion = new ContentVersion(
                Title = 'TestFileg.pdf',
                PathOnClient = 'TestFileg.pdf',
                VersionData = Blob.valueOf('Test file content'),
                IsMajorVersion = true
            );
            contentVersionsToInsert.add(contentVersion); 
        }
        
        
        if(doInsert){
            insert contentVersionsToInsert;
        }
        
        return contentVersionsToInsert;
    }
    
    
    
    public static List<ContentDocumentLink> createContentDocumentLink(List<ContentVersion> contentVersions,List<EmailMessage> emails,Boolean doInsert){
        List<ContentDocumentLink> contentDocumentLinks=new List<ContentDocumentLink>();
        
        List<ContentDocument> contentDocuments=[SELECT Id FROM ContentDocument];
        
        for(Integer i=0;i<15;i++){
            
            ContentDocumentLink contentLink = new ContentDocumentLink(
                ContentDocumentId = contentDocuments.get(i).Id,
                LinkedEntityId = emails.get(i).Id,
                Visibility = 'AllUsers', // file access
                ShareType = 'V' // Read/Write доступ
            ); 
            
            contentDocumentLinks.add(contentLink);
        }
        if(doInsert){
            insert contentDocumentLinks;
        }
        
        return contentDocumentLinks;
    }
    
    public static List<ContentDocumentLink> createContentDocumentLinkFromOrder(List<ContentVersion> contentVersions,List<Order> orders,Boolean doInsert){
        List<ContentDocumentLink> contentDocumentLinks=new List<ContentDocumentLink>();
        
        List<ContentDocument> contentDocuments=[SELECT Id FROM ContentDocument];
        
        for(Integer i=0;i<15;i++){
            ContentDocumentLink contentLink = new ContentDocumentLink(
                ContentDocumentId = contentDocuments.get(i).Id,
                LinkedEntityId = orders.get(i).Id,
                Visibility = 'AllUsers', // file access
                ShareType = 'V' // Read/Write доступ
            ); 
            
            contentDocumentLinks.add(contentLink);
        }
        if(doInsert){
            insert contentDocumentLinks;
        }
        
        return contentDocumentLinks;
    }
    
    
    
    
    public static List<Planned_Sales__c> createPlannedSales(Boolean doInsert){
        List<Planned_Sales__c> plannedSalesToInsert=new List<Planned_Sales__c>();
        
        for(Integer i=0;i<75;i++){
            Planned_Sales__c ps=new Planned_Sales__c(Car_Type__c='Used',Year__c=Date.today().year(),Month__c=Date.today().month());
            plannedSalesToInsert.add(ps);
            
            
        }
        if(doInsert){
            insert plannedSalesToInsert;
        }
        
        return plannedSalesToInsert;
    }
    
    public static List<Account> createAccounts(Boolean doInsert){
        List<Account> accountsToInsert=new List<Account>();
        
        for(Integer i=0;i<75;i++){
            Account acc=new Account(Name='Test Account',BillingCity='Test City',BillingStreet='Test Street',
                                    BillingState='Test State',BillingCountry='Test Country',BillingPostalCode='Test Postal Code');
            accountsToInsert.add(acc);
        }
        if(doInsert){
            insert accountsToInsert;
        }
        
        return accountsToInsert;
    }
    public static List<Contact> createContacts(List<Account> accounts,Boolean doInsert){
        List<Contact> contactsToInsert=new List<Contact>();
        
        for(Integer i=0;i<75;i++){
            Contact contact=new Contact(AccountId=accounts.get(i).Id,Email='test@gmail.com',FirstName='Test',LastName='Contact');
            contactsToInsert.add(contact);
        }
        if(doInsert){
            insert contactsToInsert;
        }
        return contactsToInsert;
    }
    
    public static Pricebook2 getStandardPriceBook(){
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(Id = pricebookId,IsActive = true);
        return standardPricebook;
    }
    
    public static List<PricebookEntry> createPriceBookEntry(Id priceBookId,List<Product2> cars,Boolean doInsert){
        
        List<PricebookEntry> priceBookEntriesToInsert=new List<PricebookEntry>();
        
        for(Integer i=0;i<75;i++){
            PricebookEntry priceBookEntry=new PricebookEntry(Pricebook2Id=priceBookId,Product2Id=cars.get(i).Id,
                                                             UnitPrice=1000,isActive=true); 
            priceBookEntriesToInsert.add(priceBookEntry);
        }
        
        if(doInsert){
            insert priceBookEntriesToInsert;
        }
        
        return priceBookEntriesToInsert;
        
    }
    
    public static List<Opportunity> createOpportunities(Id priceBookId,List<Account> accounts,Boolean doInsert){
        List<Opportunity> opportunitiesToInsert=new List<Opportunity>();
        
        for(Integer i=0;i<75;i++){
            Opportunity opp=new Opportunity(Name='Test Opportunity',CloseDate=Date.today(),
                                            StageName='Prospecting',AccountId=accounts.get(i).Id,Amount=25000,Pricebook2Id=priceBookId
                                           );
            opportunitiesToInsert.add(opp);
        }
        if(doInsert){
            insert opportunitiesToInsert;
        }
        
        return opportunitiesToInsert;
    }
    
    public static List<OpportunityLineItem> createOpportunityProduct(List<Product2> cars,List<Opportunity> opportunities,Boolean doInsert){
        List<OpportunityLineItem> opportunityProducts=new List<OpportunityLineItem>();
        
        for(Integer i=0;i<75;i++){
            OpportunityLineItem opportunityProduct=new OpportunityLineItem(OpportunityId=opportunities.get(i).Id,Product2Id=cars.get(i).Id,
                                                                           Quantity=1,UnitPrice=12500);
            opportunityProducts.add(opportunityProduct);
        }
        
        if(doInsert){
            insert opportunityProducts;
        }
        
        return opportunityProducts;
    }
    
    public static List<Case> createCaseFromWebToCase(List<Product2> cars,Boolean doInsert){
        
        List<Case> casesFromWebToCaseToInsert=new List<Case>();
        
        for(Integer i=0;i<75;i++){
            Case cas=new Case(SuppliedName='Web Test Name',SuppliedPhone='99999999',SuppliedCompany='test supplied company',SuppliedEmail='test@gmail.com',
                              CarBrand__c='test car brand',CarModel__c='test car model',CarVinCode__c=cars.get(i).VIN_Number__c,Origin='Web Car Service',Reason='Breakdown',
                              Subject='test subject',Description='test description'); 
            casesFromWebToCaseToInsert.add(cas);
        }
        
        if(doInsert){
            insert casesFromWebToCaseToInsert;
        }
        
        return casesFromWebToCaseToInsert;
    }
    public static List<Contract> createContracts(List<Account> accounts,Boolean doInsert){
        List<Contract> contractsToInsert=new List<Contract>();
        for(Integer i=0;i<75;i++){
            Contract contract=new Contract(AccountId=accounts.get(i).Id,Status='Draft',StartDate=Date.today(),ContractTerm=12);
            contractsToInsert.add(contract);
        }
        if(doInsert){
            insert contractsToInsert;
        }
        return contractsToInsert;
        
    }
    public static List<OpportunityContactRole> addPrimaryContactRoleToOpportunity(List<Opportunity> opportunities,List<Contact> contacts,Boolean doInsert){
        List<OpportunityContactRole> contactRolesToInsert=new List<OpportunityContactRole>();
        
        
        for(Integer i=0;i<75;i++){
            OpportunityContactRole opportunityContactRole=new OpportunityContactRole(ContactId=contacts.get(i).Id,
                                                                                     OpportunityId=opportunities.get(i).Id,
                                                                                     IsPrimary=true);
            contactRolesToInsert.add(opportunityContactRole);
        }
        if(doInsert){
            insert contactRolesToInsert;
        }
        return contactRolesToInsert;
    }
    public static List<Order> createOrders(List<Contract> contracts,List<Account> accounts,List<Opportunity> opportunities,Boolean doInsert){
        List<Order> ordersToInsert=new List<Order>();
        Map<Id,Contract> accountIdAndContract=new Map<Id,Contract>();
        Map<Id,Opportunity> accountIdAndOpportunity=new Map<Id,Opportunity>();
        
        for(Contract contract:contracts){
            accountIdAndContract.put(contract.AccountId,contract);
        }
        for(Opportunity opportunity:opportunities){
            accountIdAndOpportunity.put(opportunity.AccountId,opportunity);
        }
        
        for(Account account:accounts){
            Contract accountContract=accountIdAndContract.get(account.Id);
            Opportunity accountOpportunity=accountIdAndOpportunity.get(account.Id);
            
            Order order=new Order(AccountId=account.Id,ContractId=accountContract.Id,OpportunityId=accountOpportunity.Id,EffectiveDate=Date.today(),Status='Draft');
            ordersToInsert.add(order);
        }
        if(doInsert){
            insert ordersToInsert;
        }
        return ordersToInsert;
        
    }
    
    
}