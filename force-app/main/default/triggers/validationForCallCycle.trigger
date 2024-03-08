/*
* Trigger Name : setParentHierarchy
* Description - This trigger is used to validate the conditions before Call_Cycle__c records are saved. The conditions are below
@   1.  Two call cycles records should not be having same Call Cycle, Start Date and End Date. (For AUS)
@   2.  Start Date should always be Monday and End Date should always be Friday.(For AUS)
@   3.  Duration between Start date and End date should not be greater than 7 weeks(For AUS). (03.05.2020 7 weeks => 8 weeks)
@   4.  Duration between Start Date & End date can be 2-3 weeks for Summer Call Cycle [13-06-2013]

* @author Debasish (debasish@arxxus.com)
* @revised : 03-05-2013 [created by Debasish]
* @revised : 13-06-2013 [modified by Geeta Kushwaha ]
*/


trigger validationForCallCycle on Call_Cycle__c (before insert, before update) {
    try{
        date maxDate = system.today();
        date minDate = system.today();

        for(Call_Cycle__c cCycle : trigger.new){
            boolean erroFlag = false;
            // Check the location should not be blank
            if(cCycle.Location__c == null || cCycle.Location__c == '--None--' || cCycle.Location__c == ''){
                cCycle.addError('Please select any Location');
                erroFlag = true;
            }

            if(erroFlag == false && cCycle.Location__c == 'Australia'){
                // chekc blank value for End Date & Start Date
                if(cCycle.Start_Date__c == null || cCycle.End_Date__c == null){
                    cCycle.addError('Please enter start date and end date');
                    erroFlag = true;
                }
                else{
                    // Check for End date should be greater than Start date
                    if(cCycle.End_Date__c <= cCycle.Start_Date__c){
                        cCycle.addError('End date should be greater than Start date');
                        erroFlag = true;
                    }
                    else{
                        // Check for duration
                        if(cCycle.Call_Cycle__c == 'Summer Call Cycle'){

                            if(cCycle.End_Date__c > cCycle.Start_Date__c.addDays(28)){
                                cCycle.addError('Duration between Start date and End date should not be greater than 4 weeks for Summer Call Cycle.');
                                erroFlag = true;
                            }

                        }
                        else if(cCycle.End_Date__c > cCycle.Start_Date__c.addDays(56)){ //03.05.2020 7 weeks => 8 weeks
                            cCycle.addError('Duration between Start date and End date should not be greater than 8 weeks.');
                            erroFlag = true;
                        }
                        // Check for week day
                        else{
                            if(weekDay(cCycle.Start_Date__c) != 'Mon' || weekDay(cCycle.End_Date__c ) != 'Fri' ){
                                cCycle.addError('Start Date should always be Monday and End Date should always be Friday.');
                                erroFlag = true;
                            }
                            else{
                                if(maxDate < cCycle.End_Date__c){
                                    maxDate = cCycle.End_Date__c;
                                }
                                if(minDate >  cCycle.Start_Date__c){
                                    minDate = cCycle.Start_Date__c;
                                }
                            }
                        }
                    }
                }
            }


        }


        // fetch the existing call cycle with in time range

        list<Call_Cycle__c> listCallCyle = [select id,Start_Date__c,End_Date__c,Location__c
                                            from Call_Cycle__c
                                            where (Start_Date__c <: maxDate AND Start_Date__c >: minDate)
                                            OR (End_Date__c <: maxDate AND End_Date__c >: minDate) ];

        map<string,list<Call_Cycle__c>> locationCallCyle = new map <string,list<Call_Cycle__c>>();

        for(Call_Cycle__c ccList : listCallCyle ){
            if(locationCallCyle.containsKey(ccList.Location__c)){
                locationCallCyle.get(ccList.Location__c).add(ccList);
            }
            else{
                locationCallCyle.put(ccList.Location__c,new list <Call_Cycle__c>{ccList});
            }
        }

        // Check the new call cycle is belongs to any existing call cycle

        for(Call_Cycle__c cCycel : trigger.new){
            if(cCycel.Location__c != null && locationCallCyle.containsKey(cCycel.Location__c)){
                for(Call_Cycle__c exCCycle : locationCallCyle.get(cCycel.Location__c)){
                    if(cCycel.Start_Date__c >= exCCycle.Start_Date__c && cCycel.Start_Date__c <= exCCycle.End_Date__c &&
                       cCycel.End_Date__c >= exCCycle.Start_Date__c && cCycel.Start_Date__c <= exCCycle.End_Date__c && cCycel.id != exCCycle.id){

                           cCycel.addError('Already one "Call Cycle" record is present in this date range');

                       }
                }
            }

        }


    }
    catch(exception e){
        system.debug('----------exception ---'+ e);
    }


    /**
@ Method Description : This method crate a date
@ Input param : month as string e.g{January} and year as string e.g {2013}
@ Output param : Date[]
*/
    public date[] createDate(string month,string year){


        map<string,integer[]> numOfdays = new map<string,integer[]>{
            'January' => new integer[] {31,1},
                'February' => new integer[] {28,2},
                    'March' =>  new integer[] {31,3},
                        'April' => new integer[] {30,4},
                            'May' =>  new integer[] {31,5},
                                'June' => new integer[] {30,6},
                                    'July' => new integer[] {31,7},
                                        'August' => new integer[] {31,8},
                                            'September' => new integer[] {30,9},
                                                'October' =>  new integer[] {31,10},
                                                    'November' => new integer[] {30,11},
                                                        'December' =>  new integer[] {31,12}

        };

            integer numDay = numOfdays.get(month)[0];
        integer yearVal  = integer.valueof(year);
        integer monthVal =  numOfdays.get(month)[1];
        if(date.isLeapYear(yearVal) && month == 'February'){
            numDay += 1;
        }
        date starDate = date.newinstance(yearVal, monthVal, 1);
        date endDate  = date.newinstance(yearVal, monthVal, numDay);

        date[] datelist = new date[]{starDate,endDate};
            return datelist;
    }

    /**
@ Method Description : This method creates a day of week in string
@ Input param : date
@ Output param : string  e.g{Sun}
*/
    public string weekDay( Date cdate){
        datetime cDateTime = cdate;

        string dayOfWeek = cDateTime.format('EEE');

        return dayOfWeek ;

    }

}