List<ProductCategoryProduct> toUpdate = [SELECT Id, IsPrimaryCategory FROM ProductCategoryProduct];
for(ProductCategoryProduct pcp : toUpdate) {
    pcp.IsPrimaryCategory = true;
}
update toUpdate;