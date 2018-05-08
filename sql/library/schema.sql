SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET default_tablespace = '';
SET default_with_oids = false;

DROP VIEW IF EXISTS CopywideView CASCADE;
DROP VIEW IF EXISTS LoanableView CASCADE;
DROP VIEW IF EXISTS OnshelfView CASCADE;
DROP VIEW IF EXISTS OnloanView CASCADE;
DROP VIEW IF EXISTS OverdueView CASCADE;
DROP VIEW IF EXISTS AdultwideView CASCADE;
DROP VIEW IF EXISTS ChildwideView CASCADE;

DROP TABLE IF EXISTS adult CASCADE;
DROP TABLE IF EXISTS copy CASCADE;
DROP TABLE IF EXISTS item CASCADE;
DROP TABLE IF EXISTS juvenile CASCADE;
DROP TABLE IF EXISTS loan CASCADE;
DROP TABLE IF EXISTS loanhist CASCADE;
DROP TABLE IF EXISTS member CASCADE;
DROP TABLE IF EXISTS reservation CASCADE;
DROP TABLE IF EXISTS title CASCADE;

DROP SEQUENCE IF EXISTS member_seq;
DROP SEQUENCE IF EXISTS title_seq;

CREATE TABLE adult(
	member_no smallint NOT NULL,
	street varchar(15) NOT NULL,
	city varchar(15) NOT NULL,
	state char(2) NOT NULL,
	zip char(10) NOT NULL,
	phone_no char(13) NULL,
	expr_date timestamp NOT NULL
);


CREATE TABLE copy(
	isbn integer NOT NULL,
	copy_no smallint NOT NULL,
	title_no integer NOT NULL,
	on_loan char(1) NOT NULL
);

CREATE TABLE item(
	isbn integer NOT NULL,
	title_no integer NOT NULL,
	translation char(8) NULL,
	cover char(8) NULL,
	loanable char(1) NULL
);

CREATE TABLE juvenile(
	member_no smallint NOT NULL,
	adult_member_no smallint NOT NULL,
	birth_date Timestamp(3) NOT NULL
);

CREATE TABLE loan(
	isbn integer NOT NULL,
	copy_no smallint NOT NULL,
	title_no integer NOT NULL,
	member_no smallint NOT NULL,
	out_date Timestamp(3) NOT NULL,
	due_date Timestamp(3) NOT NULL
);

CREATE TABLE loanhist(
	isbn integer NOT NULL,
	copy_no smallint NOT NULL,
	out_date Timestamp(3) NOT NULL,
	title_no integer NOT NULL,
	member_no smallint NOT NULL,
	due_date Timestamp(3) NULL,
	in_date Timestamp(3) NULL,
	fine_assessed money NULL,
	fine_paid money NULL,
	fine_waived money NULL,
	remarks varchar(255) NULL
);

CREATE SEQUENCE member_seq;
CREATE TABLE member(
	member_no smallint DEFAULT NEXTVAL ('member_seq') NOT NULL,
	lastname varchar(15) NOT NULL,
	firstname varchar(15) NOT NULL,
	middleinitial char(1) NULL,
	photograph Bytea NULL
);

CREATE TABLE reservation(
	isbn integer NOT NULL,
	member_no smallint NOT NULL,
	log_date Timestamp(3) NULL,
	remarks varchar(255) NULL
);

CREATE SEQUENCE title_seq;
CREATE TABLE title(
	title_no integer DEFAULT NEXTVAL ('title_seq') NOT NULL,
	title varchar(63) NOT NULL,
	author varchar(31) NOT NULL,
	synopsis text NULL
); 

CREATE VIEW CopywideView AS
	SELECT 
		copy.isbn,
		copy.copy_no,
		title.title,
		title.author,
		item.translation,
		item.loanable,
		copy.on_loan
	FROM copy JOIN item ON item.isbn = copy.isbn
		JOIN title ON title.title_no = copy.title_no;


CREATE VIEW LoanableView AS
	SELECT * FROM CopywideView WHERE loanable = 'Y';


CREATE VIEW OnshelfView AS
	SELECT * FROM CopywideView WHERE on_loan ='N';

CREATE VIEW OnloanView AS
	SELECT
		loan.isbn,
		loan.copy_no,
		loan.title_no,
		title.title,
		title.author,
		loan.member_no,
		member.lastname,
		member.firstname,
		loan.out_date,
		loan.due_date
	FROM loan JOIN title ON title.title_no = loan.title_no
		JOIN member	ON member.member_no = loan.member_no;

CREATE VIEW OverdueView AS
	SELECT * FROM OnloanView WHERE OnloanView.due_date < NOW();

CREATE VIEW AdultwideView AS
	SELECT
		adult.member_no,
		member.lastname,
		member.firstname,
		member.middleinitial,
		adult.street,
		adult.city,
		adult.state,
		adult.zip,
		adult.phone_no,
		adult.expr_date
	FROM adult JOIN member ON adult.member_no = member.member_no;

CREATE VIEW ChildwideView AS
	SELECT 
		juvenile.member_no,
		member.lastname,
		member.firstname,
		member.middleinitial,
		adult.street,
		adult.city,
		adult.state,
		adult.zip,
		adult.phone_no,
		adult.expr_date
	FROM juvenile JOIN member ON member.member_no = juvenile.member_no
		JOIN adult ON adult.member_no = juvenile.adult_member_no;

ALTER TABLE ONLY adult ADD CONSTRAINT adult_ident PRIMARY KEY (member_no);
ALTER TABLE ONLY copy ADD CONSTRAINT copy_ident PRIMARY KEY (isbn, copy_no);
ALTER TABLE ONLY item ADD CONSTRAINT item_ident PRIMARY KEY (isbn);
ALTER TABLE ONLY juvenile ADD CONSTRAINT juvenile_ident PRIMARY KEY (member_no);
ALTER TABLE ONLY loan ADD CONSTRAINT loan_ident PRIMARY KEY (isbn, copy_no);
ALTER TABLE ONLY loanhist ADD CONSTRAINT loanhist_ident PRIMARY KEY (isbn, copy_no, out_date);
ALTER TABLE ONLY member ADD CONSTRAINT member_ident PRIMARY KEY (member_no);
ALTER TABLE ONLY reservation ADD CONSTRAINT reservation_ident PRIMARY KEY (member_no, isbn);
ALTER TABLE ONLY title ADD CONSTRAINT title_ident PRIMARY KEY (title_no);

CREATE INDEX copy_title_link ON copy (title_no ASC);
CREATE INDEX item_title_link ON item (title_no ASC);
CREATE INDEX loan_title_link ON loan (title_no ASC);
CREATE INDEX reserve_item_link ON reservation (isbn ASC);
CREATE INDEX juvenile_member_link ON juvenile (adult_member_no ASC);
CREATE INDEX loan_member_link ON loan(member_no ASC);
CREATE INDEX loanhist_member_link ON loanhist(member_no ASC);
CREATE INDEX loanhist_title_link ON loanhist(title_no ASC);

ALTER TABLE adult ADD CONSTRAINT adult_member_link FOREIGN KEY(member_no) REFERENCES member(member_no);
ALTER TABLE adult VALIDATE CONSTRAINT adult_member_link;

ALTER TABLE copy ADD CONSTRAINT copy_item_link FOREIGN KEY(isbn) REFERENCES item(isbn);
ALTER TABLE copy VALIDATE CONSTRAINT copy_item_link;

ALTER TABLE copy ADD CONSTRAINT copy_title_link FOREIGN KEY(title_no) REFERENCES title(title_no);
ALTER TABLE copy VALIDATE CONSTRAINT copy_title_link;

ALTER TABLE item ADD CONSTRAINT item_title_link FOREIGN KEY(title_no) REFERENCES title(title_no);
ALTER TABLE item VALIDATE CONSTRAINT item_title_link;

ALTER TABLE juvenile ADD CONSTRAINT juvenile_adult_link FOREIGN KEY(adult_member_no) REFERENCES adult(member_no);
ALTER TABLE juvenile VALIDATE CONSTRAINT juvenile_adult_link;

ALTER TABLE juvenile ADD CONSTRAINT juvenile_member_link FOREIGN KEY(member_no) REFERENCES member(member_no);
ALTER TABLE juvenile VALIDATE CONSTRAINT juvenile_member_link;

ALTER TABLE loan ADD CONSTRAINT loan_copy_link FOREIGN KEY(isbn, copy_no) REFERENCES copy(isbn, copy_no);
ALTER TABLE loan VALIDATE CONSTRAINT loan_copy_link;

ALTER TABLE loan ADD CONSTRAINT loan_member_link FOREIGN KEY(member_no) REFERENCES member(member_no);
ALTER TABLE loan VALIDATE CONSTRAINT loan_member_link;

ALTER TABLE loan ADD CONSTRAINT loan_title_link FOREIGN KEY(title_no) REFERENCES title(title_no);
ALTER TABLE loan VALIDATE CONSTRAINT loan_title_link;

ALTER TABLE loanhist ADD CONSTRAINT loanhist_copy_link FOREIGN KEY(isbn, copy_no) REFERENCES copy(isbn, copy_no);
ALTER TABLE loanhist VALIDATE CONSTRAINT loanhist_copy_link;

ALTER TABLE loanhist ADD CONSTRAINT loanhist_title_link FOREIGN KEY(title_no) REFERENCES title(title_no);
ALTER TABLE loanhist VALIDATE CONSTRAINT loanhist_title_link;

ALTER TABLE reservation ADD CONSTRAINT reservation_item_link FOREIGN KEY(isbn)REFERENCES item(isbn);
ALTER TABLE reservation VALIDATE CONSTRAINT reservation_item_link;

ALTER TABLE reservation ADD CONSTRAINT reservation_member_link FOREIGN KEY(member_no) REFERENCES member(member_no);
ALTER TABLE reservation VALIDATE CONSTRAINT reservation_member_link;

ALTER TABLE adult ADD CONSTRAINT phone_no_rule CHECK  ((phone_no like '(206)[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]'));
ALTER TABLE adult VALIDATE CONSTRAINT phone_no_rule;