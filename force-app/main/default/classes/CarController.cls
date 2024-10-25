/**
 * @description       : 
 * @author            : Nazar Voinarovych
 * @group             : 
 * @last modified on  : 10-25-2024
 * @last modified by  : Nazar Voinarovych
**/
public with sharing class CarController {
    
    @AuraEnabled(cacheable=true)
    public static List<String> getCarModels(){
        List<String> models=new List<String>();

        List<Car_Model__mdt> carModels=[SELECT DeveloperName FROM Car_Model_mdt];
        for(Car_Model__mdt carModel:carModels){
            models.add(carModel.DeveloperName);
        }
        return models;
        
    }
    @AuraEnabled(cacheable=true)
    public static List<String> getCarBrands(){
        List<String> brands=new List<String>();

        List<Car_Brand__mdt> carBrands=[SELECT DeveloperName FROM Car_Brand__mdt];
        for(Car_Brand_mdt carBrand:carBrands){
            brands.add(carBrand);
        }
        return brands;
    }
}