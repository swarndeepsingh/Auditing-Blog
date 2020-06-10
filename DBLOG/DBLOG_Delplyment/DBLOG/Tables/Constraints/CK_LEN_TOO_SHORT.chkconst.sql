ALTER TABLE [DBLog].[Users]
    ADD CONSTRAINT [CK_LEN_TOO_SHORT] CHECK (len([UserName])>(4));

