/**
 * @description       : 
 * @author            : Nazar Voinarovych
 * @group             : 
 * @last modified on  : 11-04-2024
 * @last modified by  : Nazar Voinarovych
**/

@isTest
public with sharing class SmartcarServiceTest {
    public static final String vehicleId='b58e098c-7fe5-4796-aa20-8452ed5e312b';

    @isTest
    private static void testSmartcarAPI(){

        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource('callout:SmartcarAPI/vehicles/'+vehicleId, 'jsonVehicleAttributes');
        multimock.setStaticResource('callout:SmartcarAPI/vehicles/'+vehicleId+'/location', 'jsonVehicleLocation');
        multimock.setStaticResource('callout:SmartcarAPI/vehicles/'+vehicleId+'/odometer', 'jsonVehicleOdometer');
        multimock.setStaticResource('callout:SmartcarAPI/vehicles/'+vehicleId+'/security', 'jsonVehicleLockStatus');
        multimock.setStaticResource('callout:SmartcarAPI/vehicles/'+vehicleId+'/navigation/destination', 'jsonVehicleDestination');

        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, multimock);

        Test.startTest();

        SmartcarWrapper vehicle=SmartcarService.getVehicleAttributes();
        SmartcarLocationWrapper location=SmartcarService.getVehicleLocation();
        SmartcarOdometerWrapper odometer=SmartcarService.getVehicleOdometer();
        SmartcarLockWrapper lockStatus=SmartcarService.getVehicleLockStatus();
        Integer lockVehicleStatus=SmartcarService.lockOrUnlockVehicle('{"action": "LOCK"}');
        Integer destinationStatus=SmartcarService.sendDestination('{"latitude": 51.5007, "longitude" : 0.1246}');


        Test.stopTest();

        Assert.areEqual('TESLA', vehicle.make);
        Assert.areEqual('Model S', vehicle.model);
        Assert.areEqual('2014', vehicle.year);

        Assert.areEqual(122.1381,location.longitude);
        Assert.areEqual(37.4292, location.latitude);
        Assert.areEqual(104.32,odometer.distance);

        Assert.areEqual(false, lockStatus.isLocked);
        Assert.isTrue(lockStatus.doors!=null);
        Assert.isTrue(lockStatus.windows!=null);

        Assert.areEqual('frontLeft',lockStatus.doors.get(0).type);
        Assert.areEqual('CLOSED',lockStatus.doors.get(0).status);
        Assert.areEqual('frontRight',lockStatus.doors.get(1).type);
        Assert.areEqual('OPEN',lockStatus.doors.get(1).status);
        Assert.areEqual('backRight',lockStatus.doors.get(2).type);
        Assert.areEqual('CLOSED',lockStatus.doors.get(2).status);
        Assert.areEqual('backLeft',lockStatus.doors.get(3).type);
        Assert.areEqual('CLOSED',lockStatus.doors.get(3).status);

        Assert.areEqual('frontLeft',lockStatus.windows.get(0).type);
        Assert.areEqual('CLOSED',lockStatus.windows.get(0).status);
        Assert.areEqual('frontRight',lockStatus.windows.get(1).type);
        Assert.areEqual('CLOSED',lockStatus.windows.get(1).status);
        Assert.areEqual('backRight',lockStatus.windows.get(2).type);
        Assert.areEqual('UNKNOWN',lockStatus.windows.get(2).status);
        Assert.areEqual('backLeft',lockStatus.windows.get(3).type);
        Assert.areEqual('CLOSED',lockStatus.windows.get(3).status);

        Assert.isTrue(lockVehicleStatus==200);
        Assert.isTrue(destinationStatus==200);
     

    }
   
}