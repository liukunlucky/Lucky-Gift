import { relationalStore } from '@kit.ArkData';
import { GiftEvent } from '../model/NewDataModels';
import { NewDatabaseManager } from './NewDatabaseManager';

interface BudgetRangeItem {
  range: string;
  count: number;
  totalCost: number;
}

interface BudgetAnalysis {
  totalBudget: number;
  totalActualCost: number;
  budgetVariance: number;
  eventsByBudgetRange: BudgetRangeItem[];
}

interface GiftEventStats {
  totalEvents: number;
  totalSpent: number;
  averageCost: number;
  mostFrequentOccasion: string;
  mostGiftedContact: string;
}

export class GiftEventDAO {
  private dbManager: NewDatabaseManager;

  constructor(dbManager: NewDatabaseManager) {
    this.dbManager = dbManager;
  }

  // 创建礼物事件
  async createGiftEvent(event: GiftEvent): Promise<string> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const id = this.dbManager.generateId();
    const now = this.dbManager.getCurrentTimestamp();

    const valueBucket: relationalStore.ValuesBucket = {
      id: id,
      contact_id: event.contactId,
      contact_name: event.contactName,
      occasion: event.occasion,
      date: event.date,
      gift_idea: event.giftIdea,
      actual_gift: event.actualGift || null,
      budget: event.budget,
      actual_cost: event.actualCost || null,
      images: JSON.stringify(event.images || []),
      story: event.story || null,
      reaction: event.reaction || null,
      mood: event.mood || null,
      tags: JSON.stringify(event.tags || []),
      reminder_set: event.reminderSet ? 1 : 0,
      reminder_date: event.reminderDate || null,
      created_at: now,
      updated_at: now
    };

    await rdbStore.insert('gift_events', valueBucket);
    return id;
  }

  // 获取所有礼物事件（时间轴）
  async getAllGiftEvents(): Promise<GiftEvent[]> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const resultSet = await rdbStore.querySql(
      'SELECT * FROM gift_events ORDER BY date DESC, created_at DESC'
    );

    const events: GiftEvent[] = [];
    while (resultSet.goToNextRow()) {
      events.push(this.parseGiftEventFromResultSet(resultSet));
    }
    resultSet.close();

    return events;
  }

  // 根据ID获取礼物事件
  async getGiftEventById(id: string): Promise<GiftEvent | null> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const resultSet = await rdbStore.querySql(
      'SELECT * FROM gift_events WHERE id = ?',
      [id]
    );

    let event: GiftEvent | null = null;
    if (resultSet.goToFirstRow()) {
      event = this.parseGiftEventFromResultSet(resultSet);
    }
    resultSet.close();

    return event;
  }

  // 根据联系人ID获取礼物事件
  async getGiftEventsByContactId(contactId: string): Promise<GiftEvent[]> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const resultSet = await rdbStore.querySql(
      'SELECT * FROM gift_events WHERE contact_id = ? ORDER BY date DESC',
      [contactId]
    );

    const events: GiftEvent[] = [];
    while (resultSet.goToNextRow()) {
      events.push(this.parseGiftEventFromResultSet(resultSet));
    }
    resultSet.close();

    return events;
  }

  // 根据场合获取礼物事件
  async getGiftEventsByOccasion(occasion: string): Promise<GiftEvent[]> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const resultSet = await rdbStore.querySql(
      'SELECT * FROM gift_events WHERE occasion = ? ORDER BY date DESC',
      [occasion]
    );

    const events: GiftEvent[] = [];
    while (resultSet.goToNextRow()) {
      events.push(this.parseGiftEventFromResultSet(resultSet));
    }
    resultSet.close();

    return events;
  }

  // 根据日期范围获取礼物事件
  async getGiftEventsByDateRange(startDate: string, endDate: string): Promise<GiftEvent[]> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const resultSet = await rdbStore.querySql(
      'SELECT * FROM gift_events WHERE date BETWEEN ? AND ? ORDER BY date DESC',
      [startDate, endDate]
    );

    const events: GiftEvent[] = [];
    while (resultSet.goToNextRow()) {
      events.push(this.parseGiftEventFromResultSet(resultSet));
    }
    resultSet.close();

    return events;
  }

  // 根据年份获取礼物事件
  async getGiftEventsByYear(year: number): Promise<GiftEvent[]> {
    const startDate = `${year}-01-01`;
    const endDate = `${year}-12-31`;
    return this.getGiftEventsByDateRange(startDate, endDate);
  }

  // 根据月份获取礼物事件
  async getGiftEventsByMonth(year: number, month: number): Promise<GiftEvent[]> {
    const monthStr = month.toString().padStart(2, '0');
    const startDate = `${year}-${monthStr}-01`;
    const endDate = `${year}-${monthStr}-31`;
    return this.getGiftEventsByDateRange(startDate, endDate);
  }

  // 搜索礼物事件
  async searchGiftEvents(keyword: string): Promise<GiftEvent[]> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const resultSet = await rdbStore.querySql(
      `SELECT * FROM gift_events 
       WHERE contact_name LIKE ? OR gift_idea LIKE ? OR actual_gift LIKE ? 
       OR story LIKE ? OR occasion LIKE ? 
       ORDER BY date DESC`,
      [`%${keyword}%`, `%${keyword}%`, `%${keyword}%`, `%${keyword}%`, `%${keyword}%`]
    );

    const events: GiftEvent[] = [];
    while (resultSet.goToNextRow()) {
      events.push(this.parseGiftEventFromResultSet(resultSet));
    }
    resultSet.close();

    return events;
  }

  // 根据标签搜索礼物事件
  async getGiftEventsByTag(tag: string): Promise<GiftEvent[]> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const resultSet = await rdbStore.querySql(
      'SELECT * FROM gift_events WHERE tags LIKE ? ORDER BY date DESC',
      [`%"${tag}"%`]
    );

    const events: GiftEvent[] = [];
    while (resultSet.goToNextRow()) {
      events.push(this.parseGiftEventFromResultSet(resultSet));
    }
    resultSet.close();

    return events;
  }

  // 更新礼物事件
  async updateGiftEvent(id: string, updates: GiftEvent): Promise<void> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const valueBucket: relationalStore.ValuesBucket = {
      updated_at: this.dbManager.getCurrentTimestamp()
    };

    if (updates.contactId !== undefined) valueBucket.contact_id = updates.contactId;
    if (updates.contactName !== undefined) valueBucket.contact_name = updates.contactName;
    if (updates.occasion !== undefined) valueBucket.occasion = updates.occasion;
    if (updates.date !== undefined) valueBucket.date = updates.date;
    if (updates.giftIdea !== undefined) valueBucket.gift_idea = updates.giftIdea;
    if (updates.actualGift !== undefined) valueBucket.actual_gift = updates.actualGift;
    if (updates.budget !== undefined) valueBucket.budget = updates.budget;
    if (updates.actualCost !== undefined) valueBucket.actual_cost = updates.actualCost;
    if (updates.images !== undefined) valueBucket.images = JSON.stringify(updates.images);
    if (updates.story !== undefined) valueBucket.story = updates.story;
    if (updates.reaction !== undefined) valueBucket.reaction = updates.reaction;
    if (updates.mood !== undefined) valueBucket.mood = updates.mood;
    if (updates.tags !== undefined) valueBucket.tags = JSON.stringify(updates.tags);
    if (updates.reminderSet !== undefined) valueBucket.reminder_set = updates.reminderSet ? 1 : 0;
    if (updates.reminderDate !== undefined) valueBucket.reminder_date = updates.reminderDate;

    const predicates = new relationalStore.RdbPredicates('gift_events');
    predicates.equalTo('id', id);

    await rdbStore.update(valueBucket, predicates);
  }

  // 删除礼物事件
  async deleteGiftEvent(id: string): Promise<void> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const predicates = new relationalStore.RdbPredicates('gift_events');
    predicates.equalTo('id', id);

    await rdbStore.delete(predicates);
  }

  // 获取统计数据
  async getGiftEventStats(): Promise<GiftEventStats> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    // 总事件数和总花费
    const statsResult = await rdbStore.querySql(
      'SELECT COUNT(*) as total_events, SUM(COALESCE(actual_cost, budget)) as total_spent FROM gift_events'
    );
    
    let totalEvents = 0;
    let totalSpent = 0;
    if (statsResult.goToFirstRow()) {
      totalEvents = statsResult.getLong(0);
      totalSpent = statsResult.getDouble(1);
    }
    statsResult.close();

    const averageCost = totalEvents > 0 ? totalSpent / totalEvents : 0;

    // 最频繁的场合
    const occasionResult = await rdbStore.querySql(
      'SELECT occasion, COUNT(*) as count FROM gift_events GROUP BY occasion ORDER BY count DESC LIMIT 1'
    );
    
    let mostFrequentOccasion = '';
    if (occasionResult.goToFirstRow()) {
      mostFrequentOccasion = occasionResult.getString(0);
    }
    occasionResult.close();

    // 最常送礼的联系人
    const contactResult = await rdbStore.querySql(
      'SELECT contact_name, COUNT(*) as count FROM gift_events GROUP BY contact_id ORDER BY count DESC LIMIT 1'
    );
    
    let mostGiftedContact = '';
    if (contactResult.goToFirstRow()) {
      mostGiftedContact = contactResult.getString(0);
    }
    contactResult.close();

    return {
      totalEvents,
      totalSpent,
      averageCost,
      mostFrequentOccasion,
      mostGiftedContact
    };
  }

  // 获取即将到来的提醒
  async getUpcomingReminders(days: number = 30): Promise<GiftEvent[]> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const today = new Date();
    const futureDate = new Date(today.getTime() + days * 24 * 60 * 60 * 1000);
    
    const resultSet = await rdbStore.querySql(
      `SELECT * FROM gift_events 
       WHERE reminder_set = 1 AND reminder_date BETWEEN ? AND ? 
       ORDER BY reminder_date`,
      [today.toISOString().split('T')[0], futureDate.toISOString().split('T')[0]]
    );

    const events: GiftEvent[] = [];
    while (resultSet.goToNextRow()) {
      events.push(this.parseGiftEventFromResultSet(resultSet));
    }
    resultSet.close();

    return events;
  }

  // 获取预算分析
  async getBudgetAnalysis(): Promise<BudgetAnalysis> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    // 总预算和实际花费
    const budgetResult = await rdbStore.querySql(
      'SELECT SUM(budget) as total_budget, SUM(COALESCE(actual_cost, budget)) as total_actual FROM gift_events'
    );
    
    let totalBudget = 0;
    let totalActualCost = 0;
    if (budgetResult.goToFirstRow()) {
      totalBudget = budgetResult.getDouble(0);
      totalActualCost = budgetResult.getDouble(1);
    }
    budgetResult.close();

    const budgetVariance = totalActualCost - totalBudget;

    // 按预算范围分组
    const rangeResult = await rdbStore.querySql(
      `SELECT 
         CASE 
           WHEN budget < 50 THEN '50元以下'
           WHEN budget < 200 THEN '50-200元'
           WHEN budget < 500 THEN '200-500元'
           ELSE '500元以上'
         END as range,
         COUNT(*) as count,
         SUM(COALESCE(actual_cost, budget)) as total_cost
       FROM gift_events 
       GROUP BY range
       ORDER BY MIN(budget)`
    );

    const eventsByBudgetRange: BudgetRangeItem[] = [];
    while (rangeResult.goToNextRow()) {
      const item: BudgetRangeItem = {
        range: rangeResult.getString(0),
        count: rangeResult.getLong(1),
        totalCost: rangeResult.getDouble(2)
      };
      eventsByBudgetRange.push(item);
    }
    rangeResult.close();

    const result: BudgetAnalysis = {
      totalBudget,
      totalActualCost,
      budgetVariance,
      eventsByBudgetRange
    };
    return result;
  }

  // 解析礼物事件数据
  private parseGiftEventFromResultSet(resultSet: relationalStore.ResultSet): GiftEvent {
    const imagesStr = resultSet.getString(resultSet.getColumnIndex('images'));
    const tagsStr = resultSet.getString(resultSet.getColumnIndex('tags'));
    
    return {
      id: resultSet.getString(resultSet.getColumnIndex('id')),
      contactId: resultSet.getString(resultSet.getColumnIndex('contact_id')),
      contactName: resultSet.getString(resultSet.getColumnIndex('contact_name')),
      occasion: resultSet.getString(resultSet.getColumnIndex('occasion')),
      date: resultSet.getString(resultSet.getColumnIndex('date')),
      giftIdea: resultSet.getString(resultSet.getColumnIndex('gift_idea')),
      actualGift: resultSet.getString(resultSet.getColumnIndex('actual_gift')) || undefined,
      budget: resultSet.getDouble(resultSet.getColumnIndex('budget')),
      actualCost: resultSet.getDouble(resultSet.getColumnIndex('actual_cost')) || undefined,
      images: imagesStr ? JSON.parse(imagesStr) : [],
      story: resultSet.getString(resultSet.getColumnIndex('story')) || undefined,
      reaction: resultSet.getString(resultSet.getColumnIndex('reaction')) || undefined,
      mood: resultSet.getString(resultSet.getColumnIndex('mood')) || undefined,
      tags: tagsStr ? JSON.parse(tagsStr) : [],
      reminderSet: resultSet.getLong(resultSet.getColumnIndex('reminder_set')) === 1,
      reminderDate: resultSet.getString(resultSet.getColumnIndex('reminder_date')) || undefined,
      createdAt: resultSet.getString(resultSet.getColumnIndex('created_at')),
      updatedAt: resultSet.getString(resultSet.getColumnIndex('updated_at'))
    };
  }
}