USE master;
GO

-- 1. Tái tạo database 'vunven' để đảm bảo dữ liệu mới tinh
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'vunven')
BEGIN
    ALTER DATABASE vunven SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE vunven;
END
GO

CREATE DATABASE vunven;
GO

USE vunven;
GO

-- 2. Tạo Login SQL Server 'vunven' nếu chưa tồn tại và cấp quyền db_owner
IF NOT EXISTS (SELECT name FROM sys.server_principals WHERE name = 'vunven')
BEGIN
    CREATE LOGIN vunven WITH PASSWORD = 'Password123', DEFAULT_DATABASE = vunven, CHECK_EXPIRATION = OFF, CHECK_POLICY = OFF;
END
GO

IF NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'vunven')
BEGIN
    CREATE USER vunven FOR LOGIN vunven;
    ALTER ROLE db_owner ADD MEMBER vunven;
END
GO

-- 3. Tạo các bảng dữ liệu
CREATE TABLE users (
    id VARCHAR(50) PRIMARY KEY,
    username NVARCHAR(100) NOT NULL,
    streak_count INT DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT GETDATE()
);

CREATE TABLE wallets (
    id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES users(id) ON DELETE CASCADE,
    name NVARCHAR(100) NOT NULL,
    balance FLOAT NOT NULL DEFAULT 0.0,
    frozen_balance FLOAT NOT NULL DEFAULT 0.0,
    currency VARCHAR(10) DEFAULT 'VND',
    icon NVARCHAR(50),
    color_index INT,
    type NVARCHAR(50),
    is_default BIT DEFAULT 0,
    updated_at DATETIME
);

CREATE TABLE categories (
    id VARCHAR(50) PRIMARY KEY,
    name NVARCHAR(100) NOT NULL,
    icon NVARCHAR(50),
    type VARCHAR(20) NOT NULL, -- income, expense, both
    color VARCHAR(20),
    is_system BIT DEFAULT 1
);

CREATE TABLE challenges (
    id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES users(id),
    wallet_id VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES wallets(id),
    title NVARCHAR(200) NOT NULL,
    description NVARCHAR(MAX),
    icon NVARCHAR(50),
    spend_limit FLOAT NOT NULL DEFAULT 0.0,
    bet_amount FLOAT NOT NULL DEFAULT 0.0,
    start_date DATETIME NOT NULL,
    end_date DATETIME NOT NULL,
    status VARCHAR(20) DEFAULT 'active', -- pending, active, completed, failed, forfeited
    actual_spent FLOAT DEFAULT 0.0,
    category_ids NVARCHAR(MAX), -- JSON array e.g., ["food", "shopping"]
    current_streak INT DEFAULT 0,
    shields INT DEFAULT 0,
    max_violations INT DEFAULT 1,
    current_violations INT DEFAULT 0,
    is_ai_duel BIT DEFAULT 0,
    ai_spent FLOAT DEFAULT 0.0,
    daily_spending NVARCHAR(MAX) -- JSON array of doubles e.g., [120000.0, 45000.0]
);

CREATE TABLE transactions (
    id VARCHAR(50) PRIMARY KEY,
    wallet_id VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES wallets(id) ON DELETE CASCADE,
    category_id VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES categories(id),
    category_enum VARCHAR(50),
    challenge_id VARCHAR(50) FOREIGN KEY REFERENCES challenges(id) ON DELETE SET NULL,
    amount FLOAT NOT NULL,
    type VARCHAR(20) NOT NULL, -- income, expense
    title NVARCHAR(200) NOT NULL,
    note NVARCHAR(MAX),
    date DATETIME NOT NULL,
    created_at DATETIME DEFAULT GETDATE()
);

CREATE TABLE frozen_funds (
    id VARCHAR(50) PRIMARY KEY,
    wallet_id VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES wallets(id),
    challenge_id VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES challenges(id),
    amount FLOAT NOT NULL,
    status VARCHAR(20) NOT NULL, -- locked, releasedReturned, releasedLost
    created_at DATETIME NOT NULL DEFAULT GETDATE(),
    released_at DATETIME
);

CREATE TABLE achievements (
    id VARCHAR(50) PRIMARY KEY,
    title NVARCHAR(200) NOT NULL,
    description NVARCHAR(MAX),
    icon_key VARCHAR(50)
);

CREATE TABLE user_achievements (
    user_id VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES users(id) ON DELETE CASCADE,
    achievement_id VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES achievements(id) ON DELETE CASCADE,
    unlocked_at DATETIME NOT NULL,
    PRIMARY KEY (user_id, achievement_id)
);

CREATE TABLE notifications (
    id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES users(id) ON DELETE CASCADE,
    title NVARCHAR(200) NOT NULL,
    body NVARCHAR(MAX),
    status VARCHAR(20) DEFAULT 'pending', -- pending, delivered, read
    scheduled_at DATETIME NOT NULL
);
GO

-- 4. Chèn dữ liệu mẫu (Seed Data)
INSERT INTO users (id, username, streak_count, created_at)
VALUES ('user123', N'Người dùng', 5, DATEADD(day, -30, GETDATE()));

INSERT INTO wallets (id, user_id, name, balance, frozen_balance, currency, icon, color_index, type, is_default, updated_at)
VALUES 
('w1', 'user123', N'Ví Tiền Mặt', 2450000, 150000, 'VND', N'💵', 0, N'Tiền mặt', 1, GETDATE()),
('w2', 'user123', N'Vietcombank', 15780000, 100000, 'VND', N'🏦', 1, N'Ngân hàng', 0, GETDATE()),
('w3', 'user123', N'MoMo', 830000, 0, 'VND', N'📱', 2, N'Ví điện tử', 0, GETDATE());

INSERT INTO categories (id, name, icon, type, color, is_system)
VALUES 
('food', N'Ăn uống', N'🍜', 'expense', '#FF9800', 1),
('transport', N'Di chuyển', N'🚗', 'expense', '#03A9F4', 1),
('shopping', N'Mua sắm', N'🛍️', 'expense', '#E91E63', 1),
('work', N'Thu nhập', N'💼', 'income', '#4CAF50', 1),
('health', N'Sức khỏe', N'❤️‍🩹', 'expense', '#F44336', 1),
('entertainment', N'Giải trí', N'🎮', 'expense', '#9C27B0', 1),
('other', N'Khác', N'📦', 'expense', '#9E9E9E', 1);

INSERT INTO challenges (id, user_id, wallet_id, title, description, icon, spend_limit, bet_amount, start_date, end_date, status, actual_spent, category_ids, current_streak, shields, max_violations, current_violations, is_ai_duel, ai_spent, daily_spending)
VALUES
('c1', 'user123', 'w2', N'Mua iPhone 15 Pro', N'Tiết kiệm để mua điện thoại mới cuối năm', N'📱', 28000000, 0, GETDATE(), DATEADD(day, 120, GETDATE()), 'active', 12500000, '[]', 12, 0, 1, 0, 0, 0, '[120000.0, 45000.0, 0.0, 250000.0, 60000.0]'),
('c2', 'user123', 'w1', N'Du lịch Đà Lạt', N'Chuyến đi 4 ngày 3 đêm cùng bạn bè', N'🌄', 5000000, 0, GETDATE(), DATEADD(day, 45, GETDATE()), 'active', 3200000, '[]', 4, 0, 1, 0, 0, 0, '[]'),
('c3', 'user123', 'w1', N'Hạn chế ăn ngoài', N'Tự nấu ăn tại nhà để tiết kiệm và an toàn', N'🥗', 2000000, 150000, DATEADD(day, -7, GETDATE()), DATEADD(day, 8, GETDATE()), 'active', 1650000, '["food"]', 7, 1, 2, 0, 0, 0, '[80000.0, 120000.0, 45000.0, 200000.0, 0.0, 95000.0, 110000.0]'),
('c4', 'user123', 'w2', N'Quỹ khẩn cấp 3 tháng', N'Dự phòng tương đương 3 tháng chi phí sinh hoạt', N'🛡️', 15000000, 0, GETDATE(), DATEADD(day, 200, GETDATE()), 'active', 5000000, '[]', 25, 0, 1, 0, 0, 0, '[]'),
('c5', 'user123', 'w2', N'Đấu trí trà sữa với AI', N'Cược chi tiêu ăn vặt xem ai tiết kiệm hơn Vun Vén Bot!', N'🍵', 300000, 100000, GETDATE(), DATEADD(day, 7, GETDATE()), 'active', 120000, '["food"]', 5, 0, 1, 0, 1, 90000, '[30000.0, 45000.0, 0.0, 45000.0, 0.0]');

INSERT INTO transactions (id, wallet_id, category_id, category_enum, challenge_id, amount, type, title, note, date, created_at)
VALUES
('t1', 'w2', 'work', 'work', NULL, 12000000, 'income', N'Lương tháng 7', N'Lương cứng + phụ cấp', DATEADD(day, -1, GETDATE()), DATEADD(day, -1, GETDATE())),
('t2', 'w1', 'food', 'food', 'c3', 65000, 'expense', N'Bữa trưa văn phòng', NULL, DATEADD(hour, -3, GETDATE()), DATEADD(hour, -3, GETDATE())),
('t3', 'w3', 'transport', 'transport', NULL, 45000, 'expense', N'Grab về nhà', NULL, DATEADD(hour, -5, GETDATE()), DATEADD(hour, -5, GETDATE())),
('t4', 'w2', 'shopping', 'shopping', NULL, 490000, 'expense', N'Mua áo UNIQLO', NULL, DATEADD(day, -2, GETDATE()), DATEADD(day, -2, GETDATE())),
('t5', 'w1', 'food', 'food', 'c3', 55000, 'expense', N'Cafe buổi sáng', NULL, DATEADD(day, -2, GETDATE()), DATEADD(day, -2, GETDATE())),
('t6', 'w2', 'health', 'health', NULL, 350000, 'expense', N'Khám sức khỏe định kỳ', NULL, DATEADD(day, -3, GETDATE()), DATEADD(day, -3, GETDATE())),
('t7', 'w3', 'entertainment', 'entertainment', NULL, 180000, 'expense', N'Netflix subscription', NULL, DATEADD(day, -4, GETDATE()), DATEADD(day, -4, GETDATE())),
('t8', 'w2', 'work', 'work', NULL, 3500000, 'income', N'Freelance project', N'Thiết kế UI/UX cho khách hàng mới', DATEADD(day, -5, GETDATE()), DATEADD(day, -5, GETDATE())),
('t9', 'w2', 'shopping', 'shopping', NULL, 680000, 'expense', N'Siêu thị cuối tuần', NULL, DATEADD(day, -6, GETDATE()), DATEADD(day, -6, GETDATE())),
('t10', 'w1', 'transport', 'transport', NULL, 9000, 'expense', N'Đi xe bus', NULL, DATEADD(day, -6, GETDATE()), DATEADD(day, -6, GETDATE()));

INSERT INTO frozen_funds (id, wallet_id, challenge_id, amount, status, created_at)
VALUES
('f1', 'w1', 'c3', 150000, 'locked', DATEADD(day, -7, GETDATE())),
('f2', 'w2', 'c5', 100000, 'locked', GETDATE());

INSERT INTO achievements (id, title, description, icon_key)
VALUES
('ach_1', N'Chiến thần tiết kiệm', N'Hoàn thành 3 thử thách liên tiếp', 'shield'),
('ach_2', N'Kỷ luật thép', N'Đạt chuỗi 15 ngày kỷ luật liên tục', 'fire'),
('ach_3', N'Đấu trí thắng AI', N'Đánh bại Vun Vén Bot trong chế độ đấu AI', 'robot');

INSERT INTO user_achievements (user_id, achievement_id, unlocked_at)
VALUES
('user123', 'ach_1', DATEADD(day, -10, GETDATE())),
('user123', 'ach_2', DATEADD(day, -5, GETDATE()));

INSERT INTO notifications (id, user_id, title, body, status, scheduled_at)
VALUES
('not_1', 'user123', N'Chào mừng bạn 🎉', N'Chào mừng bạn đến với Vún Vén! Hãy bắt đầu hành trình tiết kiệm ngay hôm nay.', 'read', DATEADD(day, -10, GETDATE())),
('not_2', 'user123', N'Cảnh báo ngân sách 🚨', N'Bạn đã tiêu dùng gần đạt hạn mức trong thử thách "Hạn chế ăn ngoài".', 'delivered', GETDATE());
GO
