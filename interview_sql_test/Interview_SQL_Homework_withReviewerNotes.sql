/*
	_____HOMEWORK_____
	1. 
		A. on DBO.Student, Name the field that should be the Primary Key
		B. Name any Foreign Key on any other table.
	2. Write a query to show the order of students by their Overall Attendance Rate for Acting Classes.
	3. Write a query to show who arrived Latest to an Acting Class, without being late or directly on-time.
	4. Write a query to show any time in an Acting class where a student was present and either of the Time values were not logged.
	5. Write a query to add yourself to the Students Table.
	-- Bonus // DDL --
	6. What normalization steps would you recommend for this DB?
*/

USE tempdb;
/*
DSmith "What are we looking for in these answers?"

1. primarily for filtering out those that dont know sql.
	- bonus points for going above and beyond.

2. can they use Order By effectively, along with seeing how they think. (this can be pulled as an overall, by date, by person etc)
	- Commonly see Group By on these bonus points for using HAVING

3. Prefer they reference DB tables instead of hard coding the value. (class_begin_time vs 8:00Pm)

4. Aiming for proper use of Parenthesis on OR vs AND statements.

5. do they know / can they google search how to insert a value
	- Bonus points if they use a function to identify the studentId ( ie: max(studentId) + 1 ) instead of hard-coding it. (ex: '0011')

6. 
	expand data collected on DBO.Student (middleName, DateOfBirth, etc). this will enable possible constraints to limit unintended duplication, and provide useful data values for analytics.
	dbo.student should perhaps start with 10000001 for data visual consistency, and permit better ETL or other automated data ingestion. (reduces leading Zero issues. ie: 0001 != 1)

	for scalability, 
		DBO.Class should be seperated so a single class can be taught multiple times. (ex. create a new table for "Course" so each course can be taught in multiple Classes)
		classId should be an INT/BIGINT and not a CHAR, and reference a parent table. add 'className' to parent table as NVARCHAR() instead of CHAR() to save space and be more computationally efficient.
		NOTE* this would also make dbo.Attendance perform much better once there is a larger data set.

	DBO.Professor.courseType could be tied to the course type, but a single professor/teacher may teach more than one subject. 
		this data would be better held on a seperate table with a composite primary key of professorId and courseId

	Create a constraint on DBO.Attendance to limit an Insert where isPresent=0 and the arrival or departure time are NOT NULL, to prevent incorrect reporting. (and vice versa)
	#TODO: rename dbo.Attendance.isPresent to a better, more precise terminology

*/

CREATE TABLE DBO.Student
	(
	studentId INT PRIMARY KEY,
	firstName VARCHAR(200) NOT NULL,
	lastName VARCHAR(200) NOT NULL
	);

INSERT INTO DBO.Student
VALUES
	(0001, 'Matt', 'Murdock'),
	(0002, 'Bruce', 'Banner'),
	(0003, 'Bruce', 'Wayne'),
	(0004, 'John', 'Constantine'),
	(0005, 'Mittens', 'Snugglefoot'),
	(0006, 'French', 'Toast'),
	(0007, 'Sir Niles', 'McMoneyBags'),
	(0008, 'Tony', 'Stark'),
	(0009, 'Dr.', 'Acula'),
	(0010, 'Frank', 'Stein')
	;

CREATE TABLE DBO.Professor
	(
	professorId INT PRIMARY KEY,
	firstName VARCHAR(200) NOT NULL,
	lastName VARCHAR(200) NOT NULL,
	courseType VARCHAR(20) NULL
	);

INSERT INTO DBO.Professor
VALUES
	(1001, 'Matthew', 'Murdock', 'LAW'),
	(1002, 'Mittens', 'Snugglefoot', NULL),
	(1003, 'Matthew', 'Smith', 'MATH'),
	(1004, 'Shirley', 'Temple', 'Acting'),
	(1005, 'Montain', 'Dough', NULL)
	;	

CREATE TABLE DBO.Class 
	(
	classId CHAR(7) PRIMARY KEY,
	professorId INT NULL,
	class_begin_time TIME(0) NOT NULL,
	class_end_time TIME(0) NOT NULL
	);

INSERT INTO DBO.Class
VALUES
	('MATH101', 1003, '06:00:00', '7:59:59'),  
	('LAW1040', 1001, '12:30:00', '12:59:59'),
	('ACTNG01', 1004, '08:00:00', '09:44:59')
	;

CREATE TABLE DBO.Attendance
	(
	studentID INT NOT NULL,
	classId CHAR(7) NOT NULL,
	classDate DATE NOT NULL,
	isPresent BIT DEFAULT 0,
	arrivalTime TIME(0) NULL,
	departureTime TIME(0) NULL
	);

INSERT INTO DBO.Attendance
VALUES
	(0003,'ACTNG01', '20230101', 1, '7:35:00','9:44:59'),
	(0002,'ACTNG01', '20230101', 1, '7:59:00','9:44:59'),
	(0004,'ACTNG01', '20230101', 1, '8:00:00','9:44:59'),
	(0005,'ACTNG01', '20230101', 1, '8:00:00','9:44:59'),
	(0006,'ACTNG01', '20230101', 1, '8:00:00','9:44:59'),
	(0007,'ACTNG01', '20230101', 1, '8:00:00',NULL),
	(0008,'ACTNG01', '20230101', 1, '8:00:00','9:44:59'),
	(0009,'ACTNG01', '20230101', 1, '8:00:00','9:44:59'),
	(0001,'ACTNG01', '20230101', 1, '8:02:00','9:44:59'),
	(0010,'ACTNG01', '20230101', 0, NULL,NULL),
	(0002,'ACTNG01', '20230102', 1, '7:59:00','9:44:59'),
	(0003,'ACTNG01', '20230102', 1, '7:59:00','9:44:59'),
	(0006,'ACTNG01', '20230102', 1, '8:00:00','9:44:59'),
	(0008,'ACTNG01', '20230102', 1, '8:00:00',NULL),
	(0009,'ACTNG01', '20230102', 1, '8:00:00','9:44:59'),
	(0010,'ACTNG01', '20230102', 1, '8:00:00','9:44:59'),
	(0001,'ACTNG01', '20230102', 1, NULL,'9:44:59'),
	(0004,'ACTNG01', '20230102', 0, NULL,NULL),
	(0005,'ACTNG01', '20230102', 0, NULL,NULL),
	(0007,'ACTNG01', '20230102', 0, NULL,NULL),
	(0003,'ACTNG01', '20230103', 1, '7:16:00','9:44:59'),
	(0002,'ACTNG01', '20230103', 1, '7:59:00','9:44:59'),
	(0004,'ACTNG01', '20230103', 1, '8:00:00','9:44:59'),
	(0006,'ACTNG01', '20230103', 1, '8:00:00','9:44:59'),
	(0007,'ACTNG01', '20230103', 1, '8:00:00','9:44:59'),
	(0008,'ACTNG01', '20230103', 1, '8:00:00','9:44:59'),
	(0009,'ACTNG01', '20230103', 1, '8:00:00','9:44:59'),
	(0001,'ACTNG01', '20230103', 1, '8:02:00','9:44:59'),
	(0005,'ACTNG01', '20230103', 0, NULL,NULL),
	(0010,'ACTNG01', '20230103', 0, NULL,NULL),
	(0001,'ACTNG01', '20230104', 1, '7:59:00','9:44:59'),
	(0002,'ACTNG01', '20230104', 1, '7:59:00','9:44:59'),
	(0006,'ACTNG01', '20230104', 1, '8:00:00','9:44:59'),
	(0008,'ACTNG01', '20230104', 1, '8:00:00','9:44:59'),
	(0009,'ACTNG01', '20230104', 1, '8:00:00','9:44:59'),
	(0010,'ACTNG01', '20230104', 1, '8:00:00','9:44:59'),
	(0003,'ACTNG01', '20230104', 0, NULL,NULL),
	(0004,'ACTNG01', '20230104', 0, NULL,NULL),
	(0005,'ACTNG01', '20230104', 0, NULL,NULL),
	(0007,'ACTNG01', '20230104', 0, NULL,NULL),
	(0006,'LAW1040', '20230101', 1, '12:30:00', '12:59:59'),
	(0006,'LAW1040', '20230101', 1, '12:30:00', '12:59:59'),
	(0006,'LAW1040', '20230101', 1, '12:30:00', '12:59:59'),
	(0006,'LAW1040', '20230101', 1, '12:30:00', '12:59:59'),
	(0006,'LAW1040', '20230101', 1, '12:30:00', '12:59:59'),
	(0006,'LAW1040', '20230101', 1, '12:30:00', '12:59:59'),
	(0006,'LAW1040', '20230101', 1, '12:30:00', '12:59:59'),
	(0003,'ACTNG01', '20230105', 1, '7:38:00','9:44:59'),
	(0001,'ACTNG01', '20230105', 1, '7:54:00','9:44:59'),
	(0002,'ACTNG01', '20230105', 1, '7:59:00',NULL),
	(0004,'ACTNG01', '20230105', 1, '8:00:00',NULL),
	(0006,'ACTNG01', '20230105', 1, '8:00:00',NULL),
	(0007,'ACTNG01', '20230105', 1, '8:00:00','9:44:59'),
	(0008,'ACTNG01', '20230105', 1, '8:00:00','9:44:59'),
	(0009,'ACTNG01', '20230105', 1, NULL,'9:44:59'),
	(0005,'ACTNG01', '20230105', 0, NULL,NULL),
	(0010,'ACTNG01', '20230105', 0, NULL,NULL),
	(0001,'ACTNG01', '20230106', 1, '7:56:00','9:44:59'),
	(0002,'ACTNG01', '20230106', 1, '7:59:00',NULL),
	(0006,'ACTNG01', '20230106', 1, '8:00:00','9:44:59'),
	(0008,'ACTNG01', '20230106', 1, NULL,'9:44:59'),
	(0009,'ACTNG01', '20230106', 1, '8:00:00','9:44:59'),
	(0010,'ACTNG01', '20230106', 1, '8:00:00','9:44:59'),
	(0003,'ACTNG01', '20230106', 0, NULL,NULL),
	(0004,'ACTNG01', '20230106', 0, NULL,NULL),
	(0005,'ACTNG01', '20230106', 0, NULL,NULL),
	(0007,'ACTNG01', '20230106', 0, NULL,NULL),
	(0002,'ACTNG01', '20230107', 1, '7:59:00','9:44:59'),
	(0003,'ACTNG01', '20230107', 1, '7:59:00','9:44:59'),
	(0006,'ACTNG01', '20230107', 1, '8:00:00','9:44:59'),
	(0008,'ACTNG01', '20230107', 1, '8:00:00',NULL),
	(0009,'ACTNG01', '20230107', 1, '8:00:00','9:44:59'),
	(0001,'ACTNG01', '20230107', 0, NULL,NULL),
	(0004,'ACTNG01', '20230107', 0, NULL,NULL),
	(0005,'ACTNG01', '20230107', 0, NULL,NULL),
	(0007,'ACTNG01', '20230107', 0, NULL,NULL),
	(0010,'ACTNG01', '20230107', 0, NULL,NULL)
	;