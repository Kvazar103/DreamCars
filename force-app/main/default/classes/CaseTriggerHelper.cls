/**
 * @description       : 
 * @author            : Svyatoslav Andrushchak
 * @group             : 
 * @last modified on  : 10-14-2024
 * @last modified by  : Svyatoslav Andrushchak
**/
public with sharing class CaseTriggerHelper {
    
    public static void createCarServiceIfCarVinNumberMatching(){
        
        // You can just filter for origin and vin code in  the loop. Don't need to query everything again
        Map<Id,Case> newCases=new Map<Id,Case>([SELECT Id,SuppliedCompany,SuppliedEmail,SuppliedName,SuppliedPhone,Subject,Origin,
                                                Reason,ProductId,CarVinCode__c,CarModel__c,CarBrand__c,Car_Service__c 
                                                FROM Case WHERE Origin='Web Car Service' AND Id IN:Trigger.new]);
        
        Set<Decimal> carsVinCode=new Set<Decimal>();
        Map<Id,Car_Service__c> casesIdAndCarServicesToInsert=new Map<Id,Car_Service__c>();
        
            for(Case cas:newCases.values()){
                carsVinCode.add(cas.CarVinCode__c);
            }
            List<Product2> cars=[SELECT Id,Model__c,Car_Status__c,Name,VIN_Number__c 
                                 FROM Product2 WHERE VIN_Number__c IN:carsVinCode];

            if(!cars.isEmpty()){
                for(Case cas:newCases.values()){
                    for(Product2 car:cars){
                        Car_Service__c carService=new Car_Service__c(Name=car.Name+' service',Car__c=car.Id,Date__c=Date.today().addDays(7));
                        casesIdAndCarServicesToInsert.put(cas.Id,carService);
                    }
                } 
                
                System.debug(casesIdAndCarServicesToInsert);
                if(!casesIdAndCarServicesToInsert.isEmpty()){
                    insert casesIdAndCarServicesToInsert.values();
                    // it was actually easier to create a lookup on Car Services instead. In that cas you would be able to do everything in one upper loop
                    for(Case cas:newCases.values()){
                        for(Car_Service__c carService: casesIdAndCarServicesToInsert.values()){
                            Case newCase=newCases.get(cas.Id);
                            if(newCase!=null){
                                newCase.Car_Service__c=carService.Id;
                            }
                        } 
                    }
                    update newCases.values();
                    
                }
                
            }
            
        
    }
}