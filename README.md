# Library Management System using SQL

## Project Overview

**Project Title**: Library Management System  
**Level**: Intermediate  
**Database**: `library_db_p2`

This project demonstrates the implementation of a Library Management System using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying.

## Objectives

1. **Set up the Library Management System Database**: Create and populate the database with tables for branches, employees, members, books, issued status, and return status.
2. **CRUD Operations**: Perform Create, Read, Update, and Delete operations on the data.
3. **CTAS (Create Table As Select)**: Utilize CTAS to create new tables based on query results.
4. **Advanced SQL Queries**: Develop complex queries to analyze and retrieve specific data using Joins, Aggregations, Window Functions, CTE, CTAS and Procedures.

## Project Structure

### 1. Database Setup

- **Database Creation**: Created a database named `library_db_p2`.
- **Table Creation**: Created tables for branches, employees, members, books, issued status, and return status. Each table includes relevant columns and relationships.

```sql
DROP DATABASE IF EXISTS LIBRARY_DB_P2
CREATE DATABASE LIBRARY_DB_P2;

-- Create tables
-- BRANCH TABLE
DROP TABLE IF EXISTS BRANCH;
CREATE TABLE BRANCH(
BRANCH_ID VARCHAR(10) PRIMARY KEY,
MANAGER_ID	VARCHAR(10),
BRANCH_ADDRESS VARCHAR(30),
CONTACT_NO VARCHAR(10)
CHECK (LENGTH(CONTACT_NO)=10 AND CONTACT_NO NOT LIKE '%^[0-9]%')
);

-- EMPLOYEES TABLE
DROP TABLE IF EXISTS EMPLOYEES;
CREATE TABLE EMPLOYEES(
EMP_ID VARCHAR(10) PRIMARY KEY,
EMP_NAME VARCHAR(30),
POSITION VARCHAR(30),
SALARY DECIMAL(10,2),
BRANCH_ID VARCHAR(10),
FOREIGN KEY (BRANCH_ID) REFERENCES BRANCH(BRANCH_ID)
);

-- MEMBERS TABLE
DROP TABLE IF EXISTS MEMBERS;
CREATE TABLE MEMBERS(
MEMBER_ID VARCHAR(10) PRIMARY KEY,
MEMBER_NAME VARCHAR(30),
MEMBER_ADDRESS VARCHAR(30),
REG_DATE DATE
);

-- BOOKS TABLE
DROP TABLE IF EXISTS BOOKS;
CREATE TABLE BOOKS(
BOOK_ID VARCHAR(50) PRIMARY KEY,
BOOK_TITLE VARCHAR(80),
CATEGORY VARCHAR(30),
RENTAL_PRICE DECIMAL(10,2),
STATUS VARCHAR(10),
AUTHOR VARCHAR(30),
PUBLISHER VARCHAR(30)
);

-- ISSUE_STATUS TABLE
DROP TABLE IF EXISTS ISSUE_STATUS;
CREATE TABLE ISSUE_STATUS(
ISSUED_ID VARCHAR(10) PRIMARY KEY,
ISSUED_MEMBER_ID VARCHAR(30),
ISSUED_BOOK_NAME VARCHAR(50),
ISSUED_DATE DATE,
ISSUED_BOOK_BOOKID VARCHAR(50),
ISSUED_EMP_ID VARCHAR(10),
FOREIGN KEY (ISSUED_MEMBER_ID) REFERENCES MEMBERS(MEMBER_ID),
FOREIGN KEY (ISSUED_BOOK_BOOKID) REFERENCES BOOKS(BOOK_ID),
FOREIGN KEY (ISSUED_EMP_ID) REFERENCES EMPLOYEES(EMP_ID)
);

-- RETURN_STATUS TABLE
DROP TABLE IF EXISTS RETURN_STATUS;
CREATE TABLE RETURN_STATUS(
RETURN_ID VARCHAR(10) PRIMARY KEY,
ISSUED_ID VARCHAR(30),
RETURN_BOOK_NAME VARCHAR(80),
RETURN_DATE DATE,
RETURN_BOOK_BOOKID VARCHAR(50),
FOREIGN KEY (ISSUED_ID) REFERENCES ISSUE_STATUS(ISSUED_ID),
FOREIGN KEY (RETURN_BOOK_BOOKID) REFERENCES BOOKS(BOOK_ID)
);
```

### 2. CRUD Operations

- **Create**: Inserted sample records into the `books` table.
- **Read**: Retrieved and displayed data from various tables.
- **Update**: Updated records in the `employees` table.
- **Delete**: Removed records from the `members` table as needed.

**Task 1. Create a New Book Record**
--**"978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"**
```
sql
INSERT INTO BOOKS VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT * FROM BOOKS;
```

**Task 2: Update an Existing Member's Address**
```
sql
SELECT * FROM MEMBERS;
UPDATE MEMBERS SET MEMBER_ADDRESS='999 Oak St'
WHERE MEMBER_ID='C103';
SELECT * FROM MEMBERS;
```

**Task 3: Delete a Record from the Issued Status Table: Objective: Delete the record with issued_id = 'IS121' from the issued_status table.**
```
sql
SELECT * FROM ISSUE_STATUS;

DELETE FROM ISSUE_STATUS WHERE ISSUED_ID='IS121';
SELECT * FROM ISSUE_STATUS WHERE ISSUED_ID='IS121';
```

**Task 4: Retrieve All Books Issued by a Specific Employee: Objective: Select all books issued by the employee with emp_id = 'E101'.**
```
sql
SELECT * FROM ISSUE_STATUS WHERE ISSUED_EMP_ID='E101';
```

**Task 5: List Members Who Have Issued More Than One Book : Objective: Use GROUP BY to find members who have issued more than one book.**
```
sql
SELECT ISSUED_EMP_ID, COUNT(*) FROM ISSUE_STATUS 
GROUP BY ISSUED_EMP_ID
HAVING COUNT(*)>1;
```

### 3. CTAS (Create Table As Select)

- **Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total issued_cnt**

```sql
CREATE TABLE BOOK_ISSUE_COUNT AS(
SELECT B.BOOK_ID, B.BOOK_TITLE, COUNT(I.ISSUED_ID) FROM
BOOKS B JOIN ISSUE_STATUS I ON
B.BOOK_ID=I.ISSUED_BOOK_BOOKID
GROUP BY B.BOOK_ID, B.BOOK_TITLE);

SELECT * FROM BOOK_ISSUE_COUNT;
```

**Data Analysis & Findings**

**BASIC SQL QUERIES**

**1. Get a list of all branches**
```
sql
SELECT *FROM BRANCH;
```

**2.Retrieve All Books in a Specific Category 'Classic'**
```
sql
SELECT *FROM BOOKS WHERE CATEGORY='Classic';
```

**3. Get all books available in the library, sorted by title**
```
sql
SELECT *FROM BOOKS WHERE STATUS='yes' ORDER BY BOOK_TITLE;
```

**4. Find employees working in a specific branch 'B005'**
```
sql
SELECT *FROM EMPLOYEES WHERE BRANCH_ID='B005';
```

**5. List all books published by publisher 'Penguin Books'**
```
sql
SELECT *FROM BOOKS WHERE PUBLISHER='Penguin Books';
```

**INTERMEDIATE AND COMPLEX SQL QUERIES**

**6. Find Total Rental Income by Category:**
```
sql
SELECT B.CATEGORY, SUM(RENTAL_PRICE) FROM BOOKS B JOIN ISSUE_STATUS I
ON B.BOOK_ID=I.ISSUED_BOOK_BOOKID
GROUP BY B.CATEGORY;
```

**7. Get all books and their issued status.**
```
sql
SELECT B.BOOK_ID, B.BOOK_TITLE, B.AUTHOR, B.PUBLISHER, I.ISSUED_ID, I.ISSUED_DATE 
FROM BOOKS B JOIN ISSUE_STATUS I
ON B.BOOK_ID=I.ISSUED_BOOK_BOOKID;
```

**8. Count the total number of employees in each branch.**
```
sql
SELECT BRANCH_ID, COUNT(EMP_ID) AS TOTAL_EMPLOYEES FROM EMPLOYEES 
GROUP BY BRANCH_ID;
```

**9. Create a simple CTE to get books issued after a certain date:'2024-01-01'**
```
sql
WITH GET_BOOK_ISSUED_ON_DATE AS(
SELECT *FROM ISSUE_STATUS WHERE ISSUED_DATE>'2024-01-01'
)
SELECT *FROM GET_BOOK_ISSUED_ON_DATE;
```

**10. Rank books by their rental price for a category.**
```
sql
SELECT *, RANK() OVER(PARTITION BY CATEGORY ORDER BY RENTAL_PRICE) AS BOOK_RANKS
FROM BOOKS ORDER BY CATEGORY,BOOK_RANKS;
```

**11. List Members Who Registered in the Last 1 Year(365 Days).**
```
sql
SELECT *FROM MEMBERS WHERE REG_DATE > CURRENT_DATE - INTERVAL '365 days';
```

**12. List Employees with Their Branch Manager's Name and their branch details.**
```
sql
SELECT E.EMP_ID, E.EMP_NAME, E.POSITION, E.SALARY, B.*, E2.EMP_NAME AS MANAGER_NAME
FROM EMPLOYEES E JOIN BRANCH B
ON E.BRANCH_ID=B.BRANCH_ID 
JOIN EMPLOYEES E2
ON B.MANAGER_ID=E2.EMP_ID;
```

**13. Create a Table of Books with Rental Price Above a Certain Threshold i.e. 7.00.**
```
sql
CREATE TABLE BOOKS_ABOVE_THRESHOLD AS
SELECT *FROM BOOKS WHERE RENTAL_PRICE>7;

SELECT *FROM BOOKS_ABOVE_THRESHOLD;
```

**14. Retrieve the List of Books Not Yet Returned.**
```
sql
SELECT I.*FROM ISSUE_STATUS I LEFT JOIN RETURN_STATUS R
ON I.ISSUED_ID=R.ISSUED_ID
WHERE R.RETURN_ID IS NULL;
```

**15. Get employee names and the books they’ve issued.**
```
sql
SELECT E.EMP_ID, E.EMP_NAME, I.ISSUED_BOOK_BOOKID AS BOOK_ID, I.ISSUED_BOOK_NAME AS BOOK_NAME
FROM ISSUE_STATUS I JOIN EMPLOYEES E
ON I.ISSUED_EMP_ID=E.EMP_ID;
```

**16. Get the total rental price of books issued by each member.**
```
sql
SELECT I.ISSUED_MEMBER_ID, SUM(B.RENTAL_PRICE) FROM BOOKS B JOIN ISSUE_STATUS I
ON B.BOOK_ID=I.ISSUED_BOOK_BOOKID 
GROUP BY I.ISSUED_MEMBER_ID
ORDER BY I.ISSUED_MEMBER_ID;
```

**17. Use a CTE to find employees who have issued more than 5 books.**
```
sql
WITH BOOK_ISSUED_BY_EMP AS(
SELECT ISSUED_EMP_ID, COUNT(*) AS TOTAL_BOOKS FROM ISSUE_STATUS GROUP BY ISSUED_EMP_ID HAVING COUNT(*)>5
)
SELECT E.EMP_ID, E.EMP_NAME, T.TOTAL_BOOKS FROM BOOK_ISSUED_BY_EMP T JOIN EMPLOYEES E
ON T.ISSUED_EMP_ID=E.EMP_ID;
```

**18. Calculate the running total of salaries in each branch.**
```
sql
SELECT BRANCH_ID, EMP_NAME, SALARY, SUM(SALARY) 
OVER(PARTITION BY BRANCH_ID ORDER BY EMP_NAME) AS TOTAL_RUNNING_SALARY 
FROM EMPLOYEES;
```

**19. Get the most recent book returned and the employee who issued it.**
```
sql
SELECT R.RETURN_BOOK_BOOKID AS BOOKID, R.RETURN_BOOK_NAME AS BOOK_NAME,
I.ISSUED_EMP_ID AS EMP_ID, E.EMP_NAME, R.RETURN_DATE
FROM RETURN_STATUS R JOIN ISSUE_STATUS I
ON R.ISSUED_ID=I.ISSUED_ID JOIN EMPLOYEES E
ON I.ISSUED_EMP_ID=E.EMP_ID
ORDER BY R.RETURN_DATE DESC LIMIT 1;
```

**20. Find the average rental price of books by category with at least 5 books.**
```
sql
SELECT CATEGORY, ROUND(AVG(RENTAL_PRICE),2) AS AVG_RENTAL_PRICE FROM BOOKS
GROUP BY CATEGORY
HAVING COUNT(BOOK_ID)>=5;
```

**21. Use a CTE to get members who haven’t returned all their books.**
```
sql
WITH MEMBERRETURNEDBOOKS AS(
SELECT I.ISSUED_MEMBER_ID, COUNT(I.ISSUED_ID) AS ISSUED_COUNT, COUNT(R.ISSUED_ID) AS RETURNED_COUNT FROM ISSUE_STATUS I LEFT JOIN RETURN_STATUS R
ON I.ISSUED_ID=R.ISSUED_ID
GROUP BY I.ISSUED_MEMBER_ID)

SELECT M2.MEMBER_ID, M2.MEMBER_NAME, M.ISSUED_COUNT, M.RETURNED_COUNT  
FROM MEMBERRETURNEDBOOKS M JOIN MEMBERS M2
ON M.ISSUED_MEMBER_ID=M2.MEMBER_ID
WHERE M.ISSUED_COUNT>M.RETURNED_COUNT;
```

**22. Rank employees by the number of books they’ve issued**
```
sql
SELECT E.EMP_NAME, COUNT(I.ISSUED_ID) AS TOTAL_BOOKS_ISSUED, 
RANK() OVER(ORDER BY COUNT(I.ISSUED_ID) DESC) AS RANK_EMP
FROM ISSUE_STATUS I JOIN EMPLOYEES E
ON I.ISSUED_EMP_ID=E.EMP_ID
GROUP BY E.EMP_NAME
ORDER BY RANK_EMP;
```

**ADVANCED SQL QUERIES**

**23. Identify Members with Overdue Books: Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.**
```
sql
SELECT M.MEMBER_ID, M.MEMBER_NAME, I.ISSUED_BOOK_NAME AS BOOK_TITLE, I.ISSUED_DATE, CURRENT_DATE-I.ISSUED_DATE AS DAYS_OVERDUE
FROM ISSUE_STATUS I LEFT JOIN RETURN_STATUS R
ON I.ISSUED_ID=R.ISSUED_ID JOIN MEMBERS M
ON I.ISSUED_MEMBER_ID=M.MEMBER_ID
WHERE R.ISSUED_ID IS NULL AND (CURRENT_DATE-I.ISSUED_DATE) > 30;
```

**24. Update correct Book Status of each book based on return status : Write a query to update the status of books in the books table to "yes" if book is returned else "no" (based on entries in the return_status table).**
```
sql

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
```

**25. Update Book Status on Return: Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).**
```
sql

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
	**RAISE NOTICE 'ISSUED_ID: % RETURN_ID: % BOOK_NAME: %', BOOK_ISSUE_ID, BOOK_RETURN_ID, BOOK_NAME;
	INSERT INTO RETURN_STATUS VALUES(BOOK_RETURN_ID, BOOK_ISSUE_ID, BOOK_NAME, CURRENT_DATE, ID);
	UPDATE BOOKS SET STATUS='yes' WHERE BOOK_ID=ID;
	RAISE NOTICE 'BOOK ID: % IS RETURNED AND STATUS IS UPDATED', ID;
END $$;

CALL UPDATE_RETURN_STATUS('978-0-553-29698-2');
```

**26. Branch Performance Report: Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.**
```
sql
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
```

**27. CTAS: Create a Table of Active Members: Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.**
```
sql
CREATE TABLE ACTIVE_MEMEBERS AS(
SELECT M.MEMBER_ID, COUNT(I.ISSUED_ID) AS BOOKS_ISSUED FROM ISSUE_STATUS I JOIN MEMBERS M 
ON I.ISSUED_MEMBER_ID=M.MEMBER_ID
WHERE I.ISSUED_DATE > CURRENT_DATE - INTERVAL '60 DAYS'
GROUP BY M.MEMBER_ID
HAVING COUNT(I.ISSUED_ID)>=1
)
SELECT *FROM ACTIVE_MEMEBERS;

--OR
CREATE TABLE ACTIVE_MEMBERS_TABLE AS(
	SELECT *FROM MEMBERS WHERE MEMBER_ID IN(
	SELECT DISTINCT ISSUED_MEMBER_ID FROM ISSUE_STATUS 
	WHERE ISSUED_DATE > CURRENT_DATE - INTERVAL '60 DAYS'
	GROUP BY ISSUED_MEMBER_ID)
)
SELECT *FROM ACTIVE_MEMBERS_TABLE;
```

**28. Find Employees with the Most Book Issues Processed: Write a query to find the top 3 employees who have processed the most book issued. Display the employee name, number of books processed, and their branch.**
```
sql
SELECT E.EMP_NAME, B.BRANCH_ID, COUNT(*) AS NumberOfBooksProcessed  FROM ISSUE_STATUS I JOIN EMPLOYEES E
ON I.ISSUED_EMP_ID=E.EMP_ID
JOIN BRANCH B ON E.BRANCH_ID=B.BRANCH_ID
GROUP BY E.EMP_NAME, B.BRANCH_ID 
ORDER BY COUNT(*) DESC 
LIMIT 3;
```

**29. Stored Procedure Objective: Create a stored procedure to manage the status of books in a library system. 
**Description: Write a stored procedure that updates the status of a book in the library based on its issuance. The procedure should function as follows: The stored procedure should take the book_id as an input parameter. 
**The procedure should first check if the book is available (status = 'yes'). If the book is available, it should be issued, and the status in the books table should be updated to 'no'. If the book is not available (status = 'no'), *the procedure should return an error message indicating that the book is currently not available.**

```
sql
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
```

**30. Create Table As Select (CTAS) Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.
**Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. The table should include: The number of overdue books. 
```
sql**The total fines, with each day's fine calculated at $0.50. The number of books issued by each member. The resulting table should show: Member ID Number of overdue books Total fines.**
CREATE TABLE BOOKS_NOT_RETURNED_BY_MEMBERS AS(
SELECT M.MEMBER_ID, M.MEMBER_NAME, I.ISSUED_BOOK_NAME AS BOOK_TITLE, I.ISSUED_DATE, CURRENT_DATE-I.ISSUED_DATE AS DAYS_OVERDUE
FROM ISSUE_STATUS I LEFT JOIN RETURN_STATUS R
ON I.ISSUED_ID=R.ISSUED_ID JOIN MEMBERS M
ON I.ISSUED_MEMBER_ID=M.MEMBER_ID
WHERE R.ISSUED_ID IS NULL AND (CURRENT_DATE-I.ISSUED_DATE) > 30)

SELECT *, (DAYS_OVERDUE *0.50) AS FINE FROM BOOKS_NOT_RETURNED_BY_MEMBERS;
```

## Reports

- **Database Schema**: Detailed table structures and relationships.
- **Data Analysis**: Insights into book categories, employee salaries, member registration trends, and issued books.
- **Summary Reports**: Aggregated data on high-demand books and employee performance.

## Conclusion

This project demonstrates the application of SQL skills in creating and managing a library management system. It includes database setup, data manipulation, and advanced querying, providing a solid foundation for data management and analysis.

## How to Use

1. **Clone the Repository**: Clone this repository to your local machine.
   ```sh
   git clone https://github.com/najirh/Library-System-Management---P2.git
   ```

2. **Set Up the Database**: Execute the SQL scripts in the `CREATE_DB_TABLE_SQL_QUERY_P2.sql` file to create and populate the database.
3. **Run the Queries**: Use the SQL queries in the `SQL_QUERIES_P2.sql` file to perform the analysis.
4. **Explore and Modify**: Customize the queries as needed to explore different aspects of the data or answer additional questions.

## Contact: Created by Ritika Garg (https://github.com/ritika2810-hash)

This project is part of my achievements to showcasing the SQL skills essential for data analyst roles.
