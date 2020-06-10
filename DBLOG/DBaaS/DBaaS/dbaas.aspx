<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="dbaas.aspx.cs" Inherits="DBaaS.dbaas" MasterPageFile="~/DBLOG.Master"  %>



<asp:Content ID="hc" runat="server" ContentPlaceHolderID="ParentContent">
</asp:Content>



<asp:Content ID="selectioncont" runat="server" ContentPlaceHolderID="ChildContent">
    <style type="text/css">
        .tablestyle
        {
            vertical-align:top;
            
            
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
            vertical-align:middle;
        }

        .textbox{
            font-size:15px;
            font-family:Verdana;
            color:black;
            border-color:gainsboro;
            

        }


        .center-div
            {
              position: relative;
              margin: auto;
              top: 0;
              right: 0;
              bottom: 0;
              left: 0;
              width: auto;
              height: 100px;
              border-radius: 0px;
              vertical-align:top;
             
              font-family: Verdana, Geneva, Tahoma, sans-serif;
              

            }
        .textcolor{
            font-family:Verdana;
            font-style:initial;
            color: orange;
            font-size:larger
            }
        .wizard
        {
            width:300px;
            vertical-align:top;
            height:50px;
            color:orange;
        }

    </style>
    <div id="divselection" runat="server" class="center-div" >
        <asp:Table runat="server" CssClass="tablestyle" HorizontalAlign="Center"  >
            <asp:TableHeaderRow>
                <asp:TableCell ColumnSpan="2" HorizontalAlign="Center" >
                    <asp:Label ID="Label1" runat="server" Text="Database as a Service" CssClass="label" ></asp:Label>
                </asp:TableCell>
            </asp:TableHeaderRow>
        
                <asp:TableRow>
                    <asp:TableCell VerticalAlign="Top">
        
                        <asp:Wizard ID="Wizard1" runat="server" ActiveStepIndex="0" CssClass="wizard" width="600"  >
                            
                            <WizardSteps>
                                <asp:WizardStep ID="wizRDBMS" runat="server" Title="1. Select RDBMS" StepType="Start" >
                                    <asp:RadioButtonList ID="rdRDBMS" runat="server">                    
                                        <asp:ListItem Text="Postgres"></asp:ListItem>
                                        <asp:ListItem Text="My SQL"></asp:ListItem>
                                        <asp:ListItem Text="SQL Server"></asp:ListItem>
                                        <asp:ListItem Text="Oracle"></asp:ListItem>
                                    </asp:RadioButtonList>
                                </asp:WizardStep>
                                <asp:WizardStep ID="wizDatacenter" runat="server" Title="Datacenter">
                                    <asp:RadioButtonList ID="rdDatacenter" runat="server">                    
                                        <asp:ListItem Text="Postgres"></asp:ListItem>
                                        <asp:ListItem Text="My SQL"></asp:ListItem>
                                        <asp:ListItem Text="SQL Server"></asp:ListItem>
                                        <asp:ListItem Text="Oracle"></asp:ListItem>
                                    </asp:RadioButtonList>
                                </asp:WizardStep>
                            </WizardSteps>
                        </asp:Wizard>
                        </asp:TableCell>
                </asp:TableRow>
            </asp:Table>
    </div>
</asp:Content>