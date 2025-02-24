--CTAS (Create Table As Select)
--Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

CREATE TABLE BOOK_ISSUE_COUNT AS(
SELECT B.BOOK_ID, B.BOOK_TITLE, COUNT(I.ISSUED_ID) FROM
BOOKS B JOIN ISSUE_STATUS I ON
B.BOOK_ID=I.ISSUED_BOOK_BOOKID
GROUP BY B.BOOK_ID, B.BOOK_TITLE);

SELECT * FROM BOOK_ISSUE_COUNT;