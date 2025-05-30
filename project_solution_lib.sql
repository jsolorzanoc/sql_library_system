-- Project TASKS

-- ### 1. CRUD Operations

-- Task 1. Create a New Book Record
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

INSERT INTO books (isbn, book_title, category, rental_price, status, author, publisher)
VALUES
('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

SELECT * FROM books;

-- Task 2: Update an Existing Member's Address

UPDATE members
SET member_address = '125 Main St'
WHERE member_id = 'C101';
SELECT * FROM members;


-- Task 3: Delete a Record from the Issued Status Table
-- Objective: Delete the record with issued_id = 'IS104' from the issued_status table.


SELECT * FROM issued_status
WHERE issued_id = 'IS121';

DELETE FROM issued_status
WHERE issued_id = 'IS121'

SELECT * FROM issued_status
WHERE issued_id = 'IS121';



-- Task 4: Retrieve All Books Issued by a Specific Employee
-- Objective: Select all books issued by the employee with emp_id = 'E101'.

SELECT * 
FROM issued_status
WHERE issued_emp_id = 'E101';


-- Task 5: List Members Who Have Issued More Than One Book
-- Objective: Use GROUP BY to find members who have issued more than one book.

SELECT 
	issued_member_id,
	COUNT(issued_id) AS issued_count
FROM issued_status
GROUP BY issued_member_id
HAVING COUNT(issued_id) > 1
ORDER BY issued_count DESC



-- ### 2. CTAS (Create Table As Select)

-- Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt
CREATE TABLE book_count AS 
SELECT 
	issued_book_name,
	COUNT(issued_id) AS issued_book_count
FROM issued_status
GROUP BY issued_book_name
ORDER BY issued_book_count DESC

SELECT * FROM book_count


-- ### 4. Data Analysis & Findings

-- Task 7. **Retrieve All Books in a Specific Category:

SELECT  *
FROM books 
WHERE category = 'Horror'


-- Task 8: Find Total Rental Income by Category:

SELECT 
	category,
	SUM(rental_price) AS total_rental_price
FROM books b 
JOIN issued_status i -- We used inner since we need to know only the ones that where issued. 
ON b.isbn = i.issued_book_isbn
GROUP BY category
ORDER BY total_rental_price DESC 

-- Task 9. **List Members Who Registered in the Last 180 Days**:

SELECT
  member_id,
  member_name
FROM members
WHERE CURRENT_DATE - reg_date <= 180

-- Task 10: List Employees with Their Branch Manager's Name and their branch details**:


SELECT
    e.emp_name AS employee_name,
    m.emp_name AS manager_name,
	b.branch_id,
	b.branch_address
FROM employees e 
LEFT JOIN branch b ON e.branch_id = b.branch_id
LEFT JOIN employees m ON b.manager_id = m.emp_id


-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold

CREATE TABLE book_over_5 AS
SELECT
	isbn,
	book_title,
	rental_price
FROM books 
WHERE rental_price > 5
ORDER BY rental_price DESC

SELECT * FROM book_over_5

-- Task 12: Retrieve the List of Books Not Yet Returned

SELECT 
	i.issued_id,
	i.issued_book_name,
	issued_date
FROM issued_status i
LEFT JOIN return_status r ON i.issued_id = r.issued_id
WHERE return_date IS NULL


-- ### Advanced SQL Operations

-- Task 13: Identify Members with Overdue Books
-- Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's name, book title, issue date, and days overdue.

SELECT 
	i.issued_id,
	i.issued_book_name,
	i.issued_date,
	m.member_name,
	 CURRENT_DATE - (i.issued_date + INTERVAL '30 days') AS days_overdue
FROM issued_status i
LEFT JOIN return_status r ON i.issued_id = r.issued_id
LEFT JOIN members m ON i.issued_member_id = m.member_id
WHERE return_date IS NULL AND CURRENT_DATE > (i.issued_date + INTERVAL '30 days')
ORDER BY days_overdue DESC 



-- Task 14: Branch Performance Report
-- Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.



SELECT 
	br.branch_id,
	COUNT(i.issued_id) AS issued_books,
	COUNT(r.return_id) AS returned_books,
	SUM(b.rental_price) AS total_ravenue
FROM issued_status i
JOIN  
	employees e 
ON i.issued_emp_id = e.emp_id
JOIN 
	branch br 
ON e.branch_id = br.branch_id
LEFT JOIN 
	return_status r 
ON i.issued_id = r.issued_id
JOIN 
	books b
ON i.issued_book_isbn = b.isbn

GROUP BY br.branch_id
ORDER BY total_ravenue DESC



-- Task 15: CTAS: Create a Table of Active Members
-- Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.


SELECT
	member_id,
	member_name
FROM members 
WHERE member_id IN (SELECT DISTINCT issued_member_id
				FROM issued_status
				WHERE issued_date >= CURRENT_DATE - INTERVAL '2 month')



-- Task 16: Find Employees with the Most Book Issues Processed
-- Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.


SELECT 
	e.emp_name,
	br.branch_id,
	COUNT(i.issued_id) AS book_count
FROM  issued_status i
JOIN 
	employees e
ON i.issued_emp_id = e.emp_id
JOIN 
	branch br
ON e.branch_id = br.branch_id
GROUP BY emp_id, br.branch_id
ORDER BY book_count DESC
LIMIT 3

