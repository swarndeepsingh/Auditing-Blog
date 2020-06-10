using System;
using System.Web;
using Npgsql;



namespace DBaaS.classes
{
    
    public class pgsql : IHttpModule
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

        public string ConnectToPostsql()
        {
            var connString = "Host=10.5.20.74;Username=dev;Password=102Ebix29;Database=RTM";
            //var conn = new NpgsqlConnection(connString);
            return connString;
        }
    }
}
