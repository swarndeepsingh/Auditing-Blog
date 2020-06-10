<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="test.aspx.cs" Inherits="DBaaS.test" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <asp:Wizard ID="Wizard1" runat="server" ActiveStepIndex="0" Width="95%" DisplaySideBar="False"
    FinishCompleteButtonType="Link" FinishPreviousButtonType="Link" StartNextButtonType="Link"
    StepNextButtonType="Link" StepPreviousButtonType="Link" OnActiveStepChanged="Wizard1_ActiveStepChanged"
    OnNextButtonClick="Wizard1_NextButtonClick" 
    OnFinishButtonClick="Wizard1_FinishButtonClick">
    <HeaderStyle HorizontalAlign="Center" Font-Bold="True" />
    <LayoutTemplate>
        <asp:PlaceHolder ID="navigationPlaceHolder" runat="server"/>
        <asp:PlaceHolder ID="headerPlaceHolder" runat="server" />
        <asp:PlaceHolder ID="sideBarPlaceHolder" runat="server" />
        <asp:PlaceHolder ID="WizardStepPlaceHolder" runat="server" />
    </LayoutTemplate>
    <HeaderTemplate>
        Edit User Wizard
        <br />
        <br />
        <div style="text-align:left">
            <asp:Label ID="lblStepTitle" runat="server" Text="Step Title"></asp:Label>
        </div>
    </HeaderTemplate>          
    <WizardSteps>

    </WizardSteps>
</asp:Wizard>
        </div>
    </form>
</body>
</html>
