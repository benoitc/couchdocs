Getting started with PL/SQL and the CouchDB API.

= PL/COUCH =
PLCouch is a simple way to save Oracle-Data in a document based database. With PLCouch, you can create, updet and delete documents, manage Databases.

== Dependencies ==
 * http://code.google.com/p/pl-couch/

 * https://sourceforge.net/projects/pljson/

== Sample Usage ==
{{{
SET SERVEROUTPUT ON SIZE 1000000
DECLARE
  --
  PROCEDURE ASSERTTRUE(B BOOLEAN) AS
  BEGIN
    IF(NOT B) THEN RAISE_APPLICATION_ERROR(-20111, 'Test error'); END IF;
  END;
  --
  PROCEDURE ASSERTFALSE(B BOOLEAN) AS
  BEGIN
    IF(B) THEN RAISE_APPLICATION_ERROR(-20111, 'Test error'); END IF;
  END;
  --
BEGIN
  --
  -- Connect to database
  PL_COUCH_DB.INIT_DB(HOSTNAME  => :HOST
                     ,PORT      => :PORT
                     ,ADMIN     => :admin
                     ,adminpwd  => :adminpwd);
  ASSERTTRUE(PL_COUCH_DB.PING_COUCHDB);
  --
  DBMS_OUTPUT.PUT_LINE('couchDB-Version:' || PL_COUCH_DB.GET_VERSION);
  -- Check Database
  ASSERTTRUE(PL_COUCH_DB.PING_COUCHDB);
  --
  databasename := 'test' || TO_CHAR(SYSDATE, 'YYMMDDHH24MISS') || 'x';
  DBMS_OUTPUT.PUT_LINE('Create Database: ' || databasename);
  ASSERTTRUE(PL_COUCH_DB.CREATE_DB(DATABASENAME));
  --
  jList := PL_COUCH_DB.GET_ALL_DB;
  --
  IF jList.count > 0 THEN
    FOR I in 1 .. jList.count LOOP
        listElement := jList.get_elem(I);
        dummy := listElement.getvarchar2(charElement);
        DBMS_OUTPUT.PUT_LINE('Database: ' || charElement);
    END LOOP;
  END IF;
  --
  DBMS_OUTPUT.PUT_LINE('Drop Database: ' || databasename);
  ASSERTTRUE(PL_COUCH_DB.DROP_DB(DATABASENAME));
  --
END;
/

PROMPT ENDE
}}}
More Samples see: http://code.google.com/p/pl-couch/downloads/list
