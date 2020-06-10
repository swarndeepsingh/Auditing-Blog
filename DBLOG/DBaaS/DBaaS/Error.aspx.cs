using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace DBaaS
{
    public partial class Error : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            lblError.Text = Request.QueryString["Error"];
            
        }

        public void lnkRedirectClick(object senter, EventArgs e)
        {
            //Response.Redirect("~/dbservice/Dbaasoptions.aspx");
            //if (Session["Redirect"].ToString() == "LoginPage")
            //{
            Response.Redirect("~/signin.aspx");
            //}
            //else
            //{
            //    Response.Redirect("~/dbservice/Dbaasoptions.aspx");
            //}
        }
    }
}