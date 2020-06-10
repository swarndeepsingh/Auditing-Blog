ALTER TABLE [DBLog].[Users_Roles]
    ADD CONSTRAINT [CK_UserName_TOO_SHORT] CHECK (len([UserName])>(4));

