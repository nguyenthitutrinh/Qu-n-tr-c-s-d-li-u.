use STORE
-----------------------------------------------------------------------------------

-- DUMP BẢNG NHÀ CUNG CẤP
go
create or alter procedure sp_insertIntoNhaCungCap
as
begin
	declare @NCC_ID CHAR(10),
			@NCC_Name NVARCHAR(100),
			@NCC_Ad NVARCHAR(100),
			@NCC_Phone CHAR(11),
			@NCC_Fax CHAR(11),
			@NCC_Web NVARCHAR(100), 
			@NCC_Email VARCHAR(50),
			@count int
	set @count = 1
	while @count <= 1000
	begin
		-- TẠO NCC_ID
		SET @NCC_ID = RIGHT('0000000000' + CAST(ABS(CHECKSUM(NEWID())) % 10000000000 AS VARCHAR(10)), 10)
		while exists (select 1 from NHACUNGCAP where NCC_ID = @NCC_ID)
		begin
			-- Nếu trùng thì tạo NCC_ID mới
			SET @NCC_ID = RIGHT('0000000000' + CAST(ABS(CHECKSUM(NEWID())) % 10000000000 AS VARCHAR(10)), 10)
		end
		-- TẠO NCC_Name
		set @NCC_Name = N'NCC' + CAST(@Count AS NVARCHAR(10))
		-- TẠO NCC_AD
		set @NCC_Ad = N'Địa chỉ ' + CAST(@Count AS NVARCHAR(10))
		-- TẠO NCC_PHONE, NCC_FAX, NCC_EMAIL, NCC_WEB
		set @NCC_Phone = '0' + cast(cast(rand() * 9000000000 + 1000000000 as bigint) as nvarchar(10))
		set @NCC_Fax = '0' + cast(cast(rand() * 9000000000 + 1000000000 as bigint) as nvarchar(10))
		set @NCC_Email = @NCC_Name + '@gmail.com'
		set @NCC_Web = 'www.' + @NCC_Name + '.vn'
		while	exists (select 1 from NHACUNGCAP where	NCC_Phone = @NCC_Phone or NCC_Fax = @NCC_Fax 
														or NCC_Email = @NCC_Email or NCC_Web = @NCC_Web) 
				or @NCC_Fax = @NCC_Phone
		begin
			set @NCC_Phone = '0' + cast(cast(rand() * 9999999999 as bigint) as nvarchar(10))
			set @NCC_Fax = '0' + cast(cast(rand() * 9000000000 + 1000000000 as bigint) as nvarchar(10))
		end
		INSERT INTO NhaCungCap (NCC_ID, NCC_Name, NCC_Ad, NCC_Phone, NCC_Fax,NCC_Web, NCC_Email)
        VALUES (@NCC_ID, @NCC_Name, @NCC_Ad, @NCC_Phone, @NCC_Fax,@NCC_Web, @NCC_Email)
		set @count = @count + 1
	end
end


-----------------------------------------------------------------------------------

-- DUMP BẢNG HOADONMUA
go
create or alter procedure sp_insertIntoHoaDonMua
as
begin
	declare @HDN_ID CHAR(10),
			@HDN_Time DATE,
			@HDN_TT NVARCHAR(20),
			@HDN_Thue TINYINT,
			@NCC_AcNo VARCHAR(14), 
			@NCC_Bname NVARCHAR(50),
			@NCC_BRName NVARCHAR(50),
			@NCC_ID CHAR(10),
			@count int
	set @count = 1
	while @count <= 1000
	begin
		-- TẠO HDN_ID
		set @HDN_ID = 'B' + RIGHT('000000000' + CAST(@count AS VARCHAR(9)), 9)
		-- TẠO HDN_TIME
		DECLARE @StartDate DATE = '2000-01-01'
		DECLARE @EndDate DATE = getdate()
		DECLARE @Days INT = DATEDIFF(DAY, @StartDate, @EndDate);
		SET @HDN_time = DATEADD(DAY, CAST(RAND() * @Days AS INT), @StartDate)
		-- TẠO HDN_TT
		SET @HDN_TT = CASE WHEN RAND() >= 0.5 THEN N'Tiền mặt' ELSE N'Chuyển khoản' END
		-- TẠO HDN_THUE
		SET @HDN_Thue = CASE WHEN RAND() >= 0.5 THEN 10 ELSE 8 END
		--TẠO NCC_ACNO
		if @HDN_TT = N'Tiền mặt'
		begin
			SET @NCC_AcNo = null
			set @NCC_Bname = null
			set @NCC_BRName = null
		end
		else 
		begin
			DECLARE @i int
			DECLARE @RandomNumber VARCHAR(14)
			set @RandomNumber = ''
			set @i = 1
			WHILE @i <= 14
			BEGIN
				SET @RandomNumber = @RandomNumber + CAST(FLOOR(RAND() * 10) AS VARCHAR(1))
				SET @i = @i + 1
			END
			SET @NCC_AcNo = @RandomNumber

			while exists (select 1 from HOADONMUA where NCC_AcNo = @NCC_AcNo)
			begin
				set @RandomNumber = ''
				set @i = 1
				WHILE @i <= 14
				BEGIN
					SET @RandomNumber = @RandomNumber + CAST(FLOOR(RAND() * 10) AS VARCHAR(1))
					SET @i = @i + 1
				END
				SET @NCC_AcNo = @RandomNumber
			end
			set @NCC_Bname = N'Ngân hàng' + cast(@count as varchar(1000))
			set @NCC_BRName = N'Chi nhánh' + cast(@count as varchar(1000))
		end;
		-- NCC_ID
		with CTE_NCC as (select	NCC_ID, ROW_NUMBER() OVER (ORDER BY NCC_ID) AS RowNum from NHACUNGCAP)

		select @NCC_ID = NCC_ID from CTE_NCC where RowNum = @count

		INSERT INTO HOADONMUA (HDN_ID, HDN_Time, HDN_TT, HDN_Thue, NCC_AcNo, NCC_Bname, NCC_BRName, NCC_ID)
        VALUES (@HDN_ID, @HDN_Time, @HDN_TT, @HDN_Thue, @NCC_AcNo, @NCC_Bname, @NCC_BRName, @NCC_ID)
        
		SET @Count = @Count + 1

	end
end


-----------------------------------------------------------------------------------

-- DUMP BẢNG HANGHOA

go
create or alter procedure sp_insertIntoHangHoa
as
begin
	declare @HH_ID CHAR(8),    
			@HH_Name NVARCHAR(50), 
			@DVT NVARCHAR(10),
			@GiaBanMacDinh DECIMAL(10,2),
			@count int
	set @count = 1
	while @count <= 1000
	begin
		-- TẠO HH_ID
		set @HH_ID = 'HH' + RIGHT('000000' + CAST(@Count AS VARCHAR(6)), 6)
		-- TẠO HH_NAME
		set @HH_Name = N'Hàng hóa ' + CAST(@Count AS NVARCHAR(10))
		-- TẠO DVT
		SET @DVT = CASE WHEN RAND() > 0.5 THEN N'cái' ELSE N'bộ' END
		-- TẠO GIABANMACDINH
		set @GiaBanMacDinh = CAST((RAND() * 1000000) + 200000 AS DECIMAL(10,2))
		INSERT INTO HANGHOA (HH_ID, HH_Name, DVT, GiaBanMacDinh)
        VALUES (@HH_ID, @HH_Name, @DVT, @GiaBanMacDinh)

		set @count = @count + 1
	end
end


-----------------------------------------------------------------------------------

-- DUMP BẢNG CHITIETHOADONMUA
go
create or alter procedure sp_insertIntoChiTietHoaDonMua
as
begin
	declare @HDN_ID CHAR(10),
			@HH_ID CHAR(8),
			@HDN_SoLuong INT,
			@DongiaNhap DECIMAL(10,2),
			@count int
	set @count = 1
	while @count <= 1000
	begin
		-- TẠO HDN_ID
		set @HDN_ID = 'B' + RIGHT('000000000' + CAST(@count AS VARCHAR(9)), 9)
		-- TẠO HH_ID
		set @HH_ID = 'HH' + RIGHT('000000' + CAST(@Count AS VARCHAR(6)), 6)
		-- TẠO HDN_SOLUONG
		set @HDN_SoLuong = FLOOR(RAND() * 50) + 1
		-- TAO DONGIANHAP
		select @DongiaNhap = GiaBanMacDinh/1.1 from HANGHOA
		where HH_ID = @HH_ID

		INSERT INTO CHITIETHOADONMUA (HDN_ID, HH_ID, HDN_SoLuong, DongiaNhap)
        VALUES (@HDN_ID, @HH_ID, @HDN_Soluong, @DonGiaNhap)
		set @count = @count + 1
	end
end


-----------------------------------------------------------------------------------

-- DUMP BẢNG CUSTOMER

go
create or alter procedure sp_insertIntoCustomer
as
begin
	declare @Cust_ID CHAR (10),
			@Cust_name NVARCHAR(100),
			@Cust_DDName NVARCHAR(50),
			@Cust_Ad NVARCHAR(100),
			@count int
	set @count = 1
	while @count <= 1000
	begin
		--TẠO CUST_ID
		SET @Cust_ID = RIGHT('0000000000' + CAST(ABS(CHECKSUM(NEWID())) % 10000000000 AS VARCHAR(10)), 10)
		while exists (select 1 from CUSTOMER where Cust_ID = @Cust_ID)
		begin
			-- Nếu trùng thì tạo CUST_ID mới
			SET @Cust_ID = RIGHT('0000000000' + CAST(ABS(CHECKSUM(NEWID())) % 10000000000 AS VARCHAR(10)), 10)
		end
		-- TẠO CUST_NAME
		SET @Cust_name = N'KH' + CAST(@Count AS NVARCHAR(10))
		-- TẠO CUST_DDNAME (ĐẠI DIỆN CÔNG TY MUA HÀNG)
		SET @Cust_DDName = N'Đại diện' + CAST(@Count AS NVARCHAR(10))
		-- TẠO CUST_AD
		SET @Cust_Ad = N'Địa chỉ ' + CAST(@Count AS NVARCHAR(10))
		INSERT INTO Customer (Cust_ID, Cust_Name, Cust_DDName, Cust_Ad)
        VALUES (@Cust_ID, @Cust_Name, @Cust_DDName, @Cust_Ad)
		set @count = @count + 1
	end
end

-----------------------------------------------------------------------------------

-- DUMP BẢNG HOADONBAN
go
create or alter procedure sp_insertIntoHoaDonBan
as
begin
	declare @HDB_ID CHAR(10),
			@Cust_ID CHAR(10),
			@HDB_Time DATE,               
			@HDB_TT NVARCHAR(20),             
			@HDB_Thue TINYINT,
			@Cust_AcNo VARCHAR(14),
			@count int
	set @count = 1
	while @count <= 1000
	begin
		-- TẠO HDB_ID
		SET @HDB_ID = 'S' + RIGHT('000000000' + CAST(@Count AS VARCHAR(9)), 9);
		-- TẠO CUST_ID
	
		with CTE_Cust as
		(
			select Cust_ID, ROW_NUMBER() over (order by Cust_ID) as rownum from CUSTOMER
		)
		select @Cust_ID = Cust_ID from CTE_Cust
		where rownum = @count
		-- TẠO HDB_TIME
		DECLARE @StartDate DATE = '2000-01-01'
		DECLARE @EndDate DATE = getdate()
		DECLARE @Days INT = DATEDIFF(DAY, @StartDate, @EndDate)
		SET @HDB_Time= DATEADD(DAY, CAST(RAND() * @Days AS INT), @StartDate);
		-- TẠO HDB_TT
		SET @HDB_TT = CASE WHEN RAND() > 0.5 THEN N'Tiền mặt' ELSE N'Chuyển khoản' END
		-- TẠO HDB_THUE
		SET @HDB_Thue = CASE WHEN RAND() >= 0.5 THEN 10 ELSE 8 END
		-- TẠO CUST_ACNO
		if @HDB_TT = N'Tiền mặt'
		begin
			SET @Cust_AcNo = null
		end
		else 
		begin
			DECLARE @i int
			DECLARE @RandomNumber VARCHAR(14)
			set @RandomNumber = ''
			set @i = 1
			WHILE @i <= 14
			BEGIN
				SET @RandomNumber = @RandomNumber + CAST(FLOOR(RAND() * 10) AS VARCHAR(1))
				SET @i = @i + 1
			END
			SET @Cust_AcNo = @RandomNumber

			while exists (select 1 from HOADONMUA where NCC_AcNo = @Cust_AcNo)
			begin
				set @RandomNumber = ''
				set @i = 1
				WHILE @i <= 14
				BEGIN
					SET @RandomNumber = @RandomNumber + CAST(FLOOR(RAND() * 10) AS VARCHAR(1))
					SET @i = @i + 1
				END
				SET @Cust_AcNo = @RandomNumber
			end
		end
		INSERT INTO HOADONBAN (HDB_ID, Cust_ID, HDB_Time, HDB_TT, HDB_Thue, Cust_AcNo)
        VALUES (@HDB_ID, @Cust_ID, @HDB_Time, @HDB_TT, @HDB_Thue, @Cust_AcNo)
		set @count = @count + 1
	end
end


-----------------------------------------------------------------------------------

--DUMP BẢNG CHITIETHOADONBAN


go
create or alter procedure sp_insertIntoChiTietHoaDonBan
as
begin
	declare @HDB_ID CHAR(10),                          
			@HH_ID CHAR(8),                            
			@HDB_Soluong INT,   
			@DongiaBan DECIMAL(10,2),
			@count int
	set @count = 1
	while @count <= 1000
	begin
		-- TẠO HDB_ID
		set @HDB_ID = 'S' + RIGHT('000000000' + CAST(@Count AS VARCHAR(9)), 9)
		-- TẠO HH_ID
		set @HH_ID = 'HH' + RIGHT('000000' + CAST(@Count AS VARCHAR(6)), 6)
		-- TẠO HDB_SOLUONG
		set @HDB_Soluong = FLOOR(RAND() * 50) + 1
		-- TẠO DONGIABAN
		select @DongiaBan = GiaBanMacDinh from HANGHOA
		where HH_ID = @HH_ID
		INSERT INTO CHITIETHOADONBAN (HDB_ID, HH_ID, HDB_Soluong, DonGiaBan)
        VALUES (@HDB_ID, @HH_ID, @HDB_Soluong, @DonGiaBan)
		set @count = @count + 1
	end
end

-------------------------------------------------------------------------------------------------------
go
create or alter proc sp_DumpSTORE
as
begin
	exec sp_insertIntoNhaCungCap
	exec sp_insertIntoHoaDonMua
	exec sp_insertIntoHangHoa
	exec sp_insertIntoChiTietHoaDonMua
	exec sp_insertIntoCustomer
	exec sp_insertIntoHoaDonBan
	exec sp_insertIntoChiTietHoaDonBan
end
go
exec sp_DumpSTORE

select * from NHACUNGCAP
select * from HOADONMUA
select * from CHITIETHOADONMUA
select * from HANGHOA

select * from CUSTOMER
select * from HOADONBAN
select * from CHITIETHOADONBAN

-----------------------------------------------------------------------------------

delete from HOADONMUA
delete from CHITIETHOADONMUA
delete from HANGHOA

delete from CUSTOMER
delete from HOADONBAN
delete from CHITIETHOADONBAN
delete from NHACUNGCAP



