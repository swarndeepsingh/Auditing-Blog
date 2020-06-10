using System;
using System.Web;
using System.Data.SqlClient;
using DBaaS.classes;

namespace DBaaS.classes
{
    public class sqlauthtest : IHttpModule
    {
        /// <summary>
        /// You will need to configure this module in the Web.config file of your
        /// web and register it with IIS before being able to use it. For more information
        /// see the following link: https://go.microsoft.com/?linkid=8101007
        /// </summary>
        #region IHttpModule Members

        public void Dispose()
        {
            //clean-up code here.
        }

        public void Init(HttpApplication context)
        {
            // Below is an example of how you can handle LogRequest event and provide 
            // custom logging implementation for it
            context.LogRequest += new EventHandler(OnLogRequest);
        }

        #endregion

        public void OnLogRequest(Object source, EventArgs e)
        {
            //custom logging logic can go here
        }

        public int getauth(string host, string user, string password, string database)
        {
            ExceptionSave es;
            var connString = "Data Source=" + host + ";Integrated Security=false;UID=" + user + ";PWD=" + password + ";Database=" + database + ";";
            using (var conn = new SqlConnection(connString))
            {
                try
                {
                    conn.Open();
                    using (var cmd = new SqlCommand("declare @i int=0; if (select IS_SRVROLEMEMBER('sysadmin','" + user + "'))=1 begin	set @i= 1 end if (select IS_SRVROLEMEMBER('sysadmin','" + user + "'))=0 begin if (select is_rolemember('db_owner','" + user + "'))=1  	begin set @i=1 end end select @i ", conn))
                    {
                        var result = cmd.ExecuteReader();
                        int returndata = 0;
                        while (result.Read())
                        {
                            returndata=  (int)result.GetValue(0);
                        }

                        return returndata;

                        

                    }
                }
                catch (Exception ex)
                {
                    // do nothing
                    es = new classes.ExceptionSave();
                    es.SaveExceptionToDB(ex.Message, ex.StackTrace, this.GetType().Name,"");
                    return 2;
                }
                finally
                {
                    conn.Close();
                }
            }
                
        }
    }
}
