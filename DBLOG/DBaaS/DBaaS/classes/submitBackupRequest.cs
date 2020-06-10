using System;
using System.Web;
using Npgsql;
using Newtonsoft.Json.Linq;

namespace DBaaS.classes
{
    public class submitBackupRequest : IHttpModule
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

        public string SubmitBackupRequest(int serverid, string dbid, string dict, string username, DateTime ScheduledDateTime)
        {
            var diction = JObject.Parse(dict);

            var y = DateTime.UtcNow;
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

                    using (var cmd = new NpgsqlCommand("select * from dbs.submitbackup('" + username + "'," + serverid + "," + dbid + ",'submitted', '" + diction + "', '" + ScheduledDateTime + "', '" + y + "')", conn))
                        cmd.ExecuteNonQuery();
                    return "Saved";

                }
                catch (Exception ex)
                {
                    // do nothing
                    es = new classes.ExceptionSave();
                    es.SaveExceptionToDB(ex.Message, ex.StackTrace, this.GetType().Name, username);
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
