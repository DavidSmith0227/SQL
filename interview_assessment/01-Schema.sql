
CREATE TABLE DBO.Student
	(
	firstName VARCHAR(200) NOT NULL,
	lastName VARCHAR(200) NOT NULL,
	studentId INT
	);


CREATE TABLE DBO.Professor
	(
	professorId INT PRIMARY KEY,
	firstName VARCHAR(200) NOT NULL,
	lastName VARCHAR(200) NOT NULL,
	courseType VARCHAR(20) NULL
	);


CREATE TABLE DBO.Class 
	(
	classId CHAR(7) PRIMARY KEY,
	professorId INT NULL,
	class_begin_time TIME(0) NOT NULL,
	class_end_time TIME(0) NOT NULL
	);


CREATE TABLE DBO.Attendance
	(
	studentID INT NOT NULL,
	classId CHAR(7) NOT NULL,
	classDate DATE NOT NULL,
	isPresent BIT DEFAULT 0,
	arrivalTime TIME(0) NULL,
	departureTime TIME(0) NULL
	);

