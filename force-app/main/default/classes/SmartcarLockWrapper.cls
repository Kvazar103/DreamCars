/**
 * @description       : 
 * @author            : Nazar Voinarovych
 * @group             : 
 * @last modified on  : 11-03-2024
 * @last modified by  : Nazar Voinarovych
**/
public class SmartcarLockWrapper {
    @AuraEnabled public boolean isLocked;
    @AuraEnabled public List<SmartcarLockTypeStatusWrapper> doors;
    @AuraEnabled public List<SmartcarLockTypeStatusWrapper> windows;
    @AuraEnabled public List<SmartcarLockTypeStatusWrapper> sunroof;
    @AuraEnabled public List<SmartcarLockTypeStatusWrapper> storage;
    @AuraEnabled public List<SmartcarLockTypeStatusWrapper> chargingPort;
}