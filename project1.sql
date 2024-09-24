CREATE DATABASE library_db;

DROP TABLE IF EXISTS branch1;
CREATE TABLE branch1
(
            branch_id VARCHAR(10) PRIMARY KEY,
            manager_id VARCHAR(10),
            branch_address VARCHAR(30),
            contact_no VARCHAR(15)
);
select * from branch1;

-- Create table "Employee"
DROP TABLE IF EXISTS employees;
CREATE TABLE employees
(
            emp_id VARCHAR(10) PRIMARY KEY,
            emp_name VARCHAR(30),
            position VARCHAR(30),
            salary DECIMAL(10,2),
            branch_id VARCHAR(10),
            FOREIGN KEY (branch_id )references branch1(branch_id);
select * from employees;

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

INSERT INTO return_status(return_id, issued_id, return_date) 
VALUES
('RS101', 'IS101', '2023-06-06'),
('RS102', 'IS105', '2023-06-07'),
('RS103', 'IS103', '2023-08-07'),
('RS104', 'IS106', '2024-05-01'),
('RS105', 'IS107', '2024-05-03'),
('RS106', 'IS108', '2024-05-05'),
('RS107', 'IS109', '2024-05-07'),
('RS108', 'IS110', '2024-05-09'),
('RS109', 'IS111', '2024-05-11'),
('RS110', 'IS112', '2024-05-13'),
('RS111', 'IS113', '2024-05-15'),
('RS112', 'IS114', '2024-05-17'),
('RS113', 'IS115', '2024-05-19'),
('RS114', 'IS116', '2024-05-21'),
('RS115', 'IS117', '2024-05-23'),
('RS116', 'IS118', '2024-05-25'),
('RS117', 'IS119', '2024-05-27'),
('RS118', 'IS120', '2024-05-29');
SELECT * FROM issued_status;


-- Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

insert into books(isbn ,
            book_title ,
            category ,
            rental_price ,
            status ,
            author ,
            publisher )

values('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
select * from books;

delete from books 
where isbn='-59610';

----- update a members address
select * from members;
update members
set member_address= '105 oaks cir'
where member_name= 'John';
 ------ alter the column name in member_name to members_name

alter table members
rename column member_address to members_address;

--Task 3: Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

delete from issued_status
where issued_id='IS121';

select * from issued_status;
--Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.
select issued_emp_id,issued_book_name from issued_status
where issued_emp_id='E101';
--List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.

select issued_member_id ,count(issued_book_name ) as book_count from issued_status
group by 1
having count(issued_book_name)>1
order by 2 asc;

--Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**
  create table tot_book_count_issued as
	select b.isbn,  b.book_title,count(isu.issued_member_id) as count from books b
	join issued_status isu on b.isbn=isu.issued_book_isbn
	group by 1,2
select * from tot_book_count_issued;
--ask 7. Retrieve All Books in a Specific Category:

SELECT * FROM books
WHERE category = 'Classic';

--Task 8: Find Total Rental Income by Category:
select sum(rental_price) as tot_price, category,count(*) from issued_status ist
	join books b on ist.issued_book_isbn= b.isbn
group by 2
order by 1 desc;

--task 9 List Members Who Registered in the Last 180 Days:
SELECT * FROM members
WHERE reg_date >= current_date -interval'180days';
-- task 10 .List Employees with Their Branch Manager's Name and their branch details:
select e.*,e2.emp_name as manager_name from employees e
	join branch1 b on e.branch_id= b.branch_id
	join employees e2 on b.manager_id=e2.emp_id;


--Task 11. Create a Table of Books with Rental Price Above a Certain Threshold ex:7:
create table books7 as
select * from books
where rental_price >7;
select * from books7;
--Task 12. Task 12: Retrieve the List of Books Not Yet Returned

select * from issued_status i
left join return_status r on i.issued_id= r.issued_id
where return_id is null;

--Task 13: Identify Members with Overdue Books
--Write a query to identify members who have overdue books (assume a 30-day return period). 
--Display the member's_id, member's name, book title, issue date, and days overdue.

select member_id,member_name ,issued_book_name,issued_date,return_date,(current_date-iss.issued_date) as overdue_days  
	from books b --(return date should be null so to filter the books not returned)
join issued_status iss on b.isbn= iss.issued_book_isbn
join members m on iss.issued_member_id= m.member_id
left join return_status re on re.issued_id= iss.issued_id
where return_date is null
and (current_date-iss.issued_date) >30
order by 1;

--Task 15: Branch Performance Report
--Create a query that generates a performance report for each branch, showing the number of books issued, 
--the number of books returned, and the total revenue generated from book rentals.

select br.branch_id,br.manager_id,count(iss.issued_book_name) as tot_issued,count(re.return_id) as tot_reu, sum(b.rental_price)as rev from issued_status iss
--select * from issued_status iss
	join employees e on iss.issued_emp_id=e.emp_id
 join branch1 br on e.branch_id=br.branch_id
 join books b on iss.issued_book_isbn=b.isbn
	left join return_status re on iss.issued_id=re.issued_id
group by 1,2
order by 3,4;

------------2nd approch
CREATE TABLE branch_reports
AS
SELECT 
    b.branch_id,
    b.manager_id,
    COUNT(ist.issued_id) as number_book_issued,
    COUNT(rs.return_id) as number_of_book_return,
    SUM(bk.rental_price) as total_revenue
FROM issued_status as ist
JOIN 
employees as e
ON e.emp_id = ist.issued_emp_id
JOIN
branch1 as b
ON e.branch_id = b.branch_id
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
JOIN 
books as bk
ON ist.issued_book_isbn = bk.isbn
GROUP BY 1, 2;

SELECT * FROM branch_reports;

--Task 17: Find Employees with the Most Book Issues Processed
--Write a query to find the top 3 employees who have processed the most book issues. 
--Display the employee name, number of books processed, and their branch.

select  e.emp_id,e.emp_name,br.*,count(issu.issued_id ) as most_issued from employees e
join branch1 br on e.branch_id=br.branch_id
join issued_status issu on e.emp_id=issu.issued_emp_id

group by 1,2,3
order by 4 desc;


--Task 16: CTAS: Create a Table of Active Members
--Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members 
--who have issued at least one book in the last 6 months.


CREATE TABLE Active_members
as
select * from members
where member_id IN
	(select distinct issued_member_id,issued_date from issued_status
where issued_date >= current_date- interval'6 months');

select * from Active_members;
-------------------------------------inserting few rows to issued_status-------------------------------
INSERT INTO issued_status(issued_id, issued_member_id, issued_book_name, issued_date, issued_book_isbn, issued_emp_id)
VALUES
('IS151', 'C118', 'The Catcher in the Rye', CURRENT_DATE - INTERVAL '24 days',  '978-0-553-29698-2', 'E108'),
('IS152', 'C119', 'The Catcher in the Rye', CURRENT_DATE - INTERVAL '13 days',  '978-0-553-29698-2', 'E109'),
('IS153', 'C106', 'Pride and Prejudice', CURRENT_DATE - INTERVAL '7 days',  '978-0-14-143951-8', 'E107'),
('IS154', 'C105', 'The Road', CURRENT_DATE - INTERVAL '32 days',  '978-0-375-50167-0', 'E101');

select * from issued_status;

alter table return_status
add column book_quality varchar(50) default('good');

	update return_status
	set book_quality='damaged'
	where issued_id in('IS112','IS117','IS118');
select * from return_status;








---------------------------------STORE PROCEDURE-------------(refer this for store procedure)------------------------
---------------explaination in youtube (https://www.youtube.com/watch?v=h-s_kQIqndg&t=5154s) time 32.00-------------------
-------------------------------alert-------------------------------------------------------------------





--Task 14: Update Book Status on Return
--Write a query to update the status of books in the books table to "Yes" 
--when they are returned (based on entries in the return_status table).
create or replace procedure update_books(u_return_id varchar(20),U_issued_id varchar(20),u_book_quality varchar(20))
language plpgsql
as
$$
declare
 v_isbn varchar(50);
	v_issued_book_name varchar(80);
begin
  
	select
	issued_book_isbn,
	issued_book_name
	into
	v_isbn,
	v_issued_book_name 
	from issued_status
     where issued_id= u_issued_id;


	insert into return_status(return_id,issued_id,return_date,book_quality)
                 values(u_return_id,u_issued_id,current_date,u_book_quality);

	update books
	set status = 'yes'
	where isbn= v_isbn;
          RAISE NOTICE'Thankyou for returning the book :%',v_issued_book_name;
	
END;

$$


call update_books('RS138','IS135','damaged');
--checkingggggggggggg

select * from return_status;
select * from issued_status
where issued_book_isbn='978-0-307-58837-1';
select* from books
	where isbn='978-0-307-58837-1';
call update_books('RS138','IS135','damaged');
/* test check
in book table book ""978-0-307-58837-1"" ""Sapiens: A Brief History of Humankind"- no
its not there
so consider v are returing those book
create a return id by urself
check for issued id in book table with no status, n then enter inprocedure to check*/
select * from return_status

--Task 19: Stored Procedure Objective: Create a stored procedure to manage the status of books in a library system. 
--Description: Write a stored procedure that updates the status of a book in the library based on its issuance.
--The procedure should function as follows: The stored procedure should take the book_id as an input parameter.
--The procedure should first check if the book is available (status = 'yes'). If the book is available, 
--it should be issued, and the status in the books table should be updated to 'no'. 
--If the book is not available (status = 'no'), the procedure should return an error message indicating that 
--the book is currently not available.


create or replace procedure issue_book(u_issued_id varchar(10),u_issued_member_id varchar(10),u_issued_book_isbn varchar(10),u_issued_emp_id varchar(10))
language plpgsql
as
$$

declare

v_status varchar(10);

begin
      select status
	into v_status 
	from books
	where isbn= u_issued_book_isbn;
	If v_status='yes' then
insert into issued_status(issued_id,issued_member_id,issued_date,issued_book_isbn,issued_emp_id)
       values(u_issued_id,u_issued_member_id,current_date,u_issued_book_isbn,u_issued_emp_id);
	update books
	set status='no'
	where isbn= u_issued_book_isbn;
	RAISE NOTICE 'Book records added successfully for book isbn : %', u_issued_book_isbn;


    ELSE
        RAISE NOTICE 'Sorry to inform you the book you have requested is unavailable book_isbn: %', u_issued_book_isbn;


     end if;
end;
$$

call issue_status('IS137','C107','978-0-553-29698-2','E103');


select * from books
where isbn='978-0-553-29698-2'
SELECT * FROM books;
-- "978-0-553-29698-2" -- yes
-- "978-0-375-41398-8" -- no
SELECT * FROM issued_status;

CALL issue_book('IS155', 'C108', '978-0-553-29698-2', 'E104');
CALL issue_book('IS156', 'C108', '978-0-375-41398-8', 'E104');

SELECT * FROM books
WHERE isbn = '978-0-375-41398-8'






   







