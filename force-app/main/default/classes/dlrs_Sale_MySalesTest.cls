/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Sale_MySalesTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Sale_MySalesTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Sale_MySales__c());
    }
}