/*
	_____Assesment_Questions_____

#1. Student.studentId

#2.	Class.professorId
	Attendance.studentId
	Attendance.classId
*/


/* #3 */
SELECT
	Student.firstName, 
	Student.lastName, 
	SUM(CAST(Attendance.isPresent AS INT)) as attendanceRate 
FROM 
	Student, 
	Attendance
WHERE 
	Student.studentId = Attendance.studentId
	AND Attendance.classId = 'ACTNG01'
GROUP BY Attendance.studentId		
ORDER BY attendanceRate DESC		
	

/* #4 */
SELECT 
	Attendance.classDate, 
	Student.firstName, 
	Student.lastName, 
	Attendance.arrivalTime
FROM dbo.Attendance
	INNER JOIN dbo.Student
		ON Student.studentId = Attendance.studentId
	INNER JOIN dbo.Class
		ON Class.classId = Attendance.classId
WHERE 
	Attendance.classId = 'ACTNG01' 
GROUP BY Attendance.classDate, Attendance.studentId, Student.firstName, Student.lastName, Attendance.arrivalTime
HAVING MAX(Attendance.arrivalTime) = (
    SELECT MAX(arrivalTime)
    FROM Attendance AS A
    WHERE A.classId = 'ACTNG01' 
      AND A.arrivalTime < Class.class_begin_time
      AND A.classDate = Attendance.classDate
    GROUP BY A.classDate
)
ORDER BY Attendance.classDate


/* #5 */
SELECT
  Student.firstName, 
  Student.lastName,
  Attendance.classDate,
  Attendance.arrivalTime,
  Attendance.departureTime 
FROM dbo.Attendance
	INNER JOIN dbo.Student
		ON Student.studentId = Attendance.studentId
WHERE 
	Attendance.classId = 'ACTNG01'	
	AND Attendance.isPresent = 1
	AND ( Attendance.arrivalTime IS NULL OR Attendance.departureTime IS NULL )


/* #6 */
INSERT INTO Student (firstName, lastName, studentId)
VALUES 
  (
	'firstName', 
	'lastName',
 	( SELECT MAX(studentId) + 1 FROM Student)
   );


/* #7 */
/* -- Some suggestions, but many improvements are available --
	* reorder dbo.student so primary key is first,
	* Add Primary Key constraint to DBO.Student ON studentId
	* auto-increment dbo.Student.studentId
	* expand data collected on DBO.Student (middleName, DateOfBirth, etc). this will enable possible constraints to limit unintended duplication, and provide useful data values for analytics.
	* dbo.student should perhaps start with 10000001 for data visual consistency, and permit better ETL or other automated data ingestion. (reduces leading Zero issues. ie: 0001 != 1)

	* for scalability, 
		** DBO.Class should be seperated so a single class can be taught multiple times. (ex. create a new table for "Course" so each course can be taught in multiple Classes)
		** classId should be an INT/BIGINT and not a CHAR, and reference a parent table. add 'className' to parent table as NVARCHAR() instead of CHAR() to save space and be more computationally efficient.
		** NOTE* this would also make dbo.Attendance perform much better once there is a larger data set.

	* DBO.Professor.courseType could be tied to the course type, but a single professor/teacher may teach more than one subject. 
		** this data would be better held on a seperate table with a composite primary key of professorId and courseId

	* Create a constraint on DBO.Attendance to limit an Insert where isPresent=0 and the arrival or departure time are NOT NULL, to prevent incorrect reporting. (and vice versa)
*/