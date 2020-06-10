using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using DBaaS.classes;


namespace DBaaS
{
    public partial class selection : System.Web.UI.Page
    {
        ExceptionSave es;
        protected void Page_Load(object sender, EventArgs e)
        {
            if((bool)Session["LdapAuthed"] ==true)
            {

            }
            else
            {
                try
                {
                    throw new Exception("Session Expired");
                }
                catch (Exception ex)
                {
                    es = new ExceptionSave();
                    es.SaveExceptionToDB(ex.Message, ex.StackTrace,  this.GetType().Name, Session["LdapUser"].ToString());

                }
                finally
                {
                    es.Dispose();
                }
            }
        }

        public void btnDBaasClick(object senter, EventArgs e)
        {
            Response.Redirect("~/dbservice/Dbaasoptions.aspx");
        }
    }
}