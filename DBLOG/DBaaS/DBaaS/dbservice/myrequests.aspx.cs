using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using DBaaS.classes;
using System.Data;
using System.Collections;


namespace DBaaS.dbservice
{

    public partial class myrequests : System.Web.UI.Page
    {
        Returnpgdatatable rj;
        MiscFunctions mf;
        Hashtable hs;
        String timezoneoffset;
        public void populateRequests()
        {
            

            timezoneoffset = hs["timezoneoffset"].ToString();
            DataTable dt;
            rj = new Returnpgdatatable();
            string query = "select r.id \"RequestID\",  r.datesubmitted+'" + timezoneoffset + "' \"Request Submit Date\", sl.name \"Server Name\", d.databasename \"Database Name\", datetimetoexecute+'" + timezoneoffset + "' \"Scheduled Time\", itopid \"iTop\", status \"Status\", options->'authstat' as \"Approval\", lastupdated+'" + timezoneoffset + "' \"Last Updated\"  from dbs.requests r  join dbs.backup_requests br     on br.requestid = r.id join rtm.serverslist sl     on sl.serverid = br.serverid join rtm.databases d    on d.databaseid = br.databaseid join rtm.users usr     on usr.userid = r.userid where r.requestclass='backup' and usr.username = '" + Session["LdapUser"].ToString() + "' order by r.datesubmitted desc";
            dt=rj.GetDt(query, Session["LdapUser"].ToString());
            
            grdBackupRequests.DataSource = dt;
            grdBackupRequests.DataBind();

            
         }

        protected void populateLogs(object sender, GridViewRowEventArgs e)
        {
            mf = new MiscFunctions();

            timezoneoffset = hs["timezoneoffset"].ToString();
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                DataTable dt;
                rj = new Returnpgdatatable();
                string requestid = grdBackupRequests.DataKeys[e.Row.RowIndex].Value.ToString();
                string query = string.Format("select comments \"Log\", datetimeadded+'" + timezoneoffset + "'  \"Date\" from dbs.request_log where requestid={0} order by datetimeadded desc", requestid);
                dt = rj.GetDt(query, Session["LdapUser"].ToString());
                GridView gvLogs = e.Row.FindControl("grdRequestLogs") as GridView;
                gvLogs.DataSource = dt;
                gvLogs.DataBind();
            }
        }
        protected void Page_Load(object sender, EventArgs e)
        {
            ExceptionSave es;
            mf = new MiscFunctions();

            String user;
            user = Session["LdapUser"].ToString();
            hs = mf.GetUserTimeZone(user);

            es = new ExceptionSave();
            try
            {
                if ((bool)Session["LdapAuthed"] == true)
                {

                    populateRequests();
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
    }
}