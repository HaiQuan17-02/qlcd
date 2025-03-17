-- Tạo cơ sở dữ liệu
CREATE DATABASE QuanLyChuyenDe;
USE QuanLyChuyenDe;
go
-- Bảng SinhVien
CREATE TABLE SinhVien (
    MaSV VARCHAR(10) PRIMARY KEY,
    HoVaTen NVARCHAR(100) NOT NULL,
    Phai VARCHAR(10) CHECK (Phai IN ('Nam','Nữ')),
    NgaySinh DATE NOT NULL,
    DiaChi NVARCHAR(255),
    MaNganh VARCHAR(10) NOT NULL,
    FOREIGN KEY (MaNganh) REFERENCES NGANH(MaNganh) ON DELETE CASCADE
);

-- Bảng NGANH
CREATE TABLE Nganh (
    MaNganh VARCHAR(10) PRIMARY KEY,
    TenNganh NVARCHAR(100) UNIQUE NOT NULL,
    SoChuyenDePhaiHoc INT CHECK (SoChuyenDePhaiHoc>=0),
    TongSoSinhVien INT DEFAULT 0 CHECK (TongSoSinhVien>=0)
);

-- Bảng CHUYENDE
CREATE TABLE ChuyenDe (
    MaCD VARCHAR(10) PRIMARY KEY,
    TenCD NVARCHAR(100) UNIQUE NOT NULL,
    SoSinhVienToiDa INT CHECK (SoSinhVienToiDa > 0)
);

-- Bảng NGANH_CHUYENDE (Quan hệ nhiều - nhiều)
CREATE TABLE Nganh_ChuyenDe (
    MaNganh VARCHAR(10),
    MaCD VARCHAR(10),
    PRIMARY KEY (MaNganh, MaCD),
    FOREIGN KEY (MaNganh) REFERENCES Nganh(MaNganh) ON DELETE CASCADE,
    FOREIGN KEY (MaCD) REFERENCES ChuyenDe(MaCD) ON DELETE CASCADE
);

-- Bảng DANGKY (Đăng ký học)
CREATE TABLE DangKyChuyenDe (
    MaSV VARCHAR(10),
    MaCD VARCHAR(10),
    NamHoc INT CHECK (NamHoc>=20),
    HocKy VARCHAR(10) CHECK (HocKy IN ('1','2')),
    PRIMARY KEY (MaSV, MaCD, NamHoc, HocKy),
    FOREIGN KEY (MaSV) REFERENCES SinhVien(MaSV) ON DELETE CASCADE,
    FOREIGN KEY (MaCD) REFERENCES ChuyenDe(MaCD) ON DELETE CASCADE,
);

-- Bảng MOLOP (Mở lớp học phần)
CREATE TABLE MoChuyenDe (
    MaCD VARCHAR(10),
    NamHoc INT CHECK (NamHoc >=2000),
    HocKy VARCHAR(10) CHECK (HocKy IN ('1','2')),
    PRIMARY KEY (MaCD, NamHoc, HocKy),
    FOREIGN KEY (MaCD) REFERENCES ChuyenDe(MaCD) ON DELETE CASCADE,
);

--Them nhieu du lieu hon vao bang Nganh
INSERT INTO Nganh (MaNganh, TenNganh, SoChuyenDePhaiHoc, TongSoSinhVien)
VALUES
('CNTT', N'Công nghệ thông tin', 6, 300),
('QTKD', N'Quản trị kinh doanh', 5, 200),
('KT', N'Kế toán', 4, 150),
('DL', N'Du lich', 4, 120),
('YT', N'Y tế', 5, 180);

--Thêm nhiều dữ liệu vào bảng SinhVien
INSERT INTO SinhVien (MaSV, HoTen, Phai, NgaySinh, DiaChi, MaNganh)
VALUES
('SV001', N'Nguyễn Văn A', 'Nam', '2002-05-10', N'Ha Noi', 'CNTT' ),
('SV002', N'Tran Thị B', 'Nữ', '2003-07-15', N'Hồ Chí Minh', 'QTKD' ),
('SV003', N'Lê Văn C', 'Nam', '2001-09-20', N'Đa Nang', 'KT' ),
('SV004', N'Phạm Thị D', 'Nữ', '2002-12-05', N'Cần Thơ', 'CNTT' ),
('SV005', N'Hoang Văn E', 'Nam', '2002-04-22', N'Hai Phong', 'DL' ),
('SV006', N'Bùi Thị F', 'Nữ', '2003-08-19', N'Hà Nội', 'YT' ),
('SV007', N'Đỗ Văn G', 'Nam', '2000-11-30', N'Huế', 'CNTT' ),
('SV008', N'Nguyễn Thị H', 'Nữ', '2002-03-25', N'Sài Gòn', 'QTKD' ),
('SV009', N'Lê Minh K', 'Nam', '2001-06-10', N'Cần Thơ', 'KT' ),
('SV010', N'Trần Văn M', 'Nam', '2002-09-05', N'Đà Nang', 'DL');

--Thêm nhiều du lieu vao bang ChuyenDe
INSERT INTO ChuyenDe (MaCD, TenCD, SoSinhVienToiDa)
VALUES
('CD001', N'Lập trình Java', 100),
('CD002', N'Quản trị dự án', 80),
('CD003', N'Kế toán doanh nghiệp', 70),
('CD004', N'Lap trinh Python', 100),
('CD005', N'Quản trị nhân sự', 75),
('CD006', N'Thiết kế Web', 90),
('CD007', N'Phân tích dữ liệu', 80),
('CD008', N'Tieng Anh du lich', 60),
('CD009', N'Quản lý khách sạn', 50),
('CD010', N'Y học cơ bản', 70);

--Thêm nhiều dữ liệu vào bảng Nganh_ChuyenDe
INSERT INTO Nganh_ChuyenDe (MaNganh, MaCD)
VALUES
('CNTT','CD001'), ('CNTT','CD004'),('CNTT','CD006'),('CNTT','CD007'),
('QTKD','CD002'), ('QTKD', 'CD005'),
('KT', 'CD003' ),
('DL', 'CD008'), ('DL', 'CD009'),
('YT', 'CD010');

--Thêm nhiều dữ liệu vào bảng MoChuyenDe
INSERT INTO MoChuyenDe (MaCD, NamHoc, Hocky)
VALUES
('CD001', 2024, '1'), ('CD004', 2024, '1'), ('CD006', 2024, '1'),
('CD002', 2024, '2'), ('CD005', 2024, '2'), ('CD007', 2024, '2'),
('CD003', 2024, '1'), ('CD008', 2024, '2'), ('CD009', 2024, '1'),
('CD010', 2024, '2');

-- Them nhieu du lieu vao bang DangKyChuyenDe
INSERT INTO DangKyChuyenDe (MaSV, MaCD, NamHoc, Hocky)
VALUES
('SV001', 'CD001', 2024, '1'), ('SV001', 'CD004', 2024, '1'), ('SV001', 'CD006', 2024, '1'),
('SV002', 'CD002', 2024, '2'), ('SV002', 'CD005', 2024, '2'),
('SV003', 'CD003', 2024, '1'),
('SV004', 'CD001', 2024, '1'), ('SV004', 'CD007', 2024, '2'),
('SV005', 'CD008', 2024, '2'), ('SV005', 'CD009', 2024, '1'),
('SV006', 'CD010', 2024, '2'),
('SV007', 'CD001', 2024, '1'), ('SV007', 'CD004', 2024, '1'), ('SV007', 'CD007', 2024, '2'),
('SV008', 'CD002', 2024, '2'), ('SV008', 'CD005', 2024, '2'),
('SV009', 'CD003', 2024, '1'),
('SV010', 'CD008', 2024, '2'), ('SV010', 'CD009', 2024, '1');