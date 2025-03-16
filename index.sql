--INDEX 
CREATE NONCLUSTERED INDEX IX_SinhVien_Nganh ON SinhVien(MaNganh);
SELECT * FROM SinhVien WHERE MaNganh = 'CNTT';

CREATE NONCLUSTERED INDEX IX_Nganh_ChuyenDe ON Nganh_ChuyenDe(MaNganh, MaCD);
SELECT * FROM Nganh_ChuyenDe WHERE MaNganh = 'CNTT';

CREATE NONCLUSTERED INDEX IX_MoChuyenDe_HocKy ON MoChuyenDe(NamHoc, HocKy);
SELECT * FROM MoChuyenDe WHERE NamHoc = 2024 AND HocKy = 1;

CREATE NONCLUSTERED INDEX IX_DangKyChuyenDe_MaSV ON DangKyChuyenDe(MaSV);
SELECT * FROM DangKyChuyenDe WHERE MaSV = 'SV001';

CREATE NONCLUSTERED INDEX IX_SinhVien_TinhSoLuong ON SinhVien(MaNganh) INCLUDE (MaSV);
SELECT MaNganh, COUNT(MaSV) AS SoLuongSinhVien FROM SinhVien
GROUP BY MaNganh;

CREATE NONCLUSTERED INDEX IX_DangKyChuyenDe_Count ON DangKyChuyenDe(MaCD) INCLUDE (MaSV);
SELECT MaCD, COUNT(MaSV) AS SoLuongDangKy FROM DangKyChuyenDe
GROUP BY MaCD;

CREATE NONCLUSTERED INDEX IX_Nganh_ChuyenDe_Count ON Nganh_ChuyenDe(MaNganh) INCLUDE (MaCD);
SELECT MaNganh, COUNT(MaCD) AS SoLuongChuyenDe FROM Nganh_ChuyenDe
GROUP BY MaNganh;


CREATE NONCLUSTERED INDEX IX_DangKyChuyenDe_Exists ON DangKyChuyenDe(MaSV);
SELECT 1 FROM DangKyChuyenDe 
WHERE MaSV = 'SV001';

--thủ tục không tham số 
CREATE PROCEDURE sp_GetSinhVienChuyenDe
AS
BEGIN
    SELECT SV.MaSV, SV.HoTen, N.TenNganh, CD.TenCD FROM DangKyChuyenDe DKCD
    INNER JOIN SinhVien SV ON DKCD.MaSV = SV.MaSV
    INNER JOIN Nganh N ON SV.MaNganh = N.MaNganh
    INNER JOIN ChuyenDe CD ON DKCD.MaCD = CD.MaCD
    ORDER BY SV.MaSV, CD.TenCD;
END;

EXEC sp_GetSinhVienChuyenDe;

CREATE PROCEDURE sp_GetNganhChuyenDeDangMo
AS
BEGIN
    SELECT N.TenNganh, CD.TenCD, MCD.NamHoc, MCD.HocKy, COUNT(DKCD.MaSV) AS SoLuongSinhVienDangKy
    FROM Nganh N INNER JOIN Nganh_ChuyenDe NCD ON N.MaNganh = NCD.MaNganh
			     INNER JOIN ChuyenDe CD ON NCD.MaCD = CD.MaCD
			     INNER JOIN MoChuyenDe MCD ON CD.MaCD = MCD.MaCD
			     LEFT JOIN DangKyChuyenDe DKCD ON MCD.MaCD = DKCD.MaCD 
												 AND MCD.NamHoc = DKCD.NamHoc 
												 AND MCD.HocKy = DKCD.HocKy
    GROUP BY N.TenNganh, CD.TenCD, MCD.NamHoc, MCD.HocKy
    ORDER BY N.TenNganh, MCD.NamHoc DESC, MCD.HocKy;
END;

exec sp_GetNganhChuyenDeDangMo

-- thủ tục có tham số 
CREATE PROCEDURE sp_DanhSachSinhVienTheoNganhVaNam
    @MaNganh NVARCHAR(10), 
    @NamHoc INT
AS
BEGIN
    SELECT SV.MaSV, SV.HoTen, SV.Phai, SV.NgaySinh, SV.DiaChi, N.TenNganh, DKCD.MaCD, CD.TenCD, DKCD.HocKy
    FROM SinhVien SV
    INNER JOIN Nganh N ON SV.MaNganh = N.MaNganh
    INNER JOIN DangKyChuyenDe DKCD ON SV.MaSV = DKCD.MaSV
    INNER JOIN ChuyenDe CD ON DKCD.MaCD = CD.MaCD
    WHERE SV.MaNganh = @MaNganh AND DKCD.NamHoc = @NamHoc
    ORDER BY DKCD.HocKy;
END;
EXEC sp_DanhSachSinhVienTheoNganhVaNam @MaNganh = 'CNTT', @NamHoc = 2024;

CREATE PROCEDURE sp_ChuyenDeMoTheoHocKy
    @NamHoc INT,
    @HocKy INT
AS
BEGIN
    SELECT MCD.MaCD, CD.TenCD, COUNT(DKCD.MaSV) AS SoLuongDangKy
    FROM MoChuyenDe MCD
    INNER JOIN ChuyenDe CD ON MCD.MaCD = CD.MaCD
    LEFT JOIN DangKyChuyenDe DKCD ON MCD.MaCD = DKCD.MaCD AND MCD.NamHoc = DKCD.NamHoc AND MCD.HocKy = DKCD.HocKy
    WHERE MCD.NamHoc = @NamHoc AND MCD.HocKy = @HocKy
    GROUP BY MCD.MaCD, CD.TenCD
    ORDER BY SoLuongDangKy DESC;
END;

EXEC sp_ChuyenDeMoTheoHocKy @NamHoc = 2024, @HocKy = 1;

CREATE PROCEDURE sp_ThongKeSinhVienTheoNganh
    @MaNganh NVARCHAR(10)
AS
BEGIN
    SELECT N.TenNganh, COUNT(DISTINCT SV.MaSV) AS SoLuongSinhVien
    FROM SinhVien SV
    INNER JOIN Nganh N ON SV.MaNganh = N.MaNganh
    INNER JOIN DangKyChuyenDe DKCD ON SV.MaSV = DKCD.MaSV
    WHERE SV.MaNganh = @MaNganh
    GROUP BY N.TenNganh;
END;
EXEC sp_ThongKeSinhVienTheoNganh @MaNganh = 'CNTT';

--thủ tục có output 
CREATE PROCEDURE sp_TinhSoSinhVienDangKy
    @SoSinhVienDaDangKy INT OUTPUT,
    @SoSinhVienChuaDangKy INT OUTPUT,
    @TongSinhVien INT OUTPUT
AS
BEGIN
    SELECT @TongSinhVien = COUNT(*) FROM SinhVien;
    SELECT @SoSinhVienDaDangKy = COUNT(DISTINCT DKCD.MaSV) FROM DangKyChuyenDe DKCD;
    SET @SoSinhVienChuaDangKy = @TongSinhVien - @SoSinhVienDaDangKy;
END;
DECLARE @DaDangKy INT, @ChuaDangKy INT, @Tong INT;
EXEC sp_TinhSoSinhVienDangKy @DaDangKy OUTPUT, @ChuaDangKy OUTPUT, @Tong OUTPUT;
SELECT @DaDangKy AS SoSinhVienDaDangKy, @ChuaDangKy AS SoSinhVienChuaDangKy, @Tong AS TongSinhVien;

CREATE PROCEDURE sp_TinhSoChuyenDeMo
    @NamHoc INT,
    @HocKy INT,
    @TongChuyenDe INT OUTPUT
AS
BEGIN
    SELECT @TongChuyenDe = COUNT(*)
    FROM MoChuyenDe
    WHERE NamHoc = @NamHoc AND HocKy = @HocKy;
END;
DECLARE @SoCD INT;
EXEC sp_TinhSoChuyenDeMo @NamHoc = 2024, @HocKy = 1, @TongChuyenDe = @SoCD OUTPUT;
SELECT @SoCD AS TongSoChuyenDe;

ALTER PROCEDURE sp_TinhSoSinhVienDangKyCD
    @MaCD NVARCHAR(10),
    @TenCD NVARCHAR(255) OUTPUT,
    @SoLuongSinhVien INT OUTPUT
AS
BEGIN
    SELECT @TenCD = TenCD FROM ChuyenDe 
    WHERE MaCD = @MaCD;
    SELECT @SoLuongSinhVien = COUNT(DISTINCT MaSV) FROM DangKyChuyenDe
    WHERE MaCD = @MaCD;
END;
DECLARE @TenCD NVARCHAR(255);
DECLARE @SoSV INT;

EXEC sp_TinhSoSinhVienDangKyCD 
    @MaCD = 'CD001', 
    @TenCD = @TenCD OUTPUT, 
    @SoLuongSinhVien = @SoSV OUTPUT;

SELECT 'CD001' AS MaChuyenDe, @TenCD AS TenChuyenDe, @SoSV AS SoLuongSinhVienDangKy;

