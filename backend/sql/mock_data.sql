SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- 1. 清空旧数据 (小心操作)
TRUNCATE TABLE `user`;
TRUNCATE TABLE `script`;
TRUNCATE TABLE `session`;
TRUNCATE TABLE `reservation`;
TRUNCATE TABLE `evaluation`;
TRUNCATE TABLE `favorite`;
TRUNCATE TABLE `notice`;

-- 2. 插入用户数据 (密码统一为 123456)
-- 店家 (ID 1-2)
INSERT INTO `user` (`id`, `phone`, `password`, `nickname`, `avatar`, `role`, `create_time`) VALUES 
(1, '13800000001', '123456', '迷雾侦探社', 'https://api.dicebear.com/7.x/adventurer/svg?seed=shop1', 'SHOP', NOW()),
(2, '13800000002', '123456', '第六感剧本杀', 'https://api.dicebear.com/7.x/adventurer/svg?seed=shop2', 'SHOP', NOW());

-- 玩家 (ID 3-7)
INSERT INTO `user` (`id`, `phone`, `password`, `nickname`, `avatar`, `role`, `gender`, `age`, `hobbies`, `create_time`) VALUES 
(3, '13900000001', '123456', '推理狂人', 'https://api.dicebear.com/7.x/avataaars/svg?seed=player1', 'PLAYER', 'MALE', 24, '硬核推理,本格', NOW()),
(4, '13900000002', '123456', '爱哭小鬼', 'https://api.dicebear.com/7.x/avataaars/svg?seed=player2', 'PLAYER', 'FEMALE', 22, '情感沉浸,古风', NOW()),
(5, '13900000003', '123456', '欢乐喜剧人', 'https://api.dicebear.com/7.x/avataaars/svg?seed=player3', 'PLAYER', 'MALE', 26, '欢乐撕逼,机制', NOW()),
(6, '13900000004', '123456', '胆小勿入', 'https://api.dicebear.com/7.x/avataaars/svg?seed=player4', 'PLAYER', 'FEMALE', 23, '恐怖,微恐', NOW()),
(7, '13900000005', '123456', '全能车头', 'https://api.dicebear.com/7.x/avataaars/svg?seed=player5', 'PLAYER', 'MALE', 28, '硬核推理,阵营博弈', NOW());


-- 3. 插入剧本数据
-- 店家1的剧本
INSERT INTO `script` (`id`, `shop_id`, `name`, `type`, `tags`, `people_num`, `min_people`, `max_people`, `duration`, `price`, `cover`, `intro`, `create_time`) VALUES 
(1, 1, '古木吟', '情感沉浸', '情感,古风,校园', 6, 6, 6, 240, 128.00, 'https://image.dummyjson.com/300x400/e6a23c/fff?text=GumuYin', '那是一所名为“古木”的高中，关于它的传说有很多...', NOW()),
(2, 1, '年轮', '硬核推理', '硬核,本格,烧脑', 5, 5, 5, 300, 158.00, 'https://image.dummyjson.com/300x400/909399/fff?text=NianLun', '大雪封山，五个人被困在破庙之中...', NOW()),
(3, 1, '拆迁', '欢乐撕逼', '欢乐,现代,撕逼', 8, 7, 9, 210, 98.00, 'https://image.dummyjson.com/300x400/67c23a/fff?text=ChaiQian', '为了那一笔拆迁款，全家人都疯了！', NOW());

-- 店家2的剧本
INSERT INTO `script` (`id`, `shop_id`, `name`, `type`, `tags`, `people_num`, `min_people`, `max_people`, `duration`, `price`, `cover`, `intro`, `create_time`) VALUES 
(4, 2, '第二十二条校规', '恐怖', '恐怖,变格,校园', 6, 6, 6, 240, 138.00, 'https://image.dummyjson.com/300x400/f56c6c/fff?text=Rule22', '千万不要触犯第二十二条校规...', NOW()),
(5, 2, '青楼', '阵营博弈', '阵营,古风,机制', 7, 7, 7, 270, 148.00, 'https://image.dummyjson.com/300x400/409eff/fff?text=QingLou', '满纸荒唐言，一把辛酸泪。', NOW()),
(6, 2, '病娇男孩的精分日记', '硬核推理', '变格,还原,微恐', 7, 6, 7, 260, 128.00, 'https://image.dummyjson.com/300x400/303133/fff?text=SickBoy', '我叫萧何，我总是做同一个梦...', NOW());


-- 4. 插入场次数据 (Session)
-- 过去的场次 (用于产生评价和历史记录)
INSERT INTO `session` (`id`, `script_id`, `shop_id`, `session_time`, `total_num`, `remain_num`, `price`) VALUES 
(1, 1, 1, DATE_SUB(NOW(), INTERVAL 5 DAY), 6, 0, 128.00), -- 古木吟 (满员)
(2, 2, 1, DATE_SUB(NOW(), INTERVAL 3 DAY), 5, 2, 158.00), -- 年轮 (未满)
(3, 4, 2, DATE_SUB(NOW(), INTERVAL 2 DAY), 6, 0, 138.00); -- 第二十二条校规 (满员)

-- 未来的场次 (用于预约)
INSERT INTO `session` (`id`, `script_id`, `shop_id`, `session_time`, `total_num`, `remain_num`, `price`) VALUES 
(4, 1, 1, DATE_ADD(NOW(), INTERVAL 1 DAY), 6, 6, 128.00), -- 古木吟 (空)
(5, 3, 1, DATE_ADD(NOW(), INTERVAL 2 DAY), 8, 4, 98.00),  -- 拆迁 (部分空)
(6, 5, 2, DATE_ADD(NOW(), INTERVAL 1 DAY), 7, 7, 148.00), -- 青楼 (空)
(7, 6, 2, DATE_ADD(NOW(), INTERVAL 3 DAY), 7, 5, 128.00); -- 病娇 (部分空)


-- 5. 插入预约记录 (Reservation)
-- 玩家3 (推理狂人) 玩过 年轮(id:2)
INSERT INTO `reservation` (`id`, `session_id`, `user_id`, `reserve_num`, `status`, `payment_status`, `order_no`, `has_evaluated`, `create_time`) VALUES 
(1, 2, 3, 1, 1, 1, 'ORD20260220001', 1, DATE_SUB(NOW(), INTERVAL 4 DAY));

-- 玩家4 (爱哭小鬼) 玩过 古木吟(id:1)
INSERT INTO `reservation` (`id`, `session_id`, `user_id`, `reserve_num`, `status`, `payment_status`, `order_no`, `has_evaluated`, `create_time`) VALUES 
(2, 1, 4, 1, 1, 1, 'ORD20260218001', 1, DATE_SUB(NOW(), INTERVAL 6 DAY));

-- 玩家6 (胆小勿入) 玩过 第二十二条校规(id:3)
INSERT INTO `reservation` (`id`, `session_id`, `user_id`, `reserve_num`, `status`, `payment_status`, `order_no`, `has_evaluated`, `create_time`) VALUES 
(3, 3, 6, 2, 1, 1, 'ORD20260222001', 0, DATE_SUB(NOW(), INTERVAL 3 DAY));

-- 玩家5 (欢乐喜剧人) 预约了未来的 拆迁(id:5)
INSERT INTO `reservation` (`id`, `session_id`, `user_id`, `reserve_num`, `status`, `payment_status`, `order_no`, `has_evaluated`, `create_time`) VALUES 
(4, 5, 5, 4, 0, 0, 'ORD20260228001', 0, NOW());


-- 6. 插入评价数据 (Evaluation)
-- 玩家3 评价 年轮 (高分 -> 推荐算法会捕捉 '硬核推理')
INSERT INTO `evaluation` (`id`, `script_id`, `user_id`, `booking_id`, `score`, `content`, `create_time`) VALUES 
(1, 2, 3, 1, 5, '太硬核了！逻辑闭环非常完美，推土机狂喜！', NOW());

-- 玩家4 评价 古木吟 (高分 -> 推荐算法会捕捉 '情感沉浸')
INSERT INTO `evaluation` (`id`, `script_id`, `user_id`, `booking_id`, `score`, `content`, `create_time`) VALUES 
(2, 1, 4, 2, 5, '哭死我了，菠萝头都顶不住，一定要带纸巾！', NOW());


-- 7. 插入收藏数据 (Favorite)
INSERT INTO `favorite` (`user_id`, `script_id`, `create_time`) VALUES 
(3, 6, NOW()), -- 推理狂人 收藏了 病娇
(4, 5, NOW()); -- 爱哭小鬼 收藏了 青楼

-- 8. 插入公告数据 (Notice)
INSERT INTO `notice` (`shop_id`, `content`, `create_time`) VALUES 
(1, '新店开业，全场8折！', NOW()),
(2, '本周五晚上修仙车缺2人，速来！', NOW());

SET FOREIGN_KEY_CHECKS = 1;
