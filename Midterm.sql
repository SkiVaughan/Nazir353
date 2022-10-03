--This is the review for the midterm 
--Strictly on Procedures
--4 Questions Open Note

use Library
go

/*A patron wants to know if copies of a specific book are available in the library system. 
The patron provides book name or part of the book name to search for the book. 
The system should provide the total number of available book copies to the user along with the book title.*/
Create proc spLikeName
(@bookName nvarchar(100))
as 
Begin

	SELECT COUNT(copyNumber) AS 'Available Copies', b.booktitle
	FROM BookCopy bc inner join Book b
	ON bc.ISBN = b.ISBN
	
	WHERE b.bookTitle like '%'+@bookName+'%'
	and bc.checkoutStatus = 'Available'

	Group by b.bookTitle
end
go

/*11. The library employee would need a mechanism to update the price of a book copy. 
All required columns will be provided to achieve this functionality.*/

Create proc spUpdatePrice
(@bookCopyID int,
 @price decimal(6,2))
 as
 begin
	update BookCopy
	set bookPrice = @price
	where bookCopyID = @bookCopyID
end
go


Create proc spGetLatePatronsbyPeriod
(@startdate datetime2(7),
 @enddate datetime2(7))
 as
 begin
	Select count(p.patronID), p.patronid,patronlastname, patronemail

	from BookCopyBorrowed bcb inner join patron p

	on bcb.patronID = p.patronID

	where
	(dateTimeBorrowed >= @startdate and dateTimeBorrowed <= @enddate)
	and dateTimeReturned > dateTimeDue
	or (datetimedue < getdate() and dateTimeReturned is null)

	group by p.patronid,patronLastName,patronEmail
end
go

/*The library employee would need a mechanism to enter a new patron into the system. 
All required columns will be provided to create the new record. 
The newly generated patronID will be returned.*/

Create proc spCreatePatron
(@firstname nvarchar(30),
 @lastname nvarchar(30),
 @phone nvarchar(12),
 @email nvarchar(50),
 @username nvarchar(50))
as
begin
	insert into Patron(patronFirstName, patronLastName, patronPhone, patronEmail, username)
	
	Values(@firstname, @lastname, @phone, @email, @username)

	--newly generated ID will be returned
end
go

/*7. The system should allow patrons to borrow or check out a book. 
The patron will swipe his / her ID card and scan the book’s barcode.*/


Create proc spBorrowBook
(@patronID int,
 @bookCopyID int)
 as
 begin
	insert into BookCopyBorrowed (bookCopyID, patronID, dateTimeBorrowed, dateTimeDue)

	Values (@bookCopyID, @patronID, GetDate(), GetDate() +21)
end
go

/*3. The library employee would like to know when a certain book copy is due. 
The employee provides the book copy id to retrieve the due date for the book. 
If the employee does not provide a book copy id, due dates for all books are retrieved. 
The due date for only books that haven’t been returned should be retrieved.*/

Create proc spGetBookCopyDueDate
(@bookCopyID int = null)
as
begin
	select bc.bookCopyID, bcb.datetimedue
	From BookCopy bc inner join BookCopyBorrowed bcb
	ON bc.bookCopyID = bcb.bookCopyID
	where bc.bookCopyID = isnull(@bookcopyID, bc.bookCopyID)
	and dateTimeReturned is null
end
go
--------------------------------------------------------------END OF LIBRARY PROC----------------------------------------------------------------------
ines (315 sloc)  7.57 KB

Create proc spGetAllCategories
AS
	Begin

		Select * From Category


	ENd


-- exec spGetAllCategories
go

Create proc spGetCategoryByID
(@catID int)
AS
Begin
	
	Select * from Category
	where CategoryID = @catID


End
go

-- exec spGetCategoryByID @catID = 9

Create proc spGetCategoryByDeptID
(@deptID int)
As
Begin
	Select CategoryID, Name, Description 
	From Category
	Where DepartmentID = @deptID

End
go
--execute spGetCategoryByDeptID @deptID = 2

Create proc spGetProductByName
(@name nvarchar(100))
as
Begin
	Select * from Product
	where name like '%' + @name + '%'

End

--exec spGetProductByName @name = shirt

-- 2b)
Create proc spGetCategoriesByDeptIDOptional
(@deptID int = null)
as
Begin
	Select * from Category
	Where DepartmentID = isnull(@deptID, departmentID)

ENd

go

 exec  spGetCategoriesByDeptIDOptional @deptID=2


 --2c)
 Create proc spGetCategoryByPartialName
 (@name nvarchar(100) )
 As
 begin
	Select * from Category
	where name like '%' + @name + '%' 
 end
 Go
 --exec spGetCategoryByPartialName 'App'

 --2d)

 Create Proc spGetCategoriesBetweenTwoCatIDs
 (@catID1 int,
 @catID2 int)
 As
 Begin
	Select * from Category
	where CategoryID >= @catID1
	and   CategoryID <= @catID2 
	-- where categoryID between(@catID1, @catID2)
 End

 go

 exec spGetCategoriesBetweenTwoCatIDs @catid1= 2, @catid2= 7

 -- 2e
 Create proc spGetCategoryBetweenIDsOptional
 (@catid1 int = null,
 @catid2 int = null)
 AS
 Begin
	Select * from Category
	Where CategoryID >= isnull(@catid1, categoryID)
	and CategoryID <= isnull(@catid2, categoryID)

 End

 go

 exec spGetCategoryBetweenIDsOptional @catid2= 9



 -- 6)
 Alter proc spGetProductsinCategory 
 (@catid int, @descLength int = 60 )
 AS
 Begin
	Select p.ProductID, Name, 
	
	       Case 
		       When LEN(Description) <= @descLength THEN description
			   ELSE SUBSTRING(Description, 1, @descLength)
		   
		   End as TruncatedDesc,
	       
		   
		   Price, Thumbnail, Image,
		   PromoFront, PromoDept
     
    From product p inner join ProductCategory pc
	     on p.ProductID = pc.ProductID

    where CategoryID = @catid

 End
 go

 -- exec spGetProductsinCategory 5

 --8)
 Alter proc spGetProductsOnDeptPromo 
 (@promoDept bit)
 as
 Begin
	
	Select ProductID, Name, 
	
	       Case 
		       When LEN(Description) <= 60 THEN description
			   ELSE SUBSTRING(Description, 1, 60)
		   
		   End as TruncatedDesc,
	       
		   
		   Price, Thumbnail, Image,
		   PromoFront, PromoDept

		   from Product 
		   Where PromoDept = @promoDept

 End


-- exec spGetProductsOnDeptPromo 1


--8b)
Create proc spGetProductsOnDeptPromoByDeptID 
(@deptid int)
AS
Begin
	
	Select p.ProductID, p.Name, 
	
	       Case 
		       When LEN(p.Description) <= 60 THEN p.description
			   ELSE SUBSTRING(p.Description, 1, 60)
		   
		   End as TruncatedDesc,
	       
		   
		   Price, Thumbnail, Image,
		   PromoFront, PromoDept

	From  Product p inner join ProductCategory pc
	       on p.ProductID = pc.ProductID
		   inner join Category c
		   on pc.CategoryID = c.CategoryID

     where DepartmentID = @deptid
			AND PromoDept = 1

End
GO
--exec spGetProductsOnDeptPromoByDeptID 4


--8c)
Create proc spGetProductsOnDeptPromoByTwoDeptIDs
(@deptid1 int = null, @deptid2 int = null)
AS
Begin

Select p.ProductID, p.Name, 
	
	       Case 
		       When LEN(p.Description) <= 60 THEN p.description
			   ELSE SUBSTRING(p.Description, 1, 60)
		   
		   End as TruncatedDesc,
	       
		   
		   Price, Thumbnail, Image,
		   PromoFront, PromoDept

	From  Product p inner join ProductCategory pc
	       on p.ProductID = pc.ProductID
		   inner join Category c
		   on pc.CategoryID = c.CategoryID

     where DepartmentID >= isnull(@deptid1, departmentID) 
	        AND DepartmentID <= isnull(@deptid2, departmentID)
			AND PromoDept = 1



ENd

exec spGetProductsOnDeptPromoByTwoDeptIDs 2,4

-- 9 to be done by students

--9b
Create proc spGetProductsOnFrontPromoWithPriceOptional
(@price money = null)
AS
Begin
	
	Select p.ProductID, p.Name, 
	
	       Case 
		       When LEN(p.Description) <= 60 THEN p.description
			   ELSE SUBSTRING(p.Description, 1, 60)
		   
		   End as TruncatedDesc,
	       
		   
		   Price, Thumbnail, Image,
		   PromoFront, PromoDept

	From  Product p
	     where price > isnull(@price, price)

End

exec spGetProductsOnFrontPromoWithPriceOptional 100

Create  proc spInsertCategory
(@deptid int,
@name nvarchar(100),
@desc nvarchar(1000),
@catID int output)
AS
Begin
	Insert into Category(DepartmentID, Name, Description)
	values (@deptid, @name, @desc)
	set @catid = @@IDENTITY
End


/*
declare @cID int
exec spInsertCategory 
4, 'test department', 'Test description', @cID output
print @cid
*/

--9d
create proc spInsertProduct
(@Name nvarchar(200),
@description nvarchar(max),
@price money,
@prodID int output)
as
Begin
	Insert into Product(Name, Description, Price)
	Values (@name, @description, @price)
	set @prodID = @@IDENTITY
	   
End

/*
declare @pid int
exec spInsertProduct
@Name = 'Test Product',
@description = 'Test desc',
@price = 17.99,
@prodID = @pid out
print @pid
*/

--9e

Create proc spCountProductsWithPriceGreaterThanValue
(@price money = 12.99,
@count int out)
AS
Begin
     Select @count = count(ProductID)
	 from Product
	 where price >= @price


ENd

/*
declare @countOfRows int
exec spCountProductsWithPriceGreaterThanValue 13.99, @countOfROws out
print @countofrows
*/

--10 
Create proc spShoppingCartAddItem
(@cartID char(36),
@prodId int,
@attributes nvarchar(1000))
AS
Begin
	if exists
		(Select CartID from ShoppingCart
		where cartid= @cartID and ProductID=@ProdID)
		Update ShoppingCart
		Set Quantity = Quantity + 1, DateAdded=GetDate()
		where cartid = @cartID and ProductID = @prodId
	Else
	   Insert into ShoppingCart(CartID, ProductID, Attributes, Quantity, DateAdded)
	   Values(@cartid, @prodID, @attributes, 1, getDate())
END

--exec spShoppingCartAddItem 1460, 60, 'none'

--11)

Create Proc spShoppingCartRemoveItem
(@cartid char (36),
@prodID int)
As
   Delete From ShoppingCart
   Where cartid=@cartID and ProductID = @prodID

--exec spShoppingCartRemoveItem 1460, 60


-- 12

Create proc spShoppingCartUpdateItem
(@CartID char(36),
@prodID int,
@qty int)
AS
Begin
	If @qty > 0
	  Update ShoppingCart
	  Set Quantity=@qty, DateAdded=Getdate()
	  where cartid=@cartid and ProductID=@prodID
	Else 
	  exec spShoppingCartRemoveItem @cartID, @prodid
End

-- exec spShoppingCartUpdateItem 1434, 63, 0

-- 13)

Create Proc spShoppingCartGetItems
(@cartid char(36))
AS
Begin
	Select p.ProductID, Name, 
	Price, Quantity, (Price * Quantity) as Subtotal

	From Product p inner join ShoppingCart sc
	on p.ProductID = sc.ProductID

	where CartID = @cartid

End

-- exec spShoppingCartGetItems 1460


-- 14
Create proc spShoppingCartGetTotalAmount
(@cartid char(36))
AS
Begin
     Select Cartid, SUM(Price * Quantity)

	 from product inner join ShoppingCart
	 on product.ProductID = ShoppingCart.ProductID

	 Where cartID = @cartid
	 group by cartid

End

--exec spShoppingCartGetTotalAmount 1434

--15

Create proc spCreateCustomerOrder 
(@cartid char(36),
@CustID uniqueidentifier)
As
Begin
		--Create an order
		declare @orderID int
		Insert into Orders(CustomerID)
		Values (@custID)
		set @orderID = @@IDENTITY



		--Insert items from cart into order detail table
		Insert into OrderDetail (OrderID, ProductID, 
		ProductName, Quantity, UnitCost)

		Select @orderId, Product.ProductID, Name, Quantity, Price
		From ShoppingCart inner join Product
		on ShoppingCart.ProductID = Product.ProductID
		where cartid = @cartID


		--Delete items from cart
		Delete from ShoppingCart
		where cartid = @cartID

		--print orderID
		Select @orderID


End

exec spCreateCustomerOrder 1460, '12345678-1234-1234-1234-123456789012'
--1) 
create proc spGetAllCategories
as
begin 
		select * from Category
end 
go 
/*
exec spGetAllCategories
go
*/
--2)
alter proc spGetAllProductsInCategoryByName
(@catName nvarchar(100) = null)
as
begin 
	select c.CategoryName, p.ProductName
	from Category c inner join Products p
	on c.CategoryID = p.CategoryID
	where CategoryName like '%' + @catName + '%' or 
	CategoryName=isnull(@catName, CategoryName) 

end
go
/*
exec spGetAllProductsInCategoryByName 
go
*/
go
--3) 
create proc spSearchByProductName
(@name nvarchar(100))
as
begin
	select * from Products
	where ProductName like '%' + @name + '%' 
end 
go
/*
exec spSearchByProductName 'Green'
go
*/

--4) 
alter proc spEmployeeInfo 
(@Lname nvarchar(50),
@Fname nvarchar(50),
@title nvarchar(50),
@phone nvarchar(50) = null,
@empID int output)
as
begin  
	Insert into Employees (LastName, FirstName, JobTitle, Phone) 
	values (@Lname, @Fname,@title, @phone)
	set @empID = @@IDENTITY
end
go
/*
exec spEmployeeInfo 'Lane', 'Sarah', 'CEO', null,
@empID = @eID

declare @eID int 
exec spEmployeeInfo 'Smith', 'John', 'Accountant', '304-832-2420',
@empID = @eID 
go
*/
go

--5
alter proc spHighestQty 
(@prodID int) 
as
begin 
	select @prodID as ProductID, MAX(pod.Quantity) as HighestQuantity 
	from PurchaseOrderDetails pod inner join Products p
	on pod.ProductID = p.ProductID
	where pod.ProductID = @prodID
	group by p.ProductID 
	

end
/*
exec spHighestQty 108 
*/
go
--6
alter proc spCreatePurchaseOrder
(@empID int,
@StatusID int,
@ApprovedBy int,
@purchaseID int output)
as
begin
	insert into PurchaseOrders(CreationDate, StatusID, ExpectedDate, ApprovedBy, ApprovedDate, EmpID) 
	values (GETDATE(), @StatusID, GETDATE(), @ApprovedBy, GETDATE(), @empID) 
	set @purchaseID = @@IDENTITY

end
/* 5 purchase orders: 
exec spCreatePurchaseOrder
@StatusID = 600,
@ApprovedBy = 30,
@empID = 400, 
@purchaseID = @pid 

exec spCreatePurchaseOrder
@StatusID = 700,
@ApprovedBy = 40,
@empID = 400, 
@purchaseID = @pid 

exec spCreatePurchaseOrder
@StatusID = 650,
@ApprovedBy = 50,
@empID = 402, 
@purchaseID = @pid 

exec spCreatePurchaseOrder
@StatusID = 620,
@ApprovedBy = 60,
@empID = 403, 
@purchaseID = @pid

declare @pid int
exec spCreatePurchaseOrder
@StatusID = 820,
@ApprovedBy = 30,
@empID = 402, 
@purchaseID = @pid 
*/
go
--7 
create proc spAddPurchaseDetails
(@purchaseDetailID int output,
@orderID int,
@productID int, 
@quantity int,
@unitcost money,
@postedToInv bit, 
@invID int) 
as
begin 
	insert into PurchaseOrderDetails(PurchaseOrderID, ProductID, Quantity, UnitCost, PostedToInventory,InventoryID) 
	values(@orderID, @productID, @quantity, @unitcost, @postedToInv, @invID) 
	set @purchaseDetailID = @@IDENTITY 
	
end 
go
/*
exec spAddPurchaseDetails 
@orderID = 500,
@productID = 103, 
@quantity= 1, 
@unitcost= 6, 
@postedToInv= 18, 
@invID= 303,
@purchaseDetailID=@pdID 

declare @pdID int
exec spAddPurchaseDetails
@orderID = 505,
@productID = 105, 
@quantity= 2, 
@unitcost= 5, 
@postedToInv= 15, 
@invID= 307,
@purchaseDetailID=@pdID 

declare @pdID int
exec spAddPurchaseDetails
@orderID = 507,
@productID = 108, 
@quantity= 3, 
@unitcost= 4, 
@postedToInv= 20, 
@invID= 309,
@purchaseDetailID=@pdId
*/

--8 
create proc spDeletePurchaseOrderDetail
(@orderdetailID int) 
as
begin
	delete from PurchaseOrderDetails
	where OrderDetailID = @orderdetailID
end 
go
/*
exec spDeletePurchaseOrderDetail 602
*/	
go
--9 
create proc spUpdateDates
(@purchaseID int, 
@apprDate datetime2(7))
as
begin
	if exists 
		(select PurchaseOrderID from PurchaseOrders
		where PurchaseOrderID = @purchaseID) 
		update PurchaseOrders 
		set ApprovedDate = @apprDate
	else 
		insert into PurchaseOrders (PurchaseOrderID, ApprovedDate)
		values (@purchaseID, GETDATE())
	
end
go


/*
exec spUpdateDates 504, '2022-12-15'
*/
--10 

go

create proc spCalculatePrice
(@orderDetailID int) 
as
begin
	select(Quantity * UnitCost) as Total
	from PurchaseOrderDetails
	where(OrderDetailID=@orderDetailID) 
end
go
/*
exec spCalculatePrice 602
*/
--11
alter proc spTotalOrder
(@purchaseorderID int)
as
begin
	select p.PurchaseOrderID, SUM(UnitCost * Quantity) as Total 
	from PurchaseOrderDetails pd inner join PurchaseOrders p 
	on pd.PurchaseOrderID = p.PurchaseOrderID 

	where p.PurchaseOrderID = @purchaseorderID
	group by p.PurchaseOrderID
end 
go
/*
exec spTotalOrder 500
*/
go

--12

create proc spBiggestSupplier 
(@supID int) 
as
begin 
	select Company, s.LastName, s.State, COUNT(s.SupplierID) as NumberofProducts 
	from Products p inner join Suppliers s
	on p.SupplierID = s.SupplierID 
	group by s.Company, s.LastName, s.State  
end 


go
/*
exec spBiggestSupplier 303
*/
