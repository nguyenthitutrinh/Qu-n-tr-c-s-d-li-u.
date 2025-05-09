use STOREDKT

--thêm các cột mã hóa 
Alter table CUSTOMER 
add mahoa_Cust_ID varbinary(max)
Alter table NHACUNGCAP 
add mahoa_NCC_ID varbinary(max)
Alter table HOADONBAN 
add mahoa_Cust_AcNo varbinary(max)
Alter table HOADONMUA  
add mahoa_NCC_AcNo varbinary(max)
Alter table HOADONBAN 
add mahoa_Cust_ID varbinary(max)
Alter table HOADONMUA  
add mahoa_NCC_ID varbinary(max)

-- BẢNG CUSTOMER 
go
CREATE OR ALTER PROCEDURE sp_MaHoaDuLieuKhachHang
AS
BEGIN
    DECLARE @Passphrase NVARCHAR(50) = 'YourStrongPassphrase'
    
    -- Mã hóa tất cả các giá trị trong cột Cust_ID
    UPDATE CUSTOMER
    SET mahoa_Cust_ID = EncryptByPassPhrase(@Passphrase, Cust_ID)
    WHERE Cust_ID IS NOT NULL
    
    -- Chỉ trả về các cột đã mã hóa
    SELECT mahoa_Cust_ID
    FROM CUSTOMER
    WHERE Cust_ID IS NOT NULL
END
GO


-- BẢNG NHACUNGCAP
CREATE OR ALTER PROCEDURE sp_MaHoaDuLieuNhaCungCap
AS
BEGIN
    DECLARE @Passphrase NVARCHAR(50) = 'YourStrongPassphrase'
    
    -- Mã hóa tất cả các giá trị trong cột NCC_ID
    UPDATE NHACUNGCAP
    SET mahoa_NCC_ID = EncryptByPassPhrase(@Passphrase, NCC_ID)
    WHERE NCC_ID IS NOT NULL
    
    -- Chỉ trả về các cột đã mã hóa
    SELECT mahoa_NCC_ID
    FROM NHACUNGCAP
    WHERE NCC_ID IS NOT NULL
END
GO


-- BẢNG HOADONBAN 
CREATE OR ALTER PROCEDURE sp_MaHoaDuLieuHoaDonBan
AS
BEGIN
    DECLARE @Passphrase NVARCHAR(50) = 'YourStrongPassphrase'
    
    -- Mã hóa tất cả các giá trị trong cột Cust_AcNo
    UPDATE HOADONBAN
    SET mahoa_Cust_AcNo = EncryptByPassPhrase(@Passphrase, Cust_AcNo)
    WHERE Cust_AcNo IS NOT NULL
	UPDATE HOADONBAN
    SET mahoa_Cust_ID = EncryptByPassPhrase(@Passphrase, Cust_ID)
    
    -- Chỉ trả về các cột đã mã hóa
    SELECT mahoa_Cust_AcNo, mahoa_Cust_ID
    FROM HOADONBAN
END
GO

-- BẢNG HOADONMUA 
CREATE OR ALTER PROCEDURE sp_MaHoaDuLieuHoaDonMua
AS
BEGIN
    DECLARE @Passphrase NVARCHAR(50) = 'YourStrongPassphrase'
    
    -- Mã hóa tất cả các giá trị trong cột NCC_AcNo
    UPDATE HOADONMUA
    SET mahoa_NCC_AcNo = EncryptByPassPhrase(@Passphrase, NCC_AcNo)
    WHERE NCC_AcNo IS NOT NULL

	UPDATE HOADONMUA
    SET mahoa_NCC_ID = EncryptByPassPhrase(@Passphrase, NCC_ID)
    
    -- Chỉ trả về các cột đã mã hóa
    SELECT mahoa_NCC_AcNo, mahoa_NCC_ID
    FROM HOADONMUA
END
GO


-- Gọi thủ tục mã hóa dữ liệu trong bảng CUSTOMER
EXEC sp_MaHoaDuLieuKhachHang

-- Gọi thủ tục mã hóa dữ liệu trong bảng NHACUNGCAP
EXEC sp_MaHoaDuLieuNhaCungCap

-- Gọi thủ tục mã hóa dữ liệu trong bảng HOADONBAN
EXEC sp_MaHoaDuLieuHoaDonBan

-- Gọi thủ tục mã hóa dữ liệu trong bảng HOADONMUA
EXEC sp_MaHoaDuLieuHoaDonMua









-- giải mã bảng customer 

GO 
CREATE OR ALTER PROCEDURE sp_giaimakhachhang
AS
BEGIN
    DECLARE @Passphrase NVARCHAR(50) = 'YourStrongPassphrase'
    
    SELECT 
		Cust_ID,
		mahoa_Cust_ID,
		CAST(DECRYPTBYPASSPHRASE(@Passphrase, mahoa_Cust_ID) AS char(10)) AS Cust_ID_giaima
    FROM CUSTOMER
    WHERE Cust_ID IS NOT NULL  -- Thêm điều kiện để lọc các bản ghi có giá trị mã hóa
END
GO

-- BẢNG NHACUNGCAP 
CREATE OR ALTER PROCEDURE sp_giaimanhacungcap
AS
BEGIN
    DECLARE @Passphrase NVARCHAR(50) = 'YourStrongPassphrase'
    
    SELECT 
		NCC_ID,
		mahoa_NCC_ID,
        CAST(DECRYPTBYPASSPHRASE(@Passphrase, mahoa_NCC_ID) AS char(10)) AS NCC_ID_giaima
    FROM NHACUNGCAP
    WHERE NCC_ID IS NOT NULL  -- Thêm điều kiện để lọc các bản ghi có giá trị mã hóa
END

GO



--BẢNG HOADONBAN
CREATE OR ALTER PROCEDURE sp_giaimahoadonban
AS
BEGIN
    DECLARE @Passphrase NVARCHAR(50) = 'YourStrongPassphrase'
    
    SELECT 
        Cust_Acno,
		mahoa_Cust_AcNo,
		CAST(DECRYPTBYPASSPHRASE(@Passphrase, mahoa_Cust_AcNo) AS char(14)) AS Cust_AcNo_giaima,
		CAST(DECRYPTBYPASSPHRASE(@Passphrase, mahoa_Cust_ID) AS char(10)) AS Cust_ID_giaima

    FROM HOADONBAN
END
GO



--BẢNG HOADONMUA 

CREATE OR ALTER PROCEDURE sp_giaimahoadonmua 
AS
BEGIN
    DECLARE @Passphrase NVARCHAR(50) = 'YourStrongPassphrase'
    
    SELECT 
        NCC_AcNo,
		mahoa_NCC_AcNo,
		CAST(DECRYPTBYPASSPHRASE(@Passphrase, mahoa_NCC_AcNo) AS char(14)) AS NCC_AcNo_giaima
    FROM HOADONMUA
    WHERE mahoa_NCC_AcNo IS NOT NULL -- Thêm điều kiện để lọc các bản ghi có giá trị mã hóa
END
GO


--
EXEC sp_giaimakhachhang
EXEC sp_giaimanhacungcap
EXEC sp_giaimahoadonban
EXEC sp_giaimahoadonmua


