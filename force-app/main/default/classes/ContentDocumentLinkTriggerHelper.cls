public with sharing class ContentDocumentLinkTriggerHelper {
    
    public static void processInsertedContentDocumentLinks(){
        
        List<ContentDocumentLink> cdlList = [SELECT Id,ContentDocumentId,LinkedEntityId 
                                             FROM ContentDocumentLink WHERE Id IN:Trigger.new 
                                             AND LinkedEntityId IN (SELECT Id FROM EmailMessage)];
        
        
        Set<Id> emailIds=new Set<Id>();
        
        Set<Id> emailMessageIds=new Set<Id>();
        
        Set<Id> caseIds=new Set<Id>();
        
        Set<Integer> carsVinCode=new Set<Integer>();
        
        Map<Id,Car_Service__c> casesIdAndCarServicesToInsert=new Map<Id,Car_Service__c>();
        
        List<ContentDocumentLink> newLinks=new List<ContentDocumentLink>();
        
        if(!cdlList.isEmpty()){
            for(ContentDocumentLink cl:cdlList){
                emailMessageIds.add(cl.LinkedEntityId);
            }
            
            if(!emailMessageIds.isEmpty()){
                List<EmailMessage> emailMessages=[SELECT Id,HasAttachment,ParentId,Subject,RelatedToId,AttachmentIds,ContentDocumentIds
                                                  FROM EmailMessage WHERE Id IN:emailMessageIds];
                if(!emailMessages.isEmpty() ){
                    for(EmailMessage emailMessage:emailMessages){
                        caseIds.add(emailMessage.ParentId);
                        String subject=emailMessage.Subject;
                        
                        Pattern pattern=Pattern.compile('VIN-\\{(\\d+)\\}');
                        Matcher matcher=pattern.matcher(subject);
                        if(matcher.find()){
                            String vinCode=matcher.group(1);
                            Integer code=Integer.valueOf(vinCode);
                            carsVinCode.add(code);
                        }
                    }
                }
                if(!caseIds.isEmpty()){
                    Map<Id,Case> caseMap=new Map<Id,Case>([SELECT Id,Origin,Description,Subject,CarVinCode__c,Car_Service__r.Id FROM Case 
                                                           WHERE Origin='Email' AND Id IN:caseIds]);
                    
                    if(!caseMap.isEmpty()){
                        List<Product2> cars=[SELECT Id,Model__c,Car_Status__c,Name,VIN_Number__c 
                                             FROM Product2 WHERE VIN_Number__c IN:carsVinCode];
                        
                        if(!cars.isEmpty()){
                            for(Case caseRecord:caseMap.values()){
                                for(Product2 car:cars){
                                    Car_Service__c carService=new Car_Service__c(Name=car.Name+' service',Car__c=car.Id,Date__c=Date.today().addDays(7));
                                    casesIdAndCarServicesToInsert.put(caseRecord.Id,carService);
                                }
                            }
                            if(!casesIdAndCarServicesToInsert.isEmpty()){
                                insert casesIdAndCarServicesToInsert.values();
                                for(Case caseRecord:caseMap.values()){
                                    for(Car_Service__c carService:casesIdAndCarServicesToInsert.values()){
                                        Case createdCase=caseMap.get(caseRecord.Id);
                                        if(createdCase!=null){
                                            createdCase.Car_Service__c=carService.Id;
                                            
                                        }
                                    }
                                }
                                update caseMap.values();
                            }
                            for(EmailMessage emailMessage:emailMessages){
                                
                                for(ContentDocumentLink link:cdlList){
                                    Car_Service__c carService=casesIdAndCarServicesToInsert.get(emailMessage.ParentId);
                                    Case cas=caseMap.get(emailMessage.ParentId);
                                    if(carService!=null){
                                        ContentDocumentLink newLink = new ContentDocumentLink();
                                        newLink.ContentDocumentId = link.ContentDocumentId;
                                        newLink.LinkedEntityId = carService.Id;
                                        newLink.ShareType = 'V'; // type of access ('V' - View, 'C' - Collaborate)
                                        newLink.Visibility = 'AllUsers'; // file access
                                        newLinks.add(newLink);
                                    }
                                }
                                
                            }   
                        }
                        if(!newLinks.isEmpty()){
                            insert newLinks;
                        } 
                    }
                } 
            }
        } 
    }
    public static void sendEmailWithPdfAfterOrderCreated(){
        
        Map<Id,ContentDocumentLink> cdlList = new Map<Id,ContentDocumentLink>([SELECT Id,ContentDocumentId,LinkedEntityId 
                                                                               FROM ContentDocumentLink WHERE Id IN:Trigger.new 
                                                                               AND LinkedEntityId IN (SELECT Id FROM Order)]);
        Set<Id> orderIds=new Set<Id>();
        Set<Id> opportunityIds=new Set<Id>();
        Set<Id> contentDocumentIds=new Set<Id>();
        
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<Messaging.EmailFileAttachment> emailAttachments=new List<Messaging.EmailFileAttachment>();
        
        Map<Id,ContentVersion> contactIdAndContentVersion=new Map<Id,ContentVersion>();
        if(!cdlList.isEmpty()){
            for(ContentDocumentLink cdl:cdlList.values()){
                orderIds.add(cdl.LinkedEntityId);
                contentDocumentIds.add(cdl.ContentDocumentId);
            }
  
            List<ContentVersion> contentVersions=[SELECT Id ,VersionData, Title, FileExtension,ContentDocumentId 
                                                  FROM ContentVersion WHERE ContentDocumentId IN:contentDocumentIds];
            
            if(!orderIds.isEmpty()) {
                List<Order> orders=[SELECT Id,Name,Opportunity__c FROM Order WHERE Id IN:orderIds];
                if(!orders.isEmpty()){
                    for(Order order:orders){
                        opportunityIds.add(order.Opportunity__c);
                    }
                }
                if(!opportunityIds.isEmpty()){
                    List<Opportunity> opportunities=[SELECT Id,(SELECT Id,ContactId,IsPrimary FROM OpportunityContactRoles WHERE IsPrimary=true) 
                                                     FROM Opportunity WHERE Id IN:opportunityIds];
                    List<OpportunityContactRole> opportunityContactRoles=[SELECT Id,ContactId,IsPrimary,OpportunityId FROM OpportunityContactRole 
                                                   WHERE IsPrimary=true AND OpportunityId IN:opportunityIds];
                    
                    if(!contentVersions.isEmpty()){
                        //for(Opportunity opportunity:opportunities){
                            //if (opportunity.OpportunityContactRoles != null && !opportunity.OpportunityContactRoles.isEmpty()) {
                                for(OpportunityContactRole ocr:opportunityContactRoles){
                                    for(ContentVersion cv:contentVersions){
                                        contactIdAndContentVersion.put(ocr.ContactId,cv);
                                    }
                                }
                            //}
                        //}
                    }
                }
                if(!contactIdAndContentVersion.isEmpty()){
                    
                    List<Contact> primaryContacts=[SELECT Id,Email,Name FROM Contact WHERE Id IN:contactIdAndContentVersion.keySet()];

                    if(!primaryContacts.isEmpty()){
                        for(Contact contact:primaryContacts){

                            Messaging.SingleEmailMessage email=new Messaging.SingleEmailMessage();
                            Messaging.EmailFileAttachment attachment=new Messaging.EmailFileAttachment();

                            ContentVersion cv=contactIdAndContentVersion.get(contact.Id);
                            if(cv!=null){
                                Blob filePdf=cv.VersionData;//file in format blob(version data)
                                String fileName=cv.Title+'.'+cv.FileExtension;
                                
                                email.setTargetObjectId(contact.Id); 
                                email.setSubject(contact.Name+ '.Order created!');
                                email.setPlainTextBody('Hello, '+contact.Name+'.Order has been created!');
                                
                                attachment.setFileName(fileName);
                                attachment.setBody(filePdf);
                                attachment.setContentType('application/pdf'); // MIME type (pdf)
                                
                                email.setFileAttachments(new Messaging.EmailFileAttachment[] {attachment});
                                emails.add(email);
                                
                            }
 
                        }
                        
                    }
                }
            }

        }
        if(!emails.isEmpty()){
            Messaging.sendEmail(emails);
        }

    }
    
}