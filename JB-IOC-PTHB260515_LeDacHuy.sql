CREATE DATABASE edusmart;

CREATE TABLE students
(
    ma_hv     VARCHAR(10) PRIMARY KEY,
    ho_ten    VARCHAR(100) NOT NULL,
    email     VARCHAR(100) UNIQUE,
    sdt       VARCHAR(15),
    ngay_sinh DATE
);

CREATE TABLE courses
(
    ma_kh       VARCHAR(10) PRIMARY KEY,
    ten_kh      VARCHAR(100) NOT NULL,
    the_loai    VARCHAR(50),
    hoc_phi     NUMERIC(12, 2) CHECK ( hoc_phi >= 0 ),
    so_luong_hv INT DEFAULT 0
);
CREATE TABLE enrollments
(
    ma_dk        VARCHAR(10) PRIMARY KEY,
    ma_hv        VARCHAR(10) NOT NULL,
    FOREIGN KEY (ma_hv) REFERENCES students (ma_hv),
    ma_kh        VARCHAR(10) NOT NULL,
    ngay_dang_ky DATE DEFAULT CURRENT_DATE,
    trang_thai   VARCHAR(50)
);

CREATE TABLE payments
(
    ma_tt       VARCHAR(10) PRIMARY KEY,
    ma_dk       VARCHAR(10) NOT NULL,
    FOREIGN KEY (ma_dk) REFERENCES enrollments (ma_dk),
    phuong_thuc VARCHAR(50),
    ngay_tt     DATE,
    so_tien     NUMERIC(12, 2) CHECK ( so_tien >= 0 )
);

INSERT INTO students
VALUES ('S001', 'Nguyen Van An', 'an.n@example.com', '0981234567', '1999-10-11'),
       ('S002', 'Than Thi Binh', 'binh.t@example.com', '0902345678', '1992-01-02'),
       ('S003', 'Le Minh Chau', 'chau.l@example.com', '0913456789', '2001-11-02'),
       ('S004', 'Pham Quoc Dat', 'dat.p@example.com', '0984567890', '1998-02-11'),
       ('S005', 'Vo Thanh Em', 'em.v@example.com', '0935678901', '1998-03-02');

INSERT INTO courses
VALUES ('C001', 'Python Basic', 'Lập trình', 1200000),
       ('C002', 'Digital Mkt', 'Marketing', 850000),
       ('C003', 'Data Analysis', 'Phân tích dữ liệu', 1500000),
       ('C004', 'UI/UX Design', 'Thiết kế', 1000000),
       ('C005', 'Advanced Java', 'Lập trình', 1800000);

INSERT INTO enrollments
VALUES ('EN001', 'S001', 'C001', '2025-06-01', 'Đang học'),
       ('EN002', 'S002', 'C001', '2025-06-02', 'Hoàn thành'),
       ('EN003', 'S003', 'C001', '2025-06-03', 'Hoàn thành'),
       ('EN004', 'S004', 'C002', '2025-06-04', 'Đã Huỷ'),
       ('EN005', 'S005', 'C003', '2025-06-05', 'Đang học');

INSERT INTO payments
VALUES ('PA001', 'EN001', 'Credit Card', '2025-06-01', 1200000),
       ('PA002', 'EN002', 'E-Wallet', '2025-06-02', 1200000),
       ('PA003', 'EN003', 'Bank Transfer', '2025-06-04', 1200000),
       ('PA004', 'EN004', 'Credit Card', '2025-06-05', 850000);

-- IV thao tac nghiep vu
--   1.  - “Nhân dịp Back-to-School, phòng Tuyển sinh muốn giảm 20% học phí cho tất cả các khóa học thuộc thể loại Lập trình. Hãy thực hiện cập nhật này vào bảng Courses.”
UPDATE courses
SET hoc_phi = hoc_phi * 0.8
WHERE the_loai = 'Lập trình';


--   2.  - “Học viên S001 muốn rút hồ sơ và hủy toàn bộ các khóa học đã đăng ký. Hãy xóa dữ liệu ghi danh của học viên này và các giao dịch thanh toán liên quan. Nếu xảy ra lỗi do ràng buộc FK, hãy giải thích nguyên nhân và đưa ra thứ tự/câu lệnh xóa đúng chuẩn.”
-- Chú thích do payments co rang buoc voi enrollments với ma_dk nên không thể xoá trực tiếp được
DELETE
FROM payments
WHERE ma_dk IN (SELECT ma_dk
                FROM enrollments
                WHERE ma_hv = 'S001');

DELETE
FROM enrollments
WHERE ma_hv = 'S001';

-- 3.    - “Phòng Đào tạo cần danh sách các học viên đã hoàn tất đóng học phí, gồm: mã ĐK, tên học viên, tên khóa học, ngày thanh toán, số tiền. Sắp xếp danh sách theo ngày thanh toán mới nhất”
SELECT e.ma_dk, s.ho_ten, c.ten_kh, p.ngay_tt, p.so_tien
FROM enrollments e
         JOIN students s on e.ma_hv = s.ma_hv
         JOIN courses c on e.ma_kh = c.ma_kh
         JOIN payments p on e.ma_dk = p.ma_dk
ORDER BY p.ngay_tt DESC;
-- 4.     - “Một học viên gọi lên tổng đài xin hỗ trợ nhưng quên mã HV. Khách hàng chỉ nhớ dùng số điện thoại mạng Viettel (đầu số 098) và sinh năm 1998. Hãy truy xuất mã HV, họ tên, số điện thoại để nhân viên tổng đài xác nhận.”
SELECT s.ma_hv, s.ho_ten, s.sdt, s.ngay_sinh
FROM students s
WHERE s.sdt ILIKE '098%'
  AND  date_part('year',s.ngay_sinh) = '1998';
-- 5.    - “Giao diện web quản trị hiển thị mỗi trang 2 khóa học. Hãy viết truy vấn lấy danh sách mã KH, tên KH, học phí cho trang thứ 2 (bỏ qua 2 khóa học đầu tiên).”
SELECT c.ma_kh, c.ten_kh, c.hoc_phi
FROM courses c
ORDER BY c.ma_kh
OFFSET 2;
-- V. Báo cáo & phân tích nghiệp vụ
-- 1.    - “Kế toán cần xuất báo cáo đối chiếu, hiển thị: mã HV, họ tên, tên khóa học và số tiền thanh toán. Lưu ý: Cần hiển thị cả những học viên đã đăng ký nhưng chưa thanh toán (số tiền thanh toán hiển thị là 0 hoặc NULL) - học viên chưa thanh toán sẽ chưa có dữ liệu ở bảng payments”
SELECT s.ma_hv, s.ho_ten, c.ten_kh, COALESCE(p.so_tien, 0)
FROM enrollments e
         JOIN students s on s.ma_hv = e.ma_hv
         JOIN courses c on e.ma_kh = c.ma_kh
         LEFT JOIN payments p on e.ma_dk = p.ma_dk;
-- 2.   Tính KPI & Khóa học "Best-seller":
--     - “Cuối tháng, Giám đốc muốn biết khóa học nào đang thu hút nhất. Hãy liệt kê mã KH, tên KH, tổng số lượt đăng ký, tổng doanh thu (số tiền thực tế thu được). Chỉ hiển thị những khóa học có từ 2 lượt đăng ký trở lên.”
SELECT c.ma_kh, c.ten_kh, COUNT(c.ma_kh), SUM(p.so_tien)
FROM payments p
         JOIN enrollments e on e.ma_dk = p.ma_dk
         JOIN courses c on e.ma_kh = c.ma_kh
GROUP BY c.ma_kh, c.ten_kh
HAVING COUNT(c.ma_kh) >= 2;
--  3.  Thanh tra học phí (Nợ cước):
--     - “Phòng Kế toán phát hiện có học viên đã đăng ký vào học nhưng chưa đóng tiền. Hãy truy xuất mã ĐK, mã HV, họ tên, ngày đăng ký của các trường hợp này để gửi email nhắc nhở.”
SELECT e.ma_dk, s.ho_ten, e.ngay_dang_ky
FROM enrollments e
         JOIN students s on s.ma_hv = e.ma_hv
         LEFT JOIN payments p on e.ma_dk = p.ma_dk
WHERE p.so_tien IS NULL;
-- 4.     - “Hệ thống muốn tặng mã giảm giá cho các học viên có tổng số tiền đã thanh toán từ 1.000.000 VNĐ trở lên. Hãy liệt kê mã HV, họ tên, email và tổng tiền họ đã chi trả.”
SELECT s.ma_hv, s.ho_ten, s.email
FROM payments p
         JOIN public.enrollments e on p.ma_dk = e.ma_dk
         JOIN students s on e.ma_hv = s.ma_hv
GROUP BY s.ma_hv, s.ho_ten, s.email
HAVING SUM(p.so_tien) >= 1000000;
-- VI. View, Trigger, Function/Procedure – Hướng nghiệp vụ thực tế
--   1. View: Khóa học mới ghi danh – vw_RecentEnrollments
CREATE VIEW vw_RecentEnrollments AS
SELECT s.ma_hv, c.ten_kh, e.ngay_dang_ky, e.trang_thai
FROM enrollments e
         JOIN students s on e.ma_hv = s.ma_hv
         JOIN courses c on e.ma_kh = c.ma_kh
WHERE e.ngay_dang_ky >= '2025-06-01'
ORDER BY e.ngay_dang_ky DESC;


-- 2. View: Doanh thu khóa học cao – vw_HighRevenueCourses
CREATE VIEW vm_HighRevenueCourses AS
SELECT c.ten_kh, c.the_loai, sum(p.so_tien) AS "Tong_Doanh_Thu"
FROM payments p
         JOIN enrollments e on e.ma_dk = p.ma_dk
         JOIN courses c on e.ma_kh = c.ma_kh
GROUP BY c.ten_kh, c.the_loai
HAVING sum(p.so_tien) >= 1000000;
-- 3. Trigger: Kiểm tra logic ngày thanh toán – tg_check_payment_date
CREATE OR REPLACE FUNCTION trigger_after_payments()
    RETURNS TRIGGER
AS
$$

DECLARE
    v_ngay_dang_ky DATE;

BEGIN
    SELECT e.ngay_dang_ky
    INTO v_ngay_dang_ky
    FROM enrollments e
    WHERE e.ma_dk = NEW.ma_dk;


--     SELECT p.ngay_tt
--     INTO v_ngay_dang_ky
--     FROM payments p
--     WHERE p.ma_dk = NEW.ma_dk;

--     IF v_ngay_thanh_toan < v_ngay_dang_ky THEN
--         RAISE EXCEPTION 'Ngay Thanh Toanh phai > Ngay Dang Ky';
--     END IF;


    IF NEW.ngay_tt < v_ngay_dang_ky THEN
        RAISE EXCEPTION 'Ngay Thanh Toanh phai > Ngay Dang Ky';
    END IF;

    RETURN NEW;

END;

$$
    LANGUAGE plpgsql;

CREATE TRIGGER tg_check_payment_date
    AFTER UPDATE OR INSERT
    ON payments
    FOR EACH ROW
EXECUTE FUNCTION trigger_after_payments();



--   4. Trigger: Cập nhật sĩ số lớp học – tg_update_student_count
CREATE OR REPLACE FUNCTION trigger_before_update_student()
    RETURNS TRIGGER
AS
$$

BEGIN
    UPDATE courses
    SET so_luong_hv = so_luong_hv + 1
    WHERE ma_kh = NEW.ma_kh;
    RETURN NEW;
END;
$$
    LANGUAGE plpgsql;

CREATE TRIGGER tg_update_student_count
    BEFORE INSERT
    ON enrollments
    FOR EACH ROW
EXECUTE FUNCTION trigger_before_update_student();



-- 5. Procedure: Thêm khóa học mới – sp_add_course
CREATE OR REPLACE PROCEDURE sp_add_course(
    p_ma_kh VARCHAR(10),
    p_ten_kh VARCHAR(100),
    p_the_loai VARCHAR(50),
    p_hoc_phi NUMERIC(12, 2)
)
    LANGUAGE plpgsql
AS
$$

BEGIN

    INSERT INTO courses
    VALUES (p_ma_kh,
            p_ten_kh,
            p_the_loai,
            p_hoc_phi);

END;
$$;

-- CALL sp_add_course('C006', 'C++', 'Lập trình', 360000);

--   6. Procedure: Chuyển đổi khóa học – sp_switch_course
CREATE OR REPLACE PROCEDURE sp_switch_course(
    p_makh_moi VARCHAR(10),
    p_new_dk VARCHAR(10),
    p_makh_cu VARCHAR(10)

)
    LANGUAGE plpgsql
AS
$$
BEGIN
    UPDATE enrollments
    SET ma_kh = p_makh_moi
    WHERE ma_dk = p_new_dk;

    UPDATE courses
    SET so_luong_hv = so_luong_hv - 1
    WHERE ma_kh = p_makh_cu;

    UPDATE courses
    SET so_luong_hv = so_luong_hv + 1
    WHERE ma_kh = p_makh_moi;

END;
$$;

-- CALL sp_switch_course('C005','EN005','C003');












