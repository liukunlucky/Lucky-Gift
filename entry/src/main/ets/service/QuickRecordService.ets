import { NewDatabaseManager } from '../database/NewDatabaseManager';
import relationalStore from '@ohos.data.relationalStore';

// 备忘接口
export interface QuickRecord {
  id: string;
  type: string;
  title: string;
  content: string;
  date: string;
  tags: string[];
}

// 备忘服务
export class QuickRecordService {
  private dbManager: NewDatabaseManager;

  constructor(dbManager?: NewDatabaseManager) {
    this.dbManager = dbManager || new NewDatabaseManager();
  }

  // 获取所有备忘
  public async getAllRecords(): Promise<QuickRecord[]> {
    const store = this.dbManager.getRdbStore();
    if (!store) {
      throw new Error('数据库未初始化');
    }

    try {
      const predicates = new relationalStore.RdbPredicates('quick_records');
      predicates.orderByDesc('date');
      
      const resultSet = await store.query(predicates);
      const records: QuickRecord[] = [];
      
      while (resultSet.goToNextRow()) {
        const record: QuickRecord = {
          id: resultSet.getString(resultSet.getColumnIndex('id')),
          type: resultSet.getString(resultSet.getColumnIndex('type')),
          title: resultSet.getString(resultSet.getColumnIndex('title')),
          content: resultSet.getString(resultSet.getColumnIndex('content')),
          date: resultSet.getString(resultSet.getColumnIndex('date')),
          tags: JSON.parse(resultSet.getString(resultSet.getColumnIndex('tags')) || '[]')
        };
        records.push(record);
      }
      
      resultSet.close();
      
      // 分离示例数据和普通数据，示例数据置顶
      const exampleRecords: QuickRecord[] = [];
      const normalRecords: QuickRecord[] = [];
      
      records.forEach(record => {
        if (record.tags.includes('示例')) {
          exampleRecords.push(record);
        } else {
          normalRecords.push(record);
        }
      });
      
      // 示例数据在前，普通数据在后
      return exampleRecords.concat(normalRecords);
    } catch (error) {
      console.error('获取备忘失败:', error);
      return [];
    }
  }

  // 保存新记录
  public async saveRecord(record: QuickRecord): Promise<boolean> {
    const store = this.dbManager.getRdbStore();
    if (!store) {
      throw new Error('数据库未初始化');
    }

    try {
      const now = this.dbManager.getCurrentTimestamp();
      const valueBucket: relationalStore.ValuesBucket = {
        id: record.id,
        type: record.type,
        title: record.title,
        content: record.content,
        date: record.date,
        tags: JSON.stringify(record.tags),
        created_at: now,
        updated_at: now
      };

      await store.insert('quick_records', valueBucket);
      return true;
    } catch (error) {
      console.error('保存备忘失败:', error);
      return false;
    }
  }

  // 更新记录
  public async updateRecord(record: QuickRecord): Promise<boolean> {
    const store = this.dbManager.getRdbStore();
    if (!store) {
      throw new Error('数据库未初始化');
    }

    try {
      const valueBucket: relationalStore.ValuesBucket = {
        type: record.type,
        title: record.title,
        content: record.content,
        date: record.date,
        tags: JSON.stringify(record.tags),
        updated_at: this.dbManager.getCurrentTimestamp()
      };

      const predicates = new relationalStore.RdbPredicates('quick_records');
      predicates.equalTo('id', record.id);
      
      const result = await store.update(valueBucket, predicates);
      return result > 0;
    } catch (error) {
      console.error('更新备忘失败:', error);
      return false;
    }
  }

  // 删除记录
  public async deleteRecord(recordId: string): Promise<boolean> {
    const store = this.dbManager.getRdbStore();
    if (!store) {
      throw new Error('数据库未初始化');
    }

    try {
      const predicates = new relationalStore.RdbPredicates('quick_records');
      predicates.equalTo('id', recordId);
      
      const result = await store.delete(predicates);
      return result > 0;
    } catch (error) {
      console.error('删除备忘失败:', error);
      return false;
    }
  }

  // 根据类型获取记录
  public async getRecordsByType(type: string): Promise<QuickRecord[]> {
    const store = this.dbManager.getRdbStore();
    if (!store) {
      throw new Error('数据库未初始化');
    }

    try {
      const predicates = new relationalStore.RdbPredicates('quick_records');
      predicates.equalTo('type', type).orderByDesc('date');
      
      const resultSet = await store.query(predicates);
      const records: QuickRecord[] = [];
      
      while (resultSet.goToNextRow()) {
        const record: QuickRecord = {
          id: resultSet.getString(resultSet.getColumnIndex('id')),
          type: resultSet.getString(resultSet.getColumnIndex('type')),
          title: resultSet.getString(resultSet.getColumnIndex('title')),
          content: resultSet.getString(resultSet.getColumnIndex('content')),
          date: resultSet.getString(resultSet.getColumnIndex('date')),
          tags: JSON.parse(resultSet.getString(resultSet.getColumnIndex('tags')) || '[]')
        };
        records.push(record);
      }
      
      resultSet.close();
      return records;
    } catch (error) {
      console.error('根据类型获取备忘失败:', error);
      return [];
    }
  }

  // 搜索记录
  public async searchRecords(keyword: string): Promise<QuickRecord[]> {
    const store = this.dbManager.getRdbStore();
    if (!store) {
      throw new Error('数据库未初始化');
    }

    try {
      const predicates = new relationalStore.RdbPredicates('quick_records');
      predicates.like('title', `%${keyword}%`)
        .or()
        .like('content', `%${keyword}%`)
        .orderByDesc('date');
      
      const resultSet = await store.query(predicates);
      const records: QuickRecord[] = [];
      
      while (resultSet.goToNextRow()) {
        const record: QuickRecord = {
          id: resultSet.getString(resultSet.getColumnIndex('id')),
          type: resultSet.getString(resultSet.getColumnIndex('type')),
          title: resultSet.getString(resultSet.getColumnIndex('title')),
          content: resultSet.getString(resultSet.getColumnIndex('content')),
          date: resultSet.getString(resultSet.getColumnIndex('date')),
          tags: JSON.parse(resultSet.getString(resultSet.getColumnIndex('tags')) || '[]')
        };
        records.push(record);
      }
      
      resultSet.close();
      return records;
    } catch (error) {
      console.error('搜索备忘失败:', error);
      return [];
    }
  }
}