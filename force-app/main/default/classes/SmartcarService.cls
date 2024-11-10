/**
 * @description       : 
 * @author            : Nazar Voinarovych
 * @group             : 
 * @last modified on  : 11-05-2024
 * @last modified by  : Nazar Voinarovych
**/
public with sharing class SmartcarService {

    public static final String vehicleId='b58e098c-7fe5-4796-aa20-8452ed5e312b';

    @AuraEnabled(cacheable=true)
    public static SmartcarWrapper getVehicleAttributes() {

        HttpRequest req = new HttpRequest();

        req.setEndpoint('callout:SmartcarAPI/vehicles/'+vehicleId);
        req.setMethod('GET');
        
        Http http = new Http();

        HttpResponse res = http.send(req);
  
        if(res.getStatusCode()==200){
            System.debug('Response: ' + res.getStatus() + ' ' + res.getBody());
                
            SmartcarWrapper smartCar=(SmartcarWrapper)JSON.deserialize(res.getBody(), SmartcarWrapper.class); 

            return smartCar;
        }else{
            System.debug('Response: ' + res.getStatus() + ' ' + res.getBody());
            return null;
        }
 
    }
    @AuraEnabled(cacheable=true)
    public static SmartcarLocationWrapper getVehicleLocation(){

        HttpRequest req=new HttpRequest();

        req.setEndpoint('callout:SmartcarAPI/vehicles/'+vehicleId+'/location');
        req.setMethod('GET');

        Http http=new Http();
        HttpResponse res=http.send(req);

        if(res.getStatusCode()==200){
            System.debug('Response: ' + res.getStatus() + ' ' + res.getBody());
            SmartcarLocationWrapper location=(SmartcarLocationWrapper)JSON.deserialize(res.getBody(), SmartcarLocationWrapper.class);

            return location;
        }else{
            System.debug('Response: ' + res.getStatus() + ' ' + res.getBody());
            return null;
        }
    }
    @AuraEnabled(cacheable=true)
    public static SmartcarOdometerWrapper getVehicleOdometer(){

        HttpRequest req = new HttpRequest();

        req.setEndpoint('callout:SmartcarAPI/vehicles/'+vehicleId+'/odometer');
        req.setMethod('GET');
        
        Http http = new Http();

        HttpResponse res = http.send(req);

        if(res.getStatusCode()==200){
            System.debug('Response: ' + res.getStatus() + ' ' + res.getBody());
            SmartcarOdometerWrapper odometer=(SmartcarOdometerWrapper)JSON.deserialize(res.getBody(), SmartcarOdometerWrapper.class);

            return odometer;
        }else{
            System.debug('Response: ' + res.getStatus() + ' ' + res.getBody());
            return null;
        }
    }
    @AuraEnabled(cacheable=true)
    public static SmartcarLockWrapper getVehicleLockStatus(){

        HttpRequest req = new HttpRequest();

        req.setEndpoint('callout:SmartcarAPI/vehicles/'+vehicleId+'/security');
        req.setMethod('GET');
        
        Http http = new Http();

        HttpResponse res = http.send(req);

        if(res.getStatusCode()==200){
            System.debug('Response: ' + res.getStatus() + ' ' + res.getBody());
            SmartcarLockWrapper lockStatus=(SmartcarLockWrapper)JSON.deserialize(res.getBody(), SmartcarLockWrapper.class);

            return lockStatus;
        }else{
            System.debug('Response: ' + res.getStatus() + ' ' + res.getBody());
            return null;
        }
    }
    @AuraEnabled(cacheable=true)
    public static Integer lockOrUnlockVehicle(String action){

        HttpRequest req = new HttpRequest();

        req.setEndpoint('callout:SmartcarAPI/vehicles/'+vehicleId+'/security');
        req.setMethod('POST');
        req.setHeader('Content-Type','application/json');
        req.setBody(action);
        
        Http http = new Http();

        HttpResponse res = http.send(req);

        if(res.getStatusCode()==200){
            system.debug('Success: '+res);
            return res.getStatusCode();
        }else{
            system.debug('Error: '+res);
            return res.getStatusCode();
        }
    }
    @AuraEnabled(cacheable=true)
    public static Integer sendDestination(Decimal latitude,Decimal longitude){
        String body='{"latitude":'+latitude+',"longitude":'+longitude+'}';
        system.debug('Body: '+body);


        HttpRequest req=new HttpRequest();

        req.setEndpoint('callout:SmartcarAPI/vehicles/'+vehicleId+'/navigation/destination');
        req.setMethod('POST');
        req.setHeader('Content-Type','application/json');
        req.setBody(body);

        Http http=new Http();
        HttpResponse res=http.send(req);
        if(res.getStatusCode()==200){
            system.debug('Success: '+res);
            return res.getStatusCode();
        }else{
            system.debug('Error: '+res);
            return res.getStatusCode();
        }

    }
}