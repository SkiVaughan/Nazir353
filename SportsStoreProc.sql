use SportsStoreDB;

--1 
Create proc spGetAllCategories
As
Begin
	Select * from Category
End

exec spGetAllCategories

--2a)

Create proc spGetCategoriesInDepartment
(@deptID int)
AS
Begin
	Select * from Category
	where DepartmentID = @deptID
End



--2b)
Create proc spGetCategoriesByDeptIDOptional
(@deptID int = null)
AS
Begin
	Select * from Category
	where DepartmentID = isnull(@deptID,departmentID)
End

--2c)
Create proc spGetCategoryByName
(@catName nvarchar(50))
As
Begin
	Select * from Category
	where name like '%'+@catName+'%'
end


--2d)
Create proc spGetCategoriesBetweenCatIDs
(@catID1 int, @catID2 int)
As
Begin
	Select * from Category
	where CategoryID >= @catID1
	and CategoryID <= @catID2

End

--2e)
Create proc spGetCategoryBetweenIDsOptional
(@catID1 int = null, @catID2 int = null)
as
Begin
	Select * from Category
	Where CategoryID >= isnull(@catID1, categoryID)
	and CategoryID <= isnull(@catID2, categoryID)
End

--3) 
Create proc spGetCategoryDetails
(@catID int)
As
Begin
	Select * from Category
	where CategoryID = @catID

end

execute spGetCategoryDetails 14

--4) --Student SHOULD DO	

--5)

--6)
Alter proc spGetProductsinCategory
(@catID int)
as 
begin
	Select Product.ProductID, name,
	Case
		When Len(description) <= 60
		Then Description
		Else SUBSTRING(Description, 1, 60)
		end as TruncatedDesc,
	Price, thumbnail, Image, PromoFront, PromoDept, CategoryID 
	
	from Product inner join ProductCategory
	--Need to use a fully qualifed name
	on Product.ProductID = ProductCategory.ProductID

	Where CategoryID = @catID

end

--execute spGetProductsinCategory 11


Create proc spGetProductsOnDeptPromo
AS
Begin
Select 
	Product.ProductID, name,
	Case
		When Len(description) <= 60
		Then Description
		Else SUBSTRING(Description, 1, 60)
		end as TruncatedDesc,
	Price, thumbnail, Image, PromoFront, PromoDept
	From Product

	where PromoDept = 1
end

execute spGetProductsOnDeptPromo


--8b)
Create proc spGetProductsOnDeptPromoByDeptID
(@deptID int)
AS
Begin
Select 
		p.ProductID, p.name,
	Case
		When Len(p.description) <= 60
		Then p.Description
		Else SUBSTRING(p.Description, 1, 60)
		end as TruncatedDesc,
	Price, thumbnail, Image, PromoFront, PromoDept

	From Product p inner join ProductCategory pc
		on P.ProductID = pc.ProductID
		inner join Category c 
		on pc.CategoryID = c.CategoryID

	Where DepartmentID = @deptID
		and PromoDept = 1
	end 

	exec spGetProductsOnDeptPromoByDeptID @deptID = 4

	--8c
	Create proc 
	(@deptID1 int = null, 
	@deptID2 int = null)
	As
	Begin
	Select 
		p.ProductID, p.name,
	Case
		When Len(p.description) <= 60
		Then p.Description
		Else SUBSTRING(p.Description, 1, 60)
		end as TruncatedDesc,
	Price, thumbnail, Image, PromoFront, PromoDept
	
	From Product p inner join ProductCategory pc
		on P.ProductID = pc.ProductID
		inner join Category c 
		on pc.CategoryID = c.CategoryID

	Where (DepartmentID >= isnull(@deptID1, departmentID)
		and DepartmentID <= isnull(@deptID2, departmentID))
		and PromoDept = 1

	End

	--9b)
Create proc spGetProductsOnFrontPromoWithPriceOptional
	(@price money = null)
	AS
Begin
Select 
	Product.ProductID, name,
	Case
		When Len(description) <= 60
		Then Description
		Else SUBSTRING(Description, 1, 60)
		end as TruncatedDesc,
	Price, thumbnail, Image, PromoFront, PromoDept
	From Product

	where price>= isnull(@price, price)
		and PromoFront = 1

end

--9c
Create proc spInsertCategory
(@deptID int,
@name nvarchar(100),
@desc nvarchar(1000),
@catID int out)
AS
Begin
	Insert into Category (DepartmentID, Name, Description)
	Values (@deptID, @name, @desc ) 
	set @catID = @@IDENTITY
end

declare @categoryID int

exec spInsertCategory
@deptID = 4,
@name = 'Test Category',
@desc = 'Test Description',
@catid = @categoryID out 

print @categoryID


Create proc spInsertProduct 
(@name varchar(200),
@desc nvarchar(max),
@Price Money, 
@pid int out)
As 
Begin
	Insert into Product (Name, Description, Price)
	Values (@name, @desc, @price)
	set @pid = @@IDENTITY


End


/*declare @prodID int 
exec spinsertProduct
@name ='Test Product',
@desc ='Test Description',
@price = 15.99,
@pid = @prodID out

print @prodID  */



--9e)
Create proc spCountProductsWithPriceGreaterThanValue
(@countOfProds int)
as
begin
	Select @countOfProds = Count(ProductID) from Product
	Where price >= 12.99
end


--10)
Create proc spShoppingCartAddItem
(@cartID char(36),
@prodID int,
@attributes nvarchar(100))
AS
Begin
	--update
	If EXISTS
	(Select CartID, ProductID from ShoppingCart
	where CartID=cartID and ProductID=@prodID)
	Update ShoppingCart
	set Quantity = Quantity +1, DateAdded = getdate()
	Where CartID=@cartID and ProductID=@prodID 
    --insert
	Else
	Insert into ShoppingCart
	--The order of these matter for it to run correctly 
	(CartID, ProductID, attributes, Quantity, DateAdded)
	Values (@cartID, @prodID, @attributes, 1, getdate())

End

--12)
Create proc spShoppingCartUpdateItem
(@cartid char(36),
@productid int,
@qty int)
AS
Begin
	if(@qty <= 0)
		delete from ShoppingCart
		Where cartID = @cartID and ProductID = @productid

	Else
		Update ShoppingCart
		set Quantity = @qty
		Where cartID = @cartid and ProductID = productid
End


ALter proc spShoppingCartGetTotalAmount
(@cartID char(36))
As
Begin
	Select CartID, SUM(Quantity*Price)

	From Product inner join ShoppingCart
	on Product.ProductID = ShoppingCart.ProductID
	Where cartID = @cartID

	end


	Create proc spCreateCustomerOrder
	(@custID uniqueidentifier,
	@cartid char(36))
	AS
	Begin

		-- Insert and order into the orders table 
			declare @orderID int
			Insert into Orders (CustomerID)
			Values (@custID)

			Set @orderID = @@identity  -- fetches the newly generated value
		--Insert all lineitems from the customers cart into the OrderDetail Table
		Insert into OrderDetail(OrderID, ProductID, ProductName, Quantity, UnitCost)
		Select @orderID, Product.ProductID, Name, Quantity, Price
		From Product inner join ShoppingCart
		On Product.ProductID = ShoppingCart.ProductID
		Where CartID = @cartid
		--Delete items that belong to the customers cart 
		Delete from ShoppingCart
		Where cartID = @cartID
		--Print the OrderID as confirmation that order has been placed
		Select @orderID 


	End
