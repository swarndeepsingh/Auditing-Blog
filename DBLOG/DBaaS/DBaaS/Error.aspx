<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Error.aspx.cs" Inherits="DBaaS.Error" %>

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
          </style>
    
</head>
<body>
    <form id="form1" runat="server">
        <div class="center-div">
            <asp:Table ID="Table1" runat="server" Height="16px" Width="351px" >
                
                <asp:TableRow >
                    <asp:TableCell RowSpan="2" HorizontalAlign="Left" VerticalAlign="Middle">
                        <asp:Image ID="Image1" runat="server" ImageUrl="~/dblog.png" hight="22" Width="104"  />
                    </asp:TableCell>
                    <asp:TableCell  HorizontalAlign="Left" CssClass="tableleftline"> <asp:Label ID="lblTitle"  Width="120" Text="Error" runat="server" BorderWidth="1" BorderColor="Orange" BorderStyle="Solid" ForeColor="Red"></asp:Label>


                    </asp:TableCell>
                </asp:TableRow>   
                <asp:TableRow>
                    
                    <asp:TableCell HorizontalAlign="Left" CssClass="tableleftline"> <asp:Label ID="lblError" Width="500" runat="server"  BorderWidth="1" BorderColor="Orange" BorderStyle="Solid"></asp:Label>

                    </asp:TableCell>
                </asp:TableRow>
                <asp:TableRow>
                    <asp:TableCell />
                    
                    <asp:TableCell HorizontalAlign="Left" CssClass="tableleftline"> <asp:LinkButton ID="lnkRedirect" Text="Back" Width="500" runat="server"  BorderWidth="1" BorderColor="Orange" BorderStyle="Solid" OnClick="lnkRedirectClick"></asp:LinkButton>

                    </asp:TableCell>
                </asp:TableRow>
                    
                
            </asp:Table>
            
         
        </div>
    </form>
</body>
</html>
