-- FUNCTION 
--Lấy tổng số sinh viên của một chuyên ngành
CREATE FUNCTION fn_TinhSoSinhVienTheoNganh(@MaNganh NVARCHAR(10))
RETURNS INT
AS
BEGIN
    DECLARE @SoSV INT;
    SELECT @SoSV = COUNT(*)
    FROM SinhVien
    WHERE MaNganh = @MaNganh;
    RETURN @SoSV;
END;
SELECT dbo.fn_TinhSoSinhVienTheoNganh('CNTT') AS SoLuongSinhVien;

--Kiểm tra sinh viên có đăng ký chuyên đề không
CREATE FUNCTION fn_KiemTraDangKy(@MaSV NVARCHAR(10))
RETURNS BIT
AS
BEGIN
    DECLARE @Result BIT;
    IF EXISTS (SELECT 1 FROM DangKyChuyenDe WHERE MaSV = @MaSV)
        SET @Result = 1;
    ELSE
        SET @Result = 0;
    RETURN @Result;
END;
SELECT dbo.fn_KiemTraDangKy('SV001') AS DaDangKy;

--Lấy số chuyên đề mà sinh viên đã đăng ký
CREATE FUNCTION fn_SoChuyenDeDaDangKy(@MaSV NVARCHAR(10))
RETURNS INT
AS
BEGIN
    DECLARE @SoCD INT;
    SELECT @SoCD = COUNT(*)
    FROM DangKyChuyenDe
    WHERE MaSV = @MaSV;
    RETURN @SoCD;
END;
SELECT dbo.fn_SoChuyenDeDaDangKy('SV001') AS SoChuyenDe;

--Danh sách sinh viên của một chuyên ngành
CREATE FUNCTION fn_DanhSachSinhVienTheoNganh(@MaNganh NVARCHAR(10))
RETURNS TABLE
AS
RETURN
(
    SELECT MaSV, HoTen, Phai, NgaySinh, DiaChi
    FROM SinhVien
    WHERE MaNganh = @MaNganh
);
SELECT * FROM dbo.fn_DanhSachSinhVienTheoNganh('CNTT');

--Lấy danh sách chuyên đề mở theo năm học & học kỳ
CREATE FUNCTION fn_ChuyenDeTheoHocKy(@NamHoc INT, @HocKy INT)
RETURNS TABLE
AS
RETURN
(
    SELECT CD.MaCD, CD.TenCD, CD.SoSinhVienToiDa
    FROM MoChuyenDe MCD
    JOIN ChuyenDe CD ON MCD.MaCD = CD.MaCD
    WHERE MCD.NamHoc = @NamHoc AND MCD.HocKy = @HocKy
);
SELECT * FROM dbo.fn_ChuyenDeTheoHocKy(2024, 1);

--Danh sách sinh viên đã đăng chuyên đề
CREATE FUNCTION fn_SinhVienDangKyCD(@MaCD NVARCHAR(10))
RETURNS TABLE
AS
RETURN
(
    SELECT SV.MaSV, SV.HoTen, SV.MaNganh
    FROM DangKyChuyenDe DK
    JOIN SinhVien SV ON DK.MaSV = SV.MaSV
    WHERE DK.MaCD = @MaCD
);
SELECT * FROM dbo.fn_SinhVienDangKyCD('CD001');

--Lấy số lượng sinh viên đăng ký theo từng chuyên đề
CREATE FUNCTION fn_SoSinhVienTheoChuyenDe()
RETURNS @Table TABLE
(
    MaCD NVARCHAR(10),
    TenCD NVARCHAR(255),
    SoLuongSinhVien INT
)
AS
BEGIN
    INSERT INTO @Table
    SELECT CD.MaCD, CD.TenCD, COUNT(DISTINCT DK.MaSV)
    FROM ChuyenDe CD LEFT JOIN DangKyChuyenDe DK ON CD.MaCD = DK.MaCD
    GROUP BY CD.MaCD, CD.TenCD;
    RETURN;
END;
SELECT * FROM dbo.fn_SoSinhVienTheoChuyenDe();

--Tính số lượng chuyên đề mà mỗi sinh viên đã đăng ký
CREATE FUNCTION fn_SoChuyenDeMoiSinhVien()
RETURNS @Table TABLE
(
    MaSV NVARCHAR(10),
    HoTen NVARCHAR(255),
    SoChuyenDe INT
)
AS
BEGIN
    INSERT INTO @Table
    SELECT SV.MaSV, SV.HoTen, COUNT(DK.MaCD)
    FROM SinhVien SV LEFT JOIN DangKyChuyenDe DK ON SV.MaSV = DK.MaSV
    GROUP BY SV.MaSV, SV.HoTen;
    RETURN;
END;
SELECT * FROM dbo.fn_SoChuyenDeMoiSinhVien();

--Danh sách chuyên ngành và số lượng sinh viên
CREATE FUNCTION fn_SoSinhVienTheoNganh()
RETURNS @Table TABLE
(
    MaNganh NVARCHAR(10),
    TenNganh NVARCHAR(255),
    SoSinhVien INT
)
AS
BEGIN
    INSERT INTO @Table
    SELECT N.MaNganh, N.TenNganh, COUNT(SV.MaSV)
    FROM Nganh N
    LEFT JOIN SinhVien SV ON N.MaNganh = SV.MaNganh
    GROUP BY N.MaNganh, N.TenNganh;

    RETURN;
END;
SELECT * FROM dbo.fn_SoSinhVienTheoNganh();

--Lấy danh sách chuyên đề và chuyên ngành mở rộng
CREATE FUNCTION fn_ChuyenDeTheoNganh()
RETURNS @Table TABLE
(
    MaCD NVARCHAR(10),
    TenCD NVARCHAR(255),
    MaNganh NVARCHAR(10),
    TenNganh NVARCHAR(255)
)
AS
BEGIN
    INSERT INTO @Table
    SELECT CD.MaCD, CD.TenCD, N.MaNganh, N.TenNganh
    FROM Nganh_ChuyenDe NC
    JOIN ChuyenDe CD ON NC.MaCD = CD.MaCD
    JOIN Nganh N ON NC.MaNganh = N.MaNganh;

    RETURN;
END;
SELECT * FROM dbo.fn_ChuyenDeTheoNganh();
