# Library Management System using SQL Project 

## Project Overview

**Project Title**: Library Management System  
**Database**: `library_db`

This project demonstrates the implementation of a Library Management System using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying.

![ERD](https://github.com/jsolorzanoc/sql_library_system/blob/d262392a22213d4d0d8af70d714f488f1f8ea5cf/library.jpg)

## Objectives

1. **Set up the Library Management System Database**: Create and populate the database with tables for branches, employees, members, books, issued status, and return status.
2. **CRUD Operations**: Perform Create, Read, Update, and Delete operations on the data.
3. **CTAS (Create Table As Select)**: Utilize CTAS to create new tables based on query results.
4. **Advanced SQL Queries**: Develop complex queries to analyze and retrieve specific data.

## Project Structure

### 1. Database Setup
![ERD](https://github.com/jsolorzanoc/sql_library_system/blob/d262392a22213d4d0d8af70d714f488f1f8ea5cf/diagram.png)

- **Database Creation**: Created a database named `library_db`.
- **Table Creation**: Created tables for branches, employees, members, books, issued status, and return status. Each table includes relevant columns and relationships.

```sql
CREATE DATABASE library_db;

-- Create table "Branch"
DROP TABLE IF EXISTS branch;
CREATE TABLE branch
(
            branch_id VARCHAR(10) PRIMARY KEY,
            manager_id VARCHAR(10),
            branch_address VARCHAR(30),
            contact_no VARCHAR(15)
);


-- Create table "Employee"
DROP TABLE IF EXISTS employees;
CREATE TABLE employees
(
            emp_id VARCHAR(10) PRIMARY KEY,
            emp_name VARCHAR(30),
            position VARCHAR(30),
            salary DECIMAL(10,2),
            branch_id VARCHAR(10),
            FOREIGN KEY (branch_id) REFERENCES  branch(branch_id)
);


-- Create table "Members"
DROP TABLE IF EXISTS members;
CREATE TABLE members
(
            member_id VARCHAR(10) PRIMARY KEY,
            member_name VARCHAR(30),
            member_address VARCHAR(30),
            reg_date DATE
);



-- Create table "Books"
DROP TABLE IF EXISTS books;
CREATE TABLE books
(
            isbn VARCHAR(50) PRIMARY KEY,
            book_title VARCHAR(80),
            category VARCHAR(30),
            rental_price DECIMAL(10,2),
            status VARCHAR(10),
            author VARCHAR(30),
            publisher VARCHAR(30)
);



-- Create table "IssueStatus"
DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status
(
            issued_id VARCHAR(10) PRIMARY KEY,
            issued_member_id VARCHAR(30),
            issued_book_name VARCHAR(80),
            issued_date DATE,
            issued_book_isbn VARCHAR(50),
            issued_emp_id VARCHAR(10),
            FOREIGN KEY (issued_member_id) REFERENCES members(member_id),
            FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id),
            FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn) 
);



-- Create table "ReturnStatus"
DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status
(
            return_id VARCHAR(10) PRIMARY KEY,
            issued_id VARCHAR(30),
            return_book_name VARCHAR(80),
            return_date DATE,
            return_book_isbn VARCHAR(50),
            FOREIGN KEY (return_book_isbn) REFERENCES books(isbn)
);
```

### 2. CRUD Operations

- **Create**: Inserted sample records into the `books` table.
- **Read**: Retrieved and displayed data from various tables.
- **Update**: Updated records in the `employees` table.
- **Delete**: Removed records from the `members` table as needed.

**Task 1. Create a New Book Record**
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

```sql
INSERT INTO books (isbn, book_title, category, rental_price, status, author, publisher)
VALUES
('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT * FROM books;
;
```
**Task 2: Update an Existing Member's Address**

```sql
UPDATE members
SET member_address = '125 Main St'
WHERE member_id = 'C101';
SELECT * FROM members;
```

**Task 3: Delete a Record from the Issued Status Table**
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

```sql
DELETE FROM issued_status
WHERE   issued_id =   'IS121';
```

**Task 4: Retrieve All Books Issued by a Specific Employee**
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
```sql
SELECT * 
FROM issued_status
WHERE issued_emp_id = 'E101';
'
```


**Task 5: List Members Who Have Issued More Than One Book**
-- Objective: Use GROUP BY to find members who have issued more than one book.

```sql
SELECT 
	issued_member_id,
	COUNT(issued_id) AS issued_count
FROM issued_status
GROUP BY issued_member_id
HAVING COUNT(issued_id) > 1
ORDER BY issued_count DESC

```

### 3. CTAS (Create Table As Select)

- **Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

```sql
CREATE TABLE book_count AS 
SELECT 
	issued_book_name,
	COUNT(issued_id) AS issued_book_count
FROM issued_status
GROUP BY issued_book_name
ORDER BY issued_book_count DESC

SELECT * FROM book_count
```


### 4. Data Analysis & Findings

The following SQL queries were used to address specific questions:

Task 7. **Retrieve All Books in a Specific Category**:

```sql
SELECT  *
FROM books 
WHERE category = 'Horror'
```

8. **Task 8: Find Total Rental Income by Category**:

```sql
SELECT 
	category,
	SUM(rental_price) AS total_rental_price
FROM books b 
JOIN issued_status i 
ON b.isbn = i.issued_book_isbn
GROUP BY category
ORDER BY total_rental_price DESC 
```

9. **List Members Who Registered in the Last 180 Days**:
```sql
SELECT
  member_id,
  member_name
FROM members
WHERE CURRENT_DATE - reg_date <= 180
```

10. **List Employees with Their Branch Manager's Name and their branch details**:

```sql
SELECT
    e.emp_name AS employee_name,
    m.emp_name AS manager_name,
	b.branch_id,
	b.branch_address
FROM employees e 
LEFT JOIN branch b ON e.branch_id = b.branch_id
LEFT JOIN employees m ON b.manager_id = m.emp_id
```

Task 11. **Create a Table of Books with Rental Price Above a Certain Threshold**:
```sql
CREATE TABLE book_over_5 AS
SELECT
	isbn,
	book_title,
	rental_price
FROM books 
WHERE rental_price > 5
ORDER BY rental_price DESC

SELECT * FROM book_over_5
```

Task 12: **Retrieve the List of Books Not Yet Returned**
```sql
SELECT 
	i.issued_id,
	i.issued_book_name,
	issued_date
FROM issued_status i
LEFT JOIN return_status r ON i.issued_id = r.issued_id
WHERE return_date IS NULL
```

## Advanced SQL Operations

**Task 13: Identify Members with Overdue Books**  
Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.

```sql
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
```


**Task 14: Branch Performance Report**  
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

```sql
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
```

**Task 15: CTAS: Create a Table of Active Members**  
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.

```sql

SELECT
	member_id,
	member_name
FROM members 
WHERE member_id IN (SELECT DISTINCT issued_member_id
				FROM issued_status
				WHERE issued_date >= CURRENT_DATE - INTERVAL '2 month')

```


**Task 16: Find Employees with the Most Book Issues Processed**  
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

```sql
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
```

## Reports

- **Database Schema**: Detailed table structures and relationships.
- **Data Analysis**: Insights into book categories, employee salaries, member registration trends, and issued books.
- **Summary Reports**: Aggregated data on high-demand books and employee performance.

## Conclusion
f
This project demonstrates the application of SQL skills in creating and managing a library management system. It includes database setup, data manipulation, and advanced querying, providing a solid foundation for data management and analysis.


