Create database Library
go
--creates database and then connects it
use Library
go

--Creating tables
Create table Category
(
	categoryID int not null primary key identity(100,1),
	categoryName nvarchar(100) not null
)
go

Create table Subcategory
(
	categoryID int not null,
	subCategoryID int not null,
	
	primary key (categoryID, subCategoryID),
	Foreign Key (categoryID) references Category(categoryID),
	Foreign Key (subCategoryID) references Category(categoryID)
)
go


create table Book
(
	isbn nchar(13) not null primary key,
	bookTitle nvarchar(100) not null,
	yearpublished DateTime2(1) default('Year Unknown'),
	categoryID int not null,
	eLicenses int default(1),
	Foreign key (categoryID) references Category(categoryID)
)
go

Create table Author
(
	authorID int not null primary key identity(200,1),
	authorFirstName nvarchar(50) not null,
	authorLastName nvarchar(50) not null,
)
go

Create table BookAuthor
(
	isbn nchar(13) not null,
	authorID int not null,
	primary key (isbn, authorID),
	Foreign key (isbn) references Book(isbn),
	Foreign key (authorID) references Author(authorID)
)
go

Create table Library
(
	libraryID int not null primary key identity(400,1),
	libraryName nvarchar(50) not null,
	libraryAddress nvarchar(max) not null,
	libraryPhone nvarchar(20) not null,

)
go

Create table BookCopy
(
	bookCopyID int not null primary key identity(500,1),
	isbn nchar(13) not null,
	copyNumber int not null,
	checkOutStatus nvarchar(20) not null,
	bookPrice money,
	libraryID int not null,

	Foreign Key (isbn) references Book(isbn),
	Foreign Key (libraryID) references Library(libraryID)

)
go

Create table Patron
(
	patronID int not null primary key identity(300,1),
	patronFirstName nvarchar(50),
	patronLastName nvarchar(50),
	patronPhone nvarchar(20),
	patronEmail nvarchar(50),
	patronType nvarchar(10),
	suspended bit default(0)
)
go

Create table BookCopyBorrowed
(
	bookCopyBorrowedID int not null primary key identity(601,1),
	bookCopyID int not null,
	patronID int not null,
	dateTimeBorrowed datetime2(7) not null,
	dateTimeDue datetime2(7) not null,
	dateTimeReturned datetime2(7)

	Foreign Key (bookCopyID) references BookCopy(bookCopyID),
	Foreign Key (patronID) references Patron(patronID)
)
go
