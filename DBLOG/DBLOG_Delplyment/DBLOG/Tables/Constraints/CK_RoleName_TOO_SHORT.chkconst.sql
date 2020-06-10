ALTER TABLE [DBLog].[Users_Roles]
    ADD CONSTRAINT [CK_RoleName_TOO_SHORT] CHECK (len([RoleName])>(2));

