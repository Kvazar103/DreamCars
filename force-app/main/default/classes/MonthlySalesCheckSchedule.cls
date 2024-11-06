/**
 * @description       : 
 * @author            : Nazar Voinarovych
 * @group             : 
 * @last modified on  : 11-06-2024
 * @last modified by  : Nazar Voinarovych
**/
public class MonthlySalesCheckSchedule implements Schedulable{
    public void execute(SchedulableContext ctx){
        Database.executeBatch(new MonthlySalesCheckBatch(),200);//200 records
    }
    

}