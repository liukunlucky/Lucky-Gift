import relationalStore from '@ohos.data.relationalStore';
import { DatabaseManager } from './DatabaseManager';
import { Gift, SearchFilters, TABLE_NAMES, CONSTANTS } from '../model/DataModels';

// 礼物数据访问对象
export class GiftDAO {
  private dbManager: DatabaseManager;

  constructor() {
    this.dbManager = DatabaseManager.getInstance();
  }

  // 插入礼物
  public async insertGift(gift: Gift): Promise<boolean> {
    const store = this.dbManager.getStore();
    if (!store) {
      throw new Error('数据库未初始化');
    }

    try {
      const valueBucket: relationalStore.ValuesBucket = {
        id: gift.id,
        name: gift.name,
        description: gift.description,
        category: gift.category,
        subcategory: gift.subcategory || '',
        price: gift.price,
        priceRange: JSON.stringify(gift.priceRange),
        imageUrl: gift.imageUrl,
        images: JSON.stringify(gift.images || []),
        brand: gift.brand || '',
        rating: gift.rating,
        reviewCount: gift.reviewCount,
        tags: JSON.stringify(gift.tags),
        scenarios: JSON.stringify(gift.scenarios),
        targetGender: gift.targetGender,
        targetAge: gift.targetAge,
        relationship: JSON.stringify(gift.relationship),
        meaning: gift.meaning,
        culturalBackground: gift.culturalBackground || '',
        availability: gift.availability ? 1 : 0,
        createdAt: gift.createdAt,
        updatedAt: gift.updatedAt
      };

      await store.insert(TABLE_NAMES.GIFTS, valueBucket);
      return true;
    } catch (error) {
      console.error('插入礼物失败:', error);
      return false;
    }
  }

  // 批量插入礼物
  public async insertGifts(gifts: Gift[]): Promise<boolean> {
    const store = this.dbManager.getStore();
    if (!store) {
      throw new Error('数据库未初始化');
    }

    try {
      await store.beginTransaction();
      
      for (const gift of gifts) {
        const valueBucket: relationalStore.ValuesBucket = {
          id: gift.id,
          name: gift.name,
          description: gift.description,
          category: gift.category,
          subcategory: gift.subcategory || '',
          price: gift.price,
          priceRange: JSON.stringify(gift.priceRange),
          imageUrl: gift.imageUrl,
          images: JSON.stringify(gift.images || []),
          brand: gift.brand || '',
          rating: gift.rating,
          reviewCount: gift.reviewCount,
          tags: JSON.stringify(gift.tags),
          scenarios: JSON.stringify(gift.scenarios),
          targetGender: gift.targetGender,
          targetAge: gift.targetAge,
          relationship: JSON.stringify(gift.relationship),
          meaning: gift.meaning,
          culturalBackground: gift.culturalBackground || '',
          availability: gift.availability ? 1 : 0,
          createdAt: gift.createdAt,
          updatedAt: gift.updatedAt
        };
        
        await store.insert(TABLE_NAMES.GIFTS, valueBucket);
      }
      
      await store.commit();
      return true;
    } catch (error) {
      await store.rollBack();
      console.error('批量插入礼物失败:', error);
      return false;
    }
  }

  // 根据ID获取礼物
  public async getGiftById(id: string): Promise<Gift | null> {
    const store = this.dbManager.getStore();
    if (!store) {
      throw new Error('数据库未初始化');
    }

    try {
      const predicates = new relationalStore.RdbPredicates(TABLE_NAMES.GIFTS);
      predicates.equalTo('id', id);
      
      const resultSet = await store.query(predicates);
      if (resultSet.goToFirstRow()) {
        const gift = this.parseGiftFromResultSet(resultSet);
        resultSet.close();
        return gift;
      }
      
      resultSet.close();
      return null;
    } catch (error) {
      console.error('获取礼物失败:', error);
      return null;
    }
  }

  // 搜索礼物
  public async searchGifts(keyword?: string, filters?: SearchFilters, limit: number = 20, offset: number = 0): Promise<Gift[]> {
    const store = this.dbManager.getStore();
    if (!store) {
      throw new Error('数据库未初始化');
    }

    try {
      const predicates = new relationalStore.RdbPredicates(TABLE_NAMES.GIFTS);
      
      // 可用性筛选
      predicates.equalTo('availability', 1);
      
      // 关键词搜索
      if (keyword && keyword.trim()) {
        predicates.and();
        predicates.beginWrap();
        predicates.like('name', `%${keyword}%`);
        predicates.or().like('description', `%${keyword}%`);
        predicates.or().like('tags', `%${keyword}%`);
        predicates.endWrap();
      }
      
      // 分类筛选
      if (filters?.category) {
        predicates.and().equalTo('category', filters.category);
      }
      
      // 价格区间筛选
      if (filters?.priceRange) {
        predicates.and().equalTo('priceRange', filters.priceRange);
      }
      
      // 品牌筛选
      if (filters?.brand) {
        predicates.and().equalTo('brand', filters.brand);
      }
      
      // 评分筛选
      if (filters?.rating) {
        predicates.and().greaterThanOrEqualTo('rating', filters.rating);
      }
      
      // 性别筛选
      if (filters?.targetGender && filters.targetGender !== 'unisex') {
        predicates.and();
        predicates.beginWrap();
        predicates.equalTo('targetGender', filters.targetGender);
        predicates.or().equalTo('targetGender', 'unisex');
        predicates.endWrap();
      }
      
      // 年龄筛选
      if (filters?.targetAge) {
        predicates.and().equalTo('targetAge', filters.targetAge);
      }
      
      // 场景筛选
      if (filters?.scenarios && filters.scenarios.length > 0) {
        predicates.and();
        predicates.beginWrap();
        for (let i = 0; i < filters.scenarios.length; i++) {
          if (i > 0) predicates.or();
          predicates.like('scenarios', `%${filters.scenarios[i]}%`);
        }
        predicates.endWrap();
      }
      
      // 标签筛选
      if (filters?.tags && filters.tags.length > 0) {
        predicates.and();
        predicates.beginWrap();
        for (let i = 0; i < filters.tags.length; i++) {
          if (i > 0) predicates.or();
          predicates.like('tags', `%${filters.tags[i]}%`);
        }
        predicates.endWrap();
      }
      
      // 排序和分页
      predicates.orderByDesc('rating').orderByDesc('reviewCount');
      predicates.limitAs(limit).offsetAs(offset);
      
      const resultSet = await store.query(predicates);
      const gifts: Gift[] = [];
      
      if (resultSet.goToFirstRow()) {
        do {
          gifts.push(this.parseGiftFromResultSet(resultSet));
        } while (resultSet.goToNextRow());
      }
      
      resultSet.close();
      return gifts;
    } catch (error) {
      console.error('搜索礼物失败:', error);
      return [];
    }
  }

  // 根据分类获取礼物
  public async getGiftsByCategory(category: string, limit: number = 20): Promise<Gift[]> {
    const store = this.dbManager.getStore();
    if (!store) {
      throw new Error('数据库未初始化');
    }

    try {
      const predicates = new relationalStore.RdbPredicates(TABLE_NAMES.GIFTS);
      predicates.equalTo('category', category)
        .and().equalTo('availability', 1)
        .orderByDesc('rating')
        .limitAs(limit);
      
      const resultSet = await store.query(predicates);
      const gifts: Gift[] = [];
      
      if (resultSet.goToFirstRow()) {
        do {
          gifts.push(this.parseGiftFromResultSet(resultSet));
        } while (resultSet.goToNextRow());
      }
      
      resultSet.close();
      return gifts;
    } catch (error) {
      console.error('获取分类礼物失败:', error);
      return [];
    }
  }

  // 获取推荐礼物
  public async getRecommendedGifts(scenarios: string[], targetGender?: string, priceRange?: string, limit: number = 10): Promise<Gift[]> {
    const store = this.dbManager.getStore();
    if (!store) {
      throw new Error('数据库未初始化');
    }

    try {
      const predicates = new relationalStore.RdbPredicates(TABLE_NAMES.GIFTS);
      predicates.equalTo('availability', 1);
      
      // 场景匹配
      if (scenarios.length > 0) {
        predicates.and().beginWrap();
        for (let i = 0; i < scenarios.length; i++) {
          if (i > 0) predicates.or();
          predicates.like('scenarios', `%${scenarios[i]}%`);
        }
        predicates.endWrap();
      }
      
      // 性别匹配
      if (targetGender && targetGender !== 'unisex') {
        predicates.and().beginWrap();
        predicates.equalTo('targetGender', targetGender)
          .or().equalTo('targetGender', 'unisex');
        predicates.endWrap();
      }
      
      // 价格区间匹配
      if (priceRange) {
        predicates.and().equalTo('priceRange', priceRange);
      }
      
      predicates.orderByDesc('rating')
        .orderByDesc('reviewCount')
        .limitAs(limit);
      
      const resultSet = await store.query(predicates);
      const gifts: Gift[] = [];
      
      if (resultSet.goToFirstRow()) {
        do {
          gifts.push(this.parseGiftFromResultSet(resultSet));
        } while (resultSet.goToNextRow());
      }
      
      resultSet.close();
      return gifts;
    } catch (error) {
      console.error('获取推荐礼物失败:', error);
      return [];
    }
  }

  // 获取相似礼物
  public async getSimilarGifts(giftId: string, limit: number = 6): Promise<Gift[]> {
    const gift = await this.getGiftById(giftId);
    if (!gift) {
      return [];
    }

    const store = this.dbManager.getStore();
    if (!store) {
      throw new Error('数据库未初始化');
    }

    try {
      const predicates = new relationalStore.RdbPredicates(TABLE_NAMES.GIFTS);
      predicates.equalTo('availability', 1)
        .and().notEqualTo('id', giftId)
        .and().beginWrap()
        .equalTo('category', gift.category)
        .or().equalTo('priceRange', JSON.stringify(gift.priceRange))
        .or().equalTo('targetGender', gift.targetGender)
        .endWrap()
        .orderByDesc('rating')
        .limitAs(limit);
      
      const resultSet = await store.query(predicates);
      const gifts: Gift[] = [];
      
      if (resultSet.goToFirstRow()) {
        do {
          gifts.push(this.parseGiftFromResultSet(resultSet));
        } while (resultSet.goToNextRow());
      }
      
      resultSet.close();
      return gifts;
    } catch (error) {
      console.error('获取相似礼物失败:', error);
      return [];
    }
  }

  // 获取热门礼物
  public async getPopularGifts(limit: number = 10): Promise<Gift[]> {
    const store = this.dbManager.getStore();
    if (!store) {
      throw new Error('数据库未初始化');
    }

    try {
      const predicates = new relationalStore.RdbPredicates(TABLE_NAMES.GIFTS);
      predicates.equalTo('availability', 1)
        .orderByDesc('reviewCount')
        .orderByDesc('rating')
        .limitAs(limit);
      
      const resultSet = await store.query(predicates);
      const gifts: Gift[] = [];
      
      if (resultSet.goToFirstRow()) {
        do {
          gifts.push(this.parseGiftFromResultSet(resultSet));
        } while (resultSet.goToNextRow());
      }
      
      resultSet.close();
      return gifts;
    } catch (error) {
      console.error('获取热门礼物失败:', error);
      return [];
    }
  }

  // 获取最近浏览的礼物
  public async getRecentlyViewedGifts(limit: number = 10): Promise<Gift[]> {
    // 这里应该根据浏览历史获取礼物，暂时返回随机礼物
    return await this.getPopularGifts(limit);
  }

  // 更新礼物
  public async updateGift(gift: Gift): Promise<boolean> {
    const store = this.dbManager.getStore();
    if (!store) {
      throw new Error('数据库未初始化');
    }

    try {
      const valueBucket: relationalStore.ValuesBucket = {
        name: gift.name,
        description: gift.description,
        category: gift.category,
        subcategory: gift.subcategory || '',
        price: gift.price,
        priceRange: JSON.stringify(gift.priceRange),
        imageUrl: gift.imageUrl,
        images: JSON.stringify(gift.images || []),
        brand: gift.brand || '',
        rating: gift.rating,
        reviewCount: gift.reviewCount,
        tags: JSON.stringify(gift.tags),
        scenarios: JSON.stringify(gift.scenarios),
        targetGender: gift.targetGender,
        targetAge: gift.targetAge,
        relationship: JSON.stringify(gift.relationship),
        meaning: gift.meaning,
        culturalBackground: gift.culturalBackground || '',
        availability: gift.availability ? 1 : 0,
        updatedAt: this.dbManager.getCurrentTimestamp()
      };

      const predicates = new relationalStore.RdbPredicates(TABLE_NAMES.GIFTS);
      predicates.equalTo('id', gift.id);
      
      const result = await store.update(valueBucket, predicates);
      return result > 0;
    } catch (error) {
      console.error('更新礼物失败:', error);
      return false;
    }
  }

  // 删除礼物
  public async deleteGift(id: string): Promise<boolean> {
    const store = this.dbManager.getStore();
    if (!store) {
      throw new Error('数据库未初始化');
    }

    try {
      const predicates = new relationalStore.RdbPredicates(TABLE_NAMES.GIFTS);
      predicates.equalTo('id', id);
      
      const result = await store.delete(predicates);
      return result > 0;
    } catch (error) {
      console.error('删除礼物失败:', error);
      return false;
    }
  }

  // 从结果集解析礼物对象
  private parseGiftFromResultSet(resultSet: relationalStore.ResultSet): Gift {
    return {
      id: resultSet.getString(resultSet.getColumnIndex('id')),
      name: resultSet.getString(resultSet.getColumnIndex('name')),
      description: resultSet.getString(resultSet.getColumnIndex('description')),
      category: resultSet.getString(resultSet.getColumnIndex('category')),
      subcategory: resultSet.getString(resultSet.getColumnIndex('subcategory')),
      price: resultSet.getDouble(resultSet.getColumnIndex('price')),
      priceRange: JSON.parse(resultSet.getString(resultSet.getColumnIndex('priceRange')) || '{"min":0,"max":0}'),
      imageUrl: resultSet.getString(resultSet.getColumnIndex('imageUrl')),
      images: JSON.parse(resultSet.getString(resultSet.getColumnIndex('images')) || '[]'),
      brand: resultSet.getString(resultSet.getColumnIndex('brand')),
      rating: resultSet.getDouble(resultSet.getColumnIndex('rating')),
      reviewCount: resultSet.getLong(resultSet.getColumnIndex('reviewCount')),
      tags: JSON.parse(resultSet.getString(resultSet.getColumnIndex('tags')) || '[]'),
      scenarios: JSON.parse(resultSet.getString(resultSet.getColumnIndex('scenarios')) || '[]'),
      targetGender: resultSet.getString(resultSet.getColumnIndex('targetGender')),
      targetAge: resultSet.getString(resultSet.getColumnIndex('targetAge')),
      relationship: JSON.parse(resultSet.getString(resultSet.getColumnIndex('relationship')) || '[]'),
      meaning: resultSet.getString(resultSet.getColumnIndex('meaning')),
      culturalBackground: resultSet.getString(resultSet.getColumnIndex('culturalBackground')),
      availability: resultSet.getLong(resultSet.getColumnIndex('availability')) === 1,
      purchaseLinks: [], // 暂时为空数组，实际应用中可以从其他表获取
      createdAt: resultSet.getString(resultSet.getColumnIndex('createdAt')),
      updatedAt: resultSet.getString(resultSet.getColumnIndex('updatedAt'))
    };
  }
  
  // 获取所有礼物
  public async getAllGifts(): Promise<Gift[]> {
    const store = this.dbManager.getStore();
    if (!store) {
      throw new Error('数据库未初始化');
    }

    try {
      const predicates = new relationalStore.RdbPredicates(TABLE_NAMES.GIFTS);
      const resultSet = await store.query(predicates);
      const gifts: Gift[] = [];

      while (resultSet.goToNextRow()) {
        const gift = this.parseGiftFromResultSet(resultSet);
        gifts.push(gift);
      }

      resultSet.close();
      return gifts;
    } catch (error) {
      console.error('获取所有礼物失败:', error);
      return [];
    }
  }
}