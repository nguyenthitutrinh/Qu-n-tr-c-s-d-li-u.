USE master;  
GO  

IF DB_ID (N'STORE') is not null
DROP DATABASE STORE;  
GO  

CREATE DATABASE STORE  
GO

USE STORE
GO

-- Tạo bảng KHÁCH HÀNG
CREATE TABLE CUSTOMER
(
	Cust_ID CHAR (10) PRIMARY KEY not null,
	Cust_name NVARCHAR(100) not null,
	Cust_DDName NVARCHAR(50),
	Cust_Ad NVARCHAR(100) not null
)
go
-- Tạo bảng NHÀ CUNG CẤP
CREATE TABLE NHACUNGCAP
(
	NCC_ID CHAR(10) not null PRIMARY KEY,
	NCC_Name NVARCHAR(100) not null,
	NCC_Ad NVARCHAR(100) not null,
	NCC_Phone CHAR(11) not null UNIQUE,
	NCC_Fax CHAR(11) UNIQUE,
	NCC_Web NVARCHAR(100),
	NCC_Email VARCHAR(50) not null UNIQUE
)
go
-- Tạo bảng HÀNG HÓA
CREATE TABLE HANGHOA 
(
    HH_ID CHAR(8) PRIMARY KEY not null,           
    HH_Name NVARCHAR(50) not null,      
    DVT NVARCHAR(10) not null,
	GiaBanMacDinh DECIMAL(10,2) null
)
go
-- Tạo bảng HÓA ĐƠN BÁN
CREATE TABLE HOADONBAN 
(
    HDB_ID CHAR(10) PRIMARY KEY not null,
	Cust_ID CHAR(10),
    HDB_Time DATE not null,               
    HDB_TT NVARCHAR(20) not null,             
    HDB_Thue TINYINT not null,
	Cust_AcNo VARCHAR(14) not null UNIQUE,
	FOREIGN KEY (Cust_ID) REFERENCES CUSTOMER(Cust_ID) ON DELETE CASCADE ON UPDATE CASCADE
)
go
-- Tạo bảng CHI TIẾT HÓA ĐƠN BÁN
CREATE TABLE CHITIETHOADONBAN 
(
    HDB_ID CHAR(10),                          
    HH_ID CHAR(8),                            
    HDB_Soluong INT not null CHECK (HDB_Soluong >0),   
	DongiaBan DECIMAL(10,2) null CHECK (DongiaBan >0),
    PRIMARY KEY (HDB_ID, HH_ID),              
    FOREIGN KEY (HDB_ID) REFERENCES HOADONBAN(HDB_ID) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (HH_ID) REFERENCES HANGHOA(HH_ID) ON DELETE CASCADE ON UPDATE CASCADE
)

-- Tạo bảng HÓA ĐƠN MUA
CREATE TABLE HOADONMUA 
(
	HDN_ID CHAR(10) PRIMARY KEY not null,
	HDN_Time DATE not null,
	HDN_TT NVARCHAR(20) not null,
	HDN_Thue TINYINT not null,
	NCC_AcNo VARCHAR(14) not null,
	NCC_Bname NVARCHAR(50) not null,
	NCC_BRName NVARCHAR(50),
	NCC_ID CHAR(10),
	FOREIGN KEY (NCC_ID) REFERENCES NHACUNGCAP(NCC_ID) ON DELETE CASCADE ON UPDATE CASCADE
)

-- Tạo bảng CHI TIẾT HÓA ĐƠN MUA
CREATE TABLE CHITIETHOADONMUA 
(	
	HDN_ID CHAR(10),
	HH_ID CHAR(8),
	HDN_SoLuong INT not null CHECK (HDN_SoLuong >0) ,
	DongiaNhap DECIMAL(10,2) not null CHECK (DongiaNhap >0),
	PRIMARY KEY (HDN_ID, HH_ID),
	FOREIGN KEY (HDN_ID) REFERENCES HOADONMUA(HDN_ID) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (HH_ID) REFERENCES HANGHOA(HH_ID) ON DELETE NO ACTION ON UPDATE NO ACTION
)

go
CREATE TRIGGER CapNhatGiaBanMacDinh
ON CHITIETHOADONMUA
AFTER INSERT, UPDATE
AS
BEGIN
    WITH LatestPrice AS (
        SELECT 
            HH_ID,
            MAX(HDN_Time) AS LatestTime,
            DongiaNhap * 1.1 AS NewGiaBanMacDinh
        FROM CHITIETHOADONMUA
        INNER JOIN HOADONMUA ON CHITIETHOADONMUA.HDN_ID = HOADONMUA.HDN_ID
		WHERE HH_ID IN (SELECT HH_ID FROM inserted)
        GROUP BY HH_ID, DongiaNhap
    )
    UPDATE HANGHOA
    SET GiaBanMacDinh = LP.NewGiaBanMacDinh
    FROM HANGHOA AS HH
    INNER JOIN LatestPrice AS LP ON HH.HH_ID = LP.HH_ID;
END;
GO
-- Trigger 1: Cập nhật giá bán cho các chi tiết hóa đơn bán mới
CREATE TRIGGER CapNhatGiaBan
ON CHITIETHOADONBAN 
AFTER INSERT, UPDATE
AS
BEGIN
    UPDATE CHITIETHOADONBAN
    SET DongiaBan = (
        SELECT GiaBanMacDinh
        FROM HANGHOA
        WHERE HH_ID = CHITIETHOADONBAN.HH_ID
    )
    WHERE HDB_ID IN (SELECT HDB_ID FROM CHITIETHOADONBAN WHERE HDB_ID IN (SELECT HDB_ID FROM inserted));
END;
go