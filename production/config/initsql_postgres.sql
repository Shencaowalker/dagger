-- ************************************************************
-- PostgreSQL DDL
-- 转换自MySQL
-- ************************************************************

-- 创建数据库 (需要在PostgreSQL中单独执行)
-- CREATE DATABASE log WITH ENCODING 'UTF8';

-- 切换到数据库 (在PostgreSQL中需要在连接时指定)
-- \c log;

-- 表: auth_user
-- ------------------------------------------------------------

CREATE TABLE auth_user (
  id BIGSERIAL NOT NULL PRIMARY KEY,
  is_superuser BOOLEAN NOT NULL DEFAULT FALSE,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  username VARCHAR(128) NOT NULL,
  password VARCHAR(256),
  mobile VARCHAR(32),
  email VARCHAR(128),
  create_at TIMESTAMP NOT NULL,
  last_login_at TIMESTAMP
);

-- 表: log_rule
-- ------------------------------------------------------------

CREATE TABLE log_rule (
  id BIGSERIAL NOT NULL PRIMARY KEY,
  create_at TIMESTAMP,
  key VARCHAR(128) NOT NULL,
  name VARCHAR(64),
  description VARCHAR(2056),
  summary VARCHAR(2056),
  log_ql VARCHAR(512),
  user_id BIGINT,
  update_at TIMESTAMP,
  level VARCHAR(32),
  UNIQUE (key)
);

CREATE INDEX idx_log_rule_user_id ON log_rule (user_id);

-- 表: log_event
-- ------------------------------------------------------------


CREATE TABLE log_event (
  id BIGSERIAL NOT NULL PRIMARY KEY,
  resolve_at TIMESTAMP,
  create_at TIMESTAMP,
  rule_id BIGINT,
  status VARCHAR(24) NOT NULL,
  count INTEGER
);

CREATE INDEX idx_log_event_rule_id ON log_event (rule_id);

-- 表: log_event_detail
-- ------------------------------------------------------------


CREATE TABLE log_event_detail (
  id BIGSERIAL NOT NULL PRIMARY KEY,
  starts_at TIMESTAMP,
  summary VARCHAR(512),
  labels TEXT,
  description TEXT NOT NULL,
  rule_id BIGINT,
  event_id BIGINT,
  level VARCHAR(32)
);

CREATE INDEX idx_log_event_detail_starts_at ON log_event_detail (starts_at);
CREATE INDEX idx_log_event_detail_rule_id ON log_event_detail (rule_id);
CREATE INDEX idx_log_event_detail_event_id ON log_event_detail (event_id);

-- 表: log_user_group
-- ------------------------------------------------------------

CREATE TABLE log_user_group (
  id BIGSERIAL NOT NULL PRIMARY KEY,
  create_at TIMESTAMP,
  group_name VARCHAR(64),
  user_id BIGINT
);

CREATE INDEX idx_log_user_group_user_id ON log_user_group (user_id);

-- 表: log_group
-- ------------------------------------------------------------


CREATE TABLE log_group (
  id BIGSERIAL NOT NULL PRIMARY KEY,
  group_id BIGINT,
  rule_id BIGINT
);

CREATE INDEX idx_log_group_log_user_group_id ON log_group (group_id);
CREATE INDEX idx_log_group_rule_id ON log_group (rule_id);

-- 表: log_user
-- ------------------------------------------------------------


CREATE TABLE log_user (
  id BIGSERIAL NOT NULL PRIMARY KEY,
  group_id BIGINT,
  user_id BIGINT
);

CREATE INDEX idx_log_user_log_user_group_id ON log_user (group_id);
CREATE INDEX idx_log_user_user_id ON log_user (user_id);

-- 表: log_history
-- ------------------------------------------------------------

CREATE TABLE log_history (
  id BIGSERIAL NOT NULL PRIMARY KEY,
  label_json TEXT,
  create_at TIMESTAMP,
  filter_json TEXT,
  user_id BIGINT,
  log_ql VARCHAR(1024)
);

CREATE INDEX idx_log_history_user_id ON log_history (user_id);

-- 表: log_label
-- ------------------------------------------------------------

CREATE TABLE log_label (
  id BIGSERIAL NOT NULL PRIMARY KEY,
  key VARCHAR(128),
  value VARCHAR(128),
  rule_id BIGINT
);

CREATE INDEX idx_log_label_rule_id ON log_label (rule_id);

-- 表: log_snapshot
-- ------------------------------------------------------------

CREATE TABLE log_snapshot (
  id BIGSERIAL NOT NULL PRIMARY KEY,
  name VARCHAR(128) NOT NULL,
  count INTEGER,
  create_at TIMESTAMP,
  download_url VARCHAR(512),
  user_id BIGINT,
  start_time TIMESTAMP,
  end_time TIMESTAMP,
  dir VARCHAR(128)
);

CREATE INDEX idx_log_snapshot_user_id ON log_snapshot (user_id);

-- 外键约束
-- ------------------------------------------------------------

-- log_rule 外键
ALTER TABLE log_rule ADD CONSTRAINT fk_log_rule_user 
  FOREIGN KEY (user_id) REFERENCES auth_user (id);

-- log_event 外键
ALTER TABLE log_event ADD CONSTRAINT fk_log_event_log_rule 
  FOREIGN KEY (rule_id) REFERENCES log_rule (id);

-- log_event_detail 外键
ALTER TABLE log_event_detail ADD CONSTRAINT fk_log_event_detail_log_event 
  FOREIGN KEY (event_id) REFERENCES log_event (id);
ALTER TABLE log_event_detail ADD CONSTRAINT fk_log_event_detail_log_rule 
  FOREIGN KEY (rule_id) REFERENCES log_rule (id);

-- log_group 外键
ALTER TABLE log_group ADD CONSTRAINT fk_log_group_log_rule 
  FOREIGN KEY (rule_id) REFERENCES log_rule (id);
ALTER TABLE log_group ADD CONSTRAINT fk_log_group_log_user_group 
  FOREIGN KEY (group_id) REFERENCES log_user_group (id);

-- log_user 外键
ALTER TABLE log_user ADD CONSTRAINT fk_log_user_log_user_group 
  FOREIGN KEY (group_id) REFERENCES log_user_group (id);
ALTER TABLE log_user ADD CONSTRAINT fk_log_user_user 
  FOREIGN KEY (user_id) REFERENCES auth_user (id);

-- log_user_group 外键
ALTER TABLE log_user_group ADD CONSTRAINT fk_log_user_group_user 
  FOREIGN KEY (user_id) REFERENCES auth_user (id);

-- log_history 外键
ALTER TABLE log_history ADD CONSTRAINT fk_log_history_user 
  FOREIGN KEY (user_id) REFERENCES auth_user (id);

-- log_label 外键
ALTER TABLE log_label ADD CONSTRAINT fk_log_label_log_rule 
  FOREIGN KEY (rule_id) REFERENCES log_rule (id);

-- log_snapshot 外键
ALTER TABLE log_snapshot ADD CONSTRAINT fk_log_snapshot_user 
  FOREIGN KEY (user_id) REFERENCES auth_user (id);

-- 插入初始数据
INSERT INTO auth_user (is_superuser, is_active, username, password, mobile, email, create_at, last_login_at)
VALUES (TRUE, TRUE, 'admin', '$2a$10$zqlCha8VIdeXeixuwFDlAerOFaimREojlZdDfqhPn3dwYbdD9T8n6', NULL, NULL, NOW(), NOW());