<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="signin.aspx.cs" Inherits="DBaaS.signin" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <style type="text/css">
        .tableleftline
        {
            border-left: 3px solid orange
        }
        .center-div
            {
              position: absolute;
              margin: auto;
              top: 0;
              right: 0;
              bottom: 0;
              left: 0;
              width: 400px;
              height: 100px;
              border-radius: 3px;
              font-family: Verdana, Geneva, Tahoma, sans-serif;
              

            }
        .btn
        {
            background-color:orange;
            border-color:white;
            border-width:0px;

        }

    </style>
</head>
<body >
    
        <form id="form1" runat="server">
    
        <div class="center-div">
            <asp:Table ID="Table1" runat="server" Height="16px" Width="351px" >
                
                <asp:TableRow >
                    <asp:TableCell RowSpan="3" HorizontalAlign="Left" VerticalAlign="Middle">
                        <asp:Image ID="Image1" runat="server" ImageUrl="~/dblog.png" hight="22" Width="104"  />
                    </asp:TableCell>
                    <asp:TableCell  HorizontalAlign="Right" CssClass="tableleftline"> <asp:TextBox ID="txtUser" Height="25" Width="180" placeholder="User" runat="server" BorderWidth="1" BorderColor="Orange" BorderStyle="Solid"></asp:TextBox>

                    </asp:TableCell>
                </asp:TableRow>   
                <asp:TableRow>
                    
                    <asp:TableCell HorizontalAlign="Right" CssClass="tableleftline"> <asp:TextBox ID="txtPwd" Height="25" Width="180" placeholder="Password" runat="server" TextMode="Password" BorderWidth="1" BorderColor="Orange" BorderStyle="Solid"></asp:TextBox>

                    </asp:TableCell>
                </asp:TableRow>
                    
                <asp:TableRow>
                    <asp:TableCell HorizontalAlign="Right" CssClass="tableleftline">
                        <asp:Button text="Submit" runat="server" ID="btnSubmit" Height="35"  Width="180"  OnClick="btnSubmitOnClick" CssClass="btn" />
                    </asp:TableCell>
                </asp:TableRow>
                
            </asp:Table>
            
         
        </div>

            
        </form>

</body>
</html>
