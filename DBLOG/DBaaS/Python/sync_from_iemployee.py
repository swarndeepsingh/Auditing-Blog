from sqldatabase import cursorfromconnection, Database
from sqlconnectionstring import connectionstring
from pgdatabase import cursorfromconnectionpool as pgconnectionpool, Database as pgdatabase
from pgconnectionstring import connectionstring as pgconnectionstring
import json

class sync_from_iemployee():

    def __init__(self, emladdress):
        self.email=emladdress

    # Following function would return manager's email address from iEmployee along with employee's email address
    def return_employee_manager_email(self):
        cs=connectionstring()
        Database.initialize(user=cs.user, password=cs.password, database='ifly', host=cs.iemphost, as_dict=True)
        with cursorfromconnection() as cursor:
            query=("select emp.EMP_Email [EmployeeEmail], manager.EMP_Email [ManagerEmail]  from ifly.dbo.employee emp join ifly.dbo.employee manager 	on emp.iPlan_RepMgr = manager.EMP_ID where emp.emp_email='%s'") %(self.email)
            cursor.execute(query);            
            requests=cursor.fetchall();
            return requests

class sync_to_pg():

	def __init__(self, mgremailaddress,emladdress):
		self.query="select * from rtm.upsert_manager_email('%s','%s');" %( mgremailaddress,emladdress)

    # Following functin will  upsert manager's email address
	def sync_emails(self):
		cs = pgconnectionstring()
		pgdatabase.initialize(user=cs.user, password=cs.password, database=cs.database, host=cs.host) 		
		with pgconnectionpool() as cursor:
			cursor.execute(self.query)
			requests=cursor.fetchall();
			cursor.close()

class main_insert:

    def __init__(self):
        self.query_missing_manager="select usrs.emailaddress emailaddress from rtm.users usrs left outer join rtm.usermanageremail umemail on usrs.userid=umemail.userid where umemail.userid is null"
    # following function will call sync_to_pg class.sync_emails to finally insert data based on missing entries

    def insert(self):
        cs = pgconnectionstring()
        pgdatabase.initialize(user=cs.user, password=cs.password, database=cs.database, host=cs.host) 		
        # Execute query to get all users whose manager email is missing
        with pgconnectionpool() as cursor:
            cursor.execute(self.query_missing_manager)
            requests=cursor.fetchall();
            for rows in requests:
                # For each missing entry missing email address
                for row in sync_from_iemployee(rows['emailaddress']).return_employee_manager_email():
                    # upsert data
                    si=sync_to_pg(row['ManagerEmail'],row['EmployeeEmail'])
                    si.sync_emails()
class main_update:

    def __init__(self):
        self.query_all="select usrs.emailaddress emailaddress from rtm.users usrs"

    def update(self):
        rows_all=None;
        cs = pgconnectionstring()
        pgdatabase.initialize(user=cs.user, password=cs.password, database=cs.database, host=cs.host) 		
        # Execute query to get all users whose manager email is missing
        with pgconnectionpool() as cursor:
            cursor.execute(self.query_all)
            requests=cursor.fetchall();
            rows_all=requests
        for rows in rows_all:
            print(rows)
            # For each email address
            for row in sync_from_iemployee(rows['emailaddress']).return_employee_manager_email():
                # upsert data
                #print(row)
                # si=sync_to_pg(row['ManagerEmail'],row['EmployeeEmail'])
                # si.sync_emails()
                sync_to_pg(row['ManagerEmail'],row['EmployeeEmail']).sync_emails()
"""
cls_ins=main_insert()
cls_upd=main_update()
cls_ins.insert()
cls_upd.update()
"""
