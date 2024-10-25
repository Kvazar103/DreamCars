import { LightningElement,track,wire } from 'lwc';

import getCarModels from '@salesforce/apex/CarController.getCarModels';
import getCarBrands from '@salesforce/apex/CarController.getCarBrands';

export default class CarSelectionModal extends LightningElement {
    @track carModels=[];
    @track carBrands=[];

    @wire(getCarModels)
    wiredCarModels({error,data}){
        if(data){
            this.carModels=data.map(model=>({label:model,value:model}));
        }else if(error){
            console.log('Car models error: '+error);
        }
    }
    @wire(getCarBrands)
    wiredCarBrands({error,data}){
        if(data){
            this.carBrands=data.map(brand=>({label:brand,value:brand}));
        }else if(error){
            console.log('Car brands error: '+error);
        }
    }

    
}