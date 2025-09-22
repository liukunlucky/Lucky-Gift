import relationalStore from '@ohos.data.relationalStore';
import { NewDatabaseManager } from './NewDatabaseManager';
import { Inspiration, BudgetRange } from '../model/NewDataModels';

// 我的灵感数据访问对象
export class MyInspirationDAO {
  private dbManager: NewDatabaseManager;

  constructor(dbManager: NewDatabaseManager) {
    this.dbManager = dbManager;
  }

  // 创建我的灵感
  async createMyInspiration(inspiration: Inspiration): Promise<string> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) {
      throw new Error('数据库未初始化');
    }

    const id = 'my_' + Date.now().toString();
    const now = new Date().toISOString();

    const valueBucket: relationalStore.ValuesBucket = {
      id: id,
      title: inspiration.title,
      description: inspiration.description,
      detailed_description: inspiration.detailedDescription || '',
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
      time_required: inspiration.timeRequired || '',
      materials: JSON.stringify(inspiration.materials || []),
      steps: JSON.stringify(inspiration.steps || []),
      tips: JSON.stringify(inspiration.tips || []),
      precautions: JSON.stringify(inspiration.precautions || []),
      gift_wrap_ideas: JSON.stringify(inspiration.giftWrapIdeas || []),
      presentation_tips: JSON.stringify(inspiration.presentationTips || []),
      personalized_tips: JSON.stringify(inspiration.personalizedTips || []),
      view_count: inspiration.viewCount || 0,
      favorite_count: inspiration.favoriteCount || 0,
      rating: inspiration.rating || 0,
      created_at: now,
      updated_at: now
    };

    await rdbStore.insert('my_inspirations', valueBucket);
    return id;
  }

  // 获取所有我的灵感
  async getAllMyInspirations(): Promise<Inspiration[]> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) {
      return [];
    }

    const resultSet = await rdbStore.querySql('SELECT * FROM my_inspirations ORDER BY created_at DESC');
    const inspirations: Inspiration[] = [];

    if (resultSet.rowCount > 0) {
      for (let i = 0; i < resultSet.rowCount; i++) {
        resultSet.goToRow(i);
        const inspiration = this.mapRowToInspiration(resultSet);
        inspirations.push(inspiration);
      }
    }

    resultSet.close();
    return inspirations;
  }

  // 根据ID获取我的灵感
  async getMyInspirationById(id: string): Promise<Inspiration | null> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) {
      return null;
    }

    const resultSet = await rdbStore.querySql('SELECT * FROM my_inspirations WHERE id = ?', [id]);
    
    if (resultSet.rowCount > 0) {
      resultSet.goToRow(0);
      const inspiration = this.mapRowToInspiration(resultSet);
      resultSet.close();
      return inspiration;
    }

    resultSet.close();
    return null;
  }

  // 更新我的灵感
  async updateMyInspiration(id: string, inspiration: Inspiration): Promise<void> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) {
      throw new Error('数据库未初始化');
    }

    const now = new Date().toISOString();

    const valueBucket: relationalStore.ValuesBucket = {
      title: inspiration.title,
      description: inspiration.description,
      detailed_description: inspiration.detailedDescription || '',
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
      time_required: inspiration.timeRequired || '',
      materials: JSON.stringify(inspiration.materials || []),
      steps: JSON.stringify(inspiration.steps || []),
      tips: JSON.stringify(inspiration.tips || []),
      precautions: JSON.stringify(inspiration.precautions || []),
      gift_wrap_ideas: JSON.stringify(inspiration.giftWrapIdeas || []),
      presentation_tips: JSON.stringify(inspiration.presentationTips || []),
      personalized_tips: JSON.stringify(inspiration.personalizedTips || []),
      view_count: inspiration.viewCount || 0,
      favorite_count: inspiration.favoriteCount || 0,
      rating: inspiration.rating || 0,
      updated_at: now
    };

    const predicates = new relationalStore.RdbPredicates('my_inspirations');
    predicates.equalTo('id', id);
    await rdbStore.update(valueBucket, predicates);
  }

  // 删除我的灵感
  async deleteMyInspiration(id: string): Promise<void> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) {
      throw new Error('数据库未初始化');
    }

    const predicates = new relationalStore.RdbPredicates('my_inspirations');
    predicates.equalTo('id', id);
    await rdbStore.delete(predicates);
  }

  // 搜索我的灵感
  async searchMyInspirations(keyword: string): Promise<Inspiration[]> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) {
      return [];
    }

    const sql = `
      SELECT * FROM my_inspirations 
      WHERE title LIKE ? OR description LIKE ? OR tags LIKE ?
      ORDER BY created_at DESC
    `;
    const searchTerm = `%${keyword}%`;
    const resultSet = await rdbStore.querySql(sql, [searchTerm, searchTerm, searchTerm]);
    
    const inspirations: Inspiration[] = [];
    if (resultSet.rowCount > 0) {
      for (let i = 0; i < resultSet.rowCount; i++) {
        resultSet.goToRow(i);
        const inspiration = this.mapRowToInspiration(resultSet);
        inspirations.push(inspiration);
      }
    }

    resultSet.close();
    return inspirations;
  }

  // 将数据库行映射为Inspiration对象
  private mapRowToInspiration(resultSet: relationalStore.ResultSet): Inspiration {
    const budgetRange: BudgetRange = {
      min: resultSet.getDouble(resultSet.getColumnIndex('budget_min')),
      max: resultSet.getDouble(resultSet.getColumnIndex('budget_max')),
      label: resultSet.getString(resultSet.getColumnIndex('budget_label'))
    };

    const inspiration: Inspiration = {
      id: resultSet.getString(resultSet.getColumnIndex('id')),
      title: resultSet.getString(resultSet.getColumnIndex('title')),
      description: resultSet.getString(resultSet.getColumnIndex('description')),
      detailedDescription: resultSet.getString(resultSet.getColumnIndex('detailed_description')),
      images: JSON.parse(resultSet.getString(resultSet.getColumnIndex('images')) || '[]'),
      tags: JSON.parse(resultSet.getString(resultSet.getColumnIndex('tags')) || '[]'),
      targetAudience: JSON.parse(resultSet.getString(resultSet.getColumnIndex('target_audience')) || '[]'),
      occasions: JSON.parse(resultSet.getString(resultSet.getColumnIndex('occasions')) || '[]'),
      interests: JSON.parse(resultSet.getString(resultSet.getColumnIndex('interests')) || '[]'),
      budgetRange: budgetRange,
      giftType: resultSet.getString(resultSet.getColumnIndex('gift_type')),
      difficulty: resultSet.getString(resultSet.getColumnIndex('difficulty')) as 'easy' | 'medium' | 'hard',
      timeRequired: resultSet.getString(resultSet.getColumnIndex('time_required')),
      materials: JSON.parse(resultSet.getString(resultSet.getColumnIndex('materials')) || '[]'),
      steps: JSON.parse(resultSet.getString(resultSet.getColumnIndex('steps')) || '[]'),
      tips: JSON.parse(resultSet.getString(resultSet.getColumnIndex('tips')) || '[]'),
      precautions: JSON.parse(resultSet.getString(resultSet.getColumnIndex('precautions')) || '[]'),
      giftWrapIdeas: JSON.parse(resultSet.getString(resultSet.getColumnIndex('gift_wrap_ideas')) || '[]'),
      presentationTips: JSON.parse(resultSet.getString(resultSet.getColumnIndex('presentation_tips')) || '[]'),
      personalizedTips: JSON.parse(resultSet.getString(resultSet.getColumnIndex('personalized_tips')) || '[]'),
      viewCount: resultSet.getLong(resultSet.getColumnIndex('view_count')),
      favoriteCount: resultSet.getLong(resultSet.getColumnIndex('favorite_count')),
      rating: resultSet.getDouble(resultSet.getColumnIndex('rating')),
      isRecommended: false, // 我的灵感不是系统推荐
      createdAt: resultSet.getString(resultSet.getColumnIndex('created_at'))
    };

    return inspiration;
  }
}