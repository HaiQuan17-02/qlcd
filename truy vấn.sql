SELECT *FROM SinhVien;
SELECT * FROM ChuyenDe;
SELECT * FROM Nganh_ChuyenDe;
SELECT *FROM MoChuyenDe;
SELECT * FROM DangKyChuyenDe;

-- Lay danh sach chuyen de mo trong học ky 1 nam 2024
SELECT * FROM MoChuyenDe WHERE NamHoc = 2024 AND HocKy = 1;

-- Lấy thông tin sinh viên thuộc ngành "CNTT"
SELECT * FROM SinhVien WHERE MaNganh = 'CNTT';

-- Lay danh sach chuyen de co so sinh vien toi đa lớn hơn 80
SELECT * FROM ChuyenDe WHERE SoSinhVienToiDa > 80;

--Thêm mot sinh vien mới
INSERT INTO SinhVien (MaSV, HoTen, Phai, NgaySinh, DiaChi, MaNganh)
VALUES ('SV016', N'Vũ Thị N', 'Nữ', '2002-10-15', N'Bắc Ninh', 'CNTT');

-- Thêm một chuyên đề mới
INSERT INTO ChuyenDe (MaCD, TenCD, SoSinhVienToiDa)
VALUES ('CD016', N'Phat triển phan mem', 85);

--Cập nhật địa chỉ của sinh viên "SV011"
UPDATE SinhVien
SET DiaChi = N'TP. Hồ Chí Minh'
WHERE MaSV = 'SV011';

-- Tăng số lượng sinh viên tối đa cho chuyên đề "CD011"
UPDATE ChuyenDe
SET SoSinhVienToiDa = 120
WHERE MaCD = 'CD011';

--Xóa sinh viên có mã "SV016"
DELETE FROM SinhVien WHERE MaSV = 'SV016';
--Xóa chuyên đe "CD016"
DELETE FROM ChuyenDe WHERE MaCD = 'CD016';

-- Lấy danh sách sinh viên kèm theo tên ngành học của họ
SELECT SV.MaSV, SV.HoTen, N. TenNganh
FROM SinhVien SV
INNER JOIN Nganh N ON SV.MaNganh = N.MaNganh;

-- Lấy danh sách sinh viên đã đăng ký chuyên đề, kèm theo tên chuyên đề
SELECT SV.MaSV, SV.HoTen, CD.TenCD, DK. NamHoc, DK. HocKy
FROM DangKyChuyenDe DK
INNER JOIN SinhVien SV ON DK.MaSV = SV.MaSV
INNER JOIN ChuyenDe CD ON DK.MaCD = CD.MaCD;

--Đem so sinh vien theo tung nganh học
SELECT MaNganh, COUNT (MaSV) AS SoLuongSinhVien
FROM SinhVien
GROUP BY MaNganh;

--Đếm số sinh viên đã đăng ký mỗi chuyen đề
SELECT MaCD, COUNT (MaSV) AS SoLuongDangKy
FROM DangKyChuyenDe
GROUP BY MaCD;

--Tìm nganh hoc co nhieu hon 3 sinh vien
SELECT MaNganh, COUNT (MaSV) AS SoLuongSinhVien
FROM SinhVien
GROUP BY MaNganh
HAVING COUNT(MaSV) > 3;

-- Tìm chuyên đề có hơn 2 sinh viên đăng ký
SELECT MaCD, COUNT (MaSV) AS SoLuongDangKy
FROM DangKyChuyenDe
GROUP BY MaCD
HAVING COUNT (MaSV) > 2;

-- Tìm kiếm sinh viên nào chưa đăng kí chuyên đề
SELECT * FROM SinhVien
WHERE MaSV NOT IN (
SELECT DISTINCT MaSV FROM DangKyChuyenDe
);

--Chuyên đề có sinh viên đăng kí nhiều nhất
SELECT * FROM ChuyenDe
WHERE MaCD = (
SELECT TOP 1 MaCD
FROM DangKyChuyenDe
GROUP BY MaCD
ORDER BY COUNT (MaSV) DESC

);

