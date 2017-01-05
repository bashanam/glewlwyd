-- Create database and user
-- CREATE DATABASE `glewlwyd_dev`;
-- GRANT ALL PRIVILEGES ON glewlwyd_dev.* TO 'glewlwyd'@'%' identified BY 'glewlwyd';
-- FLUSH PRIVILEGES;
-- USE `glewlwyd_dev`;

DROP TABLE IF EXISTS `g_refresh_token_scope`;
DROP TABLE IF EXISTS `g_code_scope`;
DROP TABLE IF EXISTS `g_code`;
DROP TABLE IF EXISTS `g_client_user_scope`;
DROP TABLE IF EXISTS `g_client_authorization_type`;
DROP TABLE IF EXISTS `g_resource_scope`;
DROP TABLE IF EXISTS `g_client_scope`;
DROP TABLE IF EXISTS `g_user_scope`;
DROP TABLE IF EXISTS `g_client_scope`;
DROP TABLE IF EXISTS `g_access_token`;
DROP TABLE IF EXISTS `g_refresh_token`;
DROP TABLE IF EXISTS `g_session`;
DROP TABLE IF EXISTS `g_resource`;
DROP TABLE IF EXISTS `g_redirect_uri`;
DROP TABLE IF EXISTS `g_client`;
DROP TABLE IF EXISTS `g_authorization_type`;
DROP TABLE IF EXISTS `g_scope`;
DROP TABLE IF EXISTS `g_user`;

-- ----------- --
-- Data tables --
-- ----------- --

-- User table, contains registered users with their password encrypted
CREATE TABLE `g_user` (
  `gu_id` INT(11) PRIMARY KEY AUTO_INCREMENT,
  `gu_name` VARCHAR(256) DEFAULT '',
  `gu_email` VARCHAR(256) DEFAULT '',
  `gu_login` VARCHAR(128) NOT NULL UNIQUE,
  `gu_password` VARCHAR(128) NOT NULL,
  `gu_enabled` TINYINT(1) DEFAULT 1
);

-- Scope table, contain all scope values available
CREATE TABLE `g_scope` (
  `gs_id` INT(11) PRIMARY KEY AUTO_INCREMENT,
  `gs_name` VARCHAR(128) NOT NULL,
  `gs_description` VARCHAR(512) DEFAULT ''
);

-- Authorization type table, to store authorization type available
CREATE TABLE `g_authorization_type` (
  `got_id` INT(11) PRIMARY KEY AUTO_INCREMENT,
  `got_code` INT(2) NOT NULL UNIQUE, -- 0: Authorization Code Grant, 1: Code Grant, 2: Implicit Grant, 3: Resource Owner Password Credentials Grant, 4: Client Credentials Grant
  `got_name` VARCHAR(128) NOT NULL,
  `got_description` VARCHAR(256) DEFAULT '',
  `got_enabled` TINYINT(1) DEFAULT 1
);

-- Client table, contains all registered clients with their client_id
CREATE TABLE `g_client` (
  `gc_id` INT(11) PRIMARY KEY AUTO_INCREMENT,
  `gc_name` VARCHAR(128) NOT NULL,
  `gc_description` VARCHAR(256) DEFAULT '',
  `gc_client_id` VARCHAR(128) NOT NULL UNIQUE,
  `gc_client_password` VARCHAR(128) NOT NULL,
  `gc_confidential` TINYINT(1) DEFAULT 0,
  `gc_enabled` TINYINT(1) DEFAULT 1
);

-- Resource table, contains all registered resource server
CREATE TABLE `g_resource` (
  `gr_id` INT(11) PRIMARY KEY AUTO_INCREMENT,
  `gr_name` VARCHAR(128) NOT NULL,
  `gr_description` VARCHAR(256) DEFAULT '',
  `gr_uri` VARCHAR(256)
);

-- Redirect URI, contains all registered redirect_uti values for the clients
CREATE TABLE `g_redirect_uri` (
  `gru_id` INT(11) PRIMARY KEY AUTO_INCREMENT,
  `gc_id` INT(11) NOT NULL,
  `gru_name` VARCHAR(128) NOT NULL,
  `gru_uri` VARCHAR(512),
  FOREIGN KEY(`gc_id`) REFERENCES `g_client`(`gc_id`) ON DELETE CASCADE
);

-- ------------ --
-- Token tables --
-- ------------ --

-- Refresh token table, to store a signature and meta information on all refresh tokens sent
CREATE TABLE `g_refresh_token` (
  `grt_id` INT(11) PRIMARY KEY AUTO_INCREMENT,
  `grt_hash` VARCHAR(32) NOT NULL,
  `grt_authorization_type` INT(2) NOT NULL, -- 0: Authorization Code Grant, 1: Implicit Grant, 2: Resource Owner Password Credentials Grant, 3: Client Credentials Grant
  `grt_username` VARCHAR(128) NOT NULL,
  `grt_issued_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `grt_last_seen` TIMESTAMP,
  `grt_expired_at` TIMESTAMP,
  `grt_ip_source` VARCHAR(64) NOT NULL,
  `grt_enabled` TINYINT(1) DEFAULT 1
);

-- Access token table, to store meta information on access tokensw sent
CREATE TABLE `g_access_token` (
  `gat_id` INT(11) PRIMARY KEY AUTO_INCREMENT,
  `grt_id` INT(11),
  `gat_authorization_type` INT(2) NOT NULL, -- 0: Authorization Code Grant, 1: Implicit Grant, 2: Resource Owner Password Credentials Grant, 3: Client Credentials Grant
  `gat_issued_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `gat_ip_source` VARCHAR(64) NOT NULL,
  FOREIGN KEY(`grt_id`) REFERENCES `g_refresh_token`(`grt_id`) ON DELETE CASCADE
);

-- Session table, to store signature and meta information on session tokens sent
CREATE TABLE `g_session` (
  `gss_id` INT(11) PRIMARY KEY AUTO_INCREMENT,
  `gss_hash` VARCHAR(32) NOT NULL,
  `gss_username` VARCHAR(128) NOT NULL,
  `gss_issued_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `gss_last_seen` TIMESTAMP,
  `gss_expired_at` TIMESTAMP,
  `gss_ip_source` VARCHAR(64) NOT NULL,
  `gss_enabled` TINYINT(1) DEFAULT 1
);

-- -------------- --
-- Linking tables --
-- -------------- --

-- User scope table, to store scope available for each user
CREATE TABLE `g_user_scope` (
  `gus_id` INT(11) PRIMARY KEY AUTO_INCREMENT,
  `gu_id` INT(11) NOT NULL,
  `gs_id` INT(11) NOT NULL,
  FOREIGN KEY(`gu_id`) REFERENCES `g_user`(`gu_id`) ON DELETE CASCADE,
  FOREIGN KEY(`gs_id`) REFERENCES `g_scope`(`gs_id`) ON DELETE CASCADE
);

-- Client scope table, to store scope available for a client on client authentication
CREATE TABLE `g_client_scope` (
  `gcs_id` INT(11) PRIMARY KEY AUTO_INCREMENT,
  `gc_id` INT(11) NOT NULL,
  `gs_id` INT(11) NOT NULL,
  FOREIGN KEY(`gc_id`) REFERENCES `g_client`(`gc_id`) ON DELETE CASCADE,
  FOREIGN KEY(`gs_id`) REFERENCES `g_scope`(`gs_id`) ON DELETE CASCADE
);

-- Resource scope table, to store the scopes provided by the resource server
CREATE TABLE `g_resource_scope` (
  `grs_id` INT(11) PRIMARY KEY AUTO_INCREMENT,
  `gr_id` INT(11) NOT NULL,
  `gs_id` INT(11) NOT NULL,
  FOREIGN KEY(`gr_id`) REFERENCES `g_resource`(`gr_id`) ON DELETE CASCADE,
  FOREIGN KEY(`gs_id`) REFERENCES `g_scope`(`gs_id`) ON DELETE CASCADE
);

-- Client authorization type table, to store authorization types available for the client
CREATE TABLE `g_client_authorization_type` (
  `gcat_id` INT(11) PRIMARY KEY AUTO_INCREMENT,
  `gc_id` INT(11) NOT NULL,
  `got_id` INT(11) NOT NULL,
  FOREIGN KEY(`gc_id`) REFERENCES `g_client`(`gc_id`) ON DELETE CASCADE,
  FOREIGN KEY(`got_id`) REFERENCES `g_authorization_type`(`got_id`) ON DELETE CASCADE
);

-- Client user scope table, to store the authorization of the user to use scope for this client
CREATE TABLE `g_client_user_scope` (
  `gcus_id` INT(11) PRIMARY KEY AUTO_INCREMENT,
  `gc_id` INT(11) NOT NULL,
  `gco_username` VARCHAR(128) NOT NULL,
  `gs_id` INT(11) NOT NULL,
  FOREIGN KEY(`gc_id`) REFERENCES `g_client`(`gc_id`) ON DELETE CASCADE,
  FOREIGN KEY(`gs_id`) REFERENCES `g_scope`(`gs_id`) ON DELETE CASCADE
);

-- Code table, used to store auth code sent with response_type code and validate it with response_type authorization_code
CREATE TABLE `g_code` (
  `gco_id` INT(11) PRIMARY KEY AUTO_INCREMENT,
  `gco_date` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `gco_code_hash` VARCHAR(128) NOT NULL,
  `gco_ip_source` VARCHAR(64) NOT NULL,
  `gco_enabled` TINYINT(1) DEFAULT 1,
  `gc_id` INT(11) NOT NULL,
  `gco_username` VARCHAR(128) NOT NULL,
  `gru_id` INT(11),
  FOREIGN KEY(`gc_id`) REFERENCES `g_client`(`gc_id`) ON DELETE CASCADE,
  FOREIGN KEY(`gru_id`) REFERENCES `g_redirect_uri`(`gru_id`) ON DELETE CASCADE
);

-- Code scope table, used to link a generated code to a list of scopes
CREATE TABLE `g_code_scope` (
  `gcs_id` INT(11) PRIMARY KEY AUTO_INCREMENT,
  `gco_id` INT(11) NOT NULL,
  `gs_id` INT(11) NOT NULL,
  FOREIGN KEY(`gco_id`) REFERENCES `g_code`(`gco_id`) ON DELETE CASCADE,
  FOREIGN KEY(`gs_id`) REFERENCES `g_scope`(`gs_id`) ON DELETE CASCADE
);

-- Refresh token scope table, used to link a generated refresh token to a list of scopes
CREATE TABLE `g_refresh_token_scope` (
  `grts_id` INT(11) PRIMARY KEY AUTO_INCREMENT,
  `grt_id` INT(11) NOT NULL,
  `gs_id` INT(11) NOT NULL,
  FOREIGN KEY(`grt_id`) REFERENCES `g_refresh_token`(`grt_id`) ON DELETE CASCADE,
  FOREIGN KEY(`gs_id`) REFERENCES `g_scope`(`gs_id`) ON DELETE CASCADE
);

INSERT INTO g_authorization_type (got_name, got_code, got_description) VALUES ('authorization_code', 0, 'Authorization Code Grant - Access token: https://tools.ietf.org/html/rfc6749#section-4.1');
INSERT INTO g_authorization_type (got_name, got_code, got_description) VALUES ('code', 1, 'Authorization Code Grant - Authorization: https://tools.ietf.org/html/rfc6749#section-4.1');
INSERT INTO g_authorization_type (got_name, got_code, got_description) VALUES ('token', 2, 'Implicit Grant: https://tools.ietf.org/html/rfc6749#section-4.2');
INSERT INTO g_authorization_type (got_name, got_code, got_description) VALUES ('password', 3, 'Resource Owner Password Credentials Grant: https://tools.ietf.org/html/rfc6749#section-4.3');
INSERT INTO g_authorization_type (got_name, got_code, got_description) VALUES ('client_credentials', 4, 'Client Credentials Grant: https://tools.ietf.org/html/rfc6749#section-4.4');
INSERT INTO g_scope (gs_name, gs_description) VALUES ('g_admin', 'Glewlwyd admin scope');
