import { LightningElement ,track} from 'lwc';

export default class CarCompare extends LightningElement {

    @track cars=[];
    @track isModalOpen=false;

    get isCarsSize4(){
        return this.cars.length==4;
    }

    hadnleAddVehicleButtonClick(){
        this.isModalOpen=true;
    }

    closeModal(){
        this.isModalOpen=false;
    }
    removeCar(event){
        for(let i=0;i<this.cars.length;i++){
            if(this.cars[i].Id===event.currentTarget.dataset.id){
                this.cars.splice(i,1);
            }
        }
    }
    handleCarCreated(event){
        this.isModalOpen=false;
        this.cars.push(event.detail);
    }


}