using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using DBaaS.classes;

namespace DBaaS
{
    public partial class dbaasoptions : System.Web.UI.Page
    {
        

        protected void Page_Load(object sender, EventArgs e)
        {
            ExceptionSave es;
            es = new ExceptionSave();
            try
            {
                if ((bool)Session["LdapAuthed"] == true)
                {
                    Session["Redirect"] = "optionpage";
                }
                else
                {
                    try
                    {
                        Session["Redirect"] = "LoginPage";
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
                //es.SaveExceptionToDB("Session Not Found", "Exception: Session Not Found", this.GetType().Name, Session["LdapUser"].ToString());
                Response.Redirect("~/error.aspx?error=Valid session Not Found");
            }
        }

        public void btnMyRequests_OnClick(object sender, EventArgs e)
        {
            Response.Redirect("~/dbservice/myrequests.aspx");
            //rj = new returnpgdatatable();
            //string query = "select r.id, r.requestclass, r.datesubmitted, sl.name servername, d.databasename, datetimetoexecute, itopid, status, options->'authstat' as approval, lastupdated  from dbs.requests r  join dbs.backup_requests br     on br.requestid = r.id join rtm.serverslist sl     on sl.serverid = br.serverid join rtm.databases d    on d.databaseid = br.databaseid join rtm.users usr     on usr.userid = r.userid where r.requestclass='backup' usr.username = '" + Session["LdapUser"].ToString() +"'";
            //rj.getdt(query, Session["LdapUser"].ToString());
        }

        public void btnSubmitBackup(object sender, EventArgs e)
        {
            Response.Redirect("~/dbservice/backupRequest.aspx");
        }

        public void btnNewDB_OnClick(object sender, EventArgs e)
        {
            Response.Redirect("~/dbservice/createdb.aspx");
        }
    }
}