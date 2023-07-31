Use assignment;

desc orders;
select * from orders;
select year(orderdate) from orders;

/*
				 QUE.1. Write a stored procedure that accepts the month and year as inputs and prints the ordernumber, orderdate and status of the orders placed in that month. 
							Example:  call order_status(2005, 11);

		Delimiter $$
				CREATE DEFINER=`root`@`localhost` PROCEDURE `order_status`(Yr int,Mon int)
				BEGIN
					Declare ordernum int;
					Declare orderdt date;
					Declare orderstatus varchar(20);

							  Select ordernumber,orderdate,status from orders where year(orderdate)=Yr AND month(orderdate)=Mon;

				END
		$$
call assignment.order_status(2003, 07);

*/

call assignment.order_status(2005, 05);


/*
		QUE.2. Write a stored procedure to insert a record into the cancellations table for all cancelled orders.
        
        		a.	Create a table called cancellations with the following fields.
                     id (primary key), customernumber (foreign key - Table customers), ordernumber (foreign key - Table Orders), comments.
                All values except id should be taken from the order table.

              b. Read through the orders table. If an order is cancelled, then put an entry in the cancellations table.
        
	Delimiter $$
				CREATE DEFINER=`root`@`localhost` PROCEDURE `cancelled_orders`()
			BEGIN
			declare cnum, ordnum, finished integer default 0;
				
				declare ord_cur cursor for
				select customernumber, ordernumber from orders where status='cancelled';
				declare exit handler for NOT FOUND set finished = 1;
				
				open ord_cur;    
				
				ordloop:REPEAT
					fetch ord_cur into cnum, ordnum;
					insert into cancellations (customernumber, ordernumber) values(cnum, ordnum);
					
				until finished = 1
				end repeat ordloop;

			END
				$$
*/

create table cancellations (id integer primary key auto_increment, customernumber integer, ordernumber integer,
                                   foreign key(customernumber) references customers(customernumber), foreign key(ordernumber) references orders(ordernumber));
 
 Alter table cancellations add column Comments char(50);
 Desc cancellations;
 
Select * from orders; 
select customernumber,ordernumber,status from orders where status='cancelled';
select * from cancellations;                                              ##### Records inserted into cancellation tb when oredr is cancelled.
   
/*
				QUE.3. a. Write function that takes the customernumber as input and returns the purchase_status based on the following criteria . [table:Payments]
							if the total purchase amount for the customer is < 25000 status = Silver, 
                            amount between 25000 and 50000, status = Gold
							if amount > 50000 Platinum

				Delimiter $$
							CREATE DEFINER=`root`@`localhost` FUNCTION `purchase_status`(custnum int) RETURNS varchar(20) CHARSET utf8mb4
							DETERMINISTIC
							BEGIN
								Declare amt int default 0;
								Declare purchase_status varchar(20);
								
							  Select sum(amount) into amt from payments where customernumber=custnum;
							   
								  If amt < 25000 then 
									   set purchase_status='Silver';
								   elseif amt between 25000 and 50000 then
										 set purchase_status='Gold';
									else
										 set purchase_status='Platinum';
								  End If;

							RETURN purchase_status;
							END
            $$
*/

select assignment.purchase_status(112);
select assignment.purchase_status(103);
select assignment.purchase_status(114);

/*
					QUE.3. b. Write a query that displays customerNumber, customername and purchase_status from customers table.
*/
Select customernumber, customername, purchase_status(customernumber) from customers;

/*
            QUE.4. Replicate the functionality of 'on delete cascade' and 'on update cascade' using triggers on movies and rentals tables.
                       Note: Both tables - movies and rentals - don't have primary or foreign keys. Use only triggers to implement the above.

DELIMITER $$
		CREATE DEFINER=`root`@`localhost` TRIGGER `movies_AFTER_DELETE` AFTER DELETE ON `movies` FOR EACH ROW BEGIN
			  Delete from rentals where movieid not in  (Select distinct id from movies);
		END

		CREATE DEFINER=`root`@`localhost` TRIGGER `movies_AFTER_UPDATE` AFTER UPDATE ON `movies` FOR EACH ROW BEGIN
			  Update rentals set movieid=id where movieid=old.id;
		END

$$

*/

/*
    5. Select the first name of the employee who gets the third highest salary. [table: employee]
*/
select * from employee;
Select * from (select fname,dense_rank() over (order by salary desc) as rank_value,salary from employee) as T1 where rank_value=3;
/*
    6. Assign a rank to each employee  based on their salary. The person having the highest salary has rank 1. [table: employee]
*/
desc employee;
select dense_rank() over(order by salary desc) as rank_value,empid,concat(fname,' ',lname) as name,deptno,salary from employee;

## 7. You are given a table, BST, containing two columns: N and P, where N represents the value of a node in Binary Tree, and P is the parent of N.
-- Write a query to find the node type of Binary Tree ordered by the value of the node. Output one of the following for each node:
-- Root: If node is root node.
-- Leaf: If node is leaf node.
-- Inner: If node is neither root nor leaf node.

-- Sample Output
-- 1 Leaf
-- 2 Inner
-- 3 Leaf
-- 5 Root
-- 6 Leaf
-- 8 Inner
-- 9 Leaf

create table BST
	(
     N int,
     P int
     );
     
INSERT INTO BST (  N,    P )
		 VALUES (  1,    2 ),
                (  3,    2 ),
                (  5,    6 ),
                (  7,    6 ),
                (  2,    4 ),
                (  6,    4 ),
                (  4,   15 ),
                (  8,    9 ),
                ( 10,    9 ),
                ( 12,   13 ),
                ( 14,   13 ),
                (  9,   11 ),
                ( 13,   11 ),
                ( 11,   15 ),
                ( 15, NULL );
                
select n,
       case when p is null then 'Root'
            When n in (select p from BST) then 'Inner'
            when p is not null then 'Leaf' 
            END as abc
		from BST
			order by n;
            
# 7. A median is defined as a number separating the higher half of a data set from the lower half.
--  Query the median of the Northern Latitudes (LAT_N) from STATION and round your answer to  decimal places.

select lat_n, 
       ss.row_num
	from ( select s.lat_n,
	              row_number() over ( order by lat_n ) as row_num
				from station s ) as ss
					where ss.row_num 
						    IN 
					( (select max(mx.row_numbre+1)/2
						from ( select row_number() over ( order by lat_n ) as row_numbre
									from station ) as mx) ,
					  (select max(my.row_numbra+2)/2
						from ( select row_number() over ( order by lat_n ) as row_numbra
									from station ) as my));
-- Another Aproach

SELECT round(AVG(ss.lat_n),4) as median_val
	FROM (SELECT s.lat_n, 
                 @rownum:=@rownum+1 as `row_number`,
				 @total_rows:=@rownum
			FROM station s, (SELECT @rownum:=0) r
				WHERE s.lat_n is NOT NULL
					ORDER BY s.lat_n
		  ) as ss
		WHERE ss.row_number 
			   IN 
		( FLOOR((@total_rows+1)/2), FLOOR((@total_rows+2)/2) );

# 8. Julia conducted a  days of learning SQL contest. 
-- The start date of the contest was March 01, 2016 and the end date was March 15, 2016.
-- Write a query to print total number of unique hackers who made at least  submission each day 
-- (starting on the first day of the contest), and find the hacker_id and name of the hacker who made maximum number of submissions each day. 
-- If more than one such hacker has a maximum number of submissions, print the lowest hacker_id. 
-- The query should print this information for each day of the contest, sorted by the date.

create table hackers
	(
     hacker_id int,
     name varchar(40)
     );

create table submissions
	(
     submission_date date,
     submission_id int,
     hacker_id int,
     score int
     );

INSERT INTO hackers ( hacker_id,       name )
			 Values (     15758,     'Rose' ), 
					(     20703,   'Angela' ),
                    (     36396,    'Frank' ),
                    (     38289,  'Patrick' ),
                    (     44065,     'Lisa' ),
                    (     53473, 'Kimberly' ),
                    (     62529,   'Bonnie' );
                    
# 9. You are given a table, Projects, containing three columns: Task_ID, Start_Date and End_Date.
-- It is guaranteed that the difference between the End_Date and the Start_Date is equal to 1 day for each row in the table.
-- If the End_Date of the tasks are consecutive, then they are part of the same project. 
-- Samantha is interested in finding the total number of different projects completed.
## Write a query to output the start and end dates of projects listed by the number of days it took to complete the project in ascending order. 
-- If there is more than one project that have the same number of completion days, then order by the start date of the project.

create table projects
	(
     task_id int primary key auto_increment,
     start_date date,
     end_date date
     );

Insert into projects ( start_date,   end_date )
			  Values ( 2015-10-01, 2015-10-02 ),
                     ( 2015-10-02, 2015-10-03 ),
                     ( 2015-10-03, 2015-10-04 ),
                     ( 2015-10-04, 2015-10-05 ),
                     ( 2015-10-11, 2015-10-12 ),
                     ( 2015-10-12, 2015-10-13 ),
                     ( 2015-10-15, 2015-10-16 ),
                     ( 2015-10-17, 2015-10-18 ),
                     ( 2015-10-19, 2015-10-20 ),
                     ( 2015-10-21, 2015-10-22 ),
                     ( 2015-10-25, 2015-10-26 ),
                     ( 2015-10-26, 2015-10-27 ),
                     ( 2015-10-27, 2015-10-28 ),
                     ( 2015-10-28, 2015-10-29 ),
                     ( 2015-10-29, 2015-10-30 ),
                     ( 2015-10-30, 2015-10-31 ),
                     ( 2015-11-01, 2015-11-02 ),
                     ( 2015-11-04, 2015-11-05 ),
                     ( 2015-11-07, 2015-11-08 ),
                     ( 2015-11-06, 2015-11-07 ),
                     ( 2015-11-05, 2015-11-06 ),
                     ( 2015-11-11, 2015-11-12 ),
                     ( 2015-11-12, 2015-11-13 ),
                     ( 2015-11-17, 2015-11-18 );
     
