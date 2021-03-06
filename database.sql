DROP DATABASE IF EXISTS heroku_6033235a05719ed;
CREATE DATABASE heroku_6033235a05719ed;
USE heroku_6033235a05719ed;

CREATE TABLE User (
	userID VARCHAR(100) PRIMARY KEY,
    fullName VARCHAR(100),
    lastName VARCHAR(100),
    firstName VARCHAR(100),
    email VARCHAR(100),
    userType VARCHAR(100),
    studentID VARCHAR(100) NULL UNIQUE,
    studentType VARCHAR(100) NULL,
    instructorID VARCHAR(100) NULL UNIQUE,
    instructorType VARCHAR(100) NULL
);

INSERT INTO User (userID, fullName, lastName, firstName, email, userType, instructorID)
VALUES ("millerID", "Jeff Miller", "Miller", "Jeff", "miller@usc.edu", "instructor", "Miller");

CREATE TABLE Class (
	classID VARCHAR(100) PRIMARY KEY,
    department VARCHAR(100),
    classNumber VARCHAR(100),
    instructorID VARCHAR(100),
    classDescription VARCHAR(100),
    lectureIDs VARCHAR(100),
    FOREIGN KEY (instructorID) REFERENCES User(instructorID)
);

INSERT INTO Class (classID, department, classNumber, instructorID, classDescription, lectureIDs)
VALUES ("CSCI201", "CSCI", "201", "Miller", "Principles of Software Development", "1");

CREATE TABLE Lecture (
	lectureUUID VARCHAR(100) UNIQUE,
    sectionID VARCHAR(100) PRIMARY KEY,
    classID VARCHAR(100),
    instructorID VARCHAR(100),
    startTime TIME,
    endTime TIME,
    meetingDaysOfWeek VARCHAR(100),
    lectureDescription VARCHAR(500),
    longitude VARCHAR(100),
    latitude VARCHAR(100),
    FOREIGN KEY (classID) REFERENCES Class(classID),
    FOREIGN KEY (instructorID) REFERENCES User(instructorID)
);

INSERT INTO Lecture (lectureUUID, sectionID, classID, instructorID, startTime, endTime, meetingDaysOfWeek, lectureDescription, longitude, latitude)
VALUES("ABCD", "8AM", "CSCI201", "Miller", "08:00:00", "09:20:00", "TTh", "Principles of Software Development", "-118.287588", "34.019594");

CREATE TABLE LectureRegistration (
	userID VARCHAR(100),
    lectureUUID VARCHAR(100),
    FOREIGN KEY (userID) REFERENCES User(userID),
    FOREIGN KEY (lectureUUID) REFERENCES Lecture(lectureUUID),
    PRIMARY KEY (userID, lectureUUID)
);

CREATE TABLE QnA_Table (
	idx INT(11) PRIMARY KEY AUTO_INCREMENT,
    lectureUUID VARCHAR(100),
    userID VARCHAR(100),
    postTitle VARCHAR(100) NULL,
    postContent VARCHAR(500),
    time_stamp DATETIME,
    upvotes SMALLINT(11),
    FOREIGN KEY (lectureUUID) REFERENCES Lecture(lectureUUID),
    FOREIGN KEY (userID) REFERENCES User(userID)
);

CREATE TABLE AttendanceRecord (
	idx INT(11) PRIMARY KEY AUTO_INCREMENT,
    studentID VARCHAR(100),
    lectureUUID VARCHAR(100),
    lectureDate DATE,
    attendance INT(11) NOT NULL,
	FOREIGN KEY (studentID) REFERENCES User(StudentID),
    FOREIGN KEY (lectureUUID) REFERENCES Lecture(lectureUUID)
);

CREATE TABLE DaysLectureMeets (
	lectureUUID VARCHAR(100),
	lectureDate DATE,
    FOREIGN KEY (lectureUUID) REFERENCES Lecture(lectureUUID)
);

DELIMITER $$
CREATE PROCEDURE generateTuesdayThursday(IN lectureUUID VARCHAR(100))
BEGIN
	DECLARE _now DATE;
	DECLARE _endYear DATE;
    SET _now = DATE_FORMAT(NOW(), '%Y-11-10');
	SET _endYear = DATE_FORMAT(NOW(), '%Y-11-29');
while _now < _endYear DO
	if DAYOFWEEK(_now) = 3 THEN
		INSERT INTO DaysLectureMeets (lectureUUID, lectureDate) VALUES (lectureUUID, _now);
        SET _now = _now + INTERVAL 2 DAY;
	ELSEIF DAYOFWEEK(_now) = 5 THEN
		INSERT INTO DaysLectureMeets (lectureUUID, lectureDate) VALUES (lectureUUID, _now);
		SET _now = _now + INTERVAL 5 DAY;
	ELSE
		SET _now = _now + INTERVAL 1 DAY;
	END IF;
END WHILE;
END $$
DELIMITER ;
CALL generateTuesdayThursday('ABCD');

DELIMITER //
CREATE PROCEDURE setAttendance(IN currStudentID VARCHAR(100), IN lectureID VARCHAR(100))
BEGIN
	DECLARE done BOOLEAN DEFAULT 0;
	DECLARE currDate DATE;
	DECLARE date_cursor CURSOR FOR 
		SELECT lectureDate FROM DaysLectureMeets WHERE lectureUUID = lectureID;
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done=1;
	OPEN date_cursor;
   -- Loop through all rows
   REPEAT
      -- Get date
      FETCH date_cursor INTO currDate;
      INSERT INTO AttendanceRecord (studentID, lectureUUID, lectureDate, attendance) VALUES (currStudentID, lectureID, currDate, 0);
   -- End of loop
   UNTIL done END REPEAT;
   -- Close the cursor
   CLOSE date_cursor;
END //

DELIMITER ;