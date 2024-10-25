import { LightningElement,track,wire } from 'lwc';

import getCarModels from '@salesforce/apex/CarController.getCarModels';
import getCarBrands from '@salesforce/apex/CarController.getCarBrands';
import getCarDriveTypes from '@salesforce/apex/CarController.getCarDriveTypes';
import getCarFuelTypes from '@salesforce/apex/CarController.getCarFuelTypes';
import getCarTransmissionType from '@salesforce/apex/CarController.getCarTransmissionType';
import getCarCondition from '@salesforce/apex/CarController.getCarCondition';

export default class CarSelectionModal extends LightningElement {
    @track carModels=[];
    @track carBrands=[];
    @track carYears=[];
    @track carConditions=[];
    @track carDriveTypes=[];
    @track carFuelTypes=[];
    @track carTransmissionTypes=[];
    @track carSafetyRating=[];

    selectedModel='';
    selectedBrand='';
    selectedYear='';
    selectedCondition='';
    selectedDriveType='';
    selectedFuelType='';
    selectedTransmissionType='';
    selectedSafetyRating='';

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
    @wire(getCarDriveTypes)
    wiredCarDriveTypes({error,data}){
        if(data){
            this.carDriveTypes=data.map(drive_type=>({label:drive_type,value:drive_type}));
        }else if(error){
            console.log('Car Drive Type error: '+error);
        }
    }
    @wire(getCarFuelTypes)
    wiredCarFuelTypes({error,data}){
        if(data){
            this.carFuelTypes=data.map(fuel_type=>({label:fuel_type,value:fuel_type}));
        }else if(error){
            console.log('Car Fuel Type error: '+error);
        }
    }
    @wire(getCarTransmissionType)
    wiredCarTransmissionTypes({error,data}){
        if(data){
            this.carTransmissionTypes=data.map(transmission_type=>({label:transmission_type,value:transmission_type}));
        }else if(error){
            console.log('Car Transmission Type error: '+ error);
        }
    }
    @wire(getCarCondition)
    wiredCarCondition({error,data}){
        if(data){
            this.carConditions=data.map(condition=>({label:condition,value:condition}));
        }else if(error){
            console.log('Car Condition error: '+error);
        }
    }
    connectedCallback(){
        const startYear=1990;
        const endYear=2025;

        for(let year=startYear;year<=endYear;year++){
            this.carYears.push({label:year.toString(),value:year.toString()});
        }
        const startRating=1;
        const endRating=5;
        for(let num=startRating;num<=endRating;num++){
            this.carSafetyRating.push({label:num.toString(),value:num.toString()});
        }
    }
    handleYearChange(event){
        this.selectedYear=event.target.value;
    }
    handleModalChange(event){
        this.selectedModel=event.target.value;
    }
    handleBrandChange(event){
        this.selectedBrand=event.target.value;
    }
    handleConditionChange(event){
        this.selectedCondition=event.target.value;
    }
    handleDriveTypeChange(event){
        this.selectedDriveType=event.target.value;
    }
    handleFuelTypeChange(event){
        this.selectedFuelType=event.target.value;
    }
    handleTransmissionTypeChange(event){
        this.selectedTransmissionType=event.target.value;
    }
    handleSafetyRatingChange(event){
        this.selectedSafetyRating=event.target.value;
    }

    
}