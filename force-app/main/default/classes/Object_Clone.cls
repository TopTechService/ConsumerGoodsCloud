/**
 * Purpose: Clone Quote from Custom button
 * Copying all createable fields to the new clone
 * Ignores Unique fields so they must be filled in manually
 */

global class Object_Clone {

    private Static Map<ID, ID> oldIDToNewID = New Map<ID, ID>();
    private Static String errorThrown;
    @TestVisible private STATIC FINAL String TOMANYTYPES = 'Multiple Object Types were detected in the initial records';
    @TestVisible private STATIC FINAL String NORECORDS = 'No Records to clone';


    public class Object_Clone_Exception extends Exception {

    }

    //****************************************************************************
    //   List of Objects to not clone
    //****************************************************************************

    @TestVisible private STATIC Set<String> excludedObjects {
        get {
            if (excludedObjects == null) {
                return New Set<String>();
            } else {
                return excludedObjects;
            }
        }
    }


    //*****************************************************************************
    //   Execute Clone Method - SINGLE ID
    //       From button
    //*****************************************************************************
	//Use @AuraEnabled to enable client- and server-side access to the method
    @AuraEnabled
    webservice static String cloneObjectSingle(ID oId, boolean withChildren) {
        if (cloneObjectWithExclude(New Set<ID>{oId}, withChildren, null)) {
            //If we are here then no errors so return the URL to the new Cloned Record
            //return New PageReference('/' + oldIDToNewID.get(oId)).getURL();
            return New PageReference( oldIDToNewID.get(oId)).getURL();
        } else {
            return null;
        }

    }

    /*****************************************************************************
    *   Execute Clone Method - SET OF IDs
    *       NOT specifying Child Objects to Exclude if cloning children
    ******************************************************************************/

    public static Boolean cloneObjectSet(Set<ID> oId, boolean withChildren) {
        return cloneObjectWithExclude(oId, withChildren, null);
    }


    /*****************************************************************************
    *   Execute Clone Method - SET OF IDs
    *       Specifying Child Objects to Exclude if cloning children
    ******************************************************************************/

    public static boolean cloneObjectWithExclude(Set<ID> oIds, boolean withChildren, Set<String> objectsToExclude) {
        try {
            //Reset Error
            errorThrown = null;

            //Remove nulls in case they were added to a set from above methods
            oIds.remove(null);

            //Ensure that we at least have some records
            if (oIds == null || oIds.isEmpty()) {
                throw New Object_Clone_Exception(NORECORDS);
            }

            //Populate the Excluded Object Type with Force exclude as well as User Specified
            setexcludedObjects(objectsToExclude);

            //Collection of Types to clone
            Map<Schema.SObjectType, Set<ID>> types = New Map<Schema.SObjectType, Set<ID>>();

            //Build up the collection of types to Records
            for (ID oId : oIds) {
                Set<ID> existingIDsInMap = types.get(oId.getSobjectType());
                if (existingIDsInMap == null) existingIDsInMap = New Set<ID>();
                existingIDsInMap.add(oId);
                types.put(oId.getSobjectType(),existingIDsInMap);
            }

            //For each type clone the records
            for (Schema.SObjectType objtype : types.keySet()) {

                //Start the process cloning the parent with the desired options
                cloneObjects(queryForRecords(types.get(objtype), null), (withChildren == null ? false : withChildren), true);
            }

            return true;

        } catch (Exception e) {
            //We had an error so return nothing
            system.debug(logginglevel.error, e.getMessage() + ' - ' + e.getStackTraceString());
            errorThrown = e.getMessage();
            return false;
        }
    }

    /*****************************************************************************
    *   MAIN CLONE ENTRY METHOD
    *       Executed from one of the cloneObject Methods
    ******************************************************************************/

    private static Map<Schema.SObjectType, sObject[]> cloneObjects(sObject[] oObjs, boolean withChildren, boolean doinsert) {

        //New Records to Return
        Map<Schema.SObjectType, sObject[]> results = New Map<Schema.SObjectType, sObject[]>();

        //Collection of Related Objects and their Parent Fields
        Map<Schema.SObjectType, Schema.sObjectField[]> childRelationships;

        Map<ID, SObject> oldRecToNewRec = New Map<ID, SObject>();

        //For each record for this sObjectType
        for (sObject oldObj : oObjs) { //queryForRecords(oIds, flds)) {
            Schema.SObjectType objtype = oldObj.getSObjectType();

            //Create a new Object
            sObject newObj = oldObj.clone(false, true);

            //Populate the map with the Old ID as a key and the New Record as the value
            oldRecToNewRec.put(oldObj.id, newObj);
            
            system.debug('### newObj ' + newObj);


            if (doInsert) {
                insert oldRecToNewRec.values();

                //Store the old to new IDs
                for (ID i : oldRecToNewRec.keySet()) {
                    oldIDToNewID.put(i, oldRecToNewRec.get(i).id);
                }

                if (withChildren) {
                    //Get the related Objects
                    //childRelationships = getRelatedObjects(objtype);

                    //Fire off the clone children which will call this method in a cyclic fashion
                    //until all children and their children are cloned
                    //cloneChildren(oldRecToNewRec.keySet(), childRelationships);
                }
            }

            //Add the record to the final results by Object type
            results.put(objtype, oldRecToNewRec.values());


        }

        return results;
    }

    /******************************************************************************
    *
    *   Get children of object and clone them as well
    *
    *******************************************************************************/

    /*private static void cloneChildren(Set<ID> pIds, Map<Schema.SObjectType, Schema.sObjectField[]> pFields) {

        //
        //    Currently no checks on limits
        //    This method will do 1 query and 1 dml for each group of child objects
        //    If those objects have children it will continue to add to the counts
        // 

        //Each child relationship field has its own type so we will need to go through each type and attempt to clone the records
        for (Schema.sObjectType cObjType : pFields.keySet()) {
            Schema.DescribeSObjectResult objTypeDescribe = cObjType.getDescribe();

            if (objTypeDescribe.isCreateable() == false ||
                    objTypeDescribe.getName().endsWithIgnoreCase('share') ||
                    excludedObjects.contains(objTypeDescribe.getName())) continue;

            String[] pFieldNames = new String[]{};

            //Get a List of Fields related to Parent Object
            for (Schema.SObjectField pFld : pFields.get(cObjType))
                pFieldNames.add(pFld.getDescribe().getName());


            //build the where clause - Just in case there are multiple fields related to the same SObjectType
            String pFieldWhere = '';
            for (String pFld : pFieldNames) {
                if (pFieldWhere != '') pFieldWhere += ' OR ';
                pFieldWhere += pFld + ' IN :rIds';
            }

            //Query for values - using rIds in the Where clause as the method uses that variable name for pIds here
            Map<ID, sObject> childRecords = New Map<ID, SObject>(queryForRecords(cObjType, pIds, pFieldWhere));
//            system.debug(logginglevel.error, childRecords);

            if (!childRecords.isEmpty()) {
                Map<Schema.SObjectType, sObject[]> newChildren = cloneObjects(childRecords.values(), true, false);

                for (sObject newChild : newChildren.get(cObjType)) {
//                    system.debug(logginglevel.error, 'Starting replace of Parent IDs');
                    for (String pField : pFieldNames) {
//                        system.debug(logginglevel.error, 'pField: ' + pField);
                        Object oPid = newChild.get(pField);
//                        system.debug(logginglevel.error, 'Old pId: ' + oPid);
                        if (oPid != null && oldIDToNewID.get((ID) oPid) != null) {
//                            system.debug(logginglevel.error, 'New pId: ' + oldIDToNewID.get((ID) oPid));
                            newChild.put(pField, oldIDToNewID.get((ID) oPid));
                        }
                    }
                }

                insert newChildren.get(cObjType);
            }
        }
    }*/


    /******************************************************************************
    *
    *   Query for Records to Clone
    *       Getting the ObjectType from the ID Set
    *       Ensuring that there is only one ObjectType
    *
    *******************************************************************************/

    @TestVisible private static sObject[] queryForRecords(Set<ID> rIds, String customWhereClause) {
        if (rIds == null || rIds.isEmpty()) return new sObject[]{};

        Schema.SObjectType oType;

        //Just a double check to ensure that once we get here there is only 1 object type to query
        for (ID rId : rIds) {
            if (oType == null) {
                oType = rId.getSObjectType();
            } else {
                if (rId.getSobjectType() != oType)
                    throw New Object_Clone_Exception(TOMANYTYPES);
            }
        }

        return queryForRecords(oType, rIds, customWhereClause);
    }

    /******************************************************************************
    *
    *   Query for Records to Clone - Main Method
    *       Requires Single Known ObjectType
    *
    *******************************************************************************/

    private static sObject[] queryForRecords(Schema.sObjectType oType, Set<ID> rIds, String customWhereClause) {
//        system.debug(logginglevel.error, oType);
//        system.debug(logginglevel.error, oType);

        if (rIds == null || rIds.isEmpty()) return New SObject[]{};

        String[] fldsToClone = getCreateableFields(oType);
        system.debug(logginglevel.error, fldsToClone);

        String query = 'Select ID, ';

        query += string.join(fldsToClone, ',');


        query += ' From ' + oType; // + ' Where ID IN :rIds';

        if (customWhereClause != null) {
            query += ' Where ' + customWhereClause;
        } else {
            query += ' Where ID IN :rIds';
        }
        system.debug(logginglevel.error, query);
        return database.query(query);

    }





    /******************************************************************************
    *
    *   Gets Creatable Fields
    *
    *******************************************************************************/
    private static String[] getCreateableFields(Schema.sObjectType obj) {
        String[] results = New String[]{
        };


        for (Schema.sObjectField fld : obj.getDescribe().fields.getMap().values()) {

            Schema.DescribeFieldResult dfr = fld.getDescribe();

            //ignore Unique fields. They will have to be filled in manually
            if (!dfr.isUnique() && (dfr.isCreateable() || dfr.isUpdateable())) {
                results.add(dfr.getName());
            }
        }


        return results;

    }

    /******************************************************************************
    *
    *   Gets Relationship Fields
    *       - Returning the SobjectType and the Relationship Field on that object
    *
    *******************************************************************************/


    /*private static Map<Schema.SObjectType, Schema.sObjectField[]> getRelatedObjects(Schema.sObjectType obj) {

        Map<Schema.SObjectType, Schema.sObjectField[]> results = New Map<Schema.SObjectType, Schema.sObjectField[]>();

        for (ChildRelationship r: obj.getDescribe().getChildRelationships()) {
            Schema.SObjectField[] tmp = results.get(r.getChildSObject());
            if (tmp == null) tmp = New Schema.SObjectField[]{};
            tmp.add(r.getField());
            results.put(r.getChildSObject(), tmp);
        }

        return results;

    }*/

    private static void setexcludedObjects(Set<String> userExcludedObjects) {
        //List of all object that are excluded from cloning
        Set<String> tmp = New Set<String>();
        Set<String> excludedObjects;

        Set<String> alwaysExclude = New Set<String>{
                'CollaborationGroupRecord'
        };

        if (userExcludedObjects != null) {
            for (String obj : userExcludedObjects)
                tmp.add(obj);
        }

        tmp.addAll(alwaysExclude);

        excludedObjects = tmp;
    }


    /******************************************************************************
    *
    *   Gets Error Thrown
    *
    *******************************************************************************/

    public static String getErrorMessage() {
        return errorThrown;
    }

}