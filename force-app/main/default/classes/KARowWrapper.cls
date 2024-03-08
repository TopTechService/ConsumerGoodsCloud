/*
 * Class Name : KARowWrapper
 * Description - This class is used for holding individual row data for Proposed KA Report that is to be sent by email
 * @author Geeta Kushwaha (geeta.kushwaha@arxxus.com)
 * @revised : 24-12-2013 [created by Geeta Kushwaha]
 */ 
public class KARowWrapper {
    
    public String rowName {get;set;}
    
    public decimal col1 {get;set;}
    
    public decimal col2 {get;set;}
    
    public decimal col3 {get; private set;}
    
    public decimal col4 {get; private set;}
    
    public decimal col6 {get;set;}
    
    public decimal col7 {get; set;}
    
    public decimal col8 {get; private set;}
    
    public decimal col9 {get; private set;}
    
    public decimal col11 {get;set;}
    
    public decimal col12 {get;set;}
    
    public decimal col13 {get; private set;}
    
    public decimal col14 {get; private set;}
    
    public decimal col15 {get;set;}
    
    public decimal col16 {get;set;}
    
    public decimal col17 {get; private set;}
    
    public decimal col18 {get; private set;}
    
    public decimal col19 {get;set;}
    
    public decimal col20 {get;set;}
    
    public decimal col21 {get; private set;}
    
    public decimal col22 {get; private set;}
    
    public decimal col23 {get;set;}
    
    public decimal col24 {get;set;}
    
    public decimal col25 {get; private set;}
    
    public decimal col26 {get; private set;}
    
    public decimal col27 {get;set;}
    
    public decimal col28 {get;set;}
    
    public decimal col29 {get; private set;}
    
    public decimal col30 {get; private set;}
    
    public decimal col31 {get;set;}
    
    public decimal col32 {get;set;}
    
    public decimal col33 {get; private set;}
    
    public decimal col34 {get; private set;}
    
    public decimal col35 {get;set;}
    
    public decimal col36 {get;set;}
    
    public decimal col37 {get; private set;}
    
    public decimal col38 {get; private set;}
    
    public decimal col40 {get;set;}
    
    public decimal col41 {get;set;}
    
    public decimal col42 {get;set;}
    
    public decimal col43 {get;set;}
    
    public decimal col44 {get;set;}
    
    public decimal col45 {get;set;}
    
    public decimal col46 {get;set;}
    
    public decimal col47 {get;set;}
    
    public decimal col48 {get;set;}
    
    public decimal col49 {get;set;}
    
    public decimal col50 {get;set;}
    
    public decimal col51 {get;set;}
    
    public String col3Color {get; private set;}
    
    public String col4Color {get; private set;}
    
    public String col8Color {get; private set;}
    
    public String col9Color {get; private set;}
    
    public String col13Color {get; private set;}
    
    public String col14Color {get; private set;}
    
    public String col17Color {get; private set;}
    
    public String col18Color {get; private set;}
    
    public String col21Color {get; private set;}
    
    public String col22Color {get; private set;}
    
    public String col25Color {get; private set;}
    
    public String col26Color {get; private set;}
    
    public String col29Color {get; private set;}
    
    public String col30Color {get; private set;}
    
    public String col33Color {get; private set;}
    
    public String col34Color {get; private set;}
    
    public String col37Color {get; private set;}
    
    public String col38Color {get; private set;}
    
    public static final String red {get;set;}
    
    public static final String green {get;set;}
    
    static {
        
        red = 'red';
        
        green = 'green';
        
    }
    
    public KARowWrapper(String rowName){
        
        this.rowName = rowName;
        
        col1 = col2 = col3 = col4 = col6 = col7 = col8 = col9
        
        = col11 = col12 = col13 = col14 = col15 = col16 = col17 = col18 = col19 = col20
        
        = col21 = col22 = col23 = col24 = col25 = col26 = col27 = col28 = col29 = col30
        
        = col31 = col32 = col33 = col34 = col35 = col36 = col37 = col38 = col40
        
        = col41 = col42 = col43 = col44 = col45 = col46 = col47 = col48 = col49 = col50
        
        = col51 = 0;
        
    }
    
    public void addValues(KARowWrapper wrap){
        
        //Month
        
        col1 += wrap.col1;
    
        col2 += wrap.col2;       
        
        //Calendar Year to Date 
        
        col6 += wrap.col6;
        
        col7 += wrap.col7;
        
        //Volume by Quarter & Half TY vs. LY
        
        col11 += wrap.col11;
        
        col12 += wrap.col12;
        
        col15 += wrap.col15;
        
        col16 += wrap.col16;
        
        col19 += wrap.col19;
        
        col20 += wrap.col20;
        
        col23 += wrap.col23;
        
        col24 += wrap.col24;
        
        col27 += wrap.col27;
        
        col28 += wrap.col28;

        col31 += wrap.col31;
        
        col32 += wrap.col32;
 
        col35 += wrap.col35;
        
        col36 += wrap.col36;
 
        //Volume by Month (MAT)
        
        col40 += wrap.col40;
        
        col41 += wrap.col41;
        
        col42 += wrap.col42;
        
        col43 += wrap.col43;
        
        col44 += wrap.col44;
        
        col45 += wrap.col45;
        
        col46 += wrap.col46;
        
        col47 += wrap.col47;
        
        col48 += wrap.col48;
        
        col49 += wrap.col49;
        
        col50 += wrap.col50;
        
        col51 += wrap.col51;
        
    }
    
    public void calculateAllColumnsAndSetScale(){
        
        //Month
        
        col1 = col1.setScale(2);
    
        col2 = col2.setScale(2);
        
        col3 = (col1 - col2).setScale(2);
        
        col3Color = col3 >= 0 ? green : red;
        
        col4 = (col2 > 0 ? col3 / col2 * 100 : 0).setScale(1);
        
        col4Color = col4 >= 0 ? green : red;
        
        //Calendar Year to Date 
        
        col6 = col6.setScale(2);
        
        col7 = col7.setScale(2);
        
        col8 = (col6 - col7).setScale(2);
        
        col8Color = col8 >= 0 ? green : red;
        
        col9 = (col7 > 0 ? col8 / col7 * 100 : 0).setScale(1);
        
        col9Color = col9 >= 0 ? green : red;
        
        //Volume by Quarter & Half TY vs. LY
        
        col11 = col11.setScale(2);
        
        col12 = col12.setScale(2);
        
        col13 = (col11 - col12).setScale(2);
        
        col13Color = col13 >= 0 ? green : red;
        
        col14 = (col12 > 0 ? col13 / col12 * 100 : 0).setScale(1);
        
        col14Color = col14 >= 0 ? green : red;
        
        col15 = col15.setScale(2);
        
        col16 = col16.setScale(2);
        
        col17 = (col15 - col16).setScale(2);
        
        col17Color = col17 >= 0 ? green : red;
        
        col18 = (col16 > 0 ? col17 / col16 * 100 : 0).setScale(1);
        
        col18Color = col18 >= 0 ? green : red;
        
        col19 = (col11 + col15).setScale(2);
        
        col20 = (col12 + col16).setScale(2);
        
        col21 = (col19 - col20).setScale(2);
        
        col21Color = col21 >= 0 ? green : red;
        
        col22 = (col20 > 0 ? col21 / col20 * 100 : 0).setScale(1);
        
        col22Color = col22 >= 0 ? green : red;
        
        col23 = col23.setScale(2);
        
        col24 = col24.setScale(2);
        
        col25 = (col23 - col24).setScale(2);
        
        col25Color = col25 >= 0 ? green : red;
        
        col26 = (col24 > 0 ? col25 / col24 * 100 : 0).setScale(1);
        
        col26Color = col26 >= 0 ? green : red;
        
        col27 = col27.setScale(2);
        
        col28 = col28.setScale(2);
        
        col29 = (col27 - col28).setScale(2);
        
        col29Color = col29 >= 0 ? green : red;
        
        col30 = (col28 > 0 ? col29 / col28 * 100 : 0).setScale(1);
        
        col30Color = col30 >= 0 ? green : red;
        
        col31 = (col23 + col27).setScale(2);
        
        col32 = (col24 + col28).setScale(2);
        
        col33 = (col31 - col32).setScale(2);
        
        col33Color = col33 >= 0 ? green : red;
        
        col34 = (col32 > 0 ? col33 / col32 * 100 : 0).setScale(1);
        
        col34Color = col34 >= 0 ? green : red;
        
        col35 = (col19 + col31).setScale(2);
        
        col36 = (col20 + col32).setScale(2);
        
        col37 = (col35 - col36).setScale(2);
        
        col37Color = col37 >= 0 ? green : red;
        
        col38 = (col36 > 0 ? col37 / col36 * 100 : 0).setScale(1);
        
        col38Color = col38 >= 0 ? green : red;
        
        //Volume by Month (MAT)
        
        col40 = col40.setScale(2);
        
        col41 = col41.setScale(2);
        
        col42 = col42.setScale(2);
        
        col43 = col43.setScale(2);
        
        col44 = col44.setScale(2);
        
        col45 = col45.setScale(2);
        
        col46 = col46.setScale(2);
        
        col47 = col47.setScale(2);
        
        col48 = col48.setScale(2);
        
        col49 = col49.setScale(2);
        
        col50 = col50.setScale(2);
        
        col51 = col51.setScale(2);  
        
    }

}