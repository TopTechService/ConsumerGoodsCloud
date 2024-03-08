import { LightningElement, wire, track } from 'lwc';
import getObjectiveStatisticsWrapper from '@salesforce/apex/ObjectiveStatisticController.getObjectiveStatisticsWrapper';
import updateObjectiveStatistics from '@salesforce/apex/ObjectiveStatisticController.updateObjectiveStatistics';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class EditObjectiveStatistic extends LightningElement {
    records;
    statisticRecords = [];

    error;    
    uniqueColumns = new Set(); 
    numColumns;  
    listObjectiveStatistic = [];
    
    summaryMap = new Map();
    
    NSWACT_Stat;
    QLD_Stat;
    VICTAS_Stat; 
    WASANT_Stat;


    connectedCallback(){
        console.log('connectedCallback');
       
    }
    
    renderedCallback(){
        this.generateSummary();
    }

    @wire(getObjectiveStatisticsWrapper)
    getObjectiveStatisticsWrapper({ error, data }) {
        console.log('wiree');
        if (data) {
            this.records = data;
            console.log('this.records', JSON.stringify(this.records));

            this.uniqueColumns = Object.values(this.records[0].objectives);
            console.log('this.uniqueColumns', this.uniqueColumns); 
            
            this.numColumns = this.uniqueColumns.length +1;
            console.log('this.numColumns', this.numColumns); 
            
            this.records.forEach((rec)=>{
                    this.statisticRecords.push(...rec.statistics);
            });
            
            this.error = undefined;
        
        } 
        else if (error) {
            this.error = error;
            this.records = undefined;
            console.log('## error', this.error)
        }
        
    
    }

  
    
    generateSummary(){
          let reportingName;
          let region;
          let regionKey;
          let statkey;
          let cellValue;
          let inputs = this.template.querySelectorAll("lightning-input");
          this.summaryMap.clear();
    
          inputs.forEach(input=>{

            if(Number.isInteger(parseInt(input.value)))
              cellValue = input.value;
            else 
              cellValue = 0;

            reportingName =  this.statisticRecords.find(record=>record.Id==input.dataset.id).Objective__r.Reporting_Name__c;    
            region = input.dataset.region;
             if(region=='NSW' || region=='ACT')
                regionKey = 'NSWACT';
             else if(region=='VIC' || region=='TAS')
                 regionKey = 'VICTAS';
             else if(region=='WA' || region=='SA' || region=='NT')
                  regionKey = 'WASANT';
             else
                regionKey = region;

             statkey = regionKey + '-' + reportingName;
            
                if(!this.summaryMap.has(statkey))
                    this.summaryMap.set(statkey,  cellValue);
                else 
                    this.summaryMap.set(statkey, parseInt(this.summaryMap.get(statkey)) + parseInt(cellValue));
          })
       
            for (let [key, value] of  this.summaryMap) {
                    let keyValues = key.split('-');
                    this.template.querySelector(`[data-region="${keyValues[0]}"][data-name="${keyValues[1]}"]`).innerText = value;
            }
            
    }

    handleChange(event){
        console.log('event.target:', event.target);
        console.log('event.currentTarget', event.currentTarget);
        const recordId = event.currentTarget.dataset.id;
        const fieldName = 'Total_Allocation__c';
        const fieldValue = event.currentTarget.value;
        
        let objectiveStatistic = new Object();
        objectiveStatistic["Id"] = recordId;
        objectiveStatistic[fieldName] = fieldValue;

        //console.log('objectiveStatistic', objectiveStatistic);

        const index = this.listObjectiveStatistic.findIndex(element => element.Id === objectiveStatistic["Id"]);
        if (index > -1){
            this.listObjectiveStatistic[index].Total_Allocation__c = fieldValue;
        }
        else{ 
            this.listObjectiveStatistic.push(objectiveStatistic);
        }
        
        //console.log('LISTA', this.listObjectiveStatistic);
        //console.log(JSON.stringify(this.listObjectiveStatistic));
        //console.log(event.target.value);
        this.generateSummary();
    }

    handleSave(){
        updateObjectiveStatistics({listObjectiveStatistic: this.listObjectiveStatistic})
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Record updated',
                    variant: 'success'
                })
            );
        })
        .catch(error => { 
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error updating record',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        });
    }
}