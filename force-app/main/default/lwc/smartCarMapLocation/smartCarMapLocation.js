import { LightningElement ,wire,track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getVehicleLocation from '@salesforce/apex/SmartcarService.getVehicleLocation';
import sendDestination from '@salesforce/apex/SmartcarService.sendDestination';

export default class SmartCarMapLocation extends LightningElement {

    @track mapMarkers=[];
    @track mapCenter={};

    latitude;
    longitude;

    @wire(getVehicleLocation)
    wiredVehicleLocation({error,data}){
        if(data){
            console.log(data);
            this.mapMarkers=[
                {
                    location: {
                        Latitude: data.latitude,
                        Longitude: data.longitude
                    },
                    title: 'Location', 
                    description: 'This is the location of your car.'
                }
            ]
            this.mapCenter = {
                Latitude: data.latitude,
                Longitude: data.longitude
            };
        }else{
            console.log(error);
        }
    }
    onLocationChange(event){
        this.latitude=event.detail.latitude;
        this.longitude=event.detail.longitude;
    }

    async onLocationClick(){
        const result=await sendDestination({latitude:this.latitude,longitude:this.longitude});
            if(result==200){
                this.mapMarkers=[
                    {
                        location: {
                            Latitude: this.latitude,
                            Longitude: this.longitude
                        },
                        title: 'Location', 
                        description: 'This is the location of your car.'
                    }
                ]
                this.mapCenter = {
                    Latitude: this.latitude,
                    Longitude: this.longitude
                };
                const event=new ShowToastEvent({
                    title: 'Success!',
                    message: 'Vehicle location changed!',
                    variant:'success'
                })
                this.dispatchEvent(event);
            }else{
                const event=new ShowToastEvent({
                    title: 'Error!',
                    message: 'Error!',
                    variant:'error'
                })
                this.dispatchEvent(event);
            }
    }
}