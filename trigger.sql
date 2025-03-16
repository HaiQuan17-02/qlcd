--TRIGGER
--Kiểm tra số lượng sinh viên vượt quá giới hạn của các chuyên gia
CREATE TRIGGER trg_KiemTraSoLuongSV
ON DangKyChuyenDe
AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM DangKyChuyenDe DK
        JOIN ChuyenDe CD ON DK.MaCD = CD.MaCD
        WHERE DK.MaCD IN (SELECT MaCD FROM inserted)
        GROUP BY DK.MaCD, CD.SoSinhVienToiDa
        HAVING COUNT(DK.MaSV) > CD.SoSinhVienToiDa
    )
    BEGIN
        PRINT N'Chuyên đề đã đạt giới hạn sinh viên đăng ký!';
        ROLLBACK TRANSACTION;
    END
END;

-- Cập nhật tổng số sinh viên trong bảng khi có sinh viên mới
CREATE TRIGGER trg_CapNhatSoLuongSinhVien
ON SinhVien
AFTER INSERT, DELETE
AS
BEGIN
    UPDATE Nganh
    SET TongSoSinhVien = (
        SELECT COUNT(*) FROM SinhVien WHERE SinhVien.MaNganh = Nganh.MaNganh
    )
    WHERE MaNganh IN (SELECT MaNganh FROM inserted)
       OR MaNganh IN (SELECT MaNganh FROM deleted);
END;

-- Cẩn thận không xóa chuyên gia nếu có sinh viên đã đăng ký
CREATE TRIGGER trg_KiemTraXoaChuyenDe
ON ChuyenDe
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM DangKyChuyenDe DK
        WHERE DK.MaCD IN (SELECT MaCD FROM deleted)
    )
    BEGIN
        PRINT N'Không thể xóa chuyên đề vì đã có sinh viên đăng ký!';
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        DELETE FROM ChuyenDe WHERE MaCD IN (SELECT MaCD FROM deleted);
    END
END;

-- Kiểm tra ngày sinh viên không thể nhỏ hơn năm 2000
CREATE TRIGGER trg_KiemTraNgaySinh
ON SinhVien
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM inserted
        WHERE YEAR(NgaySinh) < 2000
    )
    BEGIN
        PRINT N'Lỗi: Ngày sinh của sinh viên phải từ năm 2000 trở đi!';
        ROLLBACK TRANSACTION;
    END
END;


-- Tự động xóa đăng ký chuyên đề khi sinh viên bị xóa
CREATE TRIGGER trg_XoaDangKyKhiXoaSV
ON SinhVien
AFTER DELETE
AS
BEGIN
    DELETE FROM DangKyChuyenDe WHERE MaSV IN (SELECT MaSV FROM deleted);
END;
