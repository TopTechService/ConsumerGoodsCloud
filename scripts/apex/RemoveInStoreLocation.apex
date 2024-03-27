List<RetailStoreKpi> kpis = [SELECT Id, InStoreLocationCategory FROM RetailStoreKpi];
For (RetailStoreKpi kpi : kpis) {
    kpi.InStoreLocationCategory = null;
}
update kpis;