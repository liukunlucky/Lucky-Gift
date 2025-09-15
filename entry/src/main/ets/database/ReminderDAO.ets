import { relationalStore } from '@kit.ArkData';
import { Reminder } from '../model/NewDataModels';
import { NewDatabaseManager } from './NewDatabaseManager';

export class ReminderDAO {
  private dbManager: NewDatabaseManager;

  constructor(dbManager: NewDatabaseManager) {
    this.dbManager = dbManager;
  }

  // 创建提醒
  async createReminder(reminder: Reminder): Promise<string> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const id = this.dbManager.generateId();
    const now = this.dbManager.getCurrentTimestamp();

    const valueBucket: relationalStore.ValuesBucket = {
      id: id,
      type: reminder.type,
      related_id: reminder.relatedId,
      title: reminder.title,
      message: reminder.message,
      reminder_date: reminder.reminderDate,
      is_active: reminder.isActive ? 1 : 0,
      is_triggered: reminder.isTriggered ? 1 : 0,
      created_at: now
    };

    await rdbStore.insert('reminders', valueBucket);
    return id;
  }

  // 获取所有活跃的提醒
  async getAllReminders(): Promise<Reminder[]> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const resultSet = await rdbStore.querySql(
      'SELECT * FROM reminders WHERE is_active = 1 ORDER BY reminder_date ASC'
    );

    const reminders: Reminder[] = [];
    while (resultSet.goToNextRow()) {
      reminders.push(this.parseReminderFromResultSet(resultSet));
    }
    resultSet.close();

    return reminders;
  }

  // 根据类型获取提醒
  async getRemindersByType(type: string): Promise<Reminder[]> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const resultSet = await rdbStore.querySql(
      'SELECT * FROM reminders WHERE type = ? AND is_active = 1 ORDER BY reminder_date ASC',
      [type]
    );

    const reminders: Reminder[] = [];
    while (resultSet.goToNextRow()) {
      reminders.push(this.parseReminderFromResultSet(resultSet));
    }
    resultSet.close();

    return reminders;
  }

  // 根据关联ID获取提醒
  async getRemindersByRelatedId(relatedId: string): Promise<Reminder[]> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const resultSet = await rdbStore.querySql(
      'SELECT * FROM reminders WHERE related_id = ? ORDER BY reminder_date ASC',
      [relatedId]
    );

    const reminders: Reminder[] = [];
    while (resultSet.goToNextRow()) {
      reminders.push(this.parseReminderFromResultSet(resultSet));
    }
    resultSet.close();

    return reminders;
  }

  // 更新提醒状态
  async updateReminderStatus(id: string, isActive: boolean): Promise<void> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const valueBucket: relationalStore.ValuesBucket = {
      is_active: isActive ? 1 : 0
    };

    const predicates = new relationalStore.RdbPredicates('reminders');
    predicates.equalTo('id', id);

    await rdbStore.update(valueBucket, predicates);
  }

  // 标记提醒为已触发
  async markReminderTriggered(id: string): Promise<void> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const valueBucket: relationalStore.ValuesBucket = {
      is_triggered: 1
    };

    const predicates = new relationalStore.RdbPredicates('reminders');
    predicates.equalTo('id', id);

    await rdbStore.update(valueBucket, predicates);
  }

  // 更新提醒
  async updateReminder(reminder: Reminder): Promise<void> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const valueBucket: relationalStore.ValuesBucket = {
      type: reminder.type,
      related_id: reminder.relatedId,
      title: reminder.title,
      message: reminder.message || reminder.content || '',
      reminder_date: reminder.reminderDate || reminder.dateTime || '',
      is_active: (reminder.isActive !== undefined ? reminder.isActive : reminder.isEnabled) ? 1 : 0,
      is_triggered: reminder.isTriggered ? 1 : 0
    };

    const predicates = new relationalStore.RdbPredicates('reminders');
    predicates.equalTo('id', reminder.id);

    await rdbStore.update(valueBucket, predicates);
  }

  // 删除提醒
  async deleteReminder(id: string): Promise<void> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const predicates = new relationalStore.RdbPredicates('reminders');
    predicates.equalTo('id', id);

    await rdbStore.delete(predicates);
  }

  // 获取即将到来的提醒（未来N天内）
  async getUpcomingReminders(days: number = 30): Promise<Reminder[]> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const now = new Date();
    const futureDate = new Date(now.getTime() + days * 24 * 60 * 60 * 1000);
    
    const resultSet = await rdbStore.querySql(
      'SELECT * FROM reminders WHERE is_active = 1 AND reminder_date BETWEEN ? AND ? ORDER BY reminder_date ASC',
      [now.toISOString(), futureDate.toISOString()]
    );

    const reminders: Reminder[] = [];
    while (resultSet.goToNextRow()) {
      reminders.push(this.parseReminderFromResultSet(resultSet));
    }
    resultSet.close();

    return reminders;
  }

  // 从ResultSet解析提醒对象
  private parseReminderFromResultSet(resultSet: relationalStore.ResultSet): Reminder {
    return {
      id: resultSet.getString(resultSet.getColumnIndex('id')),
      type: resultSet.getString(resultSet.getColumnIndex('type')) as 'gift_event' | 'important_date' | 'holiday',
      relatedId: resultSet.getString(resultSet.getColumnIndex('related_id')),
      title: resultSet.getString(resultSet.getColumnIndex('title')),
      message: resultSet.getString(resultSet.getColumnIndex('message')),
      reminderDate: resultSet.getString(resultSet.getColumnIndex('reminder_date')),
      isActive: resultSet.getLong(resultSet.getColumnIndex('is_active')) === 1,
      isTriggered: resultSet.getLong(resultSet.getColumnIndex('is_triggered')) === 1,
      createdAt: resultSet.getString(resultSet.getColumnIndex('created_at'))
    };
  }
}