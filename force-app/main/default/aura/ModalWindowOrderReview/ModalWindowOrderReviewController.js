({
    openPdf: function(component, event, helper) {
        let recordId = component.get("v.recordId");  // Отримуємо recordId
        let pdfUrl = '/apex/PreviewOfTheOrder?id=' + recordId;  // Формуємо URL для PDF
        component.set("v.pdfUrl", pdfUrl);  // Встановлюємо URL у компоненті
    },
    createOrder:function(component,event,helper){
        let action=component.get("c.createOrderFromModalWithPDF");
        action.setParams({
            opportunityId:component.get("v.recordId"),
        });
        
        action.setCallback(this,function(response){
            let state=response.getState();

            if(state==='SUCCESS'){
                let orderId=response.getReturnValue();
                
                helper.attachPDFtoOrder(component,orderId);

            }else{
              console.log(response);
              console.error("Error: ", response.getError());
            }
        });
         $A.enqueueAction(action);
        
    }
})