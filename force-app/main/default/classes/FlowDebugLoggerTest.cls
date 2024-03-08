@isTest
private class FlowDebugLoggerTest {
    @isTest
    static void testFlowDebugLogger() {
        // Create test data
        List<String> debugMessages = new List<String>{'Debug Message 1', 'Debug Message 2', 'Debug Message 3'};
        
        // Call the invocable method
        Test.startTest();
        FlowDebugLogger.trace(debugMessages);
        Test.stopTest();
        
       
    }
}