using System;
using System.Web;
using Npgsql;

namespace DBaaS.classes
{
    public class RegisterNewUser : IHttpModule
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

        public string RegisterUser(string uname, string email, string fname, string lname, string timezone, string timezoneoffset)
        {
            if(uname=="" || email=="" || fname=="" || lname=="")
            {
                throw new System.Exception("Information is missing (Email, First Name, or Last Name");
            }
            var y = DateTimeOffset.Now;
            classes.ExceptionSave es;

            // create object
            pgsql pg;
            pg = new pgsql();

            // get connection string
            var connstr = "";
            connstr = pg.ConnectToPostsql();

            //initiate connection
            using (var conn = new NpgsqlConnection(connstr))
            {
                try
                {
                    
                    conn.Open();

                    using (var cmd = new NpgsqlCommand("select * from rtm.registeruser('"+uname+"','" + email + "','"  + fname + "','" + lname  + "','" + timezone + "','" + timezoneoffset + "')", conn))
                    cmd.ExecuteNonQuery();
                    return "Saved";

                }
                catch (Exception ex)
                {
                    // do nothing
                    es = new classes.ExceptionSave();
                    es.SaveExceptionToDB(ex.Message, ex.StackTrace, this.GetType().Name,"");
                    return ex.Message.ToString();
                }
                finally
                {
                    conn.Close();
                }



            }
        }
    }
}
