<%@ Page Title="" Language="C#" MasterPageFile="~/DBLOG.Master" AutoEventWireup="true" CodeBehind="registeruser.aspx.cs" Inherits="DBaaS.registeruser" %>

  <asp:Content ID="hc" runat="server" ContentPlaceHolderID="ParentContent">

  </asp:Content>
<asp:Content ID="RegisterUser" runat="server" ContentPlaceHolderID="ChildContent">
    <style type="text/css">
        .tableleftline
        {
            border-left: 0px solid orange
        }
        .pagetitle
        {
            font-size:25px;
            font-family:Verdana;
            color: black;
        }
        .label{
            font-size:20px;
            font-family:Verdana;
            color:black;
        }

        .textbox{
            font-size:15px;
            font-family:Verdana;
            color:black;
            border-color:gainsboro;
            

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
        .textcolor{
            font-family:Verdana;
            font-style:initial;
            color: orange;
        }

         .btn
        {
            background-color:orange;
            border-color:white;
            border-width:0px;

        }

    </style>


        <div  style="width:100%;">
            <asp:Table ID="Table1" runat="server" Height="16px" CssClass="textcolor"  >
                
                
                <asp:TableHeaderRow>
                    <asp:TableCell  HorizontalAlign="center" VerticalAlign="Middle" ColumnSpan="2">
                        <asp:Label ID="lblTitle" CssClass="pagetitle" runat="server" Text="Please provide more information<BR><BR>"></asp:Label>
                        
                    </asp:TableCell>
                    

                </asp:TableHeaderRow>
                <asp:TableRow></asp:TableRow>
                <asp:TableRow >
                    
                    <asp:TableCell  HorizontalAlign="Left" VerticalAlign="Middle">
                       <br /><asp:Label ID="lblUser" CssClass="label" runat="server" Text="User Name" ></asp:Label>
                    </asp:TableCell>

                    </asp:TableRow> 
                    <asp:TableRow> 

                    <asp:TableCell  HorizontalAlign="left" CssClass="tableleftline" > 
                        <asp:TextBox CssClass="textbox" ID="txtUser" ReadOnly="true"  Width="250" placeholder="User" runat="server" BorderWidth="1" BorderStyle="Solid" BackColor="#E4E4E4"></asp:TextBox>
                    
                    </asp:TableCell>
                    
                </asp:TableRow>  
                

                
                <asp:TableRow>
                    <asp:TableCell  HorizontalAlign="Left" VerticalAlign="Middle">
                        <br /><asp:Label ID="lblPwd"  CssClass="label" runat="server" Text="Email"></asp:Label>
                    </asp:TableCell>
              </asp:TableRow> 
                    <asp:TableRow> 

                        <asp:TableCell  HorizontalAlign="left" CssClass="tableleftline"> 
                            <asp:TextBox ID="txtEmail" placeholder="email" CssClass="textbox" Width="250"  runat="server" BorderWidth="1" BorderStyle="Solid"></asp:TextBox>
                            

                    </asp:TableCell>
                </asp:TableRow>

                <asp:TableRow>
                    <asp:TableCell  HorizontalAlign="Left" VerticalAlign="Middle">
                        <br /><asp:Label ID="lblFname"  CssClass="label" runat="server" Text="First Name"></asp:Label>
                    </asp:TableCell>
              </asp:TableRow> 
                    <asp:TableRow> 
                        <asp:TableCell  HorizontalAlign="left" CssClass="tableleftline"> 
                            <asp:TextBox placeholder="first name" ID="txtFname" CssClass="textbox" Width="250"  runat="server" BorderWidth="1" BorderStyle="Solid"></asp:TextBox>
                            
                    </asp:TableCell>
                </asp:TableRow>

                <asp:TableRow>
                    <asp:TableCell  HorizontalAlign="Left" VerticalAlign="Middle">
                       <br /> <asp:Label ID="lblLstname"  CssClass="label" runat="server" Text="Last Name"></asp:Label>
                    </asp:TableCell>
              </asp:TableRow> 
                    <asp:TableRow> 
                        <asp:TableCell  HorizontalAlign="left" CssClass="tableleftline"> 
                            <asp:TextBox placeholder="last name" ID="txtLname" CssClass="textbox"  Width="250"  runat="server" BorderWidth="1"  BorderStyle="Solid"></asp:TextBox>
                            
                    </asp:TableCell>
                </asp:TableRow>

                <asp:TableRow >
                    
                    <asp:TableCell  HorizontalAlign="Left" VerticalAlign="Middle">
                       <br /><asp:Label ID="lblTimeZone" CssClass="label" runat="server" Text="Your Time Zone" ></asp:Label>
                    </asp:TableCell>

                    </asp:TableRow> 
                    <asp:TableRow> 

                    <asp:TableCell  HorizontalAlign="left" CssClass="tableleftline" > 
                        <asp:DropDownList CssClass="textbox" ID="ddlTimeZone" ReadOnly="true"  Width="250" placeholder="User" runat="server" BorderWidth="1" BorderStyle="Solid" BackColor="#E4E4E4"></asp:DropDownList>
                    
                    </asp:TableCell>
                    
                </asp:TableRow>  

                
                <asp:TableRow>


                    <asp:TableCell HorizontalAlign="Left" ColumnSpan="2" >
                        <asp:Button text="Register" runat="server" ID="btnSubmit"  Width="120"  OnClick="btnSubmitOnClick" CssClass="btn" />
                    </asp:TableCell>
                </asp:TableRow>

                <asp:TableRow>
                    <asp:TableCell ColumnSpan="2" ForeColor="Red">
                        <asp:RequiredFieldValidator ID="reqtxtUser" ControlToValidate="txtUser" runat="server" ErrorMessage="Please Enter User Name"></asp:RequiredFieldValidator>    <br />
                        <asp:RequiredFieldValidator ID="txtEmailValidate" ControlToValidate="txtEmail" runat="server" ErrorMessage="Please Enter Email Address"></asp:RequiredFieldValidator> <br />   
                        <asp:RegularExpressionValidator ID="regtxtEmailvalidate" ValidationExpression="^([\w\.\-]+)@([\w\-]+)((\.(\w){2,3})+)$" ControlToValidate="txtEmail" runat="server" ErrorMessage="Please enter a valid email address"></asp:RegularExpressionValidator><br />
                        <asp:RequiredFieldValidator ID="reqtxtFname" ControlToValidate="txtFname" runat="server" ErrorMessage="Please Enter First Name"></asp:RequiredFieldValidator>    <br />
                        <asp:RequiredFieldValidator ID="reqLName" ControlToValidate="txtLname" runat="server" ErrorMessage="Please Enter Last Name"></asp:RequiredFieldValidator>    <br />

                    </asp:TableCell>
                </asp:TableRow>






            </asp:Table>
            
         
        </div>
   
    </asp:content>

