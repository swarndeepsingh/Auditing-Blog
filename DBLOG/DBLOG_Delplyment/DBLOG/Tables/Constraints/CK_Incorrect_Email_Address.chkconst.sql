ALTER TABLE [DBLog].[Users]
    ADD CONSTRAINT [CK_Incorrect_Email_Address] CHECK (charindex('@',[UsersEmailAddress])>(2));

