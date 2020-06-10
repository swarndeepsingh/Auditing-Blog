import pymssql
import sys
class sqlrequests:
    def execsql(self, server, script, port):
        
        try:
            connection=pymssql.connect(user='dp_user', password='D0ntAskMeAga1N', database='master', host=server, as_dict=True,login_timeout=30, timeout=30, port=port)
            connection.autocommit(True)
            with connection.cursor() as cursor:
                cursor.execute(script)
                result=cursor.fetchall()
                connection.close()
                # instead of returning direct data, I am returning json data with result in result key and message in message key, this will be useful to read the exception from calling class
                return {'result':result,'message':'nothing'}
        except:
            e="{}".format(sys.exc_info())
            e=e.replace("'","*")
            # as metioned in comment above, folowing will return exception to calling class instead of simply failing
            return {'result':'exception','message':e}
        
        

