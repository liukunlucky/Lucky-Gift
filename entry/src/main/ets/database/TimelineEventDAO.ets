import { relationalStore } from '@kit.ArkData';
import { NewDatabaseManager } from './NewDatabaseManager';

// 关系事件类型
export enum EventType {
  MEET = 'meet',           // 初次相遇
  FRIEND = 'friend',       // 成为朋友
  CLOSE = 'close',         // 关系加深
  CONFLICT = 'conflict',   // 产生矛盾
  RECONCILE = 'reconcile', // 和解
  GIFT = 'gift',          // 送礼记录
  MILESTONE = 'milestone', // 重要里程碑
  MEMORY = 'memory'        // 美好回忆
}

// 情感强度
export enum EmotionLevel {
  VERY_LOW = 1,
  LOW = 2,
  MEDIUM = 3,
  HIGH = 4,
  VERY_HIGH = 5
}

// 时间轴事件
export interface TimelineEvent {
  id?: string;
  contactId: string;
  contactName: string;
  contactAvatar?: string;
  type: EventType;
  title: string;
  description: string;
  date: string;
  emotionLevel: EmotionLevel;
  tags: string[];
  photos?: string[];
  location?: string;
  weather?: string;
  mood: string; // 当时的心情
  isImportant: boolean;
  relatedGiftId?: string; // 关联的礼物记录
  createdAt?: string;
  updatedAt?: string;
}

// 关系统计
export interface RelationshipStats {
  contactId: string;
  contactName: string;
  totalEvents: number;
  averageEmotion: number;
  firstMeetDate: string;
  lastEventDate: string;
  relationshipDuration: number; // 天数
  importantEvents: number;
  conflictCount: number;
  giftCount: number;
}

export class TimelineEventDAO {
  private dbManager: NewDatabaseManager;

  constructor(dbManager: NewDatabaseManager) {
    this.dbManager = dbManager;
  }

  // 创建时间轴事件
  async createTimelineEvent(event: TimelineEvent): Promise<string> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const id = this.dbManager.generateId();
    const now = this.dbManager.getCurrentTimestamp();

    const valueBucket: relationalStore.ValuesBucket = {
      id: id,
      contact_id: event.contactId,
      contact_name: event.contactName,
      contact_avatar: event.contactAvatar || '',
      type: event.type,
      title: event.title,
      description: event.description,
      date: event.date,
      emotion_level: event.emotionLevel,
      tags: JSON.stringify(event.tags || []),
      photos: JSON.stringify(event.photos || []),
      location: event.location || '',
      weather: event.weather || '',
      mood: event.mood,
      is_important: event.isImportant ? 1 : 0,
      related_gift_id: event.relatedGiftId || '',
      created_at: now,
      updated_at: now
    };

    await rdbStore.insert('timeline_events', valueBucket);
    return id;
  }

  // 获取所有时间轴事件
  async getAllTimelineEvents(): Promise<TimelineEvent[]> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const resultSet = await rdbStore.querySql(
      'SELECT * FROM timeline_events ORDER BY date DESC',
      []
    );

    const events: TimelineEvent[] = [];
    while (resultSet.goToNextRow()) {
      events.push(this.mapRowToTimelineEvent(resultSet));
    }
    resultSet.close();
    return events;
  }

  // 根据联系人ID获取时间轴事件
  async getTimelineEventsByContactId(contactId: string): Promise<TimelineEvent[]> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const resultSet = await rdbStore.querySql(
      'SELECT * FROM timeline_events WHERE contact_id = ? ORDER BY date DESC',
      [contactId]
    );

    const events: TimelineEvent[] = [];
    while (resultSet.goToNextRow()) {
      events.push(this.mapRowToTimelineEvent(resultSet));
    }
    resultSet.close();
    return events;
  }

  // 根据ID获取时间轴事件
  async getTimelineEventById(id: string): Promise<TimelineEvent | null> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const resultSet = await rdbStore.querySql(
      'SELECT * FROM timeline_events WHERE id = ?',
      [id]
    );

    let event: TimelineEvent | null = null;
    if (resultSet.goToFirstRow()) {
      event = this.mapRowToTimelineEvent(resultSet);
    }
    resultSet.close();
    return event;
  }

  // 更新时间轴事件
  async updateTimelineEvent(id: string, event: Partial<TimelineEvent>): Promise<boolean> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const valueBucket: relationalStore.ValuesBucket = {
      updated_at: this.dbManager.getCurrentTimestamp()
    };

    if (event.contactId !== undefined) valueBucket.contact_id = event.contactId;
    if (event.contactName !== undefined) valueBucket.contact_name = event.contactName;
    if (event.contactAvatar !== undefined) valueBucket.contact_avatar = event.contactAvatar;
    if (event.type !== undefined) valueBucket.type = event.type;
    if (event.title !== undefined) valueBucket.title = event.title;
    if (event.description !== undefined) valueBucket.description = event.description;
    if (event.date !== undefined) valueBucket.date = event.date;
    if (event.emotionLevel !== undefined) valueBucket.emotion_level = event.emotionLevel;
    if (event.tags !== undefined) valueBucket.tags = JSON.stringify(event.tags);
    if (event.photos !== undefined) valueBucket.photos = JSON.stringify(event.photos);
    if (event.location !== undefined) valueBucket.location = event.location;
    if (event.weather !== undefined) valueBucket.weather = event.weather;
    if (event.mood !== undefined) valueBucket.mood = event.mood;
    if (event.isImportant !== undefined) valueBucket.is_important = event.isImportant ? 1 : 0;
    if (event.relatedGiftId !== undefined) valueBucket.related_gift_id = event.relatedGiftId;

    const predicates = new relationalStore.RdbPredicates('timeline_events');
    predicates.equalTo('id', id);

    const result = await rdbStore.update(valueBucket, predicates);
    return result > 0;
  }

  // 删除时间轴事件
  async deleteTimelineEvent(id: string): Promise<boolean> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const predicates = new relationalStore.RdbPredicates('timeline_events');
    predicates.equalTo('id', id);

    const result = await rdbStore.delete(predicates);
    return result > 0;
  }

  // 根据事件类型获取事件
  async getTimelineEventsByType(contactId: string, type: EventType): Promise<TimelineEvent[]> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const resultSet = await rdbStore.querySql(
      'SELECT * FROM timeline_events WHERE contact_id = ? AND type = ? ORDER BY date DESC',
      [contactId, type]
    );

    const events: TimelineEvent[] = [];
    while (resultSet.goToNextRow()) {
      events.push(this.mapRowToTimelineEvent(resultSet));
    }
    resultSet.close();
    return events;
  }

  // 搜索时间轴事件
  async searchTimelineEvents(contactId: string, keyword: string): Promise<TimelineEvent[]> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const resultSet = await rdbStore.querySql(
      `SELECT * FROM timeline_events 
       WHERE contact_id = ? AND (
         title LIKE ? OR 
         description LIKE ? OR 
         tags LIKE ? OR 
         location LIKE ? OR 
         mood LIKE ?
       ) ORDER BY date DESC`,
      [contactId, `%${keyword}%`, `%${keyword}%`, `%${keyword}%`, `%${keyword}%`, `%${keyword}%`]
    );

    const events: TimelineEvent[] = [];
    while (resultSet.goToNextRow()) {
      events.push(this.mapRowToTimelineEvent(resultSet));
    }
    resultSet.close();
    return events;
  }

  // 获取关系统计
  async getRelationshipStats(contactId: string): Promise<RelationshipStats | null> {
    const events = await this.getTimelineEventsByContactId(contactId);
    if (events.length === 0) return null;

    const totalEmotion = events.reduce((sum, event) => sum + event.emotionLevel, 0);
    const averageEmotion = totalEmotion / events.length;

    const sortedEvents = events.sort((a, b) => new Date(a.date).getTime() - new Date(b.date).getTime());
    const firstEvent = sortedEvents[0];
    const lastEvent = sortedEvents[sortedEvents.length - 1];

    const firstDate = new Date(firstEvent.date);
    const lastDate = new Date(lastEvent.date);
    const duration = Math.ceil((lastDate.getTime() - firstDate.getTime()) / (1000 * 60 * 60 * 24));

    return {
      contactId: contactId,
      contactName: events[0].contactName,
      totalEvents: events.length,
      averageEmotion: averageEmotion,
      firstMeetDate: firstEvent.date,
      lastEventDate: lastEvent.date,
      relationshipDuration: duration,
      importantEvents: events.filter(e => e.isImportant).length,
      conflictCount: events.filter(e => e.type === EventType.CONFLICT).length,
      giftCount: events.filter(e => e.type === EventType.GIFT).length
    };
  }

  // 获取重要事件
  async getImportantEvents(contactId: string): Promise<TimelineEvent[]> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const resultSet = await rdbStore.querySql(
      'SELECT * FROM timeline_events WHERE contact_id = ? AND is_important = 1 ORDER BY date DESC',
      [contactId]
    );

    const events: TimelineEvent[] = [];
    while (resultSet.goToNextRow()) {
      events.push(this.mapRowToTimelineEvent(resultSet));
    }
    resultSet.close();
    return events;
  }

  // 获取最近的事件
  async getRecentEvents(contactId: string, limit: number = 10): Promise<TimelineEvent[]> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const resultSet = await rdbStore.querySql(
      'SELECT * FROM timeline_events WHERE contact_id = ? ORDER BY date DESC LIMIT ?',
      [contactId, limit]
    );

    const events: TimelineEvent[] = [];
    while (resultSet.goToNextRow()) {
      events.push(this.mapRowToTimelineEvent(resultSet));
    }
    resultSet.close();
    return events;
  }

  // 批量删除联系人的所有事件
  async deleteEventsByContactId(contactId: string): Promise<boolean> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const predicates = new relationalStore.RdbPredicates('timeline_events');
    predicates.equalTo('contact_id', contactId);

    const result = await rdbStore.delete(predicates);
    return result >= 0;
  }

  // 将数据库行映射为TimelineEvent对象
  private mapRowToTimelineEvent(resultSet: relationalStore.ResultSet): TimelineEvent {
    return {
      id: resultSet.getString(resultSet.getColumnIndex('id')),
      contactId: resultSet.getString(resultSet.getColumnIndex('contact_id')),
      contactName: resultSet.getString(resultSet.getColumnIndex('contact_name')),
      contactAvatar: resultSet.getString(resultSet.getColumnIndex('contact_avatar')) || undefined,
      type: resultSet.getString(resultSet.getColumnIndex('type')) as EventType,
      title: resultSet.getString(resultSet.getColumnIndex('title')),
      description: resultSet.getString(resultSet.getColumnIndex('description')),
      date: resultSet.getString(resultSet.getColumnIndex('date')),
      emotionLevel: resultSet.getLong(resultSet.getColumnIndex('emotion_level')) as EmotionLevel,
      tags: JSON.parse(resultSet.getString(resultSet.getColumnIndex('tags')) || '[]'),
      photos: JSON.parse(resultSet.getString(resultSet.getColumnIndex('photos')) || '[]'),
      location: resultSet.getString(resultSet.getColumnIndex('location')) || undefined,
      weather: resultSet.getString(resultSet.getColumnIndex('weather')) || undefined,
      mood: resultSet.getString(resultSet.getColumnIndex('mood')),
      isImportant: resultSet.getLong(resultSet.getColumnIndex('is_important')) === 1,
      relatedGiftId: resultSet.getString(resultSet.getColumnIndex('related_gift_id')) || undefined,
      createdAt: resultSet.getString(resultSet.getColumnIndex('created_at')),
      updatedAt: resultSet.getString(resultSet.getColumnIndex('updated_at'))
    };
  }
}