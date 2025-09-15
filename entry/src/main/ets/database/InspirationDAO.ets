import relationalStore from '@ohos.data.relationalStore';
import { Inspiration, FavoriteInspiration, BudgetRange, InspirationCategory, InspirationTag } from '../model/NewDataModels';
import { NewDatabaseManager } from './NewDatabaseManager';
import { MockData } from '../data/MockData';
import { FavoriteService } from '../service/FavoriteService';

interface InspirationFilters {
  targetAudience?: string;
  occasion?: string;
  interest?: string;
  minBudget?: number;
  maxBudget?: number;
  giftType?: string;
  tags?: string[];
  difficulty?: string;
}

interface TagCount {
  tag: string;
  count: number;
}

export class InspirationDAO {
  private dbManager: NewDatabaseManager;
  private favoriteService: FavoriteService;

  constructor(dbManager: NewDatabaseManager) {
    this.dbManager = dbManager;
    this.favoriteService = new FavoriteService(dbManager);
  }

  // 创建分类
  async createCategory(category: InspirationCategory): Promise<string> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const id = this.dbManager.generateId();
    const now = this.dbManager.getCurrentTimestamp();

    const valueBucket: relationalStore.ValuesBucket = {
      id: id,
      name: category.name,
      description: category.description,
      icon: category.icon,
      color: category.color,
      order_index: category.orderIndex,
      is_active: category.isActive ? 1 : 0,
      created_at: now
    };

    await rdbStore.insert('inspiration_categories', valueBucket);
    return id;
  }

  // 创建标签
  async createTag(tag: InspirationTag): Promise<string> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const id = this.dbManager.generateId();
    const now = this.dbManager.getCurrentTimestamp();

    const valueBucket: relationalStore.ValuesBucket = {
      id: id,
      name: tag.name,
      category: tag.category,
      color: tag.color,
      is_popular: tag.isPopular ? 1 : 0,
      created_at: now
    };

    await rdbStore.insert('inspiration_tags', valueBucket);
    return id;
  }

  // 创建灵感
  async createInspiration(inspiration: Inspiration): Promise<string> {
    // 生成新的ID
    const id = this.dbManager.generateId();
    
    // 创建新的灵感对象
    const newInspiration: Inspiration = {
      id: id,
      title: inspiration.title,
      description: inspiration.description,
      detailedDescription: inspiration.detailedDescription || '',
      images: inspiration.images || [],
      tags: inspiration.tags || [],
      targetAudience: inspiration.targetAudience || [],
      occasions: inspiration.occasions || [],
      interests: inspiration.interests || [],
      budgetRange: inspiration.budgetRange,
      giftType: inspiration.giftType,
      difficulty: inspiration.difficulty,
      timeRequired: inspiration.timeRequired || '',
      materials: inspiration.materials || [],
      steps: inspiration.steps || [],
      tips: inspiration.tips || [],
      isRecommended: inspiration.isRecommended || false
    };

    // 添加到模拟数据中
    MockData.addInspiration(newInspiration);
    return id;
  }

  // 获取所有灵感
  async getAllInspirations(): Promise<Inspiration[]> {
    // 从模拟数据获取，按推荐状态和创建时间排序
    const allInspirations = MockData.getAllInspirations();
    return allInspirations.sort((a, b) => {
      // 先按推荐状态排序
      if (a.isRecommended !== b.isRecommended) {
        return a.isRecommended ? -1 : 1;
      }
      // 再按ID排序（模拟创建时间）
      const aId = a.id || '';
      const bId = b.id || '';
      return aId.localeCompare(bId);
    });
  }

  // 获取推荐灵感
  async getRecommendedInspirations(): Promise<Inspiration[]> {
    // 从模拟数据中筛选推荐的灵感
    const allInspirations = MockData.getAllInspirations();
    return allInspirations.filter(inspiration => inspiration.isRecommended);
  }

  // 根据ID获取灵感
  async getInspirationById(id: string): Promise<Inspiration | null> {
    // 从模拟数据中查找
    const allInspirations = MockData.getAllInspirations();
    const inspiration = allInspirations.find(item => item.id === id);
    return inspiration || null;
  }

  // 根据目标受众筛选灵感
  async getInspirationsByTargetAudience(audience: string): Promise<Inspiration[]> {
    // 从模拟数据中筛选目标受众匹配的灵感
    const allInspirations = MockData.getAllInspirations();
    return allInspirations.filter(inspiration => 
      inspiration.targetAudience.includes(audience)
    ).sort((a, b) => {
      // 先按推荐状态排序
      if (a.isRecommended !== b.isRecommended) {
        return a.isRecommended ? -1 : 1;
      }
      // 再按ID排序
      const aId = a.id || '';
      const bId = b.id || '';
      return aId.localeCompare(bId);
    });
  }

  // 根据场合筛选灵感
  async getInspirationsByOccasion(occasion: string): Promise<Inspiration[]> {
    // 从模拟数据中筛选场合匹配的灵感
    const allInspirations = MockData.getAllInspirations();
    return allInspirations.filter(inspiration => 
      inspiration.occasions.includes(occasion)
    ).sort((a, b) => {
      // 先按推荐状态排序
      if (a.isRecommended !== b.isRecommended) {
        return a.isRecommended ? -1 : 1;
      }
      // 再按ID排序
      const aId = a.id || '';
      const bId = b.id || '';
      return aId.localeCompare(bId);
    });
  }

  // 根据兴趣筛选灵感
  async getInspirationsByInterest(interest: string): Promise<Inspiration[]> {
    // 从模拟数据中筛选兴趣匹配的灵感
    const allInspirations = MockData.getAllInspirations();
    return allInspirations.filter(inspiration => 
      inspiration.interests.includes(interest)
    ).sort((a, b) => {
      // 先按推荐状态排序
      if (a.isRecommended !== b.isRecommended) {
        return a.isRecommended ? -1 : 1;
      }
      // 再按ID排序
      const aId = a.id || '';
      const bId = b.id || '';
      return aId.localeCompare(bId);
    });
  }

  // 根据预算范围筛选灵感
  async getInspirationsByBudgetRange(minBudget: number, maxBudget: number): Promise<Inspiration[]> {
    // 从模拟数据中筛选预算范围匹配的灵感
    const allInspirations = MockData.getAllInspirations();
    return allInspirations.filter(inspiration => {
      const budgetMin = inspiration.budgetRange.min;
      const budgetMax = inspiration.budgetRange.max;
      // 检查预算范围是否有重叠
      return (budgetMin <= maxBudget && budgetMax >= minBudget) || 
             (budgetMin >= minBudget && budgetMin <= maxBudget);
    }).sort((a, b) => {
      // 先按推荐状态排序
      if (a.isRecommended !== b.isRecommended) {
        return a.isRecommended ? -1 : 1;
      }
      // 再按ID排序
      const aId = a.id || '';
      const bId = b.id || '';
      return aId.localeCompare(bId);
    });
  }

  // 根据礼物类型筛选灵感
  async getInspirationsByGiftType(giftType: string): Promise<Inspiration[]> {
    // 从模拟数据中筛选礼物类型匹配的灵感
    const allInspirations = MockData.getAllInspirations();
    return allInspirations.filter(inspiration => 
      inspiration.giftType === giftType
    ).sort((a, b) => {
      // 先按推荐状态排序
      if (a.isRecommended !== b.isRecommended) {
        return a.isRecommended ? -1 : 1;
      }
      // 再按ID排序
      const aId = a.id || '';
      const bId = b.id || '';
      return aId.localeCompare(bId);
    });
  }

  // 多条件筛选灵感
  async getInspirationsByFilters(filters: InspirationFilters): Promise<Inspiration[]> {
    // 从模拟数据中进行多条件筛选
    const allInspirations = MockData.getAllInspirations();
    
    return allInspirations.filter(inspiration => {
      // 目标受众筛选
      if (filters.targetAudience && !inspiration.targetAudience.includes(filters.targetAudience)) {
        return false;
      }
      
      // 场合筛选
      if (filters.occasion && !inspiration.occasions.includes(filters.occasion)) {
        return false;
      }
      
      // 兴趣筛选
      if (filters.interest && !inspiration.interests.includes(filters.interest)) {
        return false;
      }
      
      // 预算范围筛选
      if (filters.minBudget !== undefined && filters.maxBudget !== undefined) {
        const budgetMin = inspiration.budgetRange.min;
        const budgetMax = inspiration.budgetRange.max;
        const hasOverlap = (budgetMin <= filters.maxBudget && budgetMax >= filters.minBudget) || 
                          (budgetMin >= filters.minBudget && budgetMin <= filters.maxBudget);
        if (!hasOverlap) {
          return false;
        }
      }
      
      // 礼物类型筛选
      if (filters.giftType && inspiration.giftType !== filters.giftType) {
        return false;
      }
      
      return true;
    }).sort((a, b) => {
      // 先按推荐状态排序
      if (a.isRecommended !== b.isRecommended) {
        return a.isRecommended ? -1 : 1;
      }
      // 再按ID排序
      const aId = a.id || '';
      const bId = b.id || '';
      return aId.localeCompare(bId);
    });
  }

  // 搜索灵感
  async searchInspirations(keyword: string): Promise<Inspiration[]> {
    // 从模拟数据中搜索关键词
    const allInspirations = MockData.getAllInspirations();
    const lowerKeyword = keyword.toLowerCase();
    
    return allInspirations.filter(inspiration => {
      // 在标题、描述、详细描述、标签、礼物类型中搜索
      const searchFields = [
        inspiration.title,
        inspiration.description,
        inspiration.detailedDescription || '',
        inspiration.tags.join(' '),
        inspiration.giftType
      ];
      
      return searchFields.some(field => 
        field.toLowerCase().includes(lowerKeyword)
      );
    }).sort((a, b) => {
      // 先按推荐状态排序
      if (a.isRecommended !== b.isRecommended) {
        return a.isRecommended ? -1 : 1;
      }
      // 再按ID排序
      const aId = a.id || '';
      const bId = b.id || '';
      return aId.localeCompare(bId);
    });
  }

  // 根据标签获取灵感
  async getInspirationsByTag(tag: string): Promise<Inspiration[]> {
    // 从模拟数据中筛选包含指定标签的灵感
    const allInspirations = MockData.getAllInspirations();
    return allInspirations.filter(inspiration => 
      inspiration.tags.includes(tag)
    ).sort((a, b) => {
      // 先按推荐状态排序
      if (a.isRecommended !== b.isRecommended) {
        return a.isRecommended ? -1 : 1;
      }
      // 再按ID排序
      const aId = a.id || '';
      const bId = b.id || '';
      return aId.localeCompare(bId);
    });
  }

  // 收藏灵感
  async addToFavorites(inspirationId: string, notes?: string): Promise<string> {
    const userId = 'default_user'; // 暂时使用默认用户ID
    const success = await this.favoriteService.addFavorite(userId, inspirationId);
    if (!success) {
      throw new Error('添加收藏失败');
    }
    return inspirationId;
  }

  // 取消收藏灵感
  async removeFromFavorites(inspirationId: string): Promise<void> {
    const userId = 'default_user'; // 暂时使用默认用户ID
    const success = await this.favoriteService.removeFavorite(userId, inspirationId);
    if (!success) {
      throw new Error('取消收藏失败');
    }
  }

  // 检查是否已收藏
  async isFavorite(inspirationId: string): Promise<boolean> {
    const userId = 'default_user'; // 暂时使用默认用户ID
    return await this.favoriteService.isFavorite(userId, inspirationId);
  }

  // 获取收藏的灵感
  async getFavoriteInspirations(): Promise<Inspiration[]> {
    const userId = 'default_user'; // 暂时使用默认用户ID
    const favoriteIds: string[] = await this.favoriteService.getFavoriteGiftIds(userId);
    const allInspirations: Inspiration[] = await this.getAllInspirations();
    
    // 根据收藏的ID筛选出对应的灵感
    const favoriteInspirations: Inspiration[] = allInspirations.filter((inspiration: Inspiration): boolean => 
      inspiration.id !== undefined && favoriteIds.includes(inspiration.id)
    );
    return favoriteInspirations;
  }

  // 获取收藏详情
  async getFavoriteInspirationDetails(): Promise<FavoriteInspiration[]> {
    // 从模拟数据获取收藏的灵感，并构造收藏详情
    const favoriteInspirations = MockData.getFavoriteInspirations();
    return favoriteInspirations.map(inspiration => {
      const favoriteDetail: FavoriteInspiration = {
        id: this.dbManager.generateId(),
        inspirationId: inspiration.id || '',
        userId: 'default',
        notes: undefined,
        createdAt: new Date().toISOString()
      };
      return favoriteDetail;
    });
  }

  // 获取热门标签
  async getPopularTags(limit: number = 20): Promise<TagCount[]> {
    // 从模拟数据中统计标签
    const allInspirations = MockData.getAllInspirations();
    const tagCounts = new Map<string, number>();
    
    allInspirations.forEach(inspiration => {
      inspiration.tags.forEach(tag => {
        tagCounts.set(tag, (tagCounts.get(tag) || 0) + 1);
      });
    });

    return Array.from(tagCounts.entries())
      .map((entry) => {
        const result: TagCount = {
          tag: entry[0],
          count: entry[1]
        };
        return result;
      })
      .sort((a, b) => b.count - a.count)
      .slice(0, limit);
  }

  // 更新灵感
  async updateInspiration(id: string, updates: Inspiration): Promise<void> {
    // 从模拟数据中更新灵感
    MockData.updateInspiration(id, updates);
  }

  // 删除灵感
  async deleteInspiration(id: string): Promise<void> {
    // 从模拟数据中删除灵感
    MockData.deleteInspiration(id);
  }


}