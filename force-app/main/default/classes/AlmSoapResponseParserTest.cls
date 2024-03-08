@isTest
public with sharing class AlmSoapResponseParserTest {

	private static String responseXml = '<SupplierOrderResponse><OrderDetail><OrderHeaderResponse><WebOrderId>0' 
											+ '</WebOrderId><VendorOrderId>null</VendorOrderId><SupplierRepCode>75245003'
											+ '</SupplierRepCode><SupplierRepStateCode>3</SupplierRepStateCode><SupplierReference>'
											+ 'QLD (Vacant)ASM</SupplierReference><TurnInOrderType>O</TurnInOrderType><CustomerId>'
											+ '265676</CustomerId><CustomerStateCode>3</CustomerStateCode><WebCreatedTime>20140520154948'
											+ '</WebCreatedTime><ItemsAccepted>2</ItemsAccepted><ItemsRejected>0</ItemsRejected>'
											+ '<OrderHeaderMessages><HeaderMessageData>The field was submitted with invalid characters () ~ "'
											+ '</HeaderMessageData><HeaderMessageSeverity>ERROR</HeaderMessageSeverity></OrderHeaderMessages>' 
											+ '<OrderHeaderMessages><HeaderMessageData>Errors Detected, this order could not be processed.'
											+ ' Please review the details you have submitted. For further assistance, please contact your ALM '
											+ 'account administrator.</HeaderMessageData><HeaderMessageSeverity>ERROR</HeaderMessageSeverity>'
											+ '</OrderHeaderMessages></OrderHeaderResponse></OrderDetail></SupplierOrderResponse>';
	
	private static testMethod void testParserStringXmlResponse() {
		XmlStreamReader xs = new XmlStreamReader(responseXml);
		System.Test.startTest();
		AlmSoapResponseParser.parseStringXmlResponse(xs);
		System.Test.stopTest();
	}
	
	private static testMethod void testParserResponse() {
		XmlStreamReader xs = new XmlStreamReader(responseXml);
		System.Test.startTest();
		AlmSoapResponseParser.parseXMLResponse(xs);
		System.Test.stopTest();
	}
}