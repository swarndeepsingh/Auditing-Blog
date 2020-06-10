from psycopg2 import pool
from psycopg2 import extras
import psycopg2
class Database:
    connection_pool=None;

    @classmethod
    def initialize(cls,**kwargs):
        #Database.__connection_pool=pool.SimpleConnectionPool(1,1,**kwargs); # double underscore before connectionpool (property) makes it private as python does not use private keyword as in other languages
        Database.connection_pool=psycopg2.connect(**kwargs); # double underscore before connectionpool (property) makes it private as python does not use private keyword as in other languages

    @classmethod
    def get_connection(cls):
        #return cls.__connectionpool.getconn();
        return cls.connection_pool;


class cursorfromconnectionpool:
    
    def __init__(self):
        self.connection = None
        #self.connection = None
    
    def __enter__(self):
        self.connection=Database.connection_pool
        
        self.cursor = self.connection.cursor(cursor_factory=psycopg2.extras.DictCursor)
        #self.cursor = self.connection.cursor()
        return self.cursor
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        if exc_val is not None:
            self.connection.rollback();
        else:
            self.cursor.close()
            self.connection.commit()
    
            


