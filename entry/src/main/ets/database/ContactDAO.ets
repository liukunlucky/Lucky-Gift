import relationalStore from '@ohos.data.relationalStore';
import { TargetGroup } from '../model/GiftModel';
import { Contact, ImportantDate, ContactPreference } from '../model/NewDataModels';
import { NewDatabaseManager } from './NewDatabaseManager';

export class ContactDAO {
  private dbManager: NewDatabaseManager;

  constructor(dbManager: NewDatabaseManager) {
    this.dbManager = dbManager;
  }

  // 创建联系人
  async createContact(contact: Contact): Promise<string> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const id = this.dbManager.generateId();
    const now = this.dbManager.getCurrentTimestamp();

    const valueBucket: relationalStore.ValuesBucket = {
      id: id,
      name: contact.name,
      relationship: contact.relationship,
      avatar: contact.avatar || null,
      birthday: contact.birthday || null,
      notes: contact.notes || null,
      created_at: now,
      updated_at: now
    };

    await rdbStore.insert('contacts', valueBucket);

    // 插入重要日期
    if (contact.importantDates && contact.importantDates.length > 0) {
      for (const date of contact.importantDates) {
        await this.addImportantDate(id, date);
      }
    }

    // 插入偏好
    if (contact.preferences && contact.preferences.length > 0) {
      for (const preference of contact.preferences) {
        await this.addContactPreference(id, preference);
      }
    }

    return id;
  }

  // 获取所有联系人
  async getAllContacts(): Promise<Contact[]> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const resultSet = await rdbStore.querySql(
      'SELECT * FROM contacts ORDER BY updated_at DESC'
    );

    const contacts: Contact[] = [];
    while (resultSet.goToNextRow()) {
      const contact = this.parseContactFromResultSet(resultSet);
      
      // 获取重要日期
      contact.importantDates = await this.getImportantDatesByContactId(contact.id);
      
      // 获取偏好
      contact.preferences = await this.getContactPreferencesByContactId(contact.id);
      
      contacts.push(contact);
    }
    resultSet.close();

    return contacts;
  }

  // 根据ID获取联系人
  async getContactById(id: string): Promise<Contact | null> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const resultSet = await rdbStore.querySql(
      'SELECT * FROM contacts WHERE id = ?',
      [id]
    );

    let contact: Contact | null = null;
    if (resultSet.goToFirstRow()) {
      contact = this.parseContactFromResultSet(resultSet);
      
      // 获取重要日期
      contact.importantDates = await this.getImportantDatesByContactId(contact.id);
      
      // 获取偏好
      contact.preferences = await this.getContactPreferencesByContactId(contact.id);
    }
    resultSet.close();

    return contact;
  }

  // 搜索联系人
  async searchContacts(keyword: string): Promise<Contact[]> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const resultSet = await rdbStore.querySql(
      'SELECT * FROM contacts WHERE name LIKE ? OR relationship LIKE ? OR notes LIKE ? ORDER BY name',
      [`%${keyword}%`, `%${keyword}%`, `%${keyword}%`]
    );

    const contacts: Contact[] = [];
    while (resultSet.goToNextRow()) {
      const contact = this.parseContactFromResultSet(resultSet);
      contact.importantDates = await this.getImportantDatesByContactId(contact.id);
      contact.preferences = await this.getContactPreferencesByContactId(contact.id);
      contacts.push(contact);
    }
    resultSet.close();

    return contacts;
  }

  // 根据关系类型获取联系人
  async getContactsByRelationship(relationship: string): Promise<Contact[]> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const resultSet = await rdbStore.querySql(
      'SELECT * FROM contacts WHERE relationship = ? ORDER BY name',
      [relationship]
    );

    const contacts: Contact[] = [];
    while (resultSet.goToNextRow()) {
      const contact = this.parseContactFromResultSet(resultSet);
      contact.importantDates = await this.getImportantDatesByContactId(contact.id);
      contact.preferences = await this.getContactPreferencesByContactId(contact.id);
      contacts.push(contact);
    }
    resultSet.close();

    return contacts;
  }

  // 更新联系人
  async updateContact(contact: Contact): Promise<void> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const now = this.dbManager.getCurrentTimestamp();
    const valueBucket: relationalStore.ValuesBucket = {
      name: contact.name,
      relationship: contact.relationship,
      avatar: contact.avatar || null,
      birthday: contact.birthday || null,
      notes: contact.notes || null,
      updated_at: now
    };

    const predicates = new relationalStore.RdbPredicates('contacts');
    predicates.equalTo('id', contact.id);
    await rdbStore.update(valueBucket, predicates);

    // 删除现有的重要日期和偏好，然后重新插入
    await this.deleteImportantDatesByContactId(contact.id);
    await this.deleteContactPreferencesByContactId(contact.id);

    // 重新插入重要日期
    if (contact.importantDates && contact.importantDates.length > 0) {
      for (const date of contact.importantDates) {
        await this.addImportantDate(contact.id, date);
      }
    }

    // 重新插入偏好
    if (contact.preferences && contact.preferences.length > 0) {
      for (const preference of contact.preferences) {
        await this.addContactPreference(contact.id, preference);
      }
    }
  }

  // 删除联系人
  async deleteContact(contactId: string): Promise<void> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    // 删除相关的重要日期
    await this.deleteImportantDatesByContactId(contactId);
    
    // 删除相关的偏好
    await this.deleteContactPreferencesByContactId(contactId);
    
    // 删除联系人
    const predicates = new relationalStore.RdbPredicates('contacts');
    predicates.equalTo('id', contactId);
    await rdbStore.delete(predicates);
  }

  // 删除联系人的所有重要日期
  private async deleteImportantDatesByContactId(contactId: string): Promise<void> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const predicates = new relationalStore.RdbPredicates('important_dates');
    predicates.equalTo('contact_id', contactId);
    await rdbStore.delete(predicates);
  }

  // 删除联系人的所有偏好
  private async deleteContactPreferencesByContactId(contactId: string): Promise<void> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const predicates = new relationalStore.RdbPredicates('contact_preferences');
    predicates.equalTo('contact_id', contactId);
    await rdbStore.delete(predicates);
  }

  // 添加重要日期
  async addImportantDate(contactId: string, date: ImportantDate): Promise<string> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const id = this.dbManager.generateId();
    const valueBucket: relationalStore.ValuesBucket = {
      id: id,
      contact_id: contactId,
      name: date.name,
      date: date.date,
      is_recurring: date.isRecurring ? 1 : 0,
      reminder_enabled: date.reminderEnabled ? 1 : 0,
      reminder_days: date.reminderDays
    };

    await rdbStore.insert('important_dates', valueBucket);
    return id;
  }

  // 获取联系人的重要日期
  async getImportantDatesByContactId(contactId: string): Promise<ImportantDate[]> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const resultSet = await rdbStore.querySql(
      'SELECT * FROM important_dates WHERE contact_id = ? ORDER BY date',
      [contactId]
    );

    const dates: ImportantDate[] = [];
    while (resultSet.goToNextRow()) {
      dates.push({
        id: resultSet.getString(resultSet.getColumnIndex('id')),
        contactId: resultSet.getString(resultSet.getColumnIndex('contact_id')),
        name: resultSet.getString(resultSet.getColumnIndex('name')),
        date: resultSet.getString(resultSet.getColumnIndex('date')),
        isRecurring: resultSet.getLong(resultSet.getColumnIndex('is_recurring')) === 1,
        reminderEnabled: resultSet.getLong(resultSet.getColumnIndex('reminder_enabled')) === 1,
        reminderDays: resultSet.getLong(resultSet.getColumnIndex('reminder_days'))
      });
    }
    resultSet.close();

    return dates;
  }

  // 添加联系人偏好
  async addContactPreference(contactId: string, preference: ContactPreference): Promise<string> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const id = this.dbManager.generateId();
    const valueBucket: relationalStore.ValuesBucket = {
      id: id,
      contact_id: contactId,
      category: preference.category,
      content: preference.content,
      priority: preference.priority
    };

    await rdbStore.insert('contact_preferences', valueBucket);
    return id;
  }

  // 更新重要日期
  async updateImportantDate(date: ImportantDate): Promise<void> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const valueBucket: relationalStore.ValuesBucket = {
      name: date.name,
      date: date.date,
      is_recurring: date.isRecurring ? 1 : 0,
      reminder_enabled: date.reminderEnabled ? 1 : 0,
      reminder_days: date.reminderDays
    };

    const predicates = new relationalStore.RdbPredicates('important_dates');
    predicates.equalTo('id', date.id);
    await rdbStore.update(valueBucket, predicates);
  }

  // 删除重要日期
  async deleteImportantDate(dateId: string): Promise<void> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const predicates = new relationalStore.RdbPredicates('important_dates');
    predicates.equalTo('id', dateId);
    await rdbStore.delete(predicates);
  }

  // 获取联系人偏好
  async getContactPreferencesByContactId(contactId: string): Promise<ContactPreference[]> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const resultSet = await rdbStore.querySql(
      'SELECT * FROM contact_preferences WHERE contact_id = ? ORDER BY priority DESC, category',
      [contactId]
    );

    const preferences: ContactPreference[] = [];
    while (resultSet.goToNextRow()) {
      preferences.push({
        id: resultSet.getString(resultSet.getColumnIndex('id')),
        contactId: resultSet.getString(resultSet.getColumnIndex('contact_id')),
        category: resultSet.getString(resultSet.getColumnIndex('category')),
        content: resultSet.getString(resultSet.getColumnIndex('content')),
        priority: resultSet.getString(resultSet.getColumnIndex('priority')) as 'high' | 'medium' | 'low'
      });
    }
    resultSet.close();

    return preferences;
  }

  // 更新联系人偏好
  async updateContactPreference(preference: ContactPreference): Promise<void> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const valueBucket: relationalStore.ValuesBucket = {
      category: preference.category,
      content: preference.content,
      priority: preference.priority
    };

    const predicates = new relationalStore.RdbPredicates('contact_preferences');
    predicates.equalTo('id', preference.id);
    await rdbStore.update(valueBucket, predicates);
  }

  // 删除联系人偏好
  async deleteContactPreference(preferenceId: string): Promise<void> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const predicates = new relationalStore.RdbPredicates('contact_preferences');
    predicates.equalTo('id', preferenceId);
    await rdbStore.delete(predicates);
  }

  // 获取即将到来的重要日期
  async getUpcomingImportantDates(days: number = 30): Promise<ImportantDate[]> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const today = new Date();
    const futureDate = new Date(today.getTime() + days * 24 * 60 * 60 * 1000);
    
    const resultSet = await rdbStore.querySql(
      `SELECT id.*, c.name as contact_name FROM important_dates id 
       JOIN contacts c ON id.contact_id = c.id 
       WHERE id.reminder_enabled = 1 AND id.date BETWEEN ? AND ? 
       ORDER BY id.date`,
      [today.toISOString().split('T')[0], futureDate.toISOString().split('T')[0]]
    );

    const dates: ImportantDate[] = [];
    while (resultSet.goToNextRow()) {
      dates.push({
        id: resultSet.getString(resultSet.getColumnIndex('id')),
        contactId: resultSet.getString(resultSet.getColumnIndex('contact_id')),
        name: resultSet.getString(resultSet.getColumnIndex('name')),
        date: resultSet.getString(resultSet.getColumnIndex('date')),
        isRecurring: resultSet.getLong(resultSet.getColumnIndex('is_recurring')) === 1,
        reminderEnabled: resultSet.getLong(resultSet.getColumnIndex('reminder_enabled')) === 1,
        reminderDays: resultSet.getLong(resultSet.getColumnIndex('reminder_days'))
      });
    }
    resultSet.close();

    return dates;
  }

  // 解析联系人数据
  private parseContactFromResultSet(resultSet: relationalStore.ResultSet): Contact {
    return {
      id: resultSet.getString(resultSet.getColumnIndex('id')),
      name: resultSet.getString(resultSet.getColumnIndex('name')),
      relationship: resultSet.getString(resultSet.getColumnIndex('relationship')),
      avatar: resultSet.getString(resultSet.getColumnIndex('avatar')) || undefined,
      birthday: resultSet.getString(resultSet.getColumnIndex('birthday')) || undefined,
      notes: resultSet.getString(resultSet.getColumnIndex('notes')) || undefined,
      createdAt: resultSet.getString(resultSet.getColumnIndex('created_at')),
      updatedAt: resultSet.getString(resultSet.getColumnIndex('updated_at')),
      importantDates: [], // 将在调用方法中填充
      preferences: [] // 将在调用方法中填充
    };
  }
}