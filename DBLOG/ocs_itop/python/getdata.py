import pymysql
#from connections import connectmysql as connect

class getdata:

    def load_from_db(self,script):
        #with connect() as connection:
        connection=pymysql.connect(host='ocs.ebix.com', user='root', password='root', db='ocswebidc', cursorclass=pymysql.cursors.DictCursor)
        
        with connection.cursor() as cursor:
            cursor.execute(script)
            result = cursor.fetchall()
            connection.close()
            return result

    
