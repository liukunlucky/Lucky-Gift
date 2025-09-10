import { DatabaseManager } from '../database/DatabaseManager';
import { UserPreferences, TABLE_NAMES } from '../model/DataModels';
import relationalStore from '@ohos.data.relationalStore';

// 用户偏好服务
export class UserPreferenceService {
  private dbManager: DatabaseManager;

  constructor() {
    this.dbManager = DatabaseManager.getInstance();
  }

  // 获取用户偏好
  public async getUserPreferences(userId: string): Promise<UserPreferences | null> {
    const store = this.dbManager.getStore();
    if (!store) {
      throw new Error('数据库未初始化');
    }

    try {
      const predicates = new relationalStore.RdbPredicates(TABLE_NAMES.USER_PREFERENCES);
      predicates.equalTo('id', userId);
      
      const resultSet = await store.query(predicates);
      if (resultSet.goToFirstRow()) {
        const preferences = this.parseUserPreferencesFromResultSet(resultSet);
        resultSet.close();
        return preferences;
      }
      
      resultSet.close();
      return null;
    } catch (error) {
      console.error('获取用户偏好失败:', error);
      return null;
    }
  }

  // 保存用户偏好
  public async saveUserPreferences(preferences: UserPreferences): Promise<boolean> {
    const store = this.dbManager.getStore();
    if (!store) {
      throw new Error('数据库未初始化');
    }

    try {
      const valueBucket: relationalStore.ValuesBucket = {
        id: preferences.id,
        preferredCategories: JSON.stringify(preferences.preferredCategories || []),
        preferredPriceRange: preferences.preferredPriceRange || '',
        preferredBrands: JSON.stringify(preferences.preferredBrands || []),
        preferredTags: JSON.stringify(preferences.preferredTags || []),
        blacklistedCategories: JSON.stringify(preferences.blacklistedCategories || []),
        createdAt: preferences.createdAt,
        updatedAt: this.dbManager.getCurrentTimestamp()
      };

      // 检查是否已存在
      const existing = await this.getUserPreferences(preferences.id);
      if (existing) {
        // 更新
        const predicates = new relationalStore.RdbPredicates(TABLE_NAMES.USER_PREFERENCES);
        predicates.equalTo('id', preferences.id);
        const result = await store.update(valueBucket, predicates);
        return result > 0;
      } else {
        // 插入
        await store.insert(TABLE_NAMES.USER_PREFERENCES, valueBucket);
        return true;
      }
    } catch (error) {
      console.error('保存用户偏好失败:', error);
      return false;
    }
  }

  // 更新偏好分类
  public async updatePreferredCategories(userId: string, categories: string[]): Promise<boolean> {
    const preferences = await this.getUserPreferences(userId) || this.createDefaultPreferences(userId);
    preferences.preferredCategories = categories;
    preferences.updatedAt = this.dbManager.getCurrentTimestamp();
    return await this.saveUserPreferences(preferences);
  }

  // 更新偏好价格区间
  public async updatePreferredPriceRange(userId: string, priceRange: string): Promise<boolean> {
    const preferences = await this.getUserPreferences(userId) || this.createDefaultPreferences(userId);
    preferences.preferredPriceRange = priceRange;
    preferences.updatedAt = this.dbManager.getCurrentTimestamp();
    return await this.saveUserPreferences(preferences);
  }

  // 更新偏好品牌
  public async updatePreferredBrands(userId: string, brands: string[]): Promise<boolean> {
    const preferences = await this.getUserPreferences(userId) || this.createDefaultPreferences(userId);
    preferences.preferredBrands = brands;
    preferences.updatedAt = this.dbManager.getCurrentTimestamp();
    return await this.saveUserPreferences(preferences);
  }

  // 更新偏好标签
  public async updatePreferredTags(userId: string, tags: string[]): Promise<boolean> {
    const preferences = await this.getUserPreferences(userId) || this.createDefaultPreferences(userId);
    preferences.preferredTags = tags;
    preferences.updatedAt = this.dbManager.getCurrentTimestamp();
    return await this.saveUserPreferences(preferences);
  }

  // 添加黑名单分类
  public async addBlacklistedCategory(userId: string, category: string): Promise<boolean> {
    const preferences = await this.getUserPreferences(userId) || this.createDefaultPreferences(userId);
    if (!preferences.blacklistedCategories) {
      preferences.blacklistedCategories = [];
    }
    if (!preferences.blacklistedCategories.includes(category)) {
      preferences.blacklistedCategories.push(category);
      preferences.updatedAt = this.dbManager.getCurrentTimestamp();
      return await this.saveUserPreferences(preferences);
    }
    return true;
  }

  // 移除黑名单分类
  public async removeBlacklistedCategory(userId: string, category: string): Promise<boolean> {
    const preferences = await this.getUserPreferences(userId);
    if (preferences && preferences.blacklistedCategories) {
      preferences.blacklistedCategories = preferences.blacklistedCategories.filter(c => c !== category);
      preferences.updatedAt = this.dbManager.getCurrentTimestamp();
      return await this.saveUserPreferences(preferences);
    }
    return true;
  }

  // 基于用户行为学习偏好
  public async learnFromUserBehavior(userId: string, giftId: string, action: 'view' | 'like' | 'purchase'): Promise<void> {
    try {
      // 这里可以实现基于用户行为的偏好学习逻辑
      // 例如：用户查看、喜欢或购买某个礼物时，自动学习其分类、标签等偏好
      console.info(`学习用户行为: ${userId} ${action} ${giftId}`);
      
      // 实际实现中可以:
      // 1. 获取礼物信息
      // 2. 分析礼物的分类、标签、价格等属性
      // 3. 更新用户偏好权重
      // 4. 调整推荐算法参数
    } catch (error) {
      console.error('学习用户行为失败:', error);
    }
  }

  // 获取推荐偏好参数
  public async getRecommendationParams(userId: string): Promise<{
    preferredCategories: string[];
    preferredPriceRange?: string;
    preferredTags: string[];
    excludeCategories: string[];
  }> {
    const preferences = await this.getUserPreferences(userId);
    
    return {
      preferredCategories: preferences?.preferredCategories || [],
      preferredPriceRange: preferences?.preferredPriceRange,
      preferredTags: preferences?.preferredTags || [],
      excludeCategories: preferences?.blacklistedCategories || []
    };
  }

  // 重置用户偏好
  public async resetUserPreferences(userId: string): Promise<boolean> {
    const defaultPreferences = this.createDefaultPreferences(userId);
    return await this.saveUserPreferences(defaultPreferences);
  }

  // 删除用户偏好
  public async deleteUserPreferences(userId: string): Promise<boolean> {
    const store = this.dbManager.getStore();
    if (!store) {
      throw new Error('数据库未初始化');
    }

    try {
      const predicates = new relationalStore.RdbPredicates(TABLE_NAMES.USER_PREFERENCES);
      predicates.equalTo('id', userId);
      const result = await store.delete(predicates);
      return result > 0;
    } catch (error) {
      console.error('删除用户偏好失败:', error);
      return false;
    }
  }

  // 创建默认偏好
  private createDefaultPreferences(userId: string): UserPreferences {
    const now = this.dbManager.getCurrentTimestamp();
    return {
      id: userId,
      preferredCategories: [],
      preferredPriceRange: '',
      preferredBrands: [],
      preferredTags: [],
      blacklistedCategories: [],
      createdAt: now,
      updatedAt: now
    };
  }

  // 从结果集解析用户偏好
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
}