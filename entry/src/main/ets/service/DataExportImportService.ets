import { DatabaseManager } from '../database/DatabaseManager';
import { Gift, UserPreferences, FavoriteRecord, BrowsingHistory, Budget, BudgetRecord, HolidayReminder, TABLE_NAMES } from '../model/DataModels';
import relationalStore from '@ohos.data.relationalStore';
import fs from '@ohos.file.fs';
import { Context } from '@ohos.abilityAccessCtrl';

// 导出数据结构
export interface ExportData {
  version: string;
  exportDate: string;
  data: {
    gifts: Gift[];
    userPreferences: UserPreferences[];
    favorites: FavoriteRecord[];
    browseHistory: BrowsingHistory[];
    budgets: Budget[];
    budgetRecords: BudgetRecord[];
    holidayReminders: HolidayReminder[];
  };
}

// 导入结果
export interface ImportResult {
  success: boolean;
  message: string;
  importedCounts: {
    gifts: number;
    userPreferences: number;
    favorites: number;
    browseHistory: number;
    budgets: number;
    budgetRecords: number;
    holidayReminders: number;
  };
}

// 数据导入导出服务
export class DataExportImportService {
  private dbManager: DatabaseManager;
  private context: Context;

  constructor(context: Context) {
    this.dbManager = DatabaseManager.getInstance();
    this.context = context;
  }

  // 导出所有数据
  public async exportAllData(userId?: string): Promise<string | null> {
    try {
      const exportData: ExportData = {
        version: '1.0.0',
        exportDate: new Date().toISOString(),
        data: {
          gifts: await this.exportGifts(),
          userPreferences: await this.exportUserPreferences(userId),
          favorites: await this.exportFavorites(userId),
          browseHistory: await this.exportBrowseHistory(userId),
          budgets: await this.exportBudgets(userId),
          budgetRecords: await this.exportBudgetRecords(userId),
          holidayReminders: await this.exportHolidayReminders(userId)
        }
      };

      const jsonData = JSON.stringify(exportData, null, 2);
      const fileName = `lucky_gift_backup_${new Date().toISOString().split('T')[0]}.json`;
      const filePath = await this.saveToFile(fileName, jsonData);
      
      return filePath;
    } catch (error) {
      console.error('导出数据失败:', error);
      return null;
    }
  }

  // 导出礼物数据
  public async exportGifts(): Promise<Gift[]> {
    const store = this.dbManager.getStore();
    if (!store) {
      throw new Error('数据库未初始化');
    }

    try {
      const predicates = new relationalStore.RdbPredicates(TABLE_NAMES.GIFTS);
      const resultSet = await store.query(predicates);
      const gifts: Gift[] = [];
      
      while (resultSet.goToNextRow()) {
        gifts.push(this.parseGiftFromResultSet(resultSet));
      }
      
      resultSet.close();
      return gifts;
    } catch (error) {
      console.error('导出礼物数据失败:', error);
      return [];
    }
  }

  // 导出用户偏好数据
  public async exportUserPreferences(userId?: string): Promise<UserPreferences[]> {
    const store = this.dbManager.getStore();
    if (!store) {
      throw new Error('数据库未初始化');
    }

    try {
      const predicates = new relationalStore.RdbPredicates(TABLE_NAMES.USER_PREFERENCES);
      if (userId) {
        predicates.equalTo('id', userId);
      }
      
      const resultSet = await store.query(predicates);
      const preferences: UserPreferences[] = [];
      
      while (resultSet.goToNextRow()) {
        preferences.push(this.parseUserPreferencesFromResultSet(resultSet));
      }
      
      resultSet.close();
      return preferences;
    } catch (error) {
      console.error('导出用户偏好数据失败:', error);
      return [];
    }
  }

  // 导出收藏数据
  public async exportFavorites(userId?: string): Promise<FavoriteRecord[]> {
    const store = this.dbManager.getStore();
    if (!store) {
      throw new Error('数据库未初始化');
    }

    try {
      const predicates = new relationalStore.RdbPredicates(TABLE_NAMES.FAVORITE_RECORDS);
      if (userId) {
        predicates.equalTo('userId', userId);
      }
      
      const resultSet = await store.query(predicates);
      const favorites: FavoriteRecord[] = [];
      
      while (resultSet.goToNextRow()) {
        favorites.push(this.parseFavoriteFromResultSet(resultSet));
      }
      
      resultSet.close();
      return favorites;
    } catch (error) {
      console.error('导出收藏数据失败:', error);
      return [];
    }
  }

  // 导出浏览历史数据
  public async exportBrowseHistory(userId?: string): Promise<BrowsingHistory[]> {
    const store = this.dbManager.getStore();
    if (!store) {
      throw new Error('数据库未初始化');
    }

    try {
      const predicates = new relationalStore.RdbPredicates(TABLE_NAMES.BROWSING_HISTORY);
      if (userId) {
        predicates.equalTo('userId', userId);
      }
      
      const resultSet = await store.query(predicates);
      const history: BrowsingHistory[] = [];
      
      while (resultSet.goToNextRow()) {
        history.push(this.parseBrowseHistoryFromResultSet(resultSet));
      }
      
      resultSet.close();
      return history;
    } catch (error) {
      console.error('导出浏览历史数据失败:', error);
      return [];
    }
  }

  // 导出预算数据
  public async exportBudgets(userId?: string): Promise<Budget[]> {
    const store = this.dbManager.getStore();
    if (!store) {
      throw new Error('数据库未初始化');
    }

    try {
      const predicates = new relationalStore.RdbPredicates(TABLE_NAMES.BUDGETS);
      if (userId) {
        predicates.equalTo('userId', userId);
      }
      
      const resultSet = await store.query(predicates);
      const budgets: Budget[] = [];
      
      while (resultSet.goToNextRow()) {
        budgets.push(this.parseBudgetFromResultSet(resultSet));
      }
      
      resultSet.close();
      return budgets;
    } catch (error) {
      console.error('导出预算数据失败:', error);
      return [];
    }
  }

  // 导出预算记录数据
  public async exportBudgetRecords(userId?: string): Promise<BudgetRecord[]> {
    const store = this.dbManager.getStore();
    if (!store) {
      throw new Error('数据库未初始化');
    }

    try {
      const predicates = new relationalStore.RdbPredicates(TABLE_NAMES.BUDGET_RECORDS);
      if (userId) {
        predicates.equalTo('userId', userId);
      }
      
      const resultSet = await store.query(predicates);
      const records: BudgetRecord[] = [];
      
      while (resultSet.goToNextRow()) {
        records.push(this.parseBudgetRecordFromResultSet(resultSet));
      }
      
      resultSet.close();
      return records;
    } catch (error) {
      console.error('导出预算记录数据失败:', error);
      return [];
    }
  }

  // 导出节日提醒数据
  public async exportHolidayReminders(userId?: string): Promise<HolidayReminder[]> {
    const store = this.dbManager.getStore();
    if (!store) {
      throw new Error('数据库未初始化');
    }

    try {
      const predicates = new relationalStore.RdbPredicates(TABLE_NAMES.HOLIDAY_REMINDERS);
      if (userId) {
        predicates.equalTo('userId', userId);
      }
      
      const resultSet = await store.query(predicates);
      const reminders: HolidayReminder[] = [];
      
      while (resultSet.goToNextRow()) {
        reminders.push(this.parseHolidayReminderFromResultSet(resultSet));
      }
      
      resultSet.close();
      return reminders;
    } catch (error) {
      console.error('导出节日提醒数据失败:', error);
      return [];
    }
  }

  // 导入数据
  public async importData(filePath: string, replaceExisting: boolean = false): Promise<ImportResult> {
    try {
      const jsonData = await this.readFromFile(filePath);
      const exportData: ExportData = JSON.parse(jsonData);
      
      // 验证数据格式
      if (!this.validateExportData(exportData)) {
        return {
          success: false,
          message: '数据格式无效',
          importedCounts: this.getEmptyImportCounts()
        };
      }

      const importedCounts = this.getEmptyImportCounts();
      
      // 如果需要替换现有数据，先清空相关表
      if (replaceExisting) {
        await this.clearAllData();
      }

      // 导入各类数据
      importedCounts.gifts = await this.importGifts(exportData.data.gifts, replaceExisting);
      importedCounts.userPreferences = await this.importUserPreferences(exportData.data.userPreferences, replaceExisting);
      importedCounts.favorites = await this.importFavorites(exportData.data.favorites, replaceExisting);
      importedCounts.browseHistory = await this.importBrowseHistory(exportData.data.browseHistory, replaceExisting);
      importedCounts.budgets = await this.importBudgets(exportData.data.budgets, replaceExisting);
      importedCounts.budgetRecords = await this.importBudgetRecords(exportData.data.budgetRecords, replaceExisting);
      importedCounts.holidayReminders = await this.importHolidayReminders(exportData.data.holidayReminders, replaceExisting);

      return {
        success: true,
        message: '数据导入成功',
        importedCounts
      };
    } catch (error) {
      console.error('导入数据失败:', error);
      return {
        success: false,
        message: `导入失败: ${error.message}`,
        importedCounts: this.getEmptyImportCounts()
      };
    }
  }

  // 导入礼物数据
  private async importGifts(gifts: Gift[], replaceExisting: boolean): Promise<number> {
    const store = this.dbManager.getStore();
    if (!store) {
      throw new Error('数据库未初始化');
    }

    let importedCount = 0;
    
    for (const gift of gifts) {
      try {
        const valueBucket: relationalStore.ValuesBucket = {
          id: gift.id,
          name: gift.name,
          description: gift.description,
          category: gift.category,
          priceRange: gift.priceRange,
          brand: gift.brand,
          imageUrl: gift.imageUrl,
          tags: JSON.stringify(gift.tags),
          purchaseLinks: JSON.stringify(gift.purchaseLinks),
          createdAt: gift.createdAt,
          updatedAt: gift.updatedAt
        };

        if (replaceExisting) {
          await store.insert(TABLE_NAMES.GIFTS, valueBucket);
        } else {
          // 检查是否已存在
          const predicates = new relationalStore.RdbPredicates(TABLE_NAMES.GIFTS);
          predicates.equalTo('id', gift.id);
          const resultSet = await store.query(predicates);
          const exists = resultSet.rowCount > 0;
          resultSet.close();
          
          if (!exists) {
            await store.insert(TABLE_NAMES.GIFTS, valueBucket);
          }
        }
        
        importedCount++;
      } catch (error) {
        console.error(`导入礼物 ${gift.id} 失败:`, error);
      }
    }
    
    return importedCount;
  }

  // 导入用户偏好数据
  private async importUserPreferences(preferences: UserPreferences[], replaceExisting: boolean): Promise<number> {
    const store = this.dbManager.getStore();
    if (!store) {
      throw new Error('数据库未初始化');
    }

    let importedCount = 0;
    
    for (const pref of preferences) {
      try {
        const valueBucket: relationalStore.ValuesBucket = {
          id: pref.id,
          preferredCategories: JSON.stringify(pref.preferredCategories || []),
          preferredPriceRange: pref.preferredPriceRange || '',
          preferredBrands: JSON.stringify(pref.preferredBrands || []),
          preferredTags: JSON.stringify(pref.preferredTags || []),
          blacklistedCategories: JSON.stringify(pref.blacklistedCategories || []),
          createdAt: pref.createdAt,
          updatedAt: pref.updatedAt
        };

        if (replaceExisting) {
          await store.insert(TABLE_NAMES.USER_PREFERENCES, valueBucket);
        } else {
          // 检查是否已存在
          const predicates = new relationalStore.RdbPredicates(TABLE_NAMES.USER_PREFERENCES);
          predicates.equalTo('id', pref.id);
          const resultSet = await store.query(predicates);
          const exists = resultSet.rowCount > 0;
          resultSet.close();
          
          if (exists) {
            // 更新
            const updatePredicates = new relationalStore.RdbPredicates(TABLE_NAMES.USER_PREFERENCES);
            updatePredicates.equalTo('id', pref.id);
            await store.update(valueBucket, updatePredicates);
          } else {
            // 插入
            await store.insert(TABLE_NAMES.USER_PREFERENCES, valueBucket);
          }
        }
        
        importedCount++;
      } catch (error) {
        console.error(`导入用户偏好 ${pref.id} 失败:`, error);
      }
    }
    
    return importedCount;
  }

  // 导入收藏数据
  private async importFavorites(favorites: FavoriteRecord[], replaceExisting: boolean): Promise<number> {
    const store = this.dbManager.getStore();
    if (!store) {
      throw new Error('数据库未初始化');
    }

    let importedCount = 0;
    
    for (const favorite of favorites) {
      try {
        const valueBucket: relationalStore.ValuesBucket = {
          id: favorite.id,
          userId: favorite.userId,
          giftId: favorite.giftId,
          createdAt: favorite.createdAt
        };

        if (!replaceExisting) {
          // 检查是否已存在
          const predicates = new relationalStore.RdbPredicates(TABLE_NAMES.FAVORITE_RECORDS);
          predicates.equalTo('userId', favorite.userId).and().equalTo('giftId', favorite.giftId);
          const resultSet = await store.query(predicates);
          const exists = resultSet.rowCount > 0;
          resultSet.close();
          
          if (exists) {
            continue; // 跳过已存在的收藏
          }
        }
        
        await store.insert(TABLE_NAMES.FAVORITE_RECORDS, valueBucket);
        importedCount++;
      } catch (error) {
        console.error(`导入收藏 ${favorite.id} 失败:`, error);
      }
    }
    
    return importedCount;
  }

  // 导入浏览历史数据
  private async importBrowseHistory(history: BrowsingHistory[], replaceExisting: boolean): Promise<number> {
    const store = this.dbManager.getStore();
    if (!store) {
      throw new Error('数据库未初始化');
    }

    let importedCount = 0;
    
    for (const record of history) {
      try {
        const valueBucket: relationalStore.ValuesBucket = {
          id: record.id,
          userId: record.userId,
          giftId: record.giftId,
          viewedAt: record.viewedAt
        };

        await store.insert(TABLE_NAMES.BROWSE_HISTORY, valueBucket);
        importedCount++;
      } catch (error) {
        console.error(`导入浏览历史 ${record.id} 失败:`, error);
      }
    }
    
    return importedCount;
  }

  // 导入预算数据
  private async importBudgets(budgets: Budget[], replaceExisting: boolean): Promise<number> {
    const store = this.dbManager.getStore();
    if (!store) {
      throw new Error('数据库未初始化');
    }

    let importedCount = 0;
    
    for (const budget of budgets) {
      try {
        const valueBucket: relationalStore.ValuesBucket = {
          id: budget.id,
          userId: budget.userId,
          category: budget.category,
          amount: budget.amount,
          period: budget.period,
          startDate: budget.startDate,
          endDate: budget.endDate,
          isActive: budget.isActive ? 1 : 0,
          createdAt: budget.createdAt,
          updatedAt: budget.updatedAt
        };

        await store.insert(TABLE_NAMES.BUDGETS, valueBucket);
        importedCount++;
      } catch (error) {
        console.error(`导入预算 ${budget.id} 失败:`, error);
      }
    }
    
    return importedCount;
  }

  // 导入预算记录数据
  private async importBudgetRecords(records: BudgetRecord[], replaceExisting: boolean): Promise<number> {
    const store = this.dbManager.getStore();
    if (!store) {
      throw new Error('数据库未初始化');
    }

    let importedCount = 0;
    
    for (const record of records) {
      try {
        const valueBucket: relationalStore.ValuesBucket = {
          id: record.id,
          userId: record.userId,
          giftId: record.giftId,
          category: record.category,
          amount: record.amount,
          description: record.description,
          recordDate: record.recordDate,
          createdAt: record.createdAt
        };

        await store.insert(TABLE_NAMES.BUDGET_RECORDS, valueBucket);
        importedCount++;
      } catch (error) {
        console.error(`导入预算记录 ${record.id} 失败:`, error);
      }
    }
    
    return importedCount;
  }

  // 导入节日提醒数据
  private async importHolidayReminders(reminders: HolidayReminder[], replaceExisting: boolean): Promise<number> {
    const store = this.dbManager.getStore();
    if (!store) {
      throw new Error('数据库未初始化');
    }

    let importedCount = 0;
    
    for (const reminder of reminders) {
      try {
        const valueBucket: relationalStore.ValuesBucket = {
          id: reminder.id,
          userId: reminder.userId,
          holidayName: reminder.holidayName,
          holidayDate: reminder.holidayDate,
          reminderDate: reminder.reminderDate,
          budgetAmount: reminder.budgetAmount,
          isActive: reminder.isActive ? 1 : 0,
          createdAt: reminder.createdAt,
          updatedAt: reminder.updatedAt
        };

        await store.insert(TABLE_NAMES.HOLIDAY_REMINDERS, valueBucket);
        importedCount++;
      } catch (error) {
        console.error(`导入节日提醒 ${reminder.id} 失败:`, error);
      }
    }
    
    return importedCount;
  }

  // 清空所有数据
  private async clearAllData(): Promise<void> {
    await this.dbManager.clearAllData();
  }

  // 验证导出数据格式
  private validateExportData(data: ExportData): boolean {
    return data && 
           data.version && 
           data.exportDate && 
           data.data && 
           Array.isArray(data.data.gifts) &&
           Array.isArray(data.data.userPreferences) &&
           Array.isArray(data.data.favorites) &&
           Array.isArray(data.data.browseHistory) &&
           Array.isArray(data.data.budgets) &&
           Array.isArray(data.data.budgetRecords) &&
           Array.isArray(data.data.holidayReminders);
  }

  // 获取空的导入计数
  private getEmptyImportCounts() {
    return {
      gifts: 0,
      userPreferences: 0,
      favorites: 0,
      browseHistory: 0,
      budgets: 0,
      budgetRecords: 0,
      holidayReminders: 0
    };
  }

  // 保存到文件
  private async saveToFile(fileName: string, content: string): Promise<string> {
    try {
      const filesDir = this.context.filesDir;
      const filePath = `${filesDir}/${fileName}`;
      
      const file = fs.openSync(filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      fs.writeSync(file.fd, content);
      fs.closeSync(file);
      
      return filePath;
    } catch (error) {
      console.error('保存文件失败:', error);
      throw error;
    }
  }

  // 从文件读取
  private async readFromFile(filePath: string): Promise<string> {
    try {
      const file = fs.openSync(filePath, fs.OpenMode.READ_ONLY);
      const stat = fs.statSync(filePath);
      const buffer = new ArrayBuffer(stat.size);
      fs.readSync(file.fd, buffer);
      fs.closeSync(file);
      
      return String.fromCharCode.apply(null, new Uint8Array(buffer));
    } catch (error) {
      console.error('读取文件失败:', error);
      throw error;
    }
  }

  // 解析结果集的方法（复用其他服务的解析逻辑）
  private parseGiftFromResultSet(resultSet: relationalStore.ResultSet): Gift {
    return {
      id: resultSet.getString(resultSet.getColumnIndex('id')),
      name: resultSet.getString(resultSet.getColumnIndex('name')),
      description: resultSet.getString(resultSet.getColumnIndex('description')),
      category: resultSet.getString(resultSet.getColumnIndex('category')),
      priceRange: resultSet.getString(resultSet.getColumnIndex('priceRange')),
      brand: resultSet.getString(resultSet.getColumnIndex('brand')),
      imageUrl: resultSet.getString(resultSet.getColumnIndex('imageUrl')),
      tags: JSON.parse(resultSet.getString(resultSet.getColumnIndex('tags')) || '[]'),
      purchaseLinks: JSON.parse(resultSet.getString(resultSet.getColumnIndex('purchaseLinks')) || '[]'),
      createdAt: resultSet.getString(resultSet.getColumnIndex('createdAt')),
      updatedAt: resultSet.getString(resultSet.getColumnIndex('updatedAt'))
    };
  }

  private parseUserPreferencesFromResultSet(resultSet: relationalStore.ResultSet): UserPreferences {
    return {
      id: resultSet.getString(resultSet.getColumnIndex('id')),
      preferredCategories: JSON.parse(resultSet.getString(resultSet.getColumnIndex('preferredCategories')) || '[]'),
      preferredPriceRange: resultSet.getString(resultSet.getColumnIndex('preferredPriceRange')),
      preferredBrands: JSON.parse(resultSet.getString(resultSet.getColumnIndex('preferredBrands')) || '[]'),
      preferredTags: JSON.parse(resultSet.getString(resultSet.getColumnIndex('preferredTags')) || '[]'),
      blacklistedCategories: JSON.parse(resultSet.getString(resultSet.getColumnIndex('blacklistedCategories')) || '[]'),
      createdAt: resultSet.getString(resultSet.getColumnIndex('createdAt')),
      updatedAt: resultSet.getString(resultSet.getColumnIndex('updatedAt'))
    };
  }

  private parseFavoriteFromResultSet(resultSet: relationalStore.ResultSet): FavoriteRecord {
    return {
      id: resultSet.getString(resultSet.getColumnIndex('id')),
      userId: resultSet.getString(resultSet.getColumnIndex('userId')),
      giftId: resultSet.getString(resultSet.getColumnIndex('giftId')),
      createdAt: resultSet.getString(resultSet.getColumnIndex('createdAt'))
    };
  }

  private parseBrowseHistoryFromResultSet(resultSet: relationalStore.ResultSet): BrowsingHistory {
    return {
      id: resultSet.getString(resultSet.getColumnIndex('id')),
      userId: resultSet.getString(resultSet.getColumnIndex('userId')),
      giftId: resultSet.getString(resultSet.getColumnIndex('giftId')),
      viewedAt: resultSet.getString(resultSet.getColumnIndex('viewedAt'))
    };
  }

  private parseBudgetFromResultSet(resultSet: relationalStore.ResultSet): Budget {
    return {
      id: resultSet.getString(resultSet.getColumnIndex('id')),
      userId: resultSet.getString(resultSet.getColumnIndex('userId')),
      category: resultSet.getString(resultSet.getColumnIndex('category')),
      amount: resultSet.getDouble(resultSet.getColumnIndex('amount')),
      period: resultSet.getString(resultSet.getColumnIndex('period')),
      startDate: resultSet.getString(resultSet.getColumnIndex('startDate')),
      endDate: resultSet.getString(resultSet.getColumnIndex('endDate')),
      isActive: resultSet.getLong(resultSet.getColumnIndex('isActive')) === 1,
      createdAt: resultSet.getString(resultSet.getColumnIndex('createdAt')),
      updatedAt: resultSet.getString(resultSet.getColumnIndex('updatedAt'))
    };
  }

  private parseBudgetRecordFromResultSet(resultSet: relationalStore.ResultSet): BudgetRecord {
    return {
      id: resultSet.getString(resultSet.getColumnIndex('id')),
      userId: resultSet.getString(resultSet.getColumnIndex('userId')),
      giftId: resultSet.getString(resultSet.getColumnIndex('giftId')),
      category: resultSet.getString(resultSet.getColumnIndex('category')),
      amount: resultSet.getDouble(resultSet.getColumnIndex('amount')),
      description: resultSet.getString(resultSet.getColumnIndex('description')),
      recordDate: resultSet.getString(resultSet.getColumnIndex('recordDate')),
      createdAt: resultSet.getString(resultSet.getColumnIndex('createdAt'))
    };
  }

  private parseHolidayReminderFromResultSet(resultSet: relationalStore.ResultSet): HolidayReminder {
    return {
      id: resultSet.getString(resultSet.getColumnIndex('id')),
      userId: resultSet.getString(resultSet.getColumnIndex('userId')),
      holidayName: resultSet.getString(resultSet.getColumnIndex('holidayName')),
      holidayDate: resultSet.getString(resultSet.getColumnIndex('holidayDate')),
      reminderDate: resultSet.getString(resultSet.getColumnIndex('reminderDate')),
      budgetAmount: resultSet.getDouble(resultSet.getColumnIndex('budgetAmount')),
      isActive: resultSet.getLong(resultSet.getColumnIndex('isActive')) === 1,
      createdAt: resultSet.getString(resultSet.getColumnIndex('createdAt')),
      updatedAt: resultSet.getString(resultSet.getColumnIndex('updatedAt'))
    };
  }
}