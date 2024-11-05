/**
 * @description       : 
 * @author            : Svyatoslav Andrushchak
 * @group             : 
 * @last modified on  : 11-05-2024
 * @last modified by  : Nazar Voinarovych
**/
public with sharing class CaseTriggerHelper {
    
    public static void createCarServiceIfCarVinNumberMatching(){
        
        // You can just filter for origin and vin code in  the loop. Don't need to query everything again
        //List<Case> newCases=[SELECT Id,SuppliedCompany,SuppliedEmail,SuppliedName,SuppliedPhone,Subject,Origin,
                                                //Reason,ProductId,CarVinCode__c,CarModel__c,CarBrand__c,Car_Service__c 
                                                //FROM Case WHERE Origin='Web Car Service' AND Id IN:Trigger.new];
        List<Case> cases=(List<Case>) Trigger.new;
        List<Case> newCases=new List<Case>();
        for(Case caseRecord:cases){
            if(caseRecord.Origin=='Web Car Service'){
                newCases.add(caseRecord.clone(True,True,True,True));
            }
        }
        
        Set<Decimal> carsVinCode=new Set<Decimal>();
        Map<Id,Car_Service__c> casesIdAndCarServicesToInsert=new Map<Id,Car_Service__c>();
        Map<Decimal,Product2> vinCodeAndCar=new Map<Decimal,Product2>();
        
        for(Case cas:newCases){
            carsVinCode.add(cas.CarVinCode__c);
        }
        List<Product2> cars=[SELECT Id,Model__c,Car_Status__c,Name,VIN_Number__c 
                            FROM Product2 WHERE VIN_Number__c IN:carsVinCode];

        if(!cars.isEmpty()){
            for(Product2 car:cars){
                vinCodeAndCar.put(car.VIN_Number__c,car);
            }
        }
            
        if(!cars.isEmpty()){
            for(Case cas:newCases){
                Product2 car=vinCodeAndCar.get(cas.CarVinCode__c);
                if(car!=null){
                    Car_Service__c carService=new Car_Service__c(Name=car.Name+' service',Car__c=car.Id,Date__c=Date.today().addDays(7));
                    casesIdAndCarServicesToInsert.put(cas.Id,carService);
                }
            }  
                
            System.debug(casesIdAndCarServicesToInsert);
            if(!casesIdAndCarServicesToInsert.isEmpty()){
                insert casesIdAndCarServicesToInsert.values();
                // it was actually easier to create a lookup on Car Services instead. In that cas you would be able to do everything in one upper loop
                for(Case cas:newCases){
                    Car_Service__c carService=casesIdAndCarServicesToInsert.get(cas.Id);
                    if(carService!=null){
                        cas.Car_Service__c=carService.Id;
                    }
                }
                update newCases;
                    
            }
                
        }
            
        
    }
}