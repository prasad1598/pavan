Global class CalculateTotalRevenueBatch implements Database.Batchable<SObject>, Database.Stateful

  {
      Global decimal totalAnnualRevenue = 0.0;
      Global Database.QueryLocator start (Database.BatchableContext bcontext)
      {
          string accountsQuery = 'select id, name, industry, annualrevenue, rating from Account where annualrevenue!= Null';
          return Database.getQueryLocator(accountsQuery);
      }
      Global void Execute(Database.BatchableContext bContext, List<SObject> recordsToProcess)
      {
          if(!recordsToProcess.isEmpty())
          {
            for (Sobject Objrecord : recordsToProcess) 
            {
                Account accrecord = (Account) Objrecord;
                totalAnnualRevenue += accrecord.AnnualRevenue;
            }    
            
          }
      }
      Global void Finish(Database.BatchableContext bcontext)
      {
          System.debug('Batch job id...'+bcontext.getJobId());
          
           AsyncApexJob jobDetails = [ Select id, status, totalJobItems, jobItemsProcessed,
                                  			numberOfErrors, CreatedBy.email
                                  					from AsyncApexJob
                                  							Where Id =: bContext.getJobId()];
  
        Batchjobemailnotifications.sendbatchjobs_Nottification(jobDetails,totalAnnualRevenue,'CalculateTotalRevenueBatch');
      }
      
}