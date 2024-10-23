public with sharing class OrderController {
    
    @AuraEnabled
    public static Id createOrderFromModalWithPDF(Id opportunityId){
        
        Opportunity opportunity=[SELECT Id,Name,AccountId,ContractId FROM Opportunity WHERE Id=:opportunityId];
        
        Order newOrder=new Order(AccountId=opportunity.AccountId,
                                 Opportunity__c=opportunity.Id,
                                 Status='Draft',
                                 EffectiveDate=Date.today()
                                );
        insert newOrder;
        return newOrder.id; 
    }
    
    @AuraEnabled
    public static void attachPDFtoOrder(Id orderId,String pdfUrl){
        
        PageReference pdfPage=new PageReference(pdfUrl);
        Blob pdfBlob=pdfPage.getContentAsPDF();
        
        ContentVersion contentVersion=new ContentVersion(Title='Order PDF',
                                                         PathOnClient='Order.pdf',
                                                         VersionData=pdfBlob,
                                                         FirstPublishLocationId=orderId);
        insert contentVersion;
        
    }
    
}