using System;
using System.Web;
using Npgsql;


namespace DBaaS.classes
{
    public class ExceptionSave : IHttpModule
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

        public void SaveExceptionToDB (string err, string stack, string src, string user)
        {
            var y = DateTimeOffset.Now;

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
                    err = err.Replace("'", "\"");
                    stack = stack.Replace("'", "\"");
                    src = src.Replace("'", "\"");
                    user = user.Replace("'", "\"");

                    using (var cmd = new NpgsqlCommand("select * from rtm.saveexception ('" + user.ToString() + "', '" + err.ToString() + "','" + stack.ToString() + "','" + y + "','" + src.ToString() + "')", conn))
                        cmd.ExecuteNonQuery();
                    
                }
                catch (Exception ex)
                {
                    Console.WriteLine(ex.Message);

                    conn.Close();
                }
                finally
                {
                    conn.Close();
                }



            }
        }
    }
}
