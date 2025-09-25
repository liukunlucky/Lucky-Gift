import relationalStore from '@ohos.data.relationalStore';
import { Context } from '@ohos.abilityAccessCtrl';
import { Achievement, AchievementType, UserAchievementProgress, UserAchievementDetail, AchievementMilestone, AchievementStats } from '../model/NewDataModels';
import { NewDatabaseManager } from '../database/NewDatabaseManager';

export class AchievementDAO {
  private rdbStore: relationalStore.RdbStore | null = null;
  private userId: string = 'default'; // 默认用户ID
  private dbManager: NewDatabaseManager;

  constructor(userId: string = 'default', dbManager?: NewDatabaseManager) {
    this.userId = userId;
    this.dbManager = dbManager || new NewDatabaseManager();
  }

  // 初始化数据库连接
  async initDatabase(context: Context): Promise<void> {
    if (!this.dbManager.isInitialized()) {
      await this.dbManager.initDatabase(context);
    }
    this.rdbStore = this.dbManager.getRdbStore();
  }

  // 获取数据库连接的辅助方法
  private getStore(): relationalStore.RdbStore {
    if (!this.rdbStore) {
      throw new Error('Database not initialized. Call initDatabase() first.');
    }
    return this.rdbStore;
  }

  // 获取所有成就模板
  async getAllAchievementTemplates(): Promise<Achievement[]> {
    const rdbStore = this.getStore();
    const result = await rdbStore.querySql(
      'SELECT * FROM achievements ORDER BY id'
    );

    const achievements: Achievement[] = [];
    if (result.rowCount > 0) {
      for (let i = 0; i < result.rowCount; i++) {
        result.goToRow(i);
        const achievement = this.mapRowToAchievementTemplate(result);
        achievements.push(achievement);
      }
    }
    result.close();
    return achievements;
  }

  // 获取用户的所有成就详情（包含模板和个人进度）
  async getUserAchievementDetails(userId: string = this.userId): Promise<UserAchievementDetail[]> {
    // 获取所有成就模板
    const templates = await this.getAllAchievementTemplates();
    const details: UserAchievementDetail[] = [];

    for (const template of templates) {
      // 获取用户对该成就的进度
      let progress = await this.getUserAchievementProgress(userId, template.id);
      
      // 如果用户没有该成就的进度记录，创建一个默认的
      if (!progress) {
        progress = await this.createUserAchievementProgress(userId, template.id);
      }

      // 计算进度百分比
      const progressPercentage = Math.min(100, Math.round((progress.currentProgress / template.targetValue) * 100));

      const detail: UserAchievementDetail = {
        template: template,
        progress: progress,
        progressPercentage: progressPercentage
      };
      details.push(detail);
    }

    return details;
  }

  // 根据ID获取成就模板
  async getAchievementTemplateById(id: string): Promise<Achievement | null> {
    const result = await this.getStore().querySql(
      'SELECT * FROM achievements WHERE id = ?',
      [id]
    );

    let achievement: Achievement | null = null;
    if (result.rowCount > 0) {
      result.goToFirstRow();
      achievement = this.mapRowToAchievementTemplate(result);
    }
    result.close();
    return achievement;
  }

  // 获取用户成就进度
  async getUserAchievementProgress(userId: string, achievementId: string): Promise<UserAchievementProgress | null> {
    const result = await this.getStore().querySql(
      'SELECT * FROM user_achievement_progress WHERE user_id = ? AND achievement_id = ?',
      [userId, achievementId]
    );

    let progress: UserAchievementProgress | null = null;
    if (result.rowCount > 0) {
      result.goToFirstRow();
      progress = this.mapRowToUserProgress(result);
    }
    result.close();
    return progress;
  }

  // 创建用户成就进度记录
  async createUserAchievementProgress(userId: string, achievementId: string): Promise<UserAchievementProgress> {
    const id = 'progress_' + Date.now().toString() + '_' + Math.random().toString(36).substr(2, 9);
    const now = new Date().toISOString();

    const valueBucket: relationalStore.ValuesBucket = {
      id: id,
      user_id: userId,
      achievement_id: achievementId,
      current_progress: 0,
      is_unlocked: 0,
      unlocked_at: null,
      last_updated: now
    };

    await this.getStore().insert('user_achievement_progress', valueBucket);

    const progress: UserAchievementProgress = {
      id: id,
      userId: userId,
      achievementId: achievementId,
      currentProgress: 0,
      isUnlocked: false,
      unlockedAt: undefined,
      lastUpdated: now
    };
    return progress;
  }

  // 获取用户已解锁的成就
  async getUserUnlockedAchievements(userId: string = this.userId): Promise<UserAchievementDetail[]> {
    const allDetails = await this.getUserAchievementDetails(userId);
    return allDetails.filter(detail => detail.progress.isUnlocked);
  }

  // 获取用户未解锁的成就
  async getUserLockedAchievements(userId: string = this.userId): Promise<UserAchievementDetail[]> {
    const allDetails = await this.getUserAchievementDetails(userId);
    return allDetails.filter(detail => !detail.progress.isUnlocked);
  }

  // 更新用户成就进度
  async updateUserAchievementProgress(userId: string, achievementId: string, progress: number): Promise<boolean> {
    try {
      const valueBucket: relationalStore.ValuesBucket = {
        current_progress: progress,
        last_updated: new Date().toISOString()
      };

      const predicates = new relationalStore.RdbPredicates('user_achievement_progress');
      predicates.equalTo('user_id', userId).and().equalTo('achievement_id', achievementId);

      const result = await this.getStore().update(valueBucket, predicates);
      return result > 0;
    } catch (error) {
      console.error('Failed to update user achievement progress:', error);
      return false;
    }
  }

  // 解锁用户成就
  async unlockUserAchievement(userId: string, achievementId: string): Promise<boolean> {
    try {
      const now = new Date().toISOString();
      const valueBucket: relationalStore.ValuesBucket = {
        is_unlocked: 1,
        unlocked_at: now,
        last_updated: now
      };

      const predicates = new relationalStore.RdbPredicates('user_achievement_progress');
      predicates.equalTo('user_id', userId).and().equalTo('achievement_id', achievementId);

      const result = await this.getStore().update(valueBucket, predicates);
      
      // 如果解锁成功，添加里程碑记录
      if (result > 0) {
        const template = await this.getAchievementTemplateById(achievementId);
        if (template) {
          await this.addAchievementMilestone(achievementId, `解锁成就：${template.name}`);
        }
      }
      
      return result > 0;
    } catch (error) {
      console.error('Failed to unlock user achievement:', error);
      return false;
    }
  }

  // 添加成就里程碑
  async addAchievementMilestone(achievementId: string, description: string, relatedEventId?: string): Promise<string> {
    const id = 'milestone_' + Date.now().toString();
    const now = new Date().toISOString();

    const valueBucket: relationalStore.ValuesBucket = {
      id: id,
      achievement_id: achievementId,
      date: now,
      description: description,
      related_event_id: relatedEventId || null
    };

    await this.getStore().insert('achievement_milestones', valueBucket);
    return id;
  }

  // 获取成就的里程碑
  async getAchievementMilestones(achievementId: string): Promise<AchievementMilestone[]> {
    const result = await this.getStore().querySql(
      'SELECT * FROM achievement_milestones WHERE achievement_id = ? ORDER BY date DESC',
      [achievementId]
    );

    const milestones: AchievementMilestone[] = [];
    if (result.rowCount > 0) {
      for (let i = 0; i < result.rowCount; i++) {
        result.goToRow(i);
        const milestone = this.mapRowToMilestone(result);
        milestones.push(milestone);
      }
    }
    result.close();
    return milestones;
  }

  // 获取用户成就统计
  async getUserAchievementStats(userId: string = this.userId): Promise<AchievementStats> {
    // 获取总成就数
    const totalResult = await this.getStore().querySql('SELECT COUNT(*) as total FROM achievements');
    totalResult.goToFirstRow();
    const total = totalResult.getLong(0);
    totalResult.close();

    // 获取用户已解锁成就数
    const unlockedResult = await this.getStore().querySql(
      'SELECT COUNT(*) as unlocked FROM user_achievement_progress WHERE user_id = ? AND is_unlocked = 1',
      [userId]
    );
    unlockedResult.goToFirstRow();
    const unlocked = unlockedResult.getLong(0);
    unlockedResult.close();

    const percentage = total > 0 ? Math.round((unlocked / total) * 100) : 0;

    const stats: AchievementStats = {
      total: Number(total),
      unlocked: Number(unlocked),
      progress: percentage
    };
    return stats;
  }

  // 检查并更新用户成就
  async checkAndUpdateUserAchievements(userId: string = this.userId): Promise<void> {
    // 获取所有成就模板
    const templates = await this.getAllAchievementTemplates();
    
    for (const template of templates) {
      await this.checkSingleAchievement(userId, template);
    }
  }

  // 检查单个成就
  private async checkSingleAchievement(userId: string, template: Achievement): Promise<void> {
    // 获取或创建用户进度记录
    let progress = await this.getUserAchievementProgress(userId, template.id);
    if (!progress) {
      progress = await this.createUserAchievementProgress(userId, template.id);
    }

    // 如果已经解锁，跳过检查
    if (progress.isUnlocked) {
      return;
    }

    let currentProgress = 0;

    // 根据成就类型计算进度
    switch (template.id) {
      case 'first_gift':
        // 初次尝试：送出第一份礼物
        currentProgress = await this.getUserGiftCount(userId);
        break;
        
      case 'thoughtful_giver':
        // 心意满满：累计送礼10次
        currentProgress = await this.getUserGiftCount(userId);
        break;
        
      case 'mind_reader':
        // 读心大师：收到5次"非常开心"评价
        currentProgress = await this.getUserHappyFeedbackCount(userId);
        break;
        
      case 'budget_master':
        // 预算达人：连续3次送礼都在预算内
        currentProgress = await this.getUserConsecutiveBudgetCount(userId);
        break;
        
      case 'holiday_pioneer':
        // 节日先锋：提前一周设置重要节日提醒
        currentProgress = await this.getUserEarlyHolidayReminderCount(userId);
        break;
        
      case 'gift_master':
        // 送礼达人：累计送礼25次
        currentProgress = await this.getUserGiftCount(userId);
        break;
        
      case 'emotion_expert':
        // 情感专家：为不同情感状态的人送礼
        currentProgress = await this.getUserDifferentEmotionGiftCount(userId);
        break;
    }

    // 更新进度
    if (currentProgress !== progress.currentProgress) {
      await this.updateUserAchievementProgress(userId, template.id, currentProgress);
    }

    // 检查是否达到解锁条件
    if (currentProgress >= template.targetValue && !progress.isUnlocked) {
      await this.unlockUserAchievement(userId, template.id);
    }
  }

  // 获取用户送礼次数
  private async getUserGiftCount(userId: string): Promise<number> {
    const result = await this.getStore().querySql(
      'SELECT COUNT(*) as count FROM gift_events',
      []
    );
    result.goToFirstRow();
    const count = result.getLong(0);
    result.close();
    return Number(count);
  }

  // 获取用户收到"非常开心"评价次数
  private async getUserHappyFeedbackCount(userId: string): Promise<number> {
    const result = await this.getStore().querySql(
      'SELECT COUNT(*) as count FROM gift_events WHERE reaction = ?',
      ['非常开心']
    );
    result.goToFirstRow();
    const count = result.getLong(0);
    result.close();
    return Number(count);
  }

  // 获取用户连续预算内送礼次数
  private async getUserConsecutiveBudgetCount(userId: string): Promise<number> {
    const result = await this.getStore().querySql(
      'SELECT * FROM gift_events ORDER BY created_at DESC LIMIT 3',
      []
    );
    
    let consecutiveCount = 0;
    if (result.rowCount > 0) {
      for (let i = 0; i < result.rowCount; i++) {
        result.goToRow(i);
        const actualCost = result.getDouble(result.getColumnIndex('actual_cost'));
        const budget = result.getDouble(result.getColumnIndex('budget'));
        
        if (actualCost <= budget) {
          consecutiveCount++;
        } else {
          break; // 连续记录中断
        }
      }
    }
    result.close();
    return consecutiveCount;
  }

  // 获取用户提前设置节日提醒次数
  private async getUserEarlyHolidayReminderCount(userId: string): Promise<number> {
    // 这里需要根据实际的节日提醒表结构来实现
    // 暂时返回0，等待节日提醒功能完善
    return 0;
  }

  // 获取用户为不同情感状态送礼次数
  private async getUserDifferentEmotionGiftCount(userId: string): Promise<number> {
    const result = await this.getStore().querySql(
      'SELECT COUNT(DISTINCT mood) as count FROM gift_events WHERE mood IS NOT NULL',
      []
    );
    result.goToFirstRow();
    const count = result.getLong(0);
    result.close();
    return Number(count);
  }

  // 安全地解析成就类型
  private parseAchievementType(typeString: string): AchievementType {
    switch (typeString) {
      case 'gift_count':
        return AchievementType.GIFT_COUNT;
      case 'feedback_quality':
        return AchievementType.FEEDBACK_QUALITY;
      case 'budget_control':
        return AchievementType.BUDGET_CONTROL;
      case 'planning_ahead':
        return AchievementType.PLANNING_AHEAD;
      default:
        return AchievementType.GIFT_COUNT; // 默认值
    }
  }

  // 将数据库行映射为成就模板对象
  private mapRowToAchievementTemplate(result: relationalStore.ResultSet): Achievement {
    const achievement: Achievement = {
      id: result.getString(result.getColumnIndex('id')),
      name: result.getString(result.getColumnIndex('name')),
      description: result.getString(result.getColumnIndex('description')),
      icon: result.getString(result.getColumnIndex('icon')),
      type: this.parseAchievementType(result.getString(result.getColumnIndex('type'))),
      conditionType: this.parseAchievementType(result.getString(result.getColumnIndex('condition_type'))),
      targetValue: Number(result.getLong(result.getColumnIndex('target_value'))),
      timeWindow: result.getLong(result.getColumnIndex('time_window')) || undefined,
      specificValue: result.getString(result.getColumnIndex('specific_value'))
    };
    return achievement;
  }

  private mapRowToUserProgress(result: relationalStore.ResultSet): UserAchievementProgress {
    const progress: UserAchievementProgress = {
      id: result.getString(result.getColumnIndex('id')),
      userId: result.getString(result.getColumnIndex('user_id')),
      achievementId: result.getString(result.getColumnIndex('achievement_id')),
      currentProgress: Number(result.getLong(result.getColumnIndex('current_progress'))),
      isUnlocked: result.getLong(result.getColumnIndex('is_unlocked')) === 1,
      unlockedAt: result.getString(result.getColumnIndex('unlocked_at')),
      lastUpdated: result.getString(result.getColumnIndex('last_updated'))
    };
    return progress;
  }

  // 将数据库行映射为AchievementMilestone对象
  private mapRowToMilestone(result: relationalStore.ResultSet): AchievementMilestone {
    const milestone: AchievementMilestone = {
      date: result.getString(result.getColumnIndex('date')),
      description: result.getString(result.getColumnIndex('description')),
      relatedEventId: result.isColumnNull(result.getColumnIndex('related_event_id')) ? 
        undefined : result.getString(result.getColumnIndex('related_event_id'))
    };

    return milestone;
  }
}