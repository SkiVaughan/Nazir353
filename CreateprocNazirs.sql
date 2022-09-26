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
