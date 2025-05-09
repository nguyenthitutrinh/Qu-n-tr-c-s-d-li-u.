use STORE

--1.THỦ TỤC THÊM NHÀ CUNG CẤP MỚI VÀO BẢNG NHÀ CUNG CẤP
go
create or alter procedure sp_XuLyNhaCungCap
	@NCC_ID char(10),
	@NCC_Name NVARCHAR(100),
	@NCC_Ad NVARCHAR(100),
	@NCC_Phone CHAR(11),
	@NCC_Fax CHAR(11),
	@NCC_Web NVARCHAR(100),
	@NCC_Email VARCHAR(50),
	@ID char(10) output
as
begin
	declare @count int
	begin try 
		if @NCC_ID = ''	
		begin
			select @count = count(*) + 1 from NHACUNGCAP
			SET @NCC_ID = RIGHT('0000000000' + CAST(ABS(CHECKSUM(NEWID())) % 10000000000 AS VARCHAR(10)), 10)
			while exists (select 1 from NHACUNGCAP where NCC_ID = @NCC_ID)
			begin
				-- Nếu trùng thì tạo NCC_ID mới
				SET @NCC_ID = RIGHT('0000000000' + CAST(ABS(CHECKSUM(NEWID())) % 10000000000 AS VARCHAR(10)), 10)
			end
			insert into NHACUNGCAP
			(NCC_ID, NCC_Name, NCC_Ad, NCC_Phone, NCC_Fax, NCC_Web, NCC_Email)
			values
			(@NCC_ID, @NCC_Name, @NCC_Ad, @NCC_Phone, @NCC_Fax, @NCC_Web, @NCC_Email)
			set @ID = @NCC_ID 
		end
		else 
		begin
			set @ID = @NCC_ID 
		end
	end try
	begin catch
		print N'Lỗi trong quá trình thêm dữ liệu nhà cung cấp: ' + ERROR_MESSAGE()
	end catch
end
------------------------------------------------------------
--2.	THỦ TỤC THÊM THÔNG TIN HÓA ĐƠN MỚI KHI MUA HÀNG VÀO BẢNG HOADONMUA
go
create or alter procedure sp_XuLyHoaDonMua
	@HDN_TT NVARCHAR(20),
	@HDN_Thue TINYINT,
	@NCC_AcNo VARCHAR(14), 
	@NCC_Bname NVARCHAR(50),
	@NCC_BRName NVARCHAR(50),
	@NCC_ID CHAR(10),
	@ID char(10) output
as
begin
	declare @HDN_ID CHAR(10) 
	declare @count int
	declare @HDN_Time DATE
	begin try	
		select @count = count(*) + 1 from HOADONMUA
		set @HDN_ID = 'B' + right('000000000' + cast(@count as varchar(100)),9)
		set @HDN_Time = GETDATE()
		INSERT INTO HOADONMUA (HDN_ID, HDN_Time, HDN_TT, HDN_Thue, NCC_AcNo, NCC_Bname, NCC_BRName, NCC_ID)
        VALUES (@HDN_ID, @HDN_Time, @HDN_TT, @HDN_Thue, @NCC_AcNo, @NCC_Bname, @NCC_BRName, @NCC_ID); 
		set @ID = @HDN_ID 
	end try
	begin catch
		print N'Lỗi trong quá trình thêm dữ liệu hóa đơn mua: ' + ERROR_MESSAGE()
	end catch
end
------------------------------------------------------------
--3.	THỦ TỤC THỰC HIỆN THÊM HÀNG HÓA VÀO BẢNG HANGHOA
go
create or alter procedure sp_XuLyThemHangHoa
	--HANGHOA
	@HH_ID CHAR(8),           
    @HH_Name NVARCHAR(50),      
    @DVT NVARCHAR(10),
	--CHITIETHOADONMUA
	@HDN_ID CHAR(10),
	@HDN_SoLuong INT,
	@DongiaNhap DECIMAL(10,2),
	@check bit 
as
begin
	begin try
		declare @count int
		declare	@GiaBanMacDinh DECIMAL(10,2)
		if @check = 1
		begin
			select @count = count(*) + 1 from HANGHOA
			set @HH_ID = 'HH' + RIGHT('000000' + CAST(@Count AS VARCHAR(6)), 6)
			set @GiaBanMacDinh = @DongiaNhap * 1.1
			INSERT INTO HANGHOA (HH_ID, HH_Name, DVT, GiaBanMacDinh)
			VALUES (@HH_ID, @HH_Name, @DVT, @GiaBanMacDinh)

			INSERT INTO CHITIETHOADONMUA (HDN_ID, HH_ID, HDN_SoLuong, DongiaNhap)
			VALUES (@HDN_ID, @HH_ID, @HDN_Soluong, @DonGiaNhap)
		end
		else 
		begin
			INSERT INTO CHITIETHOADONMUA (HDN_ID, HH_ID, HDN_SoLuong, DongiaNhap)
			VALUES (@HDN_ID, @HH_ID, @HDN_Soluong, @DonGiaNhap)
		end
	end try
	begin catch
		print N'Lỗi trong quá trình thêm dữ liệu: ' + ERROR_MESSAGE()
	end catch
end

------------------------------------------------------------------------
--4.	TRIGGER TỰ ĐỘNG CẬP NHẬT GIÁ MỚI CHO HÀNG HÓA MỚI NHẬP
go
create or alter trigger XuLyCapNhatGiaBanMacDinh
on CHITIETHOADONMUA
after insert, update
as
begin
	declare @giamoi decimal(10,2)
    declare @id char(10)
	select @giamoi = DongiaNhap, @id = HH_ID from CHITIETHOADONMUA
	where HDN_ID in (select HDN_ID inserted)

	update HANGHOA
	set GiaBanMacDinh = @giamoi * 1.1
	where HH_ID = @id
end
go
-----------------------------------------------------------------------
--KIỂM TRA:
declare @ID char(10)

exec sp_XuLyNhaCungCap
	@NCC_ID = '',
	@NCC_Name = 'NCCdemo1',
	@NCC_Ad = N'Địa chỉ demo1',
	@NCC_Phone = '06018265109',
	@NCC_Fax = '06018265999',
	@NCC_Web = 'www.NCCdemo1.vn',
	@NCC_Email = 'NCCdemo1@gmail.com',
	@ID = @ID output
print(@ID)

declare @IDabc char(10)
exec sp_XuLyHoaDonMua
	@HDN_TT = 'Tiền mặt',
	@HDN_Thue = '8',
	@NCC_AcNo = null,
	@NCC_Bname = null,
	@NCC_BRName = null,
	@NCC_ID = @ID,
	@ID = @IDabc output
print(@IDabc)



exec sp_XuLyThemHangHoa
	@HH_ID = 'HH000001', 
    @HH_Name = 'Hàng hóa 1',
    @DVT = 'bộ',
	@HDN_ID = @IDabc,
	@HDN_SoLuong = 10,
	@DongiaNhap = 50000,
	@check = 0
select * from HOADONMUA
select * from NHACUNGCAP
select * from HOADONMUA
select * from CHITIETHOADONMUA
select * from HANGHOA

-- 5.	THỦ TỤC THÊM KHÁCH HÀNG MỚI VÀO BẢNG CUSTOMER
-- 6.	THỦ TỤC XỬ LÝ KHI BÁN HÀNG HÓA TRÊN BẢNG HOADONBAN & CHITIETHOADONBAN
go
create or alter procedure sp_XuLyCustomer
	@Cust_ID CHAR (10),
	@Cust_name NVARCHAR(100),
	@Cust_DDName NVARCHAR(50),
	@Cust_Ad NVARCHAR(100),
	@ID char(10) output
as
begin select * from CUSTOMER
	declare @count int
	begin try 
		if @Cust_ID = ''
		begin
			select @count = count(*) + 1 from CUSTOMER
			SET @Cust_ID = RIGHT('0000000000' + CAST(ABS(CHECKSUM(NEWID())) % 10000000000 AS VARCHAR(10)), 10)
			while exists (select 1 from CUSTOMER where Cust_ID = @Cust_ID)
			begin
				-- Nếu trùng thì tạo CUST_ID mới
				SET @Cust_ID = RIGHT('0000000000' + CAST(ABS(CHECKSUM(NEWID())) % 10000000000 AS VARCHAR(10)), 10)
			end
			INSERT INTO Customer (Cust_ID, Cust_Name, Cust_DDName, Cust_Ad)
			VALUES (@Cust_ID, @Cust_Name, @Cust_DDName, @Cust_Ad)
			set @ID = @Cust_ID 
		end
		else 
		begin
			set @ID = @Cust_ID 
		end
	end try
	begin catch
		print N'Lỗi trong quá trình thêm dữ liệu khách hàng : ' + ERROR_MESSAGE()
	end catch
end

go
create or alter procedure sp_XuLyHoaDonBan
    @Cust_ID CHAR(10),
    @HDB_TT NVARCHAR(20),             
    @HDB_Thue TINYINT,
    @Cust_AcNo VARCHAR(14),
	@ID char(10) output
as
begin
    declare @HDB_Time DATE,              
			@HDB_ID CHAR(10),
			@count int
	begin try	
		select * from HOADONBAN
		select @count = count(*) + 1 from HOADONMUA
		set @HDB_ID = 'S' + right('000000000' + cast(@count as varchar(100)),9) 
		set @HDB_Time = GETDATE()
		INSERT INTO HOADONBAN (HDB_ID, Cust_ID, HDB_Time, HDB_TT, HDB_Thue, Cust_AcNo)
        VALUES (@HDB_ID, @Cust_ID, @HDB_Time, @HDB_TT, @HDB_Thue, @Cust_AcNo)
		set @ID = @HDB_ID
	end try
	begin catch
		print N'Lỗi trong quá trình thêm dữ liệu hóa đơn bán: ' + ERROR_MESSAGE()
	end catch
end

go
create or alter procedure sp_XuLyBanHang
	@HDB_ID CHAR(10),                          
	@HH_ID CHAR(8),                            
	@HDB_Soluong INT
as
begin
	declare @count int, @DonGiaBan decimal(10,2)
	begin try
		select @DonGiaBan = GiaBanMacDinh from HANGHOA
		where HH_ID = @HH_ID
		INSERT INTO CHITIETHOADONBAN (HDB_ID, HH_ID, HDB_Soluong, DonGiaBan)
        VALUES (@HDB_ID, @HH_ID, @HDB_Soluong, @DonGiaBan)
	end try
	begin catch
		print N'Lỗi trong quá trình thêm dữ liệu vào bảng CHITIETHOADONBAN'
	end catch
end
--------------------------------------------------------------------------------------------
--KIỂM TRA:
declare @ID_test char(10)
exec sp_XuLyCustomer
	@Cust_ID = 'COM0000001',
	@Cust_name = 'KH1',
	@Cust_DDName = 'Đại diện 1',
	@Cust_Ad = 'Địa chỉ 1',
	@ID = @ID_test output
print(@ID_test)
----------------------------------
declare @ID_testabc char(10)
exec sp_XuLyHoaDonBan
	@Cust_ID = @ID_test,
    @HDB_TT = 'Tiền mặt',             
    @HDB_Thue = '8',
    @Cust_AcNo = null,
	@ID = @ID_testabc output
print(@ID_testabc)
---------------------------
exec sp_XuLyBanHang
	@HDB_ID = @ID_testabc,                          
	@HH_ID = 'HH000001',                            
	@HDB_Soluong = 10

select * from CUSTOMER
select * from HOADONBAN
select * from CHITIETHOADONBAN
select * from HANGHOA

-- 7.	THỦ TỤC TÍNH TỔNG THU NHẬP TRONG MỘT KHOẢNG THỜI GIAN NHẤT ĐỊNH
GO
CREATE OR ALTER PROCEDURE sp_TongThuNhap 
(	
    @ThoiGianBatDau DATE,        
    @ThoiGianKetThuc DATE,
    @TongThuNhap NUMERIC(15,4) OUT
)
AS
BEGIN
    DECLARE @Tong1 NUMERIC(15,4),
			@Tong2 NUMERIC(15,4),
			@count int
	set @TongThuNhap = 0
	SELECT @count = COUNT(*) FROM HOADONBAN
	WHERE HDB_Time BETWEEN @ThoiGianBatDau AND @ThoiGianKetThuc
	if @count >= 1
	begin 
		SELECT @Tong1 = SUM(HDB_Soluong * DongiaBan * (1 - 0.08))
		FROM HOADONBAN	JOIN CHITIETHOADONBAN ON HOADONBAN.HDB_ID = CHITIETHOADONBAN.HDB_ID
		WHERE HOADONBAN.HDB_Time BETWEEN @ThoiGianBatDau AND @ThoiGianKetThuc AND HDB_Thue = 8;
		
		SELECT @Tong2 = SUM(HDB_Soluong * DongiaBan * (1 - 0.10))
		FROM HOADONBAN	JOIN CHITIETHOADONBAN ON HOADONBAN.HDB_ID = CHITIETHOADONBAN.HDB_ID
		WHERE HOADONBAN.HDB_Time BETWEEN @ThoiGianBatDau AND @ThoiGianKetThuc AND HDB_Thue = 10
		
		SET @TongThuNhap = @Tong1 + @Tong2;
	end
END
go
DECLARE @TongThuNhap NUMERIC(15,4);
EXEC sp_TongThuNhap 
    @ThoiGianBatDau = '2023-01-01', 
    @ThoiGianKetThuc = '2023-12-31',
    @TongThuNhap = @TongThuNhap OUTPUT;
    
PRINT N'Tổng thu nhập: ' + CAST(@TongThuNhap AS NVARCHAR(20));
go
--------------------------------------------------------------------

-- 8.  THỦ TỤC TÍNH TỔNG CHI PHÍ NHẬP HÀNG TRONG MỘT KHOẢNG THỜI GIAN NHẤT ĐỊNH

GO
CREATE OR ALTER PROCEDURE sp_Tongchiphi 
(
    @ThoiGianBatDau DATE,        
    @ThoiGianKetThuc DATE,
    @Tongchiphi NUMERIC(15,4) OUT
)
AS
BEGIN

    SET @Tongchiphi = 0;

    SELECT @Tongchiphi = SUM(HDN_Soluong * DongiaNhap * 
        CASE 
            WHEN HDN_Thue = 8 THEN (1 + 0.08)  
            WHEN HDN_Thue = 10 THEN (1 + 0.10) 
        END)
    FROM HOADONMUA	JOIN CHITIETHOADONMUA ON HOADONMUA.HDN_ID = CHITIETHOADONMUA.HDN_ID
					JOIN HANGHOA ON CHITIETHOADONMUA.HH_ID = HANGHOA.HH_ID
    WHERE HOADONMUA.HDN_Time BETWEEN @ThoiGianBatDau AND @ThoiGianKetThuc
END
-------------------------------------------------------------------------------------------------
GO
DECLARE @TongChiPhi NUMERIC(15,4)
EXEC sp_Tongchiphi 
    @ThoiGianBatDau = '2023-01-01', 
    @ThoiGianKetThuc = '2023-12-31',
    @Tongchiphi = @TongChiPhi OUTPUT;

PRINT N'Tổng chi phí: ' + CAST(@TongChiPhi AS NVARCHAR(20))


----------------------------------------------------------------------------------------------
--9. THỦ TỤC TÍNH LỢI NHUẬN TRONG 1 KHOẢNG THỜI GIAN NHẤT ĐỊNH
GO
CREATE OR ALTER PROCEDURE sp_LoiNhuan
(
    @ThoiGianBatDau DATE,        
    @ThoiGianKetThuc DATE,       
    @LoiNhuan NUMERIC(15,4) OUT, 
    @PhanTramLoiNhuan NUMERIC(5,2) OUT, 
    @KetLuan NVARCHAR(100) OUT   
)
AS
BEGIN

    DECLARE @TongThuNhap NUMERIC(15,4) = 0
    DECLARE @TongChiPhi NUMERIC(15,4) = 0

    exec sp_TongThuNhap
		@ThoiGianBatDau = @ThoiGianBatDau,
        @ThoiGianKetThuc = @ThoiGianKetThuc,
        @TongThuNhap = @TongThuNhap OUTPUT

    exec sp_Tongchiphi
		@ThoiGianBatDau = @ThoiGianBatDau,
        @ThoiGianKetThuc = @ThoiGianKetThuc,
        @Tongchiphi = @TongChiPhi OUTPUT

    SET @LoiNhuan = @TongThuNhap - @TongChiPhi

    IF @TongThuNhap > 0
    BEGIN
        SET @PhanTramLoiNhuan = (@LoiNhuan / @TongThuNhap) * 100
    END
    ELSE
    BEGIN
        SET @PhanTramLoiNhuan = 0
    END

    IF @LoiNhuan > 0
    BEGIN
        SET @KetLuan = N'Lời: ' + CAST(@PhanTramLoiNhuan AS NVARCHAR(10)) + N'%'
    END
    ELSE
    BEGIN
        SET @KetLuan = N'Lỗ: ' + CAST(@PhanTramLoiNhuan AS NVARCHAR(10)) + N'%'
    END
END
-------------------------
go
DECLARE @LoiNhuan NUMERIC(15,4)
DECLARE @PhanTramLoiNhuan NUMERIC(5,2)
DECLARE @KetLuan NVARCHAR(100);

EXEC sp_LoiNhuan 
    @ThoiGianBatDau = '2023-01-01', 
    @ThoiGianKetThuc = '2023-12-31',
    @LoiNhuan = @LoiNhuan OUTPUT,
    @PhanTramLoiNhuan = @PhanTramLoiNhuan OUTPUT,
    @KetLuan = @KetLuan OUTPUT;

-- In kết quả
PRINT N'Tổng lợi nhuận: ' + CAST(@LoiNhuan AS NVARCHAR(20));
PRINT N'Phần trăm lợi nhuận: ' + CAST(@PhanTramLoiNhuan AS NVARCHAR(20)) + '%'
PRINT N'Kết luận: ' + @KetLuan
-----------------------------------------------------------------------------------
-- 10. THỦ TỤC TÍNH LỢI NHUẬN CỦA 1 LOẠI HÀNG HÓA TRONG MỘT KHOẢNG THỜI GIAN NHẤT ĐỊNH
GO
CREATE OR ALTER PROCEDURE sp_LoiNhuan1LoaiSp
    @HH_ID CHAR(8),
    @ThoiGianBatDau DATE,        
    @ThoiGianKetThuc DATE,
    @LoiNhuan1Sp NUMERIC(15,4) OUTPUT,
    @Tongchiphi1sp NUMERIC(15,4) OUTPUT,
    @TongThuNhap1sp NUMERIC(15, 4) OUTPUT,
    @PhanTramLoiNhuan NUMERIC(5, 2) OUTPUT,
    @KetLuan NVARCHAR(100) OUTPUT
AS
BEGIN
    SET @TongThuNhap1sp = 0;

    -- Tính tổng thu nhập
    SELECT @TongThuNhap1sp = SUM(HDB_Soluong * DongiaBan * CASE 
                                                                WHEN HDB_Thue = 8 THEN (1 - 0.08)  
                                                                WHEN HDB_Thue = 10 THEN (1 - 0.1) 
                                                            END)
    FROM HOADONBAN
    JOIN CHITIETHOADONBAN ON HOADONBAN.HDB_ID = CHITIETHOADONBAN.HDB_ID
    JOIN HANGHOA ON CHITIETHOADONBAN.HH_ID = HANGHOA.HH_ID
    WHERE HOADONBAN.HDB_Time BETWEEN @ThoiGianBatDau AND @ThoiGianKetThuc
          AND CHITIETHOADONBAN.HH_ID = @HH_ID
          AND HDB_Thue IN (8,10)

    -- Tính tổng chi phí
    SET @Tongchiphi1sp = 0;
    SELECT @Tongchiphi1sp = SUM(HDN_Soluong * DongiaNhap * 
                                CASE 
                                    WHEN HDN_Thue = 8 THEN (1 + 0.08)  
                                    WHEN HDN_Thue = 10 THEN (1 + 0.1) 
                                END)
    FROM HOADONMUA
    JOIN CHITIETHOADONMUA ON HOADONMUA.HDN_ID = CHITIETHOADONMUA.HDN_ID
    JOIN HANGHOA ON CHITIETHOADONMUA.HH_ID = HANGHOA.HH_ID
    WHERE CHITIETHOADONMUA.HH_ID = @HH_ID 
          AND HOADONMUA.HDN_Time BETWEEN @ThoiGianBatDau AND @ThoiGianKetThuc

    -- Tính lợi nhuận
    SET @LoiNhuan1Sp = @TongThuNhap1sp - @Tongchiphi1sp

    -- Tính phần trăm lợi nhuận
    IF @TongThuNhap1sp > 0
    BEGIN
        SET @PhanTramLoiNhuan = (@LoiNhuan1Sp / @TongThuNhap1sp) * 100
    END
    ELSE
    BEGIN
        SET @PhanTramLoiNhuan = 0
    END

    -- Đưa ra kết luận
    IF @LoiNhuan1Sp > 0
    BEGIN
        SET @KetLuan = N'Lời: ' + CAST(@PhanTramLoiNhuan AS NVARCHAR(20)) + N'%'
    END
    ELSE
    BEGIN
        SET @KetLuan = N'Lỗ: ' + CAST(@PhanTramLoiNhuan AS NVARCHAR(20)) + N'%'
    END
END

----CHECK

GO
DECLARE @LoiNhuan1Sp NUMERIC(15,4)
DECLARE @Tongchiphi1sp NUMERIC(15,4)
DECLARE @TongThuNhap1sp NUMERIC(15,4)
DECLARE @PhanTramLoiNhuan NUMERIC(5,2)
DECLARE @KetLuan NVARCHAR(100)


EXEC sp_LoiNhuan1LoaiSp 'HH000017', '2024-01-01', '2024-6-30', 
    @LoiNhuan1Sp OUTPUT, 
	@Tongchiphi1sp OUTPUT,
	@TongThuNhap1sp OUTPUT,
    @PhanTramLoiNhuan OUTPUT, 
    @KetLuan OUTPUT


-- In kết quả
PRINT N'Tổng lợi nhuận: ' + CAST(@LoiNhuan1Sp AS NVARCHAR(20))
PRINT N'Phần trăm lợi nhuận: ' + CAST(@PhanTramLoiNhuan AS NVARCHAR(20)) + '%'
PRINT N'Kết luận: ' + @KetLuan
select * from CHITIETHOADONBAN
select * from HOADONBAN

















