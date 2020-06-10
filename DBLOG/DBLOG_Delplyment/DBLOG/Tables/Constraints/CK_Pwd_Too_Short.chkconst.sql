ALTER TABLE [DBLog].[Users]
    ADD CONSTRAINT [CK_Pwd_Too_Short] CHECK (len([Password])>(8));

