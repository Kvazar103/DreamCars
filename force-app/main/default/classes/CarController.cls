/**
 * @description       : 
 * @author            : Nazar Voinarovych
 * @group             : 
 * @last modified on  : 10-26-2024
 * @last modified by  : Nazar Voinarovych
**/
public with sharing class CarController {
    
    @AuraEnabled(cacheable=true)
    public static List<String> getCarModels(){
        List<String> models=new List<String>();

        List<Car_Model__mdt> carModels=Car_Model__mdt.getAll().values();
        for(Car_Model__mdt carModel:carModels){
            models.add(carModel.DeveloperName);
        }
        return models;
        
    }
    @AuraEnabled(cacheable=true)
    public static List<String> getCarBrands(){
        List<String> brands=new List<String>();
       
        List<Car_Brand__mdt> carBrands=Car_Brand__mdt.getAll().values();

        for(Car_Brand__mdt carBrand:carBrands){
            brands.add(carBrand.DeveloperName);
        }
        return brands;
    }
    @AuraEnabled(cacheable=true)
    public static List<String> getCarFuelTypes(){
        List<String> fuelTypes=new List<String>();
       
        List<Fuel_Type__mdt> carFuelTypes=Fuel_Type__mdt.getAll().values();

        for(Fuel_Type__mdt fuelType:carFuelTypes){
            fuelTypes.add(fuelType.DeveloperName);
        }
        return fuelTypes;
    }
    @AuraEnabled(cacheable=true)
    public static List<String> getCarDriveTypes(){
        List<String> driveTypes=new List<String>();
       
        List<Drive_Type__mdt> carDriveTypes=Drive_Type__mdt.getAll().values();

        for(Drive_Type__mdt driveType:carDriveTypes){
            driveTypes.add(driveType.DeveloperName);
        }
        return driveTypes;
    }
    @AuraEnabled(cacheable=true)
    public static List<String> getCarTransmissionType(){
        List<String> transmissionTypes=new List<String>();
       
        List<Transmission_Type__mdt> carTransmissionTypes=Transmission_Type__mdt.getAll().values();

        for(Transmission_Type__mdt transmissionType:carTransmissionTypes){
            transmissionTypes.add(transmissionType.DeveloperName);
        }
        return transmissionTypes;
    }
    @AuraEnabled(cacheable=true)
    public static List<String> getCarCondition(){
        List<String> conditions=new List<String>();
       
        List<Condition__mdt> carConditions=Condition__mdt.getAll().values();

        for(Condition__mdt condition:carConditions){
            conditions.add(condition.DeveloperName);
        }
        return conditions;
    }
    
    @AuraEnabled(cacheable=true)
    public static Product2 getCarBySpecifica(String model,String brand,String year,String condition,String driveType,
    String fuelType,String transmissionType,String safetyRating){
        return [
            SELECT Id,
            Model__c,
            Brand__c,
            Car_Status__c,
            Condition__c,
            Drive_Type__c,
            Engine_Power__c,
            Sale_Price__c,
            Fuel_Type__c,
            Mileage__c,
            Transmission_Type__c,
            Year_of_Manufacture__c,
            Discount_Made__c,
            Safety_Rating__c
            FROM Product2
            WHERE Model__c=:model 
            AND Brand__c=:brand
            AND Year_of_Manufacture__c=:Decimal.valueOf(year)
            AND Condition__c=:condition
            AND Drive_Type__c=:driveType
            AND Fuel_Type__c=:fuelType
            AND Transmission_Type__c=:transmissionType
            AND Safety_Rating__c=:safetyRating
            WITH SECURITY_ENFORCED LIMIT 1
        ];
        
    }
}