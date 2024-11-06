/**
 * @description       : 
 * @author            : Nazar Voinarovych
 * @group             : 
 * @last modified on  : 11-06-2024
 * @last modified by  : Nazar Voinarovych
**/
public class MonthlySalesCheckNotificationQueueable implements Queueable{

    private List<Planned_Sales__c> underperfomancePlannedSales;

    public MonthlySalesCheckNotificationQueueable(List<Planned_Sales__c> plannedSales){
        this.underperfomancePlannedSales=plannedSales;
    }
    
    public void execute(QueueableContext context){
        List<User> systemAdministrators=[SELECT Id,Email,Profile.Name FROM USER WHERE Profile.Name='System Administrator'];
        List<String> adminEmails=new List<String>();

        if(!systemAdministrators.isEmpty()){
            for(User user:systemAdministrators){
                adminEmails.add(user.Email);
            }
        }
        String emailBody='Underperfomance Planned Sales records:';

        for(Planned_Sales__c plannedSale:underperfomancePlannedSales){
            emailBody+='Record Id: '+plannedSale.Id+'Total Amount Earned: '+plannedSale.Total_Amount_Earned__c+'Planned Total Amount: '+plannedSale.Planned_Total_Amount__c+'\n';
        }
        Messaging.SingleEmailMessage email=new Messaging.SingleEmailMessage();
        email.setToAddresses(adminEmails);
        email.setSubject('Underperfoming Planned Sales records');
        email.setPlainTextBody(emailBody);

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});//sent emails

    }

}