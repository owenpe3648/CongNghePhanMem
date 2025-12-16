-- ============================================
-- UTH-ConfMS Database Schema
-- Module: Authentication (Users & Roles)
-- Author: Lâm Minh Phú - MSSV: 096206003648
-- Commit: [TP1] Create users table schema
-- ============================================

-- Xóa bảng nếu tồn tại (chỉ dùng khi development)
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS roles CASCADE;

-- ============================================
-- BẢNG: roles (Vai trò người dùng)
-- ============================================
CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    description VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert các role mặc định
INSERT INTO roles (name, description) VALUES
    ('admin', 'Quản trị viên hệ thống - Toàn quyền'),
    ('chair', 'Chủ tịch hội nghị - Quản lý conference'),
    ('reviewer', 'Người phản biện - Đánh giá bài báo'),
    ('author', 'Tác giả - Nộp và theo dõi bài báo');

-- ============================================
-- BẢNG: users (Người dùng)
-- ============================================
CREATE TABLE users (
    id SERIAL PRIMARY KEY,

    -- Thông tin đăng nhập
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,

    -- Thông tin cá nhân
    fullname VARCHAR(255) NOT NULL,
    organization VARCHAR(255),          -- Đơn vị/Trường/Công ty
    phone VARCHAR(20),

    -- Vai trò (Foreign Key đến bảng roles)
    role_id INTEGER REFERENCES roles(id) DEFAULT 4,  -- Mặc định là 'author'

    -- Trạng thái tài khoản
    is_active BOOLEAN DEFAULT TRUE,
    is_verified BOOLEAN DEFAULT FALSE,  -- Email đã xác thực chưa

    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP,

    -- Constraints
    CONSTRAINT email_format CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- ============================================
-- INDEX để tối ưu query
-- ============================================
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role_id);
CREATE INDEX idx_users_active ON users(is_active);

-- ============================================
-- TRIGGER: Auto update updated_at
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- VIEW: users_with_roles (Tiện cho query)
-- ============================================
CREATE OR REPLACE VIEW users_with_roles AS
SELECT
    u.id,
    u.email,
    u.fullname,
    u.organization,
    u.phone,
    r.name as role,
    u.is_active,
    u.is_verified,
    u.created_at,
    u.last_login
FROM users u
JOIN roles r ON u.role_id = r.id;

-- ============================================
-- Sample Data (Dữ liệu mẫu để test)
-- Password: "password123" đã hash bằng bcrypt
-- ============================================
INSERT INTO users (email, password_hash, fullname, organization, role_id, is_verified) VALUES
    ('admin@uth.edu.vn', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/X4.UQC0lXfKXD0Giq', 'Admin System', 'UTH University', 1, TRUE),
    ('chair@uth.edu.vn', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/X4.UQC0lXfKXD0Giq', 'Nguyen Van Chair', 'UTH University', 2, TRUE),
    ('reviewer@uth.edu.vn', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/X4.UQC0lXfKXD0Giq', 'Tran Thi Reviewer', 'UTH University', 3, TRUE),
    ('author@uth.edu.vn', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/X4.UQC0lXfKXD0Giq', 'Le Van Author', 'UTH University', 4, TRUE);

-- ============================================
-- Verify
-- ============================================
SELECT '=== ROLES ===' as info;
SELECT * FROM roles;

SELECT '=== USERS ===' as info;
SELECT * FROM users_with_roles;
