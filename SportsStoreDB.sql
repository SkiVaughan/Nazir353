Create database SportsStoreDB
go

Use SportsStoreDB
go

Create table Department
(
	DepartmentID int primary key identity(1,1),
	Name nvarchar(100) not null,
	Description nvarchar (1000)
)
go

Create table Category
(
	CategoryID int primary key identity(1,1),
	DepartmentID int not null,
	Name nvarchar(100) not null,
	Description nvarchar(1000),
	--Department is a FK column follow the commands below to add to table 
	foreign key (departmentID) references Department(departmentID)
)
go
Create table Product
(
	ProductID int primary key identity(1,1),
	Name nvarchar(100) not null,
	Description nvarchar(1000) not null,
	Price money not null,
	Thumbnail nvarchar(20) default('genericthumb.png'),
	Image nvarchar(20) default('genericimage.png'),
	PromoFront bit default(0),
	PromoDept bit default(0)
)
go
Create Table ProductCategory
(
	ProductID int not null,
	CategoryID int not null,
	primary key (ProductID, CategoryID),
	Foreign key (productID) references Product(productID),
	Foreign key (CategoryID) references Category(CategoryID)
)
go
Create Table ShoppingCart
(
	CartID char(36) not null,
	ProductID int not null references Product(ProductID),
	Attributes nvarchar(10),
	Quantity int not null,
	DateAdded DateTime2(7) default(getdate()),
	primary key(CartID, ProductID),


)
go

Create table Orders
(
	OrderID int not null primary key identity(1,1),
	CustomerID uniqueidentifier not null,
	DateCreated DateTime2(7) default(getdate()),
	DateShipped DateTime2(7),
	Verified bit default(0),
	Completed bit default(0),
	Comments nvarchar(max),
	Canceled bit default(0),
	ShippingAddress nvarchar(max) not null,
	Status int default(0),
	Reference nvarchar(100),
	AuthCode nvarchar(100),
)

Create table OrderDetail
(
	OrderID int not null,
	ProductID int not null,
	ProductName nvarchar(100) not null,
	Quantity int not null,
	UnitCost money not null,
	Subtotal as (quantity * UnitCost),

	Constraint fk_01 Foreign Key(OrderID) references Orders(OrderID),
	Constraint fk_02 Foreign Key(ProductID) references Product(ProductID),
	Primary key (OrderID, ProductID)
)
go
