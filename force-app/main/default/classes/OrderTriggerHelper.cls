public with sharing class OrderTriggerHelper {
    
    public static void sendEmailWhenOrderCreated(){
        
        Set<Id> orderOpportunityIds=new Set<Id>();
        Set<Id> orderIds=new Set<Id>();
        Set<Id> primaryContactIds=new Set<Id>();
        system.debug('trig');
        Map<Id,ContentDocumentLink> orderIdAndContentDocumentLink=new Map<Id,ContentDocumentLink>();
        Map<Id,ContentVersion> contactIdAndContentVersion=new Map<Id,ContentVersion>();
        
        
        Set<Id> contentDocumentLinkIds=new Set<Id>();
        
        for(Order order:(List<Order>) Trigger.new){
                    system.debug('trig');
            system.debug(order.Opportunity__c);
            system.debug(order.Id);
            system.debug(order.OriginalOrderId);
            orderOpportunityIds.add(order.Opportunity__c);
            orderIds.add(order.Id);
                    system.debug('trig');

        }

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<Messaging.EmailFileAttachment> emailAttachments=new List<Messaging.EmailFileAttachment>();
        
        List<Opportunity> opportunities=[SELECT Id,(SELECT Id,ContactId,IsPrimary FROM OpportunityContactRoles WHERE IsPrimary=true) 
                                         FROM Opportunity WHERE Id IN:orderOpportunityIds];
        
                system.debug('trig');

       if(!opportunities.isEmpty() && !orderIds.isEmpty()){
            system.debug('trig');
           system.debug(orderIds);
            //Map<Id,ContentDocumentLink> contentDocumentLinks=new Map<Id,ContentDocumentLink>([SELECT Id,ContentDocumentId,LinkedEntityId FROM ContentDocumentLink 
                                                                                             // WHERE LinkedEntityId IN:orderIds]);
           
            List<ContentDocumentLink> contentDocumentLinks=[SELECT Id,ContentDocumentId,LinkedEntityId FROM ContentDocumentLink 
                                                                                              WHERE LinkedEntityId IN:orderIds];
           for(ContentDocumentLink cdl:contentDocumentLinks){
               contentDocumentLinkIds.add(cdl.Id);
           }

           
           system.debug(contentDocumentLinks);//{}
           //system.debug(contentDocumentLinks.values());//()
           system.debug(contentDocumentLinks.size());//0
           system.debug(contentDocumentLinks!=null); //true
           system.debug(contentDocumentLinks.size()>0); //false
           system.debug(!contentDocumentLinks.isEmpty());
            system.debug('trig');
            if(contentDocumentLinks!=null){
               // system.debug(contentDocumentLinks.keySet());
                List<ContentVersion> contentVersions=[SELECT Id ,VersionData, Title, FileExtension,ContentDocumentId 
                                                      FROM ContentVersion WHERE ContentDocumentId IN:contentDocumentLinkIds];
                
                
                system.debug(contentVersions);//{}
                system.debug(contentVersions.size());//0
                system.debug(contentVersions!=null);//true
                system.debug(contentVersions.size()>0);//false
                system.debug(!contentVersions.isEmpty());
                
                if(contentVersions!=null){
                    system.debug('trig');
                    for(Opportunity opportunity:opportunities){
                        system.debug('trig');
                        for(OpportunityContactRole ocr:opportunity.OpportunityContactRoles){
                            system.debug('trig');
                            for(ContentVersion cv:contentVersions){
                                system.debug('trig');
                                //primaryContactIds.add(ocr.ContactId);
                                contactIdAndContentVersion.put(ocr.ContactId,cv);
                            }
                        } 
                    }
                    
                }
            }
            
            
            if(!primaryContactIds.isEmpty()){
                system.debug('trig');

                List<Contact> primaryContacts=[SELECT Id,Email,Name FROM Contact WHERE Id IN:contactIdAndContentVersion.keySet()];
                system.debug(1);
                if(!primaryContacts.isEmpty()){//for each opp
                    for(Contact contact:primaryContacts){
                        system.debug('trig');
                        Messaging.SingleEmailMessage email=new Messaging.SingleEmailMessage();
                        Messaging.EmailFileAttachment attachment=new Messaging.EmailFileAttachment();
                        system.debug(2);
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
                            system.debug(3);
                            //emailAttachments.add(attachment);
   
                        }
                        
                        
                    }
                    
                }
            }
        }
        
        if(!emails.isEmpty()){
            system.debug('trig4');
            Messaging.sendEmail(emails);
        }
        
    }
    
}