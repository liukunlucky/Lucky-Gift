import relationalStore from '@ohos.data.relationalStore';
import { Context } from '@ohos.abilityAccessCtrl';
import { Gift, UserPreferences, FavoriteRecord, BrowsingHistory, SearchHistory, Budget, ExpenseRecord, HolidayReminder, User, GiftCategory, AppSettings, TABLE_NAMES } from '../model/DataModels';

// 数据库管理类
export class DatabaseManager {
  private static instance: DatabaseManager;
  private store: relationalStore.RdbStore | null = null;
  private readonly DB_NAME = 'LuckyGiftDB.db';
  private readonly DB_VERSION = 1;

  private constructor() {}

  public static getInstance(): DatabaseManager {
    if (!DatabaseManager.instance) {
      DatabaseManager.instance = new DatabaseManager();
    }
    return DatabaseManager.instance;
  }

  // 初始化数据库
  public async initDatabase(context: Context): Promise<void> {
    try {
      const config: relationalStore.StoreConfig = {
        name: this.DB_NAME,
        securityLevel: relationalStore.SecurityLevel.S1
      };

      this.store = await relationalStore.getRdbStore(context, config);
      await this.createTables();
      console.info('数据库初始化成功');
    } catch (error) {
      console.error('数据库初始化失败:', error);
      throw new Error(`数据库初始化失败: ${error}`);
    }
  }

  // 创建所有表
  private async createTables(): Promise<void> {
    if (!this.store) {
      throw new Error('数据库未初始化');
    }

    const tables = [
      this.createGiftsTable(),
      this.createUserPreferencesTable(),
      this.createTargetProfilesTable(),
      this.createFavoriteRecordsTable(),
      this.createBrowsingHistoryTable(),
      this.createSearchHistoryTable(),
      this.createBudgetsTable(),
      this.createExpenseRecordsTable(),
      this.createHolidayRemindersTable(),
      this.createUsersTable(),
      this.createGiftCategoriesTable(),
      this.createAppSettingsTable()
    ];

    for (const sql of tables) {
      await this.store.executeSql(sql);
    }
  }

  // 创建礼物表
  private createGiftsTable(): string {
    return `
      CREATE TABLE IF NOT EXISTS ${TABLE_NAMES.GIFTS} (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        category TEXT NOT NULL,
        subcategory TEXT,
        price REAL NOT NULL,
        priceRange TEXT NOT NULL,
        imageUrl TEXT,
        images TEXT, -- JSON字符串
        brand TEXT,
        rating REAL DEFAULT 0,
        reviewCount INTEGER DEFAULT 0,
        tags TEXT, -- JSON字符串
        scenarios TEXT, -- JSON字符串
        targetGender TEXT,
        targetAge TEXT,
        relationship TEXT, -- JSON字符串
        meaning TEXT,
        culturalBackground TEXT,
        availability INTEGER DEFAULT 1,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    `;
  }

  // 创建用户偏好表
  private createUserPreferencesTable(): string {
    return `
      CREATE TABLE IF NOT EXISTS ${TABLE_NAMES.USER_PREFERENCES} (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        preferredCategories TEXT, -- JSON字符串
        preferredPriceRange TEXT,
        preferredBrands TEXT, -- JSON字符串
        preferredTags TEXT, -- JSON字符串
        blacklistedCategories TEXT, -- JSON字符串
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    `;
  }

  // 创建目标人群画像表
  private createTargetProfilesTable(): string {
    return `
      CREATE TABLE IF NOT EXISTS ${TABLE_NAMES.TARGET_PROFILES} (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        name TEXT NOT NULL,
        gender TEXT,
        age TEXT,
        relationship TEXT,
        interests TEXT, -- JSON字符串
        preferredGifts TEXT, -- JSON字符串
        notes TEXT
      )
    `;
  }

  // 创建收藏记录表
  private createFavoriteRecordsTable(): string {
    return `
      CREATE TABLE IF NOT EXISTS ${TABLE_NAMES.FAVORITE_RECORDS} (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        giftId TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        notes TEXT,
        FOREIGN KEY (giftId) REFERENCES ${TABLE_NAMES.GIFTS}(id)
      )
    `;
  }

  // 创建浏览历史表
  private createBrowsingHistoryTable(): string {
    return `
      CREATE TABLE IF NOT EXISTS ${TABLE_NAMES.BROWSING_HISTORY} (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        giftId TEXT NOT NULL,
        viewedAt TEXT NOT NULL,
        viewDuration INTEGER,
        FOREIGN KEY (giftId) REFERENCES ${TABLE_NAMES.GIFTS}(id)
      )
    `;
  }

  // 创建搜索历史表
  private createSearchHistoryTable(): string {
    return `
      CREATE TABLE IF NOT EXISTS ${TABLE_NAMES.SEARCH_HISTORY} (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        keyword TEXT NOT NULL,
        filters TEXT, -- JSON字符串
        resultCount INTEGER,
        searchedAt TEXT NOT NULL
      )
    `;
  }

  // 创建预算表
  private createBudgetsTable(): string {
    return `
      CREATE TABLE IF NOT EXISTS ${TABLE_NAMES.BUDGETS} (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        name TEXT NOT NULL,
        totalAmount REAL NOT NULL,
        usedAmount REAL DEFAULT 0,
        category TEXT,
        startDate TEXT NOT NULL,
        endDate TEXT NOT NULL,
        isActive INTEGER DEFAULT 1,
        createdAt TEXT NOT NULL
      )
    `;
  }

  // 创建消费记录表
  private createExpenseRecordsTable(): string {
    return `
      CREATE TABLE IF NOT EXISTS ${TABLE_NAMES.EXPENSE_RECORDS} (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        budgetId TEXT,
        giftId TEXT NOT NULL,
        amount REAL NOT NULL,
        recipient TEXT NOT NULL,
        occasion TEXT NOT NULL,
        purchaseDate TEXT NOT NULL,
        notes TEXT,
        FOREIGN KEY (giftId) REFERENCES ${TABLE_NAMES.GIFTS}(id),
        FOREIGN KEY (budgetId) REFERENCES ${TABLE_NAMES.BUDGETS}(id)
      )
    `;
  }

  // 创建节日提醒表
  private createHolidayRemindersTable(): string {
    return `
      CREATE TABLE IF NOT EXISTS ${TABLE_NAMES.HOLIDAY_REMINDERS} (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        name TEXT NOT NULL,
        date TEXT NOT NULL,
        recipient TEXT NOT NULL,
        reminderDays INTEGER DEFAULT 7,
        isRecurring INTEGER DEFAULT 0,
        isActive INTEGER DEFAULT 1,
        createdAt TEXT NOT NULL
      )
    `;
  }

  // 创建用户表
  private createUsersTable(): string {
    return `
      CREATE TABLE IF NOT EXISTS ${TABLE_NAMES.USERS} (
        id TEXT PRIMARY KEY,
        nickname TEXT NOT NULL,
        avatar TEXT,
        gender TEXT,
        age TEXT,
        createdAt TEXT NOT NULL,
        lastLoginAt TEXT NOT NULL
      )
    `;
  }

  // 创建礼物分类表
  private createGiftCategoriesTable(): string {
    return `
      CREATE TABLE IF NOT EXISTS ${TABLE_NAMES.GIFT_CATEGORIES} (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        parentId TEXT,
        icon TEXT NOT NULL,
        description TEXT,
        sortOrder INTEGER DEFAULT 0,
        isActive INTEGER DEFAULT 1
      )
    `;
  }

  // 创建应用设置表
  private createAppSettingsTable(): string {
    return `
      CREATE TABLE IF NOT EXISTS ${TABLE_NAMES.APP_SETTINGS} (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        theme TEXT DEFAULT 'light',
        language TEXT DEFAULT 'zh-CN',
        notifications TEXT, -- JSON字符串
        privacy TEXT, -- JSON字符串
        updatedAt TEXT NOT NULL
      )
    `;
  }

  // 获取数据库实例
  public getStore(): relationalStore.RdbStore | null {
    return this.store;
  }

  // 生成UUID
  public generateId(): string {
    return 'id_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
  }

  // 获取当前时间戳
  public getCurrentTimestamp(): string {
    return new Date().toISOString();
  }

  // 关闭数据库
  public async closeDatabase(): Promise<void> {
    if (this.store) {
      await this.store.close();
      this.store = null;
      console.info('数据库已关闭');
    }
  }

  // 清空所有数据（用于重置应用）
  public async clearAllData(): Promise<void> {
    if (!this.store) {
      throw new Error('数据库未初始化');
    }

    const tables: string[] = Object.values(TABLE_NAMES);
    for (const table of tables) {
      await this.store.executeSql(`DELETE FROM ${table}`);
    }
    console.info('所有数据已清空');
  }
}