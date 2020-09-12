global without sharing class CreateOrAssignTasksAction {
    
    @InvocableMethod(label='Create or Assign Task')
    global static void createOrAssignTaskActionsBatch(List<CreateOrAssignTaskRequest> requests) {
        for(CreateOrAssignTaskRequest request: requests){
            createOrAssignTaskAction(request);
        }
    }
    
    public static void createOrAssignTaskAction(createOrAssignTaskRequest request) {
        Integer countOfTasks = [SELECT count() FROM Task WHERE WhatId=:request.accountId]; 
        if(countOfTasks < 3){
            Task newTask = new Task();
            newTask.Subject = 'Negotiations with ' + request.accountName;
            newTask.WhatId = request.accountId;            
            insert newTask;          
        }
        if(countOfTasks > 3){
            User user = [SELECT Id, Name, Username FROM User WHERE IsActive = true
                         and (not Name like '%Chatter%')
                         and (not Name like '%integ%')
                         and (not Name like '%sec%')
                         and (not Name like '%auto%')                                          
                         limit 1];         
            if(user != null){      
                List<Task> tasks = [SELECT Id, OwnerId FROM Task WHERE WhatId=:request.accountId];  
                List<Task> listToUpdate = new List<Task>();
                for(Task task: tasks){
                    task.OwnerId=user.Id;                                                          
                    listToUpdate.add(task);                    
                }
                update listToUpdate;
            }
        }
    }
    
    global class CreateOrAssignTaskRequest {
        @InvocableVariable(label='Account Name' required=true)
        global String accountName;
        
        @InvocableVariable(label='Account Id' required=true)
        global Id accountId;      
    }
}