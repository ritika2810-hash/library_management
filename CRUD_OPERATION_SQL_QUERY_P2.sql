-- Query to update length of ISSUED_BOOK_NAME column from 50 to 60 of table ISSUE_STATUS.
ALTER TABLE ISSUE_STATUS
ALTER COLUMN ISSUED_BOOK_NAME TYPE VARCHAR(60);

--Task 1. Create a New Book Record 
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
INSERT INTO BOOKS VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT * FROM BOOKS;

--Task 2: Update an Existing Member's Address
SELECT * FROM MEMBERS;
UPDATE MEMBERS SET MEMBER_ADDRESS='999 Oak St'
WHERE MEMBER_ID='C103';
SELECT * FROM MEMBERS;

--Task 3: Delete a Record from the Issued Status Table 
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
SELECT * FROM ISSUE_STATUS;

DELETE FROM ISSUE_STATUS WHERE ISSUED_ID='IS121';
SELECT * FROM ISSUE_STATUS WHERE ISSUED_ID='IS121';

--Task 4: Retrieve All Books Issued by a Specific Employee 
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
SELECT * FROM ISSUE_STATUS WHERE ISSUED_EMP_ID='E101';

--Task 5: List Members Who Have Issued More Than One Book 
-- Objective: Use GROUP BY to find members who have issued more than one book.
SELECT ISSUED_EMP_ID, COUNT(*) FROM ISSUE_STATUS 
GROUP BY ISSUED_EMP_ID
HAVING COUNT(*)>1;





