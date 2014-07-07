create schema library;

create table book
(Book_id char(10) NOT NULL,
Title varchar(200) NOT NULL,
PRIMARY KEY(Book_id)
);

--FOREIGN KEY (book_id) references book(Book_id)
create table book_authors
(book_id char(10) NOT NULL,
author_name varchar(50) NOT NULL,
fname varchar(15) DEFAULT NULL,
minit varchar (5) DEFAULT NULL,
lname varchar (15) DEFAULT NULL,
PRIMARY KEY(book_id,author_name)
);

create table library_branch
(branch_id char(2) NOT NULL,
Branch_name varchar(20),
address varchar(50),
PRIMARY KEY(branch_id)
);

create table book_copies
(book_id char(10) NOT NULL,
branch_id char(2) NOT NULL,
no_of_copies INT DEFAULT  '0',
FOREIGN KEY (book_id) references book(book_id),
FOREIGN KEY (branch_id) references library_branch(branch_id),
PRIMARY KEY (book_id,branch_id)
);

create table borrower 
(card_no char(5) NOT NULL,
fname varchar(15),
lname varchar(15),
address varchar(50),
city varchar(15),
state varchar(10),
phone varchar(15),
PRIMARY KEY (card_no)
);

create table book_loans
(loan_id INT NOT NULL AUTO_INCREMENT,
book_id char(10) NOT NULL,
branch_id char(2) NOT NULL,
card_no char(5) NOT NULL,
Date_out DATETIME DEFAULT CURRENT_TIMESTAMP,
Due_date DATETIME DEFAULT CURRENT_TIMESTAMP,
Date_in DATETIME,
PRIMARY KEY(loan_id) 
); 

create trigger set_date
before insert on book_loans
for each row 
set new.due_date = Date_Add(due_date,INTERVAL 14 DAY);

create trigger full_name
before insert on book_authors
for each row
set new.author_name = fname+' '+minit+' '+lname;

LOAD DATA LOCAL INFILE 'C:/Users/Ajay/Desktop/SQL_library_data/library_branch.csv'
INTO TABLE library_branch
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(branch_id, branch_name, address);

-- create a temporary table and then copy the data from here to the
-- required tables
create table book_copies_authors
(book_id char(10) NOT NULL,
author_name varchar(50),
title varchar (50) NOT NULL,
FOREIGN KEY (book_id) references book(book_id),
FOREIGN KEY (branch_id) references library_branch(branch_id),
PRIMARY KEY (book_id,branch_id)
);

--remove foreign key on book_copies_authors
--find foreign key name
show create table book_copies;
--delete foreign key
ALTER TABLE book_copies
  DROP FOREIGN KEY book_copies_ibfk_1;

LOAD DATA LOCAL INFILE 'C:/Users/Ajay/Desktop/SQL_library_data/book_copies_new.csv'
INTO TABLE book_copies
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(book_id, branch_id,no_of_copies);

LOAD DATA LOCAL INFILE 'C:/Users/Ajay/Desktop/SQL_library_data/borrowers.csv'
INTO TABLE borrower
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(card_no, fname,lname,address,city,state,phone);

-- create a temporary table and then copy the data from here to the
-- required tables
create table temp_author
(book_id char(10) NOT NULL,
author_name varchar(200),
title varchar(200) NOT NULL,
PRIMARY KEY (book_id,author_name)
);

LOAD DATA LOCAL INFILE 'C:/Users/Ajay/Desktop/SQL_library_data/books_authors.csv'
INTO TABLE temp_author
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(book_id, author_name,title);

--set all the Foreign key references that haven't already been set
Alter table book_authors 
add constraint book_id_fk foreign key (book_id) references book(book_id);

Alter table book_copies
add constraint book_copies_book_id_fk foreign key (book_id) references book(book_id);

Alter table book_copies
add constraint book_copies_branch_id_fk foreign key (branch_id) references library_branch(branch_id);

Alter table book_loans
add constraint book_loans_book_id_fk foreign key (book_id) references book(book_id);

Alter table book_loans
add constraint book_loans_branch_id_fk foreign key (branch_id) references library_branch(branch_id);

Alter table book_loans
add constraint book_loans_card_no_fk foreign key (card_no) references borrower(card_no);

--add column for available books
ALTER table book_copies
add available_copies INT;

UPDATE book_copies
SET available_copies = no_of_copies;

--doesn't work as intended
CREATE VIEW search_result AS
select book.book_id,title, author_name, fname,minit,lname,book_copies.branch_id,no_of_copies,available_copies from
--doesn't work as intended
( (book NATURAL JOIN book_authors) NATURAL JOIN book_copies);

