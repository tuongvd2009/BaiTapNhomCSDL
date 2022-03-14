﻿--Tạo bảng
CREATE DATABASE QUANLYMUAHANG
GO
USE QUANLYMUAHANG
GO
CREATE TABLE KHACHHANG (
      MaKH VARCHAR (10) PRIMARY KEY,
	  HovaTenKH NVARCHAR (100),
	  Email VARCHAR (50),
	  SoDT VARCHAR (20),
	  Diachi VARCHAR (100)
	  )
GO
CREATE TABLE SANPHAM (
      MaSP VARCHAR (10) PRIMARY KEY,
	  TenSP NVARCHAR (100),
	  MoTa NVARCHAR (100),
	  GiaSP INT,
	  SoluongSP INT
      )
GO
CREATE TABLE THANHTOAN (
      MaPTTT VARCHAR (50) PRIMARY KEY,
	  TenPTTT VARCHAR (50),
	  PhiTT INT 
	  )
GO
CREATE TABLE DATHANG (
      MaDH VARCHAR (10) PRIMARY KEY,
	  MaKH VARCHAR (10)
	  FOREIGN KEY (MaKH) REFERENCES KHACHHANG (MaKH),
	  MaPTTT VARCHAR (50),
	  FOREIGN KEY (MaPTTT) REFERENCES THANHTOAN (MaPTTT),
	  NgayDH DATE ,
	  TrangthaiDH NVARCHAR (100),	  
	  Tongtien INT
	  )
GO
CREATE TABLE CHITIETDATHANG (
      MaOrder_detail VARCHAR (10) PRIMARY KEY,
	  MaDH VARCHAR (10)
	  FOREIGN KEY(MaDH) REFERENCES DATHANG (MaDH),
	  MaSP VARCHAR (10),
	  FOREIGN KEY(MaSP) REFERENCES SANPHAM (MaSP),
	  SoluongSPmua INT,
	  GiaSPmua INT,
	  Thanhtien INT
	  )
GO

--chèn dữ liệu
INSERT INTO KHACHHANG VALUES
            ('KH0001', N'Hoàng Kim Trang', 'kimtrang0601@gmail.com', 0921647587, 'Lien Chieu'),
            ('KH0002', N'Hồ Hải Huy', 'haihuy0510@gmail.com', 0935280681, 'Thanh Khe'),
            ('KH0003', N'Nguyễn Thanh Ba', 'ba198@gmail.com', 0905631375, 'Hai Chau'),
            ('KH0004', N'Trần Ngọc Hoàng', 'ngochoang89@gmail.com', 0905987789, 'Son Tra'),
            ('KH0005', N'Hà Văn Bình', 'binhha123@gmail.com', 09565738558, 'Lien Chieu');
GO
INSERT INTO SANPHAM VALUES
            ('SP001', N'Áo',  N'Dành cho nữ', 100000, 80),
			('SP002', N'Quần',  N'Dành cho nam', 300000, 100 ),
			('SP003', N'Váy',  N'Dành cho nữ', 100000, 50),
			('SP004', N'Áo dài', N'Dành cho cả nam và nữ', 10000000, 10),
			('SP005', N'Mũ', N'Dành cho trẻ em', 70000, 80);
GO
INSERT INTO THANHTOAN VALUES
            ('P001','Credit Card', 11000),
			('P002','Momo', 10000),
			('P003','Visa', 25000);
GO
INSERT INTO DATHANG VALUES
            ('DH001', 'KH0001', 'P001', '2022-1-25', N'Đã đặt', 100000),
			('DH002', 'KH0002', 'P002', '2022-2-25', N'Đang giao', 300000),
			('DH003', 'KH0003', 'P003', '2022-2-28', N'Đang giao', 70000);
GO
INSERT INTO CHITIETDATHANG VALUES
            ('CT0001', 'DH001', 'SP001', 1, 100000, 100000),
			('CT0002', 'DH002', 'SP002', 1, 300000, 300000),
			('CT0003', 'DH003', 'SP005', 3, 70000, 210000);
GO


--Tạo view

--VIEW hiển thị thông tin khách hàng với ngày đặt hàng là ngày 25-1-2022
CREATE VIEW NGAYDATHANG1 AS
SELECT KH.* FROM KHACHHANG KH
JOIN DATHANG DH
ON DH.MaKH = KH.MaKH
WHERE NgayDH = '2022-1-25'
GO
SELECT * FROM NGAYDATHANG1
-- VIEW hiển thị mã sản phẩm, tên sản phẩm có số lượng mua bằng 1
CREATE VIEW TTSANPHAM AS
SELECT SP.MaSP, SP.TenSP FROM SANPHAM SP 
JOIN CHITIETDATHANG CTDH
ON SP.MaSP = CTDH.MaSP
WHERE CTDH.SoluongSPmua = 1
SELECT * FROM TTSANPHAM




--VIEW HIỆN THỊ KHÁCH HÀNG COS TỐNG SỐ TIỀN ĐẶT HÀNG LÀ 7OK
CREATE VIEW SOTIEN AS
SELECT KH.* FROM KHACHHANG KH
JOIN DATHANG DH
ON DH.MaKH = KH.MaKH
WHERE Tongtien = 70000
GO
SELECT * FROM SOTIEN




--TẠO HÀM
--Viết hàm trả về 1 bảng với các thông tin MaKH,  HovaTenKH,Email,SoDT,DiaChi của khách hàng có trong bảng ORDERS
CREATE FUNCTION KHACHHANGG()
returns table as
return 
(
    select DISTINCT KHACHHANG.MaKH,  HovaTenKH,Email,SoDT,DiaChi  
	from dbo.KHACHHANG join dbo.DATHANG 
	on  KHACHHANG.MaKH = DATHANG.MaKH		
)
go
select * from dbo.KHACHHANGG();

 --tạo hàm có tên UF_SELECTallKHACHHANG dùng để trả về bảng KHACHHANG để xem được tất cả thông tin của khách hàng
CREATE FUNCTION UF_SELECTallKHACHHANG()
RETURNS TABLE 
AS RETURN SELECT*FROM dbo.KHACHHANG
GO

SELECT*FROM UF_SELECTallKHACHHANG()


-- Hàm đếm tổng số lượng đã bán được của một sản phẩm nào đó

create function tongSanPhamBan(@maSP varchar(10))
returns int
as
	begin
		declare @tongSP int

		select @tongSP = sum(SoluongSPmua) from CHITIETDATHANG
		where MaSP = @maSP

		return @tongSP
	end
go 

select dbo.tongSanPhamBan('SP005') as DaBan

-- Hàm kiểm tra thông tin khách hàng qua địa chỉ 
CREATE FUNCTION fn_CUSTOMER (@DiaChi VARCHAR (25))
RETURNS TABLE 
AS 
RETURN ( SELECT *FROM KHACHHANG WHERE Diachi=@DiaChi );
go

SELECT * FROM fn_CUSTOMER ('Lien Chieu')





-- TẠO THỦ TỤC LƯU TRỮ
CREATE PROC sp_SP(@MaSP int) AS

BEGIN
  IF(exists(SELECT * FROM SANPHAM WHERE MaSP=@MaSP))
    SELECT * FROM SANPHAM WHERE MaSP=@MaSP
  ELSE
    print N'Không tìm thấy sản phẩm có mã ' + str(@MaSP,3);
END;

CREATE PROC sp_TimSP(@TenSP VARCHAR(30)) AS
BEGIN
  IF(EXISTS(SELECT TenSP FROM SANPHAM WHERE TenSP like '%'+@TenSp+'%'))
    SELECT TenSP, [MaDH], SoluongSPmua, GiaSPmua, [Thanhtien] FROM SANPHAM a JOIN CHITIETDATHANG b ON a.MaSP=b.MaSP WHERE TenSP like '%'+@TenSP+'%';
  ELSE IF(@TenSP = '*')
    SELECT TenSP, [MaDH], SoluongSPmua, GiaSPmua, [Thanhtien] FROM SANPHAM a JOIN CHITIETDATHANG b ON a.MaSP=b.MaSP ;    
  ELSE
    print N'Không tìm thấy sản phẩm có tên tương tự '+@TenSP;
END;


SELECT c.MaKH, SUM(b.SoluongSPmua * a.GiaSP) AS [TongTien], [Level] = CASE
  WHEN SUM(b.SoluongSPmua * a.GiaSP) < 200000 THEN 'Level 1'
  WHEN SUM(b.SoluongSPmua * a.GiaSP) >= 200000 AND SUM(b.SoluongSPmua * a.GiaSP) < 300000 THEN 'Level 2'
  WHEN SUM(b.SoluongSPmua * a.GiaSP) >= 300000 THEN 'V.I.P'
  ELSE 'Unknow'
  END
  FROM SANPHAM a JOIN CHITIETDATHANG b ON a.MaSP=b.MaSP JOIN DATHANG c ON b.MaDH=c.MaDH
  GROUP BY c.MaKH;

DECLARE @MaSP VARCHAR(10)
DECLARE @TenSP nvarchar(200)


DECLARE cursorSP CURSOR FOR
SELECT MaSP,TenSP FROM SANPHAM
Open cursorSP
FETCH NEXT FROM cursorSP INTO @MaSP, @TenSP
WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'MaSP:' + CAST(@MaSP as nvarchar)
    PRINT 'TenSP:' + @TenSP

    FETCH NEXT FROM cursorSP INTO @MaSP, @TenSP
END







-- TRIGGER 1
CREATE TRIGGER TongBangConLai
ON DATHANG
FOR DELETE 
AS 
BEGIN 
        DECLARE @tong INT
		SELECT @tong = COUNT(*) FROM DATHANG
		PRINT N'Tổng số bản ghi còn lại là: ' + CAST(@tong AS VARCHAR(5))
END
GO

delete from DATHANG where MaDH = 'DH004'
select *from DATHANG

INSERT INTO DATHANG VALUES
            ('DH004', 'KH0001', 'P001', '2022-1-26', N'Đã đặt', 100000);







-----------------TRIGGER 2 ----------------



CREATE TRIGGER CapNhatSoLuongSP
ON SANPHAM
FOR UPDATE
AS
BEGIN
	IF UPDATE(SoluongSP)
	BEGIN
		DECLARE @soluongSP int
		SELECT @soluongSP = SoluongSP
		FROM inserted 

		
		IF(@soluongSP >100)
		BEGIN
			PRINT N'Số lượng quá tải @_@ Vui lòng đặt lại số lượng dưới 100'
			ROLLBACK TRANSACTION
		END
		IF(@soluongSP < 0)
		BEGIN
			PRINT N'Vui lòng đặt lại số lượng lớn từ 0 đến 100'
			ROLLBACK TRANSACTION
		END
		 
	END
END
GO

UPDATE SANPHAM
SET SoluongSP = 70
WHERE MaSP = 'SP002'

select * from SANPHAM





-- TRIGGER 3


CREATE TRIGGER TinhTongCacSP
ON SANPHAM
FOR INSERT 
AS 
BEGIN 
        DECLARE @tong INT
		SELECT @tong = COUNT(*) FROM SANPHAM
		PRINT N'Tổng số bản ghi hiện tại là: ' + CAST(@tong AS VARCHAR(5))
END
GO

INSERT INTO SANPHAM VALUES
            ('SP006', N'Nón',  N'Dành cho nữ', 65000, 90);
GO

select *from SANPHAM
drop trigger TinhTongCacSP




-- TRIGGER 4





CREATE TRIGGER CapNhatGiaSP
ON SANPHAM
FOR UPDATE
AS
BEGIN
	IF UPDATE(GiaSP)
	BEGIN
		DECLARE @giaSP int
		SELECT @giaSP = GiaSP
		FROM inserted 
		IF(@giaSP <= 0)
		BEGIN
			PRINT N'Lỗi! Vui lòng đặt lại bằng số nguyên dương!'
			ROLLBACK TRANSACTION
		END
		 
	END
END
GO
UPDATE SANPHAM
SET GiaSP = -1
WHERE MaSP = 'SP001'
select * from SANPHAM





-- TRIGGER 5


CREATE TRIGGER ADDSP
ON SANPHAM
FOR INSERT
AS
 IF (SELECT TEN.GiaSP FROM SANPHAM SP JOIN inserted TEN
	                   ON SP.MaSP = TEN.MaSP	   	                  
		               WHERE SP.MoTa = N'Dành cho nam' ) < 500000
BEGIN
     PRINT N'Sản phẩm  > 500000';
	 ROLLBACK TRANSACTION	 
END
INSERT INTO SANPHAM VALUES
('SP006',  N'Kính', N'Dành cho nam', 600000,  5);
select * from SANPHAM
-------- 
/* cập nhật hàng trong kho sau khi đặt hàng hoặc cập nhật */
CREATE TRIGGER TG_insertCTDH ON dbo.CHITIETDATHANG AFTER INSERT AS 
BEGIN
	UPDATE SANPHAM
	SET SoluongSP = SoluongSP - (
		SELECT SoluongSPmua
		FROM inserted
		WHERE MaSP = SANPHAM.MaSP
	)
	FROM dbo.SANPHAM
	JOIN inserted ON SANPHAM.MaSP = inserted.MaSP
END
GO

DROP TRIGGER TG_insertCTDH
SELECT * FROM SANPHAM
SELECT * FROM CHITIETDATHANG
INSERT INTO dbo.CHITIETDATHANG
VALUES ('CT0004','DH003','SP002',10,100000,200000)
DELETE dbo.CHITIETDATHANG WHERE MaOrder_detail = 'CT0006'

-----


/* cập nhật hàng trong kho sau khi hủy đặt hàng */
CREATE TRIGGER TG_HuyDatHang ON CHITIETDATHANG FOR DELETE AS 
BEGIN
	UPDATE SANPHAM
	SET SoluongSP = SoluongSP + (SELECT SoluongSPmua FROM deleted WHERE MaSP = SANPHAM.MaSP)
	FROM SANPHAM
	JOIN deleted ON SANPHAM.MaSP = deleted.MaSP
END
SELECT * FROM SANPHAM
DELETE dbo.CHITIETDATHANG WHERE MaOrder_detail = 'CT0004'
DROP TRIGGER TG_HuyDatHang
