import { DatabaseManager } from '../database/DatabaseManager';
import { FavoriteRecord, BrowsingHistory, Gift, TABLE_NAMES } from '../model/DataModels';
import relationalStore from '@ohos.data.relationalStore';

// 收藏服务
export class FavoriteService {
  private dbManager: DatabaseManager;

  constructor() {
    this.dbManager = DatabaseManager.getInstance();
  }

  // 添加收藏
  public async addFavorite(userId: string, giftId: string): Promise<boolean> {
    const store = this.dbManager.getStore();
    if (!store) {
      throw new Error('数据库未初始化');
    }

    try {
      // 检查是否已收藏
      const existing = await this.isFavorite(userId, giftId);
      if (existing) {
        return true; // 已收藏
      }

      const favorite: FavoriteRecord = {
        id: `${userId}_${giftId}_${Date.now()}`,
        userId: userId,
        giftId: giftId,
        createdAt: this.dbManager.getCurrentTimestamp()
      };

      const valueBucket: relationalStore.ValuesBucket = {
        id: favorite.id,
        userId: favorite.userId,
        giftId: favorite.giftId,
        createdAt: favorite.createdAt
      };

      await store.insert(TABLE_NAMES.FAVORITE_RECORDS, valueBucket);
      return true;
    } catch (error) {
      console.error('添加收藏失败:', error);
      return false;
    }
  }

  // 移除收藏
  public async removeFavorite(userId: string, giftId: string): Promise<boolean> {
    const store = this.dbManager.getStore();
    if (!store) {
      throw new Error('数据库未初始化');
    }

    try {
      const predicates = new relationalStore.RdbPredicates(TABLE_NAMES.FAVORITE_RECORDS);
      predicates.equalTo('userId', userId).and().equalTo('giftId', giftId);
      
      const result = await store.delete(predicates);
      return result > 0;
    } catch (error) {
      console.error('移除收藏失败:', error);
      return false;
    }
  }

  // 检查是否已收藏
  public async isFavorite(userId: string, giftId: string): Promise<boolean> {
    const store = this.dbManager.getStore();
    if (!store) {
      throw new Error('数据库未初始化');
    }

    try {
      const predicates = new relationalStore.RdbPredicates(TABLE_NAMES.FAVORITE_RECORDS);
      predicates.equalTo('userId', userId).and().equalTo('giftId', giftId);
      
      const resultSet = await store.query(predicates);
      const exists = resultSet.rowCount > 0;
      resultSet.close();
      return exists;
    } catch (error) {
      console.error('检查收藏状态失败:', error);
      return false;
    }
  }

  // 获取用户收藏列表
  public async getUserFavorites(userId: string, limit?: number, offset?: number): Promise<FavoriteRecord[]> {
    const store = this.dbManager.getStore();
    if (!store) {
      throw new Error('数据库未初始化');
    }

    try {
      const predicates = new relationalStore.RdbPredicates(TABLE_NAMES.FAVORITE_RECORDS);
      predicates.equalTo('userId', userId).orderByDesc('createdAt');
      
      if (limit !== undefined) {
        predicates.limitAs(limit);
      }
      if (offset !== undefined) {
        predicates.offsetAs(offset);
      }
      
      const resultSet = await store.query(predicates);
      const favorites: FavoriteRecord[] = [];
      
      while (resultSet.goToNextRow()) {
        favorites.push(this.parseFavoriteFromResultSet(resultSet));
      }
      
      resultSet.close();
      return favorites;
    } catch (error) {
      console.error('获取收藏列表失败:', error);
      return [];
    }
  }

  // 获取收藏的礼物ID列表
  public async getFavoriteGiftIds(userId: string): Promise<string[]> {
    const favorites = await this.getUserFavorites(userId);
    return favorites.map(f => f.giftId);
  }

  // 获取收藏的礼物列表
  public async getFavoriteGifts(limit: number = 10): Promise<Gift[]> {
    try {
      // 暂时返回空数组，实际应该根据用户收藏获取礼物详情
      return [];
    } catch (error) {
      console.error('获取收藏礼物失败:', error);
      return [];
    }
  }

  // 获取收藏数量
  public async getFavoriteCount(userId: string): Promise<number> {
    const store = this.dbManager.getStore();
    if (!store) {
      throw new Error('数据库未初始化');
    }

    try {
      const predicates = new relationalStore.RdbPredicates(TABLE_NAMES.FAVORITE_RECORDS);
      predicates.equalTo('userId', userId);
      
      const resultSet = await store.query(predicates, ['COUNT(*) as count']);
      let count = 0;
      if (resultSet.goToFirstRow()) {
        count = resultSet.getLong(0);
      }
      resultSet.close();
      return count;
    } catch (error) {
      console.error('获取收藏数量失败:', error);
      return 0;
    }
  }

  // 添加浏览历史
  public async addBrowseHistory(userId: string, giftId: string): Promise<boolean> {
    const store = this.dbManager.getStore();
    if (!store) {
      throw new Error('数据库未初始化');
    }

    try {
      // 检查是否已存在相同记录
      const existing = await this.getBrowseHistory(userId, giftId);
      if (existing) {
        // 更新浏览时间
        return await this.updateBrowseHistory(existing.id);
      }

      const history: BrowsingHistory = {
        id: `${userId}_${giftId}_${Date.now()}`,
        userId: userId,
        giftId: giftId,
        viewedAt: this.dbManager.getCurrentTimestamp()
      };

      const valueBucket: relationalStore.ValuesBucket = {
        id: history.id,
        userId: history.userId,
        giftId: history.giftId,
        viewedAt: history.viewedAt
      };

      await store.insert(TABLE_NAMES.BROWSING_HISTORY, valueBucket);
      return true;
    } catch (error) {
      console.error('添加浏览历史失败:', error);
      return false;
    }
  }

  // 获取单个浏览历史记录
  private async getBrowseHistory(userId: string, giftId: string): Promise<BrowsingHistory | null> {
    const store = this.dbManager.getStore();
    if (!store) {
      return null;
    }

    try {
      const predicates = new relationalStore.RdbPredicates(TABLE_NAMES.BROWSING_HISTORY);
      predicates.equalTo('userId', userId).and().equalTo('giftId', giftId);
      
      const resultSet = await store.query(predicates);
      let history: BrowsingHistory | null = null;
      
      if (resultSet.goToFirstRow()) {
        history = this.parseBrowseHistoryFromResultSet(resultSet);
      }
      
      resultSet.close();
      return history;
    } catch (error) {
      console.error('获取浏览历史失败:', error);
      return null;
    }
  }

  // 更新浏览历史时间
  private async updateBrowseHistory(historyId: string): Promise<boolean> {
    const store = this.dbManager.getStore();
    if (!store) {
      return false;
    }

    try {
      const valueBucket: relationalStore.ValuesBucket = {
        viewedAt: this.dbManager.getCurrentTimestamp()
      };

      const predicates = new relationalStore.RdbPredicates(TABLE_NAMES.BROWSING_HISTORY);
      predicates.equalTo('id', historyId);
      
      const result = await store.update(valueBucket, predicates);
      return result > 0;
    } catch (error) {
      console.error('更新浏览历史失败:', error);
      return false;
    }
  }

  // 获取用户浏览历史
  public async getUserBrowseHistory(userId: string, limit?: number, offset?: number): Promise<BrowsingHistory[]> {
    const store = this.dbManager.getStore();
    if (!store) {
      throw new Error('数据库未初始化');
    }

    try {
      const predicates = new relationalStore.RdbPredicates(TABLE_NAMES.BROWSING_HISTORY);
      predicates.equalTo('userId', userId).orderByDesc('viewedAt');
      
      if (limit !== undefined) {
        predicates.limitAs(limit);
      }
      if (offset !== undefined) {
        predicates.offsetAs(offset);
      }
      
      const resultSet = await store.query(predicates);
      const history: BrowsingHistory[] = [];
      
      while (resultSet.goToNextRow()) {
        history.push(this.parseBrowseHistoryFromResultSet(resultSet));
      }
      
      resultSet.close();
      return history;
    } catch (error) {
      console.error('获取浏览历史失败:', error);
      return [];
    }
  }

  // 清除用户浏览历史
  public async clearBrowseHistory(userId: string): Promise<boolean> {
    const store = this.dbManager.getStore();
    if (!store) {
      throw new Error('数据库未初始化');
    }

    try {
      const predicates = new relationalStore.RdbPredicates(TABLE_NAMES.BROWSING_HISTORY);
      predicates.equalTo('userId', userId);
      
      const result = await store.delete(predicates);
      return result >= 0;
    } catch (error) {
      console.error('清除浏览历史失败:', error);
      return false;
    }
  }

  // 清除用户所有收藏
  public async clearAllFavorites(userId: string): Promise<boolean> {
    const store = this.dbManager.getStore();
    if (!store) {
      throw new Error('数据库未初始化');
    }

    try {
      const predicates = new relationalStore.RdbPredicates(TABLE_NAMES.FAVORITE_RECORDS);
      predicates.equalTo('userId', userId);
      
      const result = await store.delete(predicates);
      return result >= 0;
    } catch (error) {
      console.error('清除收藏失败:', error);
      return false;
    }
  }

  // 获取最近浏览的礼物ID列表
  public async getRecentlyViewedGiftIds(userId: string, limit: number = 10): Promise<string[]> {
    const history = await this.getUserBrowseHistory(userId, limit);
    return history.map(h => h.giftId);
  }

  // 从结果集解析收藏
  private parseFavoriteFromResultSet(resultSet: relationalStore.ResultSet): FavoriteRecord {
    return {
      id: resultSet.getString(resultSet.getColumnIndex('id')),
      userId: resultSet.getString(resultSet.getColumnIndex('userId')),
      giftId: resultSet.getString(resultSet.getColumnIndex('giftId')),
      createdAt: resultSet.getString(resultSet.getColumnIndex('createdAt'))
    };
  }

  // 从结果集解析浏览历史
  private parseBrowseHistoryFromResultSet(resultSet: relationalStore.ResultSet): BrowsingHistory {
    return {
      id: resultSet.getString(resultSet.getColumnIndex('id')),
      userId: resultSet.getString(resultSet.getColumnIndex('userId')),
      giftId: resultSet.getString(resultSet.getColumnIndex('giftId')),
      viewedAt: resultSet.getString(resultSet.getColumnIndex('viewedAt'))
    };
  }
}