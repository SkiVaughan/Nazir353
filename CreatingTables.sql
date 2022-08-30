Create database UnivDb
go
--Creates database and then connects to it 
use UnivDB
go

--Creating Tables in SSMS
Create table Student
(ID int not null primary key identity(1,1),
Name nvarchar(100) not null,
address nvarchar(100) not null,
Phone nvarchar(10)
)
go



Create table Course
(
ID int not null identity(1,1),
Title nvarchar(100) not null,
Credits int not null,
Description nvarchar(100) default('No description provided'),  
primary key(ID)
--primary key (ID)
)
go
--Alter table Course
--Add constraint pk_course
--primary key (ID)

Create Table prereqs
(
courseID int not null,
prereqID int not null,

primary key (courseID, prereqID),

)
go
Alter table prereqs
add constraint fk_course_01
foreign key (CourseID) references Course(ID)
go
Alter table prereqs
add constraint fk_course_02
foreign key (prereqid) references Course(ID)
go
