### 创建sqllite数据库文件
sqlite3 dagger.db

### 在提示符内执行如下sql
-- ************************************************************
-- SQLite DDL
-- 转换自PostgreSQL
-- ************************************************************

-- 启用外键约束
PRAGMA foreign_keys = ON;

-- 表: auth_user
-- ------------------------------------------------------------

CREATE TABLE auth_user (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  is_superuser BOOLEAN NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT 1,
  username TEXT NOT NULL,
  password TEXT,
  mobile TEXT,
  email TEXT,
  create_at DATETIME NOT NULL,
  last_login_at DATETIME
);

-- 表: log_rule
-- ------------------------------------------------------------

CREATE TABLE log_rule (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  create_at DATETIME,
  key TEXT NOT NULL,
  name TEXT,
  description TEXT,
  summary TEXT,
  log_ql TEXT,
  user_id INTEGER,
  update_at DATETIME,
  level TEXT,
  UNIQUE (key)
);

CREATE INDEX idx_log_rule_user_id ON log_rule (user_id);

-- 表: log_event
-- ------------------------------------------------------------

CREATE TABLE log_event (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  resolve_at DATETIME,
  create_at DATETIME,
  rule_id INTEGER,
  status TEXT NOT NULL,
  count INTEGER,
  FOREIGN KEY (rule_id) REFERENCES log_rule (id)
);

CREATE INDEX idx_log_event_rule_id ON log_event (rule_id);

-- 表: log_event_detail
-- ------------------------------------------------------------

CREATE TABLE log_event_detail (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  starts_at DATETIME,
  summary TEXT,
  labels TEXT,
  description TEXT NOT NULL,
  rule_id INTEGER,
  event_id INTEGER,
  level TEXT,
  FOREIGN KEY (rule_id) REFERENCES log_rule (id),
  FOREIGN KEY (event_id) REFERENCES log_event (id)
);

CREATE INDEX idx_log_event_detail_starts_at ON log_event_detail (starts_at);
CREATE INDEX idx_log_event_detail_rule_id ON log_event_detail (rule_id);
CREATE INDEX idx_log_event_detail_event_id ON log_event_detail (event_id);

-- 表: log_user_group
-- ------------------------------------------------------------

CREATE TABLE log_user_group (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  create_at DATETIME,
  group_name TEXT,
  user_id INTEGER,
  FOREIGN KEY (user_id) REFERENCES auth_user (id)
);

CREATE INDEX idx_log_user_group_user_id ON log_user_group (user_id);

-- 表: log_group
-- ------------------------------------------------------------

CREATE TABLE log_group (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  group_id INTEGER,
  rule_id INTEGER,
  FOREIGN KEY (group_id) REFERENCES log_user_group (id),
  FOREIGN KEY (rule_id) REFERENCES log_rule (id)
);

CREATE INDEX idx_log_group_log_user_group_id ON log_group (group_id);
CREATE INDEX idx_log_group_rule_id ON log_group (rule_id);

-- 表: log_user
-- ------------------------------------------------------------

CREATE TABLE log_user (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  group_id INTEGER,
  user_id INTEGER,
  FOREIGN KEY (group_id) REFERENCES log_user_group (id),
  FOREIGN KEY (user_id) REFERENCES auth_user (id)
);

CREATE INDEX idx_log_user_log_user_group_id ON log_user (group_id);
CREATE INDEX idx_log_user_user_id ON log_user (user_id);

-- 表: log_history
-- ------------------------------------------------------------

CREATE TABLE log_history (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  label_json TEXT,
  create_at DATETIME,
  filter_json TEXT,
  user_id INTEGER,
  log_ql TEXT,
  FOREIGN KEY (user_id) REFERENCES auth_user (id)
);

CREATE INDEX idx_log_history_user_id ON log_history (user_id);

-- 表: log_label
-- ------------------------------------------------------------

CREATE TABLE log_label (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  key TEXT,
  value TEXT,
  rule_id INTEGER,
  FOREIGN KEY (rule_id) REFERENCES log_rule (id)
);

CREATE INDEX idx_log_label_rule_id ON log_label (rule_id);

-- 表: log_snapshot
-- ------------------------------------------------------------

CREATE TABLE log_snapshot (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  count INTEGER,
  create_at DATETIME,
  download_url TEXT,
  user_id INTEGER,
  start_time DATETIME,
  end_time DATETIME,
  dir TEXT,
  FOREIGN KEY (user_id) REFERENCES auth_user (id)
);

CREATE INDEX idx_log_snapshot_user_id ON log_snapshot (user_id);

-- 插入初始数据
INSERT INTO auth_user (is_superuser, is_active, username, password, mobile, email, create_at, last_login_at)
VALUES (1, 1, 'admin', '$2a$10$zqlCha8VIdeXeixuwFDlAerOFaimREojlZdDfqhPn3dwYbdD9T8n6', NULL, NULL, datetime('now'), datetime('now'));



# 查看当前数据库在服务器上的绝对路径
.databases

# 退出当前数据库
.quit
