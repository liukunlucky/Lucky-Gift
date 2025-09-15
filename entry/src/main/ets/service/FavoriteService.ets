import { NewDatabaseManager } from '../database/NewDatabaseManager';
import relationalStore from '@ohos.data.relationalStore';

// 定义收藏记录接口
interface FavoriteRecord {
  id: string;
  inspiration_id: string;
  user_id: string;
  notes?: string;
  created_at: string;
}

// 收藏服务
export class FavoriteService {
  private dbManager: NewDatabaseManager;

  constructor(dbManager?: NewDatabaseManager) {
    this.dbManager = dbManager || new NewDatabaseManager();
  }

  // 添加收藏
  public async addFavorite(userId: string, inspirationId: string): Promise<boolean> {
    const store = this.dbManager.getRdbStore();
    if (!store) {
      throw new Error('数据库未初始化');
    }

    try {
      // 检查是否已收藏
      const existing = await this.isFavorite(userId, inspirationId);
      if (existing) {
        return true; // 已收藏
      }

      const favoriteId = this.dbManager.generateId();
      const valueBucket: relationalStore.ValuesBucket = {
        id: favoriteId,
        inspiration_id: inspirationId,
        user_id: userId,
        notes: '',
        created_at: this.dbManager.getCurrentTimestamp()
      };

      await store.insert('favorite_inspirations', valueBucket);
      return true;
    } catch (error) {
      console.error('添加收藏失败:', error);
      return false;
    }
  }

  // 移除收藏
  public async removeFavorite(userId: string, inspirationId: string): Promise<boolean> {
    const store = this.dbManager.getRdbStore();
    if (!store) {
      throw new Error('数据库未初始化');
    }

    try {
      const predicates = new relationalStore.RdbPredicates('favorite_inspirations');
      predicates.equalTo('user_id', userId).and().equalTo('inspiration_id', inspirationId);
      
      const result = await store.delete(predicates);
      return result > 0;
    } catch (error) {
      console.error('移除收藏失败:', error);
      return false;
    }
  }

  // 检查是否已收藏
  public async isFavorite(userId: string, inspirationId: string): Promise<boolean> {
    const store = this.dbManager.getRdbStore();
    if (!store) {
      throw new Error('数据库未初始化');
    }

    try {
      const predicates = new relationalStore.RdbPredicates('favorite_inspirations');
      predicates.equalTo('user_id', userId).and().equalTo('inspiration_id', inspirationId);
      
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
    const store = this.dbManager.getRdbStore();
    if (!store) {
      throw new Error('数据库未初始化');
    }

    try {
      const predicates = new relationalStore.RdbPredicates('favorite_inspirations');
      predicates.equalTo('user_id', userId).orderByDesc('created_at');
      
      if (limit !== undefined) {
        predicates.limitAs(limit);
      }
      if (offset !== undefined) {
        predicates.offsetAs(offset);
      }
      
      const resultSet = await store.query(predicates);
      const favorites: FavoriteRecord[] = [];
      
      while (resultSet.goToNextRow()) {
        const favorite: FavoriteRecord = {
          id: resultSet.getString(resultSet.getColumnIndex('id')),
          inspiration_id: resultSet.getString(resultSet.getColumnIndex('inspiration_id')),
          user_id: resultSet.getString(resultSet.getColumnIndex('user_id')),
          notes: resultSet.getString(resultSet.getColumnIndex('notes')),
          created_at: resultSet.getString(resultSet.getColumnIndex('created_at'))
        };
        favorites.push(favorite);
      }
      
      resultSet.close();
      return favorites;
    } catch (error) {
      console.error('获取收藏列表失败:', error);
      return [];
    }
  }

  // 获取收藏的灵感ID列表
  public async getFavoriteInspirationIds(userId: string): Promise<string[]> {
    const favorites = await this.getUserFavorites(userId);
    return favorites.map(f => f.inspiration_id);
  }

  // 获取收藏的礼物ID列表（向后兼容）
  public async getFavoriteGiftIds(userId: string): Promise<string[]> {
    return await this.getFavoriteInspirationIds(userId);
  }

  // 获取收藏的礼物列表
  public async getFavoriteGifts(limit: number = 10): Promise<FavoriteRecord[]> {
    try {
      // 暂时返回空数组，实际应该根据用户收藏获取礼物详情
      const emptyResult: FavoriteRecord[] = [];
      return emptyResult;
    } catch (error) {
      console.error('获取收藏礼物失败:', error);
      const emptyResult: FavoriteRecord[] = [];
      return emptyResult;
    }
  }

  // 获取收藏数量
  public async getFavoriteCount(userId: string): Promise<number> {
    const store = this.dbManager.getRdbStore();
    if (!store) {
      throw new Error('数据库未初始化');
    }

    try {
      const predicates = new relationalStore.RdbPredicates('favorite_inspirations');
      predicates.equalTo('user_id', userId);
      
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



  // 清除用户所有收藏
  public async clearAllFavorites(userId: string): Promise<boolean> {
    const store = this.dbManager.getRdbStore();
    if (!store) {
      throw new Error('数据库未初始化');
    }

    try {
      const predicates = new relationalStore.RdbPredicates('favorite_inspirations');
      predicates.equalTo('user_id', userId);
      
      const result = await store.delete(predicates);
      return result >= 0;
    } catch (error) {
      console.error('清除收藏失败:', error);
      return false;
    }
  }


}