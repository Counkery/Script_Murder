SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- 1. 修复 evaluation 表：增加 booking_id，并修正外键类型为 bigint
ALTER TABLE `evaluation` 
ADD COLUMN `booking_id` bigint(20) NOT NULL COMMENT '关联的预约ID' AFTER `user_id`,
MODIFY COLUMN `script_id` bigint(20) NOT NULL,
MODIFY COLUMN `user_id` bigint(20) NOT NULL;

-- 2. 修正其他表的外键类型 (与主键 bigint 保持一致)
ALTER TABLE `favorite`
MODIFY COLUMN `user_id` bigint(20) NOT NULL,
MODIFY COLUMN `script_id` bigint(20) NOT NULL;

ALTER TABLE `notice`
MODIFY COLUMN `shop_id` bigint(20) NOT NULL;

-- 3. 为 script 表增加 tags 字段 (用于增强推荐算法)
ALTER TABLE `script` 
ADD COLUMN `tags` varchar(255) DEFAULT NULL COMMENT '标签，逗号分隔，如：微恐,古风,情感';

-- 4. 完善 reservation 表以支持支付功能
ALTER TABLE `reservation` 
ADD COLUMN `payment_status` int(11) DEFAULT 0 COMMENT '0-未支付, 1-已支付, 2-已退款',
ADD COLUMN `order_no` varchar(64) DEFAULT NULL COMMENT '订单号';

-- 5. 补充 v_order_detail 视图 (基于 reservation 表)
DROP VIEW IF EXISTS `v_order_detail`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `v_order_detail` AS 
select 
  r.id AS `order_id`,
  r.order_no AS `order_no`,
  date_format(s.session_time, '%Y-%m-%d') AS `booking_date`,
  date_format(s.session_time, '%H:%i:%s') AS `booking_time`,
  r.reserve_num AS `player_count`,
  (r.reserve_num * s.price) AS `final_price`,
  r.payment_status AS `payment_status`,
  r.status AS `order_status`,
  u.nickname AS `user_name`,
  u.phone AS `phone`
from `reservation` r
left join `session` s on r.session_id = s.id
left join `user` u on r.user_id = u.id;

SET FOREIGN_KEY_CHECKS = 1;
