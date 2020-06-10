
import pymssql
class Database:
    connection=None;

    @classmethod
    def initialize(cls,**kwargs):
        Database.__connection=pymssql.connect(**kwargs)

        #=pool.SimpleConnectionPool(1,10,**kwargs); # double underscore before connectionpool (property) makes it private as python does not use private keyword as in other languages
        
    @classmethod
    def get_connection(cls):
        return cls.__connection;


    @classmethod
    def return_connection(cls, connection):
        return cls.__connection.close();

class cursorfromconnection:
    def __init__(self):
        self.connection = None

    def __enter__(self):
        self.connection=Database.get_connection()
        self.cursor = self.connection.cursor()
        #self.cursor = self.connection.cursor()
        return self.cursor

    def __exit__(self, exc_type, exc_val, exc_tb):
        if exc_val is not None:
            self.connection.rollback();

        else:
            self.cursor.close()
            self.connection.commit()
        Database.return_connection(self.connection)
            


