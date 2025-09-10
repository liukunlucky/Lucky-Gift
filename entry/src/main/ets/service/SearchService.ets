import { DatabaseManager } from '../database/DatabaseManager';
import { Gift, TABLE_NAMES } from '../model/DataModels';
import relationalStore from '@ohos.data.relationalStore';

// 搜索筛选参数
export interface SearchFilters {
  keyword?: string;
  categories?: string[];
  priceRange?: string;
  brands?: string[];
  tags?: string[];
  minPrice?: number;
  maxPrice?: number;
  sortBy?: 'name' | 'price' | 'createdAt' | 'popularity';
  sortOrder?: 'asc' | 'desc';
  limit?: number;
  offset?: number;
}

// 搜索结果
export interface SearchResult {
  gifts: Gift[];
  total: number;
  hasMore: boolean;
}

// 搜索服务
export class SearchService {
  private dbManager: DatabaseManager;

  constructor() {
    this.dbManager = DatabaseManager.getInstance();
  }

  // 搜索礼物
  public async searchGifts(filters: SearchFilters): Promise<SearchResult> {
    const store = this.dbManager.getStore();
    if (!store) {
      throw new Error('数据库未初始化');
    }

    try {
      const predicates = this.buildSearchPredicates(filters);
      
      // 获取总数
      const total = await this.getSearchCount(predicates);
      
      // 应用排序
      this.applySorting(predicates, filters);
      
      // 应用分页
      if (filters.limit !== undefined) {
        predicates.limitAs(filters.limit);
      }
      if (filters.offset !== undefined) {
        predicates.offsetAs(filters.offset);
      }
      
      const resultSet = await store.query(predicates);
      const gifts: Gift[] = [];
      
      while (resultSet.goToNextRow()) {
        gifts.push(this.parseGiftFromResultSet(resultSet));
      }
      
      resultSet.close();
      
      const hasMore = filters.offset !== undefined && filters.limit !== undefined 
        ? (filters.offset + filters.limit) < total 
        : false;
      
      return {
        gifts,
        total,
        hasMore
      };
    } catch (error) {
      console.error('搜索礼物失败:', error);
      return {
        gifts: [],
        total: 0,
        hasMore: false
      };
    }
  }

  // 快速搜索（仅根据关键词）
  public async quickSearch(keyword: string, limit: number = 10): Promise<Gift[]> {
    const result = await this.searchGifts({
      keyword,
      limit,
      sortBy: 'name',
      sortOrder: 'asc'
    });
    return result.gifts;
  }

  // 按分类搜索
  public async searchByCategory(category: string, limit?: number, offset?: number): Promise<SearchResult> {
    return await this.searchGifts({
      categories: [category],
      limit,
      offset,
      sortBy: 'name',
      sortOrder: 'asc'
    });
  }

  // 按价格区间搜索
  public async searchByPriceRange(minPrice: number, maxPrice: number, limit?: number): Promise<Gift[]> {
    const result = await this.searchGifts({
      minPrice,
      maxPrice,
      limit,
      sortBy: 'price',
      sortOrder: 'asc'
    });
    return result.gifts;
  }

  // 按品牌搜索
  public async searchByBrand(brand: string, limit?: number): Promise<Gift[]> {
    const result = await this.searchGifts({
      brands: [brand],
      limit,
      sortBy: 'name',
      sortOrder: 'asc'
    });
    return result.gifts;
  }

  // 按标签搜索
  public async searchByTags(tags: string[], limit?: number): Promise<Gift[]> {
    const result = await this.searchGifts({
      tags,
      limit,
      sortBy: 'name',
      sortOrder: 'asc'
    });
    return result.gifts;
  }

  // 获取所有分类
  public async getAllCategories(): Promise<string[]> {
    const store = this.dbManager.getStore();
    if (!store) {
      throw new Error('数据库未初始化');
    }

    try {
      const predicates = new relationalStore.RdbPredicates(TABLE_NAMES.GIFTS);
      const resultSet = await store.query(predicates, ['DISTINCT category']);
      
      const categories: string[] = [];
      while (resultSet.goToNextRow()) {
        const category = resultSet.getString(0);
        if (category) {
          categories.push(category);
        }
      }
      
      resultSet.close();
      return categories.sort();
    } catch (error) {
      console.error('获取分类失败:', error);
      return [];
    }
  }

  // 获取所有品牌
  public async getAllBrands(): Promise<string[]> {
    const store = this.dbManager.getStore();
    if (!store) {
      throw new Error('数据库未初始化');
    }

    try {
      const predicates = new relationalStore.RdbPredicates(TABLE_NAMES.GIFTS);
      const resultSet = await store.query(predicates, ['DISTINCT brand']);
      
      const brands: string[] = [];
      while (resultSet.goToNextRow()) {
        const brand = resultSet.getString(0);
        if (brand) {
          brands.push(brand);
        }
      }
      
      resultSet.close();
      return brands.sort();
    } catch (error) {
      console.error('获取品牌失败:', error);
      return [];
    }
  }

  // 获取价格区间统计
  public async getPriceRangeStats(): Promise<{
    min: number;
    max: number;
    avg: number;
    ranges: { range: string; count: number }[];
  }> {
    const store = this.dbManager.getStore();
    if (!store) {
      throw new Error('数据库未初始化');
    }

    try {
      const predicates = new relationalStore.RdbPredicates(TABLE_NAMES.GIFTS);
      const resultSet = await store.query(predicates, [
        'MIN(CAST(SUBSTR(priceRange, 1, INSTR(priceRange, "-") - 1) AS REAL)) as minPrice',
        'MAX(CAST(SUBSTR(priceRange, INSTR(priceRange, "-") + 1) AS REAL)) as maxPrice',
        'AVG(CAST(SUBSTR(priceRange, 1, INSTR(priceRange, "-") - 1) AS REAL)) as avgPrice'
      ]);
      
      let min = 0, max = 0, avg = 0;
      if (resultSet.goToFirstRow()) {
        min = resultSet.getDouble(0);
        max = resultSet.getDouble(1);
        avg = resultSet.getDouble(2);
      }
      resultSet.close();
      
      // 获取价格区间分布
      const ranges = await this.getPriceRangeDistribution();
      
      return { min, max, avg, ranges };
    } catch (error) {
      console.error('获取价格统计失败:', error);
      return { min: 0, max: 0, avg: 0, ranges: [] };
    }
  }

  // 获取搜索建议
  public async getSearchSuggestions(keyword: string, limit: number = 5): Promise<string[]> {
    const store = this.dbManager.getStore();
    if (!store) {
      throw new Error('数据库未初始化');
    }

    try {
      const predicates = new relationalStore.RdbPredicates(TABLE_NAMES.GIFTS);
      predicates.like('name', `%${keyword}%`)
        .or()
        .like('description', `%${keyword}%`)
        .or()
        .like('tags', `%${keyword}%`);
      
      predicates.limitAs(limit);
      
      const resultSet = await store.query(predicates, ['name']);
      const suggestions: string[] = [];
      
      while (resultSet.goToNextRow()) {
        suggestions.push(resultSet.getString(0));
      }
      
      resultSet.close();
      return suggestions;
    } catch (error) {
      console.error('获取搜索建议失败:', error);
      return [];
    }
  }

  // 构建搜索条件
  private buildSearchPredicates(filters: SearchFilters): relationalStore.RdbPredicates {
    const predicates = new relationalStore.RdbPredicates(TABLE_NAMES.GIFTS);
    let hasCondition = false;

    // 关键词搜索
    if (filters.keyword && filters.keyword.trim()) {
      const keyword = filters.keyword.trim();
      predicates.like('name', `%${keyword}%`)
        .or()
        .like('description', `%${keyword}%`)
        .or()
        .like('tags', `%${keyword}%`);
      hasCondition = true;
    }

    // 分类筛选
    if (filters.categories && filters.categories.length > 0) {
      if (hasCondition) predicates.and();
      predicates.in('category', filters.categories);
      hasCondition = true;
    }

    // 品牌筛选
    if (filters.brands && filters.brands.length > 0) {
      if (hasCondition) predicates.and();
      predicates.in('brand', filters.brands);
      hasCondition = true;
    }

    // 价格区间筛选
    if (filters.priceRange) {
      if (hasCondition) predicates.and();
      predicates.equalTo('priceRange', filters.priceRange);
      hasCondition = true;
    }

    // 最小价格
    if (filters.minPrice !== undefined) {
      if (hasCondition) predicates.and();
      // 这里需要解析priceRange字段的最小值进行比较
      predicates.greaterThanOrEqualTo('CAST(SUBSTR(priceRange, 1, INSTR(priceRange, "-") - 1) AS REAL)', filters.minPrice);
      hasCondition = true;
    }

    // 最大价格
    if (filters.maxPrice !== undefined) {
      if (hasCondition) predicates.and();
      // 这里需要解析priceRange字段的最大值进行比较
      predicates.lessThanOrEqualTo('CAST(SUBSTR(priceRange, INSTR(priceRange, "-") + 1) AS REAL)', filters.maxPrice);
      hasCondition = true;
    }

    // 标签筛选
    if (filters.tags && filters.tags.length > 0) {
      if (hasCondition) predicates.and();
      // 对于JSON数组字段，需要使用LIKE进行模糊匹配
      let tagCondition = false;
      for (const tag of filters.tags) {
        if (tagCondition) predicates.or();
        predicates.like('tags', `%"${tag}"%`);
        tagCondition = true;
      }
      hasCondition = true;
    }

    return predicates;
  }

  // 应用排序
  private applySorting(predicates: relationalStore.RdbPredicates, filters: SearchFilters): void {
    const sortBy = filters.sortBy || 'name';
    const sortOrder = filters.sortOrder || 'asc';

    switch (sortBy) {
      case 'name':
        if (sortOrder === 'desc') {
          predicates.orderByDesc('name');
        } else {
          predicates.orderByAsc('name');
        }
        break;
      case 'price':
        // 按价格排序需要解析priceRange字段
        if (sortOrder === 'desc') {
          predicates.orderByDesc('CAST(SUBSTR(priceRange, 1, INSTR(priceRange, "-") - 1) AS REAL)');
        } else {
          predicates.orderByAsc('CAST(SUBSTR(priceRange, 1, INSTR(priceRange, "-") - 1) AS REAL)');
        }
        break;
      case 'createdAt':
        if (sortOrder === 'desc') {
          predicates.orderByDesc('createdAt');
        } else {
          predicates.orderByAsc('createdAt');
        }
        break;
      default:
        predicates.orderByAsc('name');
    }
  }

  // 获取搜索结果总数
  private async getSearchCount(predicates: relationalStore.RdbPredicates): Promise<number> {
    const store = this.dbManager.getStore();
    if (!store) {
      return 0;
    }

    try {
      const countPredicates = new relationalStore.RdbPredicates(predicates.tableName);
      // 复制查询条件但不包括排序和分页
      const resultSet = await store.query(countPredicates, ['COUNT(*) as count']);
      let count = 0;
      if (resultSet.goToFirstRow()) {
        count = resultSet.getLong(0);
      }
      resultSet.close();
      return count;
    } catch (error) {
      console.error('获取搜索总数失败:', error);
      return 0;
    }
  }

  // 获取价格区间分布
  private async getPriceRangeDistribution(): Promise<{ range: string; count: number }[]> {
    const store = this.dbManager.getStore();
    if (!store) {
      return [];
    }

    try {
      const predicates = new relationalStore.RdbPredicates(TABLE_NAMES.GIFTS);
      const resultSet = await store.query(predicates, ['priceRange', 'COUNT(*) as count']);
      resultSet.groupBy(['priceRange']);
      
      const ranges: { range: string; count: number }[] = [];
      while (resultSet.goToNextRow()) {
        ranges.push({
          range: resultSet.getString(0),
          count: resultSet.getLong(1)
        });
      }
      
      resultSet.close();
      return ranges;
    } catch (error) {
      console.error('获取价格区间分布失败:', error);
      return [];
    }
  }

  // 从结果集解析礼物
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
}