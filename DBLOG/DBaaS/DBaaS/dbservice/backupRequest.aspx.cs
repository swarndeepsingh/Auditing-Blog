using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using DBaaS.classes;
using Npgsql;
using System.Data;
using System.Collections;

namespace DBaaS.dbservice
{
    public partial class backupRequest : System.Web.UI.Page
    {
        ExceptionSave es;
        submitBackupRequest sbr;
        MiscFunctions mf;
        Hashtable hs;
        protected void Page_Load(object sender, EventArgs e)
        {
            ExceptionSave es;
            es = new ExceptionSave();
            mf = new MiscFunctions();
            
            try
            {
                if ((bool)Session["LdapAuthed"] == true)
                {
                    // populate data in Drop Down list
                    if (!IsPostBack)
                    {
                        
                        //Do Nothing
                        populateServers();
                        txtDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
                        txtTime.Text = DateTime.Now.ToString("HH\\:mm");
                        //txtFinalTime.Text = DateTime.ParseExact((DateTime.Parse(txtDate.Text) + " " + DateTime.Parse(txtTime.Text)), "MM/dd/yyyy hh:mm:ss tt",System.Globalization.CultureInfo.CurrentUICulture).ToString();
                        //txtFinalTime.Text = "";
                        //Session["LdapUser"].ToString()
                        
                    }
                    hs = mf.GetUserTimeZone(Session["LdapUser"].ToString());
                    LblTimeZone.Text = "Your preferred timezone: " + hs["timezone"].ToString();



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
                        Response.Redirect("~/error.aspx?error=" + ex.Message);
                    }
                    finally
                    {
                        es.Dispose();
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
                es.SaveExceptionToDB("Session Not Found", "Exception: Session Not Found", this.GetType().Name, Session["LdapUser"].ToString());
                Response.Redirect("~/error.aspx?error=Valid session Not Found");
            }
        }

        public DateTime convertDateTimeToUTC()
        {
            DateTime dt;
            dt = DateTime.Parse(txtDate.Text);            
            dt = dt.AddHours(DateTime.Parse(txtTime.Text).Hour);
            dt = dt.AddMinutes(DateTime.Parse(txtTime.Text).Minute);
            dt = dt.AddMinutes(-(double)hs["timezoneoffsetminutes"]);

            
            return dt;

        }

        public void OnCheckByPassSecurity(object sender, EventArgs e)
        {

            if (chkByPassSecurity.Checked==true)
            {
                txtusername.Enabled = txtpassword.Enabled = false;
                
                txtusername.Text = txtpassword.Text = "";

            }

            if (chkByPassSecurity.Checked == false)
            {
                txtusername.Enabled = txtpassword.Enabled = true;

                txtusername.Text = txtpassword.Text = "";

            }
        }
        public void ddServer_OnSelectionChange(object sender, EventArgs e)
        {
            populateDatabases();
            
        }

        public void populateDatabases()
        {
            pgsql pg;
            pg = new pgsql();
            es = new ExceptionSave();
            DataTable dt = new DataTable();

            // get connection string
            var connstr = "";
            string query = "select databaseid, databasename from rtm.databases where cast(serverid as varchar)=substring('" + ddServers.SelectedValue + "' from 1 for position('(' in '" + ddServers.SelectedValue + "')-1)";
            connstr = pg.ConnectToPostsql();

            using (var conn = new NpgsqlConnection(connstr))
            {
                try
                {
                    conn.Open();
                    using (NpgsqlDataAdapter ad = new NpgsqlDataAdapter(query, conn))
                    {
                        ad.Fill(dt);
                        ddDatabases.DataSource = dt;
                        ddDatabases.DataTextField = "databasename";
                        ddDatabases.DataValueField = "databaseid";
                        ddDatabases.DataBind();
                        ddDatabases.Items.Insert(0, "Select Database");

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



        public void populateServers()
        {
            pgsql pg;
            pg = new pgsql();
            es = new ExceptionSave();
            DataTable dt = new DataTable();

            // get connection string
            var connstr = "";
            string query = "select cast(serverid as varchar(10)) || '(' || ipaddress || ')' as serverid, name, ipaddress from rtm.serverslist where active=1 order by name";
            connstr = pg.ConnectToPostsql();

            using (var conn = new NpgsqlConnection(connstr))
            {

                try
                {
                    conn.Open();
                    using (NpgsqlDataAdapter ad = new NpgsqlDataAdapter(query, conn))
                    {
                        ad.Fill(dt);
                        ddServers.DataSource = dt;
                        ddServers.DataTextField = "name";
                        ddServers.DataValueField = "serverid";
                        ddServers.DataBind();

                        ddServers.Items.Insert(0, "Select Servers");


                    }
                    

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

        
        public void onClickSubmit(object sender, EventArgs e)
        {
            DateTime ScheduledDateTime;
            ScheduledDateTime =             convertDateTimeToUTC();
            var sa = new sqlauthtest();
            int auth;
            int start = ddServers.SelectedValue.IndexOf('(') + 1;
            int length = ddServers.SelectedValue.IndexOf(')') -start;
            string hostname = ddServers.SelectedValue.Substring(start, length);
            int hostid = int.Parse(ddServers.SelectedValue.Substring(0, start-1));
            if (chkByPassSecurity.Checked == false)
            {
                auth = sa.getauth(hostname, txtusername.Text, txtpassword.Text, ddDatabases.SelectedItem.Text);
                if (auth == 1)
                {
                    //Either dbowner or server admin
                    //submit request and start process, create itop
                    //string path= txtLocation.Text;
                    //if (path.Equals(null) || path=="")
                    //{
                    //    path = "notapath";
                    //}
                    //string js = "{\"backuppath\":\"" + path + "\"," ;
                    string js = "{";
                    js = js+ "\"authstat\":\"approved\",";
                    js = js + "\"status\":\"submitted\",";
                    js = js + "\"reason\":\"db_owner or sa verified, no approval needed\",";
                    js = js + "\"approval\":{\"Manager\":\"no\",\"SQLTeam\":\"no\"}}";
                    sbr = new submitBackupRequest();
                    sbr.SubmitBackupRequest(hostid, ddDatabases.SelectedValue, js, Session["LdapUser"].ToString(),ScheduledDateTime);
                }
                if (auth == 0)
                {
                    //Neither of above
                    //submit the reqeust but request approval from manager in iTop
                    //string js = "{\"backuppath\":\"" + txtLocation.Text + "\",";
                    string js = "{";
                    js = js + "\"authstat\":\"pending-manager\",";
                    js = js + "\"status\":\"submitted\",";
                    js = js + "\"reason\":\"not authorized, approval needed\",";
                    js = js + "\"approval\":{\"Manager\":\"yes\",\"SQLTeam\":\"no\"}}";
                    sbr = new submitBackupRequest();
                    sbr.SubmitBackupRequest(hostid, ddDatabases.SelectedValue, js, Session["LdapUser"].ToString(), ScheduledDateTime);
                }
                if (auth == 2)
                {
                    // wrong credentials
                    // don't submit and reject it
                    //string js = "{\"backuppath\":\"" + txtLocation.Text + "\",";
                    string js = "{";
                    js = js + "\"authstat\":\"rejected\",";
                    js = js + "\"status\":\"rejected\",";
                    js = js + "\"reason\":\"wrong credentials\",";
                    js = js + "\"approval\":{\"Manager\":\"no\",\"SQLTeam\":\"no\"}}";
                    sbr = new submitBackupRequest();
                    sbr.SubmitBackupRequest(hostid, ddDatabases.SelectedValue, js, Session["LdapUser"].ToString(), ScheduledDateTime);
                }
            }
            else if(chkByPassSecurity.Checked == true)
            {
                auth = 3; // bypassing authentication, requires approval from manager and dba team
                //string js = "\"backuppath\":\"" + txtLocation.Text + "\",";
                string js = "{";
                js = js + "\"authstat\":\"pending-manager-sql\",";
                js = js + "\"status\":\"submitted\",";
                js = js + "\"reason\":\"bypassauth\",";
                js = js + "\"approval\":{\"Manager\":\"yes\",\"SQLTeam\":\"yes\"}}";
                sbr = new submitBackupRequest();
                sbr.SubmitBackupRequest(hostid, ddDatabases.SelectedValue, js, Session["LdapUser"].ToString(), ScheduledDateTime);
            }
            Response.Redirect("~/dbservice/myrequests.aspx");
        }
    }
}