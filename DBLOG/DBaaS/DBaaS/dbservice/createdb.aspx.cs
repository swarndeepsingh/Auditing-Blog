using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using DBaaS.classes;
using Npgsql;
using System.Data;


namespace DBaaS.dbservice
{
    public partial class creatredb : System.Web.UI.Page
    {
        ExceptionSave es;
        
        protected void Page_Load(object sender, EventArgs e)
        {
            
            ExceptionSave es;
            es = new ExceptionSave();
            try
            {

                if ((bool)Session["LdapAuthed"] == true)
                {
                    // populate data in Drop Down list
                    if (!IsPostBack)
                    {
                        populateDataCenter();
                    }



                }
                else
                {
                    try
                    {
                        throw new Exception("Session Expired");
                    }
                    catch (Exception ex)
                    {

                        es.SaveExceptionToDB(ex.Message, ex.StackTrace, this.GetType().Name, Session["LdapUser"].ToString());


                    }
                    finally
                    {
                        es.Dispose();
                    }
                }
            }
            catch
            {
                es.SaveExceptionToDB("Session Not Found", "Exception: Session Not Found", this.GetType().Name, Session["LdapUser"].ToString());
                Response.Redirect("~/error.aspx?error=Valid session Not Found");
            }
        }

        public void ddDataCenter_OnSelectionChange(object system, EventArgs e)
        {
            if (IsPostBack)
            {
                populateRDBMS();
            }
        }

        public void populateDataCenter()
        {
            pgsql pg;
            pg = new pgsql();
            es = new ExceptionSave();
            DataTable dt = new DataTable();

            // get connection string
            var connstr = "";
            string query = "select dc.datacenterid as DataCenterID, dc.datacentername as DataCenterName, sr.technology as Technology from rtm.vwdbservers sr join rtm.datacenters dc on dc.datacenterid = sr.datacenterid join rtm.dbaasenabledservers_forsql dba on dba.serverid = sr.serverid";
            connstr = pg.ConnectToPostsql();

            using (var conn = new NpgsqlConnection(connstr))
            {
                
                try
                {
                    conn.Open();
                    using (NpgsqlDataAdapter ad = new NpgsqlDataAdapter(query, conn))
                    {
                        ad.Fill(dt);
                        ddDataCenter.DataSource = dt;
                        ddDataCenter.DataTextField = "DataCenterName";
                        ddDataCenter.DataValueField = "DataCenterID";
                        ddDataCenter.DataBind();

                        ddDataCenter.Items.Insert(0, "Select Datacenter");


                    }
                    //using (var cmd = new NpgsqlCommand(query, conn))
                    //{


                    //    NpgsqlDataReader dr;
                    //    dr = cmd.ExecuteReader();
                    //    if (dr.HasRows)
                    //    {
                    //        while (dr.Read())
                    //        {
                    //            ddDataCenter.DataTextField;
                    //        }

                    //    }
                    //    dr.Close();

                    //}
                        
                }
                catch (Exception ex)
                {
                    // do nothing

                    es = new classes.ExceptionSave();
                    es.SaveExceptionToDB(ex.Message, ex.StackTrace, this.GetType().Name, Session["LdapUser"].ToString());
                    Response.Redirect("~/error.aspx?error=" + ex.Message);
                    
                }
                finally
                {
                    conn.Close();
                    es.Dispose();
                    
                }
            }
        }


        public void populateRDBMS()
        {
            pgsql pg;
            pg = new pgsql();
            es = new ExceptionSave();
            DataTable dt = new DataTable();

            // get connection string
            var connstr = "";
            string query = "select distinct sr.technology as Technology from rtm.vwdbservers sr join rtm.datacenters dc on dc.datacenterid = sr.datacenterid join rtm.dbaasenabledservers_forsql dba on dba.serverid = sr.serverid where dc.datacenterid='"+ddDataCenter.SelectedValue+"'";
            connstr = pg.ConnectToPostsql();

            using (var conn = new NpgsqlConnection(connstr))
            {

                try
                {
                    conn.Open();
                    using (NpgsqlDataAdapter ad = new NpgsqlDataAdapter(query, conn))
                    {
                        ad.Fill(dt);
                        ddRDBMS.DataSource = dt;
                        ddRDBMS.DataTextField = "Technology";
                        ddRDBMS.DataValueField = "Technology";
                        ddRDBMS.DataBind();
                        ddRDBMS.Items.Insert(0, "Select RDBMS");
                        
                    }

                }
                catch (Exception ex)
                {
                    es = new classes.ExceptionSave();
                    es.SaveExceptionToDB(ex.Message, ex.StackTrace, this.GetType().Name, Session["LdapUser"].ToString());
                    Response.Redirect("~/error.aspx?error=" + ex.Message);

                }
                finally
                {
                    conn.Close();
                    es.Dispose();

                }
            }
        }

        public void submit_onlcick(Object system, EventArgs e)
        {
            save_request();
            Response.Redirect("~/dbservice/dbaasoptions.aspx");
        }

        public int get_userid(string username)
        {
            int userid=0;

            classes.ExceptionSave es;

            // create object
            pgsql pg;
            pg = new pgsql();

            NpgsqlDataReader reader;


            // get connection string
            var connstr = "";
            connstr = pg.ConnectToPostsql();

            //initiate connection
            using (var conn = new NpgsqlConnection(connstr))
            {
                try
                {
                    conn.Open();

                    using (var cmd = new NpgsqlCommand("select * from  rtm.users where username='" + username + "'", conn))
                    {

                        reader = cmd.ExecuteReader();
                        while (reader.Read())
                        {
                            userid = (int)reader[0];
                        }
                    }

                }
                catch (Exception ex)
                {
                    // do nothing
                    es = new classes.ExceptionSave();
                    es.SaveExceptionToDB(ex.Message, ex.StackTrace, this.GetType().Name, Session["LdapUser"].ToString());
                }
                finally
                {
                    conn.Close();
                }
            }
            return userid;
        }


        public void  save_request()
        {
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

                    using (var cmd = new NpgsqlCommand("select * from  dbs.submit(" + get_userid((string)Session["LdapUser"]) + ",'" + txtDBname.Text + "','" + ddRDBMS.SelectedValue + "'," + ddDataCenter.SelectedValue + "," + txtDBSize.Text + ",'"  + y + "', '" + y + "')", conn))
                        cmd.ExecuteNonQuery();

                }
                catch (Exception ex)
                {
                    // do nothing
                    es = new classes.ExceptionSave();
                    es.SaveExceptionToDB(ex.Message, ex.StackTrace, this.GetType().Name, Session["LdapUser"].ToString());

                }
                finally
                {
                    conn.Close();
                }



            }
        }
    }
}