/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
global class MockOrderResponseTest implements HttpCalloutMock{
	// Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/xml');
       string str = 	'<SupplierOrderResponse>'
					   + '<OrderDetail>'
					   + ' <OrderHeaderResponse>'
					   + ' <WebOrderId>0</WebOrderId>'
					   + ' <VendorOrderId></VendorOrderId>'
					   + ' <SupplierRepCode>75245001</SupplierRepCode>'
					   + ' <SupplierRepStateCode>1</SupplierRepStateCode>'
					   + ' <SupplierReference>ttttttt</SupplierReference>'
					   + ' <TurnInOrderType>T</TurnInOrderType>'
					   + ' <CustomerId>800646</CustomerId>'
					   + ' <CustomerStateCode>2</CustomerStateCode>'
					   + ' <WebCreatedTime>20130605161755</WebCreatedTime>'
					   + ' <ItemsAccepted>1</ItemsAccepted>'
					   + ' <ItemsRejected>2</ItemsRejected>'
					   + ' <OrderHeaderMessages>'
                	   + ' <HeaderMessageData>Customer could not be found for the'
                       + ' ID specified. - CustomerId:80064:CustomerState:2</HeaderMessageData>'
                	   + '	<HeaderMessageSeverity>ERROR</HeaderMessageSeverity>'
            		   + '	</OrderHeaderMessages>'
            			+ '	<OrderHeaderMessages>'
                		+ '	<HeaderMessageData>Errors Detected, this order could not'
                    	+ '	be processed. Please review the details you have'
                    	+ '	submitted. For further assistance, please contact'
                    	+ '	your ALM account administrator.</HeaderMessageData>'
                		+ '	<HeaderMessageSeverity>ERROR</HeaderMessageSeverity>'
            			+ '	</OrderHeaderMessages>'
					   + ' </OrderHeaderResponse>'
					   + ' <LineMessages>'
					   + ' <LineId>1</LineId>'
					   + ' <ProductCode>52622</ProductCode>'
					   + ' <ProductDescription>Product Detail Unavailable.</ProductDescription>'
					   + ' <OrderQuantity>12</OrderQuantity>'
					   + ' <LineMessageData>An error was encountered processing this'
					   + '	order line. Please review messages or contact your ALM'
					   + '  Administrator for further detail. </LineMessageData>'
					   + ' <LineMessageSeverity>ERROR</LineMessageSeverity>'
					   + ' </LineMessages>'
					  
					   + ' </OrderDetail>'
					   + ' </SupplierOrderResponse>';
        res.setBody(str);
        res.setStatusCode(200);
        return res;
    }
}