@isTest
public class KARowWrapperTest{

    public static testMethod void myUnitTest(){
    
        test.startTest();
        
        KARowWrapper wrap1 = new KARowWrapper('Total Range');
        
        wrap1.col1 = wrap1.col6 = wrap1.col11 = wrap1.col15 = wrap1.col19 = wrap1.col23 = wrap1.col27 = wrap1.col31 = wrap1.col35 = wrap1.col40 = wrap1.col42 = wrap1.col44  = wrap1.col46 = wrap1.col48 = wrap1.col50 = 100;
        
        wrap1.col2 = wrap1.col7 = wrap1.col12 = wrap1.col16 = wrap1.col20 = wrap1.col24 = wrap1.col28 = wrap1.col32 = wrap1.col36  = wrap1.col41 = wrap1.col43 = wrap1.col45  = wrap1.col47 = wrap1.col49 = wrap1.col51 = 50; 
        
        KARowWrapper wrap2 = new KARowWrapper('Total Banner');
        
        wrap2.col1 = wrap2.col6 = wrap2.col11 = wrap2.col15 = wrap2.col19 = wrap2.col23 = wrap2.col27 = wrap2.col31 = wrap2.col35 = wrap2.col40 = wrap2.col42 = wrap2.col44  = wrap2.col46 = wrap2.col48 = wrap2.col50 = 100;
        
        wrap2.col2 = wrap2.col7 = wrap2.col12 = wrap2.col16 = wrap2.col20 = wrap2.col24 = wrap2.col28 = wrap2.col32 = wrap2.col36  = wrap2.col41 = wrap2.col43 = wrap2.col45  = wrap2.col47 = wrap2.col49 = wrap2.col51 = 50;
        
        wrap1.addValues(wrap2);
        
        System.assertEquals(wrap1.col1, 200);
        System.assertEquals(wrap1.col2, 100);
        System.assertEquals(wrap1.col6, 200);
        System.assertEquals(wrap1.col7, 100);
        System.assertEquals(wrap1.col11, 200);
                
        System.assertEquals(wrap1.col12, 100);
        System.assertEquals(wrap1.col15, 200);
        System.assertEquals(wrap1.col16, 100);
        System.assertEquals(wrap1.col19, 200);
        System.assertEquals(wrap1.col20, 100);
        
        System.assertEquals(wrap1.col23, 200);
        System.assertEquals(wrap1.col24, 100);
        System.assertEquals(wrap1.col27, 200);
        System.assertEquals(wrap1.col28, 100);
        System.assertEquals(wrap1.col31, 200);
                
        System.assertEquals(wrap1.col32, 100);
        System.assertEquals(wrap1.col35, 200);
        System.assertEquals(wrap1.col36, 100);
        System.assertEquals(wrap1.col40, 200);
        
        System.assertEquals(wrap1.col41, 100);
        System.assertEquals(wrap1.col42, 200);
        System.assertEquals(wrap1.col43, 100);
        System.assertEquals(wrap1.col44, 200);
        System.assertEquals(wrap1.col45, 100);
                                              
        System.assertEquals(wrap1.col46, 200);
        System.assertEquals(wrap1.col47, 100);
        System.assertEquals(wrap1.col48, 200);
        System.assertEquals(wrap1.col49, 100);
        System.assertEquals(wrap1.col50, 200);                                       
        
        System.assertEquals(wrap1.col51, 100);                               
        
        wrap1.calculateAllColumnsAndSetScale();
        
        System.assertNotEquals(wrap1.col3,0);
        System.assertEquals(wrap1.col3Color, 'green');        
        System.assertNotEquals(wrap1.col4,0);
        System.assertEquals(wrap1.col4Color, 'green'); 
        
        System.assertNotEquals(wrap1.col8,0);
        System.assertEquals(wrap1.col8Color, 'green');        
        System.assertNotEquals(wrap1.col9,0);
        System.assertEquals(wrap1.col9Color, 'green'); 
        
        System.assertNotEquals(wrap1.col13,0);
        System.assertEquals(wrap1.col13Color, 'green');        
        System.assertNotEquals(wrap1.col14,0);
        System.assertEquals(wrap1.col14Color, 'green'); 
        
        System.assertNotEquals(wrap1.col17,0);
        System.assertEquals(wrap1.col17Color, 'green');        
        System.assertNotEquals(wrap1.col18,0);
        System.assertEquals(wrap1.col18Color, 'green'); 
        
        System.assertNotEquals(wrap1.col21,0);
        System.assertEquals(wrap1.col21Color, 'green');        
        System.assertNotEquals(wrap1.col22,0);
        System.assertEquals(wrap1.col22Color, 'green'); 
        
        System.assertNotEquals(wrap1.col25,0);
        System.assertEquals(wrap1.col25Color, 'green');        
        System.assertNotEquals(wrap1.col26,0);
        System.assertEquals(wrap1.col26Color, 'green'); 
        
        System.assertNotEquals(wrap1.col29,0);
        System.assertEquals(wrap1.col29Color, 'green');        
        System.assertNotEquals(wrap1.col30,0);
        System.assertEquals(wrap1.col30Color, 'green'); 
        
        System.assertNotEquals(wrap1.col33,0);
        System.assertEquals(wrap1.col33Color, 'green');        
        System.assertNotEquals(wrap1.col34,0);
        System.assertEquals(wrap1.col34Color, 'green'); 
        
        System.assertNotEquals(wrap1.col37,0);
        System.assertEquals(wrap1.col37Color, 'green');        
        System.assertNotEquals(wrap1.col38,0);
        System.assertEquals(wrap1.col38Color, 'green'); 

        
        wrap2.calculateAllColumnsAndSetScale();
        
                System.assertNotEquals(wrap2.col3,0);
        System.assertEquals(wrap2.col3Color, 'green');        
        System.assertNotEquals(wrap2.col4,0);
        System.assertEquals(wrap2.col4Color, 'green'); 
        
        System.assertNotEquals(wrap2.col8,0);
        System.assertEquals(wrap2.col8Color, 'green');        
        System.assertNotEquals(wrap2.col9,0);
        System.assertEquals(wrap2.col9Color, 'green'); 
        
        System.assertNotEquals(wrap2.col13,0);
        System.assertEquals(wrap2.col13Color, 'green');        
        System.assertNotEquals(wrap2.col14,0);
        System.assertEquals(wrap2.col14Color, 'green'); 
        
        System.assertNotEquals(wrap2.col17,0);
        System.assertEquals(wrap2.col17Color, 'green');        
        System.assertNotEquals(wrap2.col18,0);
        System.assertEquals(wrap2.col18Color, 'green'); 
        
        System.assertNotEquals(wrap2.col21,0);
        System.assertEquals(wrap2.col21Color, 'green');        
        System.assertNotEquals(wrap2.col22,0);
        System.assertEquals(wrap2.col22Color, 'green'); 
        
        System.assertNotEquals(wrap2.col25,0);
        System.assertEquals(wrap2.col25Color, 'green');        
        System.assertNotEquals(wrap2.col26,0);
        System.assertEquals(wrap2.col26Color, 'green'); 
        
        System.assertNotEquals(wrap2.col29,0);
        System.assertEquals(wrap2.col29Color, 'green');        
        System.assertNotEquals(wrap2.col30,0);
        System.assertEquals(wrap2.col30Color, 'green'); 
        
        System.assertNotEquals(wrap2.col33,0);
        System.assertEquals(wrap2.col33Color, 'green');        
        System.assertNotEquals(wrap2.col34,0);
        System.assertEquals(wrap2.col34Color, 'green'); 
        
        System.assertNotEquals(wrap2.col37,0);
        System.assertEquals(wrap2.col37Color, 'green');        
        System.assertNotEquals(wrap2.col38,0);
        System.assertEquals(wrap2.col38Color, 'green');
        
        test.stopTest();
        
    
    }

}