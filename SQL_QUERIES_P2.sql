-- Data Analysis & Findings

--BASIC SQL QUERIES
-- 1. Get a list of all branches
SELECT * FROM BRANCH;

-- 2. Retrieve All Books in a Specific Category 'Classic'
SELECT * FROM BOOKS WHERE CATEGORY='Classic';

-- 3. Get all books available in the library, sorted by title
SELECT * FROM BOOKS WHERE STATUS='yes' ORDER BY BOOK_TITLE;

-- 4. Find employees working in a specific branch 'B005'
SELECT * FROM EMPLOYEES WHERE BRANCH_ID='B005';

-- 5. List all books published by publisher 'Penguin Books'
SELECT * FROM BOOKS WHERE PUBLISHER='Penguin Books';

--INTERMEDIATE AND COMPLEX SQL QUERIES
-- 6. Find Total Rental Income by Category:
SELECT B.CATEGORY, SUM(RENTAL_PRICE) FROM BOOKS B JOIN ISSUE_STATUS I
ON B.BOOK_ID=I.ISSUED_BOOK_BOOKID
GROUP BY B.CATEGORY;

-- 7. Get all books and their issued status.
SELECT B.BOOK_ID, B.BOOK_TITLE, B.AUTHOR, B.PUBLISHER, I.ISSUED_ID, I.ISSUED_DATE 
FROM BOOKS B JOIN ISSUE_STATUS I
ON B.BOOK_ID=I.ISSUED_BOOK_BOOKID;

-- 8. Count the total number of employees in each branch.
SELECT BRANCH_ID, COUNT(EMP_ID) AS TOTAL_EMPLOYEES FROM EMPLOYEES 
GROUP BY BRANCH_ID;

-- 9. Create a simple CTE to get books issued after a certain date:'2024-01-01'
WITH GET_BOOK_ISSUED_ON_DATE AS(
SELECT * FROM ISSUE_STATUS WHERE ISSUED_DATE>'2024-01-01'
)
SELECT * FROM GET_BOOK_ISSUED_ON_DATE;

-- 10. Rank books by their rental price for a category.
SELECT *, RANK() OVER(PARTITION BY CATEGORY ORDER BY RENTAL_PRICE) AS BOOK_RANKS
FROM BOOKS ORDER BY CATEGORY,BOOK_RANKS;

-- 11. List Members Who Registered in the Last 1 Year(365 Days).
SELECT * FROM MEMBERS WHERE REG_DATE > CURRENT_DATE - INTERVAL '365 days';

-- 12. List Employees with Their Branch Manager's Name and their branch details.
SELECT E.EMP_ID, E.EMP_NAME, E.POSITION, E.SALARY, B.*, E2.EMP_NAME AS MANAGER_NAME
FROM EMPLOYEES E JOIN BRANCH B
ON E.BRANCH_ID=B.BRANCH_ID 
JOIN EMPLOYEES E2
ON B.MANAGER_ID=E2.EMP_ID;

-- 13. Create a Table of Books with Rental Price Above a Certain Threshold i.e. 7.00
CREATE TABLE BOOKS_ABOVE_THRESHOLD AS
SELECT * FROM BOOKS WHERE RENTAL_PRICE>7;

SELECT * FROM BOOKS_ABOVE_THRESHOLD;

-- 14. Retrieve the List of Books Not Yet Returned.
SELECT I.* FROM ISSUE_STATUS I LEFT JOIN RETURN_STATUS R
ON I.ISSUED_ID=R.ISSUED_ID
WHERE R.RETURN_ID IS NULL;

-- 15. Get employee names and the books they’ve issued.
SELECT E.EMP_ID, E.EMP_NAME, I.ISSUED_BOOK_BOOKID AS BOOK_ID, I.ISSUED_BOOK_NAME AS BOOK_NAME
FROM ISSUE_STATUS I JOIN EMPLOYEES E
ON I.ISSUED_EMP_ID=E.EMP_ID;

-- 16. Get the total rental price of books issued by each member.
SELECT I.ISSUED_MEMBER_ID, SUM(B.RENTAL_PRICE) FROM BOOKS B JOIN ISSUE_STATUS I
ON B.BOOK_ID=I.ISSUED_BOOK_BOOKID 
GROUP BY I.ISSUED_MEMBER_ID
ORDER BY I.ISSUED_MEMBER_ID;

-- 17. Use a CTE to find employees who have issued more than 5 books.
WITH BOOK_ISSUED_BY_EMP AS(
SELECT ISSUED_EMP_ID, COUNT(*) AS TOTAL_BOOKS FROM ISSUE_STATUS GROUP BY ISSUED_EMP_ID HAVING COUNT(*)>5
)
SELECT E.EMP_ID, E.EMP_NAME, T.TOTAL_BOOKS FROM BOOK_ISSUED_BY_EMP T JOIN EMPLOYEES E
ON T.ISSUED_EMP_ID=E.EMP_ID;

-- 18. Calculate the running total of salaries in each branch.
SELECT BRANCH_ID, EMP_NAME, SALARY, SUM(SALARY) 
OVER(PARTITION BY BRANCH_ID ORDER BY EMP_NAME) AS TOTAL_RUNNING_SALARY 
FROM EMPLOYEES;

-- 19. Get the most recent book returned and the employee who issued it.
SELECT R.RETURN_BOOK_BOOKID AS BOOKID, R.RETURN_BOOK_NAME AS BOOK_NAME,
I.ISSUED_EMP_ID AS EMP_ID, E.EMP_NAME, R.RETURN_DATE
FROM RETURN_STATUS R JOIN ISSUE_STATUS I
ON R.ISSUED_ID=I.ISSUED_ID JOIN EMPLOYEES E
ON I.ISSUED_EMP_ID=E.EMP_ID
ORDER BY R.RETURN_DATE DESC LIMIT 1;

-- 20. Find the average rental price of books by category with at least 5 books.
SELECT CATEGORY, ROUND(AVG(RENTAL_PRICE),2) AS AVG_RENTAL_PRICE FROM BOOKS
GROUP BY CATEGORY
HAVING COUNT(BOOK_ID)>=5;

--21. Use a CTE to get members who haven’t returned all their books.
WITH MEMBERRETURNEDBOOKS AS(
SELECT I.ISSUED_MEMBER_ID, COUNT(I.ISSUED_ID) AS ISSUED_COUNT, COUNT(R.ISSUED_ID) AS RETURNED_COUNT FROM ISSUE_STATUS I LEFT JOIN RETURN_STATUS R
ON I.ISSUED_ID=R.ISSUED_ID
GROUP BY I.ISSUED_MEMBER_ID)

SELECT M2.MEMBER_ID, M2.MEMBER_NAME, M.ISSUED_COUNT, M.RETURNED_COUNT  
FROM MEMBERRETURNEDBOOKS M JOIN MEMBERS M2
ON M.ISSUED_MEMBER_ID=M2.MEMBER_ID
WHERE M.ISSUED_COUNT>M.RETURNED_COUNT;

-- 22. Rank employees by the number of books they’ve issued
SELECT E.EMP_NAME, COUNT(I.ISSUED_ID) AS TOTAL_BOOKS_ISSUED, 
RANK() OVER(ORDER BY COUNT(I.ISSUED_ID) DESC) AS RANK_EMP
FROM ISSUE_STATUS I JOIN EMPLOYEES E
ON I.ISSUED_EMP_ID=E.EMP_ID
GROUP BY E.EMP_NAME
ORDER BY RANK_EMP;

-- ADVANCED SQL QUERIES
-- 23. Identify Members with Overdue Books
-- Write a query to identify members who have overdue books (assume a 30-day return period). 
--Display the member's_id, member's name, book title, issue date, and days overdue.
SELECT M.MEMBER_ID, M.MEMBER_NAME, I.ISSUED_BOOK_NAME AS BOOK_TITLE, I.ISSUED_DATE, CURRENT_DATE-I.ISSUED_DATE AS DAYS_OVERDUE
FROM ISSUE_STATUS I LEFT JOIN RETURN_STATUS R
ON I.ISSUED_ID=R.ISSUED_ID JOIN MEMBERS M
ON I.ISSUED_MEMBER_ID=M.MEMBER_ID
WHERE R.ISSUED_ID IS NULL AND (CURRENT_DATE-I.ISSUED_DATE) > 30;

-- 24. Update correct Book Status of each book based on return status 
-- Write a query to update the status of books in the books table to "yes" if book is returned else "no"
-- (based on entries in the return_status table).

DO $$
DECLARE
	FETCH_RECORD CURSOR FOR
		SELECT BOOK_ID, BOOK_TITLE FROM BOOKS;
		
	BID VARCHAR(50);
	TITLE VARCHAR(80);
	BOOK_STATUS INT;

BEGIN 
	OPEN FETCH_RECORD;
	LOOP
		FETCH FETCH_RECORD INTO BID, TITLE;
		EXIT WHEN NOT FOUND;
		RAISE NOTICE 'ID: % AND NAME: %', BID, TITLE;
		WITH FIND_BOOK_STATUS AS(
			SELECT COUNT(*) AS CT FROM ISSUE_STATUS I LEFT JOIN RETURN_STATUS R
			ON I.ISSUED_ID=R.ISSUED_ID
			JOIN BOOKS B ON I.ISSUED_BOOK_BOOKID=B.BOOK_ID
			WHERE I.ISSUED_BOOK_BOOKID=BID AND R.ISSUED_ID IS NULL
		)
		SELECT CT INTO BOOK_STATUS FROM FIND_BOOK_STATUS;
		IF BOOK_STATUS=1 THEN
			UPDATE BOOKS SET STATUS='no' WHERE BOOK_ID=BID;
		ELSE
			UPDATE BOOKS SET STATUS='yes' WHERE BOOK_ID=BID;
		END IF;
		
	END LOOP;
	CLOSE FETCH_RECORD;
END $$;

-- 25. Update Book Status on Return
--Write a query to update the status of books in the books table to "Yes" when 
--they are returned (based on entries in the return_status table).

DROP PROCEDURE UPDATE_RETURN_STATUS;

CREATE OR REPLACE PROCEDURE UPDATE_RETURN_STATUS(ID VARCHAR(50))
LANGUAGE PLPGSQL
AS $$
DECLARE
	BOOK_ISSUE_ID VARCHAR(80);
	BOOK_RETURN_ID VARCHAR(10);
	BOOK_NAME VARCHAR(80);
BEGIN
	SELECT ISSUED_ID INTO BOOK_ISSUE_ID FROM ISSUE_STATUS WHERE ISSUED_BOOK_BOOKID=ID;
	SELECT CONCAT(SUBSTRING(MAX(RETURN_ID), 0,3), CAST(SUBSTRING(MAX(RETURN_ID), 3) AS INT)+1) INTO BOOK_RETURN_ID FROM RETURN_STATUS;
	SELECT BOOK_TITLE INTO BOOK_NAME FROM BOOKS WHERE BOOK_ID=ID;
	--RAISE NOTICE 'ISSUED_ID: % RETURN_ID: % BOOK_NAME: %', BOOK_ISSUE_ID, BOOK_RETURN_ID, BOOK_NAME;
	INSERT INTO RETURN_STATUS VALUES(BOOK_RETURN_ID, BOOK_ISSUE_ID, BOOK_NAME, CURRENT_DATE, ID);
	UPDATE BOOKS SET STATUS='yes' WHERE BOOK_ID=ID;
	RAISE NOTICE 'BOOK ID: % IS RETURNED AND STATUS IS UPDATED', ID;
END $$;

CALL UPDATE_RETURN_STATUS('978-0-553-29698-2')

-- 26. Branch Performance Report
-- Create a query that generates a performance report for each branch, showing the number of books issued, 
-- the number of books returned, and the total revenue generated from book rentals.
SELECT E.BRANCH_ID, COUNT(I.ISSUED_ID) AS NUM_BOOKS_ISSUED, 
COUNT(R.RETURN_ID) AS NUM_BOOKS_RETURNED, SUM(B.RENTAL_PRICE) AS TOTAL_REVENUE FROM EMPLOYEES E 
JOIN ISSUE_STATUS I 
	ON E.EMP_ID=I.ISSUED_EMP_ID 
JOIN BOOKS B
	ON B.BOOK_ID=I.ISSUED_BOOK_BOOKID
LEFT JOIN RETURN_STATUS R
	ON I.ISSUED_ID=R.ISSUED_ID 
GROUP BY E.BRANCH_ID 
ORDER BY E.BRANCH_ID;

-- 27. CTAS: Create a Table of Active Members
--Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have 
--issued at least one book in the last 2 months.
CREATE TABLE ACTIVE_MEMEBERS AS(
SELECT M.MEMBER_ID, COUNT(I.ISSUED_ID) AS BOOKS_ISSUED FROM ISSUE_STATUS I JOIN MEMBERS M 
ON I.ISSUED_MEMBER_ID=M.MEMBER_ID
WHERE I.ISSUED_DATE > CURRENT_DATE - INTERVAL '60 DAYS'
GROUP BY M.MEMBER_ID
HAVING COUNT(I.ISSUED_ID)>=1
)
SELECT * FROM ACTIVE_MEMEBERS;

-- OR
CREATE TABLE ACTIVE_MEMBERS_TABLE AS(
	SELECT * FROM MEMBERS WHERE MEMBER_ID IN(
	SELECT DISTINCT ISSUED_MEMBER_ID FROM ISSUE_STATUS 
	WHERE ISSUED_DATE > CURRENT_DATE - INTERVAL '60 DAYS'
	GROUP BY ISSUED_MEMBER_ID)
)
SELECT * FROM ACTIVE_MEMBERS_TABLE;

-- 28. Find Employees with the Most Book Issues Processed
-- Write a query to find the top 3 employees who have processed the most book issued. 
-- Display the employee name, number of books processed, and their branch.
SELECT E.EMP_NAME, B.BRANCH_ID, COUNT(*) AS NumberOfBooksProcessed  FROM ISSUE_STATUS I JOIN EMPLOYEES E
ON I.ISSUED_EMP_ID=E.EMP_ID
JOIN BRANCH B ON E.BRANCH_ID=B.BRANCH_ID
GROUP BY E.EMP_NAME, B.BRANCH_ID 
ORDER BY COUNT(*) DESC 
LIMIT 3;

-- 29. Stored Procedure Objective: Create a stored procedure to manage the status of books in a library system. 
-- Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 
-- The procedure should function as follows: The stored procedure should take the book_id as an input parameter. 
-- The procedure should first check if the book is available (status = 'yes'). If the book is available, it should be issued, 
-- and the status in the books table should be updated to 'no'. If the book is not available (status = 'no'), 
-- the procedure should return an error message indicating that the book is currently not available.


CREATE OR REPLACE PROCEDURE ISSUE_BOOK(BID VARCHAR(50), EMP_ID VARCHAR(10), MEM_ID VARCHAR(10))
LANGUAGE PLPGSQL
AS $$
DECLARE 
	BOOK_STATUS VARCHAR(10);
	BOOK_ISSUED_ID VARCHAR(10);
	BOOK_NAME VARCHAR(80);
BEGIN
	SELECT STATUS INTO BOOK_STATUS FROM BOOKS WHERE BOOK_ID=BID;

	IF BOOK_STATUS='yes' THEN
		RAISE NOTICE 'YES, BOOK ID: % IS AVAILABLE.',BID;
		SELECT CONCAT(SUBSTRING(MAX(ISSUED_ID), 0,3), CAST(SUBSTRING(MAX(ISSUED_ID), 3) AS INT)+1) 
		INTO BOOK_ISSUED_ID FROM ISSUE_STATUS;
		SELECT BOOK_TITLE INTO BOOK_NAME FROM BOOKS WHERE BOOK_ID=BID;
		
		INSERT INTO ISSUE_STATUS VALUES(BOOK_ISSUED_ID, MEM_ID, BOOK_NAME, CURRENT_DATE, BID, EMP_ID);
		UPDATE BOOKS SET STATUS='no' WHERE BOOK_ID=BID;

		RAISE NOTICE 'BOOK ID: % IS ISSUED FOR %', BID, EMP_ID;
	ELSE 
		RAISE NOTICE 'SORRY, % IS NOT AVAILABLE.', BID;
	END IF;	
END $$;	

CALL ISSUE_BOOK('978-0-14-118776-1', 'E105', 'C108');

-- 30. Create Table As Select (CTAS) Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.
-- Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not 
-- returned within 30 days. The table should include: The number of overdue books. 
-- The total fines, with each day's fine calculated at $0.50. The number of books issued by each member. 
-- The resulting table should show: Member ID Number of overdue books Total fines
CREATE TABLE BOOKS_NOT_RETURNED_BY_MEMBERS AS(
SELECT M.MEMBER_ID, M.MEMBER_NAME, I.ISSUED_BOOK_NAME AS BOOK_TITLE, I.ISSUED_DATE, CURRENT_DATE-I.ISSUED_DATE AS DAYS_OVERDUE
FROM ISSUE_STATUS I LEFT JOIN RETURN_STATUS R
ON I.ISSUED_ID=R.ISSUED_ID JOIN MEMBERS M
ON I.ISSUED_MEMBER_ID=M.MEMBER_ID
WHERE R.ISSUED_ID IS NULL AND (CURRENT_DATE-I.ISSUED_DATE) > 30)

SELECT *, (DAYS_OVERDUE * 0.50) AS FINE FROM BOOKS_NOT_RETURNED_BY_MEMBERS;
