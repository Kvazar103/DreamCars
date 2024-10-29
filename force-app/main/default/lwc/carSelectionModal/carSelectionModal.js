import { LightningElement,track,wire,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getCarModels from '@salesforce/apex/CarController.getCarModels';
import getCarBrands from '@salesforce/apex/CarController.getCarBrands';
import getCarDriveTypes from '@salesforce/apex/CarController.getCarDriveTypes';
import getCarFuelTypes from '@salesforce/apex/CarController.getCarFuelTypes';
import getCarTransmissionType from '@salesforce/apex/CarController.getCarTransmissionType';
import getCarCondition from '@salesforce/apex/CarController.getCarCondition';
import getCar from '@salesforce/apex/CarController.getCar';

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

    @track selectedCar={};

    @wire(getCarModels)
    wiredCarModels({error,data}){
        if(data){
            this.carModels=data.map(model=>({label:model.replace(/_/g,' '),value:model}));
        }else if(error){
            console.log('Car models error: '+error);
        }
    }
    @wire(getCarBrands)
    wiredCarBrands({error,data}){
        if(data){
            this.carBrands=data.map(brand=>({label:brand.replace(/_/g,' '),value:brand}));
        }else if(error){
            console.log('Car brands error: '+error);
        }
    }
    @wire(getCarDriveTypes)
    wiredCarDriveTypes({error,data}){
        if(data){
            this.carDriveTypes=data.map(drive_type=>({label:drive_type.replace(/_/g,' '),value:drive_type}));
        }else if(error){
            console.log('Car Drive Type error: '+error);
        }
    }
    @wire(getCarFuelTypes)
    wiredCarFuelTypes({error,data}){
        if(data){
            this.carFuelTypes=data.map(fuel_type=>({label:fuel_type.replace(/_/g,' '),value:fuel_type}));
        }else if(error){
            console.log('Car Fuel Type error: '+error);
        }
    }
    @wire(getCarTransmissionType)
    wiredCarTransmissionTypes({error,data}){
        if(data){
            this.carTransmissionTypes=data.map(transmission_type=>({label:transmission_type.replace(/_/g,' '),value:transmission_type}));
        }else if(error){
            console.log('Car Transmission Type error: '+ error);
        }
    }
    @wire(getCarCondition)
    wiredCarCondition({error,data}){
        if(data){
            this.carConditions=data.map(condition=>({label:condition.replace(/_/g,' '),value:condition}));
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
        this.selectedYear=event.target.value.replace(/_/g,' ');
    }
    handleModalChange(event){
        this.selectedModel=event.target.value.replace(/_/g,' ');
    }
    handleBrandChange(event){
        this.selectedBrand=event.target.value.replace(/_/g,' ');
    }
    handleConditionChange(event){
        this.selectedCondition=event.target.value.replace(/_/g,' ');
    }
    handleDriveTypeChange(event){
        this.selectedDriveType=event.target.value.replace(/_/g,' ');
    
    }
    handleFuelTypeChange(event){
        this.selectedFuelType=event.target.value.replace(/_/g,' ');
    }
    handleTransmissionTypeChange(event){
        this.selectedTransmissionType=event.target.value.replace(/_/g,' ');
    }
    handleSafetyRatingChange(event){
        this.selectedSafetyRating=event.target.value.replace(/_/g,' ');
    }

    closeModal(){
        //this.isModalOpen=false;
        this.dispatchEvent(new CustomEvent('close'));
    }

    async addCar(){
        try{
            const car=await getCar({
                model:this.selectedModel,
                brand:this.selectedBrand,
                year:this.selectedYear,
                condition:this.selectedCondition,
                driveType:this.selectedDriveType,
                fuelType:this.selectedFuelType,
                transmissionType:this.selectedTransmissionType,
                safetyRating:this.selectedSafetyRating
            });
            if(car){
                this.selectedCar=car;
                const event=new ShowToastEvent({
                    title: 'Success!',
                    message: 'Car successfully found!',
                    variant:'success'
                    
                })
                this.dispatchEvent(new CustomEvent('carcreated',{detail:car}));
                this.dispatchEvent(event);
                this.closeModal();
            }
        }catch(error){
            console.log("Fetcing car error: "+error);
            const errorEvent=new ShowToastEvent({
                title:'Error',
                message:'No such car',
                variant:'error'
            });
            this.dispatchEvent(errorEvent);
           
        }
    }



    
}