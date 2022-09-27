use LibraryDB
go
--1 WORKING)
Create proc spGetCopiesofSpecific
(@title nvarchar(100))
As 
Begin
	Select b.bookTitle, COUNT(*) AS Number_Of_Available_Copies
	From Book b INNER JOIN BookCopy bc
	ON b.isbn = bc.isbn
	WHERE b.bookTitle LIKE '%'+@title+'%'
	AND bc.bookCopyID NOT IN   
	(	SELECT bookCopyID FROM BookCopyBorrowed )
	GROUP BY b.bookTitle;
END

exec spGetCopiesofSpecific 'Professional'
go
----------------------------------------------------------------------------

--2 WORKING)
Create proc spGetCopiesofSpecificLocation
(@bookName nvarchar(100))
As 
Begin
	select Book.bookTitle, libraryID
	from BookCopy
	inner join Book on BookCopy.isbn = Book.isbn
	Where bookTitle like '%'+@bookName+'%'
	AND  checkOutStatus = 'Available'
	End

go

exec spGetCopiesofSpecificLocation 'Professional'
go
----------------------------------------------------------------------------
--3 WORKING)
Create proc spGetDueDate
(@copyID int)
As
begin
	select dateTimeDue
	from BookCopyBorrowed
	Where bookCopyID = @copyID

End
go

exec spGetDueDate 500
go
----------------------------------------------------------------------------
--4 WORKING)
Create proc spGetByPrice
(@price money)
As
Begin
	select b.bookTitle, bc.bookCopyID, bc.bookPrice
	from Book b inner join BookCopy bc
	on b.isbn = bc.isbn
	Where bookPrice >= isnull(@price, bookPrice)
End
go

exec spGetByPrice 25.99
go
----------------------------------------------------------------------------
--5 WORKING)
Create proc spGetBookCopiesList
(
@lName nvarchar(50) = null,
@catName nvarchar(100) = null,
@aLastName nvarchar(30) = null)
as
Begin
	select Book.isbn, copyNumber, bookTitle, categoryName, libraryAddress, checkOutStatus
	from Library
	inner join BookCopy on Library.libraryID = BookCopy.libraryID
	inner join Book on BookCopy.isbn = Book.isbn
	inner join Category on Book.categoryID = Category.categoryID
	inner join BookAuthor on Book.isbn = BookAuthor.isbn
	inner join Author on BookAuthor.authorID = Author.authorID
	
	Where libraryName = isnull(@lName, libraryName)
	and categoryName = isnull(@catName, categoryName)
	and authorLastName = isnull(@aLastName, authorLastName)
end
go

exec spGetBookCopiesList @catName = 'SQL'
go
----------------------------------------------------------------------------
--6)
create proc spBooksinCat
(
@catID int)
as
begin
	select Category.categoryID, categoryName, subCategoryID
	from Category
	inner join Subcategory on Category.categoryID = Subcategory.categoryID
	Where Category.categoryID = @catID
end
go

exec spBooksinCat 100
go
----------------------------------------------------------------------------

--7 WORKING)
create proc spbookCheckout
(
@pid int,
@bCopyID int)
as
begin
  insert into BookCopyBorrowed(patronID, dateTimeBorrowed, dateTimeDue, bookCopyID)
  values(@pid, GETDATE(), GETDATE()+1, @bCopyID)
end
go

exec spbookCheckout 300, 505
go
----------------------------------------------------------------------------
--8 WORKING)
create proc spbookReturn
(
@pid int,
@bCopyID int)
as
Begin
	Update BookCopyBorrowed
	set dateTimeReturned = GetDate()
	where patronID = @pid and bookCopyID = @bCopyID
end
go
exec spbookReturn 300, 505
go
----------------------------------------------------------------------------
--9 WORKING)
create proc spbookLate
(
@sDate datetime,
@dueDate datetime)
as
Begin
	select Patron.patronID, Patron.patronLastname, Patron.patronEmail, Count(BookCopyBorrowed.patronID)

	from Patron inner join BookCopyBorrowed

	on Patron.patronID = BookCopyBorrowed.patronID

	where dateTimeBorrowed >= @sDate and dateTimeDue <= @dueDate and dateTimeReturned > dateTimeDue

	group by Patron.patronId, Patron.patronLastname, Patron.patronEmail
end

go

exec spbookLate '2022-08-09', '2022-09-13'
go
----------------------------------------------------------------------------
--10 WORKING)
create proc spAddPatron
(
 @first nvarchar (30),
 @last nvarchar (30),
 @phone nvarchar (12),
 @email nvarchar (50),
 @sus bit,
 @pType nvarchar(50),
 @aspnet char(36),
 @username nvarchar(50),
 @pid int output)
 as
 Begin

	Insert into Patron(patronFirstname, patronLastname, patronPhone, patronEmail, suspended, patronType, aspnetID, username)
	Values (@first, @last, @phone, @email, @sus, @pType, @aspnet, @username)
	set @pid = @@IDENTITY

End
go


declare @pid int

exec spAddPatron
@first = 'Vaughan',
@last = 'Koscinski',
@phone = '908-555-9090',
@email = 'vk0010@mix.wvu.edu',
@sus = true,
@pType = 'Student',
@aspnet =F0C12F7F9B7D4D9AAF9308039C3AF184,
@username = 'vk0010',
@pid = @pid out

print @pid
go
----------------------------------------------------------------------------
--11 WORKING)
create proc spupdatePriceCopy
(
@bcID int,
@isbn nchar(13),
@bPrice decimal(6,2))
as
Begin
	Update BookCopy
	Set bookPrice = @bPrice
	Where bookCopyID = @bcID and isbn = @isbn
end
go

exec spupdatePriceCopy 500, 9781118102282, 17.00
go
----------------------------------------------------------------------------

--12 WORKING)
create proc spInsertBook
(
@isbn nchar(13),
@bTitle nvarchar(200),
@year int,
@catID int,
@nOEL int)
as
Begin

	Insert into Book(isbn, bookTitle, yearPublished, categoryID, numberOfELicenses)
	Values (@isbn, @bTitle, @year, @catID, @nOEL)

End

exec spInsertBook
@isbn = 1234567890098,
@bTitle = 'Vaughan Book',
@year = 2010,
@catID = 100,
@nOEL = 5
go
----------------------------------------------------------------------------

--13 1/2 WORKING)
create or alter proc spAddBookCopy
(
@isbn nchar(13),
@cNum int,
@checkOutStat nvarchar(20),
@bPrice decimal(6,2),
@libraryID int)
As 
Begin
	
			declare @bCopyID int
			Insert into BookCopy(isbn, copyNumber, checkOutStatus, bookPrice, libraryID)
			Values (@isbn, @cNum, @checkOutStat, @bPrice, @libraryID)
			set @bCopyID = @@IDENTITY

			-- I believe from here you are supposed to inner join Book on Bookcopy
			--This is so that you can link the book that you want to create another copy with
			-- something like the last proc from in class, I am just unsure how how to do the update copy part



End
go

