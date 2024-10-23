({
    attachPDFtoOrder : function(component,orderId) {
        let action=component.get("c.attachPDFtoOrder");
        
        action.setParams({
            orderId:orderId,
            pdfUrl:component.get("v.pdfUrl")
        });
        
        action.setCallback(this,function(response){
            let state=response.getState();

            if(state==="SUCCESS"){
                
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "The Order was created successfully.",
                    "type": "success"
                });
                toastEvent.fire();
                
            }else{
                console.log("error");
            }
        });
        $A.enqueueAction(action);
    }
})