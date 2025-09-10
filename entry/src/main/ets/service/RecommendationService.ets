import { GiftDAO } from '../database/GiftDAO';
import { Gift, SearchFilters } from '../model/DataModels';

// 推荐权重配置
interface RecommendationWeights {
  scenarioMatch: number;
  genderMatch: number;
  ageMatch: number;
  relationshipMatch: number;
  priceRangeMatch: number;
  ratingBonus: number;
  popularityBonus: number;
}

// 推荐参数
export interface RecommendationParams {
  scenarios?: string[];
  targetGender?: string;
  targetAge?: string;
  relationship?: string[];
  priceRange?: string;
  excludeCategories?: string[];
  preferredTags?: string[];
  maxResults?: number;
}

// 推荐结果
export interface RecommendationResult {
  gift: Gift;
  score: number;
  reasons: string[];
}

// 相似度计算结果
interface SimilarityResult {
  gift: Gift;
  similarity: number;
}

// 本地推荐服务
export class RecommendationService {
  private giftDAO: GiftDAO;
  private weights: RecommendationWeights;

  constructor() {
    this.giftDAO = new GiftDAO();
    this.weights = {
      scenarioMatch: 0.3,
      genderMatch: 0.2,
      ageMatch: 0.15,
      relationshipMatch: 0.2,
      priceRangeMatch: 0.1,
      ratingBonus: 0.03,
      popularityBonus: 0.02
    };
  }

  // 获取推荐礼物
  public async getRecommendedGifts(limit: number = 10): Promise<Gift[]> {
    try {
      // 获取所有可用礼物
      const allGifts = await this.giftDAO.getAllGifts();
      
      // 简单推荐：按评分和评论数排序
      const sortedGifts = allGifts
        .filter(gift => gift.availability)
        .sort((a, b) => {
          const scoreA = a.rating * 0.7 + (a.reviewCount / 100) * 0.3;
          const scoreB = b.rating * 0.7 + (b.reviewCount / 100) * 0.3;
          return scoreB - scoreA;
        })
        .slice(0, limit);
      
      return sortedGifts;
    } catch (error) {
      console.error('获取推荐礼物失败:', error);
      return [];
    }
  }

  // 获取个性化推荐
  public async getPersonalizedRecommendations(params: RecommendationParams): Promise<RecommendationResult[]> {
    try {
      // 获取所有可用礼物
      const allGifts = await this.giftDAO.searchGifts('', undefined, 1000);
      
      // 计算每个礼物的推荐分数
      const scoredGifts: RecommendationResult[] = [];
      
      for (const gift of allGifts) {
        // 排除指定分类
        if (params.excludeCategories && params.excludeCategories.includes(gift.category)) {
          continue;
        }
        
        const result = this.calculateRecommendationScore(gift, params);
        if (result.score > 0) {
          scoredGifts.push(result);
        }
      }
      
      // 按分数排序并返回指定数量的结果
      const maxResults = params.maxResults || 10;
      return scoredGifts
        .sort((a, b) => b.score - a.score)
        .slice(0, maxResults);
        
    } catch (error) {
      console.error('获取推荐失败:', error);
      return [];
    }
  }

  // 计算推荐分数
  private calculateRecommendationScore(gift: Gift, params: RecommendationParams): RecommendationResult {
    let score = 0;
    const reasons: string[] = [];
    
    // 场景匹配
    if (params.scenarios && params.scenarios.length > 0) {
      const matchedScenarios = params.scenarios.filter(scenario => 
        gift.scenarios.includes(scenario)
      );
      if (matchedScenarios.length > 0) {
        score += this.weights.scenarioMatch * (matchedScenarios.length / params.scenarios.length);
        reasons.push(`适合${matchedScenarios.join('、')}场景`);
      }
    }
    
    // 性别匹配
    if (params.targetGender) {
      if (gift.targetGender === params.targetGender || gift.targetGender === 'unisex') {
        score += this.weights.genderMatch;
        if (gift.targetGender === params.targetGender) {
          reasons.push(`专为${params.targetGender === 'male' ? '男性' : '女性'}设计`);
        } else {
          reasons.push('男女通用');
        }
      }
    }
    
    // 年龄匹配
    if (params.targetAge && gift.targetAge === params.targetAge) {
      score += this.weights.ageMatch;
      reasons.push(`适合${params.targetAge}年龄段`);
    }
    
    // 关系匹配
    if (params.relationship && params.relationship.length > 0) {
      const matchedRelationships = params.relationship.filter(rel => 
        gift.relationship.includes(rel)
      );
      if (matchedRelationships.length > 0) {
        score += this.weights.relationshipMatch * (matchedRelationships.length / params.relationship.length);
        reasons.push(`适合送给${matchedRelationships.join('、')}`);
      }
    }
    
    // 价格区间匹配
    if (params.priceRange) {
      const priceRangeMatch = this.checkPriceRangeMatch(gift.price, params.priceRange);
      if (priceRangeMatch) {
        score += this.weights.priceRangeMatch;
        reasons.push(`价格在预算范围内`);
      }
    }
    
    // 偏好标签匹配
    if (params.preferredTags && params.preferredTags.length > 0) {
      const matchedTags = params.preferredTags.filter(tag => 
        gift.tags.includes(tag)
      );
      if (matchedTags.length > 0) {
        score += 0.1 * (matchedTags.length / params.preferredTags.length);
        reasons.push(`符合${matchedTags.join('、')}偏好`);
      }
    }
    
    // 评分加成
    if (gift.rating >= 4.5) {
      score += this.weights.ratingBonus;
      reasons.push(`高评分商品(${gift.rating}分)`);
    }
    
    // 热度加成
    if (gift.reviewCount >= 1000) {
      score += this.weights.popularityBonus;
      reasons.push(`热门商品`);
    }
    
    return {
      gift,
      score,
      reasons
    };
  }

  // 检查价格区间匹配
  private checkPriceRangeMatch(price: number, priceRange: string): boolean {
    switch (priceRange) {
      case '0-50':
        return price <= 50;
      case '50-200':
        return price > 50 && price <= 200;
      case '200-500':
        return price > 200 && price <= 500;
      case '500-1000':
        return price > 500 && price <= 1000;
      case '1000+':
        return price > 1000;
      default:
        return true;
    }
  }

  // 获取热门推荐
  public async getPopularRecommendations(limit: number = 10): Promise<Gift[]> {
    try {
      const allGifts = await this.giftDAO.searchGifts('', undefined, 100);
      
      return allGifts
        .sort((a, b) => {
          // 按评分和评论数综合排序
          const scoreA = a.rating * 0.7 + Math.log(a.reviewCount + 1) * 0.3;
          const scoreB = b.rating * 0.7 + Math.log(b.reviewCount + 1) * 0.3;
          return scoreB - scoreA;
        })
        .slice(0, limit);
        
    } catch (error) {
      console.error('获取热门推荐失败:', error);
      return [];
    }
  }

  // 获取分类推荐
  public async getCategoryRecommendations(category: string, limit: number = 10): Promise<Gift[]> {
    try {
      return await this.giftDAO.getGiftsByCategory(category, limit);
    } catch (error) {
      console.error('获取分类推荐失败:', error);
      return [];
    }
  }

  // 获取相似推荐
  public async getSimilarRecommendations(giftId: string, limit: number = 5): Promise<Gift[]> {
    try {
      const targetGift = await this.giftDAO.getGiftById(giftId);
      if (!targetGift) {
        return [];
      }
      
      const allGifts = await this.giftDAO.searchGifts('', undefined, 200);
      
      // 计算相似度
      const similarGifts = allGifts
        .filter(gift => gift.id !== giftId)
        .map(gift => {
          const result: SimilarityResult = {
            gift: gift,
            similarity: this.calculateSimilarity(targetGift, gift)
          };
          return result;
        })
        .sort((a, b) => b.similarity - a.similarity)
        .slice(0, limit)
        .map(item => item.gift);
        
      return similarGifts;
      
    } catch (error) {
      console.error('获取相似推荐失败:', error);
      return [];
    }
  }

  // 计算礼物相似度
  private calculateSimilarity(gift1: Gift, gift2: Gift): number {
    let similarity = 0;
    
    // 分类相似度
    if (gift1.category === gift2.category) {
      similarity += 0.3;
      if (gift1.subcategory === gift2.subcategory) {
        similarity += 0.2;
      }
    }
    
    // 价格相似度
    const priceDiff = Math.abs(gift1.price - gift2.price);
    const maxPrice = Math.max(gift1.price, gift2.price);
    if (maxPrice > 0) {
      similarity += 0.2 * (1 - priceDiff / maxPrice);
    }
    
    // 标签相似度
    const commonTags = gift1.tags.filter(tag => gift2.tags.includes(tag));
    if (gift1.tags.length > 0 && gift2.tags.length > 0) {
      similarity += 0.2 * (commonTags.length / Math.max(gift1.tags.length, gift2.tags.length));
    }
    
    // 场景相似度
    const commonScenarios = gift1.scenarios.filter(scenario => gift2.scenarios.includes(scenario));
    if (gift1.scenarios.length > 0 && gift2.scenarios.length > 0) {
      similarity += 0.2 * (commonScenarios.length / Math.max(gift1.scenarios.length, gift2.scenarios.length));
    }
    
    // 目标人群相似度
    if (gift1.targetGender === gift2.targetGender) {
      similarity += 0.1;
    }
    
    return similarity;
  }

  // 更新推荐权重
  public updateWeights(newWeights: RecommendationWeights): void {
    if (newWeights.scenarioMatch !== undefined) {
      this.weights.scenarioMatch = newWeights.scenarioMatch;
    }
    if (newWeights.genderMatch !== undefined) {
      this.weights.genderMatch = newWeights.genderMatch;
    }
    if (newWeights.ageMatch !== undefined) {
      this.weights.ageMatch = newWeights.ageMatch;
    }
    if (newWeights.relationshipMatch !== undefined) {
      this.weights.relationshipMatch = newWeights.relationshipMatch;
    }
    if (newWeights.priceRangeMatch !== undefined) {
      this.weights.priceRangeMatch = newWeights.priceRangeMatch;
    }
    if (newWeights.ratingBonus !== undefined) {
      this.weights.ratingBonus = newWeights.ratingBonus;
    }
    if (newWeights.popularityBonus !== undefined) {
      this.weights.popularityBonus = newWeights.popularityBonus;
    }
  }

  // 获取当前权重配置
  public getWeights(): RecommendationWeights {
    return {
      scenarioMatch: this.weights.scenarioMatch,
      genderMatch: this.weights.genderMatch,
      ageMatch: this.weights.ageMatch,
      relationshipMatch: this.weights.relationshipMatch,
      priceRangeMatch: this.weights.priceRangeMatch,
      ratingBonus: this.weights.ratingBonus,
      popularityBonus: this.weights.popularityBonus
    };
  }
}