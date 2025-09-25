import relationalStore from '@ohos.data.relationalStore';
import { GiftStory } from '../model/NewDataModels';

interface GiftStoryStats {
  total: number;
  thisMonth: number;
}

export class GiftStoryDAO {
  private rdbStore: relationalStore.RdbStore;

  constructor(rdbStore: relationalStore.RdbStore) {
    this.rdbStore = rdbStore;
  }

  // 创建礼物故事
  async createGiftStory(story: GiftStory): Promise<string> {
    const id = 'story_' + Date.now().toString();
    const now = new Date().toISOString();

    const valueBucket: relationalStore.ValuesBucket = {
      id: id,
      gift_event_id: story.giftEventId,
      gift_event_title: story.giftEventTitle,
      contact_name: story.contactName,
      title: story.title,
      content: story.content,
      images: JSON.stringify(story.images),
      emotion: story.emotion,
      reason: story.reason,
      scene: story.scene,
      tags: JSON.stringify(story.tags),
      created_at: now,
      updated_at: now
    };

    await this.rdbStore.insert('gift_stories', valueBucket);
    return id;
  }

  // 获取所有礼物故事
  async getAllGiftStories(): Promise<GiftStory[]> {
    const result = await this.rdbStore.querySql(
      'SELECT * FROM gift_stories ORDER BY created_at DESC'
    );

    const stories: GiftStory[] = [];
    if (result.rowCount > 0) {
      for (let i = 0; i < result.rowCount; i++) {
        result.goToRow(i);
        const story = this.mapRowToGiftStory(result);
        stories.push(story);
      }
    }
    result.close();
    return stories;
  }

  // 根据ID获取礼物故事
  async getGiftStoryById(id: string): Promise<GiftStory | null> {
    const result = await this.rdbStore.querySql(
      'SELECT * FROM gift_stories WHERE id = ?',
      [id]
    );

    let story: GiftStory | null = null;
    if (result.rowCount > 0) {
      result.goToFirstRow();
      story = this.mapRowToGiftStory(result);
    }
    result.close();
    return story;
  }

  // 根据礼物事件ID获取故事
  async getGiftStoriesByEventId(eventId: string): Promise<GiftStory[]> {
    const result = await this.rdbStore.querySql(
      'SELECT * FROM gift_stories WHERE gift_event_id = ? ORDER BY created_at DESC',
      [eventId]
    );

    const stories: GiftStory[] = [];
    if (result.rowCount > 0) {
      for (let i = 0; i < result.rowCount; i++) {
        result.goToRow(i);
        const story = this.mapRowToGiftStory(result);
        stories.push(story);
      }
    }
    result.close();
    return stories;
  }

  // 更新礼物故事
  async updateGiftStory(id: string, story: Partial<GiftStory>): Promise<void> {
    const now = new Date().toISOString();
    const valueBucket: relationalStore.ValuesBucket = {
      updated_at: now
    };

    if (story.title !== undefined) valueBucket.title = story.title;
    if (story.content !== undefined) valueBucket.content = story.content;
    if (story.images !== undefined) valueBucket.images = JSON.stringify(story.images);
    if (story.emotion !== undefined) valueBucket.emotion = story.emotion;
    if (story.reason !== undefined) valueBucket.reason = story.reason;
    if (story.scene !== undefined) valueBucket.scene = story.scene;
    if (story.tags !== undefined) valueBucket.tags = JSON.stringify(story.tags);

    const predicates = new relationalStore.RdbPredicates('gift_stories');
    predicates.equalTo('id', id);
    
    await this.rdbStore.update(valueBucket, predicates);
  }

  // 删除礼物故事
  async deleteGiftStory(id: string): Promise<void> {
    const predicates = new relationalStore.RdbPredicates('gift_stories');
    predicates.equalTo('id', id);
    
    await this.rdbStore.delete(predicates);
  }

  // 搜索礼物故事
  async searchGiftStories(keyword: string): Promise<GiftStory[]> {
    const result = await this.rdbStore.querySql(
      `SELECT * FROM gift_stories 
       WHERE title LIKE ? OR content LIKE ? OR contact_name LIKE ?
       ORDER BY created_at DESC`,
      [`%${keyword}%`, `%${keyword}%`, `%${keyword}%`]
    );

    const stories: GiftStory[] = [];
    if (result.rowCount > 0) {
      for (let i = 0; i < result.rowCount; i++) {
        result.goToRow(i);
        const story = this.mapRowToGiftStory(result);
        stories.push(story);
      }
    }
    result.close();
    return stories;
  }

  // 获取故事统计信息
  async getGiftStoryStats(): Promise<GiftStoryStats> {
    // 总数
    const totalResult = await this.rdbStore.querySql(
      'SELECT COUNT(*) as count FROM gift_stories'
    );
    let total = 0;
    if (totalResult.rowCount > 0) {
      totalResult.goToFirstRow();
      total = totalResult.getLong(0);
    }
    totalResult.close();

    // 本月数量
    const thisMonth = new Date().toISOString().substring(0, 7); // YYYY-MM
    const monthResult = await this.rdbStore.querySql(
      'SELECT COUNT(*) as count FROM gift_stories WHERE created_at LIKE ?',
      [`${thisMonth}%`]
    );
    let thisMonthCount = 0;
    if (monthResult.rowCount > 0) {
      monthResult.goToFirstRow();
      thisMonthCount = monthResult.getLong(0);
    }
    monthResult.close();

    const stats: GiftStoryStats = {
      total: total,
      thisMonth: thisMonthCount
    };
    return stats;
  }

  // 将数据库行映射为GiftStory对象
  private mapRowToGiftStory(result: relationalStore.ResultSet): GiftStory {
    const story: GiftStory = {
      id: result.getString(result.getColumnIndex('id')),
      giftEventId: result.getString(result.getColumnIndex('gift_event_id')),
      giftEventTitle: result.getString(result.getColumnIndex('gift_event_title')),
      contactName: result.getString(result.getColumnIndex('contact_name')),
      title: result.getString(result.getColumnIndex('title')),
      content: result.getString(result.getColumnIndex('content')),
      images: JSON.parse(result.getString(result.getColumnIndex('images')) || '[]'),
      emotion: result.getString(result.getColumnIndex('emotion')),
      reason: result.getString(result.getColumnIndex('reason')),
      scene: result.getString(result.getColumnIndex('scene')),
      tags: JSON.parse(result.getString(result.getColumnIndex('tags')) || '[]'),
      createdAt: result.getString(result.getColumnIndex('created_at')),
      updatedAt: result.getString(result.getColumnIndex('updated_at'))
    };

    return story;
  }
}