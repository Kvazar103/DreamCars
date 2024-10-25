import { LightningElement ,track} from 'lwc';

export default class CarCompare extends LightningElement {

    @track firstCar={};
    @track secondCar={};
    @track thirdCar={};
    @track fourthCar={};

    isFirstCarModalOpen=false;
    isSecondCarModalOpen=false;
    isThirdCarModalOpen=false;
    isFourthCarModalOpen=false;


    handleAddFirstCar(){
        this.isFirstCarModalOpen=true;
    }
    handleAddSecondCar(){
        this.isSecondCarModalOpen=true;

    }
    handleAddThirdCar(){
        this.isThirdCarModalOpen=true;

    }
    handleAddFourthCar(){
        this.isFourthCarModalOpen=true;

    }
    handleCloseFirstCarModal(){
        this.isModalOpen=false;
    }
    handleCloseSecondCarModal(){
        this.isSecondCarModalOpen=false;
    }
    handleCloseThirdCarModal(){
        this.isThirdCarModalOpen=false;
    }
    handleCloseFourthCarModal(){
        this.isFourthCarModalOpen=false;
    }


}