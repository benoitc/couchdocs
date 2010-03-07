= Unique Values in SQL Table Converted to Individual Documents =
Cro-Magnon simple python script which will take the contents of an SQL table and place it into CouchDB.

This particular example depends on the SQL table having one unique field. The values in the unique field become individual documents in the CouchDB database.

You'll need the python couchdb module from http://code.google.com/p/couchdb-python/ , plus whatever DBAPI2.0 compliant module you use to connect to your favorite SQL database.This example uses Oracle, but it should be trivial to convert.

This is probably not what you want. :-)

{{{#!python
#!/usr/bin/env python
import couchdb, cx_Oracle, ConfigParser, os, datetime

# Convert a list of (sql tables, unique identifiers) into couchDB documents
# Simply figure out which db you wish to import from, and a series of tables,
# with unique fields you'd like to have them
# indexed by, put them into the list of tuples below and let fly.
# I store all my config stuf in an ini file locally.  you'll have to handle
# your own connection to your db.
# This is pretty quick-and-dirty and I don't reccomend it for any sort of
# production anything at all! :-)
# Should work for any db api 2 compliant sql database.
# Script guaranteed 100% slower than christmas.

db_name = 'mydatabase'
table_names = [ ('TABLE_NAME0', 'UNIQUE_FIELD'),
                ('TABLE_NAME1', 'UNIQUE_FIELD'),
                ('TABLE_NAME2', 'UNIQUE_FIELD') ]

class GrabbyMitts(object):
    def __init__( self, db_name ):
        config = ConfigParser.ConfigParser()
        config.optionxform = str
        config.read( [ "sqlgen.ini", os.path.expanduser("~/.sqlgen.ini" ) ] )

        # oracle connection
        self.connection = cx_Oracle.Connection( config.get("Oracle", "login") )

        # couchdb location
        self.couch = couchdb.Server( "http://localhost:5984/" )
        try:
            self.db = self.couch.create( db_name )
        except:
            self.db = self.couch[ db_name ]

    def description( self ):
        # get a description of a given table
        # returns the "header" information in list
        query = "select * from %s where 1=0"%self.table_name
        cursor = cx_Oracle.Cursor( self.connection )
        cursor.execute( query )
        description = [ i[0] for i in cursor.description ]
        cursor.close()
        return description

    def uniques( self ):
        # unique value in sql table to create couchdb document ID
        cursor = cx_Oracle.Cursor( self.connection )
        query = "select %s from %s"%( self.mykey, self.table_name )
        cursor.execute( query )
        myuniques = [ i[0] for i in cursor.fetchall() if i[0] ]
        cursor.close()
        return myuniques

    def updateCouch( self, table_and_key ):
        # populate or update couchdb documents using sql table and unique
        # identifier
        self.table_name, self.mykey = table_and_key
        cursor = cx_Oracle.Cursor( self.connection )
        documents = []
        header = self.description()

        query = """
            select %s
            from %s
            where %s=:myunique"""""%( ", ".join( header ),
                                    self.table_name,
                                    self.mykey )
        cursor.prepare( query )

        for myunique in [ { "myunique": i } for i in self.uniques() ]:
            cursor.execute( None, myunique )
            entry = dict( [ (k, v) for k, v in zip( header, cursor.fetchone() ) ] )
            # mop up datetime objects as they occour, since json cries foul.
            # will probably need to convert to unix epochal time
            for k in entry:
                if isinstance( entry[k], datetime.datetime ):
                    entry[ k ] = "%s"%entry[ k ]

            if str( myunique[ 'myunique' ] ) not in self.db:
                self.db[ str( myunique[ 'myunique' ] ) ] = entry
            else:
                doc = self.db[ str( myunique[ 'myunique' ] ) ]
                for k in entry:
                    doc[ k ] = entry[ k ]
                self.db[ str( myunique[ 'myunique' ] ) ] = doc

        cursor.close()

if __name__ == "__main__":
    gm = GrabbyMitts( db_name )
    for table_name in table_names:
        gm.updateCouch( table_name )
}}}
= Unique Values in SQL Table Converted to a Single Document =
Differs from above in that it places all table data into a single document.

{{{#!sql

select username, shoe_size, nostril_count, owns_weather_ballon from humans;

username | shoe_size | nostril_count | owns_weather_balloon

cletus        | 10            | 3                    | y
}}}
becomes:

{{{#!python

db[ 'humans' ]{'username': 'cletus','shoe_size': 10,'nostril_count': 3,'owns_weather_balloon': 'y' }
}}}
This probably isn't what you want either! Script does no checking to make sure that your particular value is unique.

{{{#!python
# HEY! THIS VERSION CAN MAKE A MOTHER-HUGE DOCUMENT! KNOW WHAT YOU ARE DOING!!!
# Convert a list of (sql tables, unique identifiers) into a single couchDB document
# Switch out with updateCouch() above

    def updateCouch( self, table_and_key ):
        # populate or update couchdb documents using sql table and unique
        # identifier
        # HEY! THIS CAN MAKE A MOTHER-HUGE DOCUMENT! KNOW WHAT YOU ARE DOING!!!
        self.table_name, self.mykey = table_and_key

        cursor = cx_Oracle.Cursor( self.connection )
        documents = []
        header = self.description()

        query = """
            select %s
            from %s
            order by %s"""""%( ", ".join( header ),
                                    self.table_name,
                                    self.mykey )

        cursor.execute( query )
        results = dict(
                [ ( str( row[0] ), dict(
                    [ (k, v) for k, v in zip( header, row ) ]
                    ) ) for row in cursor.fetchall()
                ] )

        # clean up any datetime fields
        for row in results:
            for field in results[ row ]:
                if isinstance( results[ row ][ field ], datetime.datetime ):
                    results[ row ][ field ] = "%s"%results[ row ][ field ]
        self.db[ self.table_name ] = results

        cursor.close()
}}}
