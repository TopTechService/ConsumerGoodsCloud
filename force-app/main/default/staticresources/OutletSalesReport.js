var $j = jQuery.noConflict();
Visualforce.remoting.timeout = 120000;
Visualforce.remoting.buffer = false;
/*jslint browser: true */

function addCommas(nStr)
{
    nStr += '';
    
    x = nStr.split('.');
    
    x1 = x[0];
    
    x2 = x.length > 1 ? '.' + x[1] : '';
    
    var rgx = /(\d+)(\d{3})/;
    
    while (rgx.test(x1)) {
    
        x1 = x1.replace(rgx, '$1' + ',' + '$2');
        
    }
    
    return x1 + x2;
    
}    
  
function populateFormatting() {

    $j("[name='formatWithComma']").each(function() {

        var elementHtml = $j(this).html();
        
        if(elementHtml.indexOf("%") == -1){
        
             $j(this).html(addCommas(elementHtml));
             
        }
        
        elementHtml = $j(this).html();
        
        if(elementHtml.charAt(0) == '-') {
            
            $j(this).html(elementHtml.replace("-","(") + ')');
            
        }
        elementHtml = $j(this).html();
        
    });
    
}

function tableToExcelIE(selectedRegion, selectedBannerGroup, selectedDate) 
{
	console.log('Report for IE');
    var str="", borderString ="", bgString = "";
    
    var bgColormap = new Object(); 
    bgColormap['rgb(197, 217, 241)'] = 15849925; //light blue
    bgColormap['rgb(141, 180, 226)'] = 14857357; //dark blue
    bgColormap['rgb(217, 217, 217)'] = 14277081; //light gray
    bgColormap['rgb(128, 128, 128)'] = 8421504; //dark Gray
    
    var columnNames = new Array('A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','AA','AB','AC','AD','AE','AF','AG','AH','AI','AJ','AK','AL','AM','AN','AO','AP','AQ','AR','AS','AT','AU','AV','AW','AX','AY','AZ','BA');
    
    var redCells = new Array();
    
    var ExcelApp = new ActiveXObject("Excel.Application");
    var Workbook = ExcelApp.Workbooks.Add;
    var eSheets = ExcelApp.ActiveWorkbook.Sheets;
    var eSheet1 = eSheets(1);
    eSheet1.Name="Outlet Sales	Report";
    //ExcelApp.Visible = true;
    var i=5, j=0, redCellsIndex = 0;
    var cell;
    
    cell = eSheet1.Cells(1,1);
    cell.Value = 'Outlet Sales Report';
    cell.font.bold = true
    cell.font.size = 18;
    
    cell = eSheet1.Cells(2,1);
    cell.Value = 'Region: '+selectedRegion;
    cell.Interior.ColorIndex = 17;
    
    cell = eSheet1.Cells(3,1);
    cell.Value = 'Outlet: '+selectedBannerGroup;
    cell.Interior.ColorIndex = 17;
    
    cell = eSheet1.Cells(4,1);
    cell.Value = 'Date: '+document.getElementById(selectedDate).value;
    cell.Interior.ColorIndex = 17;
    
    eSheet1.Cells(6,2).Value = 'Month';
    eSheet1.Cells(6,2).font.bold=true;
    var range = eSheet1.Range('B6:E6');
    range.HorizontalAlignment = -4108;
    range.Interior.ColorIndex = 6;
    range.MergeCells = true;
    
    eSheet1.Cells(6,7).Value = 'Calendar Year to Date';
    eSheet1.Cells(6,7).font.bold=true;
    range = eSheet1.Range('G6:J6');
    range.HorizontalAlignment = -4108;
    range.Interior.ColorIndex = 6;
    range.MergeCells = true;
    
    eSheet1.Cells(6,12).Value = 'Volume by Quarter and Half TY vs. LY';
    eSheet1.Cells(6,12).font.bold=true;
    range = eSheet1.Range('L6:AM6');
    range.HorizontalAlignment = -4108;
    range.Interior.ColorIndex = 44;
    range.MergeCells = true;
    
    eSheet1.Cells(6,41).Value = 'Volume by Month (MAT)'; 
    eSheet1.Cells(6,41).font.bold=true;
    range = eSheet1.Range('AO6:AZ6');
    range.HorizontalAlignment = -4108;
    range.Interior.ColorIndex = 44;
    range.MergeCells = true;      
      
    $j('#reportTable > thead  > tr').each(function() {
        j=0; borderString = "";
        $j(this).find('td').each(function () {
                   str= $j(this).html();
                   eSheet1.Cells(i+1,j+1).Value = str;
                   if(j > 0) {
                       range = eSheet1.Range(columnNames[j]+(i+1)).EntireColumn;
                       range.WrapText = true;
                   } 
                   if(str.length > 0)
                       borderString += columnNames[j]+(i+1)+",";                               
                   j++;
               });
               if(borderString.length > 0) {
                   borderString = borderString.substring(0, borderString.lastIndexOf(","));
                   range = eSheet1.Range(borderString);
                   range.Borders.LineStyle = 1;
                   range.Borders.LineStyle.Color = -11489280;
                   range.Borders.LineStyle.Weight = 4;
                   
               }
        i++;
        
     });
    var k;
    $j('#reportTable > tbody  > tr').each(function() {
        j=0; borderString = "";
        $j(this).find('td').each(function () {
                   
                   str= $j(this).html();
                   if(str === '&nbsp;')
                       str = ' ';
                   else if(str.length > 0) {
                       borderString += columnNames[j]+(i+1)+",";
                       if(str.charAt(0) == '-' && j>0) {
                           redCells[redCellsIndex] = columnNames[j]+(i+1);
                           redCellsIndex++;
                       }
                   }   
                   if(j === 0) {
                       eSheet1.Cells(i+1,j+1).Value = str.replace(/\&amp;/g,'&');
                   }
                   else
                       eSheet1.Cells(i+1,j+1).Value = str;
                   j++;
               });
               
               if(borderString.length > 0) {
                   k = i + 1;
                   borderString = borderString.substring(0, borderString.lastIndexOf(","));
                   range = eSheet1.Range("A"+k+":E"+k+",G"+k+":J"+k+",L"+k+":AM"+k+",AO"+k+":AZ"+k);
                   range.Borders.LineStyle = 1;
                   range.Borders.LineStyle.Color = -11489280;
                   range.Borders.LineStyle.Weight = 4;
                   bgString = $j(this).css('background-color');
                   if(bgString != 'transparent')
                       range.Interior.Color = bgColormap[bgString];
               }
               
        i++;
        
     });
     
     range = eSheet1.Range("B6:E6, G6:J6, L6:AM6, AO6:AZ6");
     range.Borders.LineStyle = 1;
     range.Borders.LineStyle.Color = -11489280;
     range.Borders.LineStyle.Weight = 4;
    
     eSheet1.Range("A:A").Columns.AutoFit;
     
     eSheet1.Range("D:D, E:E, I:I, J:J, N:N, O:O, R:R, S:S, V:V, W:W, Z:Z, AA:AA, AD:AD, AE:AE, AH:AH, AI:AI, AL:AL, AM:AM").Font.Color = -11489280; //green
     
     for (var index = 0; index < redCells.length; index++) {
         eSheet1.Range(redCells[index]).Font.Color = -16776961; //red       
     }
     
     eSheet1.Range("D7,E7,I7,J7,N7,O7,R7,S7,V7,W7,Z7,AA7,AD7,AE7,AH7,AI7,AL7,AM7").Font.Color = 0; // Title color should be black has been reset by above
     
     Workbook.SaveAs('OutletSalesReport.xls');
     
     ExcelApp.Visible = true;
}


function getSelectedText(elementId) {
    'use strict';
    var elt = document.getElementById(elementId);

    if (elt.selectedIndex === -1) { return null; }

    return elt.options[elt.selectedIndex].text;
}

function tableToExcel1(selectedRegion, selectedBannerGroup, selectedDate) {
	
	var nAgt = navigator.userAgent;
	
	console.log(nAgt);
    
    var verOffset;
    
    if ((verOffset=nAgt.indexOf("Firefox"))!=-1) {
    	console.log('1');
        tableToExcelChromeFirefox(selectedRegion, selectedBannerGroup, selectedDate, false);
    
    }
    else if ((verOffset=nAgt.indexOf("Chrome"))!=-1) {
    	console.log('2');
        tableToExcelChromeFirefox(selectedRegion, selectedBannerGroup, selectedDate, false);
    
    }
    
    else if ((verOffset=nAgt.indexOf("MSIE"))!=-1) {
        console.log('3');
        tableToExcelIE(selectedRegion, selectedBannerGroup, selectedDate);
    
    }
    
    else if ((verOffset=nAgt.indexOf("Safari"))!=-1) {
        console.log('4');
        tableToExcelChromeFirefox(selectedRegion, selectedBannerGroup, selectedDate, false);
    
    }
    
    else {
        console.log('5');
        tableToExcelChromeFirefox(selectedRegion, selectedBannerGroup, selectedDate, false);
    
    }


    
}

function tableToExcelChromeFirefox(selectedRegion, selectedBannerGroup, selectedDate, createHyperlink){
    'use strict';
    var table, html, a;
    table = document.getElementById("reportTable");
    html = '<h1>Outlet Sales Report</h1><table style="background-color: rgb(173,182,212)"><tr><td colspan="3"><b>Region: </b>' + selectedRegion + '</td></tr><tr><td colspan="3"><b>Outlet: </b>' + selectedBannerGroup + '</td></tr><tr><td colspan="3"><b>Date: </b>' + document.getElementById(selectedDate).value + '</td></tr></table><br/><br/>' + table.outerHTML;
    
    while (html.indexOf('�') !== -1) { html = html.replace('�', '&aacute;'); }
    while (html.indexOf('�') !== -1) { html = html.replace('�', '&eacute;'); }
    while (html.indexOf('�') !== -1) { html = html.replace('�', '&iacute;'); }
    while (html.indexOf('�') !== -1) { html = html.replace('�', '&oacute;'); }
    while (html.indexOf('�') !== -1) { html = html.replace('�', '&uacute;'); }
    while (html.indexOf('�') !== -1) { html = html.replace('�', '&ordm;'); }

    if(createHyperlink) {
        a = document.createElement('a');
        a.href = 'data:application/vnd.ms-excel' + ', ' + encodeURIComponent(html);
        //setting the file name
        a.download = 'OutletSalesReport.xls';
        //triggering the function
        a.click();
    }
    else {
        window.open('data:application/vnd.ms-excel,' + encodeURIComponent(html));
    }
    
}
function getData(selectedRegion, selectedBannerGroup, selectedDate){
        console.log('getData Called');
        var table= document.getElementById("reportTable");
        var html = '<h1>Outlet Sales Report</h1><table style="background-color: rgb(173,182,212)"><tr><td colspan="3"><b>Region: </b>'
        +getSelectedText(selectedRegion)+'</td></tr><tr><td colspan="3"><b>Banner Group: </b>'
        +getSelectedText(selectedBannerGroup)+'</td></tr><tr><td colspan="3"><b>Date: </b>'
        +document.getElementById(selectedDate).value
        +'</td></tr></table><br/><br/>'+table.outerHTML;
        
        //setTableData('12345666666666666666666677777777777777777777777777');
        
        console.log('controller method was invoked');
    }
    
function calculateReport(selectedDateId,region,banner,errorMsgId,remoteActions ){

    var selectedDate ;

    if(document.getElementById(selectedDateId).value != '') {
     
        var selDate = document.getElementById(selectedDateId).value.split('/');
                                 
        selectedDate = new Date(selDate[2],selDate[1]-1,selDate[0]);
         
    }   
     
    else 
     
        selectedDate = new Date(2013,6,31);
     
    selectedDate = new Date(selectedDate.valueOf() - selectedDate.getTimezoneOffset() * 60000);

    var dateString = selectedDate.toUTCString();
    var subBannerGroups;
    var counter = 0;
    
    //Get all child banner group Ids
    
    Visualforce.remoting.Manager.invokeAction(
        remoteActions[0],
        banner, 
        function(result, event){
            if (event.status) {
                console.log('1: '+result);
                subBannerGroups = result;
                console.log(subBannerGroups);
                calculateBannerColumn1();
                calculateProductColumn1();
            } 
            
            else {
                 document.getElementById(errorMsgId).innerHTML = 'Exception in Calculating col1';
                 $j("#loading").hide();
            }
        }
    );
    
    //Banner Section
    function calculateBannerColumn1(){
        Visualforce.remoting.Manager.invokeAction(
            
            remoteActions[1],
            dateString,
            region,
            subBannerGroups,
            true, 
            function(result, event){
                if (event.status) {
                    console.log('1: '+result);
                    for(var colVal in result) {
                        document.getElementById(''+colVal+'-1').innerHTML = result[colVal].toFixed(1);
                    } 
                    calculateColumn2(true);
                } 
                
                else {
                     document.getElementById(errorMsgId).innerHTML = 'Exception in Calculating col1';
                     $j("#loading").hide();
                }
            }
        );
    }

    //Products section
    //Calculate Column 1 i.e. Month:Actual TY
    function calculateProductColumn1(){
    Visualforce.remoting.Manager.invokeAction(
        
        remoteActions[1],
        dateString,
        region,
        subBannerGroups,
        false, 
        function(result, event){
            if (event.status) {
                console.log('1: '+result);
                for(var colVal in result) {
                    document.getElementById(''+colVal+'-1').innerHTML = result[colVal].toFixed(1);
                } 
                calculateColumn2(false);
            } 
            
            else {
                 document.getElementById(errorMsgId).innerHTML = 'Exception in Calculating col1';
                 $j("#loading").hide();
            }
        }
    );
    }

    //Calculate Column 2 i.e. Month:Actual LY
    function calculateColumn2(status) {
        
        Visualforce.remoting.Manager.invokeAction(
            remoteActions[2],
            dateString,
            region, 
            subBannerGroups,
            status, 
            function(result, event){
                
                if (event.status) {
                    console.log('2: '+result);
                    for(var colVal in result) {
                        document.getElementById(''+colVal+'-2').innerHTML = result[colVal].toFixed(1);
                    } 
                    calculateColumn6(status);
                } 
                
                else {
                     document.getElementById(errorMsgId).innerHTML = 'Exception in Calculating col2';
                     $j("#loading").hide();
                }
            }
        );
         
    }

    //Calculate Column 6 i.e. Calendar Year to Date:Actual TY
    function calculateColumn6(status) {
        
        Visualforce.remoting.Manager.invokeAction(
            remoteActions[3],
            dateString,
            region, 
            subBannerGroups,
            status, 
            function(result, event){
                if (event.status) {
                    console.log('6: '+result);
                    for(var colVal in result) {
                        document.getElementById(''+colVal+'-6').innerHTML = result[colVal].toFixed(1);
                    } 
                    calculateColumn7(status);
                } 
                else {
                     document.getElementById(errorMsgId).innerHTML = 'Exception in Calculating col6';
                     $j("#loading").hide();
                }
            }
        );
     
    }

    //Calculate Column 7 i.e. Calendar Year to Date:Actual LY
    function calculateColumn7(status) {
        
        Visualforce.remoting.Manager.invokeAction(
            remoteActions[4],
            dateString,
            region, 
            subBannerGroups,
            status, 
            function(result, event){
                if (event.status) {
                    console.log('7: '+result);
                    for(var colVal in result) {
                        document.getElementById(''+colVal+'-7').innerHTML = result[colVal].toFixed(1);
                    } 
                    calculateColumn11(status);
                } 
                else {
                     document.getElementById(errorMsgId).innerHTML = 'Exception in Calculating col7';
                     $j("#loading").hide();
                }
            }
        );
     
    }

    //Calculate Column 11 i.e. Volume by Quarter and Half TY vs. LY:Q1 TY
    function calculateColumn11(status) {
        
        Visualforce.remoting.Manager.invokeAction(
            remoteActions[5],
            dateString, 
            region, 
            subBannerGroups,
            status, 
            function(result, event){
                if (event.status) {
                    console.log('11: '+result);
                    for(var colVal in result) {
                        document.getElementById(''+colVal+'-11').innerHTML = result[colVal].toFixed(1);
                    } 
                    calculateColumn12(status);
                } 
                else {
                     document.getElementById(errorMsgId).innerHTML = 'Exception in Calculating col11';
                     $j("#loading").hide();
                }
            }
        );
     
    }

    //Calculate Column 12 i.e. Volume by Quarter and Half TY vs. LY:Q1 LY
    function calculateColumn12(status) {
        
        Visualforce.remoting.Manager.invokeAction(
            remoteActions[6],
            dateString,
            region, 
            subBannerGroups,
            status, 
            function(result, event){
                if (event.status) {
                    console.log('12: '+result);
                    for(var colVal in result) {
                        document.getElementById(''+colVal+'-12').innerHTML = result[colVal].toFixed(1);
                    } 
                    calculateColumn15(status);
                } 
                else {
                     document.getElementById(errorMsgId).innerHTML = 'Exception in Calculating col12';
                     $j("#loading").hide();
                }
            }
        );
     
    }

    //Calculate Column 15 i.e. Volume by Quarter and Half TY vs. LY:Q2 TY
    function calculateColumn15(status) {
        
        Visualforce.remoting.Manager.invokeAction(
            remoteActions[7],
            dateString, 
            region, 
            subBannerGroups,
            status, 
            function(result, event){
                console.log('15: '+result);
                if (event.status) {
                    for(var colVal in result) {
                        document.getElementById(''+colVal+'-15').innerHTML = result[colVal].toFixed(1);
                    } 
                    calculateColumn16(status);
                } 
                else {
                     document.getElementById(errorMsgId).innerHTML = 'Exception in Calculating col15';
                     $j("#loading").hide();
                }
            }
        );
     
    }

    //Calculate Column 16 i.e. Volume by Quarter and Half TY vs. LY:Q2 LY
    function calculateColumn16(status) {
       
        Visualforce.remoting.Manager.invokeAction(
            remoteActions[8],
            dateString, 
            region, 
            subBannerGroups,
            status, 
            function(result, event){
                console.log('16: '+result);
                if (event.status) {
                    for(var colVal in result) {
                        document.getElementById(''+colVal+'-16').innerHTML = result[colVal].toFixed(1);
                    } 
                    calculateColumn23(status);
                } 
                else {
                     document.getElementById(errorMsgId).innerHTML = 'Exception in Calculating col16';
                     $j("#loading").hide();
                }
            }
        );
     
    }

    //Calculate Column 23 i.e. Volume by Quarter and Half TY vs. LY:Q3 TY
    function calculateColumn23(status) {
        
        Visualforce.remoting.Manager.invokeAction(
            remoteActions[9],
            dateString, 
            region, 
            subBannerGroups,
            status, 
            function(result, event){
                if (event.status) {
                    console.log('23: '+result);
                    for(var colVal in result) {
                        document.getElementById(''+colVal+'-23').innerHTML = result[colVal].toFixed(1);
                    } 
                    calculateColumn24(status);
                } 
                else {
                     document.getElementById(errorMsgId).innerHTML = 'Exception in Calculating col23';
                     $j("#loading").hide();
                }
            }
        );
     
    }

    //Calculate Column 24 i.e. Volume by Quarter and Half TY vs. LY:Q3 LY
    function calculateColumn24(status) {
       
        Visualforce.remoting.Manager.invokeAction(
            remoteActions[10],
            dateString,
            region, 
            subBannerGroups,
            status, 
            function(result, event){
                if (event.status) {
                console.log('24: '+result);
                    for(var colVal in result) {
                        document.getElementById(''+colVal+'-24').innerHTML = result[colVal].toFixed(1);
                    } 
                    calculateColumn27(status);
                } 
                else {
                     document.getElementById(errorMsgId).innerHTML = 'Exception in Calculating col24';
                     $j("#loading").hide();
                }
            }
        );
     
    }

    //Calculate Column 27 i.e. Volume by Quarter and Half TY vs. LY:Q4 TY
    function calculateColumn27(status) {
        
        Visualforce.remoting.Manager.invokeAction(
            remoteActions[11],
            dateString, 
            region, 
            subBannerGroups,
            status, 
            function(result, event){
                if (event.status) {
                console.log('27: '+result);
                    for(var colVal in result) {
                        document.getElementById(''+colVal+'-27').innerHTML = result[colVal].toFixed(1);
                    } 
                    calculateColumn28(status);
                } 
                else {
                     document.getElementById(errorMsgId).innerHTML = 'Exception in Calculating col27';
                     $j("#loading").hide();
                }
            }
        );
     
    }

    //Calculate Column 28 i.e. Volume by Quarter and Half TY vs. LY:Q4 LY
    function calculateColumn28(status) {
        
        Visualforce.remoting.Manager.invokeAction(
            remoteActions[12],
            dateString, 
            region, 
            subBannerGroups,
            status, 
            function(result, event){
                if (event.status) {
                console.log('28: '+result);
                    for(var colVal in result) {
                        document.getElementById(''+colVal+'-28').innerHTML = result[colVal].toFixed(1);
                    } 
                    calculateColumn40(status);
                } 
                else {
                     document.getElementById(errorMsgId).innerHTML = 'Exception in Calculating col28';
                     $j("#loading").hide();
                }
            }
        );
     
    }

    //Calculate Column 40 i.e. Volume by Month (MAT):JAN
    function calculateColumn40(status) {
        
        Visualforce.remoting.Manager.invokeAction(
            remoteActions[13],
            dateString,
            region, 
            subBannerGroups,
            status, 
            function(result, event){
                if (event.status) {
                    console.log('40: '+result);
                    for(var colVal in result) {
                        document.getElementById(''+colVal+'-40').innerHTML = result[colVal].toFixed(1);
                    } 
                    calculateColumn41(status);
                } 
                else {
                     document.getElementById(errorMsgId).innerHTML = 'Exception in Calculating col40';
                     $j("#loading").hide();
                }
            }
        );
     
    }

    //Calculate Column 41 i.e. Volume by Month (MAT):FEB
    function calculateColumn41(status) {
        
        Visualforce.remoting.Manager.invokeAction(
            remoteActions[14],
            dateString, 
            region,
            subBannerGroups, 
            status, 
            function(result, event){
                if (event.status) {
                    console.log('41: '+result);
                    for(var colVal in result) {
                        document.getElementById(''+colVal+'-41').innerHTML = result[colVal].toFixed(1);
                    } 
                    calculateColumn42(status);
                } 
                else {
                     document.getElementById(errorMsgId).innerHTML = 'Exception in Calculating col41';
                     $j("#loading").hide();
                }
            }
        );
     
    }

    //Calculate Column 42 i.e. Volume by Month (MAT):MAR
    function calculateColumn42(status) {
        
        Visualforce.remoting.Manager.invokeAction(
            remoteActions[15],
            dateString, 
            region, 
            subBannerGroups,
            status, 
            function(result, event){
            console.log('42: '+result);
                if (event.status) {
                    for(var colVal in result) {
                        document.getElementById(''+colVal+'-42').innerHTML = result[colVal].toFixed(1);
                    } 
                    calculateColumn43(status);
                } 
                else {
                     document.getElementById(errorMsgId).innerHTML = 'Exception in Calculating col42';
                     $j("#loading").hide();
                }
            }
        );
     
    }

    //Calculate Column 43 i.e. Volume by Month (MAT):APR
    function calculateColumn43(status) {
        
        Visualforce.remoting.Manager.invokeAction(
            remoteActions[16],
            dateString,
            region, 
            subBannerGroups,
            status, 
            function(result, event){
                if (event.status) {
                console.log('43: '+result);
                    for(var colVal in result) {
                        document.getElementById(''+colVal+'-43').innerHTML = result[colVal].toFixed(1);
                    } 
                    calculateColumn44(status);
                } 
                else {
                     document.getElementById(errorMsgId).innerHTML = 'Exception in Calculating col43';
                     $j("#loading").hide();
                }
            }
        );
     
    }

    //Calculate Column 44 i.e. Volume by Month (MAT):MAY
    function calculateColumn44(status) {
        
        Visualforce.remoting.Manager.invokeAction(
            remoteActions[17],
            dateString,
            region, 
            subBannerGroups,
            status, 
            function(result, event){
                if (event.status) {
                    console.log('44: '+result);
                    for(var colVal in result) {
                        document.getElementById(''+colVal+'-44').innerHTML = result[colVal].toFixed(1);
                    } 
                    calculateColumn45(status);
                } 
                else {
                     document.getElementById(errorMsgId).innerHTML = 'Exception in Calculating col44';
                     $j("#loading").hide();
                }
            }
        );
     
    }

    //Calculate Column 45 i.e. Volume by Month (MAT):JUN
    function calculateColumn45(status) {
        
        Visualforce.remoting.Manager.invokeAction(
            remoteActions[18],
            dateString, 
            region, 
            subBannerGroups,
            status, 
            function(result, event){
                if (event.status) {
                    console.log('45: '+result);
                    for(var colVal in result) {
                        document.getElementById(''+colVal+'-45').innerHTML = result[colVal].toFixed(1);
                    } 
                    calculateColumn46(status);
                } 
                else {
                     document.getElementById(errorMsgId).innerHTML = 'Exception in Calculating col45';
                     $j("#loading").hide();
                }
            }
        );
     
    }

    //Calculate Column 46 i.e. Volume by Month (MAT):JUL
    function calculateColumn46(status) {
    
    Visualforce.remoting.Manager.invokeAction(
        remoteActions[19],
        dateString,
        region, 
        subBannerGroups,
        status, 
        function(result, event){
            if (event.status) {
                console.log('46: '+result);
                for(var colVal in result) {
                    document.getElementById(''+colVal+'-46').innerHTML = result[colVal].toFixed(1);
                } 
                calculateColumn47(status);
            } else {
                 document.getElementById(errorMsgId).innerHTML = 'Exception in Calculating col46';
                 $j("#loading").hide();
            }
        }
    );
     
    }

    //Calculate Column 47 i.e. Volume by Month (MAT):AUG
    function calculateColumn47(status) {
    
    Visualforce.remoting.Manager.invokeAction(
        remoteActions[20],
        dateString,
        region, 
        subBannerGroups,
        status, 
        function(result, event){
            if (event.status) {
                console.log('47: '+result);
                for(var colVal in result) {
                    document.getElementById(''+colVal+'-47').innerHTML = result[colVal].toFixed(1);
                } 
                calculateColumn48(status);
            } else {
                 document.getElementById(errorMsgId).innerHTML = 'Exception in Calculating col47';
                 $j("#loading").hide();
            }
        }
    );
     
    }

    //Calculate Column 48 i.e. Volume by Month (MAT):SEP
    function calculateColumn48(status) {
        
        Visualforce.remoting.Manager.invokeAction(
            remoteActions[21],
            dateString,
            region, 
            subBannerGroups,
            status, 
            function(result, event){
                if (event.status) {
                    console.log('48: '+result);
                    for(var colVal in result) {
                        document.getElementById(''+colVal+'-48').innerHTML = result[colVal].toFixed(1);
                    } 
                    calculateColumn49(status);
                } 
                else {
                     document.getElementById(errorMsgId).innerHTML = 'Exception in Calculating col48';
                     $j("#loading").hide();
                }
            }
        );
     
    }

    //Calculate Column 49 i.e. Volume by Month (MAT):OCT
    function calculateColumn49(status) {
        
        Visualforce.remoting.Manager.invokeAction(
            remoteActions[22],
            dateString, 
            region, 
            subBannerGroups,
            status, 
            function(result, event){
                if (event.status) {
                    console.log('49: '+result);
                    for(var colVal in result) {
                        document.getElementById(''+colVal+'-49').innerHTML = result[colVal].toFixed(1);
                    } 
                    calculateColumn50(status);
                } 
                else {
                     document.getElementById(errorMsgId).innerHTML = 'Exception in Calculating col49';
                     $j("#loading").hide();
                }
            }
        );
     
    }

    //Calculate Column 50 i.e. Volume by Month (MAT):NOV
    function calculateColumn50(status) {
        
        Visualforce.remoting.Manager.invokeAction(
            remoteActions[23],
            dateString,
            region, 
            subBannerGroups,
            status, 
            function(result, event){
                if (event.status) {
                console.log('50: '+result);
                    for(var colVal in result) {
                        document.getElementById(''+colVal+'-50').innerHTML = result[colVal].toFixed(1);
                    } 
                    calculateColumn51(status);
                } 
                else {
                     document.getElementById(errorMsgId).innerHTML = 'Exception in Calculating col50';
                     $j("#loading").hide();
                }
            }
        );
     
    }

    //Calculate Column 51 i.e. Volume by Month (MAT):DEC
    function calculateColumn51(status) {
        
        Visualforce.remoting.Manager.invokeAction(
            remoteActions[24],
            dateString,
            region, 
            subBannerGroups,
            status, 
            function(result, event){
                if (event.status) {
                    console.log('51: '+result);
                    for(var colVal in result) {
                        document.getElementById(''+colVal+'-51').innerHTML = result[colVal].toFixed(1);
                    } 
                    if(status) {
                       calculateBannerAllColumns();
                       formatCells(".redGreenCell",".percentSymbol1");
                    }   
                    else
                      calculateProductColumns();
                    counter ++;
                    if(counter == 2) {
                        populateFormatting();
                        $j("#loading").hide();
                    }
                    console.log('calculation ends for Products');
                } 
                else {
                     document.getElementById(errorMsgId).innerHTML = 'Exception in Calculating col51';
                     $j("#loading").hide();
                }
                
            }
        );
    }

} 

function calculateBannerAllColumns(){
   calculateProductSubClassificationSum("tr.classification","tr.bannerTotal");
}

function formatCells(nameRedGreenCells,nameOfPercentSymbol){
    $j(nameRedGreenCells).each(function() {
        var elementHtml = $j(this).html();
        if(elementHtml.charAt(0) == '-') {
            $j(this).css('color','red');
        }
        else {
            $j(this).css('color','green');
        }
    });
    $j(nameOfPercentSymbol).each(function() {
        $j(this).text($j(this).text()+'%');
    });

}
    
function calculateProductSubClassificationSum(rowId, subTotalRowId){

    var sum1 = 0.00, sum2 = 0.00, sum6 = 0.00, sum7 = 0.00, sum11 = 0.00, sum12 = 0.00, sum15 = 0.00, sum16 = 0.00, sum23 = 0.00, sum24 = 0.00, sum27 = 0.00, sum28 = 0.00;
    var sum19 =0.00, sum20 = 0.00, sum31 = 0.00, sum32 = 0.00, sum35 =0.00, sum36 = 0.00;
    var sum40 = 0.00, sum41 = 0.00, sum42 = 0.00, sum43 = 0.00, sum44 = 0.00, sum45 = 0.00, sum46 = 0.00, sum47 = 0.00, sum48 = 0.00, sum49 = 0.00, sum50 = 0.00, sum51 = 0.00;
    
    var currentRow;

    $j(rowId).each(function(){
    
        currentRow = $j(this).find("td");
    
        //Month block
        var one = parseFloat(currentRow.eq(1).text());
        sum1 += one;
        var two = parseFloat(currentRow.eq(2).text());
        sum2 += two;
        var three = (one - two);
        currentRow.eq(3).text(three.toFixed(1));
        var four = 0.00;
        if(two != 0)
           four = (three/two * 100);
        currentRow.eq(4).text(four.toFixed(1)); 
        
        //Calendar Year to Date
        var six = parseFloat(currentRow.eq(6).text());
        sum6 += six;
        var seven = parseFloat(currentRow.eq(7).text());
        sum7 += seven;
        var eight = (six - seven);
        currentRow.eq(8).text(eight.toFixed(1));
        var nine = 0.00;
        if(seven != 0)
           nine = (eight/seven * 100);
        currentRow.eq(9).text(nine.toFixed(1)); 
        
        //Volume by Quarter & Half TY vs. LY : Q1
        var eleven = parseFloat(currentRow.eq(11).text());
        sum11 += eleven;
        var twelve = parseFloat(currentRow.eq(12).text());
        sum12 += twelve;
        var thirteen = (eleven - twelve);
        currentRow.eq(13).text(thirteen.toFixed(1));
        var fourteen = 0.00;
        if(twelve != 0)
           fourteen = (thirteen/twelve * 100);
        currentRow.eq(14).text(fourteen.toFixed(1)); 
        
        //Volume by Quarter & Half TY vs. LY : Q2
        var fifteen = parseFloat(currentRow.eq(15).text());
        sum15 += fifteen;
        var sixteen = parseFloat(currentRow.eq(16).text());
        sum16 += sixteen;
        var seventeen = (fifteen - sixteen);
        currentRow.eq(17).text(seventeen.toFixed(1));
        var eighteen = 0.00;
        if(sixteen != 0)
           eighteen = (seventeen/sixteen * 100);
        currentRow.eq(18).text(eighteen.toFixed(1)); 
        
        //Volume by Quarter & Half TY vs. LY : H1
        var nineteen = (eleven + fifteen);
        currentRow.eq(19).text(nineteen.toFixed(1));
        sum19 += nineteen;
        var twenty = (twelve + sixteen);
        currentRow.eq(20).text(twenty.toFixed(1));
        sum20 += twenty;
        var twentyone = (nineteen - twenty);
        currentRow.eq(21).text(twentyone.toFixed(1));
        var twentytwo = 0.00;
        if(twenty != 0)
           twentytwo = (twentyone/twenty * 100);
        currentRow.eq(22).text(twentytwo.toFixed(1));
        
        //Volume by Quarter & Half TY vs. LY : Q3
        var twentythree = parseFloat(currentRow.eq(23).text());
        sum23 += twentythree;
        var twentyfour = parseFloat(currentRow.eq(24).text());
        sum24 += twentyfour;
        var twentyfive = (twentythree - twentyfour);
        currentRow.eq(25).text(twentyfive.toFixed(1));
        var twentysix = 0.00;
        if(twentyfour != 0)
           twentysix = (twentyfive/twentyfour * 100);
        currentRow.eq(26).text(twentysix.toFixed(1));
        
        //Volume by Quarter & Half TY vs. LY : Q4
        var twentyseven = parseFloat(currentRow.eq(27).text());
        sum27 += twentyseven;
        var twentyeight = parseFloat(currentRow.eq(28).text());
        sum28 += twentyeight;
        var twentynine = (twentyseven - twentyeight);
        currentRow.eq(29).text(twentynine.toFixed(1));
        var thirty = 0.00;
        if(twentyeight != 0)
           thirty = (twentynine/twentyeight * 100);
        currentRow.eq(30).text(thirty.toFixed(1));
        
        //Volume by Quarter & Half TY vs. LY : H2
        var thirtyone = twentythree + twentyseven;
        currentRow.eq(31).text(thirtyone.toFixed(1));
        sum31 += thirtyone;
        var thirtytwo = twentyfour + twentyeight;
        currentRow.eq(32).text(thirtytwo.toFixed(1));
        sum32 += thirtytwo;
        var thirtythree = (thirtyone - thirtytwo);
        currentRow.eq(33).text(thirtythree.toFixed(1));
        var thirtyfour = 0.00;
        if(thirtytwo != 0)
           thirtyfour = (thirtythree/thirtytwo * 100);
        currentRow.eq(34).text(thirtyfour.toFixed(1));
        
        //Volume by Quarter & Half TY vs. LY : Full Year
        
        var thirtyfive = (nineteen + thirtyone);
        currentRow.eq(31).text(thirtyfive.toFixed(1));
        sum35 += thirtyfive;
        var thirtysix = (twenty + thirtytwo);
        currentRow.eq(31).text(thirtysix.toFixed(1));
        sum36 += thirtysix;
        var thirtyseven = (thirtyfive - thirtysix);
        currentRow.eq(37).text(thirtyseven.toFixed(1));
        var thirtyeight = 0.00;
        if(thirtysix != 0)
           thirtyeight = (thirtyseven/thirtysix * 100);
        currentRow.eq(38).text(thirtyeight.toFixed(1));
        
        //Volume by Month (MAT)
        sum40 += parseFloat(currentRow.eq(40).text());
        sum41 += parseFloat(currentRow.eq(41).text());
        sum42 += parseFloat(currentRow.eq(42).text());
        sum43 += parseFloat(currentRow.eq(43).text());
        sum44 += parseFloat(currentRow.eq(44).text());
        sum45 += parseFloat(currentRow.eq(45).text());
        sum46 += parseFloat(currentRow.eq(46).text());
        sum47 += parseFloat(currentRow.eq(47).text());
        sum48 += parseFloat(currentRow.eq(48).text());
        sum49 += parseFloat(currentRow.eq(49).text());
        sum50 += parseFloat(currentRow.eq(50).text());
        sum51 += parseFloat(currentRow.eq(51).text());
        
    });
    
    calculatesubTotalRow(subTotalRowId, sum1, sum2, sum6, sum7, sum11, sum12, sum15, sum16, sum19, sum20, sum23, sum24, sum27, sum28, sum31, sum32, sum35, sum36, sum40, sum41, sum42, sum43, sum44, sum45, sum46, sum47, sum47, sum48, sum49, sum50, sum51);
        
}
    
function calcFour(currentRow, pos1, pos2, pos3, pos4, sum1, sum2){

   currentRow.eq(pos1).text(sum1.toFixed(1));
   currentRow.eq(pos2).text(sum2.toFixed(1));
   var three = sum1 - sum2;
   currentRow.eq(pos3).text(three.toFixed(1));
   var four = 0.00;
   if(sum2 != 0)
       four = (three/sum2 * 100);
   currentRow.eq(pos4).text(four.toFixed(1));
   
}
    
function calculatesubTotalRow(subTotalRowId, sum1, sum2, sum6, sum7, sum11, sum12, sum15, sum16, sum19, sum20, sum23, sum24, sum27, sum28, sum31, sum32, sum35, sum36, sum40, sum41, sum42, sum43, sum44, sum45, sum46, sum47, sum47, sum48, sum49, sum50, sum51) {
       
      $j(subTotalRowId).each(function(){
   
       currentRow = $j(this).find("td");
       
       //Month block
       calcFour(currentRow, 1, 2, 3, 4, sum1, sum2);
       
       //Calendar Year to Date
       calcFour(currentRow, 6, 7, 8, 9, sum6, sum7);
        
       //Volume by Quarter & Half TY vs. LY : Q1
       calcFour(currentRow, 11, 12, 13, 14, sum11, sum12);
        
       //Volume by Quarter & Half TY vs. LY : Q2
       calcFour(currentRow, 15, 16, 17, 18, sum15, sum16);
        
       //Volume by Quarter & Half TY vs. LY : H1
       calcFour(currentRow, 19, 20, 21, 22, sum19, sum20);
        
       //Volume by Quarter & Half TY vs. LY : Q3
       calcFour(currentRow, 23, 24, 25, 26, sum23, sum24);
        
       //Volume by Quarter & Half TY vs. LY : Q4
       calcFour(currentRow, 27, 28, 29, 30, sum27, sum28);
        
       //Volume by Quarter & Half TY vs. LY : H2
       calcFour(currentRow, 31, 32, 33, 34, sum31, sum32);
        
       //Volume by Quarter & Half TY vs. LY : Full Year
       calcFour(currentRow, 35, 36, 37, 38, sum35, sum36); 
        
       //Volume by Month (MAT)
       currentRow.eq(40).text(sum40.toFixed(1));
       currentRow.eq(41).text(sum41.toFixed(1));
       currentRow.eq(42).text(sum42.toFixed(1));
       currentRow.eq(43).text(sum43.toFixed(1));
       currentRow.eq(44).text(sum44.toFixed(1));
       currentRow.eq(45).text(sum45.toFixed(1));
       currentRow.eq(46).text(sum46.toFixed(1));
       currentRow.eq(47).text(sum47.toFixed(1));
       currentRow.eq(48).text(sum48.toFixed(1));
       currentRow.eq(49).text(sum49.toFixed(1));
       currentRow.eq(50).text(sum50.toFixed(1));
       currentRow.eq(51).text(sum51.toFixed(1));
       
    });
    
}
    
function calculateRangeSum(rowId, subTotalRowId){

    var sum1 = 0.00, sum2 = 0.00, sum6 = 0.00, sum7 = 0.00, sum11 = 0.00, sum12 = 0.00, sum15 = 0.00, sum16 = 0.00, sum23 = 0.00, sum24 = 0.00, sum27 = 0.00, sum28 = 0.00;
    var sum19 =0.00, sum20 = 0.00, sum31 = 0.00, sum32 = 0.00, sum35 =0.00, sum36 = 0.00;
    var sum40 = 0.00, sum41 = 0.00, sum42 = 0.00, sum43 = 0.00, sum44 = 0.00, sum45 = 0.00, sum46 = 0.00, sum47 = 0.00, sum48 = 0.00, sum49 = 0.00, sum50 = 0.00, sum51 = 0.00;
    
    var currentRow;

    $j(rowId).each(function(){
    
        currentRow = $j(this).find("td");
    
        //Month block
        sum1 += parseFloat(currentRow.eq(1).text());
        sum2 += parseFloat(currentRow.eq(2).text());
        
        //Calendar Year to Date
        sum6 += parseFloat(currentRow.eq(6).text());
        sum7 += parseFloat(currentRow.eq(7).text());
        
        //Volume by Quarter & Half TY vs. LY : Q1
        var eleven = parseFloat(currentRow.eq(11).text());
        sum11 += eleven;
        var twelve = parseFloat(currentRow.eq(12).text());
        sum12 += twelve;
        
        //Volume by Quarter & Half TY vs. LY : Q2
        var fifteen = parseFloat(currentRow.eq(15).text());
        sum15 += fifteen;
        var sixteen = parseFloat(currentRow.eq(16).text());
        sum16 += sixteen;
        
        //Volume by Quarter & Half TY vs. LY : H1
        var nineteen = eleven + fifteen;
        currentRow.eq(19).text(nineteen.toFixed(1));
        sum19 += nineteen;
        var twenty = twelve + sixteen;
        currentRow.eq(20).text(twenty.toFixed(1));
        sum20 += twenty;
        
        //Volume by Quarter & Half TY vs. LY : Q3
        var twentythree = parseFloat(currentRow.eq(23).text());
        sum23 += twentythree;
        var twentyfour = parseFloat(currentRow.eq(24).text());
        sum24 += twentyfour;
        
        //Volume by Quarter & Half TY vs. LY : Q4
        var twentyseven = parseFloat(currentRow.eq(27).text());
        sum27 += twentyseven;
        var twentyeight = parseFloat(currentRow.eq(28).text());
        sum28 += twentyeight;
        
        //Volume by Quarter & Half TY vs. LY : H2
        var thirtyone = twentythree + twentyseven;
        currentRow.eq(31).text(thirtyone.toFixed(1));
        sum31 += thirtyone;
        var thirtytwo = twentyfour + twentyeight;
        currentRow.eq(32).text(thirtytwo.toFixed(1));
        sum32 += thirtytwo;
        
        //Volume by Quarter & Half TY vs. LY : Full Year
        var thirtyfive = nineteen + thirtyone;
        currentRow.eq(31).text(thirtyfive.toFixed(1));
        sum35 += thirtyfive;
        var thirtysix = twenty + thirtytwo;
        currentRow.eq(31).text(thirtysix.toFixed(1));
        sum36 += thirtysix;
        
        //Volume by Month (MAT)
        sum40 += parseFloat(currentRow.eq(40).text());
        sum41 += parseFloat(currentRow.eq(41).text());
        sum42 += parseFloat(currentRow.eq(42).text());
        sum43 += parseFloat(currentRow.eq(43).text());
        sum44 += parseFloat(currentRow.eq(44).text());
        sum45 += parseFloat(currentRow.eq(45).text());
        sum46 += parseFloat(currentRow.eq(46).text());
        sum47 += parseFloat(currentRow.eq(47).text());
        sum48 += parseFloat(currentRow.eq(48).text());
        sum49 += parseFloat(currentRow.eq(49).text());
        sum50 += parseFloat(currentRow.eq(50).text());
        sum51 += parseFloat(currentRow.eq(51).text());
        
    });
    
    calculatesubTotalRow(subTotalRowId, sum1, sum2, sum6, sum7, sum11, sum12, sum15, sum16, sum19, sum20, sum23, sum24, sum27, sum28, sum31, sum32, sum35, sum36, sum40, sum41, sum42, sum43, sum44, sum45, sum46, sum47, sum47, sum48, sum49, sum50, sum51);
}
