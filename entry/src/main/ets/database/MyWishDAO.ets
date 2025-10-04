import { relationalStore } from '@kit.ArkData';
import { NewDatabaseManager } from './NewDatabaseManager';
import { MyWish, WishProgress, WishStats, WishCategory, WishPriority, WishStatus } from '../model/NewDataModels';

export class MyWishDAO {
  private dbManager: NewDatabaseManager;

  constructor(dbManager: NewDatabaseManager) {
    this.dbManager = dbManager;
  }

  // 创建心愿
  async createWish(wish: MyWish): Promise<string> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const id = this.dbManager.generateId();
    const now = this.dbManager.getCurrentTimestamp();

    const valueBucket: relationalStore.ValuesBucket = {
      id: id,
      title: wish.title,
      description: wish.description,
      category: wish.category,
      priority: wish.priority,
      status: wish.status,
      target_date: wish.targetDate || '',
      estimated_cost: wish.estimatedCost || 0,
      actual_cost: wish.actualCost || 0,
      tags: JSON.stringify(wish.tags || []),
      images: JSON.stringify(wish.images || []),
      notes: wish.notes || '',
      progress: wish.progress || 0,
      related_contacts: JSON.stringify(wish.relatedContacts || []),
      inspiration_source: wish.inspirationSource || '',
      achieved_date: wish.achievedDate || '',
      achievement_notes: wish.achievementNotes || '',
      reminder_enabled: wish.reminderEnabled ? 1 : 0,
      reminder_date: wish.reminderDate || '',
      is_public: wish.isPublic ? 1 : 0,
      created_at: now,
      updated_at: now
    };

    await rdbStore.insert('my_wishes', valueBucket);
    return id;
  }

  // 获取所有心愿
  async getAllWishes(): Promise<MyWish[]> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const resultSet = await rdbStore.querySql(
      'SELECT * FROM my_wishes ORDER BY created_at DESC',
      []
    );

    const wishes: MyWish[] = [];
    while (resultSet.goToNextRow()) {
      wishes.push(this.mapRowToWish(resultSet));
    }
    resultSet.close();
    return wishes;
  }

  // 根据状态获取心愿
  async getWishesByStatus(status: WishStatus): Promise<MyWish[]> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const resultSet = await rdbStore.querySql(
      'SELECT * FROM my_wishes WHERE status = ? ORDER BY created_at DESC',
      [status]
    );

    const wishes: MyWish[] = [];
    while (resultSet.goToNextRow()) {
      wishes.push(this.mapRowToWish(resultSet));
    }
    resultSet.close();
    return wishes;
  }

  // 根据分类获取心愿
  async getWishesByCategory(category: WishCategory): Promise<MyWish[]> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const resultSet = await rdbStore.querySql(
      'SELECT * FROM my_wishes WHERE category = ? ORDER BY created_at DESC',
      [category]
    );

    const wishes: MyWish[] = [];
    while (resultSet.goToNextRow()) {
      wishes.push(this.mapRowToWish(resultSet));
    }
    resultSet.close();
    return wishes;
  }

  // 根据优先级获取心愿
  async getWishesByPriority(priority: WishPriority): Promise<MyWish[]> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const resultSet = await rdbStore.querySql(
      'SELECT * FROM my_wishes WHERE priority = ? ORDER BY created_at DESC',
      [priority]
    );

    const wishes: MyWish[] = [];
    while (resultSet.goToNextRow()) {
      wishes.push(this.mapRowToWish(resultSet));
    }
    resultSet.close();
    return wishes;
  }

  // 根据ID获取心愿
  async getWishById(id: string): Promise<MyWish | null> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const resultSet = await rdbStore.querySql(
      'SELECT * FROM my_wishes WHERE id = ?',
      [id]
    );

    let wish: MyWish | null = null;
    if (resultSet.goToFirstRow()) {
      wish = this.mapRowToWish(resultSet);
    }
    resultSet.close();
    return wish;
  }

  // 更新心愿
  async updateWish(id: string, wish: Partial<MyWish>): Promise<boolean> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const valueBucket: relationalStore.ValuesBucket = {
      updated_at: this.dbManager.getCurrentTimestamp()
    };

    if (wish.title !== undefined) valueBucket.title = wish.title;
    if (wish.description !== undefined) valueBucket.description = wish.description;
    if (wish.category !== undefined) valueBucket.category = wish.category;
    if (wish.priority !== undefined) valueBucket.priority = wish.priority;
    if (wish.status !== undefined) valueBucket.status = wish.status;
    if (wish.targetDate !== undefined) valueBucket.target_date = wish.targetDate;
    if (wish.estimatedCost !== undefined) valueBucket.estimated_cost = wish.estimatedCost;
    if (wish.actualCost !== undefined) valueBucket.actual_cost = wish.actualCost;
    if (wish.tags !== undefined) valueBucket.tags = JSON.stringify(wish.tags);
    if (wish.images !== undefined) valueBucket.images = JSON.stringify(wish.images);
    if (wish.notes !== undefined) valueBucket.notes = wish.notes;
    if (wish.progress !== undefined) valueBucket.progress = wish.progress;
    if (wish.relatedContacts !== undefined) valueBucket.related_contacts = JSON.stringify(wish.relatedContacts);
    if (wish.inspirationSource !== undefined) valueBucket.inspiration_source = wish.inspirationSource;
    if (wish.achievedDate !== undefined) valueBucket.achieved_date = wish.achievedDate;
    if (wish.achievementNotes !== undefined) valueBucket.achievement_notes = wish.achievementNotes;
    if (wish.reminderEnabled !== undefined) valueBucket.reminder_enabled = wish.reminderEnabled ? 1 : 0;
    if (wish.reminderDate !== undefined) valueBucket.reminder_date = wish.reminderDate;
    if (wish.isPublic !== undefined) valueBucket.is_public = wish.isPublic ? 1 : 0;

    const predicates = new relationalStore.RdbPredicates('my_wishes');
    predicates.equalTo('id', id);
    const result = await rdbStore.update(valueBucket, predicates);
    return result > 0;
  }

  // 删除心愿
  async deleteWish(id: string): Promise<boolean> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const predicates = new relationalStore.RdbPredicates('my_wishes');
    predicates.equalTo('id', id);

    const result = await rdbStore.delete(predicates);
    return result > 0;
  }

  // 搜索心愿
  async searchWishes(keyword: string): Promise<MyWish[]> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const resultSet = await rdbStore.querySql(
      `SELECT * FROM my_wishes 
       WHERE title LIKE ? OR 
             description LIKE ? OR 
             tags LIKE ? OR 
             notes LIKE ?
       ORDER BY created_at DESC`,
      [`%${keyword}%`, `%${keyword}%`, `%${keyword}%`, `%${keyword}%`]
    );

    const wishes: MyWish[] = [];
    while (resultSet.goToNextRow()) {
      wishes.push(this.mapRowToWish(resultSet));
    }
    resultSet.close();
    return wishes;
  }

  // 获取心愿统计
  async getWishStats(): Promise<WishStats> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    // 获取总数统计
    const totalResult = await rdbStore.querySql('SELECT COUNT(*) as total FROM my_wishes', []);
    totalResult.goToFirstRow();
    const totalWishes = totalResult.getLong(0);
    totalResult.close();

    // 获取活跃心愿数
    const activeResult = await rdbStore.querySql('SELECT COUNT(*) as active FROM my_wishes WHERE status = ?', [WishStatus.ACTIVE]);
    activeResult.goToFirstRow();
    const activeWishes = activeResult.getLong(0);
    activeResult.close();

    // 获取已实现心愿数
    const achievedResult = await rdbStore.querySql('SELECT COUNT(*) as achieved FROM my_wishes WHERE status = ?', [WishStatus.ACHIEVED]);
    achievedResult.goToFirstRow();
    const achievedWishes = achievedResult.getLong(0);
    achievedResult.close();

    // 获取费用统计
    const costResult = await rdbStore.querySql('SELECT SUM(estimated_cost) as estimated, SUM(actual_cost) as actual FROM my_wishes', []);
    costResult.goToFirstRow();
    const totalEstimatedCost = costResult.getDouble(0) || 0;
    const totalActualCost = costResult.getDouble(1) || 0;
    costResult.close();

    // 获取分类统计
    const categoryStats = new Map<string, number>();
    const categoryResult = await rdbStore.querySql('SELECT category, COUNT(*) as count FROM my_wishes GROUP BY category', []);
    while (categoryResult.goToNextRow()) {
      const category = categoryResult.getString(0);
      const count = categoryResult.getLong(1);
      categoryStats.set(category, count);
    }
    categoryResult.close();

    // 获取优先级统计
    const priorityStats = new Map<string, number>();
    const priorityResult = await rdbStore.querySql('SELECT priority, COUNT(*) as count FROM my_wishes GROUP BY priority', []);
    while (priorityResult.goToNextRow()) {
      const priority = priorityResult.getString(0);
      const count = priorityResult.getLong(1);
      priorityStats.set(priority, count);
    }
    priorityResult.close();

    // 计算平均实现时间（简化计算）
    let averageAchievementTime = 0;
    if (achievedWishes > 0) {
      const timeResult = await rdbStore.querySql(
        'SELECT AVG(julianday(achieved_date) - julianday(created_at)) as avg_time FROM my_wishes WHERE status = ? AND achieved_date IS NOT NULL AND achieved_date != ""',
        [WishStatus.ACHIEVED]
      );
      if (timeResult.goToFirstRow()) {
        averageAchievementTime = timeResult.getDouble(0) || 0;
      }
      timeResult.close();
    }

    return {
      totalWishes: totalWishes,
      activeWishes: activeWishes,
      achievedWishes: achievedWishes,
      totalEstimatedCost: totalEstimatedCost,
      totalActualCost: totalActualCost,
      averageAchievementTime: averageAchievementTime,
      categoryStats: categoryStats,
      priorityStats: priorityStats
    };
  }

  // 将数据库行映射为MyWish对象
  private mapRowToWish(resultSet: relationalStore.ResultSet): MyWish {
    return {
      id: resultSet.getString(resultSet.getColumnIndex('id')),
      title: resultSet.getString(resultSet.getColumnIndex('title')),
      description: resultSet.getString(resultSet.getColumnIndex('description')),
      category: resultSet.getString(resultSet.getColumnIndex('category')) as WishCategory,
      priority: resultSet.getString(resultSet.getColumnIndex('priority')) as WishPriority,
      status: resultSet.getString(resultSet.getColumnIndex('status')) as WishStatus,
      targetDate: resultSet.getString(resultSet.getColumnIndex('target_date')) || undefined,
      estimatedCost: resultSet.getDouble(resultSet.getColumnIndex('estimated_cost')) || undefined,
      actualCost: resultSet.getDouble(resultSet.getColumnIndex('actual_cost')) || undefined,
      tags: JSON.parse(resultSet.getString(resultSet.getColumnIndex('tags')) || '[]'),
      images: JSON.parse(resultSet.getString(resultSet.getColumnIndex('images')) || '[]'),
      notes: resultSet.getString(resultSet.getColumnIndex('notes')) || undefined,
      progress: resultSet.getLong(resultSet.getColumnIndex('progress')),
      relatedContacts: JSON.parse(resultSet.getString(resultSet.getColumnIndex('related_contacts')) || '[]'),
      inspirationSource: resultSet.getString(resultSet.getColumnIndex('inspiration_source')) || undefined,
      achievedDate: resultSet.getString(resultSet.getColumnIndex('achieved_date')) || undefined,
      achievementNotes: resultSet.getString(resultSet.getColumnIndex('achievement_notes')) || undefined,
      reminderEnabled: resultSet.getLong(resultSet.getColumnIndex('reminder_enabled')) === 1,
      reminderDate: resultSet.getString(resultSet.getColumnIndex('reminder_date')) || undefined,
      isPublic: resultSet.getLong(resultSet.getColumnIndex('is_public')) === 1,
      createdAt: resultSet.getString(resultSet.getColumnIndex('created_at')),
      updatedAt: resultSet.getString(resultSet.getColumnIndex('updated_at'))
    };
  }
}