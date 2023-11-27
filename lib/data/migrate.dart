import 'package:askaide/helper/constant.dart';
import 'package:sqflite/sqflite.dart';

/// 执行数据库迁移
Future<void> migrate(db, oldVersion, newVersion) async {
  if (oldVersion <= 1) {
    await db.execute('''
          ALTER TABLE chat_room ADD COLUMN color TEXT;
          UPDATE chat_room SET color = 'FF4CAF50' WHERE category = 'system';
        ''');
  }

  if (oldVersion <= 2) {
    await db.execute('ALTER TABLE chat_message ADD COLUMN extra TEXT;');
    await db.execute('ALTER TABLE chat_message ADD COLUMN model TEXT;');
  }

  if (oldVersion < 5) {
    await db.execute('''
        CREATE TABLE cache (
          `key` TEXT NOT NULL PRIMARY KEY,
          `value` TEXT NOT NULL,
          `created_at` INTEGER,
          `valid_before` INTEGER
        )
        ''');
  }
  if (oldVersion < 6) {
    await db.execute('''
        CREATE TABLE creative_island_history (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          item_id TEXT NOT NULL,
          arguments TEXT NULL,
          prompt TEXT NULL,
          answer TEXT NULL,
          created_at INTEGER NOT NULL
        ) 
      ''');
  }

  if (oldVersion < 7) {
    await db.execute(
        'ALTER TABLE creative_island_history ADD COLUMN task_id TEXT NULL;');
    await db.execute(
        'ALTER TABLE creative_island_history ADD COLUMN status TEXT NULL;');
  }

  if (oldVersion < 10) {
    await db.execute('ALTER TABLE cache ADD COLUMN `group` TEXT NULL;');
  }

  if (oldVersion < 11) {
    await db.execute('''
      CREATE TABLE settings (
        `key` TEXT NOT NULL PRIMARY KEY,
        `value` TEXT NOT NULL
      );
    ''');
  }

  if (oldVersion < 12) {
    await db
        .execute('''ALTER TABLE chat_room ADD COLUMN user_id INTEGER NULL;''');
    await db.execute(
        '''ALTER TABLE creative_island_history ADD COLUMN user_id INTEGER NULL;''');
  }

  if (oldVersion < 13) {
    await db.execute(
        '''ALTER TABLE chat_message ADD COLUMN user_id INTEGER NULL;''');
  }

  if (oldVersion < 14) {
    await db.execute(
        '''ALTER TABLE chat_message ADD COLUMN ref_id INTEGER NULL;''');
    await db.execute(
        '''ALTER TABLE chat_message ADD COLUMN token_consumed INTEGER NULL;''');
    await db.execute(
        '''ALTER TABLE chat_message ADD COLUMN quota_consumed INTEGER NULL;''');
  }

  if (oldVersion < 15) {
    await db.execute('''ALTER TABLE chat_room ADD COLUMN init_message TEXT;''');
    await db.execute(
        '''ALTER TABLE chat_room ADD COLUMN max_context INTEGER DEFAULT 10;''');
  }

  if (oldVersion < 20) {
    await db.execute(
        '''ALTER TABLE chat_message ADD COLUMN chat_history_id INTEGER NULL;''');
    await db.execute('''
        CREATE TABLE chat_history (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NULL,
          room_id INTEGER NOT NULL,
          title TEXT,
          last_message TEXT,
          created_at INTEGER,
          updated_at INTEGER
        )
      ''');
  }

  if (oldVersion < 23) {
    await db.execute('ALTER TABLE chat_history ADD COLUMN model TEXT;');
  }

  if (oldVersion < 24) {
    await db
        .execute('ALTER TABLE chat_message ADD COLUMN server_id INTEGER NULL;');
  }

  if (oldVersion < 25) {
    await db.execute(
        'ALTER TABLE chat_message ADD COLUMN status INTEGER DEFAULT 1;');
  }

  if (oldVersion < 26) {
    await db.execute('ALTER TABLE chat_message ADD COLUMN images TEXT NULL;');
  }
}

/// 数据库初始化
void initDatabase(db, version) async {
  await db.execute('''
        CREATE TABLE chat_room (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NULL,
          name TEXT NOT NULL,
          category TEXT NOT NULL,
          priority INTEGER DEFAULT 0,
          model TEXT NOT NULL,
          icon_data TEXT NOT NULL,
          color TEXT,
          description TEXT,
          system_prompt TEXT,
          init_message TEXT,
          max_context INTEGER DEFAULT 10,
          created_at INTEGER,
          last_active_time INTEGER 
        )
      ''');

  await db.execute('''
        INSERT INTO chat_room (id, name, category, priority, model, icon_data, color, created_at, last_active_time)
        VALUES (1, '随便聊聊', 'system', 99999, '$modelTypeOpenAI:$defaultChatModel', '57683,MaterialIcons', 'FF4CAF50', 1680969581486, ${DateTime.now().millisecondsSinceEpoch});
      ''');

  await db.execute('''
        CREATE TABLE chat_message (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NULL,
          room_id INTEGER NOT NULL,
          chat_history_id INTEGER NULL,
          type TEXT NOT NULL,
          role TEXT NOT NULL,
          user TEXT,
          text TEXT,
          extra TEXT,
          ref_id INTEGER NULL,
          server_id INTEGER NULL,
          status INTEGER DEFAULT 1,
          token_consumed INTEGER NULL,
          quota_consumed INTEGER NULL,
          model TEXT,
          images TEXT NULL,
          ts INTEGER NOT NULL
        )
      ''');

  await db.execute('''
        CREATE TABLE chat_history (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NULL,
          room_id INTEGER NOT NULL,
          title TEXT,
          last_message TEXT,
          model TEXT,
          created_at INTEGER,
          updated_at INTEGER
        )
      ''');

  await db.execute('''
        CREATE TABLE cache (
          `key` TEXT NOT NULL PRIMARY KEY,
          `value` TEXT NOT NULL,
          `group` TEXT NULL,
          `created_at` INTEGER,
          `valid_before` INTEGER
        )
      ''');

  await db.execute('''
        CREATE TABLE creative_island_history (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NULL,
          item_id TEXT NOT NULL,
          arguments TEXT NULL,
          prompt TEXT NULL,
          answer TEXT NULL,
          task_id TEXT NULL,
          status TEXT NULL,
          created_at INTEGER NOT NULL
        ) 
      ''');

  await db.execute('''
      CREATE TABLE settings (
        `key` TEXT NOT NULL PRIMARY KEY,
        `value` TEXT NOT NULL
      );
  ''');

  // await initUserDefaultRooms(db);
}

Future<void> initUserDefaultRooms(Database db, {int? userId}) async {
  await db.execute('''
        INSERT INTO chat_room (name, category, priority, model, icon_data, description, system_prompt, created_at, last_active_time, color, user_id) 
        VALUES ('职业进阶导师', 'global', 0, 'openai:gpt-3.5-turbo', '57683,MaterialIcons', null, '我想让你担任我的职业进阶导师，你的任务是依据我的兴趣、技能和经验，为我提供职业发展建议，帮助我确定最适合的职业。注意，你需要对各种可行的职业类型进行深度研究，并在建议中包含各行业的市场趋势、就业趋势及进入该特定领域需要具备的资格', 1680969581486, ${DateTime.now().millisecondsSinceEpoch}, 'ff2196f3', ${userId ?? 'null'});
  ''');
  await db.execute('''
        INSERT INTO chat_room (name, category, priority, model, icon_data, description, system_prompt, created_at, last_active_time, color, user_id) 
        VALUES ('人生导师', 'global', 0, 'openai:gpt-3.5-turbo', '57683,MaterialIcons', null, '你是一名在个人和职业发展方面拥有丰富经验的人，我希望你成为帮助我定制并实现个人目标和愿景的人生导师。请根据我的需求，为我提供专业的建议和指导，并鼓励我以积极乐观地态度感恩生活，勇于面对困难和挑战，不断突破自我、持续成长，成为珍惜自我，尊重他人，信任可靠，散发积极正能量的人。接下来我会像你进行提问，请称呼我为朋友。', 1680969581486, ${DateTime.now().millisecondsSinceEpoch}, 'ff2196f3', ${userId ?? 'null'});
  ''');
  await db.execute('''
        INSERT INTO chat_room (name, category, priority, model, icon_data, description, system_prompt, created_at, last_active_time, color, user_id) 
        VALUES ('理财顾问', 'global', 0, 'openai:gpt-3.5-turbo', '57683,MaterialIcons', null, '我希望你成为我的理财顾问，为我提供创造性的理财方案并制定出理财计划。你需要考虑投资预算、投资策略和风险管理。在某些情况下，你可能还需要提供有关税收法律法规的建议，以帮助我实现最大化收益', 1680969581486, ${DateTime.now().millisecondsSinceEpoch}, 'ff2196f3', ${userId ?? 'null'});
  ''');
  await db.execute('''
        INSERT INTO chat_room (name, category, priority, model, icon_data, description, system_prompt, created_at, last_active_time, color, user_id) 
        VALUES ('玩乐指南', 'global', 0, 'openai:gpt-3.5-turbo', '57683,MaterialIcons', null, '我希望你是我的专属吃喝玩乐(旅行)达人，在美食、娱乐、旅游等领域拥有丰富的经验。请根据我要求的领域、位置及其他需求，为我推荐几个准确、实用、高质量的好去处，以帮助我拥有更丰富的人生体验', 1680969581486, ${DateTime.now().millisecondsSinceEpoch}, 'ff2196f3', ${userId ?? 'null'});
  ''');
  await db.execute('''
        INSERT INTO chat_room (name, category, priority, model, icon_data, description, system_prompt, created_at, last_active_time, color, user_id) 
        VALUES ('野蛮女友', 'global', 0, 'openai:gpt-3.5-turbo', '57683,MaterialIcons', null, '你是我的野蛮女友，能和我畅谈任何话题。你纯真无邪，性格里带着一丝精灵古怪和小小任性，偶尔会撒撒娇，或对我冷嘲热讽一番，非常可爱。和你聊天时，你常常会使用表情符号或Emoji回应我。另外请称呼我为大懒虫', 1680969581486, ${DateTime.now().millisecondsSinceEpoch}, 'ff2196f3', ${userId ?? 'null'});
  ''');
  await db.execute('''
        INSERT INTO chat_room (name, category, priority, model, icon_data, description, system_prompt, created_at, last_active_time, color, user_id) 
        VALUES ('鸡汤达人', 'global', 0, 'openai:gpt-3.5-turbo', '57683,MaterialIcons', null, '你是一名鸡汤达人。请在和我对话的过程中，使用你擅长的鸡汤式发言进行回答，要求回答饱经沧桑、引经据典、充满智慧和正能量。另外请称呼我为朋友', 1680969581486, ${DateTime.now().millisecondsSinceEpoch}, 'ff2196f3', ${userId ?? 'null'});
  ''');
  await db.execute('''
        INSERT INTO chat_room (name, category, priority, model, icon_data, description, system_prompt, created_at, last_active_time, color, user_id) 
        VALUES ('成语接龙', 'global', 0, 'openai:gpt-3.5-turbo', '57683,MaterialIcons', null, '陪我玩成语接龙游戏，我说一句话或一个成语，你将以最后一个字为作为起始，写一个成语出来', 1680969581486, ${DateTime.now().millisecondsSinceEpoch}, 'ff2196f3', ${userId ?? 'null'});
  ''');
  await db.execute('''
        INSERT INTO chat_room (name, category, priority, model, icon_data, description, system_prompt, created_at, last_active_time, color, user_id) 
        VALUES ('哲学大师', 'global', 0, 'openai:gpt-3.5-turbo', '57683,MaterialIcons', null, '你是一名哲学家。我会提出一些与哲学相关的话题或问题，你的工作就是深入探索这些概念并回答我。这可能涉及到对各种哲学理论的研究、提出新的想法或寻找创造性的解决方案以解决复杂的问题', 1680969581486, ${DateTime.now().millisecondsSinceEpoch}, 'ff2196f3', ${userId ?? 'null'});
  ''');
  await db.execute('''
        INSERT INTO chat_room (name, category, priority, model, icon_data, description, system_prompt, created_at, last_active_time, color, user_id) 
        VALUES ('开心果', 'global', 0, 'openai:gpt-3.5-turbo', '57683,MaterialIcons', null, '你是一个非常幽默的人，是大家心目中的开心果。作为开心果，你总是能用机智逗趣、诙谐幽默的方式回应我，妙语连珠，尽显活力，必要时还会通过讲笑话或调侃等方式来缓解气氛', 1680969581486, ${DateTime.now().millisecondsSinceEpoch}, 'ff2196f3', ${userId ?? 'null'});
  ''');
  await db.execute('''
        INSERT INTO chat_room (name, category, priority, model, icon_data, description, system_prompt, created_at, last_active_time, color, user_id) 
        VALUES ('健身教练', 'global', 0, 'openai:gpt-3.5-turbo', '57683,MaterialIcons', null, '我希望你成为我的私人教练。你的职责是运用运动学科知识、营养建议及其他相关因素，结同时考虑我的生活习惯、目标及当前健身水平，为我制定最适合我的健身计划', 1680969581486, ${DateTime.now().millisecondsSinceEpoch}, 'ff2196f3', ${userId ?? 'null'});
  ''');
}
