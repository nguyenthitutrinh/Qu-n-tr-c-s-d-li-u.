use STOREDKT

-----------------------------------------------  khách hàng ----------------------------------------------------------
go
-- Update bảng khách hàng - done
create or alter procedure updateCustomers 
	@Cust_ID varbinary(max),
	@Cust_name NVARCHAR(100),
	@Cust_Ad NVARCHAR(100)
as
begin
	DECLARE @Passphrase NVARCHAR(50) = 'YourStrongPassphrase';	
	declare @Cust_id_new char(14) =  CAST(DECRYPTBYPASSPHRASE(@Passphrase, @Cust_id) AS char(14))
	update CUSTOMER
	set Cust_name = @Cust_name, Cust_Ad = @Cust_Ad, Cust_ID = @Cust_id_new, mahoa_Cust_id = @Cust_ID
	where mahoa_Cust_ID = @Cust_ID
end
go

declare @abc varbinary(max) 
set @abc = EncryptByPassPhrase('YourStrongPassphrase','S000000001')

exec updateCustomers
	@Cust_ID = @abc,
	@cust_name = '--abc',
	@cust_ad = 'abc'

-- Read bảng khách hàng - done
GO
create or alter procedure selectCustomers
	@input varchar(100)
as
begin
	select * from CUSTOMER
	where mahoa_Cust_ID = @input 
end
go

exec selectCustomers
@input = '00104687878'

------------------------------------------------------- Nhà cung cấp ------------------------------------------------------
-- Update nhà cung cấp - done
go
create or alter procedure updateNCC
	@NCC_ID varbinary(max), 
	@NCC_Name NVARCHAR(100),
	@NCC_Ad NVARCHAR(100),
	@NCC_Phone CHAR(11),
	@NCC_Fax CHAR(11),
	@NCC_Web NVARCHAR(100),
	@NCC_Email VARCHAR(50)
as
begin
	DECLARE @Passphrase NVARCHAR(50) = 'YourStrongPassphrase';	
	declare @NCC_ID_new char(14) =  CAST(DECRYPTBYPASSPHRASE(@Passphrase, @NCC_ID) AS char(14))
	UPDATE NHACUNGCAP
    SET 
		NCC_ID = @NCC_ID_new,
        NCC_Name = @NCC_Name,
        NCC_Ad = @NCC_Ad,
        NCC_Phone = @NCC_Phone,
        NCC_Fax = @NCC_Fax,
        NCC_Web = @NCC_Web,
        NCC_Email = @NCC_Email,
		mahoa_NCC_id = @NCC_ID
    WHERE mahoa_NCC_id = @NCC_ID
end
go

-- Read nhà cung cấp - done

go
create or alter procedure selectNCC
	@input varbinary(max)
as
begin
	select * from NHACUNGCAP
    WHERE mahoa_NCC_ID = @input 
end
go

exec selectNCC
	@input = '0004741782gu'


select * from HANGHOA
go
----------------------------------------------------- bảng sản phẩm ------------------------------------------------

-- Update sản phẩm - done
create or alter procedure updateProduct
	@HH_ID CHAR(8),           
    @HH_Name NVARCHAR(50),      
    @DVT NVARCHAR(10)
as
begin
	update HANGHOA
	set HH_Name = @HH_Name, DVT = @DVT
	where HH_ID = @HH_ID
end
go

-- Read sản phẩm - done
create or alter procedure selectProduct
	@input nvarchar(100)
as
begin
	select HANGHOA.*, DongiaNhap from 
	HANGHOA inner join CHITIETHOADONMUA on HANGHOA.HH_ID = CHITIETHOADONMUA.HH_ID
	where HANGHOA.HH_ID = @input or HANGHOA.HH_Name like @input
end
go

-------------------------------------------------------- bảng hóa đơn bán --------------------------------------------------------

go
-- Cập nhật hóa đơn bán - done
create or alter procedure updateHoaDonBan 
	@HDB_ID char(10),
    @HDB_TT NVARCHAR(20),    
    @HDB_Thue TINYINT,
    @Cust_AcNo varbinary(max),
	@Cust_DDname NVARCHAR(50)
as
begin
	DECLARE @Passphrase NVARCHAR(50) = 'YourStrongPassphrase';	
	declare @Cust_AcNo_new char(14) =  CAST(DECRYPTBYPASSPHRASE(@Passphrase, @Cust_AcNo) AS char(14))

	update HOADONBAN
	set 
		HDB_TT = @HDB_TT,
		HDB_Thue = @HDB_Thue,
		Cust_DDname = @Cust_DDname,
		Cust_AcNo = @Cust_AcNo_new,
		mahoa_Cust_Acno = @Cust_AcNo
	where HDB_ID = @HDB_ID 
end
go
-- Read hóa đơn bán - done
select * from HOADONBAN
go
create or alter procedure selectHoaDonBan
	@input varbinary(max)
as
begin
	DECLARE @Passphrase NVARCHAR(50) = 'YourStrongPassphrase';
	select * from HOADONBAN
	where mahoa_Cust_ID = @input or HDB_ID = cast(DECRYPTBYPASSPHRASE(@Passphrase, @input) as char(10))
end
go

-- bảng chi tiết hóa đơn bán - update - don
go
create or alter procedure updateChiTietHoaDonBan
	@HH_ID CHAR(8),                            
	@HDB_Soluong INT
as
begin
	declare @DonGiaBan decimal(10,2)
	select @DonGiaBan = GiaBanMacDinh from HANGHOA
	where HH_ID = @HH_ID
	update CHITIETHOADONBAN
	set HH_ID = @HH_ID, HDB_Soluong = @HDB_Soluong, DongiaBan = @DonGiaBan
end

-- bảng hóa đơn mua 
-- select - done
go
create or alter procedure selectHoaDonMua
	@input varbinary(max)
as
begin
	DECLARE @Passphrase NVARCHAR(50) = 'YourStrongPassphrase';
	select * from HOADONMUA
	where HDN_ID = cast(DECRYPTBYPASSPHRASE(@Passphrase, @input) as char(10)) or NCC_ID = @input
end
go

select * from HOADONMUA

-- update - done

go
create or alter procedure updateHoaDonMua
	@HDN_ID CHAR(10),
	@HDN_TT NVARCHAR(20),
	@HDN_Thue TINYINT,
	@NCC_AcNo varbinary(max), 
	@NCC_Bname NVARCHAR(50),
	@NCC_BRName NVARCHAR(50)
as
begin
	DECLARE @Passphrase NVARCHAR(50) = 'YourStrongPassphrase';
	declare @NCC_AcNo_new varchar(14) = CAST(DECRYPTBYPASSPHRASE(@Passphrase, @NCC_AcNo) as VARCHAR(14))

	update HOADONMUA
	set
		HDN_TT = @HDN_TT,
		HDN_Thue = @HDN_Thue,
		NCC_Bname = @NCC_Bname,
		NCC_BRName = @NCC_BRName,
		NCC_AcNo = @NCC_AcNo_new,
		mahoa_NCC_Acno = @NCC_AcNo
	where HDN_ID = @HDN_ID
end
-- bảng chi tiết hóa đơn mua - update


go
select * from CHITIETHOADONMUA
go 
create or alter procedure updateChiTietHoaDonMua
	@HDN_ID CHAR(10),
	@HDN_SoLuong INT,
	@DongiaNhap DECIMAL(10,2),
	@HH_ID char(10)
as
begin
	update CHITIETHOADONMUA
	set 
		HH_ID = @HH_ID,
		HDN_SoLuong = @HDN_SoLuong,
		DongiaNhap = @DongiaNhap
	where HDN_ID = @HDN_ID
end






