using System;
using System.Web;
using Npgsql;
using System.Data;
using System.Collections;

namespace DBaaS.classes
{
    public class MiscFunctions : IHttpModule
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

        public Hashtable GetUserTimeZone(string username)
        {
            // create object
            pgsql pg;
            pg = new pgsql();

            // get connection string
            var connstr = "";
            connstr = pg.ConnectToPostsql();

            //initiate connection
            using (var conn = new NpgsqlConnection(connstr))
            {
                Hashtable data;
                data = new Hashtable();
                var dt = new DataTable();
                NpgsqlDataReader dr;
                try
                {
                    //NpgsqlDataReader result;
                    conn.Open();

                    using (var cmd = new NpgsqlCommand("select timezoneoffset, timezone, roleid, active from rtm.users where username='" + username + "'", conn))
                    {
                        //result=cmd.ExecuteReader();
                        dr = cmd.ExecuteReader();
                        if(dr.HasRows)
                        {
                            while (dr.Read())
                            {
                                data.Add("timezoneoffset", dr.GetValue(0).ToString());
                                data.Add("timezone", dr.GetValue(1).ToString());
                                data.Add("roleid", dr.GetValue(2).ToString());
                                data.Add("active", dr.GetValue(3).ToString());
                            }

                            //data=dr.GetValue(0).ToString();
                            TimeSpan ts = TimeSpan.Parse(data["timezoneoffset"].ToString());
                            data.Add("timezoneoffsetminutes", ts.TotalMinutes);
                        }
                        
                    }
                    
                    return data;

                }
                catch (Exception ex)
                {
                    Hashtable dataerror;
                    dataerror = new Hashtable() { ["Error"] = ex.Message };
                    
                    return dataerror;
                    // do nothing
                    //return ex.Message;
                }
                finally
                {
                    conn.Close();
                }



            }
            
        }
    }
}
