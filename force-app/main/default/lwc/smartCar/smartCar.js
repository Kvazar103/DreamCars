import { LightningElement,wire,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getVehicleAttributes from '@salesforce/apex/SmartcarService.getVehicleAttributes';
import getVehicleOdometer from '@salesforce/apex/SmartcarService.getVehicleOdometer';
import getVehicleLockStatus from '@salesforce/apex/SmartcarService.getVehicleLockStatus';
import lockOrUnlockVehicle from '@salesforce/apex/SmartcarService.lockOrUnlockVehicle';

export default class SmartCar extends LightningElement {

    @track vehicle;
    @track vehicleOdometer;
    @track vehicleLockStatus;
    @track isLoading=false;
    
    @wire(getVehicleAttributes)
    wiredVehicleInfo({error,data}){
        if(data){
            console.log(data);
            this.vehicle=data;
        }else{
            console.log(error);
        }
    }
    @wire(getVehicleOdometer)
    wiredVehicleOdometer({error,data}){
        if(data){
            console.log(data);
            this.vehicleOdometer=data.distance;
        }else{
            console.log(error);
        }
    }
    @wire(getVehicleLockStatus)
    wiredVehicleLockStatus({error,data}){
        if(data){
            console.log(data);
            this.vehicleLockStatus=data;
        }else{
            console.log(error);
        }
    }

    async lockUnlockButtonClick(){
        this.isLoading=true;
        if(this.vehicleLockStatus.isLocked){
           const result= await lockOrUnlockVehicle({action:'{"action":"UNLOCK"}'});
           if(result==200){
                const event=new ShowToastEvent({
                    title: 'Success!',
                    message: 'Vehicle successfully unlocked!',
                    variant:'success'
                })
                this.dispatchEvent(event);
                this.isLoading=false;

            }else{
                console.error('Error: '+result);
            }
        }else if(!this.vehicleLockStatus.isLocked){
           const result= await lockOrUnlockVehicle({action:'{"action":"LOCK"}'});
           if(result==200){
                const event=new ShowToastEvent({
                    title: 'Success!',
                    message: 'Vehicle successfully locked!',
                    variant:'success'
                        
                })
                this.dispatchEvent(event);
                this.isLoading=false      
           }else{
                console.error('Error: '+result);
           }
        }
    }

    

 


}