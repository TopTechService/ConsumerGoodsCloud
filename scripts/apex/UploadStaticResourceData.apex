cgcloud.PostInstallDemoDataEndPoint.installDemoData();
Database.executeBatch(new cgcloud.PostInstallDemoSetupDataBatch('RetailRepositoryData', cgcloud.PostInstallDemoSetupDataBatch.ResourceScope.RETAIL_ONLY), 1);
Database.executeBatch(new cgcloud.PostInstallDemoSetupDataBatch('RetailRepositoryData', cgcloud.PostInstallDemoSetupDataBatch.ResourceScope.SYNC_ONLY),1 );
cgcloud.PostInstallPPPDemoDataEndPoint.installDemoData();
