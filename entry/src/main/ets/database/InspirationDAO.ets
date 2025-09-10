import relationalStore from '@ohos.data.relationalStore';
import { Inspiration, FavoriteInspiration, BudgetRange, InspirationCategory, InspirationTag } from '../model/NewDataModels';
import { NewDatabaseManager } from './NewDatabaseManager';

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

  constructor(dbManager: NewDatabaseManager) {
    this.dbManager = dbManager;
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
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const id = this.dbManager.generateId();
    const now = this.dbManager.getCurrentTimestamp();

    const valueBucket: relationalStore.ValuesBucket = {
      id: id,
      title: inspiration.title,
      description: inspiration.description,
      detailed_description: inspiration.detailedDescription || null,
      images: JSON.stringify(inspiration.images || []),
      tags: JSON.stringify(inspiration.tags || []),
      target_audience: JSON.stringify(inspiration.targetAudience || []),
      occasions: JSON.stringify(inspiration.occasions || []),
      interests: JSON.stringify(inspiration.interests || []),
      budget_min: inspiration.budgetRange.min,
      budget_max: inspiration.budgetRange.max,
      budget_label: inspiration.budgetRange.label,
      gift_type: inspiration.giftType,
      difficulty: inspiration.difficulty,
      time_required: inspiration.timeRequired || null,
      materials: JSON.stringify(inspiration.materials || []),
      steps: JSON.stringify(inspiration.steps || []),
      tips: JSON.stringify(inspiration.tips || []),
      is_recommended: inspiration.isRecommended ? 1 : 0,
      created_at: now
    };

    await rdbStore.insert('inspirations', valueBucket);
    return id;
  }

  // 获取所有灵感
  async getAllInspirations(): Promise<Inspiration[]> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const resultSet = await rdbStore.querySql(
      'SELECT * FROM inspirations ORDER BY is_recommended DESC, created_at DESC'
    );

    const inspirations: Inspiration[] = [];
    while (resultSet.goToNextRow()) {
      inspirations.push(this.parseInspirationFromResultSet(resultSet));
    }
    resultSet.close();

    return inspirations;
  }

  // 获取推荐灵感
  async getRecommendedInspirations(): Promise<Inspiration[]> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const resultSet = await rdbStore.querySql(
      'SELECT * FROM inspirations WHERE is_recommended = 1 ORDER BY created_at DESC'
    );

    const inspirations: Inspiration[] = [];
    while (resultSet.goToNextRow()) {
      inspirations.push(this.parseInspirationFromResultSet(resultSet));
    }
    resultSet.close();

    return inspirations;
  }

  // 根据ID获取灵感
  async getInspirationById(id: string): Promise<Inspiration | null> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const resultSet = await rdbStore.querySql(
      'SELECT * FROM inspirations WHERE id = ?',
      [id]
    );

    let inspiration: Inspiration | null = null;
    if (resultSet.goToFirstRow()) {
      inspiration = this.parseInspirationFromResultSet(resultSet);
    }
    resultSet.close();

    return inspiration;
  }

  // 根据目标受众筛选灵感
  async getInspirationsByTargetAudience(audience: string): Promise<Inspiration[]> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const resultSet = await rdbStore.querySql(
      'SELECT * FROM inspirations WHERE target_audience LIKE ? ORDER BY is_recommended DESC, created_at DESC',
      [`%"${audience}"%`]
    );

    const inspirations: Inspiration[] = [];
    while (resultSet.goToNextRow()) {
      inspirations.push(this.parseInspirationFromResultSet(resultSet));
    }
    resultSet.close();

    return inspirations;
  }

  // 根据场合筛选灵感
  async getInspirationsByOccasion(occasion: string): Promise<Inspiration[]> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const resultSet = await rdbStore.querySql(
      'SELECT * FROM inspirations WHERE occasions LIKE ? ORDER BY is_recommended DESC, created_at DESC',
      [`%"${occasion}"%`]
    );

    const inspirations: Inspiration[] = [];
    while (resultSet.goToNextRow()) {
      inspirations.push(this.parseInspirationFromResultSet(resultSet));
    }
    resultSet.close();

    return inspirations;
  }

  // 根据兴趣筛选灵感
  async getInspirationsByInterest(interest: string): Promise<Inspiration[]> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const resultSet = await rdbStore.querySql(
      'SELECT * FROM inspirations WHERE interests LIKE ? ORDER BY is_recommended DESC, created_at DESC',
      [`%"${interest}"%`]
    );

    const inspirations: Inspiration[] = [];
    while (resultSet.goToNextRow()) {
      inspirations.push(this.parseInspirationFromResultSet(resultSet));
    }
    resultSet.close();

    return inspirations;
  }

  // 根据预算范围筛选灵感
  async getInspirationsByBudgetRange(minBudget: number, maxBudget: number): Promise<Inspiration[]> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const resultSet = await rdbStore.querySql(
      `SELECT * FROM inspirations 
       WHERE (budget_min <= ? AND budget_max >= ?) OR (budget_min BETWEEN ? AND ?) 
       ORDER BY is_recommended DESC, created_at DESC`,
      [maxBudget, minBudget, minBudget, maxBudget]
    );

    const inspirations: Inspiration[] = [];
    while (resultSet.goToNextRow()) {
      inspirations.push(this.parseInspirationFromResultSet(resultSet));
    }
    resultSet.close();

    return inspirations;
  }

  // 根据礼物类型筛选灵感
  async getInspirationsByGiftType(giftType: string): Promise<Inspiration[]> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const resultSet = await rdbStore.querySql(
      'SELECT * FROM inspirations WHERE gift_type = ? ORDER BY is_recommended DESC, created_at DESC',
      [giftType]
    );

    const inspirations: Inspiration[] = [];
    while (resultSet.goToNextRow()) {
      inspirations.push(this.parseInspirationFromResultSet(resultSet));
    }
    resultSet.close();

    return inspirations;
  }

  // 多条件筛选灵感
  async getInspirationsByFilters(filters: InspirationFilters): Promise<Inspiration[]> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    let sql = 'SELECT * FROM inspirations WHERE 1=1';
    const params: (string | number)[] = [];

    if (filters.targetAudience) {
      sql += ' AND target_audience LIKE ?';
      params.push(`%"${filters.targetAudience}"%`);
    }

    if (filters.occasion) {
      sql += ' AND occasions LIKE ?';
      params.push(`%"${filters.occasion}"%`);
    }

    if (filters.interest) {
      sql += ' AND interests LIKE ?';
      params.push(`%"${filters.interest}"%`);
    }

    if (filters.minBudget !== undefined && filters.maxBudget !== undefined) {
      sql += ' AND ((budget_min <= ? AND budget_max >= ?) OR (budget_min BETWEEN ? AND ?))';
      params.push(filters.maxBudget, filters.minBudget, filters.minBudget, filters.maxBudget);
    }

    if (filters.giftType) {
      sql += ' AND gift_type = ?';
      params.push(filters.giftType);
    }

    if (filters.difficulty) {
      sql += ' AND difficulty = ?';
      params.push(filters.difficulty);
    }

    sql += ' ORDER BY is_recommended DESC, created_at DESC';

    const resultSet = await rdbStore.querySql(sql, params);

    const inspirations: Inspiration[] = [];
    while (resultSet.goToNextRow()) {
      inspirations.push(this.parseInspirationFromResultSet(resultSet));
    }
    resultSet.close();

    return inspirations;
  }

  // 搜索灵感
  async searchInspirations(keyword: string): Promise<Inspiration[]> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const resultSet = await rdbStore.querySql(
      `SELECT * FROM inspirations 
       WHERE title LIKE ? OR description LIKE ? OR detailed_description LIKE ? 
       OR tags LIKE ? OR gift_type LIKE ?
       ORDER BY is_recommended DESC, created_at DESC`,
      [`%${keyword}%`, `%${keyword}%`, `%${keyword}%`, `%${keyword}%`, `%${keyword}%`]
    );

    const inspirations: Inspiration[] = [];
    while (resultSet.goToNextRow()) {
      inspirations.push(this.parseInspirationFromResultSet(resultSet));
    }
    resultSet.close();

    return inspirations;
  }

  // 根据标签获取灵感
  async getInspirationsByTag(tag: string): Promise<Inspiration[]> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const resultSet = await rdbStore.querySql(
      'SELECT * FROM inspirations WHERE tags LIKE ? ORDER BY is_recommended DESC, created_at DESC',
      [`%"${tag}"%`]
    );

    const inspirations: Inspiration[] = [];
    while (resultSet.goToNextRow()) {
      inspirations.push(this.parseInspirationFromResultSet(resultSet));
    }
    resultSet.close();

    return inspirations;
  }

  // 收藏灵感
  async addToFavorites(inspirationId: string, notes?: string): Promise<string> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    // 检查是否已收藏
    const existingResult = await rdbStore.querySql(
      'SELECT id FROM favorite_inspirations WHERE inspiration_id = ?',
      [inspirationId]
    );
    
    if (existingResult.goToFirstRow()) {
      existingResult.close();
      throw new Error('该灵感已在收藏列表中');
    }
    existingResult.close();

    const id = this.dbManager.generateId();
    const valueBucket: relationalStore.ValuesBucket = {
      id: id,
      inspiration_id: inspirationId,
      user_id: 'default',
      notes: notes || null,
      created_at: this.dbManager.getCurrentTimestamp()
    };

    await rdbStore.insert('favorite_inspirations', valueBucket);
    return id;
  }

  // 取消收藏灵感
  async removeFromFavorites(inspirationId: string): Promise<void> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const predicates = new relationalStore.RdbPredicates('favorite_inspirations');
    predicates.equalTo('inspiration_id', inspirationId);

    await rdbStore.delete(predicates);
  }

  // 检查是否已收藏
  async isFavorite(inspirationId: string): Promise<boolean> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const resultSet = await rdbStore.querySql(
      'SELECT COUNT(*) as count FROM favorite_inspirations WHERE inspiration_id = ?',
      [inspirationId]
    );

    let isFavorite = false;
    if (resultSet.goToFirstRow()) {
      isFavorite = resultSet.getLong(0) > 0;
    }
    resultSet.close();

    return isFavorite;
  }

  // 获取收藏的灵感
  async getFavoriteInspirations(): Promise<Inspiration[]> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const resultSet = await rdbStore.querySql(
      `SELECT i.* FROM inspirations i 
       JOIN favorite_inspirations f ON i.id = f.inspiration_id 
       ORDER BY f.created_at DESC`
    );

    const inspirations: Inspiration[] = [];
    while (resultSet.goToNextRow()) {
      inspirations.push(this.parseInspirationFromResultSet(resultSet));
    }
    resultSet.close();

    return inspirations;
  }

  // 获取收藏详情
  async getFavoriteInspirationDetails(): Promise<FavoriteInspiration[]> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const resultSet = await rdbStore.querySql(
      'SELECT * FROM favorite_inspirations ORDER BY created_at DESC'
    );

    const favorites: FavoriteInspiration[] = [];
    while (resultSet.goToNextRow()) {
      favorites.push({
        id: resultSet.getString(resultSet.getColumnIndex('id')),
        inspirationId: resultSet.getString(resultSet.getColumnIndex('inspiration_id')),
        userId: resultSet.getString(resultSet.getColumnIndex('user_id')),
        notes: resultSet.getString(resultSet.getColumnIndex('notes')) || undefined,
        createdAt: resultSet.getString(resultSet.getColumnIndex('created_at'))
      });
    }
    resultSet.close();

    return favorites;
  }

  // 获取热门标签
  async getPopularTags(limit: number = 20): Promise<TagCount[]> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    // 这里需要解析JSON数组中的标签，简化处理
    const resultSet = await rdbStore.querySql(
      'SELECT tags FROM inspirations WHERE tags IS NOT NULL AND tags != "[]"'
    );

    const tagCounts = new Map<string, number>();
    while (resultSet.goToNextRow()) {
      const tagsStr = resultSet.getString(0);
      try {
        const tags: string[] = JSON.parse(tagsStr);
        tags.forEach(tag => {
          tagCounts.set(tag, (tagCounts.get(tag) || 0) + 1);
        });
      } catch (e) {
        // 忽略解析错误
      }
    }
    resultSet.close();

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
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const valueBucket: relationalStore.ValuesBucket = {};

    if (updates.title !== undefined) valueBucket.title = updates.title;
    if (updates.description !== undefined) valueBucket.description = updates.description;
    if (updates.detailedDescription !== undefined) valueBucket.detailed_description = updates.detailedDescription;
    if (updates.images !== undefined) valueBucket.images = JSON.stringify(updates.images);
    if (updates.tags !== undefined) valueBucket.tags = JSON.stringify(updates.tags);
    if (updates.targetAudience !== undefined) valueBucket.target_audience = JSON.stringify(updates.targetAudience);
    if (updates.occasions !== undefined) valueBucket.occasions = JSON.stringify(updates.occasions);
    if (updates.interests !== undefined) valueBucket.interests = JSON.stringify(updates.interests);
    if (updates.budgetRange !== undefined) {
      valueBucket.budget_min = updates.budgetRange.min;
      valueBucket.budget_max = updates.budgetRange.max;
      valueBucket.budget_label = updates.budgetRange.label;
    }
    if (updates.giftType !== undefined) valueBucket.gift_type = updates.giftType;
    if (updates.difficulty !== undefined) valueBucket.difficulty = updates.difficulty;
    if (updates.timeRequired !== undefined) valueBucket.time_required = updates.timeRequired;
    if (updates.materials !== undefined) valueBucket.materials = JSON.stringify(updates.materials);
    if (updates.steps !== undefined) valueBucket.steps = JSON.stringify(updates.steps);
    if (updates.tips !== undefined) valueBucket.tips = JSON.stringify(updates.tips);
    if (updates.isRecommended !== undefined) valueBucket.is_recommended = updates.isRecommended ? 1 : 0;

    const predicates = new relationalStore.RdbPredicates('inspirations');
    predicates.equalTo('id', id);

    await rdbStore.update(valueBucket, predicates);
  }

  // 删除灵感
  async deleteInspiration(id: string): Promise<void> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const predicates = new relationalStore.RdbPredicates('inspirations');
    predicates.equalTo('id', id);

    await rdbStore.delete(predicates);
  }

  // 解析灵感数据
  private parseInspirationFromResultSet(resultSet: relationalStore.ResultSet): Inspiration {
    const imagesStr = resultSet.getString(resultSet.getColumnIndex('images'));
    const tagsStr = resultSet.getString(resultSet.getColumnIndex('tags'));
    const targetAudienceStr = resultSet.getString(resultSet.getColumnIndex('target_audience'));
    const occasionsStr = resultSet.getString(resultSet.getColumnIndex('occasions'));
    const interestsStr = resultSet.getString(resultSet.getColumnIndex('interests'));
    const materialsStr = resultSet.getString(resultSet.getColumnIndex('materials'));
    const stepsStr = resultSet.getString(resultSet.getColumnIndex('steps'));
    const tipsStr = resultSet.getString(resultSet.getColumnIndex('tips'));
    
    return {
      id: resultSet.getString(resultSet.getColumnIndex('id')),
      title: resultSet.getString(resultSet.getColumnIndex('title')),
      description: resultSet.getString(resultSet.getColumnIndex('description')),
      detailedDescription: resultSet.getString(resultSet.getColumnIndex('detailed_description')) || undefined,
      images: imagesStr ? JSON.parse(imagesStr) : [],
      tags: tagsStr ? JSON.parse(tagsStr) : [],
      targetAudience: targetAudienceStr ? JSON.parse(targetAudienceStr) : [],
      occasions: occasionsStr ? JSON.parse(occasionsStr) : [],
      interests: interestsStr ? JSON.parse(interestsStr) : [],
      budgetRange: {
        min: resultSet.getDouble(resultSet.getColumnIndex('budget_min')),
        max: resultSet.getDouble(resultSet.getColumnIndex('budget_max')),
        label: resultSet.getString(resultSet.getColumnIndex('budget_label'))
      },
      giftType: resultSet.getString(resultSet.getColumnIndex('gift_type')),
      difficulty: resultSet.getString(resultSet.getColumnIndex('difficulty')) as 'easy' | 'medium' | 'hard',
      timeRequired: resultSet.getString(resultSet.getColumnIndex('time_required')) || undefined,
      materials: materialsStr ? JSON.parse(materialsStr) : undefined,
      steps: stepsStr ? JSON.parse(stepsStr) : undefined,
      tips: tipsStr ? JSON.parse(tipsStr) : undefined,
      isRecommended: resultSet.getLong(resultSet.getColumnIndex('is_recommended')) === 1,
      createdAt: resultSet.getString(resultSet.getColumnIndex('created_at'))
    };
  }
}