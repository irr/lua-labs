how to support mysql transaction?
No milestone
No one is assigned

I want to use transaction in mysql sql.

such as:

START TRANSACTION;
SELECT @A:=SUM(salary) FROM table1 WHERE type=1;
UPDATE table2 SET summary=@A WHERE type=1;
COMMIT;

2 participants
agentzh commented 9 months ago

Just use the whole as a single query and feed it into the "send_query" method. and then call the "read_result" method until no "again" error is returned. if you have troubles, just paste your sample code and the error details.
