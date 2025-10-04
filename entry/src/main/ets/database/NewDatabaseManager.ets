import relationalStore from '@ohos.data.relationalStore';
import { Contact, GiftEvent, Inspiration, FavoriteInspiration, ImportantDate, ContactPreference, UserGiftCard, Reminder, AppSettings,
  Achievement,
  AchievementType} from '../model/NewDataModels';

// 节日数据接口
interface HolidayData {
  id: string;
  name: string;
  date: string;
  isRecurring: boolean;
  description: string;
  giftSuggestions: string;
}

// 礼品卡模板数据接口
interface GiftCardTemplateData {
  id: string;
  name: string;
  previewImage: string;
  templatePath: string;
  category: string;
  isDefault: boolean;
}

export class NewDatabaseManager {
  private rdbStore: relationalStore.RdbStore | null = null;
  private readonly DATABASE_NAME = 'LuckyGiftV2.db';
  private readonly DATABASE_VERSION = 3;

  async initDatabase(context: Context): Promise<void> {
    const config: relationalStore.StoreConfig = {
      name: this.DATABASE_NAME,
      securityLevel: relationalStore.SecurityLevel.S1
    };

    try {
      this.rdbStore = await relationalStore.getRdbStore(context, config);
      await this.createTables();
      await this.initDefaultData();
    } catch (error) {
      console.error('数据库初始化失败:', error);
      throw new Error(`数据库初始化失败: ${error}`);
    }
  }

  isInitialized(): boolean {
    return this.rdbStore !== null;
  }



  private async createTables(): Promise<void> {
    if (!this.rdbStore) return;

    const tables = [
      // 联系人表
      `CREATE TABLE IF NOT EXISTS contacts (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        relationship TEXT NOT NULL,
        avatar TEXT,
        birthday TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )`,

      // 重要日期表
      `CREATE TABLE IF NOT EXISTS important_dates (
        id TEXT PRIMARY KEY,
        contact_id TEXT NOT NULL,
        name TEXT NOT NULL,
        date TEXT NOT NULL,
        is_recurring INTEGER NOT NULL DEFAULT 1,
        reminder_enabled INTEGER NOT NULL DEFAULT 1,
        reminder_days INTEGER NOT NULL DEFAULT 7,
        FOREIGN KEY (contact_id) REFERENCES contacts (id) ON DELETE CASCADE
      )`,

      // 联系人偏好表
      `CREATE TABLE IF NOT EXISTS contact_preferences (
        id TEXT PRIMARY KEY,
        contact_id TEXT NOT NULL,
        category TEXT NOT NULL,
        content TEXT NOT NULL,
        priority TEXT NOT NULL DEFAULT 'medium',
        FOREIGN KEY (contact_id) REFERENCES contacts (id) ON DELETE CASCADE
      )`,

      // 礼物事件表（时间轴核心）
      `CREATE TABLE IF NOT EXISTS gift_events (
        id TEXT PRIMARY KEY,
        contact_id TEXT NOT NULL,
        contact_name TEXT NOT NULL,
        record_type TEXT NOT NULL DEFAULT 'give', -- 'give'送礼 或 'receive'收礼
        occasion TEXT NOT NULL,
        date TEXT NOT NULL,
        gift_idea TEXT NOT NULL,
        actual_gift TEXT,
        budget REAL NOT NULL DEFAULT 0,
        actual_cost REAL,
        images TEXT, -- JSON数组
        story TEXT,
        reaction TEXT,
        mood TEXT,
        tags TEXT, -- JSON数组
        reminder_set INTEGER NOT NULL DEFAULT 0,
        reminder_date TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (contact_id) REFERENCES contacts (id) ON DELETE CASCADE
      )`,

      // 我的灵感表（用户自己创建的灵感）
      `CREATE TABLE IF NOT EXISTS my_inspirations (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        detailed_description TEXT,
        images TEXT, -- JSON数组，存储图片路径
        tags TEXT, -- JSON数组
        target_audience TEXT, -- JSON数组
        occasions TEXT, -- JSON数组
        interests TEXT, -- JSON数组
        budget_min REAL NOT NULL DEFAULT 0,
        budget_max REAL NOT NULL DEFAULT 0,
        budget_label TEXT NOT NULL DEFAULT '',
        gift_type TEXT NOT NULL,
        difficulty TEXT NOT NULL DEFAULT 'easy',
        time_required TEXT,
        materials TEXT, -- JSON数组
        steps TEXT, -- JSON数组
        tips TEXT, -- JSON数组
        precautions TEXT, -- JSON数组
        gift_wrap_ideas TEXT, -- JSON数组
        presentation_tips TEXT, -- JSON数组
        personalized_tips TEXT, -- JSON数组
        view_count INTEGER NOT NULL DEFAULT 0,
        favorite_count INTEGER NOT NULL DEFAULT 0,
        rating REAL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )`,

      // 收藏的灵感表
      `CREATE TABLE IF NOT EXISTS favorite_inspirations (
        id TEXT PRIMARY KEY,
        inspiration_id TEXT NOT NULL,
        user_id TEXT NOT NULL DEFAULT 'default',
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (inspiration_id) REFERENCES inspirations (id) ON DELETE CASCADE
      )`,

      // 礼物卡模板表
      `CREATE TABLE IF NOT EXISTS gift_card_templates (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        preview_image TEXT NOT NULL,
        template_path TEXT NOT NULL,
        category TEXT NOT NULL,
        is_default INTEGER NOT NULL DEFAULT 0
      )`,

      // 用户礼物卡表
      `CREATE TABLE IF NOT EXISTS user_gift_cards (
        id TEXT PRIMARY KEY,
        template_id TEXT NOT NULL,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        recipient_name TEXT,
        sender_name TEXT,
        created_at TEXT NOT NULL,
        image_path TEXT,
        FOREIGN KEY (template_id) REFERENCES gift_card_templates (id)
      )`,

      // 节日表
      `CREATE TABLE IF NOT EXISTS holidays (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        date TEXT NOT NULL,
        is_recurring INTEGER NOT NULL DEFAULT 1,
        description TEXT,
        gift_suggestions TEXT, -- JSON数组
        icon TEXT
      )`,

      // 提醒表
      `CREATE TABLE IF NOT EXISTS reminders (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        related_id TEXT NOT NULL,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        reminder_date TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        is_triggered INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )`,

      // 礼物故事表
      `CREATE TABLE IF NOT EXISTS gift_stories (
        id TEXT PRIMARY KEY,
        gift_event_id TEXT NOT NULL,
        gift_event_title TEXT NOT NULL,
        contact_name TEXT NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        images TEXT, -- JSON数组，最多3张照片路径
        emotion TEXT,
        reason TEXT,
        scene TEXT,
        tags TEXT, -- JSON数组
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (gift_event_id) REFERENCES gift_events (id) ON DELETE CASCADE
      )`,

      // 成就模板表（固定的成就定义）
      `CREATE TABLE IF NOT EXISTS achievements (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        icon TEXT NOT NULL,
        type TEXT NOT NULL,
        condition_type TEXT NOT NULL,
        target_value INTEGER NOT NULL,
        time_window INTEGER,
        specific_value TEXT
      )`,

      // 用户成就进度表（每个用户的个人成就进度）
      `CREATE TABLE IF NOT EXISTS user_achievement_progress (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL DEFAULT 'default',
        achievement_id TEXT NOT NULL,
        current_progress INTEGER NOT NULL DEFAULT 0,
        is_unlocked INTEGER NOT NULL DEFAULT 0,
        unlocked_at TEXT,
        last_updated TEXT NOT NULL,
        FOREIGN KEY (achievement_id) REFERENCES achievements (id) ON DELETE CASCADE
      )`,

      // 成就里程碑表
      `CREATE TABLE IF NOT EXISTS achievement_milestones (
        id TEXT PRIMARY KEY,
        achievement_id TEXT NOT NULL,
        date TEXT NOT NULL,
        description TEXT NOT NULL,
        related_event_id TEXT,
        FOREIGN KEY (achievement_id) REFERENCES achievements (id) ON DELETE CASCADE
      )`,

      // 时间轴事件表
      `CREATE TABLE IF NOT EXISTS timeline_events (
        id TEXT PRIMARY KEY,
        contact_id TEXT NOT NULL,
        contact_name TEXT NOT NULL,
        contact_avatar TEXT,
        type TEXT NOT NULL, -- 'meet', 'friend', 'close', 'conflict', 'reconcile', 'gift', 'milestone', 'memory'
        title TEXT NOT NULL,
        description TEXT,
        date TEXT NOT NULL,
        emotion_level INTEGER NOT NULL DEFAULT 3, -- 1-5
        tags TEXT, -- JSON数组
        photos TEXT, -- JSON数组
        location TEXT,
        weather TEXT,
        mood TEXT NOT NULL,
        is_important INTEGER NOT NULL DEFAULT 0,
        related_gift_id TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (contact_id) REFERENCES contacts (id) ON DELETE CASCADE
      )`,

      // 份子礼记录表
      `CREATE TABLE IF NOT EXISTS fenzi_gift_records (
        id TEXT PRIMARY KEY,
        contact_id TEXT NOT NULL,
        contact_name TEXT NOT NULL,
        type TEXT NOT NULL, -- wedding, birthday, housewarming, baby_shower, graduation, promotion, other
        occasion TEXT NOT NULL,
        amount REAL NOT NULL,
        direction TEXT NOT NULL, -- sent, received
        date TEXT NOT NULL,
        location TEXT,
        note TEXT,
        photos TEXT, -- JSON数组
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (contact_id) REFERENCES contacts (id) ON DELETE CASCADE
      )`,

      // 应用设置表
      `CREATE TABLE IF NOT EXISTS app_settings (
        id TEXT PRIMARY KEY DEFAULT 'default',
        default_reminder_days INTEGER NOT NULL DEFAULT 7,
        enable_notifications INTEGER NOT NULL DEFAULT 1,
        data_backup_enabled INTEGER NOT NULL DEFAULT 1,
        last_backup_date TEXT,
        theme_mode TEXT NOT NULL DEFAULT 'auto',
        language TEXT NOT NULL DEFAULT 'zh-CN',
        privacy_mode INTEGER NOT NULL DEFAULT 0
      )`,

      // 备忘表
      `CREATE TABLE IF NOT EXISTS quick_records (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        date TEXT NOT NULL,
        tags TEXT NOT NULL DEFAULT '[]',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )`,

      // 我的心愿表
      `CREATE TABLE IF NOT EXISTS my_wishes (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL, -- gift, experience, travel, learning, health, career, relationship, hobby, other
        priority TEXT NOT NULL, -- low, medium, high, urgent
        status TEXT NOT NULL, -- active, achieved, cancelled, postponed
        target_date TEXT,
        estimated_cost REAL DEFAULT 0,
        actual_cost REAL DEFAULT 0,
        tags TEXT NOT NULL DEFAULT '[]', -- JSON数组
        images TEXT NOT NULL DEFAULT '[]', -- JSON数组
        notes TEXT,
        progress INTEGER NOT NULL DEFAULT 0, -- 0-100
        related_contacts TEXT NOT NULL DEFAULT '[]', -- JSON数组
        inspiration_source TEXT,
        achieved_date TEXT,
        achievement_notes TEXT,
        reminder_enabled INTEGER NOT NULL DEFAULT 0,
        reminder_date TEXT,
        is_public INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )`
    ];

    for (const sql of tables) {
      await this.rdbStore.executeSql(sql);
    }

    // 创建索引
    const indexes = [
      'CREATE INDEX IF NOT EXISTS idx_gift_events_date ON gift_events (date)',
      'CREATE INDEX IF NOT EXISTS idx_gift_events_contact ON gift_events (contact_id)',
      'CREATE INDEX IF NOT EXISTS idx_important_dates_contact ON important_dates (contact_id)',
      'CREATE INDEX IF NOT EXISTS idx_reminders_date ON reminders (reminder_date)',
      'CREATE INDEX IF NOT EXISTS idx_timeline_events_date ON timeline_events (date)',
      'CREATE INDEX IF NOT EXISTS idx_timeline_events_contact ON timeline_events (contact_id)',
      'CREATE INDEX IF NOT EXISTS idx_timeline_events_type ON timeline_events (type)',
      'CREATE INDEX IF NOT EXISTS idx_fenzi_gift_records_date ON fenzi_gift_records (date)',
      'CREATE INDEX IF NOT EXISTS idx_fenzi_gift_records_contact ON fenzi_gift_records (contact_id)',
      'CREATE INDEX IF NOT EXISTS idx_fenzi_gift_records_direction ON fenzi_gift_records (direction)',
      'CREATE INDEX IF NOT EXISTS idx_fenzi_gift_records_type ON fenzi_gift_records (type)',
      'CREATE INDEX IF NOT EXISTS idx_my_wishes_status ON my_wishes (status)',
      'CREATE INDEX IF NOT EXISTS idx_my_wishes_category ON my_wishes (category)',
      'CREATE INDEX IF NOT EXISTS idx_my_wishes_priority ON my_wishes (priority)',
      'CREATE INDEX IF NOT EXISTS idx_my_wishes_target_date ON my_wishes (target_date)',
      'CREATE INDEX IF NOT EXISTS idx_my_wishes_created_at ON my_wishes (created_at)'
    ];

    for (const sql of indexes) {
      await this.rdbStore.executeSql(sql);
    }
  }

  private async initDefaultData(): Promise<void> {
    if (!this.rdbStore) return;

    try {
      // 检查是否已有默认设置
      const settingsCount = await this.rdbStore.querySql('SELECT COUNT(*) as count FROM app_settings');
      if (settingsCount.goToFirstRow() && settingsCount.getLong(0) === 0) {
        // 插入默认设置
        await this.rdbStore.executeSql(
          'INSERT INTO app_settings (id) VALUES (?)',
          ['default']
        );
      }
      settingsCount.close();

      // 初始化默认节日数据
      const holidaysCount = await this.rdbStore.querySql('SELECT COUNT(*) as count FROM holidays');
      if (holidaysCount.goToFirstRow() && holidaysCount.getLong(0) === 0) {
        await this.initDefaultHolidays();
      }
      holidaysCount.close();

      // 初始化礼物卡模板
      const templatesCount = await this.rdbStore.querySql('SELECT COUNT(*) as count FROM gift_card_templates');
      if (templatesCount.goToFirstRow() && templatesCount.getLong(0) === 0) {
        await this.initDefaultGiftCardTemplates();
      }
      templatesCount.close();

      // 初始化成就系统
      const achievementsCount = await this.rdbStore.querySql('SELECT COUNT(*) as count FROM achievements');
      if (achievementsCount.goToFirstRow() && achievementsCount.getLong(0) === 0) {
        await this.initDefaultAchievements();
      }
      achievementsCount.close();
    } catch (error) {
      console.error('初始化默认数据失败:', error);
      throw new Error(`初始化默认数据失败: ${error}`);
    }
  }

  private async initDefaultHolidays(): Promise<void> {
    if (!this.rdbStore) return;

    const holidays: HolidayData[] = [
      {
        id: 'spring_festival',
        name: '春节',
        date: '2024-02-10', // 示例日期
        isRecurring: true,
        description: '中国传统新年',
        giftSuggestions: JSON.stringify(['红包', '年货礼盒', '传统工艺品'])
      },
      {
        id: 'valentines_day',
        name: '情人节',
        date: '02-14',
        isRecurring: true,
        description: '浪漫情人节',
        giftSuggestions: JSON.stringify(['鲜花', '巧克力', '珠宝', '浪漫晚餐'])
      },
      {
        id: 'mothers_day',
        name: '母亲节',
        date: '05-12', // 五月第二个周日
        isRecurring: true,
        description: '感恩母亲的节日',
        giftSuggestions: JSON.stringify(['康乃馨', '护肤品', '按摩器', '陪伴时光'])
      },
      {
        id: 'fathers_day',
        name: '父亲节',
        date: '06-16', // 六月第三个周日
        isRecurring: true,
        description: '感恩父亲的节日',
        giftSuggestions: JSON.stringify(['茶叶', '剃须刀', '钱包', '运动用品'])
      },
      {
        id: 'christmas',
        name: '圣诞节',
        date: '12-25',
        isRecurring: true,
        description: '西方传统节日',
        giftSuggestions: JSON.stringify(['圣诞礼盒', '装饰品', '玩具', '美食'])
      }
    ];

    for (const holiday of holidays) {
      await this.rdbStore.executeSql(
        `INSERT INTO holidays (id, name, date, is_recurring, description, gift_suggestions) 
         VALUES (?, ?, ?, ?, ?, ?)`,
        [holiday.id, holiday.name, holiday.date, holiday.isRecurring ? 1 : 0, 
         holiday.description, holiday.giftSuggestions]
      );
    }
  }

  private async initDefaultGiftCardTemplates(): Promise<void> {
    if (!this.rdbStore) return;

    const templates: GiftCardTemplateData[] = [
      {
        id: 'classic_birthday',
        name: '经典生日',
        previewImage: 'assets/templates/classic_birthday_preview.svg',
        templatePath: 'assets/templates/classic_birthday.svg',
        category: '生日',
        isDefault: true
      },
      {
        id: 'romantic_love',
        name: '浪漫爱情',
        previewImage: 'assets/templates/romantic_love_preview.svg',
        templatePath: 'assets/templates/romantic_love.svg',
        category: '爱情',
        isDefault: true
      },
      {
        id: 'warm_family',
        name: '温馨家庭',
        previewImage: 'assets/templates/warm_family_preview.svg',
        templatePath: 'assets/templates/warm_family.svg',
        category: '家庭',
        isDefault: true
      }
    ];

    for (const template of templates) {
      await this.rdbStore.executeSql(
        `INSERT INTO gift_card_templates (id, name, preview_image, template_path, category, is_default) 
         VALUES (?, ?, ?, ?, ?, ?)`,
        [template.id, template.name, template.previewImage, template.templatePath, 
         template.category, template.isDefault ? 1 : 0]
      );
    }
  }

  private async initDefaultAchievements(): Promise<void> {
    if (!this.rdbStore) return;

    // 成就模板数据（固定的7个成就定义）
    interface AchievementTemplateData {
      id: string;
      name: string;
      description: string;
      icon: string;
      type: AchievementType;
      conditionType: AchievementType;
      targetValue: number;
      timeWindow: number | null;
      specificValue: string | null;
    }
    
    const achievementTemplates: AchievementTemplateData[] = [];
    
    // 创建成就模板对象
    const firstGift: AchievementTemplateData = {
      id: 'first_gift',
      name: '初次尝试',
      description: '创建第一个礼物记录',
      icon: '🌟',
      type: AchievementType.GIFT_COUNT,
      conditionType: AchievementType.GIFT_COUNT,
      targetValue: 1,
      timeWindow: null,
      specificValue: null
    };
    achievementTemplates.push(firstGift);

    const heartFull: AchievementTemplateData = {
      id: 'heart_full',
      name: '心意满满',
      description: '累计记录10次送礼',
      icon: '💝',
      type: AchievementType.GIFT_COUNT,
      conditionType: AchievementType.GIFT_COUNT,
      targetValue: 10,
      timeWindow: null,
      specificValue: null
    };
    achievementTemplates.push(heartFull);

    const mindReader: AchievementTemplateData = {
      id: 'mind_reader',
      name: '读心大师',
      description: '收到5次"非常开心"的评价',
      icon: '🎯',
      type: AchievementType.FEEDBACK_QUALITY,
      conditionType: AchievementType.FEEDBACK_QUALITY,
      targetValue: 5,
      timeWindow: null,
      specificValue: '非常开心'
    };
    achievementTemplates.push(mindReader);

    const budgetMaster: AchievementTemplateData = {
      id: 'budget_master',
      name: '预算达人',
      description: '连续3次送礼都在预算内',
      icon: '💰',
      type: AchievementType.BUDGET_CONTROL,
      conditionType: AchievementType.BUDGET_CONTROL,
      targetValue: 3,
      timeWindow: null,
      specificValue: null
    };
    achievementTemplates.push(budgetMaster);

    const holidayPioneer: AchievementTemplateData = {
      id: 'holiday_pioneer',
      name: '节日先锋',
      description: '提前一周设置好重要节日提醒',
      icon: '🎉',
      type: AchievementType.PLANNING_AHEAD,
      conditionType: AchievementType.PLANNING_AHEAD,
      targetValue: 1,
      timeWindow: 7,
      specificValue: null
    };
    achievementTemplates.push(holidayPioneer);

    const giftMaster: AchievementTemplateData = {
      id: 'gift_master',
      name: '送礼达人',
      description: '累计记录25次送礼',
      icon: '🏆',
      type: AchievementType.GIFT_COUNT,
      conditionType: AchievementType.GIFT_COUNT,
      targetValue: 25,
      timeWindow: null,
      specificValue: null
    };
    achievementTemplates.push(giftMaster);

    const emotionExpert: AchievementTemplateData = {
      id: 'emotion_expert',
      name: '情感专家',
      description: '收到10次积极评价',
      icon: '😊',
      type: AchievementType.FEEDBACK_QUALITY,
      conditionType: AchievementType.FEEDBACK_QUALITY,
      targetValue: 10,
      timeWindow: null,
      specificValue: '开心'
    };
    achievementTemplates.push(emotionExpert);

    for (const template of achievementTemplates) {
      await this.rdbStore.executeSql(
        `INSERT INTO achievements (id, name, description, icon, type, condition_type, target_value, time_window, specific_value) 
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [
          template.id,
          template.name,
          template.description,
          template.icon,
          template.type,
          template.conditionType,
          template.targetValue,
          template.timeWindow,
          template.specificValue
        ]
      );
    }
  }

  getRdbStore(): relationalStore.RdbStore | null {
    return this.rdbStore;
  }

  // 关闭数据库
  async closeDatabase(): Promise<void> {
    if (this.rdbStore) {
      await this.rdbStore.close();
      this.rdbStore = null;
    }
  }

  // 生成UUID
  generateId(): string {
    return 'id_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
  }

  // 获取当前时间戳
  getCurrentTimestamp(): string {
    return new Date().toISOString();
  }

  // 清空所有数据（用于重置应用）
  async clearAllData(): Promise<void> {
    if (!this.rdbStore) {
      throw new Error('数据库未初始化');
    }

    const tables = [
      'contacts', 'important_dates', 'contact_preferences', 'gift_events',
      'inspirations', 'favorite_inspirations', 'gift_card_templates',
      'user_gift_cards', 'holidays', 'reminders', 'app_settings'
    ];
    
    for (const table of tables) {
      await this.rdbStore.executeSql(`DELETE FROM ${table}`);
    }
    
    // 重新初始化默认数据
    await this.initDefaultData();
  }
}